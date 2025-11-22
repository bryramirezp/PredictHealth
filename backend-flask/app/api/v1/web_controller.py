# /backend-flask\app\api\v1\web_controller.py
# Controller for JSON endpoints /api/web

from flask import Blueprint, request, jsonify, g
from flask import current_app
import logging
import requests
import json
import re
from datetime import datetime, timedelta

from app.services.proxy_service import ProxyService
from app.middleware import require_auth, get_current_user, is_authenticated
from app.middleware.jwt_middleware import jwt_middleware, store_jwt_token

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

        # Obtener access_token del servicio JWT
        access_token = auth_response['data'].get("access_token")

        if auth_response.get('status_code') == 200:
            # Verificar que tenemos el token
            if not access_token:
                logger.error("❌ Auth-JWT Service did not provide access_token")
                return web_controller._handle_auth_error("Token creation failed", 503)

            # Store JWT token in Redis before setting cookie
            expires_in = auth_response['data'].get('expires_in', 900)  # Default 15 minutes
            if not store_jwt_token(access_token, expires_in):
                logger.error("❌ Failed to store JWT token in Redis")
                return web_controller._handle_auth_error("Session storage failed", 503)

            # Responder con cookie HTTP-only usando solo el token_id (UUID)
            from flask import make_response
            resp = make_response(web_controller._handle_success({
                "user_id": auth_response['data']['user_id'],
                "user_type": auth_response['data']['user_type'],  # El servicio JWT determina esto
                "access_token": access_token,
                "expires_in": expires_in
            }, "Login exitoso"))

            # Cookie segura con el JWT completo
            resp.set_cookie(
                'predicthealth_jwt',  # ← Cookie name matching frontend
                access_token,  # ← JWT completo en la cookie
                httponly=True,
                secure=False,  # True en producción con HTTPS
                samesite='Lax',  # ← LA CLAVE! 'Strict' fallará con cross-origin
                path='/',  # ← Asegurar que la cookie esté disponible en todo el sitio
                max_age=expires_in  # Usar expires_in del servicio JWT
            )
            
            logger.info(f"✅ Cookie set with path=/, max_age={expires_in}, token length={len(access_token)}")

            logger.info(f"✅ Login successful, session cookie set and token stored in Redis")
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
    """Validar sesión JWT activa (acepta token en header Authorization o cookie)"""
    try:
        # Obtener token del header Authorization o cookie
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request()

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


@web_bp.route('/auth/token', methods=['GET'])
@require_auth()
def get_token():
    """Obtener el token JWT actual del usuario autenticado"""
    try:
        # El token ya está validado por el decorador @require_auth()
        current_user = get_current_user()
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request()

        if not token:
            return web_controller._handle_auth_error("No token found", 401)

        return web_controller._handle_success({
            "token": token,
            "user": {
                "user_id": current_user.get("user_id"),
                "user_type": current_user.get("user_type"),
                "email": current_user.get("email")
            }
        })

    except Exception as e:
        logger.error(f"Error en get_token: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/auth/logout', methods=['POST'])
def generic_logout():
    """Endpoint genérico para cerrar sesión (acepta token en header Authorization o cookie)"""
    try:
        # Get token from header or cookie before clearing it
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request()

        # Remove token from Redis if it exists
        if token and jwt_middleware.redis_client:
            try:
                redis_key = f"access_token:{token}"
                jwt_middleware.redis_client.delete(redis_key)
                logger.info(f"✅ Token removed from Redis: {redis_key}")
            except Exception as redis_error:
                logger.error(f"❌ Error removing token from Redis: {redis_error}")

        from flask import make_response
        resp = make_response(web_controller._handle_success({}, "Logout exitoso"))
        # Instruye al navegador para que elimine la cookie (si existe)
        resp.set_cookie('predicthealth_jwt', '', expires=0, httponly=True, samesite='Lax')
        logger.info("✅ Logout successful, token removed from Redis")
        return resp
    except Exception as e:
        logger.error(f"Error en generic_logout: {str(e)}")
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
@require_auth(required_user_type='patient')
def patient_dashboard():
    """Dashboard completo para pacientes - Obtiene datos del microservicio service-patients"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        patient_id = current_user['user_id']

        logger.info(f"📊 Solicitando dashboard para paciente: {patient_id}")

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Llamar al microservicio service-patients para obtener datos del dashboard
        dashboard_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/patients/{patient_id}/dashboard",
            headers={"Authorization": f"Bearer {token}"}
        )

        if dashboard_response.get('status_code') == 200:
            # Devolver respuesta del microservicio directamente
            logger.info("✅ Dashboard del paciente obtenido exitosamente")
            return jsonify({
                "status": "success",
                "message": "Dashboard del paciente",
                "data": dashboard_response['data']
            }), 200
        else:
            logger.error(f"❌ Error del microservicio service-patients: {dashboard_response}")
            return web_controller._handle_auth_error(
                dashboard_response.get('data', {}).get('detail', 'Error obteniendo dashboard'),
                dashboard_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"❌ Error en patient_dashboard: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/patient/medical-record', methods=['GET'])
@require_auth(required_user_type='patient')
def patient_medical_record():
    """Expediente médico completo del paciente"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        patient_id = current_user['user_id']

        logger.info(f"📋 Solicitando expediente médico para paciente: {patient_id}")

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Llamar al microservicio service-patients
        medical_record_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/patients/{patient_id}/medical-record",
            headers={"Authorization": f"Bearer {token}"}
        )

        if medical_record_response.get('status_code') == 200:
            logger.info("✅ Expediente médico obtenido exitosamente")
            return jsonify({
                "status": "success",
                "message": "Expediente médico del paciente",
                "data": medical_record_response['data']
            }), 200
        else:
            logger.error(f"❌ Error del microservicio service-patients: {medical_record_response}")
            return web_controller._handle_auth_error(
                medical_record_response.get('data', {}).get('detail', 'Error obteniendo expediente médico'),
                medical_record_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"❌ Error en patient_medical_record: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/patient/care-team', methods=['GET'])
@require_auth(required_user_type='patient')
def patient_care_team():
    """Equipo médico del paciente (doctor e institución)"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        patient_id = current_user['user_id']

        logger.info(f"👨‍⚕️ Solicitando equipo médico para paciente: {patient_id}")

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Llamar al microservicio service-patients
        care_team_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/patients/{patient_id}/care-team",
            headers={"Authorization": f"Bearer {token}"}
        )

        if care_team_response.get('status_code') == 200:
            logger.info("✅ Equipo médico obtenido exitosamente")
            return jsonify({
                "status": "success",
                "message": "Equipo médico del paciente",
                "data": care_team_response['data']
            }), 200
        else:
            logger.error(f"❌ Error del microservicio service-patients: {care_team_response}")
            return web_controller._handle_auth_error(
                care_team_response.get('data', {}).get('detail', 'Error obteniendo equipo médico'),
                care_team_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"❌ Error en patient_care_team: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/patient/profile', methods=['GET'])
@require_auth(required_user_type='patient')
def patient_profile():
    """Perfil completo del paciente (información personal, contacto, etc.)"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        patient_id = current_user['user_id']

        logger.info(f"👤 Solicitando perfil para paciente: {patient_id}")

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Obtener perfil completo del paciente desde el microservicio
        profile_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/patients/{patient_id}/profile",
            headers={"Authorization": f"Bearer {token}"}
        )

        if profile_response.get('status_code') != 200:
            logger.error(f"❌ Error obteniendo perfil: {profile_response}")
            return web_controller._handle_auth_error(
                profile_response.get('data', {}).get('detail', 'Error obteniendo perfil'),
                profile_response.get('status_code', 500)
            )

        # Pasar la respuesta del microservicio directamente sin transformar
        # El microservicio retorna: {personal_info, emails, phones, addresses}
        profile_data = profile_response['data']

        logger.info("✅ Perfil del paciente obtenido exitosamente")
        return jsonify({
            "status": "success",
            "message": "Perfil del paciente",
            "data": profile_data
        }), 200

    except Exception as e:
        logger.error(f"❌ Error en patient_profile: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/doctor/dashboard', methods=['GET'])
@require_auth(required_user_type='doctor')
def doctor_dashboard():
    """Dashboard para doctores - Obtiene datos del microservicio service-doctors"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        
        logger.info(f"📊 Solicitando dashboard para doctor: {current_user.get('email')}")

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Llamar al microservicio service-doctors para obtener datos del dashboard
        dashboard_response = web_controller.proxy_service.call_doctors_service(
            "GET", "/api/v1/doctors/me/dashboard",
            headers={"Authorization": f"Bearer {token}"}
        )

        if dashboard_response.get('status_code') == 200:
            # Devolver respuesta del microservicio directamente
            logger.info("✅ Dashboard del doctor obtenido exitosamente")
            return jsonify({
                "status": "success",
                "message": "Dashboard del doctor",
                "data": dashboard_response['data']
            }), 200
        else:
            logger.error(f"❌ Error del microservicio service-doctors: {dashboard_response}")
            return web_controller._handle_auth_error(
                dashboard_response.get('data', {}).get('detail', 'Error obteniendo dashboard'),
                dashboard_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"❌ Error en doctor_dashboard: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/doctor/patients', methods=['GET'])
@require_auth(required_user_type='doctor')
def doctor_patients():
    """Lista de pacientes del doctor - Obtiene datos del microservicio service-doctors"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        
        logger.info(f"👥 Solicitando lista de pacientes para doctor: {current_user.get('email')}")

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Llamar al microservicio service-doctors para obtener la lista de pacientes
        patients_response = web_controller.proxy_service.call_doctors_service(
            "GET", "/api/v1/doctors/me/patients",
            headers={"Authorization": f"Bearer {token}"}
        )

        if patients_response.get('status_code') == 200:
            # Devolver respuesta del microservicio directamente
            logger.info("✅ Lista de pacientes del doctor obtenida exitosamente")
            return jsonify({
                "status": "success",
                "message": "Lista de pacientes del doctor",
                "data": patients_response['data']
            }), 200
        else:
            logger.error(f"❌ Error del microservicio service-doctors: {patients_response}")
            return web_controller._handle_auth_error(
                patients_response.get('data', {}).get('detail', 'Error obteniendo lista de pacientes'),
                patients_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"❌ Error en doctor_patients: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/doctor/patients/<patient_id>/medical-record', methods=['GET'])
@require_auth(required_user_type='doctor')
def doctor_patient_medical_record(patient_id):
    """Expediente médico completo del paciente - Obtiene datos del microservicio service-doctors"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        
        logger.info(f"📋 Solicitando expediente médico para paciente {patient_id} del doctor: {current_user.get('email')}")

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Llamar al microservicio service-doctors para obtener el expediente médico
        medical_record_response = web_controller.proxy_service.call_doctors_service(
            "GET", f"/api/v1/doctors/me/patients/{patient_id}/medical-record",
            headers={"Authorization": f"Bearer {token}"}
        )

        if medical_record_response.get('status_code') == 200:
            # Devolver respuesta del microservicio directamente
            logger.info("✅ Expediente médico del paciente obtenido exitosamente")
            return jsonify({
                "status": "success",
                "message": "Expediente médico del paciente",
                "data": medical_record_response['data']
            }), 200
        else:
            logger.error(f"❌ Error del microservicio service-doctors: {medical_record_response}")
            return web_controller._handle_auth_error(
                medical_record_response.get('data', {}).get('detail', 'Error obteniendo expediente médico'),
                medical_record_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"❌ Error en doctor_patient_medical_record: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/institution/dashboard', methods=['GET'])
@require_auth(required_user_type='institution')
def institution_dashboard():
    """Dashboard para instituciones - Construye dashboard usando datos de otros endpoints"""
    try:
        # Obtener usuario actual
        current_user = get_current_user()
        
        logger.info(f"📊 Solicitando dashboard para institución: {current_user.get('email')}")

        # Verificar que el token tenga reference_id (necesario para el microservicio)
        metadata = current_user.get('metadata', {})
        reference_id = metadata.get('reference_id') if isinstance(metadata, dict) else None
        if not reference_id:
            reference_id = current_user.get('reference_id')
        
        if not reference_id:
            logger.error(f"❌ Token sin reference_id para institución: {current_user.get('email')}")
            logger.error(f"   Token metadata: {metadata}")
            return jsonify({
                "status": "error",
                "message": "Token inválido: no se pudo identificar la institución. Por favor, inicie sesión nuevamente."
            }), 403

        # El proxy service ya agrega automáticamente el token JWT desde g.token_id
        # Funciona tanto para cookies web como Bearer token de Tkinter
        
        # Obtener doctores de la institución
        doctors_response = web_controller.proxy_service.call_institutions_service(
            "GET", "/api/v1/institutions/doctors"
        )
        
        # Obtener pacientes de la institución
        patients_response = web_controller.proxy_service.call_institutions_service(
            "GET", "/api/v1/institutions/patients"
        )
        
        # Manejar errores de los microservicios
        if doctors_response.get('status_code') not in [200, None]:
            error_detail = doctors_response.get('data', {})
            error_message = error_detail.get('detail') or error_detail.get('error', 'Error obteniendo doctores')
            logger.error(f"❌ Error obteniendo doctores: {error_message}")
        
        if patients_response.get('status_code') not in [200, None]:
            error_detail = patients_response.get('data', {})
            error_message = error_detail.get('detail') or error_detail.get('error', 'Error obteniendo pacientes')
            logger.error(f"❌ Error obteniendo pacientes: {error_message}")
        
        # Construir dashboard con los datos obtenidos (usar datos vacíos si hay error)
        doctors_data = []
        patients_data = []
        
        if doctors_response.get('status_code') == 200:
            doctors_data = doctors_response.get('data', {}).get('doctors', [])
        
        if patients_response.get('status_code') == 200:
            patients_data = patients_response.get('data', {}).get('patients', [])
        
        # Calcular estadísticas
        total_doctors = len(doctors_data)
        active_doctors = len([d for d in doctors_data if d.get('is_active', True)])
        total_patients = len(patients_data)
        verified_patients = len([p for p in patients_data if p.get('is_verified', False)])
        
        dashboard_data = {
            "total_doctors": total_doctors,
            "active_doctors": active_doctors,
            "total_patients": total_patients,
            "verified_patients": verified_patients,
            "recent_doctors": doctors_data[:5] if doctors_data else [],
            "recent_patients": patients_data[:5] if patients_data else []
        }
        
        logger.info("✅ Dashboard de institución construido exitosamente")
        return jsonify({
            "status": "success",
            "message": "Dashboard de la institución",
            "data": dashboard_data
        }), 200

    except Exception as e:
        logger.error(f"❌ Error en institution_dashboard: {str(e)}", exc_info=True)
        return jsonify({
            "status": "error",
            "message": f"Error interno del servidor: {str(e)}"
        }), 500






# ============================================================================
# ENDPOINTS DE INSTITUCIONES (GESTIÓN DESDE LA INSTITUCIÓN)
# ============================================================================

@web_bp.route('/institution/doctors', methods=['GET'])
@require_auth(required_user_type='institution')
def institution_get_doctors():
    """Obtiene los doctores de la institución - Ahora usa proxy"""
    try:
        # Obtener usuario actual autenticado
        current_user = get_current_user()
        
        logger.info(f"👨‍⚕️ Solicitando doctores para institución: {current_user.get('email')}")
        
        # Verificar que el token tenga user_type correcto
        user_type = current_user.get('user_type')
        if user_type != 'institution':
            logger.error(f"❌ user_type incorrecto en token: {user_type}, esperado: institution")
            logger.error(f"   Token completo: {current_user}")
            return jsonify({
                "status": "error",
                "message": f"Token inválido: tipo de usuario incorrecto ({user_type})"
            }), 403

        # Verificar que el token tenga reference_id
        metadata = current_user.get('metadata', {})
        reference_id = metadata.get('reference_id') if isinstance(metadata, dict) else None
        if not reference_id:
            reference_id = current_user.get('reference_id')
        
        if not reference_id:
            logger.error(f"❌ Token sin reference_id para institución: {current_user.get('email')}")
            return jsonify({
                "status": "error",
                "message": "Token inválido: no se pudo identificar la institución"
            }), 403
        
        logger.info(f"   Token validado - user_type: {user_type}, reference_id: {reference_id}")

        # Decodificar token para verificar su contenido antes de enviarlo
        import jwt
        import os
        token = g.get('token_id')
        if token:
            try:
                jwt_secret = os.getenv('JWT_SECRET_KEY', 'UDEM')
                jwt_algorithm = os.getenv('JWT_ALGORITHM', 'HS256')
                decoded_token = jwt.decode(token, jwt_secret, algorithms=[jwt_algorithm])
                logger.info(f"   Token decodificado - user_type: {decoded_token.get('user_type')}, metadata: {decoded_token.get('metadata')}")
            except Exception as e:
                logger.warning(f"   No se pudo decodificar token para verificación: {e}")

        # El proxy service ya agrega automáticamente el token JWT desde g.token_id
        # Funciona tanto para cookies web como Bearer token de Tkinter
        # El token JWT generado en login ya incluye metadata.reference_id
        doctors_response = web_controller.proxy_service.call_institutions_service(
            "GET", "/api/v1/institutions/doctors"
        )

        if doctors_response.get('status_code') == 200:
            # El microservicio retorna {"doctors": [...]}
            # Formatear respuesta para el frontend (web y Tkinter)
            logger.info("✅ Doctores obtenidos exitosamente")
            return jsonify({
                "status": "success",
                "message": "Doctores obtenidos exitosamente",
                "data": doctors_response.get('data', {})
            }), 200
        else:
            # Manejo de errores mejorado
            error_detail = doctors_response.get('data', {})
            error_message = error_detail.get('detail') or error_detail.get('error', 'Error en microservicio')
            
            # Si el error es 400/403, probablemente falta reference_id en el token
            status_code = doctors_response.get('status_code', 500)
            if status_code in [400, 403]:
                logger.error(f"❌ Error de autenticación/autorización: {error_message}")
                logger.error(f"   Token metadata: {current_user.get('metadata', {})}")
            
            return jsonify({
                "status": "error",
                "message": error_message
            }), status_code

    except Exception as e:
        logger.error(f"❌ Error en institution_get_doctors: {str(e)}")
        return jsonify({
            "status": "error",
            "message": f"Error interno del servidor: {str(e)}"
        }), 500

@web_bp.route('/institution/doctors', methods=['POST'])
@require_auth(required_user_type='institution')
def institution_create_doctor():
    """Crea un nuevo doctor - Ahora usa proxy"""
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

        # Usar proxy service para llamar al microservicio de instituciones
        create_response = web_controller.proxy_service.call_institutions_service(
            "POST", f"/api/v1/institutions/doctors",
            data=doctor_data,
            headers={"X-User-ID": user_id, "X-User-Type": "institution"}
        )

        if create_response.get('status_code') == 201:
            return jsonify(create_response['data']), 201
        else:
            return web_controller._handle_auth_error(
                create_response.get('data', {}).get('error', 'Error creando doctor'),
                create_response.get('status_code', 500)
            )

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
    """Obtiene los pacientes de la institución - Ahora usa proxy"""
    try:
        current_user = get_current_user()
        user_id = current_user['user_id']

        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Usar proxy service para llamar al microservicio de instituciones
        # El proxy service ya agrega automáticamente el token JWT en Authorization header
        patients_response = web_controller.proxy_service.call_institutions_service(
            "GET", f"/api/v1/institutions/patients"
        )

        if patients_response.get('status_code') == 200:
            # El microservicio retorna {"patients": [...]}
            # Formatear respuesta para el frontend
            return jsonify({
                "status": "success",
                "message": "Pacientes obtenidos exitosamente",
                "data": patients_response.get('data', {})
            }), 200
        else:
            logger.error(f"❌ Error del microservicio service-institutions: {patients_response}")
            return jsonify({
                "status": "error",
                "message": patients_response.get('data', {}).get('detail', patients_response.get('data', {}).get('error', 'Error en microservicio'))
            }), patients_response.get('status_code', 500)

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
        
        # Obtener token del header o cookie para pasarlo a microservicio
        from app.middleware.jwt_middleware import extract_token_from_request
        token = extract_token_from_request() or g.get('token_id', '')
        
        # Usar el endpoint de service-institutions que ya obtiene pacientes filtrados por institución
        # El proxy service ya agrega automáticamente el token JWT en Authorization header
        patients_response = web_controller.proxy_service.call_institutions_service(
            "GET", f"/api/v1/institutions/patients"
        )
        
        if patients_response.get('status_code') == 200:
            # El microservicio retorna {"patients": [...]}
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
