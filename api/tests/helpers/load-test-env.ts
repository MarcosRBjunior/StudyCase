// Carrega api/.env.test quando existe; no CI as variáveis já vêm do workflow.
export function loadTestEnv() {
  try {
    process.loadEnvFile(new URL('../../.env.test', import.meta.url));
  } catch {
    // Sem .env.test: usa o ambiente.
  }
}
