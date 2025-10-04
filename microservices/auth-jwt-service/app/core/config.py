# /microservices\service-jwt\app\core\config.py
# /microservices/service-jwt/app/core/config.py
# Central configuration for JWT service

import os
from typing import List
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """JWT service configuration"""
    
    # JWT configuration
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database
    DATABASE_URL: str = "postgresql://predictHealth_user:password@postgres:5432/predicthealth_db"

    # Redis
    REDIS_URL: str = "redis://redis:6379/0"
    
    # Service configuration
    SERVICE_NAME: str = "servicio-auth"
    SERVICE_HOST: str = "0.0.0.0"
    SERVICE_PORT: int = 8003
    
    # CORS
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:5000,http://localhost:8000"
    
    # Logging
    LOG_LEVEL: str = "INFO"
    
    # URLs of other services
    DOCTORS_SERVICE_URL: str = "http://servicio-doctores:8000"
    PATIENTS_SERVICE_URL: str = "http://servicio-pacientes:8004"
    INSTITUTIONS_SERVICE_URL: str = "http://servicio-instituciones:8002"
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Converts CORS_ORIGINS to a list"""
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

# Global configuration instance
settings = Settings()