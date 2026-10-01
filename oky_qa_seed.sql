-- OKY – Prueba técnica QA Analyst · Parte 2 (SQL)
-- Motor: MariaDB / MySQL 8. Ejecuta este script completo en una base NUEVA de pruebas.
-- Nunca lo ejecutes en un ambiente que no sea tuyo.

CREATE DATABASE IF NOT EXISTS oky_qa_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oky_qa_test;

DROP TABLE IF EXISTS coupon_redemptions;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS coupons;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(120) NOT NULL UNIQUE,
  created_at DATETIME NOT NULL
);

CREATE TABLE coupons (
  id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(30) NOT NULL UNIQUE,
  pct_off DECIMAL(5,2) NOT NULL,
  min_subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  expires_at DATETIME NOT NULL,
  max_uses_per_user INT NOT NULL DEFAULT 1
);

CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  coupon_id INT NULL,
  status VARCHAR(20) NOT NULL,
  created_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

CREATE TABLE order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  sku VARCHAR(20) NOT NULL,
  qty INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id)
);

CREATE TABLE coupon_redemptions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  coupon_id INT NOT NULL,
  user_id INT NOT NULL,
  order_id INT NOT NULL,
  redeemed_at DATETIME NOT NULL,
  FOREIGN KEY (coupon_id) REFERENCES coupons(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (order_id) REFERENCES orders(id)
);

INSERT INTO users (id, email, created_at) VALUES
(1, 'ana@example.test',    '2026-01-05 09:00:00'),
(2, 'beto@example.test',   '2026-01-12 10:30:00'),
(3, 'carla@example.test',  '2026-02-01 15:45:00'),
(4, 'diego@example.test',  '2026-02-20 08:10:00'),
(5, 'elena@example.test',  '2026-03-03 12:00:00'),
(6, 'fabio@example.test',  '2026-03-15 17:20:00');

INSERT INTO coupons (id, code, pct_off, min_subtotal, expires_at, max_uses_per_user) VALUES
(1, 'BIENVENIDO10', 10.00, 100.00, '2027-12-31 23:59:59', 1),
(2, 'VERANO15',     15.00, 200.00, '2026-06-30 23:59:59', 1),
(3, 'FIDELIDAD5',    5.00,   0.00, '2027-06-30 23:59:59', 3),
(4, 'PROMO20',      20.00, 500.00, '2026-08-31 23:59:59', 1);

INSERT INTO orders (id, user_id, subtotal, discount, total, coupon_id, status, created_at) VALUES
(1,  1, 150.00,  15.00, 135.00, 1,    'PAID',    '2026-03-10 10:15:00'),
(2,  2, 120.00,  12.00, 108.00, 1,    'PAID',    '2026-03-15 11:00:00'),
(3,  3, 250.00,   0.00, 250.00, NULL, 'PAID',    '2026-04-02 09:40:00'),
(4,  3,  60.00,   3.00,  57.00, 3,    'PAID',    '2026-04-20 14:05:00'),
(5,  4, 300.00,  45.00, 255.00, 2,    'PAID',    '2026-05-12 16:30:00'),
(6,  2, 200.00,  20.00, 180.00, 1,    'PAID',    '2026-06-01 13:25:00'),
(7,  5, 120.00,   0.00, 120.00, NULL, 'PAID',    '2026-06-10 10:00:00'),
(8,  5, 220.00,  33.00, 187.00, 2,    'PAID',    '2026-07-15 18:45:00'),
(9,  6,  80.00,   0.00,  80.00, NULL, 'PENDING', '2026-08-01 09:15:00'),
(10, 6,  90.00,   9.00,  81.00, 1,    'PAID',    '2026-08-20 11:50:00'),
(11, 5, 210.00,  31.50, 178.50, 2,    'PAID',    '2026-06-20 15:10:00'),
(12, 3, 550.00, 110.00, 440.00, 4,    'PAID',    '2026-09-10 12:35:00'),
(13, 3,  40.00,   2.00,  38.00, 3,    'PAID',    '2026-05-05 10:20:00'),
(14, 3,  30.00,   1.50,  28.50, 3,    'PAID',    '2026-05-25 19:00:00');

INSERT INTO order_items (id, order_id, sku, qty, unit_price) VALUES
(1,  1,  'SKU-A', 2,  50.00),
(2,  1,  'SKU-B', 1,  50.00),
(3,  2,  'SKU-C', 1, 120.00),
(4,  3,  'SKU-A', 3,  50.00),
(5,  3,  'SKU-D', 1,  90.00),
(6,  4,  'SKU-E', 2,  30.00),
(7,  5,  'SKU-F', 1, 300.00),
(8,  6,  'SKU-A', 4,  50.00),
(9,  7,  'SKU-B', 3,  50.00),
(10, 8,  'SKU-G', 2, 110.00),
(11, 10, 'SKU-H', 1,  90.00),
(12, 11, 'SKU-I', 3,  70.00),
(13, 12, 'SKU-J', 5, 110.00),
(14, 13, 'SKU-E', 1,  40.00),
(15, 14, 'SKU-K', 1,  30.00);

INSERT INTO coupon_redemptions (id, coupon_id, user_id, order_id, redeemed_at) VALUES
(1,  1, 1, 1,  '2026-03-10 10:15:00'),
(2,  1, 2, 2,  '2026-03-15 11:00:00'),
(3,  3, 3, 4,  '2026-04-20 14:05:00'),
(4,  2, 4, 5,  '2026-05-12 16:30:00'),
(5,  1, 2, 6,  '2026-06-01 13:25:00'),
(6,  2, 5, 11, '2026-06-20 15:10:00'),
(7,  2, 5, 8,  '2026-07-15 18:45:00'),
(8,  1, 6, 10, '2026-08-20 11:50:00'),
(9,  3, 3, 13, '2026-05-05 10:20:00'),
(10, 3, 3, 14, '2026-05-25 19:00:00'),
(11, 4, 3, 12, '2026-09-10 12:35:00');
