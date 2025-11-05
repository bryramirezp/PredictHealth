# /backend-flask\app\api\v1\auth.py
# /backend-flask/app/api/v1/auth.py
# Endpoint de autenticación (Login, Logout, Refresh)

from flask import Blueprint, request, jsonify, current_app
import requests
import logging
import os
from datetime import datetime, timezone

# Instanciar el blueprint
auth_bp = Blueprint('auth', __name__)
logger = logging.getLogger(__name__)

# URL del servicio JWT (debe coincidir con la configuración del middleware)
JWT_SERVICE_URL = os.getenv('JWT_SERVICE_URL', 'http://servicio-auth-jwt:8003')

# Importar el middleware JWT y el servicio de autenticación
from app.middleware.jwt_middleware import jwt_middleware, require_session
from app.services.auth_service import AuthService

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    Endpoint de login con sesiones server-side.
    Crea sesión en Redis y devuelve cookie HTTP-only.
    """
    data = request.get_json()
    if not data:
        return jsonify({
            'error': 'Cuerpo de solicitud vacío',
            'message': 'Se espera JSON con email, password y user_type'
        }), 400

    email = data.get('email')
    password = data.get('password')
    user_type = data.get('user_type', 'patient')

    if not all([email, password]):
        return jsonify({
            'error': 'Datos incompletos',
            'message': 'Los campos email y password son obligatorios'
        }), 400

    # Capturar información del dispositivo
    device_info = {
        'user_agent': request.headers.get('User-Agent'),
        'ip_address': request.remote_addr or request.headers.get('X-Forwarded-For') or request.headers.get('X-Real-IP')
    }

    try:
        logger.info(f"🔄 Login request for user: {email}")

        # Usar el servicio de autenticación centralizado
        auth_service = AuthService()
        result = auth_service.authenticate_user(email, password, user_type)
        
        if result['success']:
            # Logging detallado para depurar
            logger.info(f"🔍 AuthService response: {result}")
            
            # Crear respuesta con cookie HTTP-only
            resp = jsonify({
                "success": True,
                "user": {
                    "user_id": result['user_id'],
                    "user_type": result['user_type'],
                    "email": result['email']
                },
                "token_info": {
                    "expires_in": result.get('expires_in'),
                    "token_type": "bearer"
                }
            })

            # Cookie segura con el access_token del servicio de autenticación
            resp.set_cookie(
                'predicthealth_session',
                result['access_token'],
                httponly=True,
                secure=False,  # True en producción con HTTPS
                samesite='Strict',
                max_age=15*60  # 15 minutos (expiración del token)
            )

            logger.info(f"✅ Login successful for {email}, user_type: {user_type}")
            return resp
        else:
            # Propagar error de autenticación
            logger.warning(f"⚠️ Login failed for {email}: {result['error']}")
            return jsonify({
                "error": "Autenticación fallida",
                "message": result['error']
            }), 401

    except Exception as e:
        logger.error(f"❌ Unexpected error during login for {email}: {str(e)}")
        return jsonify({
            'error': 'Error interno',
            'message': 'Ocurrió un error inesperado al procesar el login'
        }), 500


@auth_bp.route('/jwt/health', methods=['GET'])
def jwt_health():
    """
    Endpoint para verificar la salud del servicio JWT (proxy).
    """
    try:
        logger.info("🔄 Checking JWT service health")

        response = requests.get(
            f"{JWT_SERVICE_URL}/health",
            timeout=10
        )

        if response.status_code == 200:
            health_data = response.json()
            logger.info("✅ JWT service health check successful")
            return jsonify(health_data), 200
        else:
            logger.warning(f"⚠️ JWT service health check failed: {response.status_code}")
            return jsonify({
                'status': 'error',
                'message': 'JWT service health check failed',
                'status_code': response.status_code
            }), response.status_code

    except requests.exceptions.RequestException as e:
        logger.error(f"❌ Communication error with JWT service during health check: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'Cannot connect to JWT service',
            'details': str(e)
        }), 503
    except Exception as e:
        logger.error(f"❌ Unexpected error during JWT health check: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'Internal error during health check',
            'details': str(e)
        }), 500


@auth_bp.route('/logout', methods=['POST'])
def logout():
    """Cerrar sesión revocando el token JWT"""
    token = request.cookies.get('predicthealth_session')

    if token:
        try:
            # Llamar al Auth-JWT Service para revocar el token
            logout_response = requests.post(
                f"{JWT_SERVICE_URL}/auth/logout",
                json={
                    "access_token": token,
                    "refresh_token": ""
                },
                timeout=10
            )

            if logout_response.status_code == 200:
                logger.info("✅ Token revoked via Auth-JWT Service")
            else:
                logger.warning(f"⚠️ Auth-JWT Service logout failed: {logout_response.status_code}")

        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Error calling Auth-JWT Service for logout: {str(e)}")
            # Continuar con logout local si falla la llamada

    # Limpiar cookie de todos modos
    resp = jsonify({"success": True, "message": "Sesión cerrada exitosamente"})
    resp.set_cookie('predicthealth_session', '', expires=0, httponly=True)
    return resp

# Nuevo endpoint para validar sesión (restaurado para compatibilidad con frontend)
@auth_bp.route('/session/validate', methods=['GET'])
def validate_session():
    """Validar token JWT activo"""
    token = request.cookies.get('predicthealth_session')

    if not token:
        return jsonify({
            "valid": False,
            "message": "No active token"
        }), 401

    # Validar token usando el middleware
    session_data = jwt_middleware.validate_session(token)
    if not session_data:
        return jsonify({
            "valid": False,
            "message": "Token expired or invalid"
        }), 401

    return jsonify({
        "valid": True,
        "user": {
            "user_id": session_data["user_id"],
            "user_type": session_data["user_type"],
            "email": session_data["email"]
        }
    })

# Endpoints legacy para compatibilidad (pueden ser removidos después)
@auth_bp.route('/refresh', methods=['POST'])
def refresh_legacy():
    """
    Endpoint legacy para compatibilidad. Las sesiones se renuevan automáticamente.
    """
    return jsonify({
        "message": "Las sesiones se renuevan automáticamente server-side",
        "note": "Este endpoint es para compatibilidad legacy"
    }), 200

@auth_bp.route('/verify', methods=['GET'])
def verify_legacy():
    """
    Endpoint legacy para compatibilidad. Use /session/validate en su lugar.
    """
    return jsonify({
        "message": "Use /api/v1/auth/session/validate para validar sesiones",
        "note": "Este endpoint es para compatibilidad legacy"
    }), 200
