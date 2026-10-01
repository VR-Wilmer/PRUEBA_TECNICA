# Prueba Técnica QA – OKY Demo Shop

Pruebas automatizadas del carrito de compras y cupones de descuento de **OKY Demo Shop** (API GraphQL + UI web).

El proyecto contiene:

| Archivo / carpeta | Descripción |
| --- | --- |
| `server.js` | Sandbox de la aplicación bajo prueba (caja negra, **no modificar**). |
| `tests/` | Pruebas E2E con Playwright. |
| `queries.sql` | Consultas SQL de validación de datos. |
| `playwright.config.ts` | Configuración de Playwright. |

---

## 1. Requisitos previos

- [Node.js](https://nodejs.org/) **18 o superior** (probado con v22) y npm.

Verifica la instalación:

```bash
node -v
npm -v
```

## 2. Instalación

Desde la carpeta raíz del proyecto:

```bash
# 1. Instalar las dependencias del proyecto
npm install

# 2. Instalar los navegadores que usa Playwright
npx playwright install
```

> Si solo necesitas Chromium: `npx playwright install chromium`

## 3. Levantar la aplicación

Las pruebas necesitan que el servidor esté corriendo en `http://localhost:4000`.
En una terminal **aparte** ejecuta:

```bash
npm start
```

Deja esa terminal abierta. Puedes comprobar que funciona abriendo <http://localhost:4000> en el navegador.

> Para usar otro puerto: `PORT=5000 npm start` (en PowerShell: `$env:PORT=5000; npm start`).
> En ese caso actualiza también `baseURL` en `playwright.config.ts`.

## 4. Ejecutar las pruebas E2E (Playwright)

Con el servidor corriendo, en otra terminal:

```bash
# Ejecutar las pruebas en Chromium
npm test

# Ejecutar en Chromium, Firefox y WebKit
npm run test:all

# Ejecutar una prueba específica
npx playwright test tests/TC-01-ApplyCouponSucces.spec.ts --project=chromium

# Ver el navegador mientras corren las pruebas
npx playwright test --project=chromium --workers=1 --headed

# Modo interactivo (UI de Playwright)
npx playwright test --ui
```

> **Importante:** el carrito y los cupones se guardan en el servidor, así que todas las pruebas comparten el mismo estado.
> Por eso se ejecutan con `--workers=1` (una a la vez). Cada prueba reinicia la demo (`resetDemo`) antes de empezar.

### Ver el reporte

```bash
npm run report
```

Abre el reporte HTML con el resultado de cada prueba. Cuando una prueba falla, en `test-results/` se guarda una captura de pantalla.

### Casos automatizados

| Caso | Archivo | Qué valida |
| --- | --- | --- |
| TC-01 | `tests/TC-01-ApplyCouponSucces.spec.ts` | Al aplicar `FIDELIDAD5` el descuento es el 5 % del subtotal y `total = subtotal - (subtotal × 5 %)`. |
| TC-02 | `tests/TC-02-CouponAlreadyApplied.spec.ts` | Aplicar `FIDELIDAD5` por segunda vez devuelve el error `Código ya utilizado` y el descuento solo se aplica una vez. |

## 5. Solución de problemas

| Problema | Solución |
| --- | --- |
| `Test timeout of 30000ms exceeded` o `ECONNREFUSED` | El servidor no está corriendo. Ejecuta `npm start` en otra terminal. |
| `Executable doesn't exist` | Faltan los navegadores: `npx playwright install`. |
| `Código ya utilizado` en la primera aplicación | Reinicia la demo con el enlace **Reiniciar demo** en la página. |
| Pruebas que fallan de forma intermitente | Ejecútalas con `--workers=1`: todas comparten el mismo estado en el servidor. |
| `EADDRINUSE: port 4000` | Ya hay otro proceso usando el puerto 4000. Ciérralo o usa otro puerto (`PORT`). |
