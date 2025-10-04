# /backend-flask\app\services\logging_service.py
# /app/services/logging_service.py
# Servicio de logging para PredictHealth

import logging
import os
from datetime import datetime
from typing import Dict, Any, Optional

class LoggingService:
    """Servicio para manejar logs del sistema"""
    
    def __init__(self):
        self.logger = logging.getLogger('predicthealth')
        self.logger.setLevel(logging.INFO)
        
        # Crear handler para archivo si no existe
        if not self.logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
    
    def log_user_action(self, user_id: str, action: str, metadata: Dict[str, Any] = None):
        """Registra una acción del usuario"""
        log_data = {
            'user_id': user_id,
            'action': action,
            'metadata': metadata or {},
            'timestamp': datetime.now().isoformat()
        }
        self.logger.info(f"User Action: {log_data}")
    
    def log_security_event(self, event_type: str, user_id: Optional[str], ip_address: str, metadata: Dict[str, Any] = None):
        """Registra un evento de seguridad"""
        log_data = {
            'event_type': event_type,
            'user_id': user_id,
            'ip_address': ip_address,
            'metadata': metadata or {},
            'timestamp': datetime.now().isoformat()
        }
        self.logger.warning(f"Security Event: {log_data}")
    
    def log_error(self, error_type: str, error_message: str, user_id: Optional[str] = None, metadata: Dict[str, Any] = None):
        """Registra un error del sistema"""
        log_data = {
            'error_type': error_type,
            'error_message': error_message,
            'user_id': user_id,
            'metadata': metadata or {},
            'timestamp': datetime.now().isoformat()
        }
        self.logger.error(f"System Error: {log_data}")
    
    def log_medical_data_access(self, patient_id: str, data_type: str, access_type: str):
        """Registra acceso a datos médicos"""
        log_data = {
            'patient_id': patient_id,
            'data_type': data_type,
            'access_type': access_type,
            'timestamp': datetime.now().isoformat()
        }
        self.logger.info(f"Medical Data Access: {log_data}")