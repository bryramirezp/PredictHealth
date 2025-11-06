# /microservices/service-doctors/app/db.py
# Módulo de conexión a la base de datos para PredictHealth

import os
import logging
import psycopg2
import psycopg2.extras
from psycopg2.pool import SimpleConnectionPool

logger = logging.getLogger(__name__)

# Configuración de la base de datos desde variables de entorno
DATABASE_URL = os.getenv('DATABASE_URL')

if DATABASE_URL:
    DB_CONFIG = DATABASE_URL
    logger.info(f"🔧 Usando DATABASE_URL")
else:
    # Configuración para desarrollo local si DATABASE_URL no está
    DB_CONFIG = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': os.getenv('DB_PORT', '5432'),
        'database': os.getenv('DB_NAME', 'predicthealth_db'),
        'user': os.getenv('DB_USER', 'predictHealth_user'),
        'password': os.getenv('DB_PASSWORD', 'password')
    }
    logger.info(f"🔧 Usando configuración individual: {DB_CONFIG.get('host')}:{DB_CONFIG.get('port')}")

# Pool de conexiones
connection_pool = None

def init_connection_pool():
    """Inicializa el pool de conexiones a la base de datos"""
    global connection_pool
    try:
        if isinstance(DB_CONFIG, str):
            connection_pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                dsn=DB_CONFIG
            )
        else:
            connection_pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                **DB_CONFIG
            )
        logger.info("✅ Pool de conexiones a PostgreSQL inicializado")
        return True
    except Exception as e:
        logger.error(f"❌ Error inicializando pool de conexiones: {str(e)}")
        return False

def get_db_connection():
    """Obtiene una conexión del pool."""
    global connection_pool
    try:
        if connection_pool is None:
            if not init_connection_pool():
                raise Exception("Fallo al inicializar el pool de conexiones")
        
        conn = connection_pool.getconn()
        conn.cursor_factory = psycopg2.extras.DictCursor
        return conn
    except Exception as e:
        logger.error(f"❌ Error conectando a la base de datos: {str(e)}")
        raise e

def release_connection(conn):
    """Libera una conexión de vuelta al pool."""
    global connection_pool
    try:
        if connection_pool and conn:
            connection_pool.putconn(conn)
        elif conn:
            conn.close()
    except Exception as e:
        logger.error(f"❌ Error liberando conexión: {str(e)}")

# Context manager para manejo automático de conexiones y transacciones
class DatabaseConnection:
    """
    Context manager para manejo de conexiones a la base de datos.
    Garantiza que las operaciones sean transaccionales (commit/rollback).
    """
    def __init__(self):
        self.conn = None
        self.cursor = None

    def __enter__(self):
        try:
            self.conn = get_db_connection()
            self.cursor = self.conn.cursor()
            return self.conn, self.cursor
        except Exception as e:
            logger.error(f"❌ Error en DatabaseConnection.__enter__: {str(e)}")
            release_connection(self.conn)
            raise e

    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            if self.cursor:
                self.cursor.close()
            if self.conn:
                if exc_type is None:
                    self.conn.commit()
                else:
                    logger.warning(f"🔄 Rollback ejecutado debido a un error: {exc_val}")
                    self.conn.rollback()
                release_connection(self.conn)
        except Exception as e:
            logger.error(f"❌ Error en DatabaseConnection.__exit__: {str(e)}")

# Función de utilidad para ejecutar queries
def execute_query(query, params=None, fetch_one=False, fetch_all=True):
    """
    Ejecuta una query con manejo automático de conexión.
    IMPORTANTE: Esta función abre su propia conexión y hace commit,
    NO debe ser usada dentro de un bloque 'with DatabaseConnection()' más grande.
    Usar para operaciones de LECTURA simples.
    """
    try:
        with DatabaseConnection() as (conn, cursor):
            cursor.execute(query, params or ())

            if fetch_one:
                return cursor.fetchone()
            elif fetch_all:
                return cursor.fetchall()
            else:
                return None
    except Exception as e:
        logger.error(f"❌ Error ejecutando query: {str(e)}")
        logger.error(f"Query: {query}")
        return None

# Inicializar el pool al importar el módulo
if connection_pool is None:
    init_connection_pool()