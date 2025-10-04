# /microservices\service-patients\app\api\v1\endpoints\__init__.py
# /microservicios/servicio-pacientes/app/api/v1/endpoints/__init__.py
# Importaciones de endpoints de pacientes

from .patients import router as patients_router

__all__ = [
    'patients_router'
]
