# actualizar-clientes-suscripcion.ps1
# Actualiza TODOS los clientes que tienen plan de suscripción
# Itera por todos los directorios en clientes/, hace git pull upstream main y deploy

param(
    [string]$ClientesDir = "d:\Electrosun\clientes",
    [switch]$DryRun # Solo mostrar qué se haría sin ejecutar
)

# ═══════════════════════════════════════════════
# INICIO
# ═══════════════════════════════════════════════

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🚀 Actualizador Masivo de Clientes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ClientesDir)) {
    Write-Host "No existe el directorio de clientes: $ClientesDir" -ForegroundColor Red
    exit 1
}

$clientes = Get-ChildItem $ClientesDir -Directory | Where-Object { $_.Name -like "pos-*" }
$count = 0
$errors = 0

foreach ($cliente in $clientes) {
    $path = $cliente.FullName
    $name = $cliente.Name
    
    Write-Host "Revisando: $name" -NoNewline -ForegroundColor Gray
    
    # Entrar al directorio
    Push-Location $path
    
    # Verificar si es suscripción (tiene upstream)
    $remotes = git remote
    if ($remotes -contains "upstream") {
        Write-Host " [SUSCRIPCIÓN]" -ForegroundColor Green
        
        if ($DryRun) {
            Write-Host "   (DryRun) Se ejecutaría git pull upstream main" -ForegroundColor Yellow
        }
        else {
            Write-Host "   Actualizando..." -ForegroundColor Yellow
            
            # Fetch
            git fetch upstream 2>&1 | Out-Null
            
            # Merge
            $output = git merge upstream/main 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                if ($output -match "Already up to date") {
                    Write-Host "   ✅ Ya está actualizado." -ForegroundColor Green
                }
                else {
                    Write-Host "   ✅ Actualizado con éxito." -ForegroundColor Green
                    # Push para disparar deploy
                    git push origin main 2>&1 | Out-Null
                    Write-Host "   🚀 Deploy iniciado (push)." -ForegroundColor Cyan
                    $count++
                }
            }
            else {
                Write-Host "   ❌ ERROR al actualizar (posible conflicto)." -ForegroundColor Red
                Write-Host "   Salida git:" -ForegroundColor Gray
                Write-Host $output -ForegroundColor Gray
                $errors++
            }
        }
    }
    else {
        Write-Host " [PAGO ÚNICO - OMITIDO]" -ForegroundColor DarkGray
    }
    
    Pop-Location
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resumen" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Clientes actualizados: $count" -ForegroundColor Green
Write-Host "  Errores manuales:      $errors" -ForegroundColor Red
Write-Host ""
