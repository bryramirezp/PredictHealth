# /microservices\service-doctors\app\models\doctor.py
# Renamed model attributes to English; attribute names map to existing DB column names (DB column names unchanged)
# /microservicios/servicio-doctores/app/models/doctor.py
# Modelo para doctores - solo datos de negocio

from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean, Integer, DECIMAL
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
from .base import Base

class Doctor(Base):
    """Modelo para doctores (solo datos de negocio)"""
    __tablename__ = "doctors"
    __table_args__ = {"extend_existing": True}

    id = Column('id', UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    institution_id = Column('institution_id', UUID(as_uuid=True), ForeignKey('medical_institutions.id'), nullable=True)
    first_name = Column('first_name', String(100), nullable=False)
    last_name = Column('last_name', String(100), nullable=False)
    email = Column('email', String(255), unique=True, nullable=False, index=True)
    medical_license = Column('medical_license', String(50), unique=True, nullable=False, index=True)
    specialty_id = Column('specialty_id', UUID(as_uuid=True), ForeignKey('doctor_specialties.id'), nullable=True)
    secondary_specialty_id = Column('secondary_specialty_id', UUID(as_uuid=True), ForeignKey('doctor_specialties.id'), nullable=True)
    phone = Column('phone', String(20), nullable=True)
    years_experience = Column('years_experience', Integer, default=0)
    consultation_fee = Column('consultation_fee', DECIMAL(10,2), nullable=True)
    is_active = Column('is_active', Boolean, default=True, nullable=False)
    professional_status = Column('professional_status', String(50), default='active')
    last_login = Column('last_login', DateTime(timezone=True), nullable=True)
    created_at = Column('created_at', DateTime(timezone=True), server_default=func.now())
    updated_at = Column('updated_at', DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
