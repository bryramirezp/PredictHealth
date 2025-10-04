# /microservices\service-doctors\app\api\v1\endpoints\__init__.py
# /microservicios/servicio-doctores/app/api/v1/endpoints/__init__.py
# Importaciones de endpoints de doctores

from .doctors import router as doctors_router

__all__ = [
    'doctors_router'
]
