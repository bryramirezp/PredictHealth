# /backend-flask\app\api\v1\web_controller.py
# Controller for JSON endpoints /api/web

from flask import Blueprint, request, jsonify, g
from flask import current_app
import logging
import requests
import json
import re
import psycopg2
import psycopg2.extras
from datetime import datetime, timedelta

from app.services.proxy_service import ProxyService
from app.middleware import require_auth, get_current_user, is_authenticated
from app.middleware.jwt_middleware import jwt_middleware
from app.db import get_db_connection

logger = logging.getLogger(__name__)

def validate_password_strength(password: str) -> tuple[bool, str]:
    """
    Validate password strength
    
    Args:
        password: Password to validate
        
    Returns:
        tuple: (is_valid, error_message)
    """
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    
    if not any(c.isupper() for c in password):
        return False, "Password must contain at least one uppercase letter"
    
    if not any(c.islower() for c in password):
        return False, "Password must contain at least one lowercase letter"
    
    if not any(c.isdigit() for c in password):
        return False, "Password must contain at least one number"
    
    return True, ""

# Crear blueprint para endpoints web
web_bp = Blueprint('web', __name__, url_prefix='/api/web')

# Instancia del proxy service
proxy_service = ProxyService()

class WebController:
    """Controlador para endpoints JSON /api/web"""
    
    def __init__(self):
        self.proxy_service = proxy_service
    
    def _handle_auth_error(self, error_message: str, status_code: int = 400) -> tuple:
        """Maneja errores de autenticación"""
        return jsonify({
            "status": "error",
            "message": error_message,
            "code": status_code
        }), status_code
    
    def _handle_success(self, data: dict, message: str = "Success") -> tuple:
        """Maneja respuestas exitosas"""
        return jsonify({
            "status": "success",
            "message": message,
            "data": data
        }), 200

# Instancia del controlador
web_controller = WebController()

# Password validation functions
def validate_password_strength(password: str) -> tuple[bool, str]:
    """
    Validate password strength
    Returns (is_valid, error_message)
    """
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"

    if not bool(re.search(r'[A-Z]', password)):
        return False, "Password must contain at least one uppercase letter"

    if not bool(re.search(r'[a-z]', password)):
        return False, "Password must contain at least one lowercase letter"

    if not bool(re.search(r'\d', password)):
        return False, "Password must contain at least one number"

    if not bool(re.search(r'[!@#$%^&*(),.?":{}|<>]', password)):
        return False, "Password must contain at least one special character"

    return True, ""


# ============================================================================
# ENDPOINTS DE AUTENTICACIÓN POR TIPO DE USUARIO
# ============================================================================

@web_bp.route('/auth/login', methods=['POST'])
def generic_login():
    """Endpoint genérico que usa el servicio JWT para determinar tipo de usuario automáticamente"""
    try:
        login_data = request.get_json()

        if not login_data:
            return web_controller._handle_auth_error("Datos JSON requeridos")

        email = login_data.get('email')
        password = login_data.get('password')

        if not email or not password:
            return web_controller._handle_auth_error("Email y password son requeridos")

        # Preparar datos para servicio JWT (sin especificar user_type - el servicio lo determina)
        auth_data = {
            "email": email,
            "password": password
        }

        # Call JWT service for authentication (determina user_type automáticamente)
        auth_response = web_controller.proxy_service.call_jwt_service(
            "POST", "/auth/login", auth_data
        )

        # Obtener access_token y access_token_id del servicio JWT
        access_token = auth_response['data'].get("access_token")
        access_token_id = auth_response['data'].get("access_token_id")

        if auth_response.get('status_code') == 200:
            # Verificar que tenemos tanto el token como su ID
            if not access_token or not access_token_id:
                logger.error("❌ Auth-JWT Service did not provide access_token or access_token_id")
                return web_controller._handle_auth_error("Token creation failed", 503)

            # Responder con cookie HTTP-only usando solo el token_id (UUID)
            from flask import make_response
            resp = make_response(web_controller._handle_success({
                "user_id": auth_response['data']['user_id'],
                "user_type": auth_response['data']['user_type'],  # El servicio JWT determina esto
                "access_token": access_token,
                "expires_in": auth_response['data']['expires_in']
            }, "Login exitoso"))

            # Cookie segura con el JWT completo
            resp.set_cookie(
                'predicthealth_session',
                access_token,  # ← JWT completo en la cookie
                httponly=True,
                secure=False,  # True en producción con HTTPS
                samesite='Strict',
                max_age=15*60  # 15 minutos (expiración del token)
            )

            logger.info(f"✅ Login successful, session cookie set")
            return resp
        else:
            return web_controller._handle_auth_error(
                auth_response.get('message', 'Error de autenticación'),
                auth_response.get('status_code', 401)
            )

    except Exception as e:
        logger.error(f"Error en generic_login: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/auth/session/validate', methods=['GET'])
def validate_session():
    """Validar sesión JWT activa"""
    try:
        # Obtener token de la cookie
        token = request.cookies.get('predicthealth_session')

        if not token:
            return web_controller._handle_auth_error("No active session", 401)

        # Validar token usando el middleware JWT
        session_data = jwt_middleware.validate_session(token)
        if not session_data:
            return web_controller._handle_auth_error("Token expired or invalid", 401)

        response_data = {
            "valid": True,
            "user": {
                "user_id": session_data["user_id"],
                "user_type": session_data["user_type"],
                "email": session_data["email"]
            }
        }
        return web_controller._handle_success(response_data)

    except Exception as e:
        logger.error(f"Error en validate_session: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)


@web_bp.route('/auth/patient/login', methods=['POST'])
def patient_login():
    """Login endpoint for patients"""
    try:
        # Read JSON payload
        login_data = request.get_json()
        
        if not login_data:
            return web_controller._handle_auth_error("JSON body required")

        # Validate required fields
        if not login_data.get('email') or not login_data.get('password'):
            return web_controller._handle_auth_error("Email and password are required")

        # Preparar datos para servicio de auth
        auth_data = {
            "email": login_data['email'],
            "password": login_data['password'],
            "user_type": "patient"
        }

        # Call patients service for authentication
        auth_response = web_controller.proxy_service.call_patients_service(
            "POST", "/auth/login", auth_data
        )

        if auth_response.get('status_code') == 200:
            # Successful login
            response_data = {
                "user_id": auth_response['data']['user_id'],
                "user_type": "patient",
                "access_token": auth_response['data']['access_token'],
                "expires_in": auth_response['data']['expires_in']
            }
            return web_controller._handle_success(response_data, "Login successful")
        else:
            return web_controller._handle_auth_error(
                auth_response.get('message', 'Authentication error'),
                auth_response.get('status_code', 401)
            )

    except Exception as e:
        logger.error(f"Error in patient_login: {str(e)}")
        return web_controller._handle_auth_error(f"Internal error: {str(e)}", 500)

@web_bp.route('/auth/doctor/login', methods=['POST'])
def doctor_login():
    """Endpoint de login para doctores"""
    try:
        # Obtener datos JSON de entrada
        login_data = request.get_json()
        
        if not login_data:
            return web_controller._handle_auth_error("Datos JSON requeridos")

        # Validar datos requeridos
        if not login_data.get('email') or not login_data.get('password'):
            return web_controller._handle_auth_error("Email y password son requeridos")

        # Preparar datos para servicio de auth
        auth_data = {
            "email": login_data['email'],
            "password": login_data['password'],
            "user_type": "doctor"
        }

        # Call doctors service for authentication
        auth_response = web_controller.proxy_service.call_doctors_service(
            "POST", "/auth/login", auth_data
        )

        if auth_response.get('status_code') == 200:
            # Login exitoso
            response_data = {
                "user_id": auth_response['data']['user_id'],
                "user_type": "doctor",
                "access_token": auth_response['data']['access_token'],
                "expires_in": auth_response['data']['expires_in']
            }
            return web_controller._handle_success(response_data, "Login exitoso")
        else:
            return web_controller._handle_auth_error(
                auth_response.get('message', 'Error en autenticación'),
                auth_response.get('status_code', 401)
            )

    except Exception as e:
        logger.error(f"Error en doctor_login: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/auth/institution/login', methods=['POST'])
# @require_auth()  # Commented out for testing
def institution_login():
    """Endpoint de login para instituciones - Acepta JSON del frontend web"""
    try:
        # Obtener datos JSON de entrada
        login_data = request.get_json()
        
        if not login_data:
            return web_controller._handle_auth_error("Datos JSON requeridos")
        
        logger.info(f"📥 JSON recibido: {login_data}")

        # Validar datos requeridos
        if not login_data.get('email') or not login_data.get('password'):
            return web_controller._handle_auth_error("Email y password son requeridos")

        # Preparar datos para servicio de auth
        auth_data = {
            "email": login_data['email'],
            "password": login_data['password'],
            "user_type": "institution"
        }

        # Call institutions service for authentication
        auth_response = web_controller.proxy_service.call_institutions_service(
            "POST", "/auth/login", auth_data
        )

        if auth_response.get('status_code') == 200:
            # Login exitoso
            response_data = {
                "user_id": auth_response['data']['user_id'],
                "user_type": "institution",
                "access_token": auth_response['data']['access_token'],
                "expires_in": auth_response['data']['expires_in']
            }
            logger.info("✅ Login de institución exitoso")
            return web_controller._handle_success(response_data, "Login exitoso")
        else:
            logger.error(f"❌ Error en autenticación de institución: {auth_response.get('message', 'Error desconocido')}")
            return web_controller._handle_auth_error(
                auth_response.get('message', 'Error en autenticación'),
                auth_response.get('status_code', 401)
            )

    except Exception as e:
        logger.error(f"❌ Error en institution_login: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)


# ============================================================================
# ENDPOINTS DE DASHBOARD POR TIPO DE USUARIO
# ============================================================================

@web_bp.route('/patient/dashboard', methods=['GET'])
def patient_dashboard():
    """Dashboard para pacientes"""
    try:
        # Obtener usuario actual (comentado para testing)
        # current_user = get_current_user()
        # user_id = current_user['user_id']
        user_id = "test-user-id"  # Mock para testing
        
        # Obtener datos del paciente por email
        patient_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/patients/", headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )
        
        # Filtrar por email del usuario actual (mock para testing)
        patient_data = None
        if patient_response.get('status_code') == 200:
            patients = patient_response['data'].get('patients', [])
            user_email = "test@example.com"  # Mock email para testing
            patient_data = next((patient for patient in patients if patient.get('email') == user_email), None)
        
        if patient_data:
            # Preparar datos para respuesta
            dashboard_data = {
                "patient": patient_data,
                "appointments": [],
                "medications": [],
                "alerts": [],
                "statistics": {
                    "total_appointments": 0,
                    "total_medications": 0,
                    "total_alerts": 0,
                    "health_score": 85
                }
            }
            
            # Devolver JSON
            return jsonify({
                "status": "success",
                "message": "Dashboard del paciente",
                "data": dashboard_data
            }), 200
        else:
            return web_controller._handle_auth_error(
                "Paciente no encontrado para el usuario actual",
                404
            )
            
    except Exception as e:
        logger.error(f"Error en patient_dashboard: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/doctor/dashboard', methods=['GET'])
def doctor_dashboard():
    """Dashboard para doctores"""
    try:
        # Obtener usuario actual (comentado para testing)
        # current_user = get_current_user()
        # user_id = current_user['user_id']
        user_id = "test-user-id"  # Mock para testing
        
        # Obtener datos del doctor por email
        doctor_response = web_controller.proxy_service.call_doctors_service(
            "GET", f"/api/v1/doctors/", headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )
        
        # Filtrar por email del usuario actual (mock para testing)
        doctor_data = None
        if doctor_response.get('status_code') == 200:
            doctors = doctor_response['data'].get('doctors', [])
            user_email = "test@example.com"  # Mock email para testing
            doctor_data = next((doctor for doctor in doctors if doctor.get('email') == user_email), None)
        
        if doctor_data:
            # Preparar datos para respuesta
            dashboard_data = {
                "doctor": doctor_data,
                "patients": [],
                "appointments": [],
                "reviews": [],
                "statistics": {
                    "total_patients": 0,
                    "total_appointments": 0,
                    "total_reviews": 0,
                    "available_hours": 8
                }
            }
            
            # Devolver JSON
            return jsonify({
                "status": "success",
                "message": "Dashboard del doctor",
                "data": dashboard_data
            }), 200
        else:
            return web_controller._handle_auth_error(
                "Doctor no encontrado para el usuario actual",
                404
            )
            
    except Exception as e:
        logger.error(f"Error en doctor_dashboard: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/institution/dashboard', methods=['GET'])
@require_auth(required_user_type='institution')
def institution_dashboard():
    """Dashboard para instituciones"""
    try:
        # Obtener usuario actual
        current_user = get_current_user()
        user_id = current_user['user_id']

        # Log headers para debugging
        accept_header = request.headers.get('Accept', '')
        content_type = request.headers.get('Content-Type', '')
        logger.info(f"🔍 Dashboard request - Accept: '{accept_header}', Content-Type: '{content_type}'")

        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # Obtener datos de la institución
                cur.execute("""
                    SELECT mi.*, it.name as institution_type_name
                    FROM medical_institutions mi
                    JOIN institution_types it ON mi.institution_type_id = it.id
                    WHERE mi.id = %s AND mi.is_active = TRUE
                """, (user_id,))
                institution_data = cur.fetchone()

                if not institution_data:
                    return web_controller._handle_auth_error(
                        "Institución no encontrada para el usuario actual",
                        404
                    )

                # Obtener doctores de la institución
                cur.execute("""
                    SELECT id, first_name, last_name, email, specialty, years_experience, consultation_fee
                    FROM doctors
                    WHERE institution_id = %s AND is_active = TRUE
                """, (user_id,))
                doctors = [dict(row) for row in cur.fetchall()]

                # Obtener pacientes de la institución
                cur.execute("""
                    SELECT id, first_name, last_name, email, doctor_id, created_at
                    FROM patients
                    WHERE institution_id = %s AND is_active = TRUE
                """, (user_id,))
                patients = [dict(row) for row in cur.fetchall()]

                # Enriquecer pacientes con nombres de doctores
                for patient in patients:
                    if patient['doctor_id']:
                        cur.execute("""
                            SELECT first_name, last_name
                            FROM doctors
                            WHERE id = %s
                        """, (patient['doctor_id'],))
                        doctor = cur.fetchone()
                        if doctor:
                            patient['doctor_name'] = f"Dr. {doctor['first_name']} {doctor['last_name']}"

                # Preparar datos para respuesta
                dashboard_data = {
                    "institution": dict(institution_data),
                    "doctors": doctors,
                    "patients": patients,
                    "statistics": {
                        "total_doctors": len(doctors),
                        "total_patients": len(patients),
                        "active_appointments": 0,
                        "pending_reviews": 0
                    }
                }

                # Devolver JSON
                logger.info("📤 Devolviendo respuesta JSON")
                return jsonify({
                    "status": "success",
                    "message": "Dashboard de la institución",
                    "data": dashboard_data
                }), 200

    except Exception as e:
        logger.error(f"Error en institution_dashboard: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)






# ============================================================================
# ENDPOINTS DE INSTITUCIONES (GESTIÓN DESDE LA INSTITUCIÓN)
# ============================================================================

@web_bp.route('/institution/doctors', methods=['GET'])
@require_auth(required_user_type='institution')
def institution_get_doctors():
    """Obtiene los doctores de la institución - Respuesta JSON"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        user_id = current_user['user_id']

        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # Obtener doctores de la institución
                cur.execute("""
                    SELECT id, first_name, last_name, email, specialty, years_experience,
                           consultation_fee, is_active, created_at
                    FROM doctors
                    WHERE institution_id = %s
                    ORDER BY last_name, first_name
                """, (user_id,))
                doctors = [dict(row) for row in cur.fetchall()]

                # Calcular estadísticas
                total_doctors = len(doctors)
                active_doctors = len([d for d in doctors if d['is_active']])
                inactive_doctors = total_doctors - active_doctors

                stats = {
                    "total_doctors": total_doctors,
                    "active_doctors": active_doctors,
                    "inactive_doctors": inactive_doctors
                }

                # Preparar respuesta JSON
                return jsonify({
                    "status": "success",
                    "message": "Doctores obtenidos exitosamente",
                    "doctors": doctors,
                    "stats": stats
                }), 200

    except Exception as e:
        logger.error(f"Error en institution_get_doctors: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/institution/doctors', methods=['POST'])
@require_auth(required_user_type='institution')
def institution_create_doctor():
    """
    Crea un nuevo doctor con cuenta completa para la institución - Input JSON
    """
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        user_id = current_user['user_id']

        # Obtener datos JSON del request
        doctor_data = request.get_json()

        if not doctor_data:
            return web_controller._handle_auth_error("Datos del doctor requeridos", 400)

        # Validar campos requeridos
        required_fields = ['nombre', 'apellido', 'email', 'licencia_medica', 'password', 'confirm_password']
        for field in required_fields:
            if not doctor_data.get(field):
                return web_controller._handle_auth_error(f"Campo requerido: {field}", 400)

        # Validar que las contraseñas coincidan
        if doctor_data['password'] != doctor_data['confirm_password']:
            return web_controller._handle_auth_error("Las contraseñas no coinciden", 400)

        # Validar fortaleza de contraseña
        password_valid, password_error = validate_password_strength(doctor_data['password'])
        if not password_valid:
            return web_controller._handle_auth_error(password_error, 400)

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                try:
                    # Paso 1: Crear el doctor en la base de datos
                    cur.execute("""
                        INSERT INTO doctors (first_name, last_name, email, medical_license,
                                         institution_id, specialty, years_experience, consultation_fee)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        RETURNING id
                    """, (
                        doctor_data['nombre'],
                        doctor_data['apellido'],
                        doctor_data['email'],
                        doctor_data['licencia_medica'],
                        user_id,
                        doctor_data.get('especialidad'),
                        doctor_data.get('years_experience', 0),
                        doctor_data.get('consultation_fee', 0)
                    ))
                    doctor_id = cur.fetchone()[0]

                    # Paso 2: Crear usuario para autenticación
                    cur.execute("""
                        INSERT INTO users (email, password_hash, user_type, reference_id)
                        VALUES (%s, %s, 'doctor', %s)
                    """, (
                        doctor_data['email'],
                        doctor_data['password'],  # En producción, esto debería estar hasheado
                        doctor_id
                    ))

                    # Paso 3: Crear email primario
                    cur.execute("""
                        INSERT INTO emails (entity_type, entity_id, email_address, is_primary, email_type_id)
                        VALUES ('doctor', %s, %s, TRUE, (SELECT id FROM email_types WHERE name = 'primary'))
                    """, (doctor_id, doctor_data['email']))

                    conn.commit()
                    logger.info(f"✅ Doctor creado exitosamente: {doctor_data['email']} (ID: {doctor_id})")

                    # Respuesta exitosa
                    response_data = {
                        "status": "success",
                        "message": "Doctor creado exitosamente",
                        "doctor": {
                            "id": doctor_id,
                            "nombre": doctor_data['nombre'],
                            "apellido": doctor_data['apellido'],
                            "email": doctor_data['email'],
                            "licencia_medica": doctor_data['licencia_medica'],
                            "especialidad": doctor_data.get('especialidad'),
                            "activo": True
                        }
                    }
                    return jsonify(response_data), 201

                except psycopg2.errors.UniqueViolation:
                    conn.rollback()
                    return web_controller._handle_auth_error("El email o licencia médica ya existe", 409)
                except Exception as db_error:
                    conn.rollback()
                    logger.error(f"❌ Error en base de datos creando doctor: {str(db_error)}")
                    return web_controller._handle_auth_error("Error al crear doctor en base de datos", 500)

    except Exception as e:
        logger.error(f"❌ Error en institution_create_doctor: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/institution/doctors/<doctor_id>', methods=['DELETE'])
def institution_delete_doctor(doctor_id):
    """Elimina un doctor de la institución - Respuesta JSON"""
    try:
        # current_user = get_current_user()  # Commented out for testing
        # user_id = current_user['user_id']
        user_id = "test-user-id"  # Mock para testing

        # Verificar que el doctor pertenece a la institución
        doctor_response = web_controller.proxy_service.call_doctors_service(
            "GET", f"/api/v1/doctors/{doctor_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if doctor_response.get('status_code') != 200:
            return web_controller._handle_auth_error("Doctor no encontrado", 404)

        doctor_data = doctor_response.get('data', {})
        if doctor_data.get('id_institucion') != user_id:
            return web_controller._handle_auth_error("No tienes permisos para eliminar este doctor", 403)

        # Eliminar doctor
        delete_response = web_controller.proxy_service.call_doctors_service(
            "DELETE", f"/api/v1/doctors/{doctor_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if delete_response.get('status_code') == 200:
            response_data = {
                "status": "success",
                "message": "Doctor eliminado exitosamente"
            }
            return jsonify(response_data), 200
        else:
            return web_controller._handle_auth_error("Error al eliminar doctor", delete_response.get('status_code', 500))

    except Exception as e:
        logger.error(f"Error en institution_delete_doctor: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/institution/patients', methods=['GET'])
@require_auth(required_user_type='institution')
def institution_get_patients():
    """Obtiene los pacientes de la institución"""
    try:
        current_user = get_current_user()
        user_id = current_user['user_id']
        
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # Obtener pacientes de la institución con información del doctor
                cur.execute("""
                    SELECT p.id, p.first_name, p.last_name, p.email, p.doctor_id,
                           p.created_at, p.is_active,
                           d.first_name as doctor_first_name, d.last_name as doctor_last_name,
                           EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth)) as age
                    FROM patients p
                    LEFT JOIN doctors d ON p.doctor_id = d.id
                    WHERE p.institution_id = %s
                    ORDER BY p.last_name, p.first_name
                """, (user_id,))
                patients = [dict(row) for row in cur.fetchall()]
                
                # Enriquecer datos con nombres completos de doctores
                enriched_patients = []
                for patient in patients:
                    patient_dict = dict(patient)
                    if patient['doctor_first_name'] and patient['doctor_last_name']:
                        patient_dict['doctor_name'] = f"Dr. {patient['doctor_first_name']} {patient['doctor_last_name']}"
                    else:
                        patient_dict['doctor_name'] = 'Sin asignar'
                    
                    # Agregar campos adicionales para el frontend
                    patient_dict['ultima_visita'] = patient['created_at']  # Mock para testing
                    patient_dict['risk_score'] = 50  # Mock para testing
                    patient_dict['estado_validacion'] = 'full_access' if patient['is_active'] else 'pending'
                    
                    enriched_patients.append(patient_dict)
                
                # Calcular estadísticas
                total_patients = len(enriched_patients)
                active_patients = len([p for p in enriched_patients if p['estado_validacion'] == 'full_access'])
                high_risk = len([p for p in enriched_patients if p.get('risk_score', 0) >= 70])
                
                # Calcular nuevos este mes
                month_ago = datetime.now() - timedelta(days=30)
                new_this_month = len([p for p in enriched_patients if p['created_at'] >= month_ago])
                
                stats = {
                    "total_patients": total_patients,
                    "active_patients": active_patients,
                    "high_risk": high_risk,
                    "new_this_month": new_this_month
                }
                
                return jsonify({
                    "status": "success",
                    "message": "Pacientes obtenidos exitosamente",
                    "patients": enriched_patients,
                    "stats": stats
                }), 200
           
    except Exception as e:
        logger.error(f"Error en institution_get_patients: {str(e)}")
        return jsonify({
            "status": "error",
            "message": "Error interno del servidor"
        }), 500

@web_bp.route('/institution/patients/stats', methods=['GET'])
def institution_get_patient_stats():
    """Obtiene estadísticas de pacientes de la institución"""
    try:
        current_user = get_current_user()
        user_id = current_user['user_id']
        
        # Obtener pacientes de la institución
        patients_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/pacientes?id_institucion={user_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )
        
        if patients_response.get('status_code') == 200:
            patients_data = patients_response.get('data', {}).get('patients', [])
            
            # Calcular estadísticas
            total_patients = len(patients_data)
            active_patients = len([p for p in patients_data if p.get('estado_validacion') == 'full_access'])
            high_risk = len([p for p in patients_data if p.get('risk_score', 0) >= 70])
            
            # Calcular nuevos este mes
            from datetime import datetime, timedelta
            current_date = datetime.now()
            month_ago = current_date - timedelta(days=30)
            new_this_month = 0
            
            for patient in patients_data:
                if patient.get('fecha_creacion'):
                    patient_date = datetime.fromisoformat(patient['fecha_creacion'].replace('Z', '+00:00'))
                    if patient_date >= month_ago:
                        new_this_month += 1
            
            stats = {
                "total_patients": total_patients,
                "active_patients": active_patients,
                "high_risk": high_risk,
                "new_this_month": new_this_month
            }
            
            return jsonify({
                "status": "success",
                "message": "Estadísticas obtenidas exitosamente",
                **stats
            }), 200
        else:
            return jsonify({
                "status": "error",
                "message": "Error al obtener estadísticas"
            }), patients_response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"Error en institution_get_patient_stats: {str(e)}")
        return jsonify({
            "status": "error",
            "message": "Error interno del servidor"
        }), 500



# ============================================================================
# ENDPOINTS DE DASHBOARD Y ESTADÍSTICAS GENERALES
# ============================================================================

@web_bp.route('/contact', methods=['POST'])
def submit_contact_form():
    """Endpoint para procesar formularios de contacto"""
    try:
        # Obtener datos JSON del request
        contact_data = request.get_json()

        if not contact_data:
            return web_controller._handle_auth_error("Datos del formulario requeridos", 400)

        # Validar campos requeridos
        required_fields = ['name', 'email', 'message']
        for field in required_fields:
            if not contact_data.get(field):
                return web_controller._handle_auth_error(f"Campo requerido: {field}", 400)

        # Validar formato de email
        import re
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, contact_data['email']):
            return web_controller._handle_auth_error("Formato de email inválido", 400)

        # Aquí puedes agregar lógica para:
        # - Enviar email
        # - Guardar en base de datos
        # - Integrar con sistema de tickets
        # - Notificar a administradores

        # Por ahora, solo logueamos y devolvemos éxito
        logger.info(f"📧 Nuevo mensaje de contacto recibido:")
        logger.info(f"   Nombre: {contact_data['name']}")
        logger.info(f"   Email: {contact_data['email']}")
        logger.info(f"   Teléfono: {contact_data.get('phone', 'No proporcionado')}")
        logger.info(f"   Mensaje: {contact_data['message']}")

        # Preparar respuesta
        response_data = {
            "message_id": f"contact_{int(request.json.get('timestamp', 0))}",
            "status": "received",
            "estimated_response": "24 horas"
        }

        return web_controller._handle_success(response_data, "Mensaje enviado exitosamente")

    except Exception as e:
        logger.error(f"Error en submit_contact_form: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/health', methods=['GET'])
def health_check():
    """Endpoint de salud para el servicio web"""
    health_data = {
        "status": "healthy",
        "service": "web-controller",
        "version": "1.0.0",
        "endpoints": [
            "/api/web/auth/patient/login",
            "/api/web/auth/doctor/login",
            "/api/web/auth/institution/login",
            "/api/web/auth/admin/login",
            "/api/web/patient/dashboard",
            "/api/web/doctor/dashboard",
            "/api/web/institution/dashboard",
            "/api/web/contact",
            "/api/web/auth/verify"
        ]
    }
    return web_controller._handle_success(health_data, "Servicio web funcionando correctamente")
