# /backend/servicio-pacientes/doctor_service.py

import requests
import os
from fastapi import HTTPException, status

URL_SERVICIO_DOCTORES = os.getenv("URL_SERVICIO_DOCTORES", "http://localhost:8000")

def validar_doctor_existe(doctor_id: str) -> bool:
    """
    Valida que un doctor existe y está activo llamando al servicio de doctores
    """
    try:
        response = requests.get(f"{URL_SERVICIO_DOCTORES}/doctores/{doctor_id}")
        
        if response.status_code == 200:
            return True
        elif response.status_code == 404:
            return False
        else:
            # Para otros códigos de error, asumimos que el doctor no existe
            return False
            
    except requests.exceptions.RequestException:
        # Si no se puede conectar al servicio de doctores, lanzar error
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="No se pudo validar el doctor. El servicio de doctores no está disponible."
        )

def obtener_info_doctor(doctor_id: str) -> dict:
    """
    Obtiene información del doctor desde el servicio de doctores
    """
    try:
        response = requests.get(f"{URL_SERVICIO_DOCTORES}/doctores/{doctor_id}")
        response.raise_for_status()
        return response.json()
        
    except requests.exceptions.HTTPError as err:
        if err.response.status_code == 404:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"El doctor con ID '{doctor_id}' no existe o no está activo."
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Error al validar el doctor."
            )
    except requests.exceptions.RequestException:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="No se pudo comunicar con el servicio de doctores."
        )
