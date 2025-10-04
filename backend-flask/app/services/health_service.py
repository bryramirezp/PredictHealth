# /backend-flask\app\services\health_service.py
# /frontend/services/health_service.py
# Servicio de datos de salud

import requests
import os
from typing import Dict, Any
from datetime import datetime

class HealthService:
    """Servicio para manejar datos de salud y predicciones"""
    
    def __init__(self):
        self.patient_service_url = os.getenv('PATIENT_SERVICE_URL', 'http://servicio-pacientes:8000')
    
    def save_measurements(self, user_id: str, measurements_data: Dict[str, Any], access_token: str) -> Dict[str, Any]:
        """Guarda mediciones de salud"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            response = requests.post(
                f"{self.patient_service_url}/pacientes/me/medidas",
                json=measurements_data,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 201:
                return {
                    'success': True,
                    'data': response.json()
                }
            else:
                error_msg = response.json().get('detail', 'Error al guardar medidas') if response.status_code != 500 else 'Error de conexión'
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
    
    def save_lifestyle_data(self, user_id: str, lifestyle_data: Dict[str, Any], access_token: str) -> Dict[str, Any]:
        """Guarda datos de estilo de vida"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            response = requests.post(
                f"{self.patient_service_url}/pacientes/me/perfil-salud",
                json=lifestyle_data,
                headers=headers,
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                return {
                    'success': True,
                    'data': response.json()
                }
            else:
                error_msg = response.json().get('detail', 'Error al guardar hábitos') if response.status_code != 500 else 'Error de conexión'
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
    
    def get_dashboard_data(self, user_id: str, access_token: str) -> Dict[str, Any]:
        """Obtiene datos del dashboard con predicciones reales"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            # Obtener perfil de salud
            profile_response = requests.get(
                f"{self.patient_service_url}/pacientes/me/perfil-salud",
                headers=headers,
                timeout=10
            )
            
            # Obtener mediciones recientes
            measurements_response = requests.get(
                f"{self.patient_service_url}/pacientes/me/medidas?limit=10",
                headers=headers,
                timeout=10
            )
            
            # Preparar datos para predicción
            user_data = {}
            if profile_response.status_code == 200:
                profile_data = profile_response.json()
                user_data.update(profile_data)
            
            # Agregar datos de mediciones recientes
            if measurements_response.status_code == 200:
                measurements = measurements_response.json()
                for measurement in measurements[:3]:  # Últimas 3 mediciones
                    if measurement['tipo_medida'] == 'presion_arterial_sistolica':
                        user_data['presion_sistolica'] = float(measurement['valor'])
                    elif measurement['tipo_medida'] == 'presion_arterial_diastolica':
                        user_data['presion_diastolica'] = float(measurement['valor'])
                    elif measurement['tipo_medida'] == 'glucosa':
                        user_data['glucosa_actual'] = float(measurement['valor'])
            
            # Generar predicciones reales usando algoritmos
            # Como los algoritmos de predicción no están en uso, se devuelven datos simulados.
            # TODO: Implementar la lógica de predicción real cuando los algoritmos estén disponibles.
            dashboard_data = {
                "updatedAt": datetime.now().strftime("%d/%m/%Y, %H:%M:%S"),
                "diabetesRisk": 25, # Valor simulado
                "hypertensionRisk": 15, # Valor simulado
                "factors": ["Dieta", "Ejercicio", "Historial Familiar"], # Valores simulados
                "recommendations": ["Mantener dieta balanceada", "Realizar 30 min de ejercicio diario"], # Valores simulados
                "riskLevels": {
                    "diabetes": "low",
                    "hypertension": "low"
                },
                "evolution": [10, 12, 15, 13, 16, 18], # Datos de evolución simulados
                "distribution": [30, 50, 20] # Datos de distribución simulados
            }
            
            return {
                'success': True,
                'data': dashboard_data
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f'Error generando datos del dashboard: {str(e)}'
            }
    
    def get_patient_list(self, doctor_id: str, access_token: str) -> Dict[str, Any]:
        """Obtiene lista de pacientes para doctores"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            response = requests.get(
                f"{self.patient_service_url}/pacientes/?doctor_id={doctor_id}",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {
                    'success': True,
                    'data': response.json()
                }
            else:
                error_msg = response.json().get('detail', 'Error al cargar pacientes') if response.status_code != 500 else 'Error de conexión'
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
    
    def get_patient_details(self, patient_id: str, access_token: str) -> Dict[str, Any]:
        """Obtiene detalles de un paciente específico"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            response = requests.get(
                f"{self.patient_service_url}/pacientes/{patient_id}",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {
                    'success': True,
                    'data': response.json()
                }
            else:
                error_msg = response.json().get('detail', 'Paciente no encontrado') if response.status_code != 500 else 'Error de conexión'
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
    
    def get_patient_health_profile(self, patient_id: str, access_token: str) -> Dict[str, Any]:
        """Obtiene el perfil de salud de un paciente específico"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            response = requests.get(
                f"{self.patient_service_url}/pacientes/{patient_id}/perfil-salud",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {
                    'success': True,
                    'data': response.json()
                }
            else:
                error_msg = response.json().get('detail', 'Perfil de salud no encontrado') if response.status_code != 500 else 'Error de conexión'
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
    
    def get_patient_profile(self, access_token: str) -> Dict[str, Any]:
        """Obtiene el perfil completo del paciente autenticado"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            response = requests.get(
                f"{self.patient_service_url}/pacientes/me",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {
                    'success': True,
                    'data': response.json()
                }
            else:
                error_msg = response.json().get('detail', 'Perfil no encontrado') if response.status_code != 500 else 'Error de conexión'
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
    
    def get_patient_health_profile(self, access_token: str) -> Dict[str, Any]:
        """Obtiene el perfil de salud del paciente autenticado"""
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            
            response = requests.get(
                f"{self.patient_service_url}/pacientes/me/perfil-salud",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                return {
                    'success': True,
                    'data': response.json()
                }
            else:
                error_msg = response.json().get('detail', 'Perfil de salud no encontrado') if response.status_code != 500 else 'Error de conexión'
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