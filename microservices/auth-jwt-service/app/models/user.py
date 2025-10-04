# /microservices\service-jwt\app\models\user.py
from sqlalchemy import Column, String, DateTime, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from .base import Base


class User(Base):
    """SQLAlchemy model for the users table (centralized authentication).

    This model is used by the JWT service to authenticate users.
    """

    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), nullable=False, unique=True, index=True)
    password_hash = Column(String(255), nullable=False)
    user_type = Column(String(50), nullable=False, index=True)  # 'patient','doctor','admin','institution'
    reference_id = Column(UUID(as_uuid=True), nullable=False, index=True)  # ID in domain table
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    failed_login_attempts = Column(Integer, default=0)
    last_failed_login = Column(DateTime(timezone=True), nullable=True)
    password_changed_at = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())