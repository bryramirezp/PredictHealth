# /microservices\service-admins\app\main.py
# /microservices/service-admins/app/main.py
# FastAPI main app for admins service

import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import init_db
from app.api.v1 import api_v1

# Configurar logging
logging.basicConfig(
    level=getattr(logging, settings.log_level, logging.INFO),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manejar el ciclo de vida de la aplicación"""
    # Startup
    logger.info("🚀 Iniciando servicio de administradores...")
    init_db()
    logger.info("✅ Servicio de administradores iniciado correctamente")

    yield

    # Shutdown
    logger.info("🛑 Apagando servicio de administradores...")

# Crear aplicación FastAPI
app = FastAPI(
    title='Admins Service',
    description='API para gestión de administradores y creación de instituciones médicas',
    version='1.0.0',
    lifespan=lifespan
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(api_v1, prefix="/api/v1")

@app.get('/')
def root():
    """Endpoint raíz"""
    return {
        'message': 'Admins Service is running',
        'version': '1.0.0',
        'endpoints': {
            'admins': '/api/v1/admins',
            'health': '/health'
        }
    }

@app.get('/health')
def health():
    """Health check"""
    return {
        'status': 'healthy',
        'service': 'service-admins',
        'version': '1.0.0'
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.service_host,
        port=settings.service_port,
        reload=settings.debug
    )