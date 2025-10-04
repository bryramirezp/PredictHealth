# /microservices\service-admins\app\schemas\admin.py
# /microservices/service-admins/app/schemas/admin.py
# Schemas para el servicio de administradores

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class AdminBase(BaseModel):
    """Admin base schema"""
    email: EmailStr = Field(..., description="Admin email")
    first_name: str = Field(..., min_length=2, max_length=100, description="Admin first name")
    last_name: str = Field(..., min_length=2, max_length=100, description="Admin last name")
    department: Optional[str] = Field(None, max_length=100, description="Department")
    employee_id: Optional[str] = Field(None, max_length=50, description="Employee ID")
    phone: Optional[str] = Field(None, max_length=20, description="Phone number")

class AdminCreateRequest(AdminBase):
    """Schema for creating an admin"""
    password: str = Field(..., min_length=8, description="Admin password")

class AdminUpdateRequest(BaseModel):
    """Schema for updating an admin"""
    first_name: Optional[str] = Field(None, min_length=2, max_length=100)
    last_name: Optional[str] = Field(None, min_length=2, max_length=100)
    email: Optional[EmailStr] = None
    department: Optional[str] = Field(None, max_length=100)
    employee_id: Optional[str] = Field(None, max_length=50)
    phone: Optional[str] = Field(None, max_length=20)
    is_active: Optional[bool] = None

class AdminResponse(AdminBase):
    """Admin response schema"""
    id: UUID = Field(..., description="Unique admin ID")
    user_id: UUID = Field(..., description="Associated user ID")
    is_active: bool = Field(..., description="Active status")
    last_login: Optional[datetime] = Field(None, description="Last login time")
    created_at: datetime = Field(..., description="Creation date")
    updated_at: datetime = Field(..., description="Last update date")

    model_config = {"from_attributes": True}

class AdminListResponse(BaseModel):
    """Admin list response"""
    admins: List[AdminResponse] = Field(..., description="Admins list")
    total: int = Field(..., description="Total admins")
    page: int = Field(..., description="Current page")
    limit: int = Field(..., description="Page size")

class AdminAuditLogResponse(BaseModel):
    """Admin audit log response"""
    id: UUID = Field(..., description="Log ID")
    admin_id: UUID = Field(..., description="Admin ID")
    action: str = Field(..., description="Action performed")
    resource_type: str = Field(..., description="Resource type affected")
    resource_id: Optional[UUID] = Field(None, description="Resource ID affected")
    details: Optional[str] = Field(None, description="Action details")
    ip_address: Optional[str] = Field(None, description="IP address")
    user_agent: Optional[str] = Field(None, description="User agent")
    success: bool = Field(..., description="Action success")
    created_at: datetime = Field(..., description="Log timestamp")

    model_config = {"from_attributes": True}

class AdminAuditLogsResponse(BaseModel):
    """Admin audit logs list response"""
    logs: List[AdminAuditLogResponse] = Field(..., description="Audit logs")
    total: int = Field(..., description="Total logs")
    page: int = Field(..., description="Current page")
    limit: int = Field(..., description="Page size")

# Institution creation schemas (since admins create institutions)
class InstitutionCreateRequest(BaseModel):
    """Schema for creating a medical institution"""
    name: str = Field(..., min_length=2, max_length=200, description="Institution name")
    institution_type: str = Field(..., description="Institution type",
                                  pattern="^(preventive_clinic|insurer|public_health|hospital|health_center)$")
    contact_email: EmailStr = Field(..., description="Contact email")
    password: str = Field(..., min_length=8, description="Institution password")
    address: Optional[str] = Field(None, max_length=255, description="Institution address")
    region_state: Optional[str] = Field(None, max_length=100, description="Region/State")
    phone: Optional[str] = Field(None, max_length=20, description="Phone number")
    website: Optional[str] = Field(None, max_length=255, description="Website URL")
    license_number: Optional[str] = Field(None, max_length=100, description="License number")

class InstitutionResponse(BaseModel):
    """Institution response schema"""
    id: UUID = Field(..., description="Institution ID")
    name: str = Field(..., description="Institution name")
    institution_type: str = Field(..., description="Institution type")
    contact_email: EmailStr = Field(..., description="Contact email")
    address: Optional[str] = Field(None, description="Address")
    region_state: Optional[str] = Field(None, description="Region/State")
    phone: Optional[str] = Field(None, description="Phone")
    website: Optional[str] = Field(None, description="Website")
    license_number: Optional[str] = Field(None, description="License number")
    is_active: bool = Field(..., description="Active status")
    is_verified: bool = Field(..., description="Verification status")
    created_at: datetime = Field(..., description="Creation date")
    updated_at: datetime = Field(..., description="Last update date")

    model_config = {"from_attributes": True}

class InstitutionListResponse(BaseModel):
    """Institution list response"""
    institutions: List[InstitutionResponse] = Field(..., description="Institutions list")
    total: int = Field(..., description="Total institutions")
    page: int = Field(..., description="Current page")
    limit: int = Field(..., description="Page size")