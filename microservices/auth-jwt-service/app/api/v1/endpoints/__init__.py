# /microservices\service-jwt\app\api\v1\endpoints\__init__.py
# /microservices/service-jwt/app/api/v1/endpoints/__init__.py
# JWT service endpoints

from .jwt import router as jwt_router
from .auth import router as auth_router

__all__ = [
    'jwt_router',
    'auth_router'
]
