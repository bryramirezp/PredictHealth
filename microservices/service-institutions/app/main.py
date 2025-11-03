# /microservices/service-institutions/app/main.py
# Microservicio de Instituciones - Refactorizado con Lógica Transaccional (3NF) y CRUD completo

from fastapi import FastAPI, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from typing import List

from shared.database import get_db, Base, engine
from shared.auth_client import create_user as create_auth_user
from .domain import (
    MedicalInstitution,
    Email,
    InstitutionCreateRequest,
    InstitutionResponse,
    InstitutionUpdateRequest
)

# --- Configuración de la Aplicación ---
Base.metadata.create_all(bind=engine)
app = FastAPI(title="Servicio de Instituciones", version="3.0.0")

# --- Lógica de Negocio ---

def create_institution_logic(db: Session, institution_data: InstitutionCreateRequest) -> MedicalInstitution:
    if db.query(Email).filter(Email.email_address == institution_data.contact_email.email_address).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")
    if db.query(MedicalInstitution).filter(MedicalInstitution.license_number == institution_data.license_number).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El número de licencia ya está registrado.")

    db_institution = MedicalInstitution(**institution_data.dict(exclude={'contact_email', 'password'}))
    db_email = Email(entity_type='institution', entity_id=db_institution.id, **institution_data.contact_email.dict())

    db.add(db_institution)
    db.add(db_email)

    try:
        db.commit()
        db.refresh(db_institution)
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Error al guardar la institución: {e}")

    auth_user = create_auth_user(
        email=institution_data.contact_email.email_address,
        password=institution_data.password,
        user_type='institution',
        reference_id=db_institution.id
    )

    if not auth_user:
        db.delete(db_institution)
        db.commit()
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada.")

    return db_institution

# --- Endpoints de la API ---

@app.post("/api/v1/institutions", response_model=InstitutionResponse, status_code=status.HTTP_201_CREATED)
def create_institution(
    institution_data: InstitutionCreateRequest,
    db: Session = Depends(get_db)
):
    """Crea una institución, su email, y su cuenta de usuario."""
    institution = create_institution_logic(db, institution_data)
    response = InstitutionResponse.from_orm(institution)
    response.contact_email = institution_data.contact_email.email_address
    return response

# ... (El resto de los endpoints CRUD permanecen igual)
@app.get("/api/v1/institutions/{institution_id}", response_model=InstitutionResponse)
def get_institution(
    institution_id: str,
    db: Session = Depends(get_db)
):
    institution = db.query(MedicalInstitution).filter(MedicalInstitution.id == institution_id).first()
    if not institution:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")

    primary_email = db.query(Email).filter(Email.entity_id == institution.id, Email.is_primary == True).first()

    response = InstitutionResponse.from_orm(institution)
    if primary_email:
        response.contact_email = primary_email.email_address
    return response

@app.get("/api/v1/institutions", response_model=List[InstitutionResponse])
def list_institutions(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100
):
    institutions = db.query(MedicalInstitution).offset(skip).limit(limit).all()
    return institutions

@app.put("/api/v1/institutions/{institution_id}", response_model=InstitutionResponse)
def update_institution(
    institution_id: str,
    institution_update: InstitutionUpdateRequest,
    db: Session = Depends(get_db)
):
    db_institution = db.query(MedicalInstitution).filter(MedicalInstitution.id == institution_id).first()
    if not db_institution:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")

    update_data = institution_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_institution, key, value)

    db.commit()
    db.refresh(db_institution)
    return db_institution

@app.delete("/api/v1/institutions/{institution_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_institution(
    institution_id: str,
    db: Session = Depends(get_db)
):
    db_institution = db.query(MedicalInstitution).filter(MedicalInstitution.id == institution_id).first()
    if not db_institution:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")

    db_institution.is_active = False
    db.commit()
    return

@app.get("/health")
def health_check():
    return {"status": "healthy"}
