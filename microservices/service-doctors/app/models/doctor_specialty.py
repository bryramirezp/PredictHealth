from sqlalchemy import Column, String, Text, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

from ..core.database import Base

class DoctorSpecialty(Base):
    """SQLAlchemy model for the doctor_specialties table.

    This model represents medical specialties that doctors can have.
    """
    __tablename__ = "doctor_specialties"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text)
    category = Column(String(50))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    def __repr__(self):
        return f"<DoctorSpecialty(id={self.id}, name='{self.name}', category='{self.category}')>"