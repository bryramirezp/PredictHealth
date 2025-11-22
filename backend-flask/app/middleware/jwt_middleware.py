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
        redis_url = os.getenv('REDIS_URL')
        self.SECRET_KEY = os.getenv("JWT_SECRET_KEY", "UDEM")  # Valor por defecto para compatibilidad
        self.ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
        try:
            self.redis_client = redis.from_url(redis_url, decode_responses=True)
            logger.info("✅ Session middleware: Redis conectado")
        except Exception as e:
            logger.error(f"❌ Session middleware: Error conectando Redis: {e}")
            self.redis_client = None

    def validate_session(self, jwt_token: str) -> dict:
        """Validate JWT token by checking Redis first, then decoding if necessary"""
        try:
            # First, check if Redis is available
            if not self.redis_client:
                logger.error("❌ Redis client not available")
                return None

            # Check if the token exists in Redis with the correct key format
            redis_key = f"access_token:{jwt_token}"
            stored_token = self.redis_client.get(redis_key)

            if not stored_token:
                logger.warning(f"⚠️ Access token not found in Redis: {redis_key}")
                return None

            # If token exists in Redis, decode it to get session data
            payload = jwt.decode(jwt_token, self.SECRET_KEY, algorithms=[self.ALGORITHM])

            # Verify it's an access token (if type is specified)
            if payload.get("type") and payload.get("type") != "access":
                logger.warning("⚠️ Token is not an access token")
                return None

            # Return session data (extract from payload)
            session_data = {
                "user_id": payload.get("user_id"),
                "user_type": payload.get("user_type"),
                "email": payload.get("email"),
                "roles": payload.get("roles", []),
                "metadata": payload.get("metadata", {}),
                "last_activity": datetime.now().isoformat()
            }

            logger.info(f"✅ Access token validated for user: {payload.get('email')}")
            return session_data

        except jwt.ExpiredSignatureError:
            logger.warning("⚠️ Token expired")
            # Remove expired token from Redis
            if self.redis_client:
                try:
                    self.redis_client.delete(redis_key)
                except Exception as redis_error:
                    logger.error(f"❌ Error removing expired token from Redis: {redis_error}")
            return None
        except jwt.InvalidTokenError as e:
            logger.error(f"❌ Invalid token: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error validating token: {e}")
            return None

# Instancia global
jwt_middleware = SessionMiddleware()

def extract_token_from_request():
    """
    Extraer token JWT del request.
    Prioridad: 1) Header Authorization Bearer, 2) Cookie predicthealth_jwt
    Retorna el token o None si no se encuentra
    """
    # Primero intentar obtener del header Authorization (para apps de escritorio)
    auth_header = request.headers.get('Authorization', '')
    if auth_header and auth_header.startswith('Bearer '):
        token = auth_header.split(' ', 1)[1]
        logger.debug("🔑 Token extraído del header Authorization")
        return token
    
    # Fallback a cookie (para navegadores web)
    token = request.cookies.get('predicthealth_jwt')
    if token:
        logger.debug("🍪 Token extraído de cookie")
        return token
    
    logger.debug("⚠️ No se encontró token en header ni cookie")
    return None

def store_jwt_token(jwt_token: str, expiration_seconds: int = 900) -> bool:
    """Store JWT token in Redis with expiration"""
    try:
        if not jwt_middleware.redis_client:
            logger.error("❌ Redis client not available for storing token")
            return False

        redis_key = f"access_token:{jwt_token}"
        # Store the token with expiration (default 15 minutes)
        jwt_middleware.redis_client.setex(redis_key, expiration_seconds, jwt_token)
        logger.info(f"✅ JWT token stored in Redis: {redis_key}")
        return True
    except Exception as e:
        logger.error(f"❌ Error storing JWT token in Redis: {e}")
        return False

def require_session(f=None, *, allowed_roles=None):
    """Decorador para requerir token válido (header o cookie) con roles opcionales"""
    def decorator(func):
        @wraps(func)
        def decorated_function(*args, **kwargs):
            token_id = extract_token_from_request()

            if not token_id:
                logger.warning("⚠️ No token provided (header or cookie)")
                return jsonify({
                    "error": "Sesión requerida",
                    "message": "Debe iniciar sesión"
                }), 401

            # Validar token_id y obtener datos de sesión
            session_data = jwt_middleware.validate_session(token_id)
            if not session_data:
                logger.warning("⚠️ Invalid token")
                return jsonify({
                    "error": "Token inválido",
                    "message": "El token ha expirado o es inválido"
                }), 401

            # Verificar roles si se especifican
            if allowed_roles:
                user_roles = session_data.get('roles', [])
                if not any(role in user_roles for role in allowed_roles):
                    logger.warning(f"⚠️ Insufficient roles. Required: {allowed_roles}, User has: {user_roles}")
                    return jsonify({
                        "error": "Acceso denegado",
                        "message": f"Se requieren roles: {', '.join(allowed_roles)}"
                    }), 403

            # Agregar datos de usuario al contexto
            g.current_user = session_data
            g.token_id = token_id
            logger.info(f"✅ Token validated for user: {session_data.get('email')}")

            return func(*args, **kwargs)
        return decorated_function
    
    # Si se llama sin parámetros, es el decorador antiguo
    if f is not None:
        return decorator(f)
    return decorator

def optional_session(f):
    """Decorador opcional para token (header o cookie)"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token_id = extract_token_from_request()

        if token_id:
            session_data = jwt_middleware.validate_session(token_id)
            if session_data:
                g.current_user = session_data
                g.token_id = token_id

        return f(*args, **kwargs)

    return decorated_function

def require_auth(required_user_type=None):
    """Decorador para requerir autenticación con tipo de usuario opcional (header o cookie)"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token_id = extract_token_from_request()

            if not token_id:
                return jsonify({
                    "error": "Sesión requerida",
                    "message": "Debe iniciar sesión"
                }), 401

            # Validar token_id
            session_data = jwt_middleware.validate_session(token_id)
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
            g.token_id = token_id

            return f(*args, **kwargs)
        return decorated_function
    return decorator

def get_current_user():
    """Obtener usuario actual del contexto"""
    return getattr(g, 'current_user', None)

def is_authenticated():
    """Verificar si el usuario está autenticado"""
    return hasattr(g, 'current_user') and g.current_user is not None