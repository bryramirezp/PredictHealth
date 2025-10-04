# /microservices\service-patients\app\schemas\patient.py
# /microservicios/servicio-pacientes/app/schemas/patient.py
# Schemas para el servicio de pacientes

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime, date
from uuid import UUID

class PatientBase(BaseModel):
    """Patient base schema"""
    first_name: str = Field(..., min_length=2, max_length=100, description="Patient first name")
    last_name: str = Field(..., min_length=2, max_length=100, description="Patient last name")
    email: EmailStr = Field(..., description="Patient email")
    date_of_birth: date = Field(..., description="Date of birth")
    gender: Optional[str] = Field(None, description="Patient gender")
    doctor_id: Optional[UUID] = Field(None, description="Assigned doctor ID")
    institution_id: Optional[UUID] = Field(None, description="Medical institution ID")
    
class PatientCreateRequest(PatientBase):
    """Schema para crear un paciente"""
    # No se incluye la contraseña aquí, ya que se maneja en el servicio de autenticación
    # y se pasa por separado.
    pass

class PatientUpdateRequest(BaseModel):
    """Patient update schema"""
    first_name: Optional[str] = Field(None, min_length=2, max_length=100)
    last_name: Optional[str] = Field(None, min_length=2, max_length=100)
    email: Optional[EmailStr] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    doctor_id: Optional[UUID] = None
    institution_id: Optional[UUID] = None
    validation_status: Optional[str] = None

class PatientResponse(PatientBase):
    """Patient response schema"""
    id: UUID = Field(..., description="Unique patient ID")
    validation_status: str = Field(..., description="Patient validation status")
    created_at: datetime = Field(..., description="Creation date")
    updated_at: datetime = Field(..., description="Last update date")
    
    model_config = {"from_attributes": True}

class PatientSearchRequest(BaseModel):
    """Patient search schema"""
    first_name: Optional[str] = Field(None, description="Filter by first name")
    last_name: Optional[str] = Field(None, description="Filter by last name")
    gender: Optional[str] = Field(None, description="Filter by gender")
    validation_status: Optional[str] = Field(None, description="Filter by validation status")
    doctor_id: Optional[UUID] = Field(None, description="Filter by doctor")
    institution_id: Optional[UUID] = Field(None, description="Filter by institution")

class PatientListResponse(BaseModel):
    """Patient list response"""
    patients: List[PatientResponse] = Field(..., description="Patients list")
    total: int = Field(..., description="Total patients")
    page: int = Field(..., description="Current page")
    limit: int = Field(..., description="Page size")

class PatientStatisticsResponse(BaseModel):
    """Patient statistics response"""
    total_patients: int = Field(..., description="Total patients")
    by_gender: dict = Field(..., description="Count by gender")
    by_validation_state: dict = Field(..., description="Count by validation state")
    by_doctor: dict = Field(..., description="Count by doctor")
    new_patients_this_month: int = Field(..., description="New patients this month")
