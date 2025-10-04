# /microservices\service-doctors\app\schemas\doctor.py
# /microservicios/servicio-doctores/app/schemas/doctor.py
# Schemas para el servicio de doctores

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime, date
from uuid import UUID

class DoctorBase(BaseModel):
    """Doctor base schema (business data only)"""
    first_name: str = Field(..., min_length=2, max_length=100, description="Doctor first name")
    last_name: str = Field(..., min_length=2, max_length=100, description="Doctor last name")
    email: EmailStr = Field(..., description="Doctor email")
    medical_license: str = Field(..., min_length=5, max_length=50, description="Medical license number")
    specialty_id: Optional[UUID] = Field(None, description="Medical specialty ID")
    institution_id: Optional[UUID] = Field(None, description="Institution ID")

class DoctorCreateRequest(DoctorBase):
    """Schema para crear un doctor"""
    # No se incluye la contraseña aquí, ya que se maneja en el servicio de autenticación
    # y se pasa por separado.
    pass

class DoctorUpdateRequest(BaseModel):
    """Doctor update schema"""
    first_name: Optional[str] = Field(None, min_length=2, max_length=100)
    last_name: Optional[str] = Field(None, min_length=2, max_length=100)
    email: Optional[EmailStr] = None
    medical_license: Optional[str] = Field(None, min_length=5, max_length=50)
    specialty: Optional[str] = Field(None, max_length=100)
    institution_id: Optional[UUID] = None

class DoctorResponse(DoctorBase):
    """Doctor response schema"""
    id: UUID = Field(..., description="Unique doctor ID")
    created_at: datetime = Field(..., description="Creation date")
    updated_at: datetime = Field(..., description="Last update date")
    
    model_config = {"from_attributes": True}

class DoctorSearchRequest(BaseModel):
    """Doctor search schema"""
    first_name: Optional[str] = Field(None, description="Filter by first name")
    last_name: Optional[str] = Field(None, description="Filter by last name")
    specialty: Optional[str] = Field(None, description="Filter by specialty")
    institution_id: Optional[UUID] = Field(None, description="Filter by institution")
    medical_license: Optional[str] = Field(None, description="Filter by medical license")

class DoctorListResponse(BaseModel):
    """Doctor list response"""
    doctors: List[DoctorResponse] = Field(..., description="Doctors list")
    total: int = Field(..., description="Total doctors")
    page: int = Field(..., description="Current page")
    limit: int = Field(..., description="Page size")

class DoctorStatisticsResponse(BaseModel):
    """Doctor statistics response"""
    total_doctors: int = Field(..., description="Total doctors")
    by_specialty: dict = Field(..., description="Count by specialty")
    by_institution: dict = Field(..., description="Count by institution")
    new_doctors_this_month: int = Field(..., description="New doctors this month")
