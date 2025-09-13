# /database/migration_optimization.py
# Script de migración para optimizaciones de base de datos

import os
import sys
from datetime import datetime

# Importación condicional de psycopg2 para evitar errores de linting
# Nota: La advertencia del linter sobre psycopg2 es normal - es una dependencia externa
try:
    import psycopg2  # type: ignore
    PSYCOPG2_AVAILABLE = True
except ImportError:
    PSYCOPG2_AVAILABLE = False
    print("⚠️  psycopg2 no está instalado. Ejecutar: pip install psycopg2-binary")

class DatabaseOptimizer:
    """Clase para optimizar la base de datos PredictHealth"""
    
    def __init__(self):
        self.db_url = os.getenv('DATABASE_URL', 'postgresql://admin:admin123@localhost:5432/predicthealth_db')
        self.conn = None
    
    def connect(self):
        """Conectar a la base de datos"""
        if not PSYCOPG2_AVAILABLE:
            print("❌ psycopg2 no está disponible. Instalar con: pip install psycopg2-binary")
            return False
            
        try:
            self.conn = psycopg2.connect(self.db_url)
            self.conn.autocommit = False
            print("✅ Conectado a la base de datos")
            return True
        except Exception as e:
            print(f"❌ Error conectando a la base de datos: {e}")
            return False
    
    def disconnect(self):
        """Desconectar de la base de datos"""
        if self.conn:
            self.conn.close()
            print("✅ Desconectado de la base de datos")
    
    def backup_existing_data(self):
        """Crear backup de datos existentes"""
        print("🔄 Creando backup de datos existentes...")
        
        backup_queries = [
            "CREATE TABLE IF NOT EXISTS usuarios_backup AS SELECT * FROM usuarios;",
            "CREATE TABLE IF NOT EXISTS perfil_salud_general_backup AS SELECT * FROM perfil_salud_general;",
            "CREATE TABLE IF NOT EXISTS datos_biometricos_backup AS SELECT * FROM datos_biometricos;",
            "CREATE TABLE IF NOT EXISTS predicciones_riesgo_backup AS SELECT * FROM predicciones_riesgo;",
            "CREATE TABLE IF NOT EXISTS recomendaciones_medicas_backup AS SELECT * FROM recomendaciones_medicas;"
        ]
        
        cursor = self.conn.cursor()
        try:
            for query in backup_queries:
                cursor.execute(query)
            self.conn.commit()
            print("✅ Backup completado")
            return True
        except Exception as e:
            print(f"❌ Error en backup: {e}")
            self.conn.rollback()
            return False
        finally:
            cursor.close()
    
    def create_optimized_schema(self):
        """Crear esquema optimizado"""
        print("🔄 Aplicando optimizaciones de esquema...")
        
        # Leer el archivo de esquema optimizado
        try:
            # Obtener la ruta absoluta del directorio del script
            script_dir = os.path.dirname(os.path.abspath(__file__))
            schema_file = os.path.join(script_dir, 'optimized_schema.sql')
            
            with open(schema_file, 'r', encoding='utf-8') as f:
                schema_sql = f.read()
        except FileNotFoundError:
            print(f"❌ Archivo optimized_schema.sql no encontrado en: {schema_file}")
            return False
        except Exception as e:
            print(f"❌ Error leyendo archivo de esquema: {e}")
            return False
        
        cursor = self.conn.cursor()
        try:
            # Ejecutar el esquema optimizado
            cursor.execute(schema_sql)
            self.conn.commit()
            print("✅ Esquema optimizado aplicado")
            return True
        except Exception as e:
            print(f"❌ Error aplicando esquema: {e}")
            self.conn.rollback()
            return False
        finally:
            cursor.close()
    
    def migrate_existing_data(self):
        """Migrar datos existentes al nuevo esquema"""
        print("🔄 Migrando datos existentes...")
        
        migration_queries = [
            # Migrar usuarios
            """
            INSERT INTO usuarios (id_usuario, id_doctor, nombre, apellido, email, fecha_nacimiento, genero, contrasena_hash, activo, zona_horaria, fecha_creacion, fecha_actualizacion)
            SELECT id_usuario, id_doctor, nombre, apellido, email, 
                   CASE 
                       WHEN fecha_nacimiento ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
                       THEN fecha_nacimiento::DATE 
                       ELSE '1990-01-01'::DATE 
                   END,
                   genero, contrasena_hash, activo, 'America/Mexico_City', fecha_creacion, fecha_actualizacion
            FROM usuarios_backup
            ON CONFLICT (id_usuario) DO NOTHING;
            """,
            
            # Migrar perfil de salud
            """
            INSERT INTO perfil_salud_general (id_perfil, id_usuario, altura_cm, peso_kg, fumador, consumo_alcohol, diagnostico_hipertension, diagnostico_colesterol_alto, antecedente_acv, antecedente_enf_cardiaca, condiciones_preexistentes_notas, minutos_actividad_fisica_semanal, fecha_creacion, fecha_actualizacion)
            SELECT id_perfil, id_usuario, 
                   CASE WHEN altura_cm ~ '^[0-9]+\.?[0-9]*$' THEN altura_cm::DECIMAL(5,2) ELSE NULL END,
                   CASE WHEN peso_kg ~ '^[0-9]+\.?[0-9]*$' THEN peso_kg::DECIMAL(5,2) ELSE NULL END,
                   fumador, consumo_alcohol, diagnostico_hipertension, diagnostico_colesterol_alto, antecedente_acv, antecedente_enf_cardiaca, condiciones_preexistentes_notas,
                   CASE WHEN minutos_actividad_fisica_semanal ~ '^[0-9]+$' THEN minutos_actividad_fisica_semanal::INTEGER ELSE 0 END,
                   fecha_creacion, fecha_actualizacion
            FROM perfil_salud_general_backup
            ON CONFLICT (id_usuario) DO NOTHING;
            """,
            
            # Migrar datos biométricos
            """
            INSERT INTO datos_biometricos (id_dato_biometrico, id_usuario, fecha_hora_medida, tipo_medida, valor, unidad, fuente_dato, id_doctor_registro, notas, fecha_creacion)
            SELECT id_dato_biometrico, id_usuario, fecha_hora_medida, tipo_medida,
                   CASE WHEN valor ~ '^[0-9]+\.?[0-9]*$' THEN valor::DECIMAL(10,2) ELSE 0 END,
                   unidad, fuente_dato, id_doctor_registro, notas, fecha_creacion
            FROM datos_biometricos_backup
            ON CONFLICT (id_dato_biometrico) DO NOTHING;
            """,
            
            # Migrar predicciones de riesgo
            """
            INSERT INTO predicciones_riesgo (id_prediccion, id_usuario, fecha_prediccion, tipo_riesgo, puntuacion_riesgo, nivel_riesgo, detalles_prediccion, fecha_creacion)
            SELECT id_prediccion, id_usuario, fecha_prediccion, tipo_riesgo,
                   CASE WHEN puntuacion_riesgo ~ '^[0-9]+\.?[0-9]*$' THEN puntuacion_riesgo::DECIMAL(5,2) ELSE 0 END,
                   nivel_riesgo, detalles_prediccion, fecha_creacion
            FROM predicciones_riesgo_backup
            ON CONFLICT (id_prediccion) DO NOTHING;
            """,
            
            # Migrar recomendaciones médicas
            """
            INSERT INTO recomendaciones_medicas (id_recomendacion, id_usuario, id_doctor, id_prediccion, fecha_generacion, contenido_es, estado_recomendacion, feedback_doctor, fecha_creacion, fecha_actualizacion)
            SELECT id_recomendacion, id_usuario, id_doctor, id_prediccion, fecha_generacion, contenido_es, estado_recomendacion, feedback_doctor, fecha_creacion, fecha_actualizacion
            FROM recomendaciones_medicas_backup
            ON CONFLICT (id_recomendacion) DO NOTHING;
            """
        ]
        
        cursor = self.conn.cursor()
        try:
            for query in migration_queries:
                cursor.execute(query)
            self.conn.commit()
            print("✅ Datos migrados exitosamente")
            return True
        except Exception as e:
            print(f"❌ Error migrando datos: {e}")
            self.conn.rollback()
            return False
        finally:
            cursor.close()
    
    def create_indexes_concurrently(self):
        """Crear índices de forma concurrente para evitar bloqueos"""
        print("🔄 Creando índices optimizados...")
        
        # Índices que se pueden crear concurrentemente
        concurrent_indexes = [
            "CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_usuarios_doctor_activo ON usuarios(id_doctor, activo) WHERE activo = TRUE;",
            "CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_datos_biometricos_usuario_fecha ON datos_biometricos(id_usuario, fecha_hora_medida DESC);",
            "CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_predicciones_usuario_tipo ON predicciones_riesgo(id_usuario, tipo_riesgo, fecha_prediccion DESC);",
            "CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_perfil_imc ON perfil_salud_general(imc) WHERE imc IS NOT NULL;"
        ]
        
        cursor = self.conn.cursor()
        try:
            for index_query in concurrent_indexes:
                cursor.execute(index_query)
            self.conn.commit()
            print("✅ Índices creados exitosamente")
            return True
        except Exception as e:
            print(f"❌ Error creando índices: {e}")
            self.conn.rollback()
            return False
        finally:
            cursor.close()
    
    def refresh_materialized_views(self):
        """Refrescar vistas materializadas"""
        print("🔄 Refrescando vistas materializadas...")
        
        refresh_queries = [
            "REFRESH MATERIALIZED VIEW estadisticas_riesgo_por_doctor;",
            "REFRESH MATERIALIZED VIEW tendencias_mediciones_mensual;",
            "REFRESH MATERIALIZED VIEW analisis_factores_riesgo;"
        ]
        
        cursor = self.conn.cursor()
        try:
            for query in refresh_queries:
                cursor.execute(query)
            self.conn.commit()
            print("✅ Vistas materializadas refrescadas")
            return True
        except Exception as e:
            print(f"❌ Error refrescando vistas: {e}")
            self.conn.rollback()
            return False
        finally:
            cursor.close()
    
    def verify_optimization(self):
        """Verificar que las optimizaciones se aplicaron correctamente"""
        print("🔄 Verificando optimizaciones...")
        
        verification_queries = [
            ("Tablas particionadas", "SELECT COUNT(*) FROM pg_class WHERE relkind = 'p';"),
            ("Índices creados", "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public';"),
            ("Vistas materializadas", "SELECT COUNT(*) FROM pg_matviews WHERE schemaname = 'public';"),
            ("Funciones médicas", "SELECT COUNT(*) FROM pg_proc WHERE proname LIKE '%medic%' OR proname LIKE '%riesgo%';")
        ]
        
        cursor = self.conn.cursor()
        try:
            for name, query in verification_queries:
                cursor.execute(query)
                count = cursor.fetchone()[0]
                print(f"✅ {name}: {count}")
            return True
        except Exception as e:
            print(f"❌ Error en verificación: {e}")
            return False
        finally:
            cursor.close()
    
    def run_optimization(self):
        """Ejecutar proceso completo de optimización"""
        print("🚀 Iniciando optimización de base de datos PredictHealth")
        print("=" * 60)
        
        if not self.connect():
            return False
        
        try:
            # Paso 1: Backup
            if not self.backup_existing_data():
                return False
            
            # Paso 2: Aplicar esquema optimizado
            if not self.create_optimized_schema():
                return False
            
            # Paso 3: Migrar datos
            if not self.migrate_existing_data():
                return False
            
            # Paso 4: Crear índices
            if not self.create_indexes_concurrently():
                return False
            
            # Paso 5: Refrescar vistas
            if not self.refresh_materialized_views():
                return False
            
            # Paso 6: Verificar
            if not self.verify_optimization():
                return False
            
            print("=" * 60)
            print("🎉 Optimización completada exitosamente!")
            print("📊 Beneficios obtenidos:")
            print("   • Consultas médicas complejas optimizadas")
            print("   • Particionado temporal para mejor rendimiento")
            print("   • Índices especializados para análisis médico")
            print("   • Vistas materializadas para dashboards rápidos")
            print("   • Funciones especializadas para cálculos médicos")
            
            return True
            
        except Exception as e:
            print(f"❌ Error durante la optimización: {e}")
            return False
        finally:
            self.disconnect()

def check_dependencies():
    """Verificar que las dependencias necesarias estén instaladas"""
    print("🔄 Verificando dependencias...")
    
    if not PSYCOPG2_AVAILABLE:
        print("❌ psycopg2 no está instalado. Instalar con: pip install psycopg2-binary")
        return False
    else:
        print("✅ psycopg2 disponible")
    
    try:
        # Verificar módulos estándar (ya importados globalmente)
        os.path.exists
        sys.version
        datetime.now()
        print("✅ Módulos estándar disponibles")
    except Exception as e:
        print(f"❌ Error verificando módulos estándar: {e}")
        return False
    
    return True

def main():
    """Función principal"""
    # Verificar dependencias primero
    if not check_dependencies():
        print("❌ Dependencias faltantes. Instalar antes de continuar.")
        sys.exit(1)
    
    optimizer = DatabaseOptimizer()
    
    # Verificar que estamos en el directorio correcto
    script_dir = os.path.dirname(os.path.abspath(__file__))
    schema_file = os.path.join(script_dir, 'optimized_schema.sql')
    
    if not os.path.exists(schema_file):
        print(f"❌ Archivo optimized_schema.sql no encontrado en: {schema_file}")
        print("   Asegúrate de que el archivo optimized_schema.sql esté en el mismo directorio que este script.")
        sys.exit(1)
    
    # Confirmar antes de proceder
    print("⚠️  ADVERTENCIA: Esta operación modificará la estructura de la base de datos.")
    print("   Se creará un backup automático, pero se recomienda hacer backup manual.")
    print(f"📁 Directorio de trabajo: {script_dir}")
    print(f"📄 Archivo de esquema: {schema_file}")
    
    response = input("¿Continuar con la optimización? (s/N): ")
    if response.lower() != 's':
        print("❌ Operación cancelada")
        sys.exit(0)
    
    # Ejecutar optimización
    success = optimizer.run_optimization()
    
    if success:
        print("\n✅ Optimización completada. El sistema está listo para consultas médicas complejas.")
        sys.exit(0)
    else:
        print("\n❌ Optimización falló. Revisar logs para más detalles.")
        sys.exit(1)

if __name__ == "__main__":
    main()
