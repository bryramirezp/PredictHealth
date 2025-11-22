# /microservices/service-institutions/app/domain.py
# Modelos y esquemas para el dominio de Instituciones (3NF).

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from uuid import UUID as UUID_type

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
    contact_email: Optional[EmailStr] = None

    class Config:
        from_attributes = True
