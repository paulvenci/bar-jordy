# Script para limpiar el archivo snapshot - version mejorada
$inputFile = "d:\Electrosun\bar gordy\supabase\snapshots\snapshot-2026-02-03.sql"
$outputFile = "d:\Electrosun\bar gordy\supabase\snapshots\snapshot-2026-02-03.sql"

$content = Get-Content $inputFile -Raw -Encoding UTF8

# Eliminar lineas que solo contienen ?column?
$content = $content -replace '\r?\n\?column\?\r?\n', "`r`n"

# Quitar comillas al inicio de lineas que empiezan con "INSERT o "-- 
$content = $content -replace '(?m)^"(INSERT)', '$1'
$content = $content -replace '(?m)^"(-- Usuario)', '$1'
$content = $content -replace '(?m)^"(-- IMPORTANTE)', '$1'

# Quitar comillas al final de lineas que terminan con ;"
$content = $content -replace ';\"\r?\n', ";`r`n"
$content = $content -replace ';\"$', ";"

# Guardar
Set-Content $outputFile $content -Encoding UTF8 -NoNewline

Write-Host "Archivo limpiado correctamente"
