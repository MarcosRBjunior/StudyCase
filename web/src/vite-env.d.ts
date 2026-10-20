/// <reference types="vite/client" />

// Variáveis VITE_* vão para o bundle público: nunca coloque segredos aqui.
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_CLOUDINARY_CLOUD_NAME: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
