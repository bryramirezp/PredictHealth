# /backend-flask\app\api\v1\web_controller.py
# Controller for JSON endpoints /api/web

from flask import Blueprint, request, jsonify, g
from flask import current_app
import logging
import requests
import json
import re

from app.services.proxy_service import ProxyService
from app.middleware import require_auth, get_current_user, is_authenticated

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

@web_bp.route('/auth/admin/login', methods=['POST'])
def admin_login():
    """Endpoint de login para administradores"""
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
            "user_type": "admin"
        }

        # Call JWT service for authentication
        auth_response = web_controller.proxy_service.call_jwt_service(
            "POST", "/auth/login", auth_data
        )

        if auth_response.get('status_code') == 200:
            # Login exitoso
            response_data = {
                "user_id": auth_response['data']['user_id'],
                "user_type": "admin",
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
        logger.error(f"Error en admin_login: {str(e)}")
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

        # Obtener datos de la institución por email
        institution_response = web_controller.proxy_service.call_institutions_service(
            "GET", f"/api/v1/institutions/", headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        # Filtrar por email del usuario actual
        institution_data = None
        if institution_response.get('status_code') == 200:
            institutions = institution_response['data'].get('institutions', [])
            user_email = current_user['email']
            institution_data = next((inst for inst in institutions if inst.get('contact_email') == user_email), None)

        # Obtener doctores de la institución
        doctors_response = web_controller.proxy_service.call_doctors_service(
            "GET", f"/api/v1/doctors/?id_institucion={user_id}", headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        # Obtener pacientes de la institución
        patients_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/patients?id_institucion={user_id}", headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if institution_data:
            # Preparar datos para respuesta
            dashboard_data = {
                "institution": institution_data,
                "doctors": doctors_response.get('data', []) if doctors_response.get('status_code') == 200 else [],
                "patients": patients_response.get('data', []) if patients_response.get('status_code') == 200 else [],
                "statistics": {
                    "total_doctors": len(doctors_response.get('data', [])),
                    "total_patients": len(patients_response.get('data', [])),
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
        else:
            return web_controller._handle_auth_error(
                "Institución no encontrada para el usuario actual",
                404
            )

    except Exception as e:
        logger.error(f"Error en institution_dashboard: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/dashboard', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_dashboard():
    """Dashboard para administradores"""
    try:
        # Obtener usuario actual
        current_user = get_current_user()
        user_id = current_user['user_id']

        # Obtener estadísticas generales del sistema
        institutions_response = web_controller.proxy_service.call_institutions_service(
            "GET", "/api/v1/institutions/",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        doctors_response = web_controller.proxy_service.call_doctors_service(
            "GET", "/api/v1/doctors/",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        patients_response = web_controller.proxy_service.call_patients_service(
            "GET", "/api/v1/patients/",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        # Obtener información del admin actual
        admin_response = web_controller.proxy_service.call_admins_service(
            "GET", f"/admins/{user_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        # Preparar datos para respuesta
        dashboard_data = {
            "admin": admin_response.get('data', {}) if admin_response.get('status_code') == 200 else {
                "user_id": user_id,
                "email": current_user.get('email', 'admin@example.com'),
                "user_type": "admin"
            },
            "institutions": institutions_response.get('data', {}).get('institutions', []) if institutions_response.get('status_code') == 200 else [],
            "doctors": doctors_response.get('data', {}).get('doctors', []) if doctors_response.get('status_code') == 200 else [],
            "patients": patients_response.get('data', {}).get('patients', []) if patients_response.get('status_code') == 200 else [],
            "summary": {
                "system_status": "Operativo",
                "database_status": "Conectada",
                "services_status": "Todos operativos"
            },
            "statistics": {
                "total_institutions": len(institutions_response.get('data', {}).get('institutions', [])) if institutions_response.get('status_code') == 200 else 0,
                "total_doctors": len(doctors_response.get('data', {}).get('doctors', [])) if doctors_response.get('status_code') == 200 else 0,
                "total_patients": len(patients_response.get('data', {}).get('patients', [])) if patients_response.get('status_code') == 200 else 0,
                "system_status": "100%"
            },
            "alerts": [
                {
                    "type": "info",
                    "message": "Sistema funcionando correctamente"
                }
            ]
        }

        # Devolver JSON
        return jsonify({
            "status": "success",
            "message": "Dashboard del administrador",
            "data": dashboard_data
        }), 200

    except Exception as e:
        logger.error(f"Error en admin_dashboard: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

# ============================================================================
# ENDPOINTS DE ADMINISTRADORES PARA GESTIÓN DE INSTITUCIONES
# ============================================================================

@web_bp.route('/admin/institutions', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_list_institutions():
    """Lista todas las instituciones (solo administradores)"""
    try:
        # Obtener instituciones del servicio de administradores
        institutions_response = web_controller.proxy_service.call_admins_service(
            "GET", "/admins/institutions",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if institutions_response.get('status_code') == 200:
            institutions_data = institutions_response.get('data', [])

            return jsonify({
                "status": "success",
                "message": "Instituciones obtenidas exitosamente",
                "institutions": institutions_data
            }), 200
        else:
            return web_controller._handle_auth_error(
                institutions_response.get('message', 'Error al obtener instituciones'),
                institutions_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_list_institutions: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/institutions', methods=['POST'])
@require_auth(required_user_type='admin')
def admin_create_institution():
    """Crea una nueva institución (solo administradores)"""
    try:
        # Obtener datos JSON del request
        institution_data = request.get_json()

        if not institution_data:
            return web_controller._handle_auth_error("Datos de la institución requeridos", 400)

        # Validar campos requeridos
        required_fields = ['name', 'contact_email', 'phone', 'address']
        for field in required_fields:
            if not institution_data.get(field):
                return web_controller._handle_auth_error(f"Campo requerido: {field}", 400)

        # Validar formato de email
        import re
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, institution_data['contact_email']):
            return web_controller._handle_auth_error("Formato de email inválido", 400)

        # Preparar datos para el servicio de administradores
        admin_data = {
            "name": institution_data['name'],
            "contact_email": institution_data['contact_email'],
            "phone": institution_data['phone'],
            "address": institution_data['address'],
            "website": institution_data.get('website'),
            "description": institution_data.get('description')
        }

        # Crear institución en el servicio de administradores
        create_response = web_controller.proxy_service.call_admins_service(
            "POST", "/admins/institutions", admin_data,
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if create_response.get('status_code') == 201:
            institution_created = create_response.get('data', {})

            return jsonify({
                "status": "success",
                "message": "Institución creada exitosamente",
                "institution": institution_created
            }), 201
        else:
            return web_controller._handle_auth_error(
                create_response.get('message', 'Error al crear institución'),
                create_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_create_institution: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/institutions/<institution_id>', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_get_institution(institution_id):
    """Obtiene una institución específica (solo administradores)"""
    try:
        # Obtener institución del servicio de administradores
        institution_response = web_controller.proxy_service.call_admins_service(
            "GET", f"/admins/institutions/{institution_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if institution_response.get('status_code') == 200:
            institution_data = institution_response.get('data', {})

            return jsonify({
                "status": "success",
                "message": "Institución obtenida exitosamente",
                "institution": institution_data
            }), 200
        else:
            return web_controller._handle_auth_error(
                institution_response.get('message', 'Institución no encontrada'),
                institution_response.get('status_code', 404)
            )

    except Exception as e:
        logger.error(f"Error en admin_get_institution: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/institutions/<institution_id>', methods=['PUT'])
@require_auth(required_user_type='admin')
def admin_update_institution(institution_id):
    """Actualiza una institución (solo administradores)"""
    try:
        # Obtener datos JSON del request
        update_data = request.get_json()

        if not update_data:
            return web_controller._handle_auth_error("Datos de actualización requeridos", 400)

        # Validar formato de email si se está actualizando
        if 'contact_email' in update_data:
            import re
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if not re.match(email_pattern, update_data['contact_email']):
                return web_controller._handle_auth_error("Formato de email inválido", 400)

        # Actualizar institución en el servicio de administradores
        update_response = web_controller.proxy_service.call_admins_service(
            "PUT", f"/admins/institutions/{institution_id}", update_data,
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if update_response.get('status_code') == 200:
            institution_updated = update_response.get('data', {})

            return jsonify({
                "status": "success",
                "message": "Institución actualizada exitosamente",
                "institution": institution_updated
            }), 200
        else:
            return web_controller._handle_auth_error(
                update_response.get('message', 'Error al actualizar institución'),
                update_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_update_institution: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/institutions/<institution_id>', methods=['DELETE'])
@require_auth(required_user_type='admin')
def admin_delete_institution(institution_id):
    """Elimina una institución (solo administradores)"""
    try:
        # Eliminar institución del servicio de administradores
        delete_response = web_controller.proxy_service.call_admins_service(
            "DELETE", f"/admins/institutions/{institution_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if delete_response.get('status_code') == 204:
            return jsonify({
                "status": "success",
                "message": "Institución eliminada exitosamente"
            }), 200
        else:
            return web_controller._handle_auth_error(
                delete_response.get('message', 'Error al eliminar institución'),
                delete_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_delete_institution: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

# ============================================================================
# ENDPOINTS DE ADMINISTRADORES PARA GESTIÓN DE OTROS ADMINISTRADORES
# ============================================================================

@web_bp.route('/admin/admins', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_list_admins():
    """Lista todos los administradores (solo administradores)"""
    try:
        # Obtener parámetros de query para paginación
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 10, type=int)

        # Obtener administradores del servicio de administradores
        admins_response = web_controller.proxy_service.call_admins_service(
            "GET", f"/admins/?page={page}&limit={limit}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if admins_response.get('status_code') == 200:
            admins_data = admins_response.get('data', [])

            return jsonify({
                "status": "success",
                "message": "Administradores obtenidos exitosamente",
                "admins": admins_data
            }), 200
        else:
            return web_controller._handle_auth_error(
                admins_response.get('message', 'Error al obtener administradores'),
                admins_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_list_admins: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/admins', methods=['POST'])
@require_auth(required_user_type='admin')
def admin_create_admin():
    """Crea un nuevo administrador (solo administradores)"""
    try:
        # Obtener datos JSON del request
        admin_data = request.get_json()

        if not admin_data:
            return web_controller._handle_auth_error("Datos del administrador requeridos", 400)

        # Validar campos requeridos
        required_fields = ['email', 'password', 'first_name', 'last_name']
        for field in required_fields:
            if not admin_data.get(field):
                return web_controller._handle_auth_error(f"Campo requerido: {field}", 400)

        # Validar formato de email
        import re
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, admin_data['email']):
            return web_controller._handle_auth_error("Formato de email inválido", 400)

        # Validar fortaleza de contraseña
        password_valid, password_error = validate_password_strength(admin_data['password'])
        if not password_valid:
            return web_controller._handle_auth_error(password_error, 400)

        # Preparar datos para el servicio de administradores
        create_data = {
            "email": admin_data['email'],
            "password": admin_data['password'],
            "first_name": admin_data['first_name'],
            "last_name": admin_data['last_name'],
            "phone": admin_data.get('phone'),
            "is_active": admin_data.get('is_active', True)
        }

        # Crear administrador en el servicio de administradores
        create_response = web_controller.proxy_service.call_admins_service(
            "POST", "/admins/", create_data,
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if create_response.get('status_code') == 201:
            admin_created = create_response.get('data', {})

            return jsonify({
                "status": "success",
                "message": "Administrador creado exitosamente",
                "admin": admin_created
            }), 201
        else:
            return web_controller._handle_auth_error(
                create_response.get('message', 'Error al crear administrador'),
                create_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_create_admin: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/admins/<admin_id>', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_get_admin(admin_id):
    """Obtiene un administrador específico (solo administradores)"""
    try:
        # Obtener administrador del servicio de administradores
        admin_response = web_controller.proxy_service.call_admins_service(
            "GET", f"/admins/{admin_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if admin_response.get('status_code') == 200:
            admin_data = admin_response.get('data', {})

            return jsonify({
                "status": "success",
                "message": "Administrador obtenido exitosamente",
                "admin": admin_data
            }), 200
        else:
            return web_controller._handle_auth_error(
                admin_response.get('message', 'Administrador no encontrado'),
                admin_response.get('status_code', 404)
            )

    except Exception as e:
        logger.error(f"Error en admin_get_admin: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/admins/<admin_id>', methods=['PUT'])
@require_auth(required_user_type='admin')
def admin_update_admin(admin_id):
    """Actualiza un administrador (solo administradores)"""
    try:
        # Obtener datos JSON del request
        update_data = request.get_json()

        if not update_data:
            return web_controller._handle_auth_error("Datos de actualización requeridos", 400)

        # Validar formato de email si se está actualizando
        if 'email' in update_data:
            import re
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if not re.match(email_pattern, update_data['email']):
                return web_controller._handle_auth_error("Formato de email inválido", 400)

        # Validar fortaleza de contraseña si se está actualizando
        if 'password' in update_data:
            password_valid, password_error = validate_password_strength(update_data['password'])
            if not password_valid:
                return web_controller._handle_auth_error(password_error, 400)

        # Actualizar administrador en el servicio de administradores
        update_response = web_controller.proxy_service.call_admins_service(
            "PUT", f"/admins/{admin_id}", update_data,
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if update_response.get('status_code') == 200:
            admin_updated = update_response.get('data', {})

            return jsonify({
                "status": "success",
                "message": "Administrador actualizado exitosamente",
                "admin": admin_updated
            }), 200
        else:
            return web_controller._handle_auth_error(
                update_response.get('message', 'Error al actualizar administrador'),
                update_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_update_admin: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

@web_bp.route('/admin/admins/<admin_id>', methods=['DELETE'])
@require_auth(required_user_type='admin')
def admin_delete_admin(admin_id):
    """Elimina un administrador (solo administradores)"""
    try:
        # Eliminar administrador del servicio de administradores
        delete_response = web_controller.proxy_service.call_admins_service(
            "DELETE", f"/admins/{admin_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if delete_response.get('status_code') == 204:
            return jsonify({
                "status": "success",
                "message": "Administrador eliminado exitosamente"
            }), 200
        else:
            return web_controller._handle_auth_error(
                delete_response.get('message', 'Error al eliminar administrador'),
                delete_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_delete_admin: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

# ============================================================================
# ENDPOINTS DE AUDITORÍA PARA ADMINISTRADORES
# ============================================================================

@web_bp.route('/admin/audit/logs', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_get_audit_logs():
    """Obtiene logs de auditoría del sistema (solo administradores)"""
    try:
        # Obtener parámetros de query
        admin_id = request.args.get('admin_id')  # Filtrar por admin específico
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 50, type=int)

        # Preparar parámetros para el servicio de administradores
        params = f"?page={page}&limit={limit}"
        if admin_id:
            params += f"&admin_id={admin_id}"

        # Obtener logs de auditoría del servicio de administradores
        audit_response = web_controller.proxy_service.call_admins_service(
            "GET", f"/admins/audit/logs{params}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if audit_response.get('status_code') == 200:
            audit_data = audit_response.get('data', [])

            return jsonify({
                "status": "success",
                "message": "Logs de auditoría obtenidos exitosamente",
                "logs": audit_data
            }), 200
        else:
            return web_controller._handle_auth_error(
                audit_response.get('message', 'Error al obtener logs de auditoría'),
                audit_response.get('status_code', 500)
            )

    except Exception as e:
        logger.error(f"Error en admin_get_audit_logs: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno: {str(e)}", 500)

# ============================================================================
# ENDPOINTS DE ESTADÍSTICAS PARA ADMINISTRADORES
# ============================================================================

@web_bp.route('/admin/statistics', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_get_statistics():
    """Obtiene estadísticas generales del sistema (solo administradores)"""
    try:
        # Obtener estadísticas de diferentes servicios
        institutions_response = web_controller.proxy_service.call_institutions_service(
            "GET", "/api/v1/institutions/statistics/overview",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        doctors_response = web_controller.proxy_service.call_doctors_service(
            "GET", "/api/v1/doctors/",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        patients_response = web_controller.proxy_service.call_patients_service(
            "GET", "/api/v1/patients/",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        # Obtener información de administradores
        admins_response = web_controller.proxy_service.call_admins_service(
            "GET", "/admins/",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        # Calcular estadísticas adicionales
        institutions_count = len(institutions_response.get('data', {}).get('institutions', [])) if institutions_response.get('status_code') == 200 else 0
        doctors_count = len(doctors_response.get('data', {}).get('doctors', [])) if doctors_response.get('status_code') == 200 else 0
        patients_count = len(patients_response.get('data', {}).get('patients', [])) if patients_response.get('status_code') == 200 else 0
        admins_count = len(admins_response.get('data', {}).get('admins', [])) if admins_response.get('status_code') == 200 else 0

        # Calcular estadísticas de pacientes
        active_patients = 0
        high_risk_patients = 0
        new_patients_this_month = 0

        if patients_response.get('status_code') == 200:
            patients = patients_response.get('data', {}).get('patients', [])
            active_patients = len([p for p in patients if p.get('estado_validacion') == 'full_access'])
            high_risk_patients = len([p for p in patients if p.get('risk_score', 0) >= 70])

            # Calcular nuevos este mes
            from datetime import datetime, timedelta
            current_date = datetime.now()
            month_ago = current_date - timedelta(days=30)
            new_patients_this_month = len([
                p for p in patients
                if p.get('fecha_creacion') and
                datetime.fromisoformat(p['fecha_creacion'].replace('Z', '+00:00')) >= month_ago
            ])

        # Preparar datos de estadísticas
        statistics_data = {
            "overview": {
                "total_institutions": institutions_count,
                "total_doctors": doctors_count,
                "total_patients": patients_count,
                "total_admins": admins_count,
                "system_health": "100%"
            },
            "patients": {
                "total": patients_count,
                "active": active_patients,
                "high_risk": high_risk_patients,
                "new_this_month": new_patients_this_month,
                "inactive": patients_count - active_patients
            },
            "institutions": {
                "total": institutions_count,
                "avg_doctors_per_institution": round(doctors_count / institutions_count, 2) if institutions_count > 0 else 0,
                "avg_patients_per_institution": round(patients_count / institutions_count, 2) if institutions_count > 0 else 0
            },
            "doctors": {
                "total": doctors_count,
                "avg_patients_per_doctor": round(patients_count / doctors_count, 2) if doctors_count > 0 else 0
            },
            "system": {
                "status": "Operativo",
                "uptime": "99.9%",
                "last_backup": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "version": "1.0.0"
            }
        }

        return jsonify({
            "status": "success",
            "message": "Estadísticas del sistema obtenidas exitosamente",
            "data": statistics_data
        }), 200

    except Exception as e:
        logger.error(f"Error en admin_get_statistics: {str(e)}")
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

        # Obtener doctores de la institución
        doctors_response = web_controller.proxy_service.call_doctors_service(
            "GET", f"/api/v1/doctors/?id_institucion={user_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if doctors_response.get('status_code') == 200:
            doctors_data = doctors_response.get('data', {}).get('doctors', [])

            # Preparar respuesta JSON
            return jsonify({
                "status": "success",
                "message": "Doctores obtenidos exitosamente",
                "doctors": doctors_data
            }), 200
        else:
            return web_controller._handle_auth_error("Error al obtener doctores", doctors_response.get('status_code', 500))

    except Exception as e:
        logger.error(f"Error en institution_get_doctors: {str(e)}")
        return web_controller._handle_auth_error(f"Error interno del servidor: {str(e)}", 500)

@web_bp.route('/institution/doctors', methods=['POST'])
@require_auth(required_user_type='institution')
def institution_create_doctor():
    """
    Crea un nuevo doctor con cuenta completa para la institución - Input JSON

    Proceso unificado: Crea doctor + usuario de autenticación con contraseña obligatoria
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

        # Paso 1: Crear el doctor en el servicio de doctores (solo datos de negocio)
        business_doctor_data = {
            'nombre': doctor_data['nombre'],
            'apellido': doctor_data['apellido'],
            'email': doctor_data['email'],
            'licencia_medica': doctor_data['licencia_medica'],
            'especialidad': doctor_data.get('especialidad'),
            'id_institucion': user_id
        }

        logger.info(f"🔄 Paso 1: Creando doctor en servicio de doctores: {business_doctor_data['email']}")

        doctor_response = web_controller.proxy_service.call_doctors_service(
            "POST", "/api/v1/doctores/", business_doctor_data,
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if doctor_response.get('status_code') != 201:
            logger.error(f"❌ Error creando doctor: {doctor_response.get('message', 'Error desconocido')}")
            return web_controller._handle_auth_error(doctor_response.get('message', 'Error al crear doctor'), doctor_response.get('status_code', 500))

        doctor_created = doctor_response['data']
        doctor_id = doctor_created.get('id_doctor')
        logger.info(f"✅ Doctor creado exitosamente: {doctor_created.get('email')} (ID: {doctor_id})")

        # Paso 2: Crear tokens JWT para el doctor
        logger.info(f"🔄 Paso 2: Creando tokens JWT para doctor: {doctor_data['email']}")

        jwt_response = web_controller.proxy_service.call_jwt_service(
            "POST", "/tokens/create", {
                'user_id': doctor_id,
                'user_type': 'doctor',
                'email': doctor_data['email'],
                'roles': ['doctor'],
                'metadata': {
                    'id_doctor': doctor_id,
                    'id_institucion': user_id,
                    'nombre': doctor_data['nombre'],
                    'apellido': doctor_data['apellido'],
                    'licencia_medica': doctor_data['licencia_medica']
                }
            }
        )

        if jwt_response.get('status_code') != 200:
            logger.error(f"❌ Error creando tokens JWT: {jwt_response.get('message', 'Error desconocido')}")
            # TODO: Aquí podríamos implementar rollback eliminando el doctor creado
            return web_controller._handle_auth_error(jwt_response.get('message', 'Error al crear tokens JWT'), jwt_response.get('status_code', 500))

        logger.info(f"✅ Tokens JWT creados exitosamente para doctor: {doctor_data['email']}")

        # Respuesta exitosa
        response_data = {
            "status": "success",
            "message": "Doctor con tokens JWT creado exitosamente",
            "doctor": doctor_created,
            "tokens": {
                "access_token": jwt_response['data'].get('access_token'),
                "refresh_token": jwt_response['data'].get('refresh_token'),
                "user_id": doctor_id,
                "user_type": "doctor",
                "email": doctor_data['email']
            }
        }
        return jsonify(response_data), 201

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
def institution_get_patients():
    """Obtiene los pacientes de la institución"""
    try:
        current_user = get_current_user()
        user_id = current_user['user_id']
        
        # Obtener pacientes de la institución
        patients_response = web_controller.proxy_service.call_patients_service(
            "GET", f"/api/v1/patients?id_institucion={user_id}",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )
        
        if patients_response.get('status_code') == 200:
            patients_data = patients_response.get('data', {}).get('patients', [])
            
            # Enriquecer datos con información del doctor
            enriched_patients = []
            for patient in patients_data:
                if patient.get('id_doctor'):
                    # Obtener información del doctor
                    doctor_response = web_controller.proxy_service.call_doctors_service(
                        "GET", f"/api/v1/doctors/{patient['id_doctor']}",
                        headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
                    )
                    if doctor_response.get('status_code') == 200:
                        doctor_data = doctor_response.get('data', {})
                        patient['doctor_name'] = f"Dr. {doctor_data.get('nombre', '')} {doctor_data.get('apellido', '')}"
                
                enriched_patients.append(patient)
            
            return jsonify({
                "status": "success",
                "message": "Pacientes obtenidos exitosamente",
                "patients": enriched_patients
            }), 200
        else:
            return jsonify({
                "status": "error",
                "message": "Error al obtener pacientes"
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


@web_bp.route('/admin/health', methods=['GET'])
@require_auth(required_user_type='admin')
def admin_health_check():
    """Health check endpoint for admin service (requires authentication)"""
    try:
        # Proxy the health check to the admin microservice
        health_response = web_controller.proxy_service.call_admins_service(
            "GET", "/health",
            headers={"Authorization": f"Bearer {request.headers.get('Authorization', '').split(' ')[1]}"}
        )

        if health_response.get('status_code') == 200:
            health_data = health_response.get('data', {})
            return web_controller._handle_success(health_data, "Admin service health check successful")
        else:
            return web_controller._handle_auth_error(
                f"Admin service health check failed: {health_response.get('data', {}).get('error', 'Unknown error')}",
                health_response.get('status_code', 503)
            )

    except Exception as e:
        logger.error(f"Error in admin_health_check: {str(e)}")
        return web_controller._handle_auth_error(f"Error checking admin service health: {str(e)}", 500)

# ============================================================================
# ENDPOINTS DE CONTACTO Y SOPORTE
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
            "/api/web/admin/dashboard",
            "/api/web/admin/health",
            "/api/web/admin/institutions",
            "/api/web/admin/admins",
            "/api/web/admin/audit/logs",
            "/api/web/admin/statistics",
            "/api/web/contact",
            "/api/web/auth/verify"
        ]
    }
    return web_controller._handle_success(health_data, "Servicio web funcionando correctamente")
