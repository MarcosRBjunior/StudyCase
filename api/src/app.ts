import express from 'express';
import { healthRouter } from './modules/health/health.routes.js';

export function createApp() {
  const app = express();

  app.disable('x-powered-by');

  app.use('/api/v1/health', healthRouter);

  return app;
}

export const app = createApp();
