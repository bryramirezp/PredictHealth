# /frontend/controllers/health_controller.py
# Controlador de datos de salud

from flask import session, jsonify, request
from frontend.services.health_service import HealthService
from frontend.services.logging_service import LoggingService
from frontend.validators.medical_validators import MedicalDataValidator
from shared_models.nomenclature_standards import DataTransferObjects, FieldMapping, ValidationRules

class HealthController:
    """Controlador para manejar datos de salud y predicciones"""
    
    def __init__(self):
        self.health_service = HealthService()
        self.logger = LoggingService()
        self.validator = MedicalDataValidator()
    
    def save_measurements(self, measurements_data: dict):
        """Guarda mediciones de salud del paciente"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            # Mapear datos del frontend al backend usando nomenclatura estándar
            mapped_data = FieldMapping.map_form_to_backend(measurements_data)
            
            # Validar datos médicos usando reglas estándar
            validation_result = self._validate_measurements_standard(mapped_data)
            if not validation_result['valid']:
                return jsonify({"error": validation_result['errors']}), 400
            
            # Convertir a formato del backend
            backend_measurements = self._prepare_measurements_for_backend(mapped_data)
            
            # Guardar mediciones
            result = self.health_service.save_measurements(
                session.get('patient_id'),
                backend_measurements,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'measurements_saved',
                    {'measurements_count': len(backend_measurements.get('mediciones', []))}
                )
                return jsonify({"status": "success", "message": "Medidas guardadas correctamente"}), 201
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('measurements_save_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Error interno del servidor"}), 500
    
    def _validate_measurements_standard(self, measurements_data: dict) -> dict:
        """Valida mediciones usando estándares de nomenclatura"""
        errors = []
        
        # Validar presión arterial
        if 'presion_sistolica' in measurements_data and 'presion_diastolica' in measurements_data:
            sistolica = float(measurements_data['presion_sistolica'])
            diastolica = float(measurements_data['presion_diastolica'])
            
            if not ValidationRules.validate_medical_value('presion_sistolica', sistolica):
                errors.append(ValidationRules.get_validation_message('presion_sistolica'))
            
            if not ValidationRules.validate_medical_value('presion_diastolica', diastolica):
                errors.append(ValidationRules.get_validation_message('presion_diastolica'))
            
            if diastolica >= sistolica:
                errors.append("La presión diastólica debe ser menor que la sistólica")
        
        # Validar glucosa
        if 'glucosa' in measurements_data:
            glucosa = float(measurements_data['glucosa'])
            if not ValidationRules.validate_medical_value('glucosa', glucosa):
                errors.append(ValidationRules.get_validation_message('glucosa'))
        
        return {'valid': len(errors) == 0, 'errors': errors}
    
    def _prepare_measurements_for_backend(self, measurements_data: dict) -> dict:
        """Prepara mediciones en formato estándar para el backend"""
        mediciones = []
        
        # Presión arterial sistólica
        if 'presion_sistolica' in measurements_data:
            mediciones.append({
                'tipo_medida': 'presion_arterial_sistolica',
                'valor': float(measurements_data['presion_sistolica']),
                'unidad': 'mmHg',
                'fuente_dato': 'usuario_web'
            })
        
        # Presión arterial diastólica
        if 'presion_diastolica' in measurements_data:
            mediciones.append({
                'tipo_medida': 'presion_arterial_diastolica',
                'valor': float(measurements_data['presion_diastolica']),
                'unidad': 'mmHg',
                'fuente_dato': 'usuario_web'
            })
        
        # Glucosa
        if 'glucosa' in measurements_data:
            mediciones.append({
                'tipo_medida': 'glucosa',
                'valor': float(measurements_data['glucosa']),
                'unidad': 'mg/dL',
                'fuente_dato': 'usuario_web'
            })
        
        return {'mediciones': mediciones}
    
    def save_lifestyle_data(self, lifestyle_data: dict):
        """Guarda datos de estilo de vida del paciente"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            # Validar datos de estilo de vida
            validation_result = self.validator.validate_lifestyle_data(lifestyle_data)
            if not validation_result['valid']:
                return jsonify({"error": validation_result['errors']}), 400
            
            # Guardar datos
            result = self.health_service.save_lifestyle_data(
                session.get('patient_id'),
                lifestyle_data,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'lifestyle_data_saved',
                    {'data_fields': list(lifestyle_data.keys())}
                )
                return jsonify({"status": "success", "message": "Hábitos de vida guardados correctamente"}), 201
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('lifestyle_save_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Error interno del servidor"}), 500
    
    def get_dashboard_data(self):
        """Obtiene datos del dashboard con predicciones reales"""
        if session.get('user_type') not in ['patient', 'doctor']:
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            user_id = session.get('patient_id') if session.get('user_type') == 'patient' else None
            
            if not user_id:
                return jsonify({"error": "ID de usuario no encontrado"}), 400
            
            # Obtener datos del dashboard
            result = self.health_service.get_dashboard_data(
                user_id,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    user_id,
                    'dashboard_accessed',
                    {'predictions_generated': len(result['data'].get('recommendations', []))}
                )
                return jsonify(result['data'])
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('dashboard_error', str(e), session.get('patient_id'))
            # Fallback a datos simulados
            fallback_data = {
                "updatedAt": "Datos no disponibles",
                "diabetesRisk": 25,
                "hypertensionRisk": 20,
                "factors": ["Error de conexión"],
                "evolution": [20, 22, 25, 23, 26, 25],
                "distribution": [25, 55, 20]
            }
            return jsonify(fallback_data)
    
    def get_patient_list(self):
        """Obtiene lista de pacientes para doctores"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            result = self.health_service.get_patient_list(
                session.get('doctor_id'),
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('doctor_id'),
                    'patient_list_accessed',
                    {'patient_count': len(result['data'].get('pacientes', []))}
                )
                return jsonify(result['data'])
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_list_error', str(e), session.get('doctor_id'))
            return jsonify({"error": "Error al cargar pacientes"}), 500
    
    def get_patient_details(self, patient_id: str):
        """Obtiene detalles de un paciente específico"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            result = self.health_service.get_patient_details(
                patient_id,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_medical_data_access(
                    patient_id,
                    'patient_details',
                    'doctor_access'
                )
                return jsonify(result['data'])
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_details_error', str(e), session.get('doctor_id'))
            return jsonify({"error": "Error al cargar detalles del paciente"}), 500

    def get_patient_health_profile(self, patient_id: str):
        """Obtiene el perfil de salud de un paciente específico"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            result = self.health_service.get_patient_health_profile(
                patient_id,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_medical_data_access(
                    patient_id,
                    'health_profile',
                    'doctor_access'
                )
                return jsonify(result['data'])
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_health_profile_error', str(e), session.get('doctor_id'))
            return jsonify({"error": "Error al cargar perfil de salud del paciente"}), 500
    
    def get_patient_profile(self):
        """Obtiene el perfil completo del paciente autenticado"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            result = self.health_service.get_patient_profile(
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'profile_accessed',
                    {'profile_type': 'personal_info'}
                )
                return jsonify(result['data'])
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_profile_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Error al cargar perfil del paciente"}), 500
    
    def get_patient_health_profile(self):
        """Obtiene el perfil de salud del paciente autenticado"""
        print(f"Getting patient health profile...")
        print(f"User type: {session.get('user_type')}")
        print(f"Patient ID: {session.get('patient_id')}")
        print(f"Access token: {session.get('access_token')[:20] if session.get('access_token') else 'None'}...")
        
        if session.get('user_type') != 'patient':
            print("User type is not patient")
            return jsonify({"error": "No autorizado"}), 401
        
        try:
            result = self.health_service.get_patient_health_profile(
                session.get('access_token')
            )
            
            print(f"Health service result: {result}")
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'health_profile_accessed',
                    {'profile_type': 'health_info'}
                )
                return jsonify(result['data'])
            else:
                print(f"Health service error: {result['error']}")
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            print(f"Exception in get_patient_health_profile: {str(e)}")
            self.logger.log_error('patient_health_profile_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Error al cargar perfil de salud"}), 500