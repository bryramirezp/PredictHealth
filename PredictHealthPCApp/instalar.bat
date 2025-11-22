@echo off
echo ========================================
echo   PredictHealth - Instalador
echo ========================================
echo.
echo Instalando dependencias...
echo.

pip install customtkinter matplotlib pillow requests --break-system-packages

echo.
echo ========================================
echo   Instalacion completada!
echo ========================================
echo.
echo Para ejecutar la aplicacion:
echo   python main.py
echo.
pause
