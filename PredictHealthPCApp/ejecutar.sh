#!/bin/bash

echo "======================================"
echo "  PREDICTHEALTH - INICIANDO APP"
echo "======================================"
echo ""

# Verificar que existe el entorno virtual
if [ ! -d "venv" ]; then
    echo "❌ Entorno virtual no encontrado"
    echo "Por favor ejecuta primero: ./instalar.sh"
    exit 1
fi

# Activar entorno virtual
source venv/bin/activate

# Ejecutar aplicación
echo "🚀 Iniciando PredictHealth..."
python main.py

# Desactivar al cerrar
deactivate