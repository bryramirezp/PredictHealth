# /backend/shared_models/security_config.py
# Configuración de seguridad para sistema médico

import os
from typing import List
import secrets

class SecurityConfig:
    """Configuración centralizada de seguridad para PredictHealth"""
    
    # Configuración de CORS para producción
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:5001",
        "http://localhost:3000",
        "https://predicthealth.com",  # Dominio de producción
        "https://www.predicthealth.com"
    ]
    
    # Configuración de CORS para desarrollo
    DEVELOPMENT_ORIGINS: List[str] = [
        "http://localhost:*",
        "http://127.0.0.1:*",
        "http://0.0.0.0:*"
    ]
    
    @classmethod
    def get_cors_origins(cls) -> List[str]:
        """Obtiene los orígenes CORS permitidos según el entorno"""
        if os.getenv('FLASK_ENV') == 'development':
            return cls.DEVELOPMENT_ORIGINS
        return cls.ALLOWED_ORIGINS
    
    @classmethod
    def get_secret_key(cls) -> str:
        """Genera o obtiene una clave secreta segura"""
        secret_key = os.getenv('SECRET_KEY')
        if not secret_key:
            # Generar clave secreta segura
            secret_key = secrets.token_urlsafe(32)
            print(f"⚠️  ADVERTENCIA: SECRET_KEY no configurada. Usando clave temporal: {secret_key}")
            print("   Configure SECRET_KEY en variables de entorno para producción")
        return secret_key
    
    @classmethod
    def get_database_url(cls) -> str:
        """Obtiene la URL de base de datos con validación de seguridad"""
        db_url = os.getenv('DATABASE_URL')
        if not db_url:
            raise ValueError("DATABASE_URL no configurada")
        
        # Validar que no sea una URL insegura
        if 'localhost' in db_url and os.getenv('FLASK_ENV') == 'production':
            raise ValueError("No usar localhost en producción")
        
        return db_url
    
    # Configuración de validación de datos médicos
    MEDICAL_DATA_RANGES = {
        'presion_sistolica': {'min': 50, 'max': 250},
        'presion_diastolica': {'min': 30, 'max': 150},
        'glucosa': {'min': 30, 'max': 600},
        'peso': {'min': 10, 'max': 300},
        'altura': {'min': 50, 'max': 250},
        'temperatura': {'min': 35, 'max': 42},
        'frecuencia_cardiaca': {'min': 40, 'max': 200},
        'saturacion_oxigeno': {'min': 70, 'max': 100}
    }
    
    # Configuración de logging de seguridad
    SECURITY_LOG_EVENTS = [
        'login_attempt',
        'login_success',
        'login_failure',
        'data_access',
        'data_modification',
        'prediction_generated',
        'recommendation_created',
        'unauthorized_access',
        'suspicious_activity'
    ]
    
    @classmethod
    def validate_medical_range(cls, measurement_type: str, value: float) -> bool:
        """Valida que un valor médico esté dentro del rango permitido"""
        if measurement_type not in cls.MEDICAL_DATA_RANGES:
            return False
        
        range_config = cls.MEDICAL_DATA_RANGES[measurement_type]
        return range_config['min'] <= value <= range_config['max']
    
    @classmethod
    def get_rate_limit_config(cls) -> dict:
        """Configuración de rate limiting para APIs"""
        return {
            'login_attempts': {'max': 5, 'window': 300},  # 5 intentos en 5 minutos
            'api_calls': {'max': 100, 'window': 3600},    # 100 llamadas por hora
            'predictions': {'max': 10, 'window': 3600},   # 10 predicciones por hora
            'data_upload': {'max': 50, 'window': 3600}    # 50 subidas por hora
        }
    
    # Configuración de encriptación
    ENCRYPTION_CONFIG = {
        'algorithm': 'AES-256-GCM',
        'key_length': 32,
        'iv_length': 12,
        'tag_length': 16
    }
    
    # Configuración de sesiones
    SESSION_CONFIG = {
        'permanent': False,
        'timeout': 3600,  # 1 hora
        'secure': True,   # Solo HTTPS en producción
        'httponly': True, # Prevenir acceso desde JavaScript
        'samesite': 'Lax'
    }
