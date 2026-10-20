import { prisma } from '../../src/lib/prisma.js';

export async function resetDatabase() {
  await prisma.$executeRaw`TRUNCATE projects, project_features, technologies, project_technologies, project_images, case_studies, case_study_sections CASCADE`;
}

export function localized(ptBR: string, en: string) {
  return { 'pt-BR': ptBR, en };
}

export async function createProject(slug = 'app-de-tarefas') {
  return prisma.project.create({
    data: {
      slug,
      title: localized('App de tarefas', 'To-do app'),
      description: localized('Aplicativo para organizar tarefas', 'An app to organize tasks'),
    },
  });
}

export function image(projectId: string, position: number, isCover: boolean) {
  return {
    projectId,
    position,
    isCover,
    url: `https://res.cloudinary.com/demo/image/upload/portfolio/img-${position}.png`,
    providerPublicId: `portfolio/img-${position}`,
    altText: localized('Tela inicial do app', 'App home screen'),
  };
}
