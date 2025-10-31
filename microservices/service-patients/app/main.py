# /microservices\service-patients\app\main.py
# FastAPI main app for patients service
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.endpoints import patients

app = FastAPI(
    title='Patients Service',
    description='API for medical patients management',
    version='1.0.0',
    docs_url='/docs',
    redoc_url='/redoc'
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5000", "http://localhost:8000"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Include routers
app.include_router(patients.router, prefix="/api/v1", tags=["patients"])

@app.get('/')
def root():
    return {
        'message': 'Patients Service is running',
        'version': '1.0.0',
        'endpoints': {
            'patients': '/api/v1/patients',
            'health': '/health',
            'swagger_ui': '/docs',
            'redoc': '/redoc'
        }
    }

@app.get('/health')
def health():
    return {
        'status': 'healthy',
        'service': 'service-patients',
        'version': '1.0.0',
        'timestamp': '2024-01-01T00:00:00Z'
    }
