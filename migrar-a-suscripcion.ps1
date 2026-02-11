# migrar-a-suscripcion.ps1
# Migra un cliente de Pago Único a Suscripción
# Realiza: git merge upstream/main + migraciones BD + update docs

param(
    [string]$NombreCortoCliente, # ej: esquina-dorada
    [string]$ClientesDir = "d:\Electrosun\clientes"
)

# ═══════════════════════════════════════════════
# FUNCIONES AUXILIARES
# ═══════════════════════════════════════════════

function Write-Step($num, $msg) { Write-Host "`n$num. $msg" -ForegroundColor Yellow }
function Write-Ok($msg) { Write-Host "   ✅ $msg" -ForegroundColor Green }
function Write-Err($msg) { Write-Host "   ❌ $msg" -ForegroundColor Red }

# ═══════════════════════════════════════════════
# VALIDACIONES
# ═══════════════════════════════════════════════

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🔄 Migración a Suscripción" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $NombreCortoCliente) {
    $repoList = Get-ChildItem $ClientesDir -Directory | Where-Object { $_.Name -like "pos-*" }
    Write-Host "Clientes encontrados:" -ForegroundColor Gray
    foreach ($repo in $repoList) {
        Write-Host " - $($repo.Name -replace 'pos-', '')"
    }
    Write-Host ""
    $NombreCortoCliente = Read-Host "Ingresa el nombre corto del cliente (ej: esquina-dorada)"
}

$repoName = "pos-$NombreCortoCliente"
$clientePath = Join-Path $ClientesDir $repoName

if (-not (Test-Path $clientePath)) {
    Write-Err "No se encuentra el directorio: $clientePath"
    exit 1
}

Set-Location $clientePath

# ═══════════════════════════════════════════════
# 1. CONFIGURAR UPSTREAM & MERGE
# ═══════════════════════════════════════════════

Write-Step "1" "Sincronizando código con versión más reciente..."

# Verificar si existe remote upstream
$remotes = git remote
if ($remotes -notcontains "upstream") {
    Write-Host "   Configurando upstream..." -ForegroundColor Gray
    git remote add upstream "https://github.com/paulvenci/bar-jordy.git"
}

Write-Host "   Obteniendo actualizaciones..." -ForegroundColor Gray
git fetch upstream

Write-Host "   Fusionando cambios (merge)..." -ForegroundColor Gray
# Intentar merge. Si hay conflictos, podría fallar y requerir intervención manual.
git merge upstream/main

if ($LASTEXITCODE -ne 0) {
    Write-Err "CONFLICTOS DETECTADOS en el merge."
    Write-Host "   Debes resolver los conflictos manualmente en: $clientePath" -ForegroundColor Yellow
    Write-Host "   1. Abre VS Code en esa carpeta" -ForegroundColor Gray
    Write-Host "   2. Resuelve conflictos" -ForegroundColor Gray
    Write-Host "   3. Commit cambios" -ForegroundColor Gray
    Write-Host "   4. Vuelve a ejecutar este script" -ForegroundColor Gray
    exit 1
}

Write-Ok "Código actualizado a la última versión"

# ═══════════════════════════════════════════════
# 2. EJECUTAR MIGRACIONES DE BD
# ═══════════════════════════════════════════════

Write-Step "2" "Aplicando actualizaciones de base de datos..."

# Leer credenciales del .env para conectar a Supabase
if (Test-Path "frontend\.env") {
    $envContent = Get-Content "frontend\.env"
    $sbUrl = ($envContent | Select-String "VITE_SUPABASE_URL=(.+)").Matches.Groups[1].Value
    $sbAnon = ($envContent | Select-String "VITE_SUPABASE_ANON_KEY=(.+)").Matches.Groups[1].Value
    
    Write-Host "   URL: $sbUrl" -ForegroundColor Gray
    
    # Aquí idealmente necesitaríamos la SERVICE_ROLE key para aplicar migraciones via API
    # Como no la guardamos en el .env por seguridad (usualmente), pedimos input
    
    Write-Host "   ⚠️ Para aplicar migraciones requerimos la SERVICE ROLE KEY" -ForegroundColor Yellow
    Write-Host "      (Obtenla de Supabase > Settings > API)" -ForegroundColor Gray
    $serviceKey = Read-Host "   Service Role Key (Enter para saltar si ya lo hiciste manual)"
    
    if ($serviceKey) {
        # Buscar archivos de migración nuevos
        # Esto es complejo de automatizar 100% sin un 'state' file de migraciones.
        # Por seguridad, aplicamos schema.sql completo (asumiendo idempotencia IF NOT EXISTS)
        # O mejor, avisamos al usuario.
        
        Write-Host "   Aplicando schema.sql (migraciones idempotentes)..." -ForegroundColor Gray
        
        $schemaPath = "supabase\schema.sql"
        if (Test-Path $schemaPath) {
            $schemaSQL = Get-Content $schemaPath -Raw
            
            $headers = @{
                "apikey"        = $serviceKey
                "Authorization" = "Bearer $serviceKey"
                "Content-Type"  = "application/json"
                "Prefer"        = "return=minimal"
            }
            
            try {
                $body = @{ query = $schemaSQL } | ConvertTo-Json
                Invoke-RestMethod -Uri "$sbUrl/rest/v1/rpc/exec_sql" `
                    -Method POST -Headers $headers -Body $body -ErrorAction Stop
                Write-Ok "Schema/Migraciones aplicadas correctamente"
            }
            catch {
                Write-Err "Error aplicando SQL: $($_.Exception.Message)"
                Write-Host "   Asegúrate de aplicar migraciones manualmente." -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "   Saltando aplicación automática de BD." -ForegroundColor Gray
    }
}

# ═══════════════════════════════════════════════
# 3. ACTUALIZAR DOCUMENTACIÓN & DEPLOY
# ═══════════════════════════════════════════════

Write-Step "3" "Actualizando ficha de cliente y desplegando..."

$clienteMd = "CLIENTE.md"
if (Test-Path $clienteMd) {
    $content = Get-Content $clienteMd -Raw
    # Reemplazar Pago Único por Suscripción
    $newContent = $content -replace "Pago Único \(Congelado\)", "Suscripción (Actualizable)"
    $newContent = $newContent -replace "- ⚠️ Versión congelada(.+)", "- ✅ Recibe actualizaciones automáticas via upstream"
    
    Set-Content -Path $clienteMd -Value $newContent -Encoding UTF8
    Write-Ok "Ficha CLIENTE.md actualizada"
}

# Deploy
Write-Host "   Subiendo cambios a GitHub (iniciará Deploy)..." -ForegroundColor Gray
git add .
git commit -m "chore: migración a plan suscripción"
git push origin main

Write-Ok "Cambios subidos. El deploy comenzará en breves minutos."

# ═══════════════════════════════════════════════
# RESUMEN
# ═══════════════════════════════════════════════

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  🎉 Migración Completada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Cliente: $NombreCortoCliente" -ForegroundColor White
Write-Host "  Plan:    Suscripción" -ForegroundColor White
Write-Host ""
Write-Host "  Recuerda:" -ForegroundColor Yellow
Write-Host "  1. Verificar que el deploy en GitHub Actions termine en verde" -ForegroundColor Gray
Write-Host "  2. Actualizar el registro de facturación del cliente" -ForegroundColor Gray
Write-Host ""
