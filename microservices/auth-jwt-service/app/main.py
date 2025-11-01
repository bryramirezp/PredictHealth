# /microservices\service-jwt\app\main.py
# FastAPI entry point, configures CORS and includes authentication routes

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import uvicorn
import logging

from app.core.config import settings
from app.services.jwt_service import jwt_service
from app.api.v1.endpoints import jwt_router, auth_router

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Crear aplicación FastAPI
app = FastAPI(
    title="Auth-JWT Service",
    description="Unified authentication and JWT token management service",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Include routers
app.include_router(jwt_router, tags=["jwt"])
app.include_router(auth_router, tags=["auth"])

@app.on_event("startup")
async def startup_event():
    """Application startup event"""
    try:
        logger.info("🚀 Starting PredictHealth Auth-JWT Service...")
        # Database initialization removed - tokens now stored in Redis only
        logger.info("✅ Auth-JWT Service started successfully (Redis-only token storage)")
        logger.info(f"📊 Configuration:")
        logger.info(f"   - Port: {settings.SERVICE_PORT}")
        logger.info(f"   - Host: {settings.SERVICE_HOST}")
        logger.info(f"   - Token expiration: {settings.ACCESS_TOKEN_EXPIRE_MINUTES} minutes")
        logger.info(f"   - Refresh token expiration: {settings.REFRESH_TOKEN_EXPIRE_DAYS} days")
        logger.info(f"   - Redis URL: {settings.REDIS_URL}")
    except Exception as e:
        logger.error(f"❌ Error starting service: {e}")
        raise

@app.on_event("shutdown")
async def shutdown_event():
    """Evento de cierre de la aplicación"""
    logger.info("🛑 Shutting down Auth-JWT Service...")

@app.get("/", status_code=status.HTTP_200_OK)
def root():
    """Endpoint raíz del servicio"""
    return {
        "message": "PredictHealth Auth-JWT Service",
        "version": "1.0.0",
        "status": "active",
        "docs": "/docs",
        "endpoints": {
            "login": "/auth/login",
            "logout": "/auth/logout",
            "create_tokens": "/tokens/create",
            "verify_token": "/tokens/verify",
            "refresh_token": "/tokens/refresh",
            "revoke_token": "/tokens/revoke",
            "health": "/health",
            "statistics": "/statistics"
        }
    }

@app.get("/health", status_code=status.HTTP_200_OK)
def health_check():
    """Endpoint de salud del servicio con verificación de Redis"""
    health_data = jwt_service.health_check()
    return {
        "status": health_data.get("status", "unknown"),
        "service": "auth-jwt-service",
        "version": "1.0.0",
        "redis_available": health_data.get("redis_available", False),
        "redis_pool_size": health_data.get("redis_pool_size", 0),
        "timestamp": "2024-01-01T00:00:00Z"
    }


@app.get("/statistics", status_code=status.HTTP_200_OK)
def get_statistics():
    """Get authentication statistics and metrics"""
    try:
        stats = jwt_service.get_statistics()
        return stats
    except Exception as e:
        logger.error(f"Error getting statistics: {e}")
        return {
            "service": "auth-jwt-service",
            "version": "1.0.0",
            "error": str(e),
            "timestamp": "2024-01-01T00:00:00Z"
        }

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.SERVICE_HOST,
        port=settings.SERVICE_PORT,
        reload=True,
        log_level=settings.LOG_LEVEL.lower()
    )


