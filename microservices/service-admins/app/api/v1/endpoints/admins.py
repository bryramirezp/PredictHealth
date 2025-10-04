# /microservices\service-admins\app\api\v1\endpoints\admins.py
# Endpoints de administradores para API v1

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError, IntegrityError, DataError
from typing import List, Optional
import logging

from app.core.database import get_db
from app.core.security import get_current_admin
from app.services.admin_service import admin_service
from app.models.admin import Admin
from ....schemas.admin import (
    AdminCreateRequest, AdminUpdateRequest, AdminResponse, AdminListResponse,
    InstitutionCreateRequest, InstitutionResponse, InstitutionListResponse,
    AdminAuditLogsResponse, AdminAuditLogResponse
)

logger = logging.getLogger(__name__)

# Crear router para administradores
router = APIRouter()

# ============================================================================
# ENDPOINTS PÚBLICOS (SIN AUTENTICACIÓN)
# ============================================================================

@router.get("/health", status_code=200)
async def health_check():
    """Health check endpoint - no requiere autenticación"""
    return {
        "status": "healthy",
        "service": "servicio-admins",
        "version": "1.0.0"
    }

@router.get("/statistics")
async def get_statistics(
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Obtener estadísticas del sistema (requiere autenticación admin)"""
    try:
        logger.info("Obteniendo estadísticas del sistema")
        
        # Contar admins activos
        total_admins = db.query(Admin).filter(Admin.is_active == True).count()
        active_admins = total_admins  # Por ahora son lo mismo
        
        # Contar instituciones
        try:
            from app.models.institution import MedicalInstitution
            total_institutions = db.query(MedicalInstitution).count()
        except ImportError:
            logger.warning("Modelo MedicalInstitution no encontrado, usando 0")
            total_institutions = 0
        
        stats = {
            "total_admins": total_admins,
            "active_admins": active_admins,
            "total_institutions": total_institutions
        }
        
        logger.info(f"Estadísticas obtenidas: {stats}")
        return stats
        
    except Exception as e:
        logger.error(f"Error obteniendo estadísticas: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error obteniendo estadísticas: {str(e)}"
        )

# ============================================================================
# ENDPOINTS DE ADMINISTRADORES
# ============================================================================

@router.post("/", response_model=AdminResponse, status_code=status.HTTP_201_CREATED)
async def create_admin(
    admin_data: AdminCreateRequest,
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Crear un nuevo administrador (solo administradores)"""
    try:
        logger.info(f"Creando administrador: {admin_data.email}")

        result = await admin_service.create_admin(
            db, admin_data, current_admin.get('user_id')
        )

        logger.info(f"Administrador creado: {result.id}")
        return result

    except Exception as e:
        logger.error(f"Error creando administrador: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )

@router.get("/", response_model=AdminListResponse)
def list_admins(
    page: int = Query(1, ge=1, description="Número de página"),
    limit: int = Query(10, ge=1, le=100, description="Elementos por página"),
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Listar administradores con paginación"""
    try:
        skip = (page - 1) * limit
        admins, total = admin_service.get_admins(db, skip, limit)

        return AdminListResponse(
            admins=admins,
            total=total,
            page=page,
            limit=limit
        )

    except DataError as e:
        logger.error(f"Error de datos en paginación de administradores: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Parámetros de paginación inválidos"
        )
    except SQLAlchemyError as e:
        logger.exception(f"Error de base de datos listando administradores: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error de base de datos al obtener administradores"
        )
    except Exception as e:
        logger.exception(f"Error inesperado listando administradores: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )

@router.get("/{admin_id}", response_model=AdminResponse)
def get_admin(
    admin_id: str,
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Obtener un administrador específico"""
    try:
        return admin_service.get_admin(db, admin_id)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error obteniendo administrador {admin_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )

@router.put("/{admin_id}", response_model=AdminResponse)
async def update_admin(
    admin_id: str,
    update_data: AdminUpdateRequest,
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Actualizar un administrador"""
    try:
        result = await admin_service.update_admin(
            db, admin_id, update_data, current_admin.get('user_id')
        )
        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error actualizando administrador {admin_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )

@router.delete("/{admin_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_admin(
    admin_id: str,
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Eliminar un administrador"""
    try:
        await admin_service.delete_admin(db, admin_id, current_admin.get('user_id'))
        return {"message": "Admin deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error eliminando administrador {admin_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )

# ============================================================================
# ENDPOINTS DE INSTITUCIONES (CREADAS POR ADMINS)
# ============================================================================

@router.post("/institutions", response_model=InstitutionResponse, status_code=status.HTTP_201_CREATED)
async def create_institution(
    institution_data: InstitutionCreateRequest,
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Crear una nueva institución médica (solo administradores)"""
    try:
        logger.info(f"Creando institución: {institution_data.name}")

        result = await admin_service.create_institution(
            db, institution_data, current_admin.get('user_id')
        )

        logger.info(f"Institución creada: {result.id}")
        return result

    except Exception as e:
        logger.error(f"Error creando institución: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )

# ============================================================================
# ENDPOINTS DE AUDITORÍA
# ============================================================================

@router.get("/audit/logs", response_model=AdminAuditLogsResponse)
def get_audit_logs(
    admin_id: Optional[str] = Query(None, description="Filtrar por admin ID"),
    page: int = Query(1, ge=1, description="Número de página"),
    limit: int = Query(50, ge=1, le=200, description="Elementos por página"),
    db: Session = Depends(get_db),
    current_admin: dict = Depends(get_current_admin)
):
    """Obtener logs de auditoría"""
    try:
        skip = (page - 1) * limit
        logs, total = admin_service.get_audit_logs(db, admin_id, skip, limit)

        return AdminAuditLogsResponse(
            logs=[AdminAuditLogResponse.model_validate(log) for log in logs],
            total=total,
            page=page,
            limit=limit
        )

    except Exception as e:
        logger.error(f"Error obteniendo logs de auditoría: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )