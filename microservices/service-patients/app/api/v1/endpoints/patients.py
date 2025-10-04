# /microservices\service-patients\app\api\v1\endpoints\patients.py
# /microservicios/servicio-pacientes/app/api/v1/endpoints/patients.py
# Endpoints para el servicio de pacientes

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import logging

from app.core.database import get_db
from app.services.patient_service import patient_service
from app.schemas.patient import (
    PatientCreateRequest,
    PatientUpdateRequest,
    PatientResponse,
    PatientSearchRequest,
    PatientListResponse,
    PatientStatisticsResponse
)

# Configurar logging
logger = logging.getLogger(__name__)

# Router for patients endpoints (English)
router = APIRouter(prefix="/patients", tags=["patients"])

@router.post("/", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
async def create_patient(
    patient_data: PatientCreateRequest,
    db: Session = Depends(get_db)
):
    """Create a new patient"""
    try:
        logger.info(f"🔄 Creating patient: {patient_data.first_name}")
        
        patient = patient_service.create_patient(
            db=db,
            patient_data=patient_data.model_dump()
        )
        
        logger.info(f"✅ Patient created: {patient.nombre}")
        
        return PatientResponse(
            id=str(patient.id),
            doctor_id=str(patient.doctor_id) if patient.doctor_id else None,
            institution_id=str(patient.institution_id) if patient.institution_id else None,
            first_name=patient.first_name,
            last_name=patient.last_name,
            email=patient.email,
            date_of_birth=patient.date_of_birth,
            gender=patient.gender,
            validation_status=patient.validation_status,
            created_at=patient.created_at,
            updated_at=patient.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error creando paciente: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno creando paciente"
        )

@router.get("/statistics", response_model=PatientStatisticsResponse)
async def get_patient_statistics(
    db: Session = Depends(get_db)
):
    """Get patients statistics"""
    try:
        logger.info("🔄 Getting patients statistics")

        stats = patient_service.get_patient_statistics(db)

        logger.info("✅ Statistics retrieved successfully")

        return PatientStatisticsResponse(
            total_patients=stats.get("total_patients", 0),
            by_gender=stats.get("by_gender", {}),
            by_validation_state=stats.get("by_validation_state", {}),
            by_doctor=stats.get("by_doctor", {}),
            new_patients_this_month=stats.get("new_patients_this_month", 0)
        )

    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas de pacientes: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno obteniendo estadísticas de pacientes"
        )

@router.get("/{patient_id}", response_model=PatientResponse)
async def get_patient(
    patient_id: str,
    db: Session = Depends(get_db)
):
    """Get a patient by ID"""
    try:
        logger.info(f"🔄 Getting patient: {patient_id}")
        
        patient = patient_service.get_patient_by_id(db, patient_id)
        
        if not patient:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")
        
        logger.info(f"✅ Patient retrieved: {patient.nombre}")
        
        return PatientResponse(
            id=str(patient.id),
            doctor_id=str(patient.doctor_id) if patient.doctor_id else None,
            institution_id=str(patient.institution_id) if patient.institution_id else None,
            first_name=patient.first_name,
            last_name=patient.last_name,
            email=patient.email,
            date_of_birth=patient.date_of_birth,
            gender=patient.gender,
            validation_status=patient.validation_status,
            created_at=patient.created_at,
            updated_at=patient.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error obteniendo paciente: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno obteniendo paciente"
        )

@router.get("/", response_model=PatientListResponse)
async def get_patients(
    skip: int = Query(0, ge=0, description="Número de registros a saltar"),
    limit: int = Query(100, ge=1, le=1000, description="Límite de registros"),
    gender: Optional[str] = Query(None, description="Filter by gender"),
    validation_status: Optional[str] = Query(None, description="Filter by validation status"),
    doctor_id: Optional[str] = Query(None, description="Filter by doctor"),
    institution_id: Optional[str] = Query(None, description="Filter by institution"),
    db: Session = Depends(get_db)
):
    """Get patients list with optional filters"""
    try:
        logger.info(f"🔄 Getting patients (skip={skip}, limit={limit})")
        
        if doctor_id:
            patients = patient_service.get_patients_by_doctor(db, doctor_id)
        elif institution_id:
            patients = patient_service.get_patients_by_institution(db, institution_id)
        elif validation_status:
            patients = patient_service.get_patients_by_validation_state(db, validation_status)
        else:
            patients = patient_service.get_all_patients(db, skip, limit)
        
        # Build response
        patient_responses = [
            PatientResponse(
                id=str(pat.id),
                doctor_id=str(pat.doctor_id) if pat.doctor_id else None,
                institution_id=str(pat.institution_id) if pat.institution_id else None,
                first_name=pat.first_name,
                last_name=pat.last_name,
                email=pat.email,
                date_of_birth=pat.date_of_birth,
                gender=pat.gender,
                validation_status=pat.validation_status,
                created_at=pat.created_at,
                updated_at=pat.updated_at
            ) for pat in patients
        ]
        
        logger.info(f"✅ {len(patient_responses)} patients fetched")
        
        return PatientListResponse(
            patients=patient_responses,
            total=len(patient_responses),
            page=skip // limit + 1,
            limit=limit
        )
        
    except Exception as e:
        logger.error(f"❌ Error obteniendo pacientes: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error getting patients"
        )
