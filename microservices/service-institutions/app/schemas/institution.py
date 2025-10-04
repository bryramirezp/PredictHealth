# /microservices\service-institutions\app\schemas\institution.py
# /microservicios/servicio-instituciones/schemas/institution.py
# Schemas para el servicio de instituciones

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
import uuid

class InstitutionCreateRequest(BaseModel):
    """Schema for creating an institution"""
    name: str = Field(..., min_length=1, max_length=200, description="Institution name")
    institution_type: str = Field(..., description="Institution type")
    contact_email: EmailStr = Field(..., description="Contact email")
    password: Optional[str] = Field(None, min_length=8, description="Institution password for authentication")
    address: Optional[str] = Field(None, max_length=255, description="Institution address")
    region_state: Optional[str] = Field(None, max_length=100, description="Region or state")

class InstitutionUpdateRequest(BaseModel):
    """Schema for updating an institution"""
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    institution_type: Optional[str] = Field(None)
    contact_email: Optional[EmailStr] = Field(None)
    address: Optional[str] = Field(None, max_length=255)
    region_state: Optional[str] = Field(None, max_length=100)

class InstitutionResponse(BaseModel):
    """Institution response schema"""
    id: str
    name: str
    institution_type: str
    contact_email: str
    address: Optional[str]
    region_state: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}

class InstitutionSearchRequest(BaseModel):
    """Institution search schema"""
    query: str = Field(..., min_length=1, description="Search term")
    institution_type: Optional[str] = Field(None, description="Filter by type")
    region: Optional[str] = Field(None, description="Filter by region")

class InstitutionListResponse(BaseModel):
    """Schema para lista de instituciones"""
    institutions: List[InstitutionResponse]
    total: int
    page: int
    limit: int

class InstitutionStatisticsResponse(BaseModel):
    """Schema para estadísticas de instituciones"""
    total_institutions: int
    by_type: Dict[str, int]
    by_region: Dict[str, int]

class InstitutionLoginRequest(BaseModel):
    """Schema for institution login"""
    email: EmailStr = Field(..., description="Institution email")
    password: str = Field(..., min_length=1, description="Institution password")
    user_type: str = Field(..., description="User type (should be 'institution')")

class InstitutionLoginResponse(BaseModel):
    """Schema for institution login response"""
    id: str
    name: str
    institution_type: str
    contact_email: str
    address: Optional[str]
    region_state: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}
