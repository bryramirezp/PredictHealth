# /microservices/service-patients/app/db.py
# Módulo de conexión a la base de datos para PredictHealth

import os
import logging
import psycopg2
import psycopg2.extras
from psycopg2.pool import SimpleConnectionPool

logger = logging.getLogger(__name__)

# Configuración de la base de datos desde variables de entorno
# Soporta tanto DATABASE_URL completo como variables individuales
DATABASE_URL = os.getenv('DATABASE_URL')

if DATABASE_URL:
    # Usar DATABASE_URL completo (para Docker/producción)
    DB_CONFIG = DATABASE_URL
    logger.info(f"🔧 Usando DATABASE_URL: {DATABASE_URL}")
else:
    # Usar variables individuales (para desarrollo local)
    DB_CONFIG = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': os.getenv('DB_PORT', '5432'),
        'database': os.getenv('DB_NAME', 'predicthealth'),
        'user': os.getenv('DB_USER', 'postgres'),
        'password': os.getenv('DB_PASSWORD', 'password'),
        'sslmode': os.getenv('DB_SSLMODE', 'prefer')
    }
    logger.info(f"🔧 Usando configuración individual: {DB_CONFIG['host']}:{DB_CONFIG['port']}")

# Pool de conexiones para mejor rendimiento
connection_pool = None

def init_connection_pool():
    """Inicializa el pool de conexiones a la base de datos"""
    global connection_pool
    try:
        if isinstance(DB_CONFIG, str):
            # DATABASE_URL completo
            connection_pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                dsn=DB_CONFIG
            )
        else:
            # DB_CONFIG como diccionario
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
    """
    Obtiene una conexión a la base de datos PostgreSQL

    Returns:
        psycopg2.extensions.connection: Conexión a la base de datos
    """
    global connection_pool

    try:
        if connection_pool is None:
            init_connection_pool()

        # Usar el pool si está disponible
        if connection_pool:
            conn = connection_pool.getconn()
            # Configurar para que los diccionarios sean retornados como DictRow
            conn.cursor_factory = psycopg2.extras.DictCursor
            return conn
        else:
            # Conexión directa si el pool no está disponible
            if isinstance(DB_CONFIG, str):
                # DATABASE_URL completo
                conn = psycopg2.connect(
                    DB_CONFIG,
                    cursor_factory=psycopg2.extras.DictCursor
                )
            else:
                # DB_CONFIG como diccionario
                conn = psycopg2.connect(
                    cursor_factory=psycopg2.extras.DictCursor,
                    **DB_CONFIG
                )
            return conn

    except Exception as e:
        logger.error(f"❌ Error conectando a la base de datos: {str(e)}")
        logger.error(f"🔍 Configuración usada: {DB_CONFIG}")
        raise e

def release_connection(conn):
    """
    Libera una conexión al pool

    Args:
        conn: Conexión a liberar
    """
    global connection_pool

    try:
        if connection_pool and conn:
            connection_pool.putconn(conn)
        elif conn:
            conn.close()
    except Exception as e:
        logger.error(f"❌ Error liberando conexión: {str(e)}")

def close_all_connections():
    """Cierra todas las conexiones del pool"""
    global connection_pool

    try:
        if connection_pool:
            connection_pool.closeall()
            logger.info("✅ Todas las conexiones cerradas")
    except Exception as e:
        logger.error(f"❌ Error cerrando conexiones: {str(e)}")

# Context manager para manejo automático de conexiones
class DatabaseConnection:
    """Context manager para manejo de conexiones a la base de datos"""

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
            raise e

    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            if self.cursor:
                self.cursor.close()
            if self.conn:
                if exc_type is None:
                    self.conn.commit()
                else:
                    self.conn.rollback()
                release_connection(self.conn)
        except Exception as e:
            logger.error(f"❌ Error en DatabaseConnection.__exit__: {str(e)}")

# Función de utilidad para ejecutar queries con manejo automático de conexión
def execute_query(query, params=None, fetch_one=False, fetch_all=True):
    """
    Ejecuta una query con manejo automático de conexión

    Args:
        query (str): Query SQL a ejecutar
        params (tuple): Parámetros de la query
        fetch_one (bool): Si debe retornar solo un resultado
        fetch_all (bool): Si debe retornar todos los resultados

    Returns:
        Resultados de la query o None si hay error
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