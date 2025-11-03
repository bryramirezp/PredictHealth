# /microservices/service-institutions/app/domain.py
# Modelos y esquemas para el dominio de Instituciones (3NF).

from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID as UUID_type
import uuid

from shared.database import Base

# --- Modelos de SQLAlchemy ---

class MedicalInstitution(Base):
    """Modelo SQLAlchemy para medical_institutions."""
    __tablename__ = "medical_institutions"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False)
    institution_type_id = Column(Integer, nullable=False) # FK a institution_types
    website = Column(String(255))
    license_number = Column(String(100), unique=True, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)

    # Relaciones para acceder a la información de contacto
    emails = relationship("Email", back_populates="institution")
    phones = relationship("Phone", back_populates="institution")
    addresses = relationship("Address", back_populates="institution")

class Email(Base):
    """Modelo para la tabla normalizada de emails."""
    __tablename__ = "emails"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entity_type = Column(String(50), nullable=False)
    entity_id = Column(UUID(as_uuid=True), ForeignKey('medical_institutions.id'))
    email_address = Column(String(255), nullable=False)
    is_primary = Column(Boolean, default=False, nullable=False)
    institution = relationship("MedicalInstitution", back_populates="emails")

# Se podrían añadir aquí los modelos para Phone y Address si se decide que este servicio los gestione

# --- Esquemas de Pydantic ---

class EmailSchema(BaseModel):
    email_address: EmailStr
    is_primary: bool = True

class InstitutionBase(BaseModel):
    name: str
    institution_type_id: int
    website: Optional[str] = None
    license_number: str

class InstitutionCreateRequest(InstitutionBase):
    """Esquema para crear una institución con su email principal y contraseña."""
    contact_email: EmailSchema
    password: str = Field(..., min_length=8)

class InstitutionUpdateRequest(BaseModel):
    """Esquema para actualizar una institución (todos los campos son opcionales)."""
    name: Optional[str] = None
    institution_type_id: Optional[int] = None
    website: Optional[str] = None
    license_number: Optional[str] = None

class InstitutionResponse(InstitutionBase):
    """Esquema para la respuesta de una institución."""
    id: UUID_type
    is_active: bool
    is_verified: bool
    contact_email: Optional[EmailStr] = None # Se poblará en la lógica

    class Config:
        from_attributes = True
