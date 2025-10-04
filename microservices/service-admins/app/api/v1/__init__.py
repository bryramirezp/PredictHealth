# /microservices\service-admins\app\api\v1\__init__.py
# /microservices/service-admins/app/api/v1/__init__.py
# API v1 para el servicio de administradores

from fastapi import APIRouter
from .endpoints.admins import router as admins_router

# Crear router principal para API v1
api_v1 = APIRouter()

# Registrar sub-routers
api_v1.include_router(admins_router, prefix="/admins", tags=["admins"])

# Health endpoint
@api_v1.get("/health")
def health():
    """Health check para API v1"""
    return {
        "status": "healthy",
        "service": "service-admins",
        "version": "1.0.0",
        "endpoints": {
            "admins": "/api/v1/admins",
            "health": "/api/v1/health"
        }
    }