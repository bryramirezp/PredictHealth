# /microservices\service-jwt\app\core\jwt_config.py
# /microservices/service-jwt/app/core/jwt_config.py
# Configuración JWT para el servicio de autenticación

import os
import jwt
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)

class JWTConfig:
    """Clase de configuración para JWT"""
    SECRET_KEY: str = os.getenv("JWT_SECRET_KEY")
    SALT: str = os.getenv("JWT_SALT", "a_strong_random_salt_for_extra_security") # Considerar generar dinámicamente o desde secrets
    ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    REFRESH_TOKEN_EXPIRE_DAYS: int = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))
    ISSUER: str = os.getenv("JWT_ISSUER", "predicthealth.com")
    AUDIENCE: str = os.getenv("JWT_AUDIENCE", "predicthealth_users")

    @staticmethod
    def verify_token(token: str) -> Optional[Dict[str, Any]]:
        """Verifica y decodifica un token JWT."""
        try:
            secret_with_salt = f"{JWTConfig.SECRET_KEY}:{JWTConfig.SALT}"
            payload = jwt.decode(token, secret_with_salt, algorithms=[JWTConfig.ALGORITHM], audience=JWTConfig.AUDIENCE, issuer=JWTConfig.ISSUER)
            return payload
        except jwt.ExpiredSignatureError:
            logger.warning("❌ Token expirado")
            return None
        except jwt.InvalidTokenError as e:
            logger.warning(f"❌ Token inválido: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error inesperado al verificar token: {e}")
            return None

class JWTUtils:
    """Utilidades JWT (si se necesitan funciones estáticas adicionales)"""
    # Por ahora, las utilidades de verificación están en JWTConfig.
    # Se pueden añadir más aquí si es necesario.
    pass