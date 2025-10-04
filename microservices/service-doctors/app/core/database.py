# /microservices\service-doctors\app\core\database.py
# /microservicios/servicio-doctores/app/core/database.py
# Configuración de base de datos para el servicio de doctores

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
import logging

from .config import settings

# Configurar logging
logger = logging.getLogger(__name__)

# Crear engine de SQLAlchemy
engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
    echo=settings.debug
)

# Crear sesión de base de datos
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para modelos
Base = declarative_base()

def get_db():
    """Dependencia para obtener sesión de base de datos"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """Inicializar base de datos"""
    try:
        logger.info("🔄 Inicializando base de datos (servicio-doctores)")
        
        # Importar todos los modelos para que se registren
        from ..models import Base
        
        # Crear todas las tablas
        Base.metadata.create_all(bind=engine)
        
        logger.info("✅ Base de datos inicializada exitosamente (servicio-doctores)")
        
    except Exception as e:
        logger.error(f"❌ Error inicializando base de datos: {str(e)}")
        raise