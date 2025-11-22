# /microservices/service-institutions/app/main.py
# Microservicio de Instituciones - Refactorizado con Autenticación JWT y Estructura Normalizada (3NF)

from fastapi import FastAPI, Depends, HTTPException, status, Header
from typing import List, Optional, Dict, Any
from uuid import UUID
import jwt
import os
import logging

from .db import DatabaseConnection, execute_query
from shared.auth_client import create_user as create_auth_user
from .domain import (
    InstitutionCreateRequest,
    InstitutionResponse,
    InstitutionUpdateRequest
)

# --- Configuración ---
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "UDEM")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("service-institutions")

app = FastAPI(
    title="Servicio de Instituciones",
    version="3.0.0",
    description="Microservicio para la gestión de instituciones médicas."
)

# --- Lógica de Autenticación JWT ---

def verify_jwt_token(token: str) -> Dict[str, Any]:
    """Verifica y decodifica un token JWT."""
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        logger.warning("Token expirado")
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.PyJWTError as e:
        logger.error(f"Error decodificando token: {e}")
        raise HTTPException(status_code=401, detail="Token inválido")

def get_current_user(authorization: str = Header(None)) -> Dict[str, Any]:
    """Obtiene el usuario actual desde el token JWT en el encabezado."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token de autorización 'Bearer' requerido")
    
    token = authorization.split(" ")[1]
    user_data = verify_jwt_token(token)
    logger.info(f"Usuario autenticado: user_type={user_data.get('user_type')}, id={user_data.get('user_id')}")
    return user_data

def _get_institution_id_from_token(current_user: Dict[str, Any]) -> Optional[str]:
    """Extrae el institution_id del token JWT."""
    # El token puede tener reference_id en metadata o directamente
    metadata = current_user.get("metadata", {})
    if isinstance(metadata, dict):
        reference_id = metadata.get("reference_id")
        if reference_id:
            return str(reference_id)
    
    # Fallback: buscar reference_id directamente
    reference_id = current_user.get("reference_id")
    if reference_id:
        return str(reference_id)
    
    logger.warning(f"No se encontró reference_id en el token: {current_user}")
    return None

def require_institution_access(current_user: Dict[str, Any], institution_id: str):
    """Verifica que el usuario actual tenga permiso para acceder a los datos de una institución."""
    user_id_from_token = _get_institution_id_from_token(current_user)
    
    if current_user.get("user_type") == "institution":
        if not user_id_from_token:
             logger.warning("Token de institución sin ID válido")
             raise HTTPException(status_code=403, detail="Token de institución inválido")
             
        if str(user_id_from_token) != str(institution_id):
            logger.warning(f"Acceso denegado: token_id={user_id_from_token} != target_id={institution_id}")
            raise HTTPException(status_code=403, detail="No tienes permiso para acceder a este recurso")

# --- Lógica de Negocio y Acceso a Datos (Helpers Internos) ---

def _get_institution_details_from_db(institution_id: str) -> Optional[dict]:
    """
    Función helper DRY para obtener los detalles completos de una institución de la BD.
    Usa estructura normalizada (emails, phones, addresses en tablas separadas).
    """
    query = """
        SELECT
            i.id, i.name, i.institution_type_id, i.website, i.license_number,
            i.is_active, i.is_verified, i.created_at, i.updated_at,
            (SELECT email_address FROM emails WHERE entity_id = i.id AND entity_type = 'institution' AND is_primary = TRUE LIMIT 1) as contact_email,
            (SELECT phone_number FROM phones WHERE entity_id = i.id AND entity_type = 'institution' AND is_primary = TRUE LIMIT 1) as primary_phone,
            it.name as institution_type_name
        FROM medical_institutions i
        LEFT JOIN institution_types it ON i.institution_type_id = it.id
        WHERE i.id = %s AND i.is_active = TRUE
    """
    institution_data = execute_query(query, (UUID(institution_id),), fetch_one=True)
    
    if not institution_data:
        return None

    institution_dict = dict(institution_data)
    return institution_dict

def _create_full_institution_transaction(institution_data: InstitutionCreateRequest) -> UUID:
    """Ejecuta la creación completa de una institución dentro de una transacción atómica."""
    with DatabaseConnection() as (conn, cursor):
        # Validar email único
        cursor.execute("SELECT id FROM emails WHERE email_address = %s", (institution_data.contact_email.email_address,))
        if cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="El email ya está en uso.")

        # Validar licencia única
        cursor.execute("SELECT id FROM medical_institutions WHERE license_number = %s", (institution_data.license_number,))
        if cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="El número de licencia ya está registrado.")

        # Crear institución
        institution_query = """
            INSERT INTO medical_institutions (
                name, institution_type_id, website, license_number, is_active, is_verified
            ) VALUES (%s, %s, %s, %s, TRUE, FALSE)
            RETURNING id
        """
        cursor.execute(institution_query, (
            institution_data.name,
            institution_data.institution_type_id,
            institution_data.website,
            institution_data.license_number
        ))
        institution_id = cursor.fetchone()['id']

        # Crear email
        email_query = """
            INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
            VALUES ('institution', %s, (SELECT id FROM email_types WHERE name = 'primary'), %s, TRUE, FALSE)
        """
        cursor.execute(email_query, (institution_id, institution_data.contact_email.email_address))

        # Crear usuario de autenticación
        auth_user = create_auth_user(
            email=institution_data.contact_email.email_address,
            password=institution_data.password,
            user_type='institution',
            reference_id=institution_id
        )
        
        if not auth_user:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE, 
                detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada."
            )
            
    return institution_id

# --- Endpoints de la API ---

@app.post("/api/v1/institutions", response_model=InstitutionResponse, status_code=status.HTTP_201_CREATED)
def create_institution(institution_data: InstitutionCreateRequest):
    """Crea una institución, su email, y su cuenta de usuario de forma atómica."""
    try:
        institution_id = _create_full_institution_transaction(institution_data)
        created_institution_dict = _get_institution_details_from_db(str(institution_id))
        
        if not created_institution_dict:
            raise HTTPException(status_code=500, detail="Error crítico: No se pudo recuperar la institución después de la creación.")

        return InstitutionResponse(
            id=created_institution_dict['id'],
            name=created_institution_dict['name'],
            institution_type_id=created_institution_dict['institution_type_id'],
            website=created_institution_dict['website'],
            license_number=created_institution_dict['license_number'],
            is_active=created_institution_dict['is_active'],
            is_verified=created_institution_dict['is_verified'],
            contact_email=created_institution_dict.get('contact_email')
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error inesperado al crear institución: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {e}")

@app.get("/api/v1/institutions", response_model=List[InstitutionResponse])
def list_institutions(skip: int = 0, limit: int = 100):
    """Lista todas las instituciones activas con su información básica."""
    query = """
        SELECT
            i.id, i.name, i.institution_type_id, i.website, i.license_number,
            i.is_active, i.is_verified,
            (SELECT email_address FROM emails WHERE entity_id = i.id AND entity_type = 'institution' AND is_primary = TRUE LIMIT 1) as contact_email
        FROM medical_institutions i
        WHERE i.is_active = TRUE
        ORDER BY i.created_at DESC
        LIMIT %s OFFSET %s
    """
    institutions_data = execute_query(query, (limit, skip), fetch_all=True)

    return [
        InstitutionResponse(
            id=i['id'],
            name=i['name'],
            institution_type_id=i['institution_type_id'],
            website=i['website'],
            license_number=i['license_number'],
            is_active=i['is_active'],
            is_verified=i['is_verified'],
            contact_email=i.get('contact_email')
        ) for i in institutions_data
    ]

# --- Endpoints para Gestión de Doctores y Pacientes de la Institución ---

@app.get("/api/v1/institutions/doctors")
def get_institution_doctors(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene la lista de doctores de la institución del usuario autenticado."""
    if current_user.get("user_type") != "institution":
        raise HTTPException(status_code=403, detail="Este endpoint es solo para instituciones")
    
    institution_id = _get_institution_id_from_token(current_user)
    if not institution_id:
        raise HTTPException(status_code=400, detail="No se pudo identificar la institución")
    
    query = """
        SELECT
            d.id, d.first_name, d.last_name, d.medical_license, d.years_experience,
            d.consultation_fee, d.is_active, d.professional_status,
            ds.name as specialty_name,
            e.email_address as contact_email,
            ph.phone_number as contact_phone,
            (SELECT COUNT(*) FROM patients WHERE doctor_id = d.id AND is_active = TRUE) as active_patients
        FROM doctors d
        LEFT JOIN doctor_specialties ds ON d.specialty_id = ds.id
        LEFT JOIN emails e ON e.entity_id = d.id AND e.entity_type = 'doctor' AND e.is_primary = TRUE
        LEFT JOIN phones ph ON ph.entity_id = d.id AND ph.entity_type = 'doctor' AND ph.is_primary = TRUE
        WHERE d.institution_id = %s AND d.is_active = TRUE
        ORDER BY d.last_name, d.first_name
    """
    logger.info(f"🔍 Ejecutando query de doctores para institución ID: {institution_id} (tipo: {type(institution_id)})")
    doctors_data = execute_query(query, (str(institution_id),), fetch_all=True) or []
    logger.info(f"🔍 Query finalizada. Doctores encontrados: {len(doctors_data)}")
    
    # Formatear datos para el frontend
    doctors_list = []
    for doctor in doctors_data:
        doctor_dict = dict(doctor)
        # Mapear specialty_name a specialty para el frontend
        doctor_dict['specialty'] = doctor_dict.get('specialty_name')
        doctors_list.append(doctor_dict)
    
    return {"doctors": doctors_list}

@app.get("/api/v1/institutions/doctors")
def get_my_institution_doctors(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Alias para /api/v1/institutions/doctors - Obtiene doctores de la institución autenticada."""
    return get_institution_doctors(current_user)

@app.get("/api/v1/institutions/patients")
def get_institution_patients(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene la lista de pacientes de la institución del usuario autenticado."""
    logger.info("Solicitando lista de pacientes")
    
    if current_user.get("user_type") != "institution":
        logger.warning(f"Acceso denegado: user_type={current_user.get('user_type')} != institution")
        raise HTTPException(status_code=403, detail="Este endpoint es solo para instituciones")
    
    institution_id = _get_institution_id_from_token(current_user)
    if not institution_id:
        logger.error("No se pudo identificar la institución del token")
        raise HTTPException(status_code=400, detail="No se pudo identificar la institución")
    
    logger.info(f"Obteniendo pacientes para institución: {institution_id}")
    
    query = """
        SELECT
            p.id, p.first_name, p.last_name, p.date_of_birth, p.last_login,
            p.is_verified, p.created_at,
            e.email_address as contact_email,
            ph.phone_number as contact_phone,
            d.first_name as doctor_first_name,
            d.last_name as doctor_last_name,
            CASE 
                WHEN p.is_verified = TRUE THEN 'verified'
                ELSE 'unverified'
            END as validation_status,
            CONCAT(d.first_name, ' ', d.last_name) as doctor_name
        FROM patients p
        LEFT JOIN emails e ON e.entity_id = p.id AND e.entity_type = 'patient' AND e.is_primary = TRUE
        LEFT JOIN phones ph ON ph.entity_id = p.id AND ph.entity_type = 'patient' AND ph.is_primary = TRUE
        LEFT JOIN doctors d ON p.doctor_id = d.id
        WHERE p.institution_id = %s AND p.is_active = TRUE
        ORDER BY p.last_name, p.first_name
    """
    patients_data = execute_query(query, (str(institution_id),), fetch_all=True) or []
    
    # Formatear datos para el frontend
    patients_list = []
    for patient in patients_data:
        patient_dict = dict(patient)
        # Calcular risk_level basado en condiciones (simplificado por ahora)
        # TODO: Implementar lógica real de cálculo de riesgo
        patient_dict['risk_level'] = 'low'  # Placeholder
        patient_dict['last_activity'] = patient_dict.get('last_login') or patient_dict.get('created_at')
        patients_list.append(patient_dict)
    
    return {"patients": patients_list}

@app.get("/api/v1/institutions/patients")
def get_institution_patients(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene la list  a de pacientes de la institución autenticada."""
    return get_institution_patients(current_user)

@app.get("/api/v1/institutions/{institution_id}", response_model=InstitutionResponse)
def get_institution(institution_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene la información detallada de una institución específica."""
    require_institution_access(current_user, institution_id)
    
    institution_dict = _get_institution_details_from_db(institution_id)
    if not institution_dict:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")
    
    return InstitutionResponse(
        id=institution_dict['id'],
        name=institution_dict['name'],
        institution_type_id=institution_dict['institution_type_id'],
        website=institution_dict['website'],
        license_number=institution_dict['license_number'],
        is_active=institution_dict['is_active'],
        is_verified=institution_dict['is_verified'],
        contact_email=institution_dict.get('contact_email')
    )

@app.put("/api/v1/institutions/{institution_id}", response_model=InstitutionResponse)
def update_institution(institution_id: str, institution_update: InstitutionUpdateRequest, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Actualiza la información de una institución."""
    require_institution_access(current_user, institution_id)
    
    update_data = institution_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No hay datos para actualizar.")

    with DatabaseConnection() as (conn, cursor):
        cursor.execute("SELECT id FROM medical_institutions WHERE id = %s AND is_active = TRUE", (UUID(institution_id),))
        if not cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")

        set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
        values = list(update_data.values()) + [UUID(institution_id)]
        
        update_query = f"UPDATE medical_institutions SET {set_clause} WHERE id = %s"
        cursor.execute(update_query, values)
        
    updated_institution_dict = _get_institution_details_from_db(institution_id)
    return InstitutionResponse(
        id=updated_institution_dict['id'],
        name=updated_institution_dict['name'],
        institution_type_id=updated_institution_dict['institution_type_id'],
        website=updated_institution_dict['website'],
        license_number=updated_institution_dict['license_number'],
        is_active=updated_institution_dict['is_active'],
        is_verified=updated_institution_dict['is_verified'],
        contact_email=updated_institution_dict.get('contact_email')
    )

@app.delete("/api/v1/institutions/{institution_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_institution(institution_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Realiza un borrado lógico (soft delete) de una institución."""
    require_institution_access(current_user, institution_id)

    with DatabaseConnection() as (conn, cursor):
        cursor.execute("SELECT id FROM medical_institutions WHERE id = %s AND is_active = TRUE", (UUID(institution_id),))
        if not cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Institución no encontrada.")
        
        cursor.execute("UPDATE medical_institutions SET is_active = FALSE WHERE id = %s", (UUID(institution_id),))

@app.get("/health")
def health_check():
    """Endpoint de health check para monitoreo."""
    return {"status": "healthy"}
