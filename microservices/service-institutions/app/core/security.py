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

class HeaderValidator:
    """Extractor de información de usuario desde headers HTTP (verificado por API Gateway)"""

    @staticmethod
    def extract_user_info_from_headers(request_headers: Dict[str, str]) -> Dict[str, Any]:
        """
        Extrae información del usuario de los headers HTTP añadidos por el API Gateway

        Args:
            request_headers: Headers de la petición HTTP

        Returns:
            Dict[str, Any]: Información del usuario

        Raises:
            HTTPException: Si los headers requeridos no están presentes
        """
        try:
            # Extraer información de los headers añadidos por el gateway
            user_id = request_headers.get("X-User-ID")
            user_type = request_headers.get("X-User-Type")
            email = request_headers.get("X-User-Email")
            roles_str = request_headers.get("X-User-Roles", "[]")
            metadata_str = request_headers.get("X-User-Metadata", "{}")

            if not all([user_id, user_type, email]):
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Información de usuario no encontrada en headers (verificación faltante por gateway)",
                    headers={"WWW-Authenticate": "Bearer"},
                )

            # Parsear roles y metadata
            try:
                roles = eval(roles_str) if roles_str else []
                metadata = eval(metadata_str) if metadata_str else {}
            except:
                roles = []
                metadata = {}

            user_info = {
                "user_id": user_id,
                "user_type": user_type,
                "email": email,
                "roles": roles,
                "metadata": metadata,
            }

            logger.info(f"✅ Información de usuario extraída de headers para {email} (tipo: {user_type})")

            return user_info

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error extrayendo información del usuario de headers: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Error extrayendo información del usuario de headers",
                headers={"WWW-Authenticate": "Bearer"},
            )

# Dependencia FastAPI para obtener el usuario actual desde headers
async def get_current_user(request: Request) -> Dict[str, Any]:
    """
    Dependencia FastAPI para obtener el usuario actual desde headers HTTP

    Args:
        request: Objeto Request de FastAPI

    Returns:
        Dict[str, Any]: Información del usuario autenticado

    Raises:
        HTTPException: Si la información no está disponible
    """
    try:
        user_info = HeaderValidator.extract_user_info_from_headers(dict(request.headers))
        return user_info
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error obteniendo usuario actual: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Error obteniendo usuario actual",
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
