import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router';
import { describe, expect, it } from 'vitest';
import { ptBR } from '../../src/i18n/pt-BR.ts';
import { AppRoutes } from '../../src/router.tsx';

describe('AppRoutes', () => {
  it('deve mostrar a página provisória quando qualquer rota é aberta', () => {
    render(
      <MemoryRouter initialEntries={['/projetos']}>
        <AppRoutes />
      </MemoryRouter>,
    );

    expect(screen.getByRole('heading', { name: ptBR.placeholder.title })).toBeInTheDocument();
  });
});
