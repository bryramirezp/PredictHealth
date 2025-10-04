# /backend-flask/app/middleware/jwt_middleware.py
import os
import json
import redis
from functools import wraps
from flask import request, g, jsonify
from datetime import datetime
import logging
import jwt

logger = logging.getLogger(__name__)

class SessionMiddleware:
    """Middleware para autenticación basada en JWT tokens Redis"""

    def __init__(self):
        redis_url = os.getenv('REDIS_URL', 'redis://redis:6379/0')
        self.SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your-default-secure-secret")
        self.ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
        try:
            self.redis_client = redis.from_url(redis_url, decode_responses=True)
            logger.info("✅ Session middleware: Redis conectado")
        except Exception as e:
            logger.error(f"❌ Session middleware: Error conectando Redis: {e}")
            self.redis_client = None

    def validate_session(self, token: str) -> dict:
        """Validar token JWT en Redis y retornar datos"""
        if not self.redis_client:
            return None

        try:
            # Decodificar el token JWT
            payload = jwt.decode(token, self.SECRET_KEY, algorithms=[self.ALGORITHM])
            token_id = payload.get("token_id")

            if not token_id:
                logger.error("❌ Token does not contain token_id")
                return None

            # Verificar que el token existe en Redis
            session_data = self.redis_client.get(f"token:{token_id}")
            if session_data:
                # Actualizar actividad
                data = json.loads(session_data)
                data["last_activity"] = datetime.now().isoformat()
                self.redis_client.setex(f"token:{token_id}", 15*60, json.dumps(data))  # 15 minutos
                return data
            return None
        except jwt.ExpiredSignatureError:
            logger.warning("⚠️ Token expired")
            return None
        except jwt.InvalidTokenError as e:
            logger.error(f"❌ Invalid token: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error validando token: {e}")
            return None

# Instancia global
jwt_middleware = SessionMiddleware()

def require_session(f):
    """Decorador para requerir token JWT válido"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.cookies.get('predicthealth_session')

        if not token:
            logger.warning("⚠️ No session cookie provided")
            return jsonify({
                "error": "Sesión requerida",
                "message": "Debe iniciar sesión"
            }), 401

        # Validar token en Redis
        session_data = session_middleware.validate_session(token)
        if not session_data:
            logger.warning("⚠️ Invalid token")
            return jsonify({
                "error": "Token inválido",
                "message": "El token ha expirado o es inválido"
            }), 401

        # Agregar datos de usuario al contexto
        g.current_user = session_data
        g.token = token
        logger.info(f"✅ Token validated for user: {session_data.get('email')}")

        return f(*args, **kwargs)

    return decorated_function

def optional_session(f):
    """Decorador opcional para token"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.cookies.get('predicthealth_session')

        if token:
            session_data = session_middleware.validate_session(token)
            if session_data:
                g.current_user = session_data
                g.token = token

        return f(*args, **kwargs)

    return decorated_function

def require_auth(required_user_type=None):
    """Decorador para requerir autenticación con tipo de usuario opcional"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token = request.cookies.get('predicthealth_session')

            if not token:
                return jsonify({
                    "error": "Sesión requerida",
                    "message": "Debe iniciar sesión"
                }), 401

            # Validar token
            session_data = session_middleware.validate_session(token)
            if not session_data:
                return jsonify({
                    "error": "Token inválido",
                    "message": "El token ha expirado o es inválido"
                }), 401

            # Verificar tipo de usuario si se especifica
            if required_user_type and session_data.get('user_type') != required_user_type:
                return jsonify({
                    "error": "Acceso denegado",
                    "message": f"Se requiere ser {required_user_type}"
                }), 403

            # Agregar datos de usuario al contexto
            g.current_user = session_data
            g.token = token

            return f(*args, **kwargs)
        return decorated_function
    return decorator

def get_current_user():
    """Obtener usuario actual del contexto"""
    return getattr(g, 'current_user', None)

def is_authenticated():
    """Verificar si el usuario está autenticado"""
    return hasattr(g, 'current_user') and g.current_user is not None