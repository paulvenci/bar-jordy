# Script para capturar snapshot de base de datos de produccion
# Fecha: 2026-02-03
# Este script exporta los datos actuales para usarlos en el entorno de demo

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Capturando datos de produccion" -ForegroundColor Cyan
Write-Host "  Fecha: 2026-02-03" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que existe el archivo .env con las credenciales de produccion
$envFile = "d:\Electrosun\bar gordy\frontend\.env"
if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: No se encuentra el archivo .env en frontend/" -ForegroundColor Red
    Write-Host "Necesitas configurar las credenciales de Supabase de produccion." -ForegroundColor Yellow
    exit 1
}

# Leer las variables de entorno
Write-Host "1. Leyendo configuracion de Supabase..." -ForegroundColor Yellow
$envContent = Get-Content $envFile
$supabaseUrl = ($envContent | Select-String "VITE_SUPABASE_URL=(.+)").Matches.Groups[1].Value
$supabaseKey = ($envContent | Select-String "VITE_SUPABASE_ANON_KEY=(.+)").Matches.Groups[1].Value

if (-not $supabaseUrl -or -not $supabaseKey) {
    Write-Host "ERROR: No se pudieron leer las credenciales de Supabase del archivo .env" -ForegroundColor Red
    exit 1
}

Write-Host "   URL: $supabaseUrl" -ForegroundColor Gray
Write-Host "   Credenciales encontradas." -ForegroundColor Green

# Crear directorio para el snapshot
$snapshotDir = "d:\Electrosun\bar gordy\supabase\snapshots"
$snapshotFile = "$snapshotDir\snapshot-2026-02-03.sql"

if (-not (Test-Path $snapshotDir)) {
    New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null
}

Write-Host ""
Write-Host "2. Exportando datos de produccion..." -ForegroundColor Yellow
Write-Host "   Destino: $snapshotFile" -ForegroundColor Gray
Write-Host ""

# Crear archivo SQL con los datos
$sqlContent = @"
-- ========================================
-- Snapshot de Base de Datos - Bar Gordy
-- Fecha: 2026-02-03
-- ========================================
-- Este archivo contiene un snapshot de los datos de produccion
-- para usar en el entorno de demo.
-- Los datos estan congelados a la fecha indicada.

-- IMPORTANTE: Este script debe ejecutarse DESPUES de las migraciones
-- en una base de datos limpia de Supabase local.

BEGIN;

-- Nota: Este es un template. Los datos reales deben exportarse desde Supabase Studio.
-- Para exportar los datos:
-- 1. Abre Supabase Studio de produccion
-- 2. Ve a SQL Editor
-- 3. Ejecuta las siguientes consultas y guarda los resultados:

-- Exportar roles
-- SELECT * FROM roles;

-- Exportar categorias
-- SELECT * FROM categorias;

-- Exportar productos
-- SELECT * FROM productos;

-- Exportar mesas
-- SELECT * FROM mesas;

-- Exportar ventas (ultimos 30 dias para demo)
-- SELECT * FROM ventas WHERE fecha >= CURRENT_DATE - INTERVAL '30 days';

-- Exportar items de venta relacionados
-- SELECT vi.* FROM venta_items vi
-- JOIN ventas v ON vi.venta_id = v.id
-- WHERE v.fecha >= CURRENT_DATE - INTERVAL '30 days';

-- Exportar retiros (ultimos 30 dias)
-- SELECT * FROM retiros WHERE fecha >= CURRENT_DATE - INTERVAL '30 days';

-- Exportar usuarios (sin passwords sensibles)
-- SELECT id, nombre, email, pin, activo, rol_id, created_at, updated_at
-- FROM usuarios;

COMMIT;

-- ========================================
-- Instrucciones de uso:
-- ========================================
-- 1. Exporta los datos desde Supabase Studio (produccion)
-- 2. Reemplaza este contenido con los INSERT statements generados
-- 3. Ejecuta este archivo en tu Supabase local:
--    supabase db reset
--    psql -h localhost -p 54322 -U postgres -d postgres -f supabase/snapshots/snapshot-2026-02-03.sql
"@

Set-Content -Path $snapshotFile -Value $sqlContent -Encoding UTF8

Write-Host "   Archivo template creado." -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  INSTRUCCIONES PARA COMPLETAR" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para capturar los datos reales de produccion:" -ForegroundColor White
Write-Host ""
Write-Host "OPCION A - Usando Supabase Studio (Recomendado):" -ForegroundColor Cyan
Write-Host "1. Abre tu Supabase Studio de produccion" -ForegroundColor White
Write-Host "2. Ve a: Database > Backups" -ForegroundColor White
Write-Host "3. Crea un backup manual" -ForegroundColor White
Write-Host "4. Descarga el backup" -ForegroundColor White
Write-Host "5. Guardalo como: $snapshotFile" -ForegroundColor White
Write-Host ""
Write-Host "OPCION B - Usando pg_dump (Avanzado):" -ForegroundColor Cyan
Write-Host "1. Obten la cadena de conexion desde Supabase Dashboard" -ForegroundColor White
Write-Host "2. Ejecuta:" -ForegroundColor White
Write-Host "   pg_dump postgresql://... --data-only --inserts > snapshot.sql" -ForegroundColor Gray
Write-Host ""
Write-Host "OPCION C - Exportacion manual de tablas:" -ForegroundColor Cyan
Write-Host "1. Abre el archivo: $snapshotFile" -ForegroundColor White
Write-Host "2. Sigue las instrucciones dentro del archivo" -ForegroundColor White
Write-Host "3. Exporta cada tabla desde SQL Editor" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Archivo template creado" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proximo paso:" -ForegroundColor Yellow
Write-Host "Ejecutar: .\3-configurar-demo.ps1" -ForegroundColor White
Write-Host ""
