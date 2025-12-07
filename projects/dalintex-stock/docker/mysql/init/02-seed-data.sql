-- ============================================================================
-- Script de Seeders - DALINTEX Stock Management
-- Datos de ejemplo para desarrollo y testing
-- ============================================================================

USE dalintex_stock_dev;

-- ============================================================================
-- Datos de ejemplo: Categorías
-- ============================================================================

INSERT INTO categories (name, description, parent_id) VALUES
('Láminas Metálicas', 'Láminas de diversos metales y espesores', NULL),
('Acero Inoxidable', 'Productos de acero inoxidable', 1),
('Aluminio', 'Productos de aluminio', 1),
('Herramientas', 'Herramientas de taller', NULL),
('Consumibles', 'Materiales de consumo', NULL),
('Accesorios', 'Accesorios varios', NULL)
ON DUPLICATE KEY UPDATE name=name;

-- ============================================================================
-- Datos de ejemplo: Proveedores
-- ============================================================================

INSERT INTO suppliers (name, contact_name, email, phone, address, city, tax_id) VALUES
('Aceros del Norte SA', 'Juan Pérez', 'ventas@acerosnorte.com.ar', '+54 11 4444-5555', 'Av. Industrial 1234', 'Buenos Aires', '30-12345678-9'),
('Metalúrgica Central', 'María González', 'info@metalurgicacentral.com', '+54 11 5555-6666', 'Calle Metalúrgica 567', 'Rosario', '33-87654321-0'),
('Distribuidora Inox', 'Carlos Rodríguez', 'carlos@distribuidorainox.com', '+54 351 444-7777', 'Zona Industrial KM 8', 'Córdoba', '30-11223344-5'),
('Aluminio Premium SRL', 'Ana Martínez', 'ventas@alupremium.com.ar', '+54 11 6666-7777', 'Parque Industrial Norte', 'San Martín', '33-55667788-9'),
('Herramientas del Sur', 'Roberto Silva', 'info@herrasur.com', '+54 221 888-9999', 'Av. Talleres 890', 'La Plata', '30-99887766-3')
ON DUPLICATE KEY UPDATE name=name;

-- ============================================================================
-- Datos de ejemplo: Productos
-- ============================================================================

INSERT INTO products (sku, name, description, category_id, supplier_id, unit_price, cost_price, stock_quantity, min_stock, max_stock, unit, barcode) VALUES
-- Láminas de Acero Inoxidable
('INOX-304-1MM-1X2', 'Lámina Inox 304 1mm 1x2m', 'Lámina de acero inoxidable 304, espesor 1mm, medida 1x2 metros', 2, 3, 45000.00, 35000.00, 25, 5, 100, 'unidad', '7798123456001'),
('INOX-304-2MM-1X2', 'Lámina Inox 304 2mm 1x2m', 'Lámina de acero inoxidable 304, espesor 2mm, medida 1x2 metros', 2, 3, 85000.00, 70000.00, 15, 5, 50, 'unidad', '7798123456002'),
('INOX-316-1MM-1X2', 'Lámina Inox 316 1mm 1x2m', 'Lámina de acero inoxidable 316, espesor 1mm, medida 1x2 metros', 2, 3, 55000.00, 42000.00, 20, 5, 80, 'unidad', '7798123456003'),

-- Láminas de Aluminio
('ALU-1MM-1X2', 'Lámina Aluminio 1mm 1x2m', 'Lámina de aluminio, espesor 1mm, medida 1x2 metros', 3, 4, 28000.00, 22000.00, 30, 10, 100, 'unidad', '7798123456004'),
('ALU-2MM-1X2', 'Lámina Aluminio 2mm 1x2m', 'Lámina de aluminio, espesor 2mm, medida 1x2 metros', 3, 4, 48000.00, 38000.00, 18, 5, 60, 'unidad', '7798123456005'),
('ALU-3MM-1X2', 'Lámina Aluminio 3mm 1x2m', 'Lámina de aluminio, espesor 3mm, medida 1x2 metros', 3, 4, 65000.00, 52000.00, 12, 5, 40, 'unidad', '7798123456006'),

-- Herramientas
('DISC-CORTE-115', 'Disco de Corte 115mm', 'Disco de corte para amoladora 115mm', 4, 5, 850.00, 650.00, 100, 20, 500, 'unidad', '7798123456007'),
('DISC-CORTE-230', 'Disco de Corte 230mm', 'Disco de corte para amoladora 230mm', 4, 5, 1500.00, 1200.00, 75, 20, 300, 'unidad', '7798123456008'),
('SIERRA-METAL', 'Sierra Manual para Metal', 'Sierra manual para corte de metal', 4, 5, 3500.00, 2800.00, 15, 5, 50, 'unidad', '7798123456009'),

-- Consumibles
('ELEC-INOX-2MM', 'Electrodo Inox 2mm', 'Electrodo para soldadura de acero inoxidable 2mm', 5, 1, 450.00, 350.00, 200, 50, 1000, 'unidad', '7798123456010'),
('ELEC-INOX-3MM', 'Electrodo Inox 3mm', 'Electrodo para soldadura de acero inoxidable 3mm', 5, 1, 550.00, 450.00, 150, 50, 800, 'unidad', '7798123456011'),
('LIJA-GRANO-80', 'Lija Grano 80', 'Lija de grano 80 para metal', 5, 5, 120.00, 90.00, 300, 100, 1000, 'unidad', '7798123456012'),

-- Accesorios
('GUANTES-SOLDADOR', 'Guantes de Soldador', 'Guantes de cuero para soldadura', 6, 5, 2500.00, 1800.00, 40, 10, 100, 'par', '7798123456013'),
('MASCARA-SOLDAR', 'Máscara de Soldar Fotosensible', 'Máscara de soldar con visor fotosensible automático', 6, 5, 15000.00, 12000.00, 10, 3, 30, 'unidad', '7798123456014'),
('REMACHES-ALU-4MM', 'Remaches Aluminio 4mm', 'Caja x100 remaches de aluminio 4mm', 6, 4, 800.00, 600.00, 50, 20, 200, 'caja', '7798123456015')
ON DUPLICATE KEY UPDATE sku=sku;

-- ============================================================================
-- Datos de ejemplo: Clientes
-- ============================================================================

INSERT INTO customers (name, contact_name, email, phone, address, city, tax_id) VALUES
('Construcciones del Sur SA', 'Pedro Gómez', 'compras@consursur.com', '+54 11 3333-4444', 'Av. Construcción 456', 'Buenos Aires', '30-11111111-1'),
('Metalúrgica Express', 'Laura Fernández', 'laura@metalexpress.com', '+54 351 222-3333', 'Polígono Industrial 12', 'Córdoba', '33-22222222-2'),
('Talleres Modernos SRL', 'Diego López', 'diego@talleresmodernos.com', '+54 11 7777-8888', 'Zona Industrial Este', 'Avellaneda', '30-33333333-3'),
('Estructuras Metálicas del Litoral', 'Sofía Castro', 'ventas@estructuraslitoral.com', '+54 341 444-5555', 'Parque Industrial Sur', 'Rosario', '33-44444444-4'),
('Industrias del Acero', 'Martín Ruiz', 'martin@indacero.com.ar', '+54 221 555-6666', 'Av. Metalúrgica 789', 'Ensenada', '30-55555555-5')
ON DUPLICATE KEY UPDATE name=name;

-- ============================================================================
-- Datos de ejemplo: Movimientos de Stock (histórico)
-- ============================================================================

-- Ingresos iniciales
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, user_id) VALUES
(1, 'in', 30, 'purchase_order', 1001, 'Compra inicial - Proveedor Distribuidora Inox', 1),
(2, 'in', 20, 'purchase_order', 1001, 'Compra inicial - Proveedor Distribuidora Inox', 1),
(3, 'in', 25, 'purchase_order', 1001, 'Compra inicial - Proveedor Distribuidora Inox', 1),
(4, 'in', 50, 'purchase_order', 1002, 'Compra inicial - Proveedor Aluminio Premium', 1),
(5, 'in', 30, 'purchase_order', 1002, 'Compra inicial - Proveedor Aluminio Premium', 1),
(7, 'in', 150, 'purchase_order', 1003, 'Compra inicial - Proveedor Herramientas del Sur', 1);

-- Salidas (ventas)
INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, user_id) VALUES
(1, 'out', 5, 'sale_order', 2001, 'Venta a Construcciones del Sur SA', 1),
(2, 'out', 5, 'sale_order', 2001, 'Venta a Construcciones del Sur SA', 1),
(4, 'out', 20, 'sale_order', 2002, 'Venta a Metalúrgica Express', 1),
(7, 'out', 50, 'sale_order', 2003, 'Venta a Talleres Modernos SRL', 1);

-- ============================================================================
-- Datos de ejemplo: Pedidos
-- ============================================================================

INSERT INTO orders (order_number, customer_id, status, total_amount, notes, user_id) VALUES
('PED-2024-001', 1, 'delivered', 130000.00, 'Pedido completado - Láminas inox', 1),
('PED-2024-002', 2, 'delivered', 560000.00, 'Pedido completado - Láminas aluminio', 1),
('PED-2024-003', 3, 'processing', 42500.00, 'Pedido en proceso - Discos de corte', 1),
('PED-2024-004', 4, 'pending', 85000.00, 'Pedido pendiente - Láminas inox', 1)
ON DUPLICATE KEY UPDATE order_number=order_number;

-- ============================================================================
-- Datos de ejemplo: Items de Pedidos
-- ============================================================================

INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
-- PED-2024-001
(1, 1, 5, 45000.00, 225000.00),
(1, 2, 5, 85000.00, 425000.00),

-- PED-2024-002
(2, 4, 20, 28000.00, 560000.00),

-- PED-2024-003
(3, 7, 50, 850.00, 42500.00),

-- PED-2024-004
(4, 2, 1, 85000.00, 85000.00)
ON DUPLICATE KEY UPDATE order_id=order_id;

-- ============================================================================
-- Mensaje de confirmación
-- ============================================================================
SELECT 'Seeders aplicados exitosamente!' AS message;
SELECT
    (SELECT COUNT(*) FROM categories) AS 'Categorías',
    (SELECT COUNT(*) FROM suppliers) AS 'Proveedores',
    (SELECT COUNT(*) FROM products) AS 'Productos',
    (SELECT COUNT(*) FROM customers) AS 'Clientes',
    (SELECT COUNT(*) FROM orders) AS 'Pedidos';
