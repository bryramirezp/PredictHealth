# /backend-flask\app\services\auth_service.py
# /backend-flask/app/services/auth_service.py
# Servicio de autenticación actualizado para usar servicio-auth centralizado

import requests
import os
from typing import Dict, Any
import logging

logger = logging.getLogger(__name__)

class AuthService:
    """Servicio para manejar autenticación con servicio-auth centralizado"""
    
    def __init__(self):
        self.auth_service_url = os.getenv('JWT_SERVICE_URL', 'http://servicio-auth-jwt:8003')
        self.doctor_service_url = os.getenv('DOCTOR_SERVICE_URL', 'http://servicio-doctores:8000')
        self.patient_service_url = os.getenv('PATIENT_SERVICE_URL', 'http://servicio-pacientes:8004')
        self.institution_service_url = os.getenv('INSTITUTION_SERVICE_URL', 'http://servicio-instituciones:8002')
        self.admin_service_url = os.getenv('ADMIN_SERVICE_URL', 'http://servicio-admins:8006')
    
    def authenticate_user(self, email: str, password: str, user_type: str) -> Dict[str, Any]:
        """
        Autentica un usuario usando el servicio-auth centralizado
        
        Args:
            email: Email del usuario
            password: Contraseña del usuario
            user_type: Tipo de usuario (patient, doctor, institution, admin)
            
        Returns:
            Dict con resultado de autenticación
        """
        try:
            login_data = {
                'email': email,
                'password': password,
                'user_type': user_type
            }
            
            response = requests.post(
                f"{self.auth_service_url}/auth/login",
                json=login_data,
                timeout=10,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'success': True,
                    'access_token': data['access_token'],
                    'refresh_token': data['refresh_token'],
                    'user_id': data['user_id'],
                    'user_type': data['user_type'],
                    'email': data['email'],
                    'expires_in': data['expires_in']
                }
            else:
                error_msg = response.json().get('detail', 'Credenciales incorrectas') if response.status_code != 500 else 'Error de conexión'
                return {
                    'success': False,
                    'error': error_msg
                }
                
        except requests.exceptions.RequestException as e:
            return {
                'success': False,
                'error': f'Error de conexión: {str(e)}'
            }
        except Exception as e:
            return {
                'success': False,
                'error': f'Error inesperado: {str(e)}'
            }
    
    def register_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Registra un nuevo usuario usando el servicio-auth centralizado
        
        Args:
            user_data: Datos del usuario a registrar
            
        Returns:
            Dict con resultado de registro
        """
        try:
            response = requests.post(
                f"{self.auth_service_url}/auth/register",
                json=user_data,
                timeout=10,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'success': True,
                    'access_token': data['access_token'],
                    'refresh_token': data['refresh_token'],
                    'user_id': data['user_id'],
                    'user_type': data['user_type'],
                    'email': data['email'],
                    'expires_in': data['expires_in']
                }
            else:
                error_msg = response.json().get('detail', 'Error al registrar usuario') if response.status_code != 500 else 'Error de conexión'
                return {
                    'success': False,
                    'error': error_msg
                }
                
        except requests.exceptions.RequestException as e:
            return {
                'success': False,
                'error': f'Error de conexión: {str(e)}'
            }
        except Exception as e:
            return {
                'success': False,
                'error': f'Error inesperado: {str(e)}'
            }
    
    def refresh_token(self, refresh_token: str) -> Dict[str, Any]:
        """
        Renueva un access token usando un refresh token
        
        Args:
            refresh_token: Refresh token válido
            
        Returns:
            Dict con nuevo access token
        """
        try:
            response = requests.post(
                f"{self.auth_service_url}/auth/refresh",
                json={"refresh_token": refresh_token},
                timeout=10,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'success': True,
                    'access_token': data['access_token'],
                    'refresh_token': data['refresh_token'],
                    'expires_in': data['expires_in']
                }
            else:
                error_msg = response.json().get('detail', 'Error renovando token') if response.status_code != 500 else 'Error de conexión'
                return {
                    'success': False,
                    'error': error_msg
                }
                
        except requests.exceptions.RequestException as e:
            return {
                'success': False,
                'error': f'Error de conexión: {str(e)}'
            }
        except Exception as e:
            return {
                'success': False,
                'error': f'Error inesperado: {str(e)}'
            }
    
    def verify_token(self, token: str) -> Dict[str, Any]:
        """
        Verifica un token JWT
        
        Args:
            token: Token JWT a verificar
            
        Returns:
            Dict con resultado de verificación
        """
        try:
            response = requests.get(
                f"{self.auth_service_url}/auth/verify",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'success': True,
                    'valid': data['valid'],
                    'user_id': data['user_id'],
                    'user_type': data['user_type'],
                    'email': data['email'],
                    'expires_at': data['expires_at']
                }
            else:
                return {
                    'success': False,
                    'error': 'Token inválido o expirado'
                }
                
        except requests.exceptions.RequestException as e:
            return {
                'success': False,
                'error': f'Error de conexión: {str(e)}'
            }
        except Exception as e:
            return {
                'success': False,
                'error': f'Error inesperado: {str(e)}'
            }
    
    def get_user_profile(self, token: str) -> Dict[str, Any]:
        """
        Obtiene el perfil del usuario autenticado
        
        Args:
            token: Token JWT del usuario
            
        Returns:
            Dict con perfil del usuario
        """
        try:
            response = requests.get(
                f"{self.auth_service_url}/auth/me",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'success': True,
                    'profile': data
                }
            else:
                error_msg = response.json().get('detail', 'Error obteniendo perfil') if response.status_code != 500 else 'Error de conexión'
                return {
                    'success': False,
                    'error': error_msg
                }
                
        except requests.exceptions.RequestException as e:
            return {
                'success': False,
                'error': f'Error de conexión: {str(e)}'
            }
        except Exception as e:
            return {
                'success': False,
                'error': f'Error inesperado: {str(e)}'
            }
    
    # Métodos de compatibilidad con la API anterior
    def authenticate_patient(self, email: str, password: str) -> Dict[str, Any]:
        """Autentica un paciente"""
        return self.authenticate_user(email, password, 'patient')
    
    def authenticate_doctor(self, email: str, password: str) -> Dict[str, Any]:
        """Autentica un doctor"""
        return self.authenticate_user(email, password, 'doctor')
    
    def authenticate_institution(self, email: str, password: str) -> Dict[str, Any]:
        """Autentica una institución"""
        return self.authenticate_user(email, password, 'institution')
    
    def authenticate_admin(self, email: str, password: str) -> Dict[str, Any]:
        """Autentica un administrador"""
        return self.authenticate_user(email, password, 'admin')
