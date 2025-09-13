# /backend/servicio-pacientes/main.py

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
from datetime import timedelta
import uuid

import models, schemas, database, auth, doctor_service
from database import engine

# Crear las tablas en la base de datos
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Servicio de Gestión de Pacientes",
    description="API para la gestión de pacientes en PredictHealth",
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

# --- ENDPOINTS DE PACIENTES ---

@app.post("/pacientes/", response_model=schemas.Paciente, status_code=status.HTTP_201_CREATED)
def crear_paciente(paciente: schemas.PacienteCreate, db: Session = Depends(database.get_db)):
    """Crear un nuevo paciente con perfil de salud"""
    
    # Validar que el doctor existe
    doctor_service.validar_doctor_existe(str(paciente.id_doctor))
    
    # Verificar si el email ya existe
    existing_paciente = db.query(models.Usuario).filter(models.Usuario.email == paciente.email).first()
    if existing_paciente:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un paciente con este email"
        )
    
    # Crear el nuevo paciente
    hashed_password = auth.get_password_hash(paciente.password)
    db_paciente = models.Usuario(
        id_doctor=paciente.id_doctor,
        nombre=paciente.nombre,
        apellido=paciente.apellido,
        email=paciente.email,
        fecha_nacimiento=paciente.fecha_nacimiento,
        genero=paciente.genero,
        zona_horaria=paciente.zona_horaria,
        contrasena_hash=hashed_password
    )
    
    db.add(db_paciente)
    db.commit()
    db.refresh(db_paciente)
    
    # Crear el perfil de salud general
    db_perfil = models.PerfilSaludGeneral(
        id_usuario=db_paciente.id_usuario,
        altura_cm=paciente.altura_cm,
        peso_kg=paciente.peso_kg,
        fumador=paciente.fumador,
        consumo_alcohol=paciente.consumo_alcohol,
        diagnostico_hipertension=paciente.diagnostico_hipertension,
        diagnostico_colesterol_alto=paciente.diagnostico_colesterol_alto,
        antecedente_acv=paciente.antecedente_acv,
        antecedente_enf_cardiaca=paciente.antecedente_enf_cardiaca,
        condiciones_preexistentes_notas=paciente.condiciones_preexistentes_notas,
        minutos_actividad_fisica_semanal=paciente.minutos_actividad_fisica_semanal
    )
    
    db.add(db_perfil)
    db.commit()
    db.refresh(db_perfil)
    
    return db_paciente

@app.post("/pacientes/login", response_model=schemas.PacienteToken)
def login_paciente(paciente_login: schemas.PacienteLogin, db: Session = Depends(database.get_db)):
    """Autenticar un paciente"""
    
    paciente = auth.authenticate_paciente(db, paciente_login.email, paciente_login.password)
    if not paciente:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": str(paciente.id_usuario)}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "paciente": schemas.PacienteResponse.from_orm(paciente)
    }

@app.get("/pacientes/me", response_model=schemas.PacienteResponse)
def get_current_paciente_info(current_paciente: models.Usuario = Depends(auth.get_current_paciente)):
    """Obtener información del paciente actual"""
    return schemas.PacienteResponse.from_orm(current_paciente)

@app.get("/pacientes/{patient_id}", response_model=schemas.PacienteResponse)
def get_patient_by_id(patient_id: str, db: Session = Depends(database.get_db)):
    """Obtener información de un paciente específico por ID"""
    try:
        patient_uuid = uuid.UUID(patient_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ID de paciente inválido"
        )
    
    paciente = db.query(models.Usuario).filter(
        models.Usuario.id_usuario == patient_uuid,
        models.Usuario.activo == True
    ).first()
    
    if not paciente:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado"
        )
    
    return schemas.PacienteResponse.from_orm(paciente)

@app.get("/pacientes/{patient_id}/perfil-salud", response_model=schemas.PerfilSaludGeneral)
def get_patient_health_profile(patient_id: str, db: Session = Depends(database.get_db)):
    """Obtener perfil de salud de un paciente específico"""
    try:
        patient_uuid = uuid.UUID(patient_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ID de paciente inválido"
        )
    
    # Verificar que el paciente existe
    paciente = db.query(models.Usuario).filter(
        models.Usuario.id_usuario == patient_uuid,
        models.Usuario.activo == True
    ).first()
    
    if not paciente:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado"
        )
    
    # Obtener perfil de salud
    perfil = db.query(models.PerfilSaludGeneral).filter(
        models.PerfilSaludGeneral.id_usuario == patient_uuid
    ).first()
    
    if not perfil:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de salud no encontrado"
        )
    
    return perfil

@app.get("/pacientes/{patient_id}/medidas", response_model=List[schemas.DatoBiometrico])
def get_patient_measurements(patient_id: str, db: Session = Depends(database.get_db)):
    """Obtener mediciones de un paciente específico"""
    try:
        patient_uuid = uuid.UUID(patient_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ID de paciente inválido"
        )
    
    # Verificar que el paciente existe
    paciente = db.query(models.Usuario).filter(
        models.Usuario.id_usuario == patient_uuid,
        models.Usuario.activo == True
    ).first()
    
    if not paciente:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado"
        )
    
    # Obtener mediciones
    mediciones = db.query(models.DatoBiometrico).filter(
        models.DatoBiometrico.id_usuario == patient_uuid
    ).order_by(models.DatoBiometrico.fecha_hora_medida.desc()).all()
    
    return mediciones

@app.get("/pacientes/me/perfil-salud", response_model=schemas.PerfilSaludGeneral)
def get_current_patient_health_profile(current_paciente: models.Usuario = Depends(auth.get_current_paciente), db: Session = Depends(database.get_db)):
    """Obtener perfil de salud del paciente actual"""
    try:
        print(f"Getting health profile for patient: {current_paciente.id_usuario}")
        
        perfil = db.query(models.PerfilSaludGeneral).filter(
            models.PerfilSaludGeneral.id_usuario == current_paciente.id_usuario
        ).first()
        
        print(f"Found existing profile: {perfil is not None}")
        
        if not perfil:
            print("Creating new health profile...")
            # Crear un perfil de salud vacío si no existe
            perfil = models.PerfilSaludGeneral(
                id_usuario=current_paciente.id_usuario,
                altura_cm=None,
                peso_kg=None,
                fumador=False,
                consumo_alcohol=False,
                diagnostico_hipertension=False,
                diagnostico_colesterol_alto=False,
                antecedente_acv=False,
                antecedente_enf_cardiaca=False,
                condiciones_preexistentes_notas=None,
                minutos_actividad_fisica_semanal=0
            )
            db.add(perfil)
            db.commit()
            db.refresh(perfil)
            print(f"Created new profile: {perfil.id_perfil}")
        
        print(f"Returning profile: {perfil}")
        return perfil
        
    except Exception as e:
        print(f"Error in get_current_patient_health_profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error interno: {str(e)}"
        )

@app.put("/pacientes/me", response_model=schemas.PacienteResponse)
def actualizar_paciente(
    paciente_update: schemas.PacienteUpdate,
    current_paciente: models.Usuario = Depends(auth.get_current_paciente),
    db: Session = Depends(database.get_db)
):
    """Actualizar información del paciente actual"""
    
    # Verificar si el nuevo email ya existe (si se está actualizando)
    if paciente_update.email and paciente_update.email != current_paciente.email:
        existing_paciente = db.query(models.Usuario).filter(
            models.Usuario.email == paciente_update.email
        ).first()
        if existing_paciente:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Ya existe un paciente con este email"
            )
    
    # Actualizar campos
    update_data = paciente_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_paciente, field, value)
    
    db.commit()
    db.refresh(current_paciente)
    
    return schemas.PacienteResponse.from_orm(current_paciente)

@app.get("/pacientes/", response_model=schemas.PacienteList)
def listar_pacientes_por_doctor(
    doctor_id: str,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    """Listar pacientes de un doctor específico"""
    
    try:
        # Validar que el doctor existe
        doctor_service.validar_doctor_existe(doctor_id)
    except HTTPException as e:
        # Si hay error validando el doctor, continuar de todas formas
        # para evitar bloqueos por problemas de conectividad
        print(f"Warning: No se pudo validar doctor {doctor_id}: {e.detail}")
    
    try:
        doctor_uuid = uuid.UUID(doctor_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ID de doctor inválido"
        )
    
    pacientes = db.query(models.Usuario).filter(
        models.Usuario.id_doctor == doctor_uuid,
        models.Usuario.activo == True
    ).offset(skip).limit(limit).all()
    
    total = db.query(models.Usuario).filter(
        models.Usuario.id_doctor == doctor_uuid,
        models.Usuario.activo == True
    ).count()
    
    # Convertir los objetos Usuario a PacienteResponse usando el método from_orm
    pacientes_response = [schemas.PacienteResponse.from_orm(paciente) for paciente in pacientes]
    
    return {
        "pacientes": pacientes_response,
        "total": total,
        "pagina": skip // limit + 1,
        "por_pagina": limit
    }

@app.delete("/pacientes/me")
def desactivar_paciente(
    current_paciente: models.Usuario = Depends(auth.get_current_paciente),
    db: Session = Depends(database.get_db)
):
    """Desactivar la cuenta del paciente actual"""
    
    current_paciente.activo = False
    db.commit()
    
    return {"mensaje": "Cuenta desactivada exitosamente"}

# --- ENDPOINTS DE PERFIL DE SALUD ---

@app.post("/pacientes/me/perfil-salud", response_model=schemas.PerfilSalud)
def crear_perfil_salud(
    perfil: schemas.PerfilSaludCreate,
    current_paciente: models.Paciente = Depends(auth.get_current_paciente),
    db: Session = Depends(database.get_db)
):
    """Crear o actualizar perfil de salud del paciente"""
    
    # Verificar si ya existe un perfil
    existing_perfil = db.query(models.PerfilSalud).filter(
        models.PerfilSalud.id_paciente == current_paciente.id_paciente
    ).first()
    
    if existing_perfil:
        # Actualizar perfil existente
        update_data = perfil.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(existing_perfil, field, value)
        db.commit()
        db.refresh(existing_perfil)
        return existing_perfil
    else:
        # Crear nuevo perfil
        db_perfil = models.PerfilSalud(
            id_paciente=current_paciente.id_paciente,
            **perfil.dict()
        )
        db.add(db_perfil)
        db.commit()
        db.refresh(db_perfil)
        return db_perfil

@app.get("/pacientes/me/perfil-salud", response_model=schemas.PerfilSalud)
def obtener_perfil_salud(
    current_paciente: models.Paciente = Depends(auth.get_current_paciente),
    db: Session = Depends(database.get_db)
):
    """Obtener perfil de salud del paciente actual"""
    
    perfil = db.query(models.PerfilSalud).filter(
        models.PerfilSalud.id_paciente == current_paciente.id_paciente
    ).first()
    
    if not perfil:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de salud no encontrado"
        )
    
    return perfil

# --- ENDPOINTS DE MEDIDAS DE SALUD ---

@app.post("/pacientes/me/medidas", response_model=schemas.MedidaSalud)
def crear_medida_salud(
    medida: schemas.MedidaSaludCreate,
    current_paciente: models.Paciente = Depends(auth.get_current_paciente),
    db: Session = Depends(database.get_db)
):
    """Registrar una nueva medida de salud"""
    
    db_medida = models.MedidaSalud(
        id_paciente=current_paciente.id_paciente,
        **medida.dict()
    )
    
    db.add(db_medida)
    db.commit()
    db.refresh(db_medida)
    
    return db_medida

@app.get("/pacientes/me/medidas", response_model=List[schemas.MedidaSalud])
def obtener_medidas_salud(
    tipo_medida: str = None,
    limit: int = 100,
    current_paciente: models.Paciente = Depends(auth.get_current_paciente),
    db: Session = Depends(database.get_db)
):
    """Obtener medidas de salud del paciente actual"""
    
    query = db.query(models.MedidaSalud).filter(
        models.MedidaSalud.id_paciente == current_paciente.id_paciente
    )
    
    if tipo_medida:
        query = query.filter(models.MedidaSalud.tipo_medida == tipo_medida)
    
    medidas = query.order_by(models.MedidaSalud.fecha_medicion.desc()).limit(limit).all()
    
    return medidas

@app.get("/")
def root():
    """Endpoint raíz del servicio"""
    return {"message": "Servicio de Gestión de Pacientes", "version": "1.0.0", "docs": "/docs"}

@app.get("/health")
def health_check():
    """Endpoint de salud del servicio"""
    return {"status": "healthy", "service": "servicio-pacientes"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
