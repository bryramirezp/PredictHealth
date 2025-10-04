# /microservices\service-institutions\app\models\doctor.py
from sqlalchemy import Column, String, DateTime, Integer, DECIMAL, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from .base import Base


class Doctor(Base):
    """SQLAlchemy model for the doctors table (used by institution service to create doctors)."""

    __tablename__ = "doctors"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    institution_id = Column(UUID(as_uuid=True), ForeignKey('medical_institutions.id'), nullable=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    medical_license = Column(String(50), unique=True, nullable=False, index=True)
    specialty_id = Column(UUID(as_uuid=True), ForeignKey('doctor_specialties.id'), nullable=True)
    secondary_specialty_id = Column(UUID(as_uuid=True), ForeignKey('doctor_specialties.id'), nullable=True)
    phone = Column(String(20), nullable=True)
    years_experience = Column(Integer, default=0)
    consultation_fee = Column(DECIMAL(10,2), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    is_active = Column('is_active', Boolean, default=True, nullable=False)
    professional_status = Column(String(50), default='active')