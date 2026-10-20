// Configuração do Prisma CLI (Prisma 7). O CLI usa DIRECT_URL (no Supabase, o pooler em modo
// sessão, porta 5432). O cliente da aplicação usa DATABASE_URL pelo driver adapter (src/lib/prisma.ts).
import { defineConfig } from 'prisma/config';

try {
  process.loadEnvFile();
} catch {
  // Sem .env: as variáveis vêm do ambiente (CI, Vercel).
}

const directUrl = process.env.DIRECT_URL;

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: { path: 'prisma/migrations' },
  // `prisma generate` não precisa de URL; migrate e studio precisam.
  ...(directUrl ? { datasource: { url: directUrl } } : {}),
});
