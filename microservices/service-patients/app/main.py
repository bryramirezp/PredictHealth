# /microservices/service-patients/app/main.py
# Microservicio de Pacientes - Refactorizado con Lógica Transaccional (3NF) y CRUD completo

from fastapi import FastAPI, Depends, HTTPException, status, Header, Query
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional

from shared.database import get_db, Base, engine
from shared.auth_client import create_user as create_auth_user
from .domain import (
    Patient,
    Email,
    HealthProfile,
    PatientCreateRequest,
    PatientResponse,
    PatientUpdateRequest
)

# --- Configuración de la Aplicación ---
Base.metadata.create_all(bind=engine)
app = FastAPI(title="Servicio de Pacientes", version="3.0.0")

# --- Lógica de Negocio ---

def create_patient_logic(db: Session, patient_data: PatientCreateRequest) -> Patient:
    if db.query(Email).filter(Email.email_address == patient_data.contact_email.email_address).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")

    db_patient = Patient(**patient_data.dict(exclude={'contact_email', 'health_profile', 'password'}))
    db_email = Email(entity_type='patient', entity_id=db_patient.id, **patient_data.contact_email.dict())
    db_health_profile = HealthProfile(patient_id=db_patient.id, **patient_data.health_profile.dict())

    db.add(db_patient)
    db.add(db_email)
    db.add(db_health_profile)

    try:
        db.commit()
        db.refresh(db_patient)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error al guardar el paciente: {e}")

    auth_user = create_auth_user(
        email=patient_data.contact_email.email_address,
        password=patient_data.password,
        user_type='patient',
        reference_id=db_patient.id
    )

    if not auth_user:
        db.delete(db_patient) # Esto eliminará en cascada el email y el perfil de salud
        db.commit()
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada.")

    return db_patient

# --- Endpoints de la API ---

@app.post("/api/v1/patients", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
def create_patient(
    patient_data: PatientCreateRequest,
    db: Session = Depends(get_db)
):
    """Crea un paciente, su email, perfil de salud, y cuenta de usuario."""
    patient = create_patient_logic(db, patient_data)

    response = PatientResponse.from_orm(patient)
    response.contact_email = patient_data.contact_email.email_address
    response.health_profile = patient_data.health_profile
    return response

# ... (El resto de los endpoints CRUD permanecen igual)
@app.get("/api/v1/patients/{patient_id}", response_model=PatientResponse)
def get_patient(
    patient_id: str,
    db: Session = Depends(get_db),
    x_user_id: str = Header(None),
    x_user_type: str = Header(None)
):
    patient = db.query(Patient).options(joinedload(Patient.health_profile), joinedload(Patient.emails)).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")

    if x_user_type == 'patient' and x_user_id != str(patient.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tienes permiso para ver este paciente.")

    response = PatientResponse.from_orm(patient)
    if patient.emails:
        response.contact_email = next((e.email_address for e in patient.emails if e.is_primary), None)
    response.health_profile = patient.health_profile
    return response

@app.get("/api/v1/patients", response_model=List[PatientResponse])
def list_patients(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100
):
    patients = db.query(Patient).offset(skip).limit(limit).all()
    return patients

@app.put("/api/v1/patients/{patient_id}", response_model=PatientResponse)
def update_patient(
    patient_id: str,
    patient_update: PatientUpdateRequest,
    db: Session = Depends(get_db)
):
    db_patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not db_patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")

    update_data = patient_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_patient, key, value)

    db.commit()
    db.refresh(db_patient)
    return db_patient

@app.delete("/api/v1/patients/{patient_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_patient(
    patient_id: str,
    db: Session = Depends(get_db)
):
    db_patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not db_patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")

    db_patient.is_active = False
    db.commit()
    return

@app.get("/health")
def health_check():
    return {"status": "healthy"}
