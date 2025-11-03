# /microservices/service-doctors/app/domain.py
# Modelos y esquemas para el dominio de Doctores (3NF).

from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean, Integer, DECIMAL
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID as UUID_type
import uuid

from shared.database import Base

# --- Modelos de SQLAlchemy ---

class Doctor(Base):
    """Modelo SQLAlchemy para doctors."""
    __tablename__ = "doctors"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    institution_id = Column(UUID(as_uuid=True), ForeignKey('medical_institutions.id'), nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    sex_id = Column(Integer) # FK a sexes
    gender_id = Column(Integer) # FK a genders
    medical_license = Column(String(50), unique=True, nullable=False)
    specialty_id = Column(UUID(as_uuid=True), ForeignKey('doctor_specialties.id'))
    years_experience = Column(Integer, default=0)
    consultation_fee = Column(DECIMAL(10, 2))
    is_active = Column(Boolean, default=True, nullable=False)
    professional_status = Column(String(50), default='active')

    emails = relationship("Email", back_populates="doctor")
    phones = relationship("Phone", back_populates="doctor")

class Email(Base):
    """Modelo para la tabla normalizada de emails."""
    __tablename__ = "emails"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entity_type = Column(String(50), nullable=False)
    entity_id = Column(UUID(as_uuid=True), ForeignKey('doctors.id'))
    email_address = Column(String(255), nullable=False)
    is_primary = Column(Boolean, default=False, nullable=False)
    doctor = relationship("Doctor", back_populates="emails")

# --- Esquemas de Pydantic ---

class EmailSchema(BaseModel):
    email_address: EmailStr
    is_primary: bool = True

class DoctorBase(BaseModel):
    institution_id: UUID_type
    first_name: str
    last_name: str
    medical_license: str
    specialty_id: Optional[UUID_type] = None
    years_experience: Optional[int] = 0
    consultation_fee: Optional[float] = None

class DoctorCreateRequest(DoctorBase):
    """Esquema para crear un doctor con su email principal y contraseña."""
    contact_email: EmailSchema
    password: str = Field(..., min_length=8)

class DoctorUpdateRequest(BaseModel):
    """Esquema para actualizar un doctor (todos los campos son opcionales)."""
    institution_id: Optional[UUID_type] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    medical_license: Optional[str] = None
    specialty_id: Optional[UUID_type] = None
    years_experience: Optional[int] = None
    consultation_fee: Optional[float] = None
    professional_status: Optional[str] = None

class DoctorResponse(DoctorBase):
    """Esquema para la respuesta de un doctor."""
    id: UUID_type
    is_active: bool
    professional_status: str
    contact_email: Optional[EmailStr] = None # Se poblará en la lógica

    class Config:
        from_attributes = True
