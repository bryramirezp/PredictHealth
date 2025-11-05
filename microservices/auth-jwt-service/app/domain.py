# /microservices/auth-jwt-service/app/domain.py
# Modelos y esquemas para el dominio de Autenticación (3NF).

from pydantic import BaseModel, Field, EmailStr
from typing import Optional, Dict, Any
from uuid import UUID as UUID_type

# --- Esquemas de Pydantic ---

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenPayload(BaseModel):
    user_id: str
    user_type: str
    email: EmailStr
    roles: list = []
    metadata: Dict[str, Any] = {}

class VerifyTokenResponse(BaseModel):
    valid: bool
    payload: Optional[TokenPayload] = None

class UserCreateRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)
    user_type: str
    reference_id: UUID_type

class UserResponse(BaseModel):
    id: UUID_type
    email: EmailStr
    user_type: str
    is_active: bool
    is_verified: bool

    class Config:
        from_attributes = True
