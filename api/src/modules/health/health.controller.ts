import type { Request, Response } from 'express';

// Fase 0: só confirma que a API responde. A verificação do banco (SELECT 1) entra na Fase 1.
export function getHealth(_req: Request, res: Response) {
  res.set('Cache-Control', 'no-store');
  res.status(200).json({ status: 'ok' });
}
