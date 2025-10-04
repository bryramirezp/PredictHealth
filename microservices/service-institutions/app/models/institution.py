# /microservices\service-institutions\app\models\institution.py
# /microservicios/servicio-instituciones/models/institution.py
# Modelo para instituciones - solo datos de negocio

from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid
from .base import Base

class MedicalInstitution(Base):
    """Medical institution business model (credentials managed centrally)."""
    __tablename__ = "medical_institutions"
    __table_args__ = {"extend_existing": True}

    id = Column('id', UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column('name', String(200), nullable=False)
    institution_type = Column('institution_type', String(50), nullable=False)
    contact_email = Column('contact_email', String(255), unique=True, nullable=False, index=True)
    # Credentials are centralized in the auth service; keep domain model free of password_hash
    address = Column('address', String(255), nullable=True)
    region_state = Column('region_state', String(100), nullable=True)
    created_at = Column('created_at', DateTime(timezone=True), server_default=func.now())
    updated_at = Column('updated_at', DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
