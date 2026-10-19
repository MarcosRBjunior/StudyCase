import { Route, Routes } from 'react-router';
import { PlaceholderPage } from './pages/PlaceholderPage.tsx';

// Fase 0: rota provisória. As rotas /projetos e /en/projects entram na Fase 3.
export function AppRoutes() {
  return (
    <Routes>
      <Route path="*" element={<PlaceholderPage />} />
    </Routes>
  );
}
