# /microservices\service-jwt\app\models\user_token.py
from sqlalchemy import Column, String, DateTime, Boolean, Text
from sqlalchemy.dialects.postgresql import UUID, INET
from sqlalchemy.sql import func
import uuid

from .base import Base


class UserToken(Base):
    """SQLAlchemy model mapped to the user_tokens table defined in init.sql.

    Stores access/refresh/audit token hashes for any user type with device tracking.
    """

    __tablename__ = "user_tokens"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    user_type = Column(String(50), nullable=False, index=True)
    token_type = Column(String(50), nullable=False, index=True)  # 'access' | 'refresh' | 'audit'
    token_hash = Column(String(255), nullable=False, unique=True, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=False, index=True)
    is_active = Column(Boolean, default=True, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    last_used_at = Column(DateTime(timezone=True), nullable=True)

    # Device information for security tracking
    user_agent = Column(Text, nullable=True)
    ip_address = Column(INET, nullable=True)
    device_fingerprint = Column(String(64), nullable=True, index=True)  # SHA-256 hash
    device_name = Column(String(255), nullable=True)
    device_type = Column(String(50), nullable=True)  # 'mobile', 'desktop', 'tablet', etc.
    browser_name = Column(String(100), nullable=True)
    browser_version = Column(String(50), nullable=True)
    os_name = Column(String(100), nullable=True)
    os_version = Column(String(50), nullable=True)
    location_country = Column(String(100), nullable=True)
    location_region = Column(String(100), nullable=True)


class RevokedToken(Base):
    """SQLAlchemy model mapped to the revoked_tokens table defined in init.sql.

    Stores revoked token hashes for security.
    """

    __tablename__ = "revoked_tokens"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    token_hash = Column(String(255), nullable=False, unique=True, index=True)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    revoked_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False, index=True)
    revocation_reason = Column(String(100), default='manual', nullable=False)

