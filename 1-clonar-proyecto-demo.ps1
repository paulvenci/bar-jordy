# Script para clonar proyecto Bar Gordy a entorno de demo
# Fecha: 2026-02-03

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Clonando Bar Gordy a entorno DEMO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$sourceDir = "d:\Electrosun\bar gordy"
$destDir = "d:\Electrosun\bar-gordy-demo"

# Verificar que existe el directorio fuente
if (-not (Test-Path $sourceDir)) {
    Write-Host "ERROR: No se encuentra el directorio fuente: $sourceDir" -ForegroundColor Red
    exit 1
}

# Crear directorio destino si no existe
Write-Host "1. Creando directorio de demo..." -ForegroundColor Yellow
if (Test-Path $destDir) {
    $response = Read-Host "El directorio $destDir ya existe. ¿Desea eliminarlo y crear uno nuevo? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        Remove-Item -Path $destDir -Recurse -Force
        Write-Host "   Directorio anterior eliminado." -ForegroundColor Green
    } else {
        Write-Host "   Operación cancelada." -ForegroundColor Red
        exit 0
    }
}

# Copiar archivos (excluyendo node_modules, .git, y archivos temporales)
Write-Host "2. Copiando archivos del proyecto..." -ForegroundColor Yellow
Write-Host "   (Esto puede tomar unos minutos...)" -ForegroundColor Gray

$excludeDirs = @("node_modules", ".git", "dist", ".vite", ".supabase")
$excludeFiles = @(".env", ".env.local", ".env.production")

# Usar robocopy para copia eficiente
$robocopyArgs = @(
    $sourceDir,
    $destDir,
    "/E",           # Copiar subdirectorios incluyendo vacíos
    "/XD",          # Excluir directorios
    "node_modules", ".git", "dist", ".vite", ".supabase",
    "/XF",          # Excluir archivos
    ".env", ".env.local", ".env.production",
    "/NFL",         # No mostrar lista de archivos
    "/NDL",         # No mostrar lista de directorios
    "/NJH",         # No mostrar encabezado del trabajo
    "/NJS",         # No mostrar resumen del trabajo
    "/NC",          # No mostrar clases de archivos
    "/NS",          # No mostrar tamaños
    "/NP"           # No mostrar progreso
)

$result = robocopy @robocopyArgs

# Robocopy retorna códigos de salida específicos
# 0-7 son éxito, 8+ son errores
if ($LASTEXITCODE -ge 8) {
    Write-Host "   ERROR al copiar archivos (código: $LASTEXITCODE)" -ForegroundColor Red
    exit 1
} else {
    Write-Host "   Archivos copiados exitosamente." -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Clonación completada exitosamente" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proyecto demo creado en: $destDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Ejecutar: .\2-capturar-datos-produccion.ps1" -ForegroundColor White
Write-Host "2. Configurar Supabase local en el proyecto demo" -ForegroundColor White
Write-Host "3. Instalar dependencias con 'npm install'" -ForegroundColor White
Write-Host ""
