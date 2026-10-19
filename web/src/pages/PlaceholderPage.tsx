import { ptBR } from '../i18n/pt-BR.ts';

export function PlaceholderPage() {
  return (
    <main>
      <h1>{ptBR.placeholder.title}</h1>
      <p>{ptBR.placeholder.body}</p>
    </main>
  );
}
