# /backend/shared_models/logging_config.py
# Configuración de logging estructurado para sistema médico

import logging
import sys
from datetime import datetime
from typing import Dict, Any
import json
import os

class MedicalSystemLogger:
    """Logger estructurado para sistema médico con niveles de criticidad"""
    
    def __init__(self, service_name: str):
        self.service_name = service_name
        self.logger = self._setup_logger()
    
    def _setup_logger(self) -> logging.Logger:
        """Configura el logger con formato estructurado"""
        logger = logging.getLogger(f"predicthealth.{self.service_name}")
        logger.setLevel(logging.INFO)
        
        # Evitar duplicación de handlers
        if logger.handlers:
            return logger
        
        # Handler para consola
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        
        # Formato estructurado JSON para producción
        formatter = logging.Formatter(
            '{"timestamp": "%(asctime)s", "service": "%(name)s", "level": "%(levelname)s", "message": "%(message)s", "module": "%(module)s", "function": "%(funcName)s", "line": %(lineno)d}',
            datefmt='%Y-%m-%dT%H:%M:%SZ'
        )
        console_handler.setFormatter(formatter)
        
        logger.addHandler(console_handler)
        
        # Handler para archivo si está configurado
        log_file = os.getenv('LOG_FILE_PATH')
        if log_file:
            file_handler = logging.FileHandler(log_file)
            file_handler.setLevel(logging.DEBUG)
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)
        
        return logger
    
    def log_user_action(self, user_id: str, action: str, details: Dict[str, Any] = None):
        """Log de acciones del usuario"""
        log_data = {
            "user_id": user_id,
            "action": action,
            "details": details or {},
            "timestamp": datetime.utcnow().isoformat()
        }
        self.logger.info(f"USER_ACTION: {json.dumps(log_data)}")
    
    def log_medical_data_access(self, user_id: str, data_type: str, access_type: str):
        """Log de acceso a datos médicos (crítico para HIPAA)"""
        log_data = {
            "user_id": user_id,
            "data_type": data_type,
            "access_type": access_type,
            "timestamp": datetime.utcnow().isoformat(),
            "compliance": "HIPAA_AUDIT"
        }
        self.logger.warning(f"MEDICAL_DATA_ACCESS: {json.dumps(log_data)}")
    
    def log_prediction_generated(self, user_id: str, prediction_type: str, risk_score: float, risk_level: str):
        """Log de predicciones generadas"""
        log_data = {
            "user_id": user_id,
            "prediction_type": prediction_type,
            "risk_score": risk_score,
            "risk_level": risk_level,
            "timestamp": datetime.utcnow().isoformat()
        }
        self.logger.info(f"PREDICTION_GENERATED: {json.dumps(log_data)}")
    
    def log_api_request(self, endpoint: str, method: str, user_id: str = None, status_code: int = None, response_time: float = None):
        """Log de requests API"""
        log_data = {
            "endpoint": endpoint,
            "method": method,
            "user_id": user_id,
            "status_code": status_code,
            "response_time_ms": response_time,
            "timestamp": datetime.utcnow().isoformat()
        }
        self.logger.info(f"API_REQUEST: {json.dumps(log_data)}")
    
    def log_error(self, error_type: str, error_message: str, user_id: str = None, additional_data: Dict[str, Any] = None):
        """Log de errores del sistema"""
        log_data = {
            "error_type": error_type,
            "error_message": error_message,
            "user_id": user_id,
            "additional_data": additional_data or {},
            "timestamp": datetime.utcnow().isoformat()
        }
        self.logger.error(f"SYSTEM_ERROR: {json.dumps(log_data)}")
    
    def log_security_event(self, event_type: str, user_id: str = None, ip_address: str = None, details: Dict[str, Any] = None):
        """Log de eventos de seguridad"""
        log_data = {
            "event_type": event_type,
            "user_id": user_id,
            "ip_address": ip_address,
            "details": details or {},
            "timestamp": datetime.utcnow().isoformat(),
            "severity": "SECURITY"
        }
        self.logger.critical(f"SECURITY_EVENT: {json.dumps(log_data)}")
    
    def log_performance_metric(self, metric_name: str, value: float, unit: str = None):
        """Log de métricas de rendimiento"""
        log_data = {
            "metric_name": metric_name,
            "value": value,
            "unit": unit,
            "timestamp": datetime.utcnow().isoformat()
        }
        self.logger.info(f"PERFORMANCE_METRIC: {json.dumps(log_data)}")

# Instancias globales para cada servicio
doctors_logger = MedicalSystemLogger("doctors-service")
patients_logger = MedicalSystemLogger("patients-service")
frontend_logger = MedicalSystemLogger("frontend")

def get_logger(service_name: str) -> MedicalSystemLogger:
    """Factory function para obtener logger de un servicio específico"""
    return MedicalSystemLogger(service_name)
