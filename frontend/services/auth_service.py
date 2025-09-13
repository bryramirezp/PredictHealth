# /frontend/services/auth_service.py
# Servicio de autenticación

import requests
import os
from typing import Dict, Any

class AuthService:
    """Servicio para manejar autenticación con microservicios"""
    
    def __init__(self):
        self.doctor_service_url = os.getenv('DOCTOR_SERVICE_URL', 'http://localhost:8000')
        self.patient_service_url = os.getenv('PATIENT_SERVICE_URL', 'http://localhost:8001')
    
    def authenticate_patient(self, email: str, password: str) -> Dict[str, Any]:
        """Autentica un paciente"""
        try:
            login_data = {
                'email': email,
                'password': password
            }
            
            response = requests.post(
                f"{self.patient_service_url}/pacientes/login",
                json=login_data,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'success': True,
                    'patient': data['paciente'],
                    'access_token': data['access_token']
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
    
    def authenticate_doctor(self, email: str, password: str) -> Dict[str, Any]:
        """Autentica un doctor"""
        try:
            login_data = {
                'email': email,
                'password': password
            }
            
            response = requests.post(
                f"{self.doctor_service_url}/doctores/login",
                json=login_data,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    'success': True,
                    'doctor': data['doctor'],
                    'access_token': data['access_token']
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
    
    def register_patient(self, patient_data: Dict[str, Any], doctor_token: str) -> Dict[str, Any]:
        """Registra un nuevo paciente"""
        try:
            headers = {'Authorization': f'Bearer {doctor_token}'}
            
            response = requests.post(
                f"{self.patient_service_url}/pacientes/",
                json=patient_data,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 201:
                data = response.json()
                return {
                    'success': True,
                    'patient': data
                }
            else:
                error_msg = response.json().get('detail', 'Error al registrar paciente') if response.status_code != 500 else 'Error de conexión'
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
    
    def register_doctor(self, doctor_data: Dict[str, Any]) -> Dict[str, Any]:
        """Registra un nuevo doctor"""
        try:
            response = requests.post(
                f"{self.doctor_service_url}/doctores/",
                json=doctor_data,
                timeout=10
            )
            
            if response.status_code == 201:
                data = response.json()
                return {
                    'success': True,
                    'doctor': data
                }
            else:
                error_msg = response.json().get('detail', 'Error al registrar doctor') if response.status_code != 500 else 'Error de conexión'
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
