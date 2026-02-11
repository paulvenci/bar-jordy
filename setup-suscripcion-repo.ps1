$target = "..\GestorBarSuscripcion"
if (Test-Path $target) { Write-Host "Target exists. Aborting."; exit 1 }
Write-Host "Cloning to $target..."
git clone . $target
if (-not (Test-Path $target)) { Write-Host "Clone failed."; exit 1 }
Set-Location $target
git remote remove origin
Write-Host "Cloned successfully to $target."
Write-Host "Please create the remote repo manually and push."
