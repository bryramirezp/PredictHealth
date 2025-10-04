# /microservices\service-institutions\app\main.py
# /microservices/service-institutions/app/main.py
# Main application for institutions service

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from contextlib import asynccontextmanager
import uvicorn
import logging

from app.core.config import settings
from app.core.database import init_db, get_db
from app.api.v1.endpoints import institutions

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.log_level),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifecycle manager"""
    # Startup
    try:
        logger.info("🚀 Starting PredictHealth Institutions Service...")

        # Initialize database
        init_db()

        logger.info("✅ Institutions Service started successfully")
        logger.info(f"📊 Configuración:")
        logger.info(f"   - Puerto: {settings.service_port}")
        logger.info(f"   - Host: {settings.service_host}")

    except Exception as e:
        logger.error(f"❌ Error starting service: {e}")
        raise

    yield

    # Shutdown
    logger.info("🛑 Shutting down Institutions Service...")

# Crear aplicación FastAPI
app = FastAPI(
    title="Servicio de Instituciones PredictHealth",
    description="API para gestión de instituciones médicas",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Include routers
app.include_router(institutions.router, prefix="/api/v1", tags=["institutions"])

@app.get("/", status_code=status.HTTP_200_OK)
def root():
    """Endpoint raíz del servicio"""
    return {
        "message": "Servicio de Instituciones PredictHealth",
        "version": "1.0.0",
        "status": "active",
        "docs": "/docs",
        "endpoints": {
            "institutions": "/api/v1/instituciones",
            "health": "/health",
            "info": "/info"
        }
    }

@app.get("/health", status_code=status.HTTP_200_OK)
def health_check():
    """Endpoint de salud del servicio"""
    return {
        "status": "healthy",
        "service": "service-institutions",
        "version": "1.0.0",
        "timestamp": "2024-01-01T00:00:00Z"
    }

@app.get("/info", status_code=status.HTTP_200_OK)
def service_info():
    """Información detallada del servicio"""
    return {
        "service": "service-institutions",
        "version": "1.0.0",
        "description": "API para gestión de instituciones médicas",
        "features": [
            "Gestión de instituciones médicas",
            "Búsqueda y filtrado",
            "Estadísticas de instituciones",
            "CRUD completo"
        ],
        "configuration": {
            "cors_origins": settings.cors_origins
        }
    }

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.service_host,
        port=settings.service_port,
        reload=True,
        log_level=settings.log_level.lower()
    )
