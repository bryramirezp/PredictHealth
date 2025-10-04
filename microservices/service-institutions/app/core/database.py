# /microservices\service-institutions\app\core\database.py
# Configuración de base de datos para servicio de instituciones

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Crear engine de base de datos
try:
    engine = create_engine(
        settings.database_url,
        pool_pre_ping=True,
        pool_recycle=300,
        echo=settings.debug
    )
    logger.info("✅ Conexión a base de datos establecida (servicio-instituciones)")
except Exception as e:
    logger.error(f"❌ Error conectando a base de datos: {e}")
    raise

# Crear sesión de base de datos
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    """Dependencia para obtener sesión de base de datos"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """Inicializar base de datos - crear tablas de instituciones"""
    try:
        # Importar todos los modelos para que se registren
        from app.models import Base, MedicalInstitution
        
        # Crear todas las tablas de instituciones
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Tablas de instituciones creadas exitosamente")
        
    except Exception as e:
        logger.error(f"❌ Error inicializando base de datos: {e}")
        raise
