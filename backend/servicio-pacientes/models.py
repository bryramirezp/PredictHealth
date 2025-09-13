# /backend/servicio-pacientes/models.py
# Modelos específicos para el servicio de pacientes/usuarios

from sqlalchemy import Column, String, Boolean, DateTime, Text, ForeignKey, Numeric, Integer, Date
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from shared_models.base import Base

class Usuario(Base):
    """Modelo para usuarios/pacientes con tipos de datos correctos"""
    __tablename__ = "usuarios"

    id_usuario = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    id_doctor = Column(UUID(as_uuid=True), nullable=False, index=True)  # Referencia externa al servicio de doctores
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    fecha_nacimiento = Column(Date, nullable=False)  # Cambiado a tipo Date
    genero = Column(String(20), nullable=False)
    zona_horaria = Column(String(50), default="America/Mexico_City", nullable=False)
    contrasena_hash = Column(String(255), nullable=False)
    activo = Column(Boolean, default=True, nullable=False)
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())
    fecha_actualizacion = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relaciones locales
    perfil_salud = relationship("PerfilSaludGeneral", back_populates="usuario", uselist=False)
    datos_biometricos = relationship("DatoBiometrico", back_populates="usuario")
    predicciones_riesgo = relationship("PrediccionRiesgo", back_populates="usuario")
    recomendaciones_recibidas = relationship("RecomendacionMedica", back_populates="usuario")

class PerfilSaludGeneral(Base):
    """Perfil de salud con tipos numéricos correctos para cálculos médicos"""
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

    # Relaciones
    usuario = relationship("Usuario", back_populates="perfil_salud")

class DatoBiometrico(Base):
    """Datos biométricos con tipos numéricos correctos"""
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

    # Relaciones
    usuario = relationship("Usuario", back_populates="datos_biometricos")

class PrediccionRiesgo(Base):
    """Predicciones de riesgo con tipos numéricos correctos"""
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

    # Relaciones
    usuario = relationship("Usuario", back_populates="predicciones_riesgo")
    recomendaciones_motivadas = relationship("RecomendacionMedica", back_populates="prediccion")

class RecomendacionMedica(Base):
    """Recomendaciones médicas"""
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

    # Relaciones
    usuario = relationship("Usuario", back_populates="recomendaciones_recibidas")
    prediccion = relationship("PrediccionRiesgo", back_populates="recomendaciones_motivadas")

# Alias para compatibilidad con el código existente
Paciente = Usuario