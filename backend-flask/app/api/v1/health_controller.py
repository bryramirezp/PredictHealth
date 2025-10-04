# /backend-flask\app\api\v1\health_controller.py
# /backend-flask/app/api/v1/health_controller.py
# Health data controller

from flask import session, jsonify, request
from app.services.health_service import HealthService
from app.services.logging_service import LoggingService

class HealthController:
    """Controller to handle health data and predictions"""
    
    def __init__(self):
        self.health_service = HealthService()
        self.logger = LoggingService()
    
    def save_measurements(self, measurements_data: dict):
        """Save patient health measurements"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            # Map frontend data to backend using standard nomenclature
            # TODO: Implement FieldMapping class
            mapped_data = measurements_data  # Usar datos directamente por ahora

            # Validate measurements using standard rules
            validation_result = self._validate_measurements_standard(mapped_data)
            if not validation_result['valid']:
                return jsonify({"error": validation_result['errors']}), 400
            
            # Convert to backend format
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
                return jsonify({"status": "success", "message": "Measurements saved successfully"}), 201
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('measurements_save_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Internal server error"}), 500
    
    def _validate_measurements_standard(self, measurements_data: dict) -> dict:
        """Validate measurements using nomenclature standards"""
        errors = []
        
        # Validate blood pressure
        if 'presion_sistolica' in measurements_data and 'presion_diastolica' in measurements_data:
            sistolica = float(measurements_data['presion_sistolica'])
            diastolica = float(measurements_data['presion_diastolica'])

            # Basic blood pressure validation
            if sistolica < 70 or sistolica > 250:
                errors.append("Systolic blood pressure must be between 70 and 250 mmHg")

            if diastolica < 40 or diastolica > 150:
                errors.append("Diastolic blood pressure must be between 40 and 150 mmHg")

            if diastolica >= sistolica:
                errors.append("Diastolic pressure must be lower than systolic pressure")

        # Validate glucose
        if 'glucosa' in measurements_data:
            glucosa = float(measurements_data['glucosa'])
            # Basic glucose validation
            if glucosa < 20 or glucosa > 600:
                errors.append("Glucose value must be between 20 and 600 mg/dL")
        
        return {'valid': len(errors) == 0, 'errors': errors}
    
    def _prepare_measurements_for_backend(self, measurements_data: dict) -> dict:
        """Prepare measurements in backend standard format"""
        mediciones = []
        
        # Systolic blood pressure
        if 'presion_sistolica' in measurements_data:
            mediciones.append({
                'tipo_medida': 'presion_arterial_sistolica',
                'valor': float(measurements_data['presion_sistolica']),
                'unidad': 'mmHg',
                'fuente_dato': 'usuario_web'
            })
        
        # Diastolic blood pressure
        if 'presion_diastolica' in measurements_data:
            mediciones.append({
                'tipo_medida': 'presion_arterial_diastolica',
                'valor': float(measurements_data['presion_diastolica']),
                'unidad': 'mmHg',
                'fuente_dato': 'usuario_web'
            })
        
        # Glucose
        if 'glucosa' in measurements_data:
            mediciones.append({
                'tipo_medida': 'glucosa',
                'valor': float(measurements_data['glucosa']),
                'unidad': 'mg/dL',
                'fuente_dato': 'usuario_web'
            })
        
        return {'mediciones': mediciones}
    
    def save_lifestyle_data(self, lifestyle_data: dict):
        """Save patient lifestyle data"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            # Validate lifestyle data (basic validation)
            # TODO: Implement validator class
            validation_result = {'valid': True, 'errors': []}  # Validación básica por ahora
            if not validation_result['valid']:
                return jsonify({"error": validation_result['errors']}), 400
            
            # Save data
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
                return jsonify({"status": "success", "message": "Lifestyle data saved successfully"}), 201
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('lifestyle_save_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Internal server error"}), 500
    
    def get_dashboard_data(self):
        """Get dashboard data with real predictions"""
        if session.get('user_type') not in ['patient', 'doctor']:
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            user_id = session.get('patient_id') if session.get('user_type') == 'patient' else None
            
            if not user_id:
                return jsonify({"error": "User ID not found"}), 400
            
            # Get dashboard data
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
            # Fallback to mock data
            fallback_data = {
                "updatedAt": "Data unavailable",
                "diabetesRisk": 25,
                "hypertensionRisk": 20,
                "factors": ["Connection error"],
                "evolution": [20, 22, 25, 23, 26, 25],
                "distribution": [25, 55, 20]
            }
            return jsonify(fallback_data)
    
    def get_patient_list(self):
        """Get patient list for doctors"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "Unauthorized"}), 401
        
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
            return jsonify({"error": "Error loading patients"}), 500
    
    def get_patient_details(self, patient_id: str):
        """Get details of a specific patient"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "Unauthorized"}), 401
        
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
            return jsonify({"error": "Error loading patient details"}), 500

    def get_patient_health_profile(self, patient_id: str):
        """Get the health profile of a specific patient"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "Unauthorized"}), 401
        
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
            return jsonify({"error": "Error loading patient health profile"}), 500
    
    def get_patient_profile(self):
        """Get the full profile of the authenticated patient"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "Unauthorized"}), 401
        
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
            return jsonify({"error": "Error loading patient profile"}), 500
    
    def get_current_patient_health_profile(self):
        """Get the health profile of the authenticated patient"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "Unauthorized"}), 401

        try:
            result = self.health_service.get_patient_health_profile(
                session.get('access_token')
            )

            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'health_profile_accessed',
                    {'profile_type': 'health_info'}
                )
                return jsonify(result['data'])
            else:
                return jsonify({"error": result['error']}), 500

        except Exception as e:
            self.logger.log_error('patient_health_profile_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Error loading health profile"}), 500

    # --- MÉTODOS JSON PARA ENDPOINTS WEB ---
    
    def get_dashboard_data_json(self):
        """Get dashboard data in JSON format for web"""
        if session.get('user_type') not in ['patient', 'doctor']:
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            user_id = session.get('patient_id') if session.get('user_type') == 'patient' else None
            
            if not user_id:
                return jsonify({"error": "User ID not found"}), 400
            
            # Obtener datos del dashboard usando la misma lógica existente
            result = self.health_service.get_dashboard_data(
                user_id,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    user_id,
                    'dashboard_accessed_json',
                    {'predictions_generated': len(result['data'].get('recommendations', []))}
                )
                return jsonify(result['data']), 200
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('dashboard_json_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Internal server error"}), 500
    
    def save_measurements_json(self):
        """Save health measurements in JSON format for web"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            # Get JSON data from request
            measurements_data = request.get_json()
            
            if not measurements_data:
                return jsonify({"error": "Measurements data required"}), 400
            
            # Use the same validation logic
            validation_result = self._validate_measurements_standard(measurements_data)
            if not validation_result['valid']:
                return jsonify({"error": validation_result['errors']}), 400
            
            # Convert to backend format
            backend_measurements = self._prepare_measurements_for_backend(measurements_data)
            
            # Save measurements using existing service
            result = self.health_service.save_measurements(
                session.get('patient_id'),
                backend_measurements,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'measurements_saved_json',
                    {'measurements_count': len(backend_measurements.get('mediciones', []))}
                )
                return jsonify({"status": "success", "message": "Measurements saved successfully"}), 201
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('measurements_json_save_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Internal server error"}), 500
    
    def save_lifestyle_data_json(self):
        """Save lifestyle data in JSON format for web"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            # Get JSON data from request
            lifestyle_data = request.get_json()
            
            if not lifestyle_data:
                return jsonify({"error": "Lifestyle data required"}), 400
            
            # Save data using the existing service
            result = self.health_service.save_lifestyle_data(
                session.get('patient_id'),
                lifestyle_data,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'lifestyle_data_saved_json',
                    {'data_fields': list(lifestyle_data.keys())}
                )
                return jsonify({"status": "success", "message": "Lifestyle data saved successfully"}), 201
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('lifestyle_json_save_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Internal server error"}), 500
    
    def get_patient_list_json(self):
        """Get patient list in JSON format for web"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            result = self.health_service.get_patient_list(
                session.get('doctor_id'),
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('doctor_id'),
                    'patient_list_accessed_json',
                    {'patient_count': len(result['data'].get('pacientes', []))}
                )
                return jsonify(result['data']), 200
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_list_json_error', str(e), session.get('doctor_id'))
            return jsonify({"error": "Error loading patients"}), 500
    
    def get_patient_details_json(self, patient_id: str):
        """Get details of a specific patient in JSON format for web"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            result = self.health_service.get_patient_details(
                patient_id,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_medical_data_access(
                    patient_id,
                    'patient_details_json',
                    'doctor_access'
                )
                return jsonify(result['data']), 200
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_details_json_error', str(e), session.get('doctor_id'))
            return jsonify({"error": "Error loading patient details"}), 500
    
    def get_patient_health_profile_json(self, patient_id: str = None):
        """Get health profile in JSON format for web"""
        # Si no se proporciona patient_id, usar el paciente autenticado
        if patient_id is None:
            if session.get('user_type') != 'patient':
                return jsonify({"error": "Unauthorized"}), 401
            patient_id = session.get('patient_id')
        else:
            if session.get('user_type') != 'doctor':
                return jsonify({"error": "Unauthorized"}), 401
        
        try:
            if patient_id == session.get('patient_id'):
                # Perfil del paciente autenticado
                result = self.health_service.get_patient_health_profile(
                    session.get('access_token')
                )
            else:
                # Perfil de paciente específico (para doctores)
                result = self.health_service.get_patient_health_profile(
                    patient_id,
                    session.get('access_token')
                )
            
            if result['success']:
                self.logger.log_medical_data_access(
                    patient_id,
                    'health_profile_json',
                    'patient_access' if patient_id == session.get('patient_id') else 'doctor_access'
                )
                return jsonify(result['data']), 200
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_health_profile_json_error', str(e), patient_id)
            return jsonify({"error": "Error loading health profile"}), 500
    
    def get_patient_measurements_json(self, patient_id: str):
        """Get measurements of a specific patient in JSON format for web"""
        if session.get('user_type') != 'doctor':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            # Get patient measurements
            result = self.health_service.get_patient_measurements(
                patient_id,
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_medical_data_access(
                    patient_id,
                    'patient_measurements_json',
                    'doctor_access'
                )
                return jsonify(result['data']), 200
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_measurements_json_error', str(e), session.get('doctor_id'))
            return jsonify({"error": "Error loading patient measurements"}), 500
    
    def get_patient_profile_json(self):
        """Get the full profile of the authenticated patient in JSON format for web"""
        if session.get('user_type') != 'patient':
            return jsonify({"error": "Unauthorized"}), 401
        
        try:
            result = self.health_service.get_patient_profile(
                session.get('access_token')
            )
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('patient_id'),
                    'profile_accessed_json',
                    {'profile_type': 'personal_info'}
                )
                return jsonify(result['data']), 200
            else:
                return jsonify({"error": result['error']}), 500
                
        except Exception as e:
            self.logger.log_error('patient_profile_json_error', str(e), session.get('patient_id'))
            return jsonify({"error": "Error loading patient profile"}), 500