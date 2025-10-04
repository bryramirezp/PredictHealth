# /microservices\service-admins\app\services\admin_service.py
# /microservices/service-admins/app/services/admin_service.py
# Servicio de negocio para administradores

import logging
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from fastapi import HTTPException, status
import httpx

from ..core.config import settings
from ..models.admin import Admin, AdminAuditLog
from ..schemas.admin import (
    AdminCreateRequest, AdminUpdateRequest, AdminResponse,
    InstitutionCreateRequest, InstitutionResponse
)

logger = logging.getLogger(__name__)

class AdminService:
    """Servicio para operaciones de administradores"""

    def __init__(self):
        self.jwt_service_url = settings.jwt_service_url
        self.institutions_service_url = settings.institutions_service_url

    async def create_admin(self, db: Session, admin_data: AdminCreateRequest, created_by: str = None) -> AdminResponse:
        """Crear un nuevo administrador"""
        try:
            # First create user in JWT service
            user_payload = {
                "email": admin_data.email,
                "password": admin_data.password,
                "user_type": "admin",
                "first_name": admin_data.first_name,
                "last_name": admin_data.last_name
            }

            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.jwt_service_url}/auth/register",
                    json=user_payload,
                    timeout=10.0
                )

                if response.status_code != 200:
                    error_detail = response.json().get('detail', 'Failed to create user')
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"User creation failed: {error_detail}"
                    )

                user_data = response.json()
                user_id = user_data.get('user_id')

            # Create admin record
            db_admin = Admin(
                user_id=user_id,
                email=admin_data.email,
                first_name=admin_data.first_name,
                last_name=admin_data.last_name,
                department=admin_data.department,
                employee_id=admin_data.employee_id,
                phone=admin_data.phone
            )

            db.add(db_admin)
            db.commit()
            db.refresh(db_admin)

            # Log the action
            await self._log_admin_action(
                db, db_admin.id, "admin_created", "admin", db_admin.id,
                f"Created admin: {db_admin.full_name}", created_by
            )

            return AdminResponse.model_validate(db_admin)

        except Exception as e:
            db.rollback()
            logger.error(f"Error creating admin: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create admin"
            )

    def get_admin(self, db: Session, admin_id: str) -> AdminResponse:
        """Obtener un administrador por ID"""
        admin = db.query(Admin).filter(Admin.id == admin_id).first()
        if not admin:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Admin not found"
            )
        return AdminResponse.model_validate(admin)

    def get_admins(self, db: Session, skip: int = 0, limit: int = 100) -> tuple[List[AdminResponse], int]:
        """Obtener lista de administradores con conteo total"""
        # Get total count
        total = db.query(func.count(Admin.id)).scalar()

        # Get paginated results
        admins = db.query(Admin).offset(skip).limit(limit).all()
        return [AdminResponse.model_validate(admin) for admin in admins], total

    async def update_admin(self, db: Session, admin_id: str, update_data: AdminUpdateRequest, updated_by: str = None) -> AdminResponse:
        """Actualizar un administrador"""
        admin = db.query(Admin).filter(Admin.id == admin_id).first()
        if not admin:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Admin not found"
            )

        # Update fields
        for field, value in update_data.model_dump(exclude_unset=True).items():
            setattr(admin, field, value)

        db.commit()
        db.refresh(admin)

        # Log the action
        await self._log_admin_action(
            db, admin_id, "admin_updated", "admin", admin_id,
            f"Updated admin: {admin.full_name}", updated_by
        )

        return AdminResponse.model_validate(admin)

    async def delete_admin(self, db: Session, admin_id: str, deleted_by: str = None) -> bool:
        """Eliminar un administrador"""
        admin = db.query(Admin).filter(Admin.id == admin_id).first()
        if not admin:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Admin not found"
            )

        # Log before deletion
        await self._log_admin_action(
            db, admin_id, "admin_deleted", "admin", admin_id,
            f"Deleted admin: {admin.full_name}", deleted_by
        )

        db.delete(admin)
        db.commit()
        return True

    async def create_institution(self, db: Session, institution_data: InstitutionCreateRequest, created_by: str = None) -> InstitutionResponse:
        """Crear una nueva institución médica"""
        try:
            # Create institution via institutions service
            institution_payload = {
                "name": institution_data.name,
                "institution_type": institution_data.institution_type,
                "contact_email": institution_data.contact_email,
                "password": institution_data.password,
                "address": institution_data.address,
                "region_state": institution_data.region_state,
                "phone": institution_data.phone,
                "website": institution_data.website,
                "license_number": institution_data.license_number
            }

            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.institutions_service_url}/api/v1/institutions/",
                    json=institution_payload,
                    timeout=10.0
                )

                if response.status_code not in [200, 201]:
                    error_detail = response.json().get('detail', 'Failed to create institution')
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Institution creation failed: {error_detail}"
                    )

                institution_data_response = response.json()

            # Log the action
            await self._log_admin_action(
                db, created_by, "institution_created", "institution", institution_data_response.get('id'),
                f"Created institution: {institution_data.name}", created_by
            )

            return InstitutionResponse(**institution_data_response)

        except Exception as e:
            logger.error(f"Error creating institution: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create institution"
            )

    def get_audit_logs(self, db: Session, admin_id: Optional[str] = None, skip: int = 0, limit: int = 100):
        """Obtener logs de auditoría con conteo total"""
        query = db.query(AdminAuditLog)

        if admin_id:
            query = query.filter(AdminAuditLog.admin_id == admin_id)

        # Get total count
        total = query.count()

        # Get paginated results
        logs = query.order_by(AdminAuditLog.created_at.desc()).offset(skip).limit(limit).all()
        return logs, total

    async def _log_admin_action(self, db: Session, admin_id: str, action: str, resource_type: str,
                               resource_id: Optional[str] = None, details: str = None, performed_by: str = None):
        """Registrar una acción de administrador"""
        try:
            audit_log = AdminAuditLog(
                admin_id=admin_id if admin_id else performed_by,
                action=action,
                resource_type=resource_type,
                resource_id=resource_id,
                details=details
            )

            db.add(audit_log)
            db.commit()

        except Exception as e:
            logger.error(f"Failed to log admin action: {str(e)}")
            # Don't raise exception for logging failures

# Instancia global del servicio
admin_service = AdminService()