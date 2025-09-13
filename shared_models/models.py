# /backend/shared_models/models.py
# Modelos compartidos con tipos de datos correctos

from sqlalchemy import Column, String, Boolean, DateTime, Text, ForeignKey, Numeric, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from .base import Base

class Doctor(Base):
    """Modelo para doctores - solo en servicio-doctores"""
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

class Usuario(Base):
    """Modelo para usuarios/pacientes - solo en servicio-pacientes"""
    __tablename__ = "usuarios"

    id_usuario = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    id_doctor = Column(UUID(as_uuid=True), nullable=False, index=True)  # Referencia externa
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    fecha_nacimiento = Column(String(10), nullable=False)  # Mantenido como String para compatibilidad frontend
    genero = Column(String(20), nullable=False)
    contrasena_hash = Column(String(255), nullable=False)
    activo = Column(Boolean, default=True, nullable=False)
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())
    fecha_actualizacion = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class PerfilSaludGeneral(Base):
    """Perfil de salud del usuario - solo en servicio-pacientes"""
    __tablename__ = "perfil_salud_general"

    id_perfil = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    id_usuario = Column(UUID(as_uuid=True), ForeignKey("usuarios.id_usuario"), nullable=False, unique=True)
    # Tipos numéricos correctos para cálculos médicos
    altura_cm = Column(Numeric(5, 2), nullable=True)
    peso_kg = Column(Numeric(5, 2), nullable=True)
    fumador = Column(Boolean, default=False)
    consumo_alcohol = Column(Boolean, default=False)
    diagnostico_hipertension = Column(Boolean, default=False)
    diagnostico_colesterol_alto = Column(Boolean, default=False)
    antecedente_acv = Column(Boolean, default=False)
    antecedente_enf_cardiaca = Column(Boolean, default=False)
    condiciones_preexistentes_notas = Column(Text, nullable=True)
    minutos_actividad_fisica_semanal = Column(Integer, default=0)
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())
    fecha_actualizacion = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class DatoBiometrico(Base):
    """Datos biométricos del usuario - solo en servicio-pacientes"""
    __tablename__ = "datos_biometricos"

    id_dato_biometrico = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    id_usuario = Column(UUID(as_uuid=True), ForeignKey("usuarios.id_usuario"), nullable=False)
    fecha_hora_medida = Column(DateTime(timezone=True), nullable=False)
    tipo_medida = Column(String(50), nullable=False)
    # Tipo numérico correcto para valores médicos
    valor = Column(Numeric(10, 2), nullable=False)
    unidad = Column(String(20), nullable=False)
    fuente_dato = Column(String(50), nullable=False)
    id_doctor_registro = Column(UUID(as_uuid=True), nullable=True)  # Referencia externa
    notas = Column(Text, nullable=True)
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())

class PrediccionRiesgo(Base):
    """Predicciones de riesgo de salud - solo en servicio-pacientes"""
    __tablename__ = "predicciones_riesgo"

    id_prediccion = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    id_usuario = Column(UUID(as_uuid=True), ForeignKey("usuarios.id_usuario"), nullable=False)
    fecha_prediccion = Column(DateTime(timezone=True), nullable=False)
    tipo_riesgo = Column(String(50), nullable=False)
    # Tipo numérico correcto para puntuaciones
    puntuacion_riesgo = Column(Numeric(5, 2), nullable=False)
    nivel_riesgo = Column(String(20), nullable=False)
    detalles_prediccion = Column(Text, nullable=True)
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())

class RecomendacionMedica(Base):
    """Recomendaciones médicas - solo en servicio-pacientes"""
    __tablename__ = "recomendaciones_medicas"

    id_recomendacion = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    id_usuario = Column(UUID(as_uuid=True), ForeignKey("usuarios.id_usuario"), nullable=False)
    id_doctor = Column(UUID(as_uuid=True), nullable=False)  # Referencia externa
    id_prediccion = Column(UUID(as_uuid=True), ForeignKey("predicciones_riesgo.id_prediccion"), nullable=True)
    fecha_generacion = Column(DateTime(timezone=True), nullable=False)
    contenido_es = Column(Text, nullable=False)
    estado_recomendacion = Column(String(20), default="pendiente")
    feedback_doctor = Column(Text, nullable=True)
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())
    fecha_actualizacion = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
