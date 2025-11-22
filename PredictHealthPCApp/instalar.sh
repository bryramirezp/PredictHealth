#!/bin/bash

echo "======================================"
echo "  INSTALADOR - PREDICTHEALTH APP"
echo "======================================"
echo ""

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 no está instalado"
    echo "Por favor instala Python 3.8 o superior desde python.org"
    exit 1
fi

echo "✅ Python encontrado: $(python3 --version)"
echo ""

# Crear entorno virtual
echo "📦 Creando entorno virtual..."
python3 -m venv venv

# Activar entorno virtual
echo "🔧 Activando entorno virtual..."
source venv/bin/activate

# Instalar dependencias
echo "📥 Instalando dependencias..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "✅ ¡Instalación completada exitosamente!"
echo ""
echo "Para ejecutar la aplicación:"
echo "  ./ejecutar.sh"
echo ""