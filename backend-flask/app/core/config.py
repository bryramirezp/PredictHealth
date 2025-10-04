# /backend-flask\app\core\config.py
# Flask configuration
import os

class Config:
    """Configuración base para la aplicación Flask"""
    
    # Configuración básica de Flask
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Configuración de base de datos
    DATABASE_URL = os.environ.get('DATABASE_URL') or 'postgresql://localhost/predictHealth'
    REDIS_URL = os.environ.get('REDIS_URL') or 'redis://localhost:6379/0'
    
    # Configuración JWT
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY')
    JWT_ALGORITHM = os.environ.get('JWT_ALGORITHM') or 'HS256'
    
    # URLs de microservicios
    JWT_SERVICE_URL = os.environ.get('JWT_SERVICE_URL') or 'http://servicio-auth-jwt:8003'
    DOCTOR_SERVICE_URL = os.environ.get('DOCTOR_SERVICE_URL') or 'http://servicio-doctores:8000'
    PATIENT_SERVICE_URL = os.environ.get('PATIENT_SERVICE_URL') or 'http://servicio-pacientes:8004'
    INSTITUTION_SERVICE_URL = os.environ.get('INSTITUTION_SERVICE_URL') or 'http://servicio-instituciones:8002'
    ADMIN_SERVICE_URL = os.environ.get('ADMIN_SERVICE_URL') or 'http://servicio-admins:8006'
    
    # Configuración de logging
    LOG_LEVEL = os.environ.get('LOG_LEVEL') or 'INFO'
    
    # Configuración de CORS
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', 'http://localhost:5000,http://localhost:3000').split(',')
    
    # Configuración de Flask
    FLASK_ENV = os.environ.get('FLASK_ENV') or 'development'
    FLASK_DEBUG = os.environ.get('FLASK_DEBUG', '1' if FLASK_ENV == 'development' else '0').lower() in ('1', 'true', 'yes')

class DevelopmentConfig(Config):
    """Configuración para desarrollo"""
    DEBUG = True
    FLASK_DEBUG = True

class ProductionConfig(Config):
    """Configuración para producción"""
    DEBUG = False
    FLASK_DEBUG = False

class TestingConfig(Config):
    """Configuración para testing"""
    TESTING = True
    DEBUG = True