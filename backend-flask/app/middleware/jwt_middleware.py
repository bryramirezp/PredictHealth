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
        self.SECRET_KEY = os.getenv("JWT_SECRET_KEY")
        self.ALGORITHM = os.getenv("JWT_ALGORITHM")
        try:
            self.redis_client = redis.from_url(redis_url, decode_responses=True)
            logger.info("✅ Session middleware: Redis conectado")
        except Exception as e:
            logger.error(f"❌ Session middleware: Error conectando Redis: {e}")
            self.redis_client = None

    def validate_session(self, jwt_token: str) -> dict:
        """Validate JWT token by checking if it exists in Redis with JWT in key name"""
        if not self.redis_client:
            return None

        try:
            # Check if the JWT token exists as a key in Redis
            key = f"access_token:{jwt_token}"
            exists = self.redis_client.exists(key)

            if not exists:
                logger.warning(f"⚠️ Access token not found in Redis: {key[:50]}...")
                return None

            # Decode the JWT token to extract session data
            payload = jwt.decode(jwt_token, self.SECRET_KEY, algorithms=[self.ALGORITHM])

            # Verify it's an access token
            if payload.get("type") != "access":
                logger.warning("⚠️ Token is not an access token")
                return None

            # Update last activity (extend expiration)
            self.redis_client.expire(key, 15*60)  # 15 minutes

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
            return None
        except jwt.InvalidTokenError as e:
            logger.error(f"❌ Invalid token: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error validating token: {e}")
            return None

# Instancia global
jwt_middleware = SessionMiddleware()

def require_session(f):
    """Decorador para requerir token_id válido en cookie"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token_id = request.cookies.get('predicthealth_session')

        if not token_id:
            logger.warning("⚠️ No session cookie provided")
            return jsonify({
                "error": "Sesión requerida",
                "message": "Debe iniciar sesión"
            }), 401

        # Validar token_id y obtener datos de sesión
        session_data = jwt_middleware.validate_session(token_id)
        if not session_data:
            logger.warning("⚠️ Invalid token_id")
            return jsonify({
                "error": "Token inválido",
                "message": "El token ha expirado o es inválido"
            }), 401

        # Agregar datos de usuario al contexto
        g.current_user = session_data
        g.token_id = token_id
        logger.info(f"✅ Token validated for user: {session_data.get('email')}")

        return f(*args, **kwargs)

    return decorated_function

def optional_session(f):
    """Decorador opcional para token_id"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token_id = request.cookies.get('predicthealth_session')

        if token_id:
            session_data = jwt_middleware.validate_session(token_id)
            if session_data:
                g.current_user = session_data
                g.token_id = token_id

        return f(*args, **kwargs)

    return decorated_function

def require_auth(required_user_type=None):
    """Decorador para requerir autenticación con tipo de usuario opcional"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token_id = request.cookies.get('predicthealth_session')

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