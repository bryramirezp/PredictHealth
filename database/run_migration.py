# /database/run_migration.py
# Script wrapper para ejecutar la migración de base de datos de forma segura

#!/usr/bin/env python3
"""
Script wrapper para ejecutar la migración de optimización de base de datos
PredictHealth de forma segura y con verificaciones previas.
"""

import os
import sys
import subprocess
from pathlib import Path

def check_python_version():
    """Verificar que la versión de Python sea compatible"""
    if sys.version_info < (3, 7):
        print("❌ Se requiere Python 3.7 o superior")
        print(f"   Versión actual: {sys.version}")
        return False
    print(f"✅ Python {sys.version.split()[0]} compatible")
    return True

def install_dependencies():
    """Instalar dependencias necesarias"""
    print("🔄 Instalando dependencias...")
    
    requirements_file = Path(__file__).parent / "requirements.txt"
    
    if not requirements_file.exists():
        print("❌ Archivo requirements.txt no encontrado")
        return False
    
    try:
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
        ])
        print("✅ Dependencias instaladas correctamente")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error instalando dependencias: {e}")
        return False

def check_database_connection():
    """Verificar conexión a la base de datos"""
    print("🔄 Verificando conexión a la base de datos...")
    
    try:
        import psycopg2
        from dotenv import load_dotenv
        
        # Cargar variables de entorno
        load_dotenv()
        
        db_url = os.getenv('DATABASE_URL', 'postgresql://admin:admin123@localhost:5432/predicthealth_db')
        
        conn = psycopg2.connect(db_url)
        conn.close()
        print("✅ Conexión a base de datos exitosa")
        return True
        
    except ImportError as e:
        print(f"❌ Dependencia faltante: {e}")
        return False
    except Exception as e:
        print(f"❌ Error conectando a la base de datos: {e}")
        print("   Verificar que:")
        print("   - PostgreSQL esté ejecutándose")
        print("   - La base de datos 'predicthealth_db' exista")
        print("   - Las credenciales en DATABASE_URL sean correctas")
        return False

def run_migration():
    """Ejecutar el script de migración"""
    print("🔄 Ejecutando migración de optimización...")
    
    migration_script = Path(__file__).parent / "migration_optimization.py"
    
    if not migration_script.exists():
        print("❌ Script de migración no encontrado")
        return False
    
    try:
        subprocess.check_call([sys.executable, str(migration_script)])
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error ejecutando migración: {e}")
        return False

def main():
    """Función principal del wrapper"""
    print("🚀 Iniciando migración de optimización de base de datos PredictHealth")
    print("=" * 70)
    
    # Verificaciones previas
    checks = [
        ("Versión de Python", check_python_version),
        ("Instalación de dependencias", install_dependencies),
        ("Conexión a base de datos", check_database_connection)
    ]
    
    for check_name, check_func in checks:
        print(f"\n📋 {check_name}...")
        if not check_func():
            print(f"\n❌ Falló la verificación: {check_name}")
            print("   Corregir el problema antes de continuar.")
            sys.exit(1)
    
    print("\n✅ Todas las verificaciones pasaron correctamente")
    print("\n🚀 Iniciando migración...")
    
    # Ejecutar migración
    if run_migration():
        print("\n🎉 Migración completada exitosamente!")
        print("📊 La base de datos está optimizada para consultas médicas complejas.")
    else:
        print("\n❌ Migración falló. Revisar logs para más detalles.")
        sys.exit(1)

if __name__ == "__main__":
    main()
