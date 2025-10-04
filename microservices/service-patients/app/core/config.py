# /microservices\service-patients\app\core\config.py
# /microservicios/servicio-pacientes/app/core/config.py
# Configuración para el servicio de pacientes

from pydantic_settings import BaseSettings
from typing import Optional, List
import os

class Settings(BaseSettings):
    """Configuración del servicio de pacientes"""
    
    # Configuración de la aplicación
    app_name: str = "Servicio de Pacientes PredictHealth"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # Configuración de la base de datos
    database_url: str = "postgresql://predictHealth_user:password@postgres:5432/predicthealth_db"

    # Configuración de logging
    log_level: str = "INFO"

    # Configuración de servicios
    service_port: int = 8004
    service_host: str = "0.0.0.0"
    
    # Configuración de CORS
    cors_origins: str = "http://localhost:3000,http://localhost:5000"

    @property
    def cors_origins_list(self) -> List[str]:
        """Converts cors_origins to a list"""
        return [origin.strip() for origin in self.cors_origins.split(",")]
    
    # Configuración de servicios externos
    jwt_service_url: str = "http://servicio-auth-jwt:8003"
    doctors_service_url: str = "http://servicio-doctores:8000"
    patients_service_url: str = "http://servicio-pacientes:8004"
    institutions_service_url: str = "http://servicio-instituciones:8002"
    admin_service_url: str = "http://servicio-admins:8006"
    
    # Configuración de seguridad
    jwt_secret_key: str
    jwt_algorithm: str = "HS256"
    
    class Config:
        env_file = ".env"
        case_sensitive = False

# Instancia global de configuración
settings = Settings()