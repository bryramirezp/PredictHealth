# /microservices/service-patients/app/main.py
# Microservicio de Pacientes - Refactorizado con Lógica Transaccional (3NF) y CRUD completo

from fastapi import FastAPI, Depends, HTTPException, status, Header, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional, Dict, Any
from uuid import UUID
import jwt
import os
import logging

from shared.auth_client import create_user as create_auth_user
from .domain import (
    PatientCreateRequest,
    PatientResponse,
    PatientUpdateRequest
)
from .db import execute_query

# --- Configuración JWT ---
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "UDEM")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

# Configure logging
logger = logging.getLogger(__name__)

# --- Configuración de la Aplicación ---
app = FastAPI(title="Servicio de Pacientes", version="3.0.0")

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5000", "http://127.0.0.1:5000"],  # URLs del frontend
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
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
    """Obtiene el usuario actual desde el token JWT."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token de autorización requerido")

    token = authorization.split(" ")[1]
    return verify_jwt_token(token)

def require_patient_access(current_user: Dict[str, Any], patient_id: str):
    """Verifica que el usuario tenga acceso al paciente especificado."""
    if current_user["user_type"] == "patient" and current_user["user_id"] != patient_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para acceder a este paciente")

# --- Lógica de Negocio ---

def create_patient_logic(patient_data: PatientCreateRequest):
    # Check if email already exists
    existing_email = execute_query("SELECT id FROM emails WHERE email_address = %s", (patient_data.contact_email.email_address,), fetch_one=True)
    if existing_email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")

    # Insert patient
    patient_query = """
        INSERT INTO patients (
            first_name, last_name, date_of_birth, sex_id, gender_id,
            emergency_contact_name, doctor_id, institution_id, is_active, is_verified
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, TRUE, FALSE)
        RETURNING id
    """
    patient_result = execute_query(patient_query, (
        patient_data.first_name, patient_data.last_name, patient_data.date_of_birth,
        patient_data.sex_id, patient_data.gender_id, patient_data.emergency_contact_name,
        patient_data.doctor_id, patient_data.institution_id
    ), fetch_one=True)

    if not patient_result:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al guardar el paciente")

    patient_id = patient_result['id']

    # Insert email
    email_query = """
        INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
        VALUES ('patient', %s, (SELECT id FROM email_types WHERE name = 'primary'), %s, TRUE, FALSE)
    """
    execute_query(email_query, (patient_id, patient_data.contact_email.email_address))

    # Insert health profile
    health_profile_query = """
        INSERT INTO health_profiles (
            patient_id, height_cm, weight_kg, blood_type_id, is_smoker,
            smoking_years, consumes_alcohol, alcohol_frequency, physical_activity_minutes_weekly, notes
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    execute_query(health_profile_query, (
        patient_id, patient_data.health_profile.height_cm, patient_data.health_profile.weight_kg,
        patient_data.health_profile.blood_type_id, patient_data.health_profile.is_smoker,
        patient_data.health_profile.smoking_years, patient_data.health_profile.consumes_alcohol,
        patient_data.health_profile.alcohol_frequency, patient_data.health_profile.physical_activity_minutes_weekly,
        patient_data.health_profile.notes
    ))

    # Create auth user
    auth_user = create_auth_user(
        email=patient_data.contact_email.email_address,
        password=patient_data.password,
        user_type='patient',
        reference_id=patient_id
    )

    if not auth_user:
        # Rollback: delete patient, email and health profile
        execute_query("DELETE FROM health_profiles WHERE patient_id = %s", (patient_id,))
        execute_query("DELETE FROM emails WHERE entity_id = %s AND entity_type = 'patient'", (patient_id,))
        execute_query("DELETE FROM patients WHERE id = %s", (patient_id,))
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada.")

    return {"id": patient_id, "email": patient_data.contact_email.email_address}

# --- Endpoints de la API ---

@app.post("/api/v1/patients", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
def create_patient(patient_data: PatientCreateRequest):
    """Crea un paciente, su email, perfil de salud, y cuenta de usuario."""
    result = create_patient_logic(patient_data)

    # Get created patient data
    patient_query = """
        SELECT
            p.id, p.doctor_id, p.institution_id, p.first_name, p.last_name,
            p.date_of_birth, p.sex_id, p.gender_id, p.emergency_contact_name,
            p.is_active, p.is_verified,
            e.email_address as contact_email,
            hp.height_cm, hp.weight_kg, hp.blood_type_id
        FROM patients p
        LEFT JOIN emails e ON e.entity_type = 'patient' AND e.entity_id = p.id AND e.is_primary = TRUE
        LEFT JOIN health_profiles hp ON hp.patient_id = p.id
        WHERE p.id = %s
    """
    patient_data_result = execute_query(patient_query, (result['id'],), fetch_one=True)

    return PatientResponse(
        id=patient_data_result['id'],
        doctor_id=patient_data_result['doctor_id'],
        institution_id=patient_data_result['institution_id'],
        first_name=patient_data_result['first_name'],
        last_name=patient_data_result['last_name'],
        date_of_birth=patient_data_result['date_of_birth'],
        sex_id=patient_data_result['sex_id'],
        gender_id=patient_data_result['gender_id'],
        emergency_contact_name=patient_data_result['emergency_contact_name'],
        is_active=patient_data_result['is_active'],
        is_verified=patient_data_result['is_verified'],
        contact_email=patient_data_result['contact_email'],
        health_profile={
            'height_cm': patient_data_result['height_cm'],
            'weight_kg': patient_data_result['weight_kg'],
            'blood_type_id': patient_data_result['blood_type_id']
        } if patient_data_result['height_cm'] is not None else None
    )

# ... (El resto de los endpoints CRUD permanecen igual)
@app.get("/api/v1/patients/{patient_id}", response_model=PatientResponse)
def get_patient(
    patient_id: str,
    x_user_id: str = Header(None),
    x_user_type: str = Header(None)
):
    # Verificar permisos de acceso
    if x_user_type == 'patient' and x_user_id != patient_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tienes permiso para ver este paciente.")

    # Query para obtener datos del paciente con JOINs
    query = """
        SELECT
            p.id, p.doctor_id, p.institution_id, p.first_name, p.last_name,
            p.date_of_birth, p.sex_id, p.gender_id, p.emergency_contact_name,
            p.is_active, p.is_verified,
            e.email_address as contact_email,
            hp.height_cm, hp.weight_kg, hp.blood_type_id
        FROM patients p
        LEFT JOIN emails e ON e.entity_type = 'patient' AND e.entity_id = p.id AND e.is_primary = TRUE
        LEFT JOIN health_profiles hp ON hp.patient_id = p.id
        WHERE p.id = %s AND p.is_active = TRUE
    """

    patient_data = execute_query(query, (patient_id,), fetch_one=True)

    if not patient_data:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")

    # Construir respuesta manualmente
    response = PatientResponse(
        id=patient_data['id'],
        doctor_id=patient_data['doctor_id'],
        institution_id=patient_data['institution_id'],
        first_name=patient_data['first_name'],
        last_name=patient_data['last_name'],
        date_of_birth=patient_data['date_of_birth'],
        sex_id=patient_data['sex_id'],
        gender_id=patient_data['gender_id'],
        emergency_contact_name=patient_data['emergency_contact_name'],
        is_active=patient_data['is_active'],
        is_verified=patient_data['is_verified'],
        contact_email=patient_data['contact_email'],
        health_profile={
            'height_cm': patient_data['height_cm'],
            'weight_kg': patient_data['weight_kg'],
            'blood_type_id': patient_data['blood_type_id']
        } if patient_data['height_cm'] is not None else None
    )

    return response

@app.get("/api/v1/patients", response_model=List[PatientResponse])
def list_patients(skip: int = 0, limit: int = 100):
    query = """
        SELECT
            p.id, p.doctor_id, p.institution_id, p.first_name, p.last_name,
            p.date_of_birth, p.sex_id, p.gender_id, p.emergency_contact_name,
            p.is_active, p.is_verified,
            e.email_address as contact_email,
            hp.height_cm, hp.weight_kg, hp.blood_type_id
        FROM patients p
        LEFT JOIN emails e ON e.entity_type = 'patient' AND e.entity_id = p.id AND e.is_primary = TRUE
        LEFT JOIN health_profiles hp ON hp.patient_id = p.id
        WHERE p.is_active = TRUE
        ORDER BY p.created_at DESC
        LIMIT %s OFFSET %s
    """
    patients_data = execute_query(query, (limit, skip), fetch_all=True)

    return [
        PatientResponse(
            id=p['id'],
            doctor_id=p['doctor_id'],
            institution_id=p['institution_id'],
            first_name=p['first_name'],
            last_name=p['last_name'],
            date_of_birth=p['date_of_birth'],
            sex_id=p['sex_id'],
            gender_id=p['gender_id'],
            emergency_contact_name=p['emergency_contact_name'],
            is_active=p['is_active'],
            is_verified=p['is_verified'],
            contact_email=p['contact_email'],
            health_profile={
                'height_cm': p['height_cm'],
                'weight_kg': p['weight_kg'],
                'blood_type_id': p['blood_type_id']
            } if p['height_cm'] is not None else None
        ) for p in patients_data
    ]

@app.put("/api/v1/patients/{patient_id}", response_model=PatientResponse)
def update_patient(patient_id: str, patient_update: PatientUpdateRequest):
    # Check if patient exists
    existing_patient = execute_query("SELECT id FROM patients WHERE id = %s AND is_active = TRUE", (patient_id,), fetch_one=True)
    if not existing_patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")

    # Build update query dynamically
    update_data = patient_update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No hay datos para actualizar.")

    set_clause = ", ".join([f"{key} = %s" for key in update_data.keys()])
    values = list(update_data.values()) + [patient_id]

    update_query = f"UPDATE patients SET {set_clause} WHERE id = %s"
    execute_query(update_query, values)

    # Return updated patient
    return get_patient(patient_id)

@app.delete("/api/v1/patients/{patient_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_patient(patient_id: str):
    # Check if patient exists
    existing_patient = execute_query("SELECT id FROM patients WHERE id = %s AND is_active = TRUE", (patient_id,), fetch_one=True)
    if not existing_patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")

    # Soft delete
    execute_query("UPDATE patients SET is_active = FALSE WHERE id = %s", (patient_id,))

# --- Endpoints Específicos para Dashboard ---

@app.get("/patients/{patient_id}/basic-info")
async def get_patient_basic_info(
    patient_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Retorna información básica del paciente para el dashboard."""
    try:
        # Verificar permisos de acceso
        require_patient_access(current_user, patient_id)

        # Obtener datos básicos del paciente
        query = """
            SELECT
                p.id,
                p.first_name,
                p.last_name,
                p.date_of_birth,
                EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth)) as age,
                s.display_name as biological_sex,
                g.display_name as gender_identity,
                e.email_address as primary_email,
                hp.height_cm,
                hp.weight_kg,
                hp.blood_type_id,
                bt.name as blood_type,
                hp.is_smoker,
                hp.consumes_alcohol,
                hp.physical_activity_minutes_weekly,
                d.first_name as doctor_first_name,
                d.last_name as doctor_last_name,
                ds.name as doctor_specialty,
                mi.name as institution_name
            FROM patients p
            LEFT JOIN sexes s ON p.sex_id = s.id
            LEFT JOIN genders g ON p.gender_id = g.id
            LEFT JOIN emails e ON e.entity_type = 'patient' AND e.entity_id = p.id AND e.is_primary = TRUE
            LEFT JOIN health_profiles hp ON hp.patient_id = p.id
            LEFT JOIN blood_types bt ON hp.blood_type_id = bt.id
            LEFT JOIN doctors d ON p.doctor_id = d.id
            LEFT JOIN doctor_specialties ds ON d.specialty_id = ds.id
            LEFT JOIN medical_institutions mi ON p.institution_id = mi.id
            WHERE p.id = %s AND p.is_active = TRUE
        """

        result = execute_query(query, (patient_id,), fetch_one=True)

        if not result:
            raise HTTPException(status_code=404, detail="Paciente no encontrado")

        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error obteniendo información básica para paciente {patient_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error obteniendo información básica: {str(e)}")

@app.get("/patients/{patient_id}/dashboard")
async def get_patient_dashboard(
    patient_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Retorna todos los datos necesarios para el dashboard del paciente."""
    try:
        # Verificar permisos de acceso
        require_patient_access(current_user, patient_id)

        # Información básica del paciente
        basic_info = await get_patient_basic_info(patient_id, current_user)

        # Medicamentos activos
        medications_query = """
            SELECT
                m.name,
                pm.dosage,
                pm.frequency
            FROM patient_medications pm
            JOIN medications m ON pm.medication_id = m.id
            WHERE pm.patient_id = %s
        """
        medications = execute_query(medications_query, (patient_id,), fetch_all=True)

        # Próximas citas (placeholder - tabla no existe aún)
        appointments = []  # TODO: Implementar tabla de citas

        # Condiciones médicas
        conditions_query = """
            SELECT
                mc.name,
                pc.diagnosis_date,
                pc.notes
            FROM patient_conditions pc
            JOIN medical_conditions mc ON pc.condition_id = mc.id
            WHERE pc.patient_id = %s
        """
        conditions = execute_query(conditions_query, (patient_id,), fetch_all=True)

        # Calcular puntuación de salud (lógica simplificada)
        health_score = calculate_health_score(basic_info, conditions, medications)

        return {
            "patient": basic_info,
            "health_score": health_score,
            "medications": medications,
            "appointments": appointments,
            "conditions": conditions,
            "recent_activity": []  # TODO: Implementar actividad reciente
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error obteniendo dashboard para paciente {patient_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error obteniendo dashboard: {str(e)}")

def calculate_health_score(patient_info: Dict, conditions: List, medications: List) -> int:
    """Calcula una puntuación de salud básica (0-100)."""
    score = 100

    # Penalizar por condiciones médicas
    score -= len(conditions) * 10

    # Penalizar por medicamentos (más medicación = más condiciones)
    score -= len(medications) * 5

    # Penalizar por tabaquismo
    if patient_info.get('is_smoker'):
        score -= 15

    # Penalizar por consumo de alcohol
    if patient_info.get('consumes_alcohol'):
        score -= 10

    # Bonificar por actividad física
    activity = patient_info.get('physical_activity_minutes_weekly', 0)
    if activity >= 150:  # Recomendación semanal
        score += 10
    elif activity >= 75:
        score += 5

    return max(0, min(100, score))

@app.get("/patients/{patient_id}/medical-record")
async def get_patient_medical_record(
    patient_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Retorna el expediente médico completo del paciente."""
    try:
        # Verificar permisos de acceso
        require_patient_access(current_user, patient_id)

        # Perfil de salud
        health_profile_query = """
            SELECT
                height_cm,
                weight_kg,
                blood_type_id,
                bt.name as blood_type,
                is_smoker,
                smoking_years,
                consumes_alcohol,
                alcohol_frequency,
                physical_activity_minutes_weekly,
                notes
            FROM health_profiles hp
            LEFT JOIN blood_types bt ON hp.blood_type_id = bt.id
            WHERE hp.patient_id = %s
        """
        health_profile = execute_query(health_profile_query, (patient_id,), fetch_one=True)

        # Condiciones médicas
        conditions_query = """
            SELECT
                mc.name,
                pc.diagnosis_date,
                pc.notes
            FROM patient_conditions pc
            JOIN medical_conditions mc ON pc.condition_id = mc.id
            WHERE pc.patient_id = %s
            ORDER BY pc.diagnosis_date DESC
        """
        conditions = execute_query(conditions_query, (patient_id,), fetch_all=True)

        # Medicamentos
        medications_query = """
            SELECT
                m.name,
                pm.dosage,
                pm.frequency,
                pm.start_date
            FROM patient_medications pm
            JOIN medications m ON pm.medication_id = m.id
            WHERE pm.patient_id = %s
            ORDER BY pm.start_date DESC
        """
        medications = execute_query(medications_query, (patient_id,), fetch_all=True)

        # Alergias
        allergies_query = """
            SELECT
                a.name,
                pa.severity,
                pa.reaction_description
            FROM patient_allergies pa
            JOIN allergies a ON pa.allergy_id = a.id
            WHERE pa.patient_id = %s
        """
        allergies = execute_query(allergies_query, (patient_id,), fetch_all=True)

        # Historial familiar
        family_history_query = """
            SELECT
                mc.name as condition_name,
                pfh.relative_type,
                pfh.notes
            FROM patient_family_history pfh
            JOIN medical_conditions mc ON pfh.condition_id = mc.id
            WHERE pfh.patient_id = %s
        """
        family_history = execute_query(family_history_query, (patient_id,), fetch_all=True)

        return {
            "health_profile": health_profile,
            "conditions": conditions,
            "medications": medications,
            "allergies": allergies,
            "family_history": family_history
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error obteniendo expediente médico para paciente {patient_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error obteniendo expediente médico: {str(e)}")

@app.get("/patients/{patient_id}/care-team")
async def get_patient_care_team(
    patient_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Retorna información del equipo médico del paciente."""
    try:
        # Verificar permisos de acceso
        require_patient_access(current_user, patient_id)

        query = """
            SELECT
                -- Información del Doctor
                d.id as doctor_id,
                d.first_name as doctor_first_name,
                d.last_name as doctor_last_name,
                d.medical_license,
                d.years_experience,
                d.consultation_fee,
                ds.name as doctor_specialty,
                dsc.name as specialty_category,

                -- Información de la Institución
                mi.id as institution_id,
                mi.name as institution_name,
                mi.license_number,
                it.name as institution_type,
                mi.website,

                -- Contacto del Doctor
                de.email_address as doctor_email,
                dp.phone_number as doctor_phone,

                -- Contacto de la Institución
                ie.email_address as institution_email,
                ip.phone_number as institution_phone,

                -- Dirección de la Institución
                addr.street_address,
                addr.city,
                r.name as region_name,
                c.name as country_name,
                addr.postal_code

            FROM patients p
            INNER JOIN doctors d ON p.doctor_id = d.id
            LEFT JOIN doctor_specialties ds ON d.specialty_id = ds.id
            LEFT JOIN specialty_categories dsc ON ds.category_id = dsc.id
            INNER JOIN medical_institutions mi ON p.institution_id = mi.id
            LEFT JOIN institution_types it ON mi.institution_type_id = it.id

            -- Contactos del doctor
            LEFT JOIN emails de ON de.entity_type = 'doctor' AND de.entity_id = d.id AND de.is_primary = TRUE
            LEFT JOIN phones dp ON dp.entity_type = 'doctor' AND dp.entity_id = d.id AND dp.is_primary = TRUE

            -- Contactos de la institución
            LEFT JOIN emails ie ON ie.entity_type = 'institution' AND ie.entity_id = mi.id AND ie.is_primary = TRUE
            LEFT JOIN phones ip ON ip.entity_type = 'institution' AND ip.entity_id = mi.id AND ip.is_primary = TRUE

            -- Dirección de la institución
            LEFT JOIN addresses addr ON addr.entity_type = 'institution' AND addr.entity_id = mi.id AND addr.is_primary = TRUE
            LEFT JOIN regions r ON addr.region_id = r.id
            LEFT JOIN countries c ON addr.country_id = c.id

            WHERE p.id = %s AND p.is_active = TRUE
        """

        result = execute_query(query, (patient_id,), fetch_one=True)

        if not result:
            raise HTTPException(status_code=404, detail="Equipo médico no encontrado")

        return {
            "doctor": {
                "id": result['doctor_id'],
                "first_name": result['doctor_first_name'],
                "last_name": result['doctor_last_name'],
                "medical_license": result['medical_license'],
                "years_experience": result['years_experience'],
                "consultation_fee": float(result['consultation_fee']) if result['consultation_fee'] else None,
                "specialty": result['doctor_specialty'],
                "specialty_category": result['specialty_category'],
                "email": result['doctor_email'],
                "phone": result['doctor_phone']
            },
            "institution": {
                "id": result['institution_id'],
                "name": result['institution_name'],
                "license_number": result['license_number'],
                "type": result['institution_type'],
                "website": result['website'],
                "email": result['institution_email'],
                "phone": result['institution_phone'],
                "address": {
                    "street": result['street_address'],
                    "city": result['city'],
                    "region": result['region_name'],
                    "country": result['country_name'],
                    "postal_code": result['postal_code']
                } if result['street_address'] else None
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error obteniendo equipo médico para paciente {patient_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error obteniendo equipo médico: {str(e)}")

@app.get("/health")
def health_check():
    return {"status": "healthy"}
