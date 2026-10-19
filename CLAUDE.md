# StudyCase — Portfólio com estudos de caso (Projeto 09)

- Repositório: https://github.com/MarcosRBjunior/StudyCase.git
- Especificação completa: `docs/especificacao.md`. É a fonte da verdade: leia a seção citada antes de implementar.
- Fase atual: **Fase 0 — Fundação** (ver "PLANO DE IMPLEMENTAÇÃO" na especificação).

## O que é

Portfólio full-stack que mostra uma faixa de miniaturas de projetos e, abaixo dela, o detalhe do projeto selecionado. O detalhe traz nome, descrição, features, stack com "como foi feito", imagens e o estudo de caso. Todo o conteúdo e toda a interface existem em português e em inglês.

## Stack (não trocar)

- **web:** React 19, Vite, TypeScript e React Router v8 em modo declarativo. Importe de `react-router` e `react-router/dom`, nunca de `react-router-dom`.
- **api:** Node.js LTS, Express 5 e TypeScript. Roda como função no Vercel, e `src/index.ts` exporta o `app`.
- **ORM:** Prisma 7, sempre com `prisma@7` e `@prisma/client@7` fixados no `package.json`. Use `npx prisma@7 ...` e nunca instale o Prisma 8.
- **Banco:** PostgreSQL no Supabase, usado só como banco. Não use supabase-js, Auth, Storage nem a Data API.
- **Demais ferramentas:**
  - imagens: Cloudinary
  - validação: Zod
  - logs: pino
  - testes: Vitest, Supertest, Testing Library, MSW e Playwright

## Estrutura

- `web/` (front) e `api/` (back) são independentes. Não há pacote compartilhado entre eles, e a comunicação é só por HTTP/JSON.
- **api:**
  - `src/modules/<recurso>/` segue o fluxo routes → controller → service → repository (Prisma);
  - `src/middlewares/` guarda request-id, auth-admin, validate, error-handler e not-found;
  - `src/lib/` guarda os clientes únicos.
- **web:**
  - `src/features/<feature>/` guarda components, hooks, `api.ts` e `types.ts`;
  - `src/components/ui/` guarda a UI genérica, sem chamadas à API;
  - `src/i18n/` guarda os dicionários.
- **docs/:** especificação, ADRs (uma por decisão D-xx) e diagramas Mermaid.

## Regras de domínio (não violar)

- **Tabelas:** são 7 — `projects`, `project_features`, `technologies`, `project_technologies`, `project_images`, `case_studies` e `case_study_sections`. O schema está na seção 11 da especificação.
- **Textos (RN-14):** todo texto exibido ao visitante é `LocalizedText`, um `jsonb` no formato `{ "pt-BR": string, "en": string }`, com as duas chaves obrigatórias. Os limites de tamanho valem para cada idioma. A decisão D-19 ainda está aberta: siga este formato, a menos que o Marcos decida outro.
- **Slug:** único, em kebab-case, igual nos dois idiomas e imutável depois de criado.
- **Composição de cada projeto:**
  - pelo menos 1 imagem e exatamente 1 capa;
  - de 1 a 10 features;
  - 1 estudo de caso com no mínimo uma seção `PROCESS` e uma `CHALLENGE`.
- **Tecnologias:** formam um catálogo único por slug, com upsert. "React" e "react" são a mesma tecnologia.
- **Criação atômica:** projeto e filhos são gravados juntos, dentro de `$transaction`.
- **Imagens:** só são aceitas URLs de `https://res.cloudinary.com/<cloud-name>/`. O banco guarda `public_id` e URL, nunca o arquivo.
- **Ordem da lista:** `display_order` crescente e, no empate, `created_at` decrescente.

## API

- O prefixo é `/api/v1`. As rotas do MVP são `GET /health`, `GET /projects`, `GET /projects/:slug` e `POST /projects`.
- **GET:**
  - aceita `lang=pt-BR|en`, com padrão `pt-BR`; qualquer outro valor devolve `400`;
  - responde com o texto já resolvido, o campo `lang` e o cabeçalho `Content-Language`;
  - usa `Cache-Control: public, s-maxage=60, stale-while-revalidate=600`.
- **POST:**
  - exige `Authorization: Bearer <ADMIN_TOKEN>`, comparado com `crypto.timingSafeEqual`;
  - aceita corpo de até 100 KB e tem limite de taxa;
  - devolve `201` com `Location`.
- **Erros:**
  - formato sempre `{ "error": { "code", "message", "details?", "requestId" } }`, gerado por um handler central;
  - códigos listados na seção 12;
  - nunca devolva stack trace em produção.
- A API se recusa a iniciar sem `ADMIN_TOKEN` e sem as variáveis obrigatórias, que são validadas com Zod.

## Front-end

- **Rotas:** `/` (redireciona conforme a preferência salva ou o idioma do navegador), `/projetos`, `/projetos/:slug`, `/en/projects`, `/en/projects/:slug` e `*`. As telas `/admin/*` ficam para depois do MVP.
- **Tela única:** a faixa de miniaturas fica no topo, o detalhe embaixo e o estudo de caso no fim, com a âncora `#estudo-de-caso`.
- **Busca de dados:**
  - fica em hooks (`useProjects`, `useProject(slug)`) com `useState`, `useEffect` e `AbortController`, repassando `lang`;
  - componentes de UI só recebem props.
- **Textos de interface:** nenhum texto literal no JSX. Tudo vem de `src/i18n/pt-BR.ts` e `src/i18n/en.ts` (mesmas chaves) pelo hook `useT()`.
- **Markdown:** use `react-markdown` sem HTML bruto e nunca `dangerouslySetInnerHTML`.
- **Token de admin:** nunca em variável `VITE_*`, porque essas variáveis vão para o bundle público.
- **Estados obrigatórios:** loading (skeleton), vazio, erro com "Tentar novamente" e 404, todos nos dois idiomas.

## Banco e Supabase

- **`DATABASE_URL`:**
  - aponta para o pooler em modo transação (porta 6543), com `pgbouncer=true` e `sslmode=require`;
  - é usada pelo cliente via `@prisma/adapter-pg`, com pool de 1 conexão e um cliente por instância.
- **`DIRECT_URL`:**
  - aponta para o pooler em modo sessão (porta 5432);
  - é usada só pelo Prisma CLI, em `prisma.config.ts`;
  - nunca use a conexão direta do Supabase, que é só IPv6.
- **Migrações:**
  - a função `is_localized`, os `CHECK`, o índice parcial de capa e o RLS entram editando a migração gerada com `npx prisma@7 migrate dev --create-only`;
  - nunca rode `migrate dev` contra o Supabase;
  - em produção, as migrações rodam só pelo workflow `migrate.yml`.
- **Testes de integração:** rodam no Postgres local (`docker-compose`), nunca no Supabase.

## Convenções

- **Código:** TypeScript em modo estrito, ESM, ESLint (flat config) e Prettier.
- **Nomes:**
  - componentes em `PascalCase.tsx` e demais arquivos em `kebab-case.ts`;
  - tabelas em `snake_case` no plural;
  - models do Prisma em PascalCase com `@@map`;
  - JSON em camelCase.
- **Git:** GitHub Flow, com branches `feat/`, `fix/`, `docs/` e `chore/`, Conventional Commits e PR só com o CI verde.
- **Segredos:** `.env` nunca é commitado. Mantenha o `.env.example` atualizado e nunca registre `Authorization` ou segredos nos logs.

## Como trabalhar

1. Siga o PLANO DE IMPLEMENTAÇÃO fase por fase, com uma história (US-x.y) por branch e por PR.
2. Antes de codar uma história, leia os RF, RN e CA que ela cita e escreva os testes TC-xx listados nela.
3. Não implemente nada fora do escopo (editar/excluir, filtros, SSR, analytics, terceiro idioma) sem pedido explícito.
4. Se algo não estiver definido na especificação, pergunte em vez de inventar uma regra.
5. Ao concluir uma história, marque as tarefas dela e diga quais critérios de aceite foram verificados.

## Comandos (a criar na Fase 0)

- `npm run dev -w api` e `npm run dev -w web`
- `npm run lint`, `npm run typecheck`, `npm test` e `npm run build`
- `docker compose up -d db`
- `npx prisma@7 migrate dev --create-only` e `npx prisma@7 generate`
