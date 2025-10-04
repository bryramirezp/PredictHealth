# /microservices\service-doctors\app\models\patient.py
from sqlalchemy import Column, String, DateTime, Date, ForeignKey, Text, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from .base import Base


class Patient(Base):
    """SQLAlchemy model for the patients table (used by doctor service to create patients)."""

    __tablename__ = "patients"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    doctor_id = Column(UUID(as_uuid=True), ForeignKey('doctors.id'), nullable=True)
    institution_id = Column(UUID(as_uuid=True), ForeignKey('medical_institutions.id'), nullable=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    date_of_birth = Column(Date, nullable=False)
    gender = Column(String(20), nullable=True)  # 'male', 'female', 'other', 'prefer_not_to_say'
    phone = Column(String(20), nullable=True)
    emergency_contact_name = Column(String(200), nullable=True)
    emergency_contact_phone = Column(String(20), nullable=True)
    validation_status = Column(String(50), default='pending', nullable=False)  # 'pending', 'doctor_validated', 'institution_validated', 'full_access'
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    is_active = Column('is_active', Boolean, default=True, nullable=False)
    is_verified = Column('is_verified', Boolean, default=False, nullable=False)
    last_login = Column(DateTime(timezone=True), nullable=True)