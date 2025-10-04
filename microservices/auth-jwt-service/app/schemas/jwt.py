# /microservices\service-jwt\app\schemas\jwt.py
# /microservices/service-jwt/app/schemas/jwt.py
# JWT service schemas for token operations

from pydantic import BaseModel, Field
from typing import Dict, Any, Optional
from datetime import datetime

class CreateTokenRequest(BaseModel):
    """Request schema for creating JWT tokens"""
    user_id: str = Field(..., description="User ID from domain service")
    user_type: str = Field(..., pattern="^(patient|doctor|institution|admin)$", description="User type")
    email: str = Field(..., description="User email")
    roles: Optional[list] = Field(default=[], description="User roles")
    metadata: Optional[Dict[str, Any]] = Field(default={}, description="Additional metadata")

class VerifyTokenRequest(BaseModel):
    """Request schema for verifying JWT tokens"""
    token: str = Field(..., description="JWT token to verify")

class RefreshTokenRequest(BaseModel):
    """Request schema for refreshing access tokens"""
    refresh_token: str = Field(..., description="Refresh token to use")

class RevokeTokenRequest(BaseModel):
    """Request schema for revoking tokens"""
    token: str = Field(..., description="Token to revoke")

class TokenResponse(BaseModel):
    """Response schema for token operations"""
    access_token: Optional[str] = Field(None, description="JWT access token")
    refresh_token: Optional[str] = Field(None, description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Token expiration in seconds")
    user_id: str = Field(..., description="User ID")
    user_type: str = Field(..., description="User type")
    email: str = Field(..., description="User email")
    roles: list = Field(default=[], description="User roles")
    metadata: Dict[str, Any] = Field(default={}, description="Additional metadata")

class VerifyTokenResponse(BaseModel):
    """Response schema for token verification"""
    valid: bool = Field(..., description="Whether token is valid")
    user_id: Optional[str] = Field(None, description="User ID from token")
    user_type: Optional[str] = Field(None, description="User type from token")
    email: Optional[str] = Field(None, description="User email from token")
    roles: list = Field(default=[], description="User roles from token")
    metadata: Dict[str, Any] = Field(default={}, description="Metadata from token")
    expires_at: Optional[datetime] = Field(None, description="Token expiration time")
    token_type: Optional[str] = Field(None, description="Token type (access/refresh)")

class RevokeTokenResponse(BaseModel):
    """Response schema for token revocation"""
    revoked: bool = Field(..., description="Whether token was successfully revoked")
    message: str = Field(..., description="Result message")

class LoginRequest(BaseModel):
    """Request schema for user login"""
    email: str = Field(..., description="User email")
    password: str = Field(..., description="User password")

class LoginResponse(BaseModel):
    """Response schema for user login"""
    access_token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(..., description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Token expiration in seconds")
    user_id: str = Field(..., description="User ID")
    user_type: str = Field(..., description="User type")
    email: str = Field(..., description="User email")
    reference_id: str = Field(..., description="Reference ID to domain entity")
    access_token_id: str = Field(..., description="Access token ID for Redis lookup")

class LogoutRequest(BaseModel):
    """Request schema for user logout"""
    access_token: Optional[str] = Field(None, description="Access token to revoke")
    refresh_token: Optional[str] = Field(None, description="Refresh token to revoke")

class LogoutResponse(BaseModel):
    """Response schema for user logout"""
    logged_out: bool = Field(..., description="Whether logout was successful")
    message: str = Field(..., description="Logout result message")
