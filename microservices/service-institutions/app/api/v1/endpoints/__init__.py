# /microservices\service-institutions\app\api\v1\endpoints\__init__.py
# /microservicios/servicio-instituciones/api/v1/endpoints/__init__.py
# Importaciones de endpoints de instituciones

from .institutions import router as institutions_router

__all__ = [
    'institutions_router'
]
