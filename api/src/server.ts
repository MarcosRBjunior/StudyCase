// Entrada para desenvolvimento local.
import { app } from './app.js';

const port = Number(process.env.PORT ?? 3000);

app.listen(port, () => {
  console.log(`api ouvindo em http://localhost:${port}`);
});
