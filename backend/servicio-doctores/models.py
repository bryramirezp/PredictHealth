# /backend/servicio-doctores/models.py
# Modelos específicos para el servicio de doctores

from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
from shared_models.base import Base

class Doctor(Base):
    """Modelo específico para doctores - solo maneja entidades de doctores"""
    __tablename__ = "doctores"

    id_doctor = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    licencia_medica = Column(String(50), unique=True, nullable=False, index=True)
    contrasena_hash = Column(String(255), nullable=False)
    activo = Column(Boolean, default=True, nullable=False)
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())
    fecha_actualizacion = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
