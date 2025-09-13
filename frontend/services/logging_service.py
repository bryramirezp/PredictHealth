# /frontend/services/logging_service.py
# Servicio de logging para el frontend

from shared_models.logging_config import frontend_logger

class LoggingService:
    """Servicio de logging para el frontend"""
    
    def __init__(self):
        self.logger = frontend_logger
    
    def log_user_action(self, user_id: str, action: str, details: dict = None):
        """Log de acciones del usuario"""
        self.logger.log_user_action(user_id, action, details)
    
    def log_medical_data_access(self, user_id: str, data_type: str, access_type: str):
        """Log de acceso a datos médicos"""
        self.logger.log_medical_data_access(user_id, data_type, access_type)
    
    def log_security_event(self, event_type: str, user_id: str = None, ip_address: str = None, details: dict = None):
        """Log de eventos de seguridad"""
        self.logger.log_security_event(event_type, user_id, ip_address, details)
    
    def log_error(self, error_type: str, error_message: str, user_id: str = None, additional_data: dict = None):
        """Log de errores del sistema"""
        self.logger.log_error(error_type, error_message, user_id, additional_data)
    
    def log_api_request(self, endpoint: str, method: str, user_id: str = None, status_code: int = None, response_time: float = None):
        """Log de requests API"""
        self.logger.log_api_request(endpoint, method, user_id, status_code, response_time)
