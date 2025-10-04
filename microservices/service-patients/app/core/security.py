# /microservices\service-patients\app\core\security.py
# Header-based authentication (token verified by API Gateway)

import re
import hashlib
from typing import Dict, Any, Optional, List
from fastapi import Depends, HTTPException, status, Request
import logging
import bcrypt

logger = logging.getLogger(__name__)

class SecurityUtils:
    """Utility class for security operations"""

    @staticmethod
    def sanitize_input(input_str: str) -> str:
        """Sanitize input by removing potentially dangerous characters"""
        if not input_str:
            return ""
        # Remove HTML tags and trim whitespace
        sanitized = re.sub(r'<[^>]+>', '', input_str)
        return sanitized.strip()

    @staticmethod
    def validate_required_fields(data: Dict[str, Any], required_fields: List[str]) -> None:
        """Validate that all required fields are present and not empty"""
        missing_fields = []
        for field in required_fields:
            value = data.get(field)
            if value is None or (isinstance(value, str) and value.strip() == ""):
                missing_fields.append(field)

        if missing_fields:
            raise ValueError(f"Missing required fields: {', '.join(missing_fields)}")

    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email format using regex"""
        if not email:
            return False

        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(email_pattern, email))

    @staticmethod
    def hash_password(password: str) -> str:
        """Hash a password using bcrypt"""
        # Handle bcrypt 72-byte limit
        password_bytes = password.encode('utf-8')
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
            password = password_bytes.decode('utf-8', errors='ignore')

        # Generate hash with bcrypt
        hashed = bcrypt.hashpw(password_bytes, bcrypt.gensalt())
        return hashed.decode('utf-8')

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash"""
        # Handle bcrypt 72-byte limit
        password_bytes = plain_password.encode('utf-8')
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
            plain_password = password_bytes.decode('utf-8', errors='ignore')

        # Verify with bcrypt
        return bcrypt.checkpw(password_bytes, hashed_password.encode('utf-8'))

# Header-based authentication (token verified by API Gateway)
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

# Dependencia específica para pacientes
def get_current_patient(current_user: Dict[str, Any] = Depends(require_user_type("patient"))):
    """
    Dependencia específica para obtener el paciente actual
    
    Args:
        current_user: Usuario actual validado
        
    Returns:
        Dict[str, Any]: Información del paciente
    """
    return current_user

# Dependencia específica para doctores (para que puedan acceder a datos de pacientes)
def get_current_doctor(current_user: Dict[str, Any] = Depends(require_user_type("doctor"))):
    """
    Dependencia específica para obtener el doctor actual
    
    Args:
        current_user: Usuario actual validado
        
    Returns:
        Dict[str, Any]: Información del doctor
    """
    return current_user
