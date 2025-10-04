# /microservices\service-admins\app\models\admin.py
# /microservices/service-admins/app/models/admin.py
# Modelos de base de datos para administradores

from sqlalchemy import Column, String, Boolean, DateTime, Text, UUID, ForeignKey, Integer
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..core.database import Base

class Admin(Base):
    """Modelo para administradores"""
    __tablename__ = "admins"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.uuid_generate_v4())
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    email = Column(String(255), nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    department = Column(String(100))
    employee_id = Column(String(50), unique=True)
    phone = Column(String(20))
    is_active = Column(Boolean, default=True, nullable=False)
    last_login = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relación con audit logs
    audit_logs = relationship("AdminAuditLog", back_populates="admin", cascade="all, delete-orphan")

    @property
    def full_name(self) -> str:
        """Retorna el nombre completo del administrador"""
        return f"{self.first_name} {self.last_name}"

class AdminAuditLog(Base):
    """Modelo para logs de auditoría de administradores"""
    __tablename__ = "admin_audit_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.uuid_generate_v4())
    admin_id = Column(UUID(as_uuid=True), ForeignKey("admins.id", ondelete="CASCADE"), nullable=False)
    action = Column(String(100), nullable=False)
    resource_type = Column(String(50), nullable=False)
    resource_id = Column(UUID(as_uuid=True))
    details = Column(Text)
    ip_address = Column(String(45))  # IPv6 support
    user_agent = Column(Text)
    success = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relación con admin
    admin = relationship("Admin", back_populates="audit_logs")