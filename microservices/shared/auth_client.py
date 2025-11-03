# /microservices/shared/auth_client.py
# Cliente HTTP para interactuar con el auth-jwt-service.

import os
import requests
import logging
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)

AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL", "http://servicio-auth-jwt:8003")

def create_user(email: str, password: str, user_type: str, reference_id: str) -> Optional[Dict[str, Any]]:
    """
    Llama al auth-jwt-service para crear un nuevo usuario.

    Args:
        email: Email del usuario.
        password: Contraseña en texto plano.
        user_type: Tipo de usuario ('patient', 'doctor', etc.).
        reference_id: El UUID de la entidad de dominio asociada.

    Returns:
        Un diccionario con los datos del usuario creado o None si falla.
    """
    create_url = f"{AUTH_SERVICE_URL}/users/create"
    payload = {
        "email": email,
        "password": password,
        "user_type": user_type,
        "reference_id": str(reference_id)
    }

    try:
        response = requests.post(create_url, json=payload, timeout=5)
        response.raise_for_status() # Lanza una excepción para errores HTTP 4xx/5xx
        logger.info(f"Usuario creado exitosamente en el servicio de autenticación para {email}")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Error al conectar con auth-jwt-service: {e}")
        return None
    except Exception as e:
        logger.error(f"Error inesperado al crear usuario en auth-jwt-service: {e}")
        return None
