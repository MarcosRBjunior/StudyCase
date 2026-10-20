import { afterAll, beforeEach, describe, expect, it } from 'vitest';
import { prisma } from '../../src/lib/prisma.js';
import { createProject, image, localized, resetDatabase } from '../helpers/db.js';

describe('constraints do banco', () => {
  beforeEach(resetDatabase);
  afterAll(() => prisma.$disconnect());

  describe('capa do projeto (RN-05)', () => {
    it('deve aceitar uma capa e outras imagens sem capa', async () => {
      const project = await createProject();

      await prisma.projectImage.createMany({
        data: [
          image(project.id, 0, true),
          image(project.id, 1, false),
          image(project.id, 2, false),
        ],
      });

      expect(await prisma.projectImage.count({ where: { projectId: project.id } })).toBe(3);
    });

    it('deve falhar quando o mesmo projeto recebe duas capas', async () => {
      const project = await createProject();
      await prisma.projectImage.create({ data: image(project.id, 0, true) });

      await expect(
        prisma.projectImage.create({ data: image(project.id, 1, true) }),
      ).rejects.toThrow();
      expect(await prisma.projectImage.count({ where: { projectId: project.id } })).toBe(1);
    });

    it('deve permitir uma capa em cada projeto', async () => {
      const a = await createProject('projeto-a');
      const b = await createProject('projeto-b');

      await prisma.projectImage.create({ data: image(a.id, 0, true) });
      await prisma.projectImage.create({ data: image(b.id, 0, true) });

      expect(await prisma.projectImage.count({ where: { isCover: true } })).toBe(2);
    });
  });

  describe('LocalizedText (RN-14, TC-22)', () => {
    const description = localized('Aplicativo para organizar tarefas', 'An app to organize tasks');

    it('deve rejeitar texto com chave extra', async () => {
      await expect(
        prisma.project.create({
          data: {
            slug: 'chave-extra',
            title: { 'pt-BR': 'App de tarefas', en: 'To-do app', es: 'App de tareas' },
            description,
          },
        }),
      ).rejects.toThrow();
    });

    it('deve rejeitar texto com um idioma vazio', async () => {
      await expect(
        prisma.project.create({
          data: { slug: 'idioma-vazio', title: localized('App de tarefas', ''), description },
        }),
      ).rejects.toThrow();
    });

    it('deve rejeitar texto sem um dos idiomas', async () => {
      await expect(
        prisma.project.create({
          data: { slug: 'sem-ingles', title: { 'pt-BR': 'App de tarefas' }, description },
        }),
      ).rejects.toThrow();
    });

    it('deve rejeitar texto fora do limite de tamanho em um idioma', async () => {
      await expect(
        prisma.project.create({
          data: { slug: 'titulo-curto', title: localized('App de tarefas', 'ab'), description },
        }),
      ).rejects.toThrow();
    });
  });

  describe('slug (RN-07)', () => {
    it('deve rejeitar slug fora do formato kebab-case', async () => {
      await expect(createProject('App_De_Tarefas')).rejects.toThrow();
    });

    it('deve rejeitar slug repetido', async () => {
      await createProject('app-de-tarefas');

      await expect(createProject('app-de-tarefas')).rejects.toThrow();
    });
  });

  it('deve apagar os filhos em cascata ao excluir o projeto', async () => {
    const project = await createProject();
    await prisma.projectImage.create({ data: image(project.id, 0, true) });

    await prisma.project.delete({ where: { id: project.id } });

    expect(await prisma.projectImage.count()).toBe(0);
  });
});
