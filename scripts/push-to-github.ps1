<#
.SYNOPSIS
  Projeyi belirtilen GitHub deposuna push etmek için yardımcı betik.

.DESCRIPTION
  Bu PowerShell betiği, yerel projeyi bir Git deposu olarak hazırlar (gerekirse),
  remote origin'i ayarlar ve değişiklikleri seçilen dala (branch) push eder.

.PARAMETER RepoUrl
  Hedef GitHub repo URL'si. Örn: https://github.com/Ozge05/To-Do-App.git

.PARAMETER Username
  GitHub kullanıcı adınız. PAT ile birlikte kimlik doğrulama için kullanılır.

.PARAMETER Pat
  GitHub Personal Access Token (PAT). Parametre olarak vermek yerine GITHUB_TOKEN
  ortam değişkeninden de alınabilir.

.PARAMETER Branch
  Push yapılacak dal adı. Varsayılan: main

.PARAMETER CommitMessage
  Yapılacak commit için mesaj. Varsayılan: "Initial commit"

.EXAMPLE
  pwsh -File .\scripts\push-to-github.ps1 -RepoUrl "https://github.com/Ozge05/To-Do-App.git" -Username "Ozge05" -Pat "<PAT>"

.NOTES
  - PAT'i parametre olarak vermek yerine, güvenlik için bir seferlik oturum değişkeni olarak
    $env:GITHUB_TOKEN içinde tutmanız önerilir.
  - Bu betik Windows PowerShell ve PowerShell 7+ ile uyumludur.
#>

param(
  [string]$RepoUrl = "https://github.com/Ozge05/To-Do-App.git",
  [Parameter(Mandatory=$true)][string]$Username,
  [string]$Pat,
  [string]$Branch = "main",
  [string]$CommitMessage = "Initial commit"
)

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Git kontrolü
try {
  git --version | Out-Null
} catch {
  Write-Err "Git yüklü değil ya da PATH içinde değil. Lütfen Git kurun: https://git-scm.com/downloads"
  exit 1
}

# PAT'i ortam değişkeninden almayı dene
if (-not $Pat -and $env:GITHUB_TOKEN) {
  $Pat = $env:GITHUB_TOKEN
}

if (-not $Pat) {
  Write-Err "PAT bulunamadı. -Pat parametresini verin veya GITHUB_TOKEN ortam değişkenini ayarlayın."
  exit 1
}

# Çalışma dizini repo kökü olmalı (betik proje kökünden çağrılmalı)
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
Set-Location $repoRoot
Write-Info "Repo kökü: $repoRoot"

# .git var mı?
if (-not (Test-Path -Path (Join-Path $repoRoot ".git"))) {
  Write-Info "Git deposu bulunamadı, git init çalıştırılıyor..."
  git init | Out-Null
  # Varsayılan dal adı
  git symbolic-ref HEAD "refs/heads/$Branch" | Out-Null
}

# Kullanıcı bilgileri konfigüre edilmemişse uyarı (zorunlu değil)
try {
  $existingName = git config user.name
  $existingEmail = git config user.email
} catch { }
if (-not $existingName) { git config user.name $Username | Out-Null }
if (-not $existingEmail) { git config user.email "$Username@users.noreply.github.com" | Out-Null }

# Remote origin ayarla/güncelle
$hasOrigin = $false
try {
  $originUrl = git remote get-url origin 2>$null
  if ($originUrl) { $hasOrigin = $true }
} catch {}

# PAT içeren URL oluştur
$safeRepoUrl = $RepoUrl.Trim()
if ($safeRepoUrl -notmatch "^https?://") {
  Write-Err "RepoUrl http(s) ile başlamalı. Verilen: $safeRepoUrl"
  exit 1
}

# URL'i https://USERNAME:PAT@github.com/owner/repo.git formatına dönüştür
$uri = [System.Uri]::new($safeRepoUrl)
$authPart = "$Username`:$Pat@"
$pushUrl = "{0}://{1}{2}{3}" -f $uri.Scheme, $authPart, $uri.Host, $uri.PathAndQuery

if ($hasOrigin) {
  Write-Info "Mevcut origin güncelleniyor..."
  git remote set-url origin $pushUrl | Out-Null
} else {
  Write-Info "Origin ekleniyor..."
  git remote add origin $pushUrl | Out-Null
}

# Dosyaları ekle ve commit et (değişiklik varsa)
git add -A | Out-Null

# Değişiklik var mı kontrolü
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
  Write-Warn "Commitlenecek bir değişiklik yok. Mevcut HEAD push edilecek."
} else {
  Write-Info "Commit işlemi yapılıyor..."
  git commit -m $CommitMessage | Out-Null
}

# Dal oluştur/checkout (varsa atla)
try {
  git rev-parse --verify $Branch 2>$null | Out-Null
} catch {
  Write-Info "Dal '$Branch' oluşturuluyor..."
  git checkout -b $Branch | Out-Null
}

# Uzak depoda aynı branch var mı kontrol et ve varsa birleştir (README gibi ön-commitler için)
Write-Info "Uzak depoda '$Branch' dalı var mı kontrol ediliyor..."
$remoteHasBranch = $false
try {
  $heads = git ls-remote --heads origin $Branch
  if (-not [string]::IsNullOrWhiteSpace($heads)) { $remoteHasBranch = $true }
} catch { }

if ($remoteHasBranch) {
  Write-Info "Uzakta '$Branch' bulundu. Fetch + pull (allow-unrelated-histories) yapılıyor..."
  git fetch origin $Branch | Out-Null
  # İlişkisiz geçmişler için izin vererek merge/pull
  git pull origin $Branch --allow-unrelated-histories
}

Write-Info "GitHub'a push ediliyor: origin $Branch"
try {
  git push -u origin $Branch
  if ($LASTEXITCODE -ne 0) { throw "Push başarısız" }
  Write-Host "\nBaşarılı: Proje GitHub deposuna push edildi." -ForegroundColor Green
} catch {
  Write-Err "Push sırasında hata oluştu. $_"
  Write-Warn "Remote URL doğru mu? Repo mevcut ve sizin yazma izniniz var mı?"
  exit 1
}
