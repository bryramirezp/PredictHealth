# /microservices\service-jwt\app\core\database.py
# /microservicios/servicio-auth/app/core/database.py

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
import os
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Crear engine de base de datos (solo para autenticación de usuarios)
try:
    engine = create_engine(
        settings.DATABASE_URL,
        pool_pre_ping=True,
        pool_recycle=300,
        echo=False  # Cambiar a True para debug SQL
    )
    logger.info("✅ Conexión a base de datos establecida (para autenticación de usuarios)")
except Exception as e:
    logger.error(f"❌ Error conectando a base de datos: {e}")
    # No raise aquí - permitir que el servicio funcione sin DB si es necesario
    engine = None

# Crear sesión de base de datos
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    """Dependencia para obtener sesión de base de datos"""
    if engine is None:
        raise Exception("Database connection not available")
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """No-op initializer to preserve API; auto-creation disabled intentionally."""
    auto_init = os.getenv("AUTH_AUTO_INIT_DB", "false").lower() == "true"
    if auto_init:
        try:
            from app.models import Base  # only imports Base (no models to create)
            Base.metadata.create_all(bind=engine)
            logger.info("✅ (Deprecated) metadata.create_all ejecutado por AUTH_AUTO_INIT_DB=true")
        except Exception as e:
            logger.error(f"❌ Error en create_all opcional: {e}")
            raise

def create_default_roles():
    """Deprecated: roles no usados con user_tokens. Mantener por compatibilidad de import."""
    logger.info("ℹ️ create_default_roles() omitido: roles no utilizados")
