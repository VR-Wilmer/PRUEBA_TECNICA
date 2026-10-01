import { test, expect } from '@playwright/test';

// extract the numeric amount from texts like "Q 99.99" or "− Q 5.00"
const toNumber = (text: string | null) => parseFloat((text ?? '').replace(/[^\d.]/g, '') || '0');

test.beforeEach(async ({ request }) => {
  // cart and coupon state live on the server, reset it so the first apply succeeds
  await request.post('/graphql', { data: { query: 'mutation{ resetDemo }' } });
});

test('FIDELIDAD5 cannot be applied twice', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('textbox', { name: 'Código de descuento' }).fill('FIDELIDAD5');
  await page.getByRole('button', { name: 'Aplicar' }).click();
  // make sure the first apply finished before applying again
  await expect(page.locator('#cpn')).toHaveText('FIDELIDAD5');

  const [response] = await Promise.all([
    page.waitForResponse((res) =>
      res.url().includes('/graphql') &&
      res.request().method() === 'POST' &&
      res.status() === 200
    ),
    page.getByRole('button', { name: 'Aplicar' }).click(),
  ]);

  const body = await response.json();

  expect(body.errors?.[0]?.message).toBe('Código ya utilizado');
  expect(body.errors?.[0]?.path).toContain('applyCoupon');
  expect(body.data.applyCoupon).toBeNull();

  // the discount must still be applied only once: total = subtotal - (subtotal * 5%)
  const subtotalValue = toNumber(await page.locator('#sub').textContent());
  const discountValue = toNumber(await page.locator('#disc').textContent());
  const totalValue = toNumber(await page.locator('#tot').textContent());

  expect(discountValue).toBeCloseTo(Math.round(subtotalValue * 0.05 * 100) / 100, 2);
  expect(totalValue).toBeCloseTo(Math.round((subtotalValue - subtotalValue * 0.05) * 100) / 100, 2);
});
