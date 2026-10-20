# StudyCase — Portfólio com estudos de caso

Portfólio full-stack bilíngue (português e inglês): uma faixa de miniaturas de projetos e, abaixo dela, o detalhe do projeto selecionado com features, stack, imagens e estudo de caso.

> Em construção: Fase 0 (fundação). A especificação completa está em [`docs/especificacao.md`](docs/especificacao.md).

## Estrutura

| Pasta   | O que é                                                                |
| ------- | ---------------------------------------------------------------------- |
| `web/`  | Front-end: React 19, Vite, TypeScript, React Router v8                 |
| `api/`  | Back-end: Node.js, Express 5, TypeScript (função serverless no Vercel) |
| `docs/` | Especificação, ADRs e diagramas                                        |

`web` e `api` são independentes e conversam só por HTTP/JSON. Os npm workspaces servem só para rodar scripts a partir da raiz.

## Requisitos

- Node.js 22.22+ ou 24 (veja `.nvmrc`)
- Docker, para o Postgres local

## Como rodar

```bash
npm install

# Postgres local (porta 5437 no host; mude com POSTGRES_PORT)
docker compose up -d db

# Variáveis de ambiente
cp api/.env.example api/.env
cp api/.env.test.example api/.env.test
cp web/.env.example web/.env

# Aplica as migrações no banco de desenvolvimento
npm run db:migrate -w api

# Em dois terminais
npm run dev -w api   # http://localhost:3000/api/v1/health
npm run dev -w web   # http://localhost:5173
```

## Scripts da raiz

| Comando             | O que faz                           |
| ------------------- | ----------------------------------- |
| `npm run lint`      | ESLint em `api` e `web`             |
| `npm run typecheck` | `tsc` em modo estrito nos dois apps |
| `npm test`          | Vitest nos dois apps                |
| `npm run build`     | Build de produção dos dois apps     |
| `npm run format`    | Prettier no repositório             |

Os testes da `api` usam o banco `study_case_test` do Postgres local (criado pelo `docker compose`) e aplicam as migrações sozinhos antes de rodar. Nunca aponte o `.env.test` para o Supabase.

## Banco de dados

Prisma 7 com versão fixada (`prisma@7.10.1`). Não instale o Prisma 8: a CLI dele não lê `schema.prisma`.

| Comando                            | O que faz                                              |
| ---------------------------------- | ------------------------------------------------------ |
| `npm run db:migrate -w api`        | Aplica as migrações no banco local                     |
| `npm run db:migrate:create -w api` | Gera uma migração sem aplicar, para editar o SQL antes |
| `npm run db:generate -w api`       | Gera o cliente em `api/src/generated/prisma`           |
| `npm run db:studio -w api`         | Abre o Prisma Studio                                   |

A função `is_localized`, os `CHECK`, o índice parcial de capa e o RLS são escritos à mão na migração gerada com `--create-only`. Nunca rode `migrate dev` contra o Supabase.
