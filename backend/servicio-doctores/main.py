# /backend/servicio-doctores/main.py

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
from datetime import timedelta
import uuid

import models, schemas, database, auth
from database import engine

# Crear las tablas en la base de datos
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Servicio de Gestión de Doctores",
    description="API para la gestión de doctores en PredictHealth",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios exactos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- ENDPOINTS ---

@app.post("/doctores/", response_model=schemas.Doctor, status_code=status.HTTP_201_CREATED)
def crear_doctor(doctor: schemas.DoctorCreate, db: Session = Depends(database.get_db)):
    """Crear un nuevo doctor"""
    
    # Verificar si el email ya existe
    existing_doctor = db.query(models.Doctor).filter(models.Doctor.email == doctor.email).first()
    if existing_doctor:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un doctor con este email"
        )
    
    # Verificar si la licencia médica ya existe
    existing_license = db.query(models.Doctor).filter(
        models.Doctor.licencia_medica == doctor.licencia_medica
    ).first()
    if existing_license:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un doctor con esta licencia médica"
        )
    
    # Crear el nuevo doctor
    hashed_password = auth.get_password_hash(doctor.password)
    db_doctor = models.Doctor(
        nombre=doctor.nombre,
        apellido=doctor.apellido,
        email=doctor.email,
        licencia_medica=doctor.licencia_medica,
        contrasena_hash=hashed_password
    )
    
    db.add(db_doctor)
    db.commit()
    db.refresh(db_doctor)
    
    return db_doctor

@app.post("/doctores/login", response_model=schemas.Token)
def login_doctor(doctor_login: schemas.DoctorLogin, db: Session = Depends(database.get_db)):
    """Autenticar un doctor"""
    
    doctor = auth.authenticate_doctor(db, doctor_login.email, doctor_login.password)
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": str(doctor.id_doctor)}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "doctor": schemas.DoctorResponse.from_orm(doctor)
    }

@app.get("/doctores/me", response_model=schemas.DoctorResponse)
def get_current_doctor_info(current_doctor: models.Doctor = Depends(auth.get_current_doctor)):
    """Obtener información del doctor actual"""
    return current_doctor

@app.get("/doctores/{doctor_id}", response_model=schemas.DoctorResponse)
def leer_doctor(doctor_id: str, db: Session = Depends(database.get_db)):
    """Obtener un doctor por su ID (para validación desde otros servicios)"""
    
    try:
        doctor_uuid = uuid.UUID(doctor_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ID de doctor inválido"
        )
    
    doctor = db.query(models.Doctor).filter(
        models.Doctor.id_doctor == doctor_uuid,
        models.Doctor.activo == True
    ).first()
    
    if not doctor:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Doctor no encontrado"
        )
    
    return doctor

@app.put("/doctores/me", response_model=schemas.DoctorResponse)
def actualizar_doctor(
    doctor_update: schemas.DoctorUpdate,
    current_doctor: models.Doctor = Depends(auth.get_current_doctor),
    db: Session = Depends(database.get_db)
):
    """Actualizar información del doctor actual"""
    
    # Verificar si el nuevo email ya existe (si se está actualizando)
    if doctor_update.email and doctor_update.email != current_doctor.email:
        existing_doctor = db.query(models.Doctor).filter(
            models.Doctor.email == doctor_update.email
        ).first()
        if existing_doctor:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ya existe un doctor con este email"
            )
    
    # Actualizar campos
    update_data = doctor_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_doctor, field, value)
    
    db.commit()
    db.refresh(current_doctor)
    
    return current_doctor

@app.get("/doctores/", response_model=schemas.DoctorList)
def listar_doctores(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    """Listar todos los doctores (para administración)"""
    
    doctores = db.query(models.Doctor).filter(models.Doctor.activo == True).offset(skip).limit(limit).all()
    total = db.query(models.Doctor).filter(models.Doctor.activo == True).count()
    
    return {
        "doctores": doctores,
        "total": total,
        "pagina": skip // limit + 1,
        "por_pagina": limit
    }

@app.delete("/doctores/me")
def desactivar_doctor(
    current_doctor: models.Doctor = Depends(auth.get_current_doctor),
    db: Session = Depends(database.get_db)
):
    """Desactivar la cuenta del doctor actual"""
    
    current_doctor.activo = False
    db.commit()
    
    return {"mensaje": "Cuenta desactivada exitosamente"}

@app.get("/")
def root():
    """Endpoint raíz del servicio"""
    return {"message": "Servicio de Gestión de Doctores", "version": "1.0.0", "docs": "/docs"}

@app.get("/health")
def health_check():
    """Endpoint de salud del servicio"""
    return {"status": "healthy", "service": "servicio-doctores"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
