# Script para configurar el entorno de demo
# Fecha: 2026-02-03

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configurando entorno de DEMO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$demoDir = "d:\Electrosun\bar-gordy-demo"

# Verificar que existe el directorio demo
if (-not (Test-Path $demoDir)) {
    Write-Host "ERROR: No se encuentra el directorio demo: $demoDir" -ForegroundColor Red
    Write-Host "Ejecuta primero: .\1-clonar-proyecto-demo.ps1" -ForegroundColor Yellow
    exit 1
}

Set-Location $demoDir

Write-Host "1. Inicializando Supabase local..." -ForegroundColor Yellow
if (-not (Test-Path "supabase\config.toml")) {
    supabase init
    Write-Host "   Supabase inicializado." -ForegroundColor Green
} else {
    Write-Host "   Supabase ya está inicializado." -ForegroundColor Gray
}

Write-Host ""
Write-Host "2. Iniciando Supabase local..." -ForegroundColor Yellow
Write-Host "   (Primera vez puede tomar varios minutos descargando imágenes Docker)" -ForegroundColor Gray
Write-Host ""

supabase start

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: No se pudo iniciar Supabase local." -ForegroundColor Red
    Write-Host "Verifica que Docker Desktop esté corriendo." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "3. Obteniendo credenciales de Supabase local..." -ForegroundColor Yellow
$status = supabase status

# Extraer URL y anon key del status
$apiUrl = ($status | Select-String "API URL: (.+)").Matches.Groups[1].Value
$anonKey = ($status | Select-String "anon key: (.+)").Matches.Groups[1].Value

if (-not $apiUrl -or -not $anonKey) {
    Write-Host "ERROR: No se pudieron obtener las credenciales de Supabase." -ForegroundColor Red
    exit 1
}

Write-Host "   API URL: $apiUrl" -ForegroundColor Gray
Write-Host "   Anon Key obtenida." -ForegroundColor Green

Write-Host ""
Write-Host "4. Creando archivo .env.local..." -ForegroundColor Yellow
$envContent = @"
# Configuración de Supabase Local para DEMO
# Generado automáticamente el 2026-02-03

VITE_SUPABASE_URL=$apiUrl
VITE_SUPABASE_ANON_KEY=$anonKey
"@

Set-Content -Path "frontend\.env.local" -Value $envContent -Encoding UTF8
Write-Host "   Archivo .env.local creado en frontend/" -ForegroundColor Green

Write-Host ""
Write-Host "5. Aplicando migraciones de base de datos..." -ForegroundColor Yellow
supabase db push

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ADVERTENCIA: Hubo problemas al aplicar migraciones." -ForegroundColor Yellow
    Write-Host "   Puedes aplicarlas manualmente desde Studio: http://localhost:54323" -ForegroundColor Gray
}

Write-Host ""
Write-Host "6. Cargando snapshot de datos de producción..." -ForegroundColor Yellow
$snapshotFile = "d:\Electrosun\bar gordy\supabase\snapshots\snapshot-2026-02-03.sql"

if (Test-Path $snapshotFile) {
    # Verificar si el snapshot tiene datos reales o es solo el template
    $snapshotContent = Get-Content $snapshotFile -Raw
    if ($snapshotContent -match "BEGIN;" -and $snapshotContent -match "INSERT INTO") {
        Write-Host "   Ejecutando snapshot de datos..." -ForegroundColor Gray
        
        # Ejecutar el snapshot en la base de datos local
        $env:PGPASSWORD = "postgres"
        psql -h localhost -p 54322 -U postgres -d postgres -f $snapshotFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   Datos de producción cargados exitosamente." -ForegroundColor Green
        } else {
            Write-Host "   ADVERTENCIA: Hubo problemas al cargar los datos." -ForegroundColor Yellow
        }
    } else {
        Write-Host "   El snapshot es un template. Completa la exportación de datos primero." -ForegroundColor Yellow
        Write-Host "   Ejecuta: .\2-capturar-datos-produccion.ps1" -ForegroundColor Gray
    }
} else {
    Write-Host "   No se encontró snapshot de datos." -ForegroundColor Yellow
    Write-Host "   Ejecuta: .\2-capturar-datos-produccion.ps1" -ForegroundColor Gray
}

Write-Host ""
Write-Host "7. Creando usuario administrador de demo..." -ForegroundColor Yellow
$createUserSQL = @"
-- Crear usuario de demo
DO `$`$
BEGIN
    -- Insertar en auth.users si no existe
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        confirmation_token,
        recovery_token,
        email_change_token_new,
        email_change
    )
    SELECT
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        'demo@bargordy.local',
        crypt('demo1234', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    WHERE NOT EXISTS (
        SELECT 1 FROM auth.users WHERE email = 'demo@bargordy.local'
    );

    -- Insertar en tabla usuarios si no existe
    INSERT INTO usuarios (id, nombre, email, pin, activo, rol_id)
    SELECT
        (SELECT id FROM auth.users WHERE email = 'demo@bargordy.local'),
        'Usuario Demo',
        'demo@bargordy.local',
        '1234',
        true,
        (SELECT id FROM roles WHERE nombre = 'Administrador')
    WHERE NOT EXISTS (
        SELECT 1 FROM usuarios WHERE email = 'demo@bargordy.local'
    );
END
`$`$;
"@

$tempSQLFile = "$env:TEMP\create-demo-user.sql"
Set-Content -Path $tempSQLFile -Value $createUserSQL -Encoding UTF8

$env:PGPASSWORD = "postgres"
psql -h localhost -p 54322 -U postgres -d postgres -f $tempSQLFile | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "   Usuario demo creado: demo@bargordy.local / PIN: 1234" -ForegroundColor Green
} else {
    Write-Host "   ADVERTENCIA: Hubo problemas al crear el usuario." -ForegroundColor Yellow
    Write-Host "   Puedes crearlo manualmente desde Studio." -ForegroundColor Gray
}

Remove-Item $tempSQLFile -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "8. Instalando dependencias de Node.js..." -ForegroundColor Yellow
Set-Location "frontend"
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ERROR: Hubo problemas al instalar dependencias." -ForegroundColor Red
    exit 1
}

Write-Host "   Dependencias instaladas." -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Configuración completada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Entorno de demo listo en: $demoDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para iniciar la aplicación de demo:" -ForegroundColor Yellow
Write-Host "  cd `"$demoDir\frontend`"" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Credenciales de acceso:" -ForegroundColor Yellow
Write-Host "  Email: demo@bargordy.local" -ForegroundColor White
Write-Host "  PIN: 1234" -ForegroundColor White
Write-Host ""
Write-Host "Accesos:" -ForegroundColor Yellow
Write-Host "  App: http://localhost:5173" -ForegroundColor White
Write-Host "  Studio: http://localhost:54323" -ForegroundColor White
Write-Host ""
Write-Host "Para resetear datos entre demos:" -ForegroundColor Yellow
Write-Host "  supabase db reset" -ForegroundColor White
Write-Host ""
