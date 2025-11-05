# /microservices/service-patients/app/domain.py
# Modelos y esquemas para el dominio de Pacientes (3NF).

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import date as date_type
from uuid import UUID as UUID_type

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
    health_profile: Optional[dict] = None

    class Config:
        from_attributes = True
