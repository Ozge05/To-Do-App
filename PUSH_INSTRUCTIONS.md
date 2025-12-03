Projenizi GitHub'a push etmek (Windows)

Bu proje köküne, tek komutla GitHub'a push etmeyi kolaylaştıran bir PowerShell betiği eklendi: scripts/push-to-github.ps1

Gereksinimler
- Git (https://git-scm.com/downloads)
- GitHub hesabı
- Personal Access Token (PAT) — repo kapsamı yeterlidir.

PAT oluşturma (özet)
1. https://github.com/settings/tokens adresine gidin (classic veya fine‑grained token kullanabilirsiniz).
2. En azından repo yazma izni verin.
3. Token'ı güvenli bir yerde saklayın.

Kullanım
1. Windows'ta PowerShell açın.
2. Proje kök klasörüne gidin:
   cd "C:\Projects\intellij Projects\todo project"
3. Gerekirse token'ınızı oturum değişkeni olarak ayarlayın:
   $env:GITHUB_TOKEN = "<PAT>"
4. Betiği çalıştırın:
   pwsh -File .\scripts\push-to-github.ps1 -RepoUrl "https://github.com/Ozge05/To-Do-App.git" -Username "<GitHubKullaniciAdiniz>"

Notlar
- Varsayılan dal adı main'dir. Farklı dal isterseniz -Branch parametresiyle değiştirin.
- İlk çalıştırmada git init ve ilk commit otomatik yapılır (değişiklik varsa).
- Zaten commit'leriniz varsa, betik yalnızca push yapacaktır.
- Hata alırsanız, depoya yazma izninizin olduğundan emin olun ve RepoUrl'in doğru olduğuna bakın.
