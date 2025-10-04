# /microservices\service-doctors\app\api\v1\endpoints\doctors.py
# /microservicios/servicio-doctores/app/api/v1/endpoints/doctors.py
# Endpoints para el servicio de doctores

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import logging

from app.core.database import get_db
from app.services.doctor_service import doctor_service
from app.schemas.doctor import (
    DoctorCreateRequest,
    DoctorUpdateRequest,
    DoctorResponse,
    DoctorSearchRequest,
    DoctorListResponse,
    DoctorStatisticsResponse
)

# Configurar logging
logger = logging.getLogger(__name__)

# Router for doctors endpoints (English)
router = APIRouter(prefix="/doctors", tags=["doctors"])

@router.post("/", response_model=DoctorResponse, status_code=status.HTTP_201_CREATED)
async def create_doctor(
    doctor_data: DoctorCreateRequest,
    db: Session = Depends(get_db)
):
    """Create a new doctor"""
    try:
        logger.info(f"🔄 Creating doctor: {doctor_data.first_name}")
        
        doctor = doctor_service.create_doctor(
            db=db,
            doctor_data=doctor_data.model_dump()
        )
        
        logger.info(f"✅ Doctor created: {doctor.first_name}")
        
        return DoctorResponse(
            id=str(doctor.id),
            institution_id=str(doctor.institution_id) if doctor.institution_id else None,
            first_name=doctor.first_name,
            last_name=doctor.last_name,
            email=doctor.email,
            medical_license=doctor.medical_license,
            specialty_id=str(doctor.specialty_id) if doctor.specialty_id else None,
            created_at=doctor.created_at,
            updated_at=doctor.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error creando doctor: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno creando doctor"
        )

@router.get("/statistics", response_model=DoctorStatisticsResponse)
async def get_doctor_statistics(
    db: Session = Depends(get_db)
):
    """Get doctors statistics"""
    try:
        logger.info("🔄 Getting doctors statistics")

        stats = doctor_service.get_doctor_statistics(db)

        logger.info("✅ Statistics retrieved successfully")

        return DoctorStatisticsResponse(
            total_doctors=stats.get("total_doctors", 0),
            by_specialty=stats.get("by_specialty", {}),
            by_institution=stats.get("by_institution", {}),
            new_doctors_this_month=stats.get("new_doctors_this_month", 0)
        )

    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas de doctores: {str(e)}")
        # Return 500 instead of 200 to provide accurate feedback
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno obteniendo estadísticas de doctores"
        )

@router.get("/{doctor_id}", response_model=DoctorResponse)
async def get_doctor(
    doctor_id: str,
    db: Session = Depends(get_db)
):
    """Get a doctor by ID"""
    try:
        logger.info(f"🔄 Getting doctor: {doctor_id}")
        
        doctor = doctor_service.get_doctor_by_id(db, doctor_id)
        
        if not doctor:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor not found")
        
        logger.info(f"✅ Doctor retrieved: {doctor.first_name}")
        
        return DoctorResponse(
            id=str(doctor.id),
            institution_id=str(doctor.institution_id) if doctor.institution_id else None,
            first_name=doctor.first_name,
            last_name=doctor.last_name,
            email=doctor.email,
            medical_license=doctor.medical_license,
            specialty_id=str(doctor.specialty_id) if doctor.specialty_id else None,
            created_at=doctor.created_at,
            updated_at=doctor.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error obteniendo doctor: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno obteniendo doctor"
        )

@router.get("/", response_model=DoctorListResponse)
async def get_doctors(
    skip: int = Query(0, ge=0, description="Número de registros a saltar"),
    limit: int = Query(100, ge=1, le=1000, description="Límite de registros"),
    specialty: Optional[str] = Query(None, description="Filtrar por especialidad", alias="especialidad"),
    institution_id: Optional[str] = Query(None, description="Filtrar por institución", alias="id_institucion"),
    db: Session = Depends(get_db)
):
    """Get doctors list with optional filters"""
    try:
        logger.info(f"🔄 Getting doctors (skip={skip}, limit={limit})")
        
        if specialty:
            doctors = doctor_service.get_doctors_by_specialty(db, specialty)
        elif institution_id:
            doctors = doctor_service.get_doctors_by_institution(db, institution_id)
        else:
            doctors = doctor_service.get_all_doctors(db, skip, limit)
        
        # Convertir a response
        doctor_responses = [
            DoctorResponse(
                id=str(doc.id),
                institution_id=str(doc.institution_id) if doc.institution_id else None,
                first_name=doc.first_name,
                last_name=doc.last_name,
                email=doc.email,
                medical_license=doc.medical_license,
                specialty_id=doc.specialty_id,
                created_at=doc.created_at,
                updated_at=doc.updated_at
            ) for doc in doctors
        ]
        
        logger.info(f"✅ {len(doctor_responses)} doctors fetched")
        
        return DoctorListResponse(
            doctors=doctor_responses,
            total=len(doctor_responses),
            page=skip // limit + 1,
            limit=limit
        )
        
    except Exception as e:
        logger.error(f"❌ Error obteniendo doctores: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno obteniendo doctores"
        )

@router.delete("/{doctor_id}", status_code=status.HTTP_200_OK)
async def delete_doctor(
    doctor_id: str,
    db: Session = Depends(get_db)
):
    """Delete a doctor"""
    try:
        logger.info(f"🔄 Deleting doctor: {doctor_id}")
        
        success = doctor_service.delete_doctor(db, doctor_id)
        
        if success:
            logger.info(f"✅ Doctor eliminado exitosamente: {doctor_id}")
            return {"message": "Doctor deleted successfully"}
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor not found")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error eliminando doctor: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error deleting doctor"
        )