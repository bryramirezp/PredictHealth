# /microservices\service-doctors\app\main.py
# FastAPI main app for doctors service
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.endpoints import doctors

app = FastAPI(
    title='Doctors Service',
    description='API para gestión de doctores médicos',
    version='1.0.0'
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5000", "http://localhost:8000"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(doctors.router, prefix="/api/v1", tags=["doctors"])

@app.get('/')
def root():
    return {
        'message': 'Doctors Service is running',
        'version': '1.0.0',
        'endpoints': {
            'doctors': '/api/v1/doctors',
            'health': '/health'
        }
    }

@app.get('/health')
def health():
    return {
        'status': 'healthy',
        'service': 'service-doctors',
        'version': '1.0.0',
        'timestamp': '2024-01-01T00:00:00Z'
    }
