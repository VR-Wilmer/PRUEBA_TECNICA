-- Encuentra las órdenes cuyo subtotal no coincide con la suma de sus ítems (qty × unit_price). Incluye las órdenes que no tengan ítems.
SELECT 
    o.id AS order_id,
    o.subtotal AS stored_subtotal,
    COALESCE(SUM(oi.qty * oi.unit_price), 0) AS calculated_subtotal
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.subtotal
HAVING stored_subtotal != calculated_subtotal;

-- Encuentra los usuarios que superaron el máximo de usos permitido (max_uses_per_user) de algún cupón.
SELECT 
    cr.user_id,
    cr.coupon_id,
    c.code AS coupon_code,
    COUNT(cr.id) AS times_used,
    c.max_uses_per_user
FROM coupon_redemptions cr
JOIN coupons c ON cr.coupon_id = c.id
GROUP BY cr.user_id, cr.coupon_id, c.code, c.max_uses_per_user
HAVING COUNT(cr.id) > c.max_uses_per_user;

-- Encuentra los canjes realizados después de la fecha de vencimiento del cupón.
SELECT 
    cr.id AS redemption_id,
    c.id as coupon_id,
    cr.redeemed_at,
    c.expires_at AS coupon_expiration,
    cr.order_id
FROM coupon_redemptions cr
JOIN coupons c ON cr.coupon_id = c.id
WHERE cr.redeemed_at > c.expires_at;

-- Encuentra las órdenes cuyo subtotal es menor al mínimo requerido por el cupón aplicado.
SELECT 
    o.id AS order_id,
    c.code AS coupon_code,
    o.subtotal AS order_subtotal,
    c.min_subtotal
FROM orders o
JOIN coupons c ON o.coupon_id = c.id
WHERE o.subtotal < c.min_subtotal;

-- Prepara un escenario de prueba: un usuario nuevo con un carrito de exactamente Q100.00 y un cupón que venció ayer (calculado con funciones de fecha, no con una fecha fija). 
-- Escribe los INSERT/UPDATE dentro de una transacción y explica cómo lo revertirías y cómo evitas afectar otros datos.
START TRANSACTION;

-- 1. Crear el usuario
INSERT INTO users (email, created_at) 
VALUES ('test_cupon@ejemplo.com', NOW());
SET @user_id = LAST_INSERT_ID();

-- 2. Crear el cupón vencido
INSERT INTO coupons (code, pct_off, min_subtotal, expires_at, max_uses_per_user) 
VALUES ('VENCIDO10', 10.00, 50.00, NOW() - INTERVAL 1 DAY, 1);
SET @coupon_id = LAST_INSERT_ID();

-- 3. Crear la orden 
INSERT INTO orders (user_id, subtotal, discount, total, coupon_id, status, created_at) 
VALUES (@user_id, 100.00, 10.00, 90.00, @coupon_id, 'PENDING', NOW());
SET @order_id = LAST_INSERT_ID();

-- 4. Insertar los ítems de la orden 
INSERT INTO order_items (order_id, sku, qty, unit_price) 
VALUES (@order_id, 'SKU-PRUEBA-01', 1, 100.00);

-- 5. Registrar el canje
INSERT INTO coupon_redemptions (coupon_id, user_id, order_id, redeemed_at) 
VALUES (@coupon_id, @user_id, @order_id, NOW());

-- Para revertir los cambios y no afectar la BD, se ejecuta:
ROLLBACK;
-- Para guardar se debe ejecutar el commit de la transaccion
-- COMMIT;



-- Bonus. Para SELECT * FROM orders WHERE user_id = ? AND status = 'PAID' ORDER BY created_at DESC, propón un índice y explica cómo verificarías su efecto con EXPLAIN.

CREATE INDEX idx_orders_user_status_created ON orders (user_id, status, created_at);
EXPLAIN SELECT * FROM orders WHERE user_id = 5 AND status = 'PAID' ORDER BY created_at DESC;