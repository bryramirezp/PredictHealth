# /microservices\service-institutions\app\core\config.py
# /microservices/service-institutions/app/core/config.py
# Configuration for institutions service

from pydantic_settings import BaseSettings
from typing import Optional, List
import os

class Settings(BaseSettings):
    """Configuration for institutions service"""

    # Application configuration
    app_name: str = "PredictHealth Institutions Service"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # Database configuration
    database_url: str = "postgresql://predictHealth_user:password@postgres:5432/predicthealth_db"

    # Service configuration
    service_host: str = "0.0.0.0"
    service_port: int = 8002
    
    # Logging configuration
    log_level: str = "INFO"
    
    # CORS configuration
    cors_origins: str = "http://localhost:3000,http://localhost:5000"

    @property
    def cors_origins_list(self) -> List[str]:
        """Converts cors_origins to a list"""
        return [origin.strip() for origin in self.cors_origins.split(",")]

    # External service URLs
    jwt_service_url: str = "http://servicio-auth-jwt:8003"
    doctors_service_url: str = "http://servicio-doctores:8000"
    patients_service_url: str = "http://servicio-pacientes:8004"
    institutions_service_url: str = "http://servicio-instituciones:8002"
    admin_service_url: str = "http://servicio-admins:8006"
    
    # Security configuration
    jwt_secret_key: str
    jwt_algorithm: str = "HS256"
    
    class Config:
        env_file = ".env"
        case_sensitive = False

# Global configuration instance
settings = Settings()
