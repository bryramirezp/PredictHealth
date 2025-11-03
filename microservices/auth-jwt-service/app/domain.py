# /microservices/auth-jwt-service/app/domain.py
# Modelos y esquemas para el dominio de Autenticación (3NF).

from sqlalchemy import Column, String, DateTime, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from pydantic import BaseModel, Field, EmailStr
from typing import Optional, Dict, Any
from datetime import datetime
from uuid import UUID as UUID_type
import uuid

from shared.database import Base

# --- Modelo de SQLAlchemy ---

class User(Base):
    """Modelo SQLAlchemy para la tabla de usuarios."""
    __tablename__ = "users"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    user_type = Column(String(50), nullable=False, index=True)
    reference_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    failed_login_attempts = Column(Integer, default=0)
    last_failed_login = Column(DateTime(timezone=True), nullable=True)
    password_changed_at = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

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
