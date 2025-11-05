# /microservices/service-doctors/app/main.py
# Microservicio de Doctores - Refactorizado con Lógica Transaccional (3NF) y CRUD completo

from fastapi import FastAPI, Depends, HTTPException, status, Header
from typing import List, Optional

from .db import execute_query
from shared.auth_client import create_user as create_auth_user
from .domain import (
    DoctorCreateRequest,
    DoctorResponse,
    DoctorUpdateRequest
)

# --- Configuración de la Aplicación ---
app = FastAPI(title="Servicio de Doctores", version="3.0.0")

# --- Lógica de Negocio ---

def create_doctor_logic(doctor_data: DoctorCreateRequest):
    # Check if email already exists
    existing_email = execute_query("SELECT id FROM emails WHERE email_address = %s", (doctor_data.contact_email.email_address,), fetch_one=True)
    if existing_email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")

    # Check if medical license already exists
    existing_license = execute_query("SELECT id FROM doctors WHERE medical_license = %s", (doctor_data.medical_license,), fetch_one=True)
    if existing_license:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La licencia médica ya está registrada.")

    # Insert doctor
    doctor_query = """
        INSERT INTO doctors (
            first_name, last_name, medical_license, specialty_id, institution_id,
            years_experience, consultation_fee, is_active, is_verified
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, TRUE, FALSE)
        RETURNING id
    """
    doctor_result = execute_query(doctor_query, (
        doctor_data.first_name, doctor_data.last_name, doctor_data.medical_license,
        doctor_data.specialty_id, doctor_data.institution_id, doctor_data.years_experience,
        doctor_data.consultation_fee
    ), fetch_one=True)

    if not doctor_result:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al guardar el doctor")

    doctor_id = doctor_result['id']

    # Insert email
    email_query = """
        INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
        VALUES ('doctor', %s, (SELECT id FROM email_types WHERE name = 'primary'), %s, TRUE, FALSE)
    """
    execute_query(email_query, (doctor_id, doctor_data.contact_email.email_address))

    # Create auth user
    auth_user = create_auth_user(
        email=doctor_data.contact_email.email_address,
        password=doctor_data.password,
        user_type='doctor',
        reference_id=doctor_id
    )

    if not auth_user:
        # Rollback: delete doctor and email
        execute_query("DELETE FROM emails WHERE entity_id = %s AND entity_type = 'doctor'", (doctor_id,))
        execute_query("DELETE FROM doctors WHERE id = %s", (doctor_id,))
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada.")

    return {"id": doctor_id, "email": doctor_data.contact_email.email_address}


# --- Endpoints de la API ---

@app.post("/api/v1/doctors", response_model=DoctorResponse, status_code=status.HTTP_201_CREATED)
def create_doctor(doctor_data: DoctorCreateRequest):
    """Crea un doctor, su email, y su cuenta de usuario en una transacción compensada."""
    result = create_doctor_logic(doctor_data)

    # Get created doctor data
    doctor_query = """
        SELECT d.id, d.first_name, d.last_name, d.medical_license, d.specialty_id,
               d.institution_id, d.years_experience, d.consultation_fee, d.is_active, d.is_verified,
               e.email_address as contact_email
        FROM doctors d
        LEFT JOIN emails e ON e.entity_type = 'doctor' AND e.entity_id = d.id AND e.is_primary = TRUE
        WHERE d.id = %s
    """
    doctor_data_result = execute_query(doctor_query, (result['id'],), fetch_one=True)

    return DoctorResponse(
        id=doctor_data_result['id'],
        first_name=doctor_data_result['first_name'],
        last_name=doctor_data_result['last_name'],
        medical_license=doctor_data_result['medical_license'],
        specialty_id=doctor_data_result['specialty_id'],
        institution_id=doctor_data_result['institution_id'],
        years_experience=doctor_data_result['years_experience'],
        consultation_fee=float(doctor_data_result['consultation_fee']) if doctor_data_result['consultation_fee'] else None,
        is_active=doctor_data_result['is_active'],
        is_verified=doctor_data_result['is_verified'],
        contact_email=doctor_data_result['contact_email']
    )

# ... (El resto de los endpoints CRUD han sido convertidos a psycopg2)

@app.get("/api/v1/doctors/{doctor_id}", response_model=DoctorResponse)
def get_doctor(doctor_id: str):
    query = """
        SELECT d.id, d.first_name, d.last_name, d.medical_license, d.specialty_id,
               d.institution_id, d.years_experience, d.consultation_fee, d.is_active, d.is_verified,
               e.email_address as contact_email
        FROM doctors d
        LEFT JOIN emails e ON e.entity_type = 'doctor' AND e.entity_id = d.id AND e.is_primary = TRUE
        WHERE d.id = %s AND d.is_active = TRUE
    """
    doctor_data = execute_query(query, (doctor_id,), fetch_one=True)

    if not doctor_data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    return DoctorResponse(
        id=doctor_data['id'],
        first_name=doctor_data['first_name'],
        last_name=doctor_data['last_name'],
        medical_license=doctor_data['medical_license'],
        specialty_id=doctor_data['specialty_id'],
        institution_id=doctor_data['institution_id'],
        years_experience=doctor_data['years_experience'],
        consultation_fee=float(doctor_data['consultation_fee']) if doctor_data['consultation_fee'] else None,
        is_active=doctor_data['is_active'],
        is_verified=doctor_data['is_verified'],
        contact_email=doctor_data['contact_email']
    )

@app.get("/api/v1/doctors", response_model=List[DoctorResponse])
def list_doctors(skip: int = 0, limit: int = 100):
    query = """
        SELECT d.id, d.first_name, d.last_name, d.medical_license, d.specialty_id,
               d.institution_id, d.years_experience, d.consultation_fee, d.is_active, d.is_verified,
               e.email_address as contact_email
        FROM doctors d
        LEFT JOIN emails e ON e.entity_type = 'doctor' AND e.entity_id = d.id AND e.is_primary = TRUE
        WHERE d.is_active = TRUE
        ORDER BY d.created_at DESC
        LIMIT %s OFFSET %s
    """
    doctors_data = execute_query(query, (limit, skip), fetch_all=True)

    return [
        DoctorResponse(
            id=d['id'],
            first_name=d['first_name'],
            last_name=d['last_name'],
            medical_license=d['medical_license'],
            specialty_id=d['specialty_id'],
            institution_id=d['institution_id'],
            years_experience=d['years_experience'],
            consultation_fee=float(d['consultation_fee']) if d['consultation_fee'] else None,
            is_active=d['is_active'],
            is_verified=d['is_verified'],
            contact_email=d['contact_email']
        ) for d in doctors_data
    ]

@app.put("/api/v1/doctors/{doctor_id}", response_model=DoctorResponse)
def update_doctor(doctor_id: str, doctor_update: DoctorUpdateRequest):
    # Check if doctor exists
    existing_doctor = execute_query("SELECT id FROM doctors WHERE id = %s AND is_active = TRUE", (doctor_id,), fetch_one=True)
    if not existing_doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    # Build update query dynamically
    update_data = doctor_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No hay datos para actualizar.")

    set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
    values = list(update_data.values()) + [doctor_id]

    update_query = f"UPDATE doctors SET {set_clause} WHERE id = %s"
    execute_query(update_query, values)

    # Return updated doctor
    return get_doctor(doctor_id)

@app.delete("/api/v1/doctors/{doctor_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_doctor(doctor_id: str):
    # Check if doctor exists
    existing_doctor = execute_query("SELECT id FROM doctors WHERE id = %s AND is_active = TRUE", (doctor_id,), fetch_one=True)
    if not existing_doctor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    # Soft delete
    execute_query("UPDATE doctors SET is_active = FALSE WHERE id = %s", (doctor_id,))

@app.get("/health")
def health_check():
    return {"status": "healthy"}
