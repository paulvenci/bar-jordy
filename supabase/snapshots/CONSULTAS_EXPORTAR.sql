-- =====================================================
-- CONSULTAS PARA EXPORTAR DATOS DE PRODUCCION
-- Fecha: 2026-02-03
-- =====================================================
-- INSTRUCCIONES:
-- 1. Abre Supabase Studio de produccion
-- 2. Ve a SQL Editor
-- 3. Ejecuta CADA consulta por separado
-- 4. Copia los resultados en el archivo snapshot-2026-02-03.sql
-- =====================================================

-- =====================================================
-- CONSULTA 1: ROLES
-- =====================================================
SELECT 
  'INSERT INTO roles (id, nombre, descripcion, es_sistema, activo, created_at, updated_at) VALUES (' ||
  '''' || id || ''', ' ||
  '''' || REPLACE(nombre, '''', '''''') || ''', ' ||
  COALESCE('''' || REPLACE(descripcion, '''', '''''') || '''', 'NULL') || ', ' ||
  COALESCE(es_sistema::text, 'false') || ', ' ||
  activo || ', ' ||
  '''' || created_at || ''', ' ||
  COALESCE('''' || updated_at || '''', 'NULL') || ') ON CONFLICT (nombre) DO NOTHING;'
FROM roles;

-- =====================================================
-- CONSULTA 2: PERMISOS
-- =====================================================
SELECT 
  'INSERT INTO permisos (id, codigo, nombre, descripcion, modulo, created_at) VALUES (' ||
  '''' || id || ''', ' ||
  '''' || codigo || ''', ' ||
  '''' || REPLACE(nombre, '''', '''''') || ''', ' ||
  COALESCE('''' || REPLACE(descripcion, '''', '''''') || '''', 'NULL') || ', ' ||
  '''' || modulo || ''', ' ||
  '''' || created_at || ''') ON CONFLICT (codigo) DO NOTHING;'
FROM permisos;

-- =====================================================
-- CONSULTA 3: ROL_PERMISOS
-- =====================================================
SELECT 
  'INSERT INTO rol_permisos (id, rol_id, permiso_id, created_at) VALUES (' ||
  '''' || id || ''', ' ||
  '''' || rol_id || ''', ' ||
  '''' || permiso_id || ''', ' ||
  '''' || created_at || ''') ON CONFLICT (rol_id, permiso_id) DO NOTHING;'
FROM rol_permisos;

-- =====================================================
-- CONSULTA 4: CATEGORIAS
-- =====================================================
SELECT 
  'INSERT INTO categorias (id, nombre, descripcion, created_at) VALUES (' ||
  '''' || id || ''', ' ||
  '''' || REPLACE(nombre, '''', '''''') || ''', ' ||
  COALESCE('''' || REPLACE(descripcion, '''', '''''') || '''', 'NULL') || ', ' ||
  '''' || created_at || ''') ON CONFLICT (nombre) DO NOTHING;'
FROM categorias;

-- =====================================================
-- CONSULTA 5: PRODUCTOS
-- =====================================================
SELECT 
  'INSERT INTO productos (id, nombre, codigo, categoria_id, descripcion, foto, valor_costo, valor_venta, tipo_producto, stock_actual, stock_minimo, activo, created_at, updated_at) VALUES (' ||
  '''' || id || ''', ' ||
  '''' || REPLACE(nombre, '''', '''''') || ''', ' ||
  '''' || codigo || ''', ' ||
  COALESCE('''' || categoria_id || '''', 'NULL') || ', ' ||
  COALESCE('''' || REPLACE(descripcion, '''', '''''') || '''', 'NULL') || ', ' ||
  COALESCE('''' || foto || '''', 'NULL') || ', ' ||
  valor_costo || ', ' ||
  valor_venta || ', ' ||
  '''' || tipo_producto || ''', ' ||
  stock_actual || ', ' ||
  stock_minimo || ', ' ||
  activo || ', ' ||
  '''' || created_at || ''', ' ||
  '''' || updated_at || ''') ON CONFLICT (codigo) DO NOTHING;'
FROM productos;

-- =====================================================
-- CONSULTA 6: MESAS
-- =====================================================
SELECT 
  'INSERT INTO mesas (id, numero, capacidad, estado, descripcion, created_at) VALUES (' ||
  '''' || id || ''', ' ||
  numero || ', ' ||
  COALESCE(capacidad::text, '4') || ', ' ||
  '''' || COALESCE(estado, 'LIBRE') || ''', ' ||
  COALESCE('''' || REPLACE(descripcion, '''', '''''') || '''', 'NULL') || ', ' ||
  '''' || created_at || ''') ON CONFLICT (numero) DO NOTHING;'
FROM mesas;

-- =====================================================
-- CONSULTA 7: VENTAS (ultimos 60 dias)
-- =====================================================
SELECT 
  'INSERT INTO ventas (id, numero, fecha, subtotal, iva, total, metodo_pago, estado, cliente_nombre, descuento, mesa_id, created_at) VALUES (' ||
  '''' || id || ''', ' ||
  numero || ', ' ||
  '''' || fecha || ''', ' ||
  subtotal || ', ' ||
  iva || ', ' ||
  total || ', ' ||
  COALESCE('''' || metodo_pago || '''', 'NULL') || ', ' ||
  '''' || estado || ''', ' ||
  COALESCE('''' || REPLACE(cliente_nombre, '''', '''''') || '''', 'NULL') || ', ' ||
  COALESCE(descuento::text, '0') || ', ' ||
  COALESCE('''' || mesa_id || '''', 'NULL') || ', ' ||
  '''' || created_at || ''');'
FROM ventas 
WHERE fecha >= CURRENT_DATE - INTERVAL '60 days';

-- =====================================================
-- CONSULTA 8: ITEMS DE VENTA (ultimos 60 dias)
-- =====================================================
SELECT 
  'INSERT INTO items_venta (id, venta_id, producto_id, nombre_producto, cantidad, precio_unitario, subtotal, costo) VALUES (' ||
  '''' || iv.id || ''', ' ||
  '''' || iv.venta_id || ''', ' ||
  COALESCE('''' || iv.producto_id || '''', 'NULL') || ', ' ||
  '''' || REPLACE(iv.nombre_producto, '''', '''''') || ''', ' ||
  iv.cantidad || ', ' ||
  iv.precio_unitario || ', ' ||
  iv.subtotal || ', ' ||
  iv.costo || ');'
FROM items_venta iv
JOIN ventas v ON v.id = iv.venta_id
WHERE v.fecha >= CURRENT_DATE - INTERVAL '60 days';

-- =====================================================
-- CONSULTA 9: CONFIGURACION
-- =====================================================
SELECT 
  'INSERT INTO configuracion (clave, valor, tipo_dato, descripcion) VALUES (' ||
  '''' || clave || ''', ' ||
  '''' || REPLACE(valor, '''', '''''') || ''', ' ||
  COALESCE('''' || tipo_dato || '''', 'NULL') || ', ' ||
  COALESCE('''' || REPLACE(descripcion, '''', '''''') || '''', 'NULL') || ') ON CONFLICT (clave) DO NOTHING;'
FROM configuracion;

-- =====================================================
-- CONSULTA 10: USUARIOS (sin datos sensibles de auth)
-- Los usuarios de auth.users se crean manualmente
-- =====================================================
SELECT 
  '-- Usuario: ' || nombre || E'\n' ||
  '-- IMPORTANTE: Primero crear en auth.users con email: ' || email || E'\n' ||
  'INSERT INTO usuarios (id, nombre, email, pin, activo, rol_id, turno_actual, created_at, updated_at) VALUES (' ||
  '''' || id || ''', ' ||
  '''' || REPLACE(nombre, '''', '''''') || ''', ' ||
  '''' || email || ''', ' ||
  COALESCE('''' || pin || '''', 'NULL') || ', ' ||
  activo || ', ' ||
  COALESCE('''' || rol_id || '''', 'NULL') || ', ' ||
  COALESCE('''' || turno_actual || '''', 'NULL') || ', ' ||
  '''' || created_at || ''', ' ||
  COALESCE('''' || updated_at || '''', 'NULL') || ');'
FROM usuarios;
