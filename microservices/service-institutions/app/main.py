# /microservices/service-institutions/app/main.py
# Microservicio de Instituciones - Refactorizado con Lógica Transaccional (3NF) y CRUD completo

from fastapi import FastAPI, Depends, HTTPException, status, Header
from typing import List

from .db import execute_query
from shared.auth_client import create_user as create_auth_user
from .domain import (
    InstitutionCreateRequest,
    InstitutionResponse,
    InstitutionUpdateRequest
)

# --- Configuración de la Aplicación ---
app = FastAPI(title="Servicio de Instituciones", version="3.0.0")

# --- Lógica de Negocio ---

def create_institution_logic(institution_data: InstitutionCreateRequest):
    # Check if email already exists
    existing_email = execute_query("SELECT id FROM emails WHERE email_address = %s", (institution_data.contact_email.email_address,), fetch_one=True)
    if existing_email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")

    # Check if license number already exists
    existing_license = execute_query("SELECT id FROM medical_institutions WHERE license_number = %s", (institution_data.license_number,), fetch_one=True)
    if existing_license:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El número de licencia ya está registrado.")

    # Insert institution
    institution_query = """
        INSERT INTO medical_institutions (
            name, type_id, license_number, address, phone, region, is_active, is_verified
        ) VALUES (%s, %s, %s, %s, %s, %s, TRUE, FALSE)
        RETURNING id
    """
    institution_result = execute_query(institution_query, (
        institution_data.name, institution_data.type_id, institution_data.license_number,
        institution_data.address, institution_data.phone, institution_data.region
    ), fetch_one=True)

    if not institution_result:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al guardar la institución")

    institution_id = institution_result['id']

    # Insert email
    email_query = """
        INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
        VALUES ('institution', %s, (SELECT id FROM email_types WHERE name = 'primary'), %s, TRUE, FALSE)
    """
    execute_query(email_query, (institution_id, institution_data.contact_email.email_address))

    # Create auth user
    auth_user = create_auth_user(
        email=institution_data.contact_email.email_address,
        password=institution_data.password,
        user_type='institution',
        reference_id=institution_id
    )

    if not auth_user:
        # Rollback: delete institution and email
        execute_query("DELETE FROM emails WHERE entity_id = %s AND entity_type = 'institution'", (institution_id,))
        execute_query("DELETE FROM medical_institutions WHERE id = %s", (institution_id,))
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada.")

    return {"id": institution_id, "email": institution_data.contact_email.email_address}

# --- Endpoints de la API ---

@app.post("/api/v1/institutions", response_model=InstitutionResponse, status_code=status.HTTP_201_CREATED)
def create_institution(institution_data: InstitutionCreateRequest):
    """Crea una institución, su email, y su cuenta de usuario."""
    result = create_institution_logic(institution_data)

    # Get created institution data
    institution_query = """
        SELECT i.id, i.name, i.type_id, i.license_number, i.address, i.phone, i.region, i.is_active, i.is_verified,
               e.email_address as contact_email
        FROM medical_institutions i
        LEFT JOIN emails e ON e.entity_type = 'institution' AND e.entity_id = i.id AND e.is_primary = TRUE
        WHERE i.id = %s
    """
    institution_data_result = execute_query(institution_query, (result['id'],), fetch_one=True)

    return InstitutionResponse(
        id=institution_data_result['id'],
        name=institution_data_result['name'],
        type_id=institution_data_result['type_id'],
        license_number=institution_data_result['license_number'],
        address=institution_data_result['address'],
        phone=institution_data_result['phone'],
        region=institution_data_result['region'],
        is_active=institution_data_result['is_active'],
        is_verified=institution_data_result['is_verified'],
        contact_email=institution_data_result['contact_email']
    )

# ... (El resto de los endpoints CRUD han sido convertidos a psycopg2)
@app.get("/api/v1/institutions/{institution_id}", response_model=InstitutionResponse)
def get_institution(institution_id: str):
    query = """
        SELECT i.id, i.name, i.type_id, i.license_number, i.address, i.phone, i.region, i.is_active, i.is_verified,
               e.email_address as contact_email
        FROM medical_institutions i
        LEFT JOIN emails e ON e.entity_type = 'institution' AND e.entity_id = i.id AND e.is_primary = TRUE
        WHERE i.id = %s AND i.is_active = TRUE
    """
    institution_data = execute_query(query, (institution_id,), fetch_one=True)

    if not institution_data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")

    return InstitutionResponse(
        id=institution_data['id'],
        name=institution_data['name'],
        type_id=institution_data['type_id'],
        license_number=institution_data['license_number'],
        address=institution_data['address'],
        phone=institution_data['phone'],
        region=institution_data['region'],
        is_active=institution_data['is_active'],
        is_verified=institution_data['is_verified'],
        contact_email=institution_data['contact_email']
    )

@app.get("/api/v1/institutions", response_model=List[InstitutionResponse])
def list_institutions(skip: int = 0, limit: int = 100):
    query = """
        SELECT i.id, i.name, i.type_id, i.license_number, i.address, i.phone, i.region, i.is_active, i.is_verified,
               e.email_address as contact_email
        FROM medical_institutions i
        LEFT JOIN emails e ON e.entity_type = 'institution' AND e.entity_id = i.id AND e.is_primary = TRUE
        WHERE i.is_active = TRUE
        ORDER BY i.created_at DESC
        LIMIT %s OFFSET %s
    """
    institutions_data = execute_query(query, (limit, skip), fetch_all=True)

    return [
        InstitutionResponse(
            id=i['id'],
            name=i['name'],
            type_id=i['type_id'],
            license_number=i['license_number'],
            address=i['address'],
            phone=i['phone'],
            region=i['region'],
            is_active=i['is_active'],
            is_verified=i['is_verified'],
            contact_email=i['contact_email']
        ) for i in institutions_data
    ]

@app.put("/api/v1/institutions/{institution_id}", response_model=InstitutionResponse)
def update_institution(institution_id: str, institution_update: InstitutionUpdateRequest):
    # Check if institution exists
    existing_institution = execute_query("SELECT id FROM medical_institutions WHERE id = %s AND is_active = TRUE", (institution_id,), fetch_one=True)
    if not existing_institution:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")

    # Build update query dynamically
    update_data = institution_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No hay datos para actualizar.")

    set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
    values = list(update_data.values()) + [institution_id]

    update_query = f"UPDATE medical_institutions SET {set_clause} WHERE id = %s"
    execute_query(update_query, values)

    # Return updated institution
    return get_institution(institution_id)

@app.delete("/api/v1/institutions/{institution_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_institution(institution_id: str):
    # Check if institution exists
    existing_institution = execute_query("SELECT id FROM medical_institutions WHERE id = %s AND is_active = TRUE", (institution_id,), fetch_one=True)
    if not existing_institution:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")

    # Soft delete
    execute_query("UPDATE medical_institutions SET is_active = FALSE WHERE id = %s", (institution_id,))

@app.get("/health")
def health_check():
    return {"status": "healthy"}
