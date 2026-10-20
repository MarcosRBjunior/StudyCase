import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../generated/prisma/client.js';

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error('DATABASE_URL não definida');
}

// Um cliente por instância da função, com pool de 1 conexão: em serverless, quem multiplexa
// as conexões é o pooler do Supabase em modo transação.
const adapter = new PrismaPg({ connectionString, max: 1 });

export const prisma = new PrismaClient({ adapter });
