# /microservices\service-institutions\app\api\v1\endpoints\institutions.py
# /microservicios/servicio-instituciones/api/v1/endpoints/institutions.py
# Endpoints para el servicio de instituciones

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import logging

from app.core.database import get_db
from app.services.institution_service import institution_service
from app.schemas.institution import (
    InstitutionCreateRequest,
    InstitutionUpdateRequest,
    InstitutionResponse,
    InstitutionSearchRequest,
    InstitutionListResponse,
    InstitutionStatisticsResponse
)
from typing import Dict, Any

# Configurar logging
logger = logging.getLogger(__name__)

# Router for institutions endpoints (English)
router = APIRouter(prefix="/institutions", tags=["institutions"])

@router.post("/", response_model=InstitutionResponse, status_code=status.HTTP_201_CREATED)
async def create_institution(
    institution_data: InstitutionCreateRequest,
    db: Session = Depends(get_db)
):
    """Create a new medical institution"""
    try:
        logger.info(f"🔄 Creating institution: {institution_data.name}")
        
        institution = institution_service.create_institution(
            db=db,
            institution_data=institution_data.model_dump()
        )
        
        logger.info(f"✅ Institution created: {institution.name}")
        
        return InstitutionResponse(
            id=str(institution.id),
            name=institution.name,
            institution_type=institution.institution_type,
            contact_email=institution.contact_email,
            address=institution.address,
            region_state=institution.region_state,
            created_at=institution.created_at,
            updated_at=institution.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error creando institución: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error creating institution"
        )

@router.get("/statistics", response_model=Dict[str, Any])
async def get_statistics(db: Session = Depends(get_db)):
    """Get institution statistics"""
    logger.info("📊 Getting institution statistics")
    try:
        statistics = institution_service.get_statistics(db)
        return statistics
    except Exception as e:
        logger.error(f"❌ Error getting statistics: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# IMPORTANT: This route must come AFTER /statistics
@router.get("/{institution_id}", response_model=InstitutionResponse)
async def get_institution(
    institution_id: str,
    db: Session = Depends(get_db)
):
    """Get institution by ID"""
    try:
        logger.info(f"🔄 Getting institution: {institution_id}")
        
        institution = institution_service.get_institution_by_id(db, institution_id)
        
        if not institution:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Institution not found"
            )
        
        logger.info(f"✅ Institution retrieved: {institution.name}")
        
        return InstitutionResponse(
            id=str(institution.id),
            name=institution.name,
            institution_type=institution.institution_type,
            contact_email=institution.contact_email,
            address=institution.address,
            region_state=institution.region_state,
            created_at=institution.created_at,
            updated_at=institution.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error obteniendo institución: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error getting institution"
        )

@router.get("/", response_model=InstitutionListResponse)
async def get_institutions(
    skip: int = Query(0, ge=0, description="Número de registros a saltar"),
    limit: int = Query(100, ge=1, le=1000, description="Límite de registros"),
    tipo_institucion: Optional[str] = Query(None, description="Filtrar por tipo"),
    region: Optional[str] = Query(None, description="Filtrar por región"),
    db: Session = Depends(get_db)
):
    """Get institutions list with optional filters"""
    try:
        logger.info(f"🔄 Getting institutions (skip={skip}, limit={limit})")
        
        if tipo_institucion:
            institutions = institution_service.get_institutions_by_type(db, tipo_institucion)
        elif region:
            institutions = institution_service.get_institutions_by_region(db, region)
        else:
            institutions = institution_service.get_all_institutions(db, skip, limit)
        
        # Build response
        institution_responses = [
            InstitutionResponse(
                id=str(inst.id),
                name=inst.name,
                institution_type=inst.institution_type,
                contact_email=inst.contact_email,
                address=inst.address,
                region_state=inst.region_state,
                created_at=inst.created_at,
                updated_at=inst.updated_at
            ) for inst in institutions
        ]
        
        logger.info(f"✅ {len(institution_responses)} institutions fetched")
        
        return InstitutionListResponse(
            institutions=institution_responses,
            total=len(institution_responses),
            page=skip // limit + 1,
            limit=limit
        )
        
    except Exception as e:
        logger.error(f"❌ Error obteniendo instituciones: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error getting institutions"
        )

@router.put("/{institution_id}", response_model=InstitutionResponse)
async def update_institution(
    institution_id: str,
    update_data: InstitutionUpdateRequest,
    db: Session = Depends(get_db)
):
    """Update an institution"""
    try:
        logger.info(f"🔄 Updating institution: {institution_id}")
        
        # Filtrar campos None
        update_dict = {k: v for k, v in update_data.dict().items() if v is not None}
        
        institution = institution_service.update_institution(
            db=db,
            institution_id=institution_id,
            update_data=update_dict
        )
        
        logger.info(f"✅ Institution updated: {institution.name}")
        
        return InstitutionResponse(
            id=str(institution.id),
            name=institution.name,
            institution_type=institution.institution_type,
            contact_email=institution.contact_email,
            address=institution.address,
            region_state=institution.region_state,
            created_at=institution.created_at,
            updated_at=institution.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error actualizando institución: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error updating institution"
        )

@router.delete("/{institution_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_institution(
    institution_id: str,
    db: Session = Depends(get_db)
):
    """Delete an institution"""
    try:
        logger.info(f"🔄 Deleting institution: {institution_id}")
        
        institution_service.delete_institution(db, institution_id)
        
        logger.info(f"✅ Institution deleted: {institution_id}")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error eliminando institución: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error deleting institution"
        )

@router.post("/search", response_model=InstitutionListResponse)
async def search_institutions(
    search_request: InstitutionSearchRequest,
    db: Session = Depends(get_db)
):
    """Search institutions"""
    try:
        logger.info(f"🔄 Searching institutions: {search_request.query}")
        
        institutions = institution_service.search_institutions(
            db=db,
            query=search_request.query,
            institution_type=search_request.institution_type,
            region=search_request.region
        )
        
        # Convertir a response
        institution_responses = [
            InstitutionResponse(
                id=str(inst.id),
                name=inst.name,
                institution_type=inst.institution_type,
                contact_email=inst.contact_email,
                address=inst.address,
                region_state=inst.region_state,
                created_at=inst.created_at,
                updated_at=inst.updated_at
            ) for inst in institutions
        ]
        
        logger.info(f"✅ {len(institution_responses)} institutions found")
        
        return InstitutionListResponse(
            institutions=institution_responses,
            total=len(institution_responses),
            page=1,
            limit=len(institution_responses)
        )
        
    except Exception as e:
        logger.error(f"❌ Error buscando instituciones: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error searching institutions"
        )

@router.get("/statistics/overview", response_model=InstitutionStatisticsResponse)
async def get_institution_statistics(
    db: Session = Depends(get_db)
):
    """Get institutions statistics"""
    try:
        logger.info("🔄 Getting institutions statistics")
        
        stats = institution_service.get_institution_statistics(db)
        
        logger.info("✅ Statistics retrieved successfully")
        
        return InstitutionStatisticsResponse(
            total_institutions=stats.get("total_institutions", 0),
            by_type=stats.get("by_type", {}),
            by_region=stats.get("by_region", {})
        )
        
    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno obteniendo estadísticas"
        )
