import { describe, expect, it } from 'vitest';
import { buildCloudinaryUrl } from '../../src/lib/cloudinary-url.ts';

const base = 'https://res.cloudinary.com/demo/image/upload';

describe('buildCloudinaryUrl', () => {
  it('deve gerar a miniatura com no máximo 400 px de largura', () => {
    const url = buildCloudinaryUrl({
      cloudName: 'demo',
      publicId: 'portfolio/app-de-tarefas/capa',
      variant: 'thumbnail',
    });

    expect(url).toBe(`${base}/c_fill,w_400,h_225,f_auto,q_auto/portfolio/app-de-tarefas/capa`);
  });

  it('deve gerar a imagem de detalhe com 1200 px de largura', () => {
    const url = buildCloudinaryUrl({
      cloudName: 'demo',
      publicId: 'portfolio/app-de-tarefas/capa',
      variant: 'detail',
    });

    expect(url).toBe(`${base}/w_1200,f_auto,q_auto/portfolio/app-de-tarefas/capa`);
  });

  it('deve codificar cada segmento do publicId sem codificar as barras', () => {
    const url = buildCloudinaryUrl({
      cloudName: 'demo',
      publicId: 'portfolio/meu app/tela #1',
      variant: 'detail',
    });

    expect(url).toBe(`${base}/w_1200,f_auto,q_auto/portfolio/meu%20app/tela%20%231`);
  });

  it('deve falhar quando o cloud name não está definido', () => {
    expect(() =>
      buildCloudinaryUrl({ cloudName: '', publicId: 'portfolio/x', variant: 'detail' }),
    ).toThrow();
  });
});
