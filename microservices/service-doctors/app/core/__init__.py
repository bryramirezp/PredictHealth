# /microservices\service-doctors\app\core\__init__.py
# /microservicios/servicio-doctores/app/core/__init__.py
# Importaciones del core

from .config import settings
from .database import get_db, init_db

__all__ = [
    'settings',
    'get_db',
    'init_db'
]
