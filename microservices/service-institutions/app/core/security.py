# /microservices\service-institutions\app\core\security.py
# /microservicios/servicio-instituciones/core/security.py
# Header-based authentication (token verified by API Gateway)

import re
from typing import Dict, Any, Optional
import bcrypt
from fastapi import Depends, HTTPException, status, Request
import logging

logger = logging.getLogger(__name__)

# Header-based authentication (token verified by API Gateway)

class SecurityUtils:
    """Utilidades de seguridad para el servicio de instituciones"""

    @staticmethod
    def validate_email(email: str) -> bool:
        """Valida el formato de un email usando regex"""
        if not email or not isinstance(email, str):
            return False
        
        # Patrón regex para validar email
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(email_pattern, email.strip()) is not None

    @staticmethod
    def sanitize_input(input_str: str) -> str:
        """Sanitiza una entrada de texto"""
        if not input_str or not isinstance(input_str, str):
            return ""
        
        # Remover espacios en blanco al inicio y final
        sanitized = input_str.strip()
        
        # Limitar longitud máxima
        if len(sanitized) > 255:
            sanitized = sanitized[:255]
        
        return sanitized

    @staticmethod
    def validate_required_fields(data: Dict[str, Any], required_fields: list) -> None:
        """Valida que los campos requeridos estén presentes y no vacíos"""
        missing_fields = []
        
        for field in required_fields:
            if field not in data or not data[field] or str(data[field]).strip() == "":
                missing_fields.append(field)
        
        if missing_fields:
            raise ValueError(f"Campos requeridos faltantes o vacíos: {', '.join(missing_fields)}")

    @staticmethod
    def hash_password(password: str) -> str:
        """Hashea una contraseña usando bcrypt"""
        # Manejar límite de 72 bytes de bcrypt
        password_bytes = password.encode('utf-8')
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
            password = password_bytes.decode('utf-8', errors='ignore')

        # Generar hash con bcrypt
        hashed = bcrypt.hashpw(password_bytes, bcrypt.gensalt())
        return hashed.decode('utf-8')

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verifica una contraseña contra su hash"""
        # Manejar límite de 72 bytes de bcrypt
        password_bytes = plain_password.encode('utf-8')
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
            plain_password = password_bytes.decode('utf-8', errors='ignore')

        # Verificar con bcrypt
        return bcrypt.checkpw(password_bytes, hashed_password.encode('utf-8'))

# JWT Bearer token authentication
class JWTValidator:
    """Extractor de información de usuario desde JWT Bearer token"""

    # JWT Configuration (same as auth-jwt service)
    JWT_SECRET_KEY = "your-default-secure-secret"  # Should match auth-jwt service
    JWT_ALGORITHM = "HS256"

    @staticmethod
    def extract_user_info_from_jwt(request_headers: Dict[str, str]) -> Dict[str, Any]:
        """
        Extrae información del usuario del JWT Bearer token

        Args:
            request_headers: Headers de la petición HTTP

        Returns:
            Dict[str, Any]: Información del usuario

        Raises:
            HTTPException: Si el token no es válido o está ausente
        """
        try:
            import jwt

            # Extraer token del header Authorization
            auth_header = request_headers.get("Authorization", "")
            if not auth_header.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token Bearer requerido. Formato: 'Authorization: Bearer <token>'",
                    headers={"WWW-Authenticate": "Bearer"},
                )

            token = auth_header.replace("Bearer ", "")

            # Decodificar JWT token
            try:
                payload = jwt.decode(token, JWTValidator.JWT_SECRET_KEY, algorithms=[JWTValidator.JWT_ALGORITHM])
            except jwt.ExpiredSignatureError:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token expirado",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            except jwt.InvalidTokenError as e:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail=f"Token inválido: {str(e)}",
                    headers={"WWW-Authenticate": "Bearer"},
                )

            # Extraer información del usuario del payload
            user_id = payload.get("user_id")
            user_type = payload.get("user_type")
            email = payload.get("email")
            roles = payload.get("roles", [])
            reference_id = payload.get("reference_id")

            if not all([user_id, user_type, email]):
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token no contiene información completa del usuario",
                    headers={"WWW-Authenticate": "Bearer"},
                )

            user_info = {
                "user_id": user_id,
                "user_type": user_type,
                "email": email,
                "roles": roles,
                "reference_id": reference_id,
                "metadata": payload.get("metadata", {}),
            }

            logger.info(f"✅ Información de usuario extraída de JWT para {email} (tipo: {user_type})")

            return user_info

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error procesando JWT token: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Error procesando token de autenticación",
                headers={"WWW-Authenticate": "Bearer"},
            )

# Legacy header-based validator (for backward compatibility)
class HeaderValidator:
    """Extractor de información de usuario desde headers HTTP (LEGACY)"""

    @staticmethod
    def extract_user_info_from_headers(request_headers: Dict[str, str]) -> Dict[str, Any]:
        """
        Extrae información del usuario de los headers HTTP añadidos por el API Gateway
        """
        logger.warning("⚠️ Usando método legacy de headers. Se recomienda usar JWT Bearer tokens.")
        return JWTValidator.extract_user_info_from_jwt(request_headers)

# Dependencia FastAPI para obtener el usuario actual desde JWT Bearer token
async def get_current_user(request: Request) -> Dict[str, Any]:
    """
    Dependencia FastAPI para obtener el usuario actual desde JWT Bearer token

    Args:
        request: Objeto Request de FastAPI

    Returns:
        Dict[str, Any]: Información del usuario autenticado

    Raises:
        HTTPException: Si el token no es válido
    """
    try:
        user_info = JWTValidator.extract_user_info_from_jwt(dict(request.headers))
        return user_info
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error obteniendo usuario actual: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Error obteniendo usuario actual. Token Bearer requerido.",
            headers={"WWW-Authenticate": "Bearer"},
        )

# Dependencia para requerir tipo de usuario específico
def require_user_type(required_type: str):
    """
    Decorador para requerir un tipo de usuario específico
    
    Args:
        required_type: Tipo de usuario requerido (doctor, patient, institution, admin)
        
    Returns:
        Función que valida el tipo de usuario
    """
    def type_checker(current_user: Dict[str, Any] = Depends(get_current_user)):
        user_type = current_user.get("user_type")
        if user_type != required_type:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Se requiere el tipo de usuario: {required_type}. Usuario actual: {user_type}",
            )
        return current_user
    return type_checker

# Dependencia para requerir rol específico
def require_role(required_role: str):
    """
    Decorador para requerir un rol específico
    
    Args:
        required_role: Rol requerido
        
    Returns:
        Función que valida el rol del usuario
    """
    def role_checker(current_user: Dict[str, Any] = Depends(get_current_user)):
        user_roles = current_user.get("roles", [])
        if required_role not in user_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Se requiere el rol: {required_role}",
            )
        return current_user
    return role_checker

# Dependencia específica para instituciones
def get_current_institution(current_user: Dict[str, Any] = Depends(require_user_type("institution"))):
    """
    Dependencia específica para obtener la institución actual
    
    Args:
        current_user: Usuario actual validado
        
    Returns:
        Dict[str, Any]: Información de la institución
    """
    return current_user
