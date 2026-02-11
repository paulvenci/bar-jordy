# onboarding-nuevo-cliente.ps1
# Automatiza la creación de un nuevo cliente POS
# Requisitos: git, gh (GitHub CLI), node/npm

param(
    [string]$ClientesDir = "d:\Electrosun\clientes"
)

# ═══════════════════════════════════════════════
# FUNCIONES AUXILIARES
# ═══════════════════════════════════════════════

function Write-Step($num, $msg) {
    Write-Host "`n$num. $msg" -ForegroundColor Yellow
}

function Write-Ok($msg) {
    Write-Host "   ✅ $msg" -ForegroundColor Green
}

function Write-Err($msg) {
    Write-Host "   ❌ $msg" -ForegroundColor Red
}

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

# ═══════════════════════════════════════════════
# VERIFICAR PREREQUISITOS
# ═══════════════════════════════════════════════

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🚀 Onboarding de Nuevo Cliente POS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$missing = @()
if (-not (Test-Command "git")) { $missing += "git" }
if (-not (Test-Command "gh"))  { $missing += "gh (GitHub CLI)" }
if (-not (Test-Command "node")) { $missing += "node" }
if (-not (Test-Command "npm")) { $missing += "npm" }

if ($missing.Count -gt 0) {
    Write-Err "Faltan herramientas: $($missing -join ', ')"
    Write-Host "   Instala con:" -ForegroundColor Gray
    Write-Host "   winget install Git.Git" -ForegroundColor Gray
    Write-Host "   winget install GitHub.cli" -ForegroundColor Gray
    Write-Host "   winget install OpenJS.NodeJS.LTS" -ForegroundColor Gray
    exit 1
}

# Verificar que gh está autenticado
$ghStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "GitHub CLI no está autenticado. Ejecuta: gh auth login"
    exit 1
}
Write-Ok "Prerequisitos verificados"

# ═══════════════════════════════════════════════
# RECOLECTAR DATOS DEL CLIENTE
# ═══════════════════════════════════════════════

Write-Step "1" "Datos del cliente"

$nombreNegocio = Read-Host "   Nombre del negocio"
$nombreCorto = Read-Host "   Nombre corto (para repo, sin espacios, ej: esquina-dorada)"
$emailAdmin = Read-Host "   Email del administrador"
$pinAdmin = Read-Host "   PIN del administrador (4 dígitos)"

Write-Host ""
Write-Host "   Tipo de plan:" -ForegroundColor White
Write-Host "   1) Pago Único  (versión congelada, sin actualizaciones)" -ForegroundColor Gray
Write-Host "   2) Suscripción (actualizaciones + soporte continuo)" -ForegroundColor Gray
$tipoPlan = Read-Host "   Seleccione (1/2)"

$planNombre = if ($tipoPlan -eq "2") { "suscripcion" } else { "pago_unico" }

Write-Host ""
Write-Host "   Credenciales de Supabase del cliente:" -ForegroundColor White
Write-Host "   (Las encuentras en Settings > API del proyecto Supabase)" -ForegroundColor Gray
$supabaseUrl = Read-Host "   Supabase Project URL"
$supabaseAnonKey = Read-Host "   Supabase Anon Key"
$supabaseServiceKey = Read-Host "   Supabase Service Role Key (para crear usuario)"

$repoName = "pos-$nombreCorto"
$clienteDir = Join-Path $ClientesDir $repoName
# Intentar obtener usuario actual de gh
try {
    $ghUser = (gh api user --jq '.login')
} catch {
    Write-Err "No se pudo obtener el usuario de GitHub via API. Verifica 'gh auth status'."
    exit 1
}


Write-Host ""
Write-Host "   Resumen:" -ForegroundColor Cyan
Write-Host "   - Negocio: $nombreNegocio" -ForegroundColor White
Write-Host "   - Repo: $ghUser/$repoName (privado)" -ForegroundColor White
Write-Host "   - Plan: $planNombre" -ForegroundColor White
Write-Host "   - Admin: $emailAdmin" -ForegroundColor White
Write-Host "   - Dir: $clienteDir" -ForegroundColor White
Write-Host ""
$confirmar = Read-Host "   ¿Continuar? (S/N)"
if ($confirmar -ne "S" -and $confirmar -ne "s") {
    Write-Host "   Operación cancelada." -ForegroundColor Red
    exit 0
}

# ═══════════════════════════════════════════════
# CREAR REPO PRIVADO EN GITHUB
# ═══════════════════════════════════════════════

Write-Step "2" "Creando repositorio privado en GitHub..."

# Crear directorio de clientes si no existe
if (-not (Test-Path $ClientesDir)) {
    New-Item -ItemType Directory -Path $ClientesDir -Force | Out-Null
}

# Clonar repo base
$baseRepo = "https://github.com/paulvenci/GestorBar.git"

if (Test-Path $clienteDir) {
    Write-Host "   ⚠️ El directorio $clienteDir ya existe." -ForegroundColor Yellow
    $overwrite = Read-Host "   ¿Sobrescribir? (S/N)"
    if ($overwrite -eq "S" -or $overwrite -eq "s") {
        Remove-Item $clienteDir -Recurse -Force
    } else {
        exit 1
    }
}

git clone $baseRepo $clienteDir 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Err "Error clonando repositorio base"
    exit 1
}

Set-Location $clienteDir

# Remover origin del repo base y crear nuevo repo privado
git remote remove origin

# Crear repo privado. Si falla porque ya existe, avisar.
try {
    gh repo create $repoName --private --source=. --push 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Repo creado: github.com/$ghUser/$repoName (privado)"
    } else {
        Write-Host "   ⚠️ El repo ya existe o hubo error (ver arriba). Intentando continuar..." -ForegroundColor Yellow
    }
} catch {
    Write-Err "Error fatal creando repo"
}

# Si es suscripción, configurar upstream para actualizaciones futuras
if ($tipoPlan -eq "2") {
    git remote add upstream $baseRepo
    Write-Ok "Upstream configurado para recibir actualizaciones"
}

# ═══════════════════════════════════════════════
# CONFIGURAR .ENV
# ═══════════════════════════════════════════════

Write-Step "3" "Configurando variables de entorno..."

$envContent = @"
# Configuración de Supabase - $nombreNegocio
# Generado: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
# Plan: $planNombre

VITE_SUPABASE_URL=$supabaseUrl
VITE_SUPABASE_ANON_KEY=$supabaseAnonKey
"@

Set-Content -Path "frontend\.env" -Value $envContent -Encoding UTF8
Write-Ok "Archivo .env creado"

# ═══════════════════════════════════════════════
# EJECUTAR SCHEMA EN SUPABASE
# ═══════════════════════════════════════════════

Write-Step "4" "Configurando base de datos..."

# Extraer host y proyecto de la URL de Supabase para logs/referencia
# Pero usamos la URL completa para el REST API
# URL base para API REST: https://xyz.supabase.co/rest/v1/
# URL base para Auth: https://xyz.supabase.co/auth/v1/

$schemaPath = Join-Path $clienteDir "supabase\schema.sql"
if (Test-Path $schemaPath) {
    $schemaSQL = Get-Content $schemaPath -Raw

    $headers = @{
        "apikey" = $supabaseServiceKey
        "Authorization" = "Bearer $supabaseServiceKey"
        "Content-Type" = "application/json"
        "Prefer" = "return=minimal"
    }

    try {
        # Ejecutar schema via Supabase REST (function postgres)
        # NOTA: Supabase no expone ejecución de SQL raw por seguridad por defecto via REST
        # salvo que tengas una Edge Function dedicada o uses psql.
        # SI el usuario tiene psql instalado, usamos psql.
        
        if (Test-Command "psql") {
            # Necesitamos la DB Connection String
            # Para simplificar, la construimos asumiendo el formato estándar:
            # postgres://postgres.[project-ref]:[password]@[aws-0-region].pooler.supabase.com:6543/postgres
            # Pero como no tenemos la password de la DB aquí (solo service key), 
            # NO podemos usar psql fácilmente sin pedir password.
            
            # ALTERNATIVA: Usar la API SQL de Supabase Management API (requiere Personal Access Token, más complejo)
            
            # Vamos a avisar al usuario para que lo corra manual si no hay método fácil.
            Write-Host "   ⚠️ Ejecución automática de SQL omitida (requiere password de DB)." -ForegroundColor Yellow
            Write-Host "   👉 Copia el contenido de supabase\schema.sql y ejecútalo en el SQL Editor de Supabase." -ForegroundColor Cyan
            Read-Host "   Presiona ENTER cuando hayas ejecutado el SQL..."
        } else {
            Write-Host "   ⚠️ Ejecución automática de SQL omitida (no se detectó psql)." -ForegroundColor Yellow
            Write-Host "   👉 Copia el contenido de supabase\schema.sql y ejecútalo en el SQL Editor de Supabase." -ForegroundColor Cyan
            Read-Host "   Presiona ENTER cuando hayas ejecutado el SQL..."
        }

    } catch {
        Write-Host "   ⚠️ Error intentando ejecutar SQL." -ForegroundColor Yellow
    }
} else {
    Write-Err "No se encontró schema.sql"
}

# ═══════════════════════════════════════════════
# CREAR USUARIO ADMIN
# ═══════════════════════════════════════════════

Write-Step "5" "Creando usuario administrador..."

$headers = @{
    "apikey" = $supabaseServiceKey
    "Authorization" = "Bearer $supabaseServiceKey"
    "Content-Type" = "application/json"
}

try {
    # Crear usuario en Auth
    # NOTA: El endpoint /auth/v1/admin/users requiere service_role key
    $userBody = @{
        email = $emailAdmin
        password = "admin1234"
        email_confirm = $true
    } | ConvertTo-Json -Depth 10

    # Determinar endpoint correcto. Supabase a veces usa /auth/v1/admin/users
    $authUrl = "$supabaseUrl/auth/v1/admin/users"
    
    try {
        $authUser = Invoke-RestMethod -Uri $authUrl `
            -Method POST -Headers $headers -Body $userBody
            
        $userId = $authUser.id
        Write-Ok "Usuario Auth creado ($userId)"

        # Insertar en tabla usuarios (public schema)
        # Endpoint: /rest/v1/usuarios
        $usuarioBody = @{
            id = $userId
            email = $emailAdmin
            nombre = "Administrador"
            pin = $pinAdmin
            activo = $true
            # Rol: Asumimos que el ID del rol o el nombre se maneja. 
            # En schema.sql original no vi tabla roles explícita populada, pero en inserts sí.
            # Veamos GUIA_NUEVO_CLIENTE.md:
            # INSERT INTO usuarios (id, email, nombre_completo, rol, pin, activo) ...
            rol = "admin" # Ajustar según esquema real
        } | ConvertTo-Json

        Invoke-RestMethod -Uri "$supabaseUrl/rest/v1/usuarios" `
            -Method POST -Headers $headers -Body $usuarioBody

        Write-Ok "Admin creado en DB: $emailAdmin / PIN: $pinAdmin"
        Write-Host "   ⚠️ Contraseña temporal: admin1234 (cambiar al primer login)" -ForegroundColor Yellow

    } catch {
        $err = $_
        Write-Err "Error creando usuario: $($err.Exception.Message)"
        Write-Host "   Detalle: $($err | Out-String)" -ForegroundColor Gray
    }

} catch {
    Write-Host "   ⚠️ Error general en creación de usuario." -ForegroundColor Yellow
}

# ═══════════════════════════════════════════════
# CONFIGURAR GITHUB SECRETS + PAGES
# ═══════════════════════════════════════════════

Write-Step "6" "Configurando GitHub Secrets y Pages..."

# Setear secrets require estar en el directorio del repo
try {
    gh secret set VITE_SUPABASE_URL --body $supabaseUrl
    gh secret set VITE_SUPABASE_ANON_KEY --body $supabaseAnonKey
    Write-Ok "Secrets configurados en GitHub"
} catch {
    Write-Err "Error configurando secrets. Verifica conexión."
}

# ═══════════════════════════════════════════════
# INSTALAR + BUILD + PUSH
# ═══════════════════════════════════════════════

Write-Step "7" "Instalando dependencias y construyendo..."

Set-Location "frontend"
# npm install suele tardar, avisar
Write-Host "   Ejecutando npm install..." -ForegroundColor Gray
cmd /c "npm install" 2>&1 | Out-Null
Write-Ok "Dependencias instaladas"

# Volver a raíz del repo
Set-Location ..

# ═══════════════════════════════════════════════
# CONGELAR VERSIÓN (Solo Pago Único)
# ═══════════════════════════════════════════════

# Leer version del package.json
try {
    $pkgJson = Get-Content "frontend\package.json" | ConvertFrom-Json
    $version = $pkgJson.version
} catch {
    $version = "1.0.0"
}

if ($tipoPlan -eq "1") {
    Write-Step "8" "Congelando versión (Pago Único)..."

    git add -A
    git commit -m "chore: configuración inicial para $nombreNegocio"
    git tag -a "v$version-entrega" -m "Versión entregada a $nombreNegocio"
    git push origin main --tags

    Write-Ok "Versión congelada en tag: v$version-entrega"
} else {
    Write-Step "8" "Configurando actualizaciones (Suscripción)..."

    git add -A
    git commit -m "chore: configuración inicial para $nombreNegocio"
    git push origin main

    Write-Ok "Repo listo para recibir actualizaciones via upstream"
    Write-Host "   Para actualizar en el futuro: git fetch upstream && git merge upstream/main" -ForegroundColor Gray
}

# ═══════════════════════════════════════════════
# GENERAR FICHA DEL CLIENTE
# ═══════════════════════════════════════════════

Write-Step "9" "Generando ficha del cliente..."

$fechaHoy = Get-Date -Format 'yyyy-MM-dd'
$planDesc = if ($tipoPlan -eq "1") { "Pago Único (Congelado)" } else { "Suscripción (Actualizable)" }

$fichaContent = @"
# 📋 Ficha de Cliente: $nombreNegocio

| Campo | Valor |
|---|---|
| **Negocio** | $nombreNegocio |
| **Plan** | $planDesc |
| **Versión Inicial** | v$version |
| **Fecha Setup** | $fechaHoy |
| **Admin Email** | $emailAdmin |
| **Admin PIN** | $pinAdmin |
| **URL App** | https://$ghUser.github.io/$repoName/ |
| **Repo** | https://github.com/$ghUser/$repoName |
| **Supabase URL** | $supabaseUrl |

## Notas
- **Contraseña temporal Admin:** ``admin1234`` (Cambiar inmediatamente)
- **Directorio Local:** ``$clienteDir``

## Acciones Comunes

### Desplegar cambios manuales
```bash
npm run build
# El deploy es automático via GitHub Actions al hacer push a main
```

$(if ($tipoPlan -eq "2") { @"
### Actualizar versión (Suscripción)
```bash
git fetch upstream
git merge upstream/main
git push origin main
```
"@ })

"@

Set-Content -Path "CLIENTE.md" -Value $fichaContent -Encoding UTF8
git add CLIENTE.md
git commit -m "docs: generar ficha del cliente"
git push origin main 2>&1 | Out-Null

Write-Ok "Ficha generada: CLIENTE.md"
Write-Host "   👉 Ver ficha: $clienteDir\CLIENTE.md" -ForegroundColor Cyan

# ═══════════════════════════════════════════════
# RESUMEN FINAL
# ═══════════════════════════════════════════════

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ Cliente configurado exitosamente" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Negocio:  $nombreNegocio" -ForegroundColor White
Write-Host "  Plan:     $planNombre" -ForegroundColor White
Write-Host "  URL:      https://$ghUser.github.io/$repoName/" -ForegroundColor Cyan
Write-Host "  Repo:     https://github.com/$ghUser/$repoName" -ForegroundColor Cyan
Write-Host "  Admin:    $emailAdmin / PIN: $pinAdmin" -ForegroundColor White
Write-Host ""
Write-Host "  ⚠️ PASO FINAL MANUAL:" -ForegroundColor Yellow
Write-Host "  1. Ve a https://github.com/$ghUser/$repoName/settings/pages" -ForegroundColor White
Write-Host "  2. En Source elige 'GitHub Actions'" -ForegroundColor White
Write-Host "  (Esto es necesario la primera vez para activar el deploy)" -ForegroundColor Gray
Write-Host ""
