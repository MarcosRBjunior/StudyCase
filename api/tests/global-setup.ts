import { execFileSync } from 'node:child_process';
import { loadTestEnv } from './helpers/load-test-env.js';

// Aplica as migrações no banco de teste antes de rodar a suíte.
export default function setup() {
  loadTestEnv();
  execFileSync('npx', ['prisma', 'migrate', 'deploy'], { stdio: 'inherit', env: process.env });
}
