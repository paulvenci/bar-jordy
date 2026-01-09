@echo off
REM Lanzador de Bar Gordy POS en Modo Kiosco con Impresión Automática
REM ====================================================================

echo Iniciando Bar Gordy POS en Modo Kiosco...
echo.
echo MODO KIOSCO ACTIVADO:
echo - Pantalla completa (F11 para salir)
echo - Impresion automatica a impresora predeterminada
echo - Sin dialogos de impresion
echo.
echo Para salir: Presiona ALT+F4 o cierra la ventana
echo.

REM Esperar 2 segundos
timeout /t 2 /nobreak > nul

REM Iniciar Chrome en modo kiosco con impresión automática
REM IMPORTANTE: Ajusta la ruta de Chrome si está en otro lugar
"C:\Program Files\Google\Chrome\Application\chrome.exe" --kiosk --kiosk-printing --app=http://localhost:5173

REM Si Chrome no está en Program Files, prueba con:
REM "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --kiosk --kiosk-printing --app=http://localhost:5173

echo.
echo Modo kiosco cerrado. Presiona cualquier tecla para salir...
pause > nul
