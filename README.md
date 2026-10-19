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
cp web/.env.example web/.env

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
