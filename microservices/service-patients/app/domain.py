# /microservices/service-patients/app/domain.py
# Modelos y esquemas para el dominio de Pacientes (3NF).

from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean, Integer, DECIMAL, Date
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime, date as date_type
from uuid import UUID as UUID_type
import uuid

from shared.database import Base

# --- Modelos de SQLAlchemy ---

class Patient(Base):
    """Modelo SQLAlchemy para patients."""
    __tablename__ = "patients"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    doctor_id = Column(UUID(as_uuid=True), ForeignKey('doctors.id'), nullable=False)
    institution_id = Column(UUID(as_uuid=True), ForeignKey('medical_institutions.id'), nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    date_of_birth = Column(Date, nullable=False)
    sex_id = Column(Integer) # FK a sexes
    gender_id = Column(Integer) # FK a genders
    emergency_contact_name = Column(String(200))
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)

    health_profile = relationship("HealthProfile", back_populates="patient", uselist=False)
    emails = relationship("Email", back_populates="patient")

class HealthProfile(Base):
    """Modelo SQLAlchemy para health_profiles."""
    __tablename__ = "health_profiles"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey('patients.id'), unique=True, nullable=False)
    height_cm = Column(DECIMAL(5, 2))
    weight_kg = Column(DECIMAL(5, 2))
    blood_type_id = Column(Integer) # FK a blood_types

    patient = relationship("Patient", back_populates="health_profile")

class Email(Base):
    """Modelo para la tabla normalizada de emails."""
    __tablename__ = "emails"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entity_type = Column(String(50), nullable=False)
    entity_id = Column(UUID(as_uuid=True), ForeignKey('patients.id'))
    email_address = Column(String(255), nullable=False)
    is_primary = Column(Boolean, default=False, nullable=False)
    patient = relationship("Patient", back_populates="emails")

# --- Esquemas de Pydantic ---

class EmailSchema(BaseModel):
    email_address: EmailStr
    is_primary: bool = True

class HealthProfileSchema(BaseModel):
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    blood_type_id: Optional[int] = None

class PatientBase(BaseModel):
    doctor_id: UUID_type
    institution_id: UUID_type
    first_name: str
    last_name: str
    date_of_birth: date_type
    sex_id: Optional[int] = None
    gender_id: Optional[int] = None

class PatientCreateRequest(PatientBase):
    """Esquema para crear un paciente con su perfil, email y contraseña."""
    contact_email: EmailSchema
    health_profile: HealthProfileSchema
    password: str = Field(..., min_length=8)

class PatientUpdateRequest(BaseModel):
    """Esquema para actualizar un paciente (todos los campos son opcionales)."""
    doctor_id: Optional[UUID_type] = None
    institution_id: Optional[UUID_type] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    date_of_birth: Optional[date_type] = None
    sex_id: Optional[int] = None
    gender_id: Optional[int] = None
    emergency_contact_name: Optional[str] = None

class PatientResponse(PatientBase):
    """Esquema para la respuesta completa de un paciente."""
    id: UUID_type
    is_active: bool
    is_verified: bool
    contact_email: Optional[EmailStr] = None
    health_profile: Optional[HealthProfileSchema] = None

    class Config:
        from_attributes = True
