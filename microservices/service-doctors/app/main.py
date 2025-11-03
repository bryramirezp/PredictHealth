# /microservices/service-doctors/app/main.py
# Microservicio de Doctores - Refactorizado con Lógica Transaccional (3NF) y CRUD completo

from fastapi import FastAPI, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from typing import List, Optional

from shared.database import get_db, Base, engine
from shared.auth_client import create_user as create_auth_user
from .domain import (
    Doctor,
    Email,
    DoctorCreateRequest,
    DoctorResponse,
    DoctorUpdateRequest
)

# --- Configuración de la Aplicación ---
Base.metadata.create_all(bind=engine)
app = FastAPI(title="Servicio de Doctores", version="3.0.0")

# --- Lógica de Negocio ---

def create_doctor_logic(db: Session, doctor_data: DoctorCreateRequest) -> Doctor:
    if db.query(Email).filter(Email.email_address == doctor_data.contact_email.email_address).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")
    if db.query(Doctor).filter(Doctor.medical_license == doctor_data.medical_license).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La licencia médica ya está registrada.")

    db_doctor = Doctor(**doctor_data.dict(exclude={'contact_email', 'password'}))
    db_email = Email(entity_type='doctor', entity_id=db_doctor.id, **doctor_data.contact_email.dict())

    db.add(db_doctor)
    db.add(db_email)

    try:
        # Hacemos commit inicial para asegurar que el doctor y email se guardan y el ID está disponible
        db.commit()
        db.refresh(db_doctor)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error al guardar el doctor: {e}")

    # Después de crear el doctor, crear el usuario en el servicio de autenticación
    auth_user = create_auth_user(
        email=doctor_data.contact_email.email_address,
        password=doctor_data.password,
        user_type='doctor',
        reference_id=db_doctor.id
    )

    if not auth_user:
        # Si la creación del usuario falla, revertimos la creación del doctor (compensación)
        db.delete(db_doctor)
        db.delete(db_email)
        db.commit()
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada.")

    return db_doctor


# --- Endpoints de la API ---

@app.post("/api/v1/doctors", response_model=DoctorResponse, status_code=status.HTTP_201_CREATED)
def create_doctor(
    doctor_data: DoctorCreateRequest,
    db: Session = Depends(get_db)
):
    """Crea un doctor, su email, y su cuenta de usuario en una transacción compensada."""
    doctor = create_doctor_logic(db, doctor_data)
    response = DoctorResponse.from_orm(doctor)
    response.contact_email = doctor_data.contact_email.email_address
    return response

# ... (El resto de los endpoints CRUD permanecen igual)

@app.get("/api/v1/doctors/{doctor_id}", response_model=DoctorResponse)
def get_doctor(
    doctor_id: str,
    db: Session = Depends(get_db)
):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    primary_email = db.query(Email).filter(Email.entity_id == doctor.id, Email.is_primary == True).first()

    response = DoctorResponse.from_orm(doctor)
    if primary_email:
        response.contact_email = primary_email.email_address
    return response

@app.get("/api/v1/doctors", response_model=List[DoctorResponse])
def list_doctors(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100
):
    doctors = db.query(Doctor).offset(skip).limit(limit).all()
    return doctors

@app.put("/api/v1/doctors/{doctor_id}", response_model=DoctorResponse)
def update_doctor(
    doctor_id: str,
    doctor_update: DoctorUpdateRequest,
    db: Session = Depends(get_db)
):
    db_doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not db_doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    update_data = doctor_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_doctor, key, value)

    db.commit()
    db.refresh(db_doctor)
    return db_doctor

@app.delete("/api/v1/doctors/{doctor_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_doctor(
    doctor_id: str,
    db: Session = Depends(get_db)
):
    db_doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not db_doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    db_doctor.is_active = False
    db.commit()
    return

@app.get("/health")
def health_check():
    return {"status": "healthy"}
