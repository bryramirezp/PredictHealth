# /microservices/service-doctors/app/main.py
# CORREGIDO: Maneja 'reference_id' anidado y elimina conversiones (UUID())

from fastapi import FastAPI, Depends, HTTPException, status, Header
from typing import List, Optional, Dict, Any
from uuid import UUID # Sigue siendo necesario para el type hint
import jwt
import os
import logging
import requests

from .db import DatabaseConnection, execute_query
from shared.auth_client import create_user as create_auth_user
from .domain import (
    DoctorCreateRequest,
    DoctorResponse,
    DoctorUpdateRequest,
    DoctorProfileResponse,
    DoctorInstitutionResponse,
    DoctorPatientListResponse,
    DoctorPatientMedicalRecord,
    DoctorDashboardKPIs,
    LoginRequest
)

# --- Configuración de la Aplicación ---
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "UDEM")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL", "http://servicio-auth-jwt:8003")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Servicio de Doctores", 
    version="3.4.0",
    description="Microservicio para la gestión de doctores, perfiles y pacientes asignados."
)

# --- Lógica de Autenticación (JWT) ---

def verify_jwt_token(token: str) -> Dict[str, Any]:
    """Verifica y decodifica un token JWT."""
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Token inválido")

def get_current_user(authorization: str = Header(None)) -> Dict[str, Any]:
    """Obtiene el usuario actual desde el token JWT en el encabezado."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token de autorización 'Bearer' requerido")
    
    token = authorization.split(" ")[1]
    return verify_jwt_token(token)

def get_reference_id_from_token(payload: Dict[str, Any]) -> Optional[str]:
    """
    Helper para extraer el reference_id, incluso si está anidado
    dentro de 'metadata' (como se ve en los logs de Redis).
    """
    ref_id = payload.get("reference_id")
    if ref_id:
        return str(ref_id)
    
    metadata = payload.get("metadata")
    if isinstance(metadata, dict):
        ref_id = metadata.get("reference_id")
        if ref_id:
            logger.info(f"✅ 'reference_id' encontrado dentro de 'metadata': {ref_id}")
            return str(ref_id)
            
    user_id = payload.get("user_id")
    if user_id:
        logger.warning(f"⚠️ No se encontró 'reference_id', usando 'user_id' como fallback: {user_id}")
        return str(user_id)
        
    return None

def require_doctor_role(current_user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
    """
    Dependencia que verifica que el usuario sea un doctor y extrae
    correctamente el reference_id.
    """
    if current_user.get("user_type") != "doctor":
        raise HTTPException(status_code=403, detail="Acceso denegado: Se requiere rol de Doctor.")
    
    reference_id = get_reference_id_from_token(current_user)
    
    if not reference_id:
        logger.error(f"❌ Token de doctor inválido. Payload: {current_user}")
        raise HTTPException(status_code=400, detail="Token de doctor inválido, no contiene reference_id.")
    
    return {
        "payload": current_user,
        "reference_id": reference_id 
    }

# --- Endpoint de Login ---

@app.post("/auth/login")
def login(login_request: LoginRequest):
    """
    Endpoint de login para doctores.
    Valida que el doctor existe y está activo antes de delegar al auth-service.
    """
    try:
        if not login_request.email or not login_request.password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email y contraseña son requeridos"
            )
        
        # Verificar que el doctor existe y está activo en la BD
        doctor_query = """
            SELECT d.id, d.is_active, d.professional_status, e.email_address
            FROM doctors d
            LEFT JOIN emails e ON e.entity_id = d.id AND e.entity_type = 'doctor' AND e.is_primary = TRUE
            WHERE e.email_address = %s
        """
        doctor_data = execute_query(doctor_query, (login_request.email,), fetch_one=True)
        
        if not doctor_data:
            logger.warning(f"Login attempt with non-existent doctor email: {login_request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email o contraseña incorrectos"
            )
        
        # Verificar que el doctor está activo
        if not doctor_data.get('is_active'):
            logger.warning(f"Login attempt for inactive doctor: {login_request.email}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Doctor desactivado. Contacte al administrador."
            )
        
        # Verificar estado profesional
        professional_status = doctor_data.get('professional_status')
        if professional_status and professional_status != 'active':
            logger.warning(f"Login attempt for doctor with status '{professional_status}': {login_request.email}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cuenta de doctor no disponible. Contacte al administrador."
            )
        
        # Delegar autenticación al auth-jwt-service
        auth_url = f"{AUTH_SERVICE_URL}/auth/login"
        auth_payload = {
            "email": login_request.email,
            "password": login_request.password
        }
        
        try:
            auth_response = requests.post(auth_url, json=auth_payload, timeout=5)
            auth_response.raise_for_status()
            auth_data = auth_response.json()
            
            # Verificar que el usuario es de tipo doctor
            if auth_data.get('user_type') != 'doctor':
                logger.warning(f"Login attempt for non-doctor user: {login_request.email}")
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Este endpoint es solo para doctores"
                )
            
            logger.info(f"Successful login for doctor: {login_request.email}")
            return auth_data
            
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 401:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Email o contraseña incorrectos"
                )
            logger.error(f"Error calling auth-service: {e}")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Error de comunicación con el servicio de autenticación"
            )
        except requests.exceptions.RequestException as e:
            logger.error(f"Error connecting to auth-service: {e}")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="No se pudo conectar con el servicio de autenticación"
            )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error during login for {login_request.email}: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor durante el login"
        )

# --- Lógica de Negocio ---

def _create_full_doctor_transaction(doctor_data: DoctorCreateRequest) -> UUID:
    """Ejecuta la creación completa de un doctor dentro de una transacción atómica."""
    with DatabaseConnection() as (conn, cursor):
        cursor.execute("SELECT id FROM emails WHERE email_address = %s", (doctor_data.contact_email.email_address,))
        if cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="El email ya está en uso.")

        cursor.execute("SELECT id FROM doctors WHERE medical_license = %s", (doctor_data.medical_license,))
        if cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="La licencia médica ya está registrada.")

        doctor_query = """
            INSERT INTO doctors (
                first_name, last_name, medical_license, specialty_id, institution_id,
                years_experience, consultation_fee, is_active, professional_status
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, TRUE, 'active')
            RETURNING id
        """
        cursor.execute(doctor_query, (
            doctor_data.first_name, doctor_data.last_name, doctor_data.medical_license,
            doctor_data.specialty_id, doctor_data.institution_id, doctor_data.years_experience,
            doctor_data.consultation_fee
        ))
        
        doctor_id = cursor.fetchone()['id'] # Esto ya es un objeto UUID de la BD

        email_query = """
            INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
            VALUES ('doctor', %s, (SELECT id FROM email_types WHERE name = 'primary'), %s, TRUE, FALSE)
        """
        cursor.execute(email_query, (doctor_id, doctor_data.contact_email.email_address))

        auth_user = create_auth_user(
            email=doctor_data.contact_email.email_address,
            password=doctor_data.password,
            user_type='doctor',
            reference_id=doctor_id
        )

        if not auth_user:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE, 
                detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada."
            )
            
    return doctor_id

def _get_doctor_details_from_db(doctor_id: str) -> dict:
    """Función helper DRY para obtener los detalles de un doctor para el CRUD de Admin."""
    query = """
        SELECT 
            d.id, d.first_name, d.last_name, d.medical_license, d.specialty_id,
            d.institution_id, d.years_experience, d.consultation_fee, d.is_active, 
            d.professional_status,
            e.email_address as contact_email
        FROM doctors d
        LEFT JOIN emails e ON e.entity_type = 'doctor' AND e.entity_id = d.id AND e.is_primary = TRUE
        WHERE d.id = %s
    """
    # Pasamos el string 'doctor_id' directamente. psycopg2 lo manejará.
    doctor_data = execute_query(query, (doctor_id,), fetch_one=True)

    if not doctor_data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")
    
    return dict(doctor_data)

# --- Endpoints del Doctor Autenticado (para el Frontend del Doctor) ---

@app.get("/api/v1/doctors/me/dashboard", response_model=DoctorDashboardKPIs)
def get_my_dashboard_kpis(auth_info: Dict[str, Any] = Depends(require_doctor_role)):
    """
    Obtiene los KPIs para el dashboard.html del doctor.
    """
    doctor_id = auth_info.get("reference_id")
    
    patients_query = "SELECT COUNT(*) as count FROM patients WHERE doctor_id = %s AND is_active = TRUE"
    
    # Pasamos el string 'doctor_id' directamente.
    patients_count_row = execute_query(patients_query, (doctor_id,), fetch_one=True)
    
    today_appointments = 0
    pending_reviews = 0

    return {
        "total_patients": patients_count_row['count'] if patients_count_row else 0,
        "today_appointments": today_appointments,
        "pending_reviews": pending_reviews
    }

@app.get("/api/v1/doctors/me/profile", response_model=DoctorProfileResponse)
def get_my_profile(auth_info: Dict[str, Any] = Depends(require_doctor_role)):
    """
    Obtiene el perfil del doctor actualmente autenticado para profile.html.
    """
    doctor_id = auth_info.get("reference_id")

    query = """
        SELECT
            d.id, d.first_name, d.last_name, 
            e.email_address as email,
            ds.name as specialty_name,
            d.specialty_id,
            mi.name as institution_name,
            d.years_experience, d.consultation_fee
        FROM doctors d
        LEFT JOIN emails e ON e.entity_id = d.id AND e.entity_type = 'doctor' AND e.is_primary = TRUE
        LEFT JOIN doctor_specialties ds ON d.specialty_id = ds.id
        LEFT JOIN medical_institutions mi ON d.institution_id = mi.id
        WHERE d.id = %s AND d.is_active = TRUE
    """
    profile_data = execute_query(query, (doctor_id,), fetch_one=True)

    if not profile_data:
        raise HTTPException(status_code=404, detail="Perfil de doctor no encontrado.")

    return dict(profile_data)

@app.put("/api/v1/doctors/me/profile", response_model=DoctorProfileResponse)
def update_my_profile(
    profile_update: DoctorUpdateRequest, 
    auth_info: Dict[str, Any] = Depends(require_doctor_role)
):
    """
    Actualiza el perfil del doctor actualmente autenticado (profile.html).
    """
    doctor_id = auth_info.get("reference_id")
    
    update_data = profile_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No hay datos para actualizar.")

    set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
    values = list(update_data.values()) + [doctor_id]

    update_query = f"UPDATE doctors SET {set_clause} WHERE id = %s"
    
    try:
        with DatabaseConnection() as (conn, cursor):
            cursor.execute(update_query, values)
    except Exception as e:
        logger.error(f"Error al actualizar perfil de doctor: {e}")
        raise HTTPException(status_code=500, detail="Error al actualizar la base de datos.")

    return get_my_profile(auth_info)

@app.get("/api/v1/doctors/me/institution", response_model=DoctorInstitutionResponse)
def get_my_institution(auth_info: Dict[str, Any] = Depends(require_doctor_role)):
    """
    Obtiene la información de la institución del doctor (my-institution.html).
    """
    doctor_id = auth_info.get("reference_id")
    
    query = """
        SELECT
            mi.id, mi.name, mi.website, mi.license_number,
            it.name as type,
            e.email_address as email,
            p.phone_number as phone,
            a.street_address, a.city, r.name as region_name, 
            c.name as country_name, a.postal_code
        FROM doctors d
        JOIN medical_institutions mi ON d.institution_id = mi.id
        LEFT JOIN institution_types it ON mi.institution_type_id = it.id
        LEFT JOIN emails e ON e.entity_id = mi.id AND e.entity_type = 'institution' AND e.is_primary = TRUE
        LEFT JOIN phones p ON p.entity_id = mi.id AND p.entity_type = 'institution' AND p.is_primary = TRUE
        LEFT JOIN addresses a ON a.entity_id = mi.id AND a.entity_type = 'institution' AND a.is_primary = TRUE
        LEFT JOIN regions r ON a.region_id = r.id
        LEFT JOIN countries c ON a.country_id = c.id
        WHERE d.id = %s
    """
    inst_data = execute_query(query, (doctor_id,), fetch_one=True)
    
    if not inst_data:
        raise HTTPException(status_code=404, detail="Institución no encontrada para este doctor.")

    inst_dict = dict(inst_data)
    inst_dict["address"] = {
        "street_address": inst_data["street_address"],
        "city": inst_data["city"],
        "region_name": inst_data["region_name"],
        "country_name": inst_data["country_name"],
        "postal_code": inst_data["postal_code"]
    } if inst_data["street_address"] else None
    
    return inst_dict


@app.get("/api/v1/doctors/me/patients", response_model=DoctorPatientListResponse)
def get_my_patients(auth_info: Dict[str, Any] = Depends(require_doctor_role)):
    """
    Obtiene la lista de pacientes asignados al doctor (patients.html).
    """
    doctor_id = auth_info.get("reference_id")

    query = """
        SELECT
            p.id, p.first_name, p.last_name, p.date_of_birth, p.last_login,
            e.email_address as contact_email,
            ph.phone_number as contact_phone
        FROM patients p
        LEFT JOIN emails e ON e.entity_id = p.id AND e.entity_type = 'patient' AND e.is_primary = TRUE
        LEFT JOIN phones ph ON ph.entity_id = p.id AND ph.entity_type = 'patient' AND ph.is_primary = TRUE
        WHERE p.doctor_id = %s AND p.is_active = TRUE
        ORDER BY p.last_name, p.first_name
    """
    patients_rows = execute_query(query, (doctor_id,), fetch_all=True)
    
    patient_list = [dict(row) for row in patients_rows]

    return {
        "patient_count": len(patient_list),
        "patients": patient_list
    }

@app.get("/api/v1/doctors/me/patients/{patient_id}/medical-record", response_model=DoctorPatientMedicalRecord)
def get_patient_medical_record_for_doctor(patient_id: str, auth_info: Dict[str, Any] = Depends(require_doctor_role)):
    """
    Obtiene el expediente de un paciente específico, PERO solo si está
    asignado al doctor autenticado (patient-detail.html).
    """
    doctor_id = auth_info.get("reference_id")

    # --- 1. Seguridad: Verificar que el paciente pertenece al doctor ---
    patient_info_query = """
        SELECT
            p.id, p.first_name, p.last_name, p.date_of_birth, p.last_login,
            e.email_address as contact_email,
            ph.phone_number as contact_phone
        FROM patients p
        LEFT JOIN emails e ON e.entity_id = p.id AND e.entity_type = 'patient' AND e.is_primary = TRUE
        LEFT JOIN phones ph ON ph.entity_id = p.id AND ph.entity_type = 'patient' AND ph.is_primary = TRUE
        WHERE p.id = %s AND p.doctor_id = %s AND p.is_active = TRUE
    """
    patient_info_row = execute_query(patient_info_query, (patient_id, doctor_id), fetch_one=True)
    
    if not patient_info_row:
        raise HTTPException(status_code=404, detail="Paciente no encontrado o no asignado a este doctor.")
    
    patient_info = dict(patient_info_row)

    # --- 2. Obtener el resto del expediente (como en service-patients) ---
    health_profile_query = """
        SELECT hp.*, bt.name as blood_type
        FROM health_profiles hp
        LEFT JOIN blood_types bt ON hp.blood_type_id = bt.id
        WHERE hp.patient_id = %s
    """
    health_profile_row = execute_query(health_profile_query, (patient_id,), fetch_one=True)
    
    conditions_rows = execute_query("SELECT mc.id, mc.name, pc.diagnosis_date, pc.notes FROM patient_conditions pc JOIN medical_conditions mc ON pc.condition_id = mc.id WHERE pc.patient_id = %s", (patient_id,), fetch_all=True)
    medications_rows = execute_query("SELECT m.id, m.name, pm.dosage, pm.frequency, pm.start_date FROM patient_medications pm JOIN medications m ON pm.medication_id = m.id WHERE pm.patient_id = %s", (patient_id,), fetch_all=True)
    allergies_rows = execute_query("SELECT a.id, a.name, pa.severity, pa.reaction_description FROM patient_allergies pa JOIN allergies a ON pa.allergy_id = a.id WHERE pa.patient_id = %s", (patient_id,), fetch_all=True)
    family_history_rows = execute_query("SELECT mc.id, mc.name as condition_name, pfh.relative_type, pfh.notes FROM patient_family_history pfh JOIN medical_conditions mc ON pfh.condition_id = mc.id WHERE pfh.patient_id = %s", (patient_id,), fetch_all=True)

    return {
        "patient_info": patient_info,
        "health_profile": dict(health_profile_row) if health_profile_row else None,
        "conditions": [dict(r) for r in conditions_rows],
        "medications": [dict(r) for r in medications_rows],
        "allergies": [dict(r) for r in allergies_rows],
        "family_history": [dict(r) for r in family_history_rows]
    }


# --- Endpoints de Admin (CRUD de Doctores) ---
# (Protegidos por autenticación general)

@app.post("/api/v1/doctors", response_model=DoctorResponse, status_code=status.HTTP_201_CREATED)
def create_doctor(doctor_data: DoctorCreateRequest, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Crea un doctor. (Endpoint protegido para Admin)"""
    try:
        doctor_id = _create_full_doctor_transaction(doctor_data)
        created_doctor_dict = _get_doctor_details_from_db(str(doctor_id))
        return created_doctor_dict
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error inesperado al crear doctor: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {e}")

@app.get("/api/v1/doctors/{doctor_id}", response_model=DoctorResponse)
def get_doctor(doctor_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene un doctor específico por ID. (Endpoint protegido para Admin)"""
    doctor_dict = _get_doctor_details_from_db(doctor_id)
    return doctor_dict

@app.get("/api/v1/doctors", response_model=List[DoctorResponse])
def list_doctors(skip: int = 0, limit: int = 100, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Lista todos los doctores activos. (Endpoint protegido para Admin)"""
    query = """
        SELECT 
            d.id, d.first_name, d.last_name, d.medical_license, d.specialty_id,
            d.institution_id, d.years_experience, d.consultation_fee, d.is_active, 
            d.professional_status,
            e.email_address as contact_email
        FROM doctors d
        LEFT JOIN emails e ON e.entity_type = 'doctor' AND e.entity_id = d.id AND e.is_primary = TRUE
        WHERE d.is_active = TRUE
        ORDER BY d.created_at DESC
        LIMIT %s OFFSET %s
    """
    doctors_data = execute_query(query, (limit, skip), fetch_all=True)
    return [dict(d) for d in doctors_data]

@app.put("/api/v1/doctors/{doctor_id}", response_model=DoctorResponse)
def update_doctor(doctor_id: str, doctor_update: DoctorUpdateRequest, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Actualiza un doctor. (Endpoint protegido para Admin)"""
    if not _get_doctor_details_from_db(doctor_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    update_data = doctor_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No hay datos para actualizar.")

    set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
    values = list(update_data.values()) + [doctor_id]

    update_query = f"UPDATE doctors SET {set_clause} WHERE id = %s"
    
    try:
        with DatabaseConnection() as (conn, cursor):
            cursor.execute(update_query, values)
    except Exception as e:
        logger.error(f"Error al actualizar doctor: {e}")
        raise HTTPException(status_code=500, detail="Error al actualizar la base de datos.")

    return _get_doctor_details_from_db(doctor_id)

@app.delete("/api/v1/doctors/{doctor_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_doctor(doctor_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Realiza un borrado lógico (soft delete) de un doctor. (Endpoint protegido para Admin)"""
    if not _get_doctor_details_from_db(doctor_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Doctor no encontrado.")

    try:
        with DatabaseConnection() as (conn, cursor):
            cursor.execute("UPDATE doctors SET is_active = FALSE WHERE id = %s", (doctor_id,))
    except Exception as e:
        logger.error(f"Error al eliminar doctor: {e}")
        raise HTTPException(status_code=500, detail="Error al actualizar la base de datos.")

@app.get("/health")
def health_check():
    """Endpoint de health check para monitoreo."""
    return {"status": "healthy"}