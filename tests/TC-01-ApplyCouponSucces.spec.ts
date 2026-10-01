import { test, expect } from '@playwright/test';

// extract the numeric amount from texts like "Q 99.99" or "− Q 5.00"
const toNumber = (text: string | null) => parseFloat((text ?? '').replace(/[^\d.]/g, '') || '0');

test.beforeEach(async ({ request }) => {
  // cart and coupon state live on the server, reset it so the coupon is not "already used"
  await request.post('/graphql', { data: { query: 'mutation{ resetDemo }' } });
});

test('FIDELIDAD5 applies a 5% discount to the total', async ({ page }) => {
  await page.goto('/');
  // wait for the cart to load before reading the subtotal
  await expect(page.locator('#sub')).toHaveText(/Q \d/);
  const subtotalValue = toNumber(await page.locator('#sub').textContent());

  await page.getByRole('textbox', { name: 'Código de descuento' }).fill('FIDELIDAD5');
  await page.getByRole('button', { name: 'Aplicar' }).click();
  await expect(page.locator('#cpn')).toHaveText('FIDELIDAD5');

  const expectedDiscount = Math.round(subtotalValue * 0.05 * 100) / 100;
  const expectedTotal = Math.round((subtotalValue - subtotalValue * 0.05) * 100) / 100;

  const discountValue = toNumber(await page.locator('#disc').textContent());
  const totalValue = toNumber(await page.locator('#tot').textContent());

  // the discount shown must be 5% of the subtotal
  expect(discountValue).toBeCloseTo(expectedDiscount, 2);
  // total = subtotal - (subtotal * 5%)
  expect(totalValue).toBeCloseTo(expectedTotal, 2);
});
