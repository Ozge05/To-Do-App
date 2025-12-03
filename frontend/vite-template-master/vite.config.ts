import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // '/api' ile başlayan istekleri proxy'le
      '/api': {
        target: 'http://localhost:8080', // Backend sunucunuzun adresi
        changeOrigin: true, // Host header'ını hedef URL ile eşleşecek şekilde değiştirir
      },
    },
  },
});