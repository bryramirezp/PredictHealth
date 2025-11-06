# /microservices/service-patients/app/main.py (REFACTORIZADO)

from fastapi import FastAPI, Depends, HTTPException, status, Header
from typing import List, Optional, Dict, Any
from uuid import UUID
import jwt
import os
import logging
from datetime import date as date_type, datetime # Importar datetime

from shared.auth_client import create_user as create_auth_user

from .domain import (
    PatientCreateRequest,
    PatientResponse,
    PatientUpdateRequest,
    DashboardResponse,
    MedicalRecordResponse,
    CareTeamResponse,
    PatientProfileResponse
)
from .db import DatabaseConnection, execute_query

# --- Configuración ---
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "UDEM")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Servicio de Pacientes",
    version="3.0.0",
    description="Microservicio para la gestión de pacientes, sus perfiles y datos médicos."
)

# --- Lógica de Autenticación JWT ---

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

def require_patient_access(current_user: Dict[str, Any], patient_id: str):
    """Verifica que el usuario actual tenga permiso para acceder a los datos de un paciente."""
    user_id_from_token = current_user.get("reference_id") or current_user.get("user_id")
    
    if current_user.get("user_type") == "patient" and str(user_id_from_token) != patient_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para acceder a este recurso")


# --- Lógica de Negocio y Acceso a Datos (Helpers Internos) ---

def _get_patient_details_from_db(patient_id: str) -> Optional[dict]:
    """
    Función helper DRY para obtener los detalles completos de un paciente de la BD.
    """
    query = """
        SELECT
            p.id, p.doctor_id, p.institution_id, p.first_name, p.last_name,
            p.date_of_birth, p.sex_id, p.gender_id, p.emergency_contact_name,
            p.is_active, p.is_verified,
            (SELECT email_address FROM emails WHERE entity_id = p.id AND entity_type = 'patient' AND is_primary = TRUE) as contact_email,
            hp.height_cm, hp.weight_kg,
            bt.name as blood_type,
            hp.is_smoker, hp.consumes_alcohol, hp.notes,
            hp.physical_activity_minutes_weekly
        FROM patients p
        LEFT JOIN health_profiles hp ON hp.patient_id = p.id
        LEFT JOIN blood_types bt ON (hp.blood_type_id = bt.id AND hp.blood_type_id IS NOT NULL)
        WHERE p.id = %s AND p.is_active = TRUE
    """
    patient_data = execute_query(query, (UUID(patient_id),), fetch_one=True)
    
    if not patient_data:
        return None

    patient_dict = dict(patient_data)
    
    if patient_data["height_cm"] is not None or patient_data["blood_type"] is not None:
        patient_dict["health_profile"] = {
            "height_cm": patient_data["height_cm"],
            "weight_kg": patient_data["weight_kg"],
            "blood_type": patient_data["blood_type"],
            "is_smoker": patient_data["is_smoker"],
            "consumes_alcohol": patient_data["consumes_alcohol"],
            "notes": patient_data["notes"],
            "physical_activity_minutes_weekly": patient_data["physical_activity_minutes_weekly"]
        }
    else:
        patient_dict["health_profile"] = None
    
    return patient_dict

def _create_full_patient_transaction(patient_data: PatientCreateRequest) -> UUID:
    """Ejecuta la creación completa de un paciente dentro de una transacción atómica."""
    with DatabaseConnection() as (conn, cursor):
        cursor.execute("SELECT id FROM emails WHERE email_address = %s", (patient_data.contact_email.email_address,))
        if cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="El email ya está en uso.")

        patient_query = """
            INSERT INTO patients (
                first_name, last_name, date_of_birth, sex_id, gender_id,
                emergency_contact_name, doctor_id, institution_id, is_active, is_verified
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, TRUE, FALSE)
            RETURNING id
        """
        cursor.execute(patient_query, (
            patient_data.first_name, patient_data.last_name, patient_data.date_of_birth,
            patient_data.sex_id, patient_data.gender_id, patient_data.emergency_contact_name,
            patient_data.doctor_id, patient_data.institution_id
        ))
        patient_id = cursor.fetchone()['id']

        email_query = """
            INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
            VALUES ('patient', %s, (SELECT id FROM email_types WHERE name = 'primary'), %s, TRUE, FALSE)
        """
        cursor.execute(email_query, (patient_id, patient_data.contact_email.email_address))

        hp = patient_data.health_profile
        health_profile_query = """
            INSERT INTO health_profiles (
                patient_id, height_cm, weight_kg, blood_type_id, is_smoker,
                smoking_years, consumes_alcohol, alcohol_frequency, physical_activity_minutes_weekly, notes
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(health_profile_query, (
            patient_id, hp.height_cm, hp.weight_kg, hp.blood_type_id, hp.is_smoker,
            hp.smoking_years, hp.consumes_alcohol, hp.alcohol_frequency, 
            hp.physical_activity_minutes_weekly, hp.notes
        ))

        auth_user = create_auth_user(
            email=patient_data.contact_email.email_address,
            password=patient_data.password,
            user_type='patient',
            reference_id=patient_id
        )
        
        if not auth_user:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE, 
                detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada."
            )
            
    return patient_id


# --- Endpoints de la API ---

@app.post("/api/v1/patients", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
def create_patient(patient_data: PatientCreateRequest):
    """Crea un paciente, su email, perfil de salud y cuenta de usuario de forma atómica."""
    try:
        patient_id = _create_full_patient_transaction(patient_data)
        created_patient_dict = _get_patient_details_from_db(str(patient_id))
        
        if not created_patient_dict:
             raise HTTPException(status_code=500, detail="Error crítico: No se pudo recuperar el paciente después de la creación.")

        return created_patient_dict
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error inesperado al crear paciente: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {e}")

@app.get("/api/v1/patients", response_model=List[PatientResponse])
def list_patients(skip: int = 0, limit: int = 100):
    """Lista todos los pacientes activos con su información básica."""
    query = """
        SELECT
            p.id, p.doctor_id, p.institution_id, p.first_name, p.last_name,
            p.date_of_birth, p.sex_id, p.gender_id, p.emergency_contact_name,
            p.is_active, p.is_verified,
            (SELECT email_address FROM emails WHERE entity_id = p.id AND entity_type = 'patient' AND is_primary = TRUE) as contact_email,
            hp.height_cm, hp.weight_kg,
            bt.name as blood_type,
            hp.is_smoker, hp.consumes_alcohol, hp.notes,
            hp.physical_activity_minutes_weekly
        FROM patients p
        LEFT JOIN health_profiles hp ON hp.patient_id = p.id
        LEFT JOIN blood_types bt ON (hp.blood_type_id = bt.id AND hp.blood_type_id IS NOT NULL)
        WHERE p.is_active = TRUE
        ORDER BY p.created_at DESC
        LIMIT %s OFFSET %s
    """
    patients_data = execute_query(query, (limit, skip), fetch_all=True)

    response_list = []
    for p_data in patients_data:
        p_dict = dict(p_data)
        if p_data["height_cm"] is not None or p_data["blood_type"] is not None:
            p_dict["health_profile"] = {
                "height_cm": p_data["height_cm"],
                "weight_kg": p_data["weight_kg"],
                "blood_type": p_data["blood_type"],
                "is_smoker": p_data["is_smoker"],
                "consumes_alcohol": p_data["consumes_alcohol"],
                "notes": p_data["notes"],
                "physical_activity_minutes_weekly": p_data["physical_activity_minutes_weekly"]
            }
        else:
            p_dict["health_profile"] = None
        
        response_list.append(p_dict)
        
    return response_list


@app.get("/api/v1/patients/{patient_id}", response_model=PatientResponse)
def get_patient(patient_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene la información detallada de un paciente específico."""
    require_patient_access(current_user, patient_id)
    
    patient_dict = _get_patient_details_from_db(patient_id)
    if not patient_dict:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")
    
    return patient_dict

@app.put("/api/v1/patients/{patient_id}", response_model=PatientResponse)
def update_patient(patient_id: str, patient_update: PatientUpdateRequest, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Actualiza la información de un paciente."""
    require_patient_access(current_user, patient_id)
    
    update_data = patient_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No hay datos para actualizar.")

    with DatabaseConnection() as (conn, cursor):
        cursor.execute("SELECT id FROM patients WHERE id = %s AND is_active = TRUE", (UUID(patient_id),))
        if not cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")

        set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
        values = list(update_data.values()) + [UUID(patient_id)]
        
        update_query = f"UPDATE patients SET {set_clause} WHERE id = %s"
        cursor.execute(update_query, values)
        
    updated_patient_dict = _get_patient_details_from_db(patient_id)
    return updated_patient_dict


@app.delete("/api/v1/patients/{patient_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_patient(patient_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Realiza un borrado lógico (soft delete) de un paciente."""
    require_patient_access(current_user, patient_id)

    with DatabaseConnection() as (conn, cursor):
        cursor.execute("SELECT id FROM patients WHERE id = %s AND is_active = TRUE", (UUID(patient_id),))
        if not cursor.fetchone():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")
        
        cursor.execute("UPDATE patients SET is_active = FALSE WHERE id = %s", (UUID(patient_id),))


# --- Endpoints Específicos para Dashboard (REFACTORIZADOS) ---

def calculate_health_score(patient_info: Dict, conditions: List, medications: List) -> int:
    """Calcula una puntuación de salud básica (0-100)."""
    score = 100
    if conditions: score -= len(conditions) * 10
    if medications: score -= len(medications) * 5
    
    if patient_info.get('is_smoker') is True: score -= 15
    if patient_info.get('consumes_alcohol') is True: score -= 10
        
    activity = patient_info.get('physical_activity_minutes_weekly', 0) or 0
    if activity >= 150: score += 10
    elif activity >= 75: score += 5
    return max(0, min(100, score))

def calculate_age(birth_date: Optional[date_type]) -> Optional[int]:
    """Calcula la edad a partir de la fecha de nacimiento."""
    if not birth_date:
        return None
    today = date_type.today()
    age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
    return age

def calculate_bmi(height_cm: Optional[float], weight_kg: Optional[float]) -> Optional[float]:
    """Calcula el IMC si ambos valores están presentes."""
    if height_cm and weight_kg and height_cm > 0:
        height_m = float(height_cm) / 100
        bmi = float(weight_kg) / (height_m ** 2)
        return round(bmi, 1)
    return None

def classify_bmi(bmi: Optional[float]) -> Optional[str]:
    """Clasifica el IMC en categorías."""
    if bmi is None:
        return None
    if bmi < 18.5:
        return "Bajo peso 🟡"
    if 18.5 <= bmi < 25:
        return "Normal ✅"
    if 25 <= bmi < 30:
        return "Sobrepeso 🟠"
    if 30 <= bmi < 35:
        return "Obesidad I 🔴"
    if 35 <= bmi < 40:
        return "Obesidad II 🔴"
    if bmi >= 40:
        return "Obesidad III 🚨"
    return None

@app.get("/api/v1/patients/{patient_id}/dashboard", response_model=DashboardResponse)
async def get_patient_dashboard(patient_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Retorna todos los datos necesarios para el dashboard del paciente."""
    require_patient_access(current_user, patient_id)
    try:
        # Consulta actualizada para traer todos los datos necesarios para los KPIs
        basic_info_query = """
            SELECT 
                p.first_name, p.last_name, p.date_of_birth,
                hp.is_smoker, hp.consumes_alcohol, hp.physical_activity_minutes_weekly,
                hp.height_cm, hp.weight_kg 
            FROM patients p 
            LEFT JOIN health_profiles hp ON p.id = hp.patient_id 
            WHERE p.id = %s
        """
        basic_info_row = execute_query(basic_info_query, (UUID(patient_id),), fetch_one=True)
        
        if not basic_info_row:
            raise HTTPException(status_code=404, detail="Información básica del paciente no encontrada")
        
        basic_info = dict(basic_info_row)
        
        medications_query = "SELECT m.name, pm.dosage, pm.frequency FROM patient_medications pm JOIN medications m ON pm.medication_id = m.id WHERE pm.patient_id = %s"
        medications_rows = execute_query(medications_query, (UUID(patient_id),), fetch_all=True)
        medications = [dict(row) for row in medications_rows]

        conditions_query = "SELECT mc.name FROM patient_conditions pc JOIN medical_conditions mc ON pc.condition_id = mc.id WHERE pc.patient_id = %s"
        conditions_rows = execute_query(conditions_query, (UUID(patient_id),), fetch_all=True)
        conditions = [dict(row) for row in conditions_rows]

        # --- Calcular KPIs ---
        health_score = calculate_health_score(basic_info, conditions, medications)
        age = calculate_age(basic_info.get('date_of_birth'))
        bmi = calculate_bmi(basic_info.get('height_cm'), basic_info.get('weight_kg'))
        bmi_classification = classify_bmi(bmi)

        return {
            "patient": basic_info,
            "health_score": health_score,
            "medications": medications,
            "conditions": conditions,
            "age": age,
            "bmi": bmi,
            "bmi_classification": bmi_classification,
            # Placeholders
            "appointments": [],
            "recent_activity": []
        }
    except Exception as e:
        logger.error(f"Error obteniendo dashboard para paciente {patient_id}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error interno al obtener el dashboard: {e}")

@app.get("/api/v1/patients/{patient_id}/medical-record", response_model=MedicalRecordResponse)
async def get_patient_medical_record(patient_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Retorna el expediente médico completo del paciente."""
    require_patient_access(current_user, patient_id)
    try:
        health_profile_query = """
            SELECT hp.*, bt.name as blood_type
            FROM health_profiles hp
            LEFT JOIN blood_types bt ON hp.blood_type_id = bt.id
            WHERE hp.patient_id = %s
        """
        health_profile_row = execute_query(health_profile_query, (UUID(patient_id),), fetch_one=True)
        health_profile = dict(health_profile_row) if health_profile_row else None
        
        conditions_rows = execute_query("SELECT mc.name, pc.diagnosis_date, pc.notes FROM patient_conditions pc JOIN medical_conditions mc ON pc.condition_id = mc.id WHERE pc.patient_id = %s ORDER BY pc.diagnosis_date DESC", (UUID(patient_id),), fetch_all=True)
        conditions = [dict(row) for row in conditions_rows]
        
        medications_rows = execute_query("SELECT m.name, pm.dosage, pm.frequency, pm.start_date FROM patient_medications pm JOIN medications m ON pm.medication_id = m.id WHERE pm.patient_id = %s ORDER BY pm.start_date DESC", (UUID(patient_id),), fetch_all=True)
        medications = [dict(row) for row in medications_rows]

        allergies_rows = execute_query("SELECT a.name, pa.severity, pa.reaction_description FROM patient_allergies pa JOIN allergies a ON pa.allergy_id = a.id WHERE pa.patient_id = %s", (UUID(patient_id),), fetch_all=True)
        allergies = [dict(row) for row in allergies_rows]

        family_history_rows = execute_query("SELECT mc.name as condition_name, pfh.relative_type, pfh.notes FROM patient_family_history pfh JOIN medical_conditions mc ON pfh.condition_id = mc.id WHERE pfh.patient_id = %s", (UUID(patient_id),), fetch_all=True)
        family_history = [dict(row) for row in family_history_rows]

        return {
            "health_profile": health_profile, 
            "conditions": conditions, 
            "medications": medications,
            "allergies": allergies, 
            "family_history": family_history
        }
    except Exception as e:
        logger.error(f"Error obteniendo expediente médico para paciente {patient_id}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error interno al obtener el expediente médico: {e}")

@app.get("/api/v1/patients/{patient_id}/care-team", response_model=CareTeamResponse)
async def get_patient_care_team(patient_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Retorna información del equipo médico del paciente (doctor e institución)."""
    require_patient_access(current_user, patient_id)
    query = """
        SELECT
            d.id as doctor_id, d.first_name as doctor_first_name, d.last_name as doctor_last_name, d.years_experience, ds.name as doctor_specialty,
            de.email_address as doctor_email, dp.phone_number as doctor_phone,
            mi.id as institution_id, mi.name as institution_name, mi.website, it.name as institution_type,
            ie.email_address as institution_email, ip.phone_number as institution_phone,
            addr.street_address, addr.city, r.name as region_name, c.name as country_name, addr.postal_code
        FROM patients p
        JOIN doctors d ON p.doctor_id = d.id
        LEFT JOIN doctor_specialties ds ON d.specialty_id = ds.id
        JOIN medical_institutions mi ON p.institution_id = mi.id
        LEFT JOIN institution_types it ON mi.institution_type_id = it.id
        LEFT JOIN emails de ON de.entity_id = d.id AND de.entity_type = 'doctor' AND de.is_primary = TRUE
        LEFT JOIN phones dp ON dp.entity_id = d.id AND dp.entity_type = 'doctor' AND dp.is_primary = TRUE
        LEFT JOIN emails ie ON ie.entity_id = mi.id AND ie.entity_type = 'institution' AND ie.is_primary = TRUE
        LEFT JOIN phones ip ON ip.entity_id = mi.id AND ip.entity_type = 'institution' AND ip.is_primary = TRUE
        LEFT JOIN addresses addr ON addr.entity_id = mi.id AND addr.entity_type = 'institution' AND addr.is_primary = TRUE
        LEFT JOIN regions r ON addr.region_id = r.id
        LEFT JOIN countries c ON addr.country_id = c.id
        WHERE p.id = %s AND p.is_active = TRUE
    """
    result = execute_query(query, (UUID(patient_id),), fetch_one=True)

    if not result:
        raise HTTPException(status_code=404, detail="Equipo médico no encontrado para este paciente.")

    return {
        "doctor": {
            "first_name": result['doctor_first_name'], "last_name": result['doctor_last_name'],
            "years_experience": result['years_experience'], "specialty": result['doctor_specialty'],
            "email": result['doctor_email'], "phone": result['doctor_phone']
        },
        "institution": {
            "name": result['institution_name'], "type": result['institution_type'], "website": result['website'],
            "email": result['institution_email'], "phone": result['institution_phone'],
            "address": {
                "street": result['street_address'], "city": result['city'], "region": result['region_name'],
                "country": result['country_name'], "postal_code": result['postal_code']
            } if result['street_address'] else None
        }
    }

@app.get("/api/v1/patients/{patient_id}/profile", response_model=PatientProfileResponse)
async def get_patient_profile(patient_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Retorna toda la información necesaria para la página de perfil del paciente."""
    require_patient_access(current_user, patient_id)
    try:
        personal_info_query = "SELECT first_name, last_name, date_of_birth FROM patients WHERE id = %s"
        personal_info_row = execute_query(personal_info_query, (UUID(patient_id),), fetch_one=True)
        
        if not personal_info_row:
            raise HTTPException(status_code=404, detail="Perfil de paciente no encontrado.")
        personal_info = dict(personal_info_row)

        emails_query = "SELECT id, email_address, is_primary, is_verified, (SELECT name FROM email_types WHERE id = email_type_id) as email_type FROM emails WHERE entity_id = %s AND entity_type = 'patient'"
        emails_rows = execute_query(emails_query, (UUID(patient_id),), fetch_all=True)
        emails = [dict(row) for row in emails_rows]

        phones_query = "SELECT id, phone_number, is_primary, is_verified, (SELECT name FROM phone_types WHERE id = phone_type_id) as phone_type FROM phones WHERE entity_id = %s AND entity_type = 'patient'"
        phones_rows = execute_query(phones_query, (UUID(patient_id),), fetch_all=True)
        phones = [dict(row) for row in phones_rows]

        addresses_query = "SELECT * FROM addresses WHERE entity_id = %s AND entity_type = 'patient'"
        addresses_rows = execute_query(addresses_query, (UUID(patient_id),), fetch_all=True)
        addresses = [dict(row) for row in addresses_rows]

        primary_email = next((email['email_address'] for email in emails if email.get('is_primary')), None)
        personal_info['primary_email'] = primary_email

        return {
            "personal_info": personal_info,
            "emails": emails,
            "phones": phones,
            "addresses": addresses
        }
    except Exception as e:
        logger.error(f"Error obteniendo perfil para paciente {patient_id}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error interno al obtener el perfil: {e}")

@app.get("/health")
def health_check():
    """Endpoint de health check para monitoreo."""
    return {"status": "healthy"}