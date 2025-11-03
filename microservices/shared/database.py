# /microservices/shared/database.py
# Módulo unificado para la configuración y sesión de la base de datos.

import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import SQLAlchemyError
import logging

# Configurar logging
logger = logging.getLogger(__name__)

# Cargar la URL de la base de datos desde las variables de entorno
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    logger.error("La variable de entorno DATABASE_URL no está configurada.")
    raise ValueError("La variable de entorno DATABASE_URL no está configurada.")

try:
    # Crear el engine de SQLAlchemy
    engine = create_engine(DATABASE_URL)

    # Crear una factoría de sesiones
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    # Crear una clase Base para los modelos declarativos
    Base = declarative_base()

    logger.info("✅ Conexión a la base de datos configurada exitosamente.")

except SQLAlchemyError as e:
    logger.error(f"❌ Error al configurar la base de datos: {e}")
    raise

def get_db():
    """
    Función de dependencia de FastAPI para obtener una sesión de base de datos.
    Asegura que la sesión se cierre correctamente después de su uso.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
