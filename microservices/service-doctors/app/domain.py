# /microservices/service-doctors/app/domain.py
# Modelos y esquemas para el dominio de Doctores (3NF).

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from uuid import UUID as UUID_type

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
