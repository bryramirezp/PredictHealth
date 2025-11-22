@echo off
echo ========================================
echo   Iniciando PredictHealth...
echo ========================================
echo.

python main.py

if errorlevel 1 (
    echo.
    echo Error al ejecutar la aplicacion.
    echo Verifica que Python este instalado.
    pause
)
