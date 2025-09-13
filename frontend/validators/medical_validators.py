# /frontend/validators/medical_validators.py
# Validadores médicos para el frontend

from shared_models.validators import (
    BloodPressureValidator, 
    GlucoseValidator, 
    WeightHeightValidator,
    MedicalMeasurementValidator
)
from typing import Dict, Any, List

class MedicalDataValidator:
    """Validador de datos médicos para el frontend"""
    
    def validate_measurements(self, measurements_data: Dict[str, Any]) -> Dict[str, Any]:
        """Valida datos de mediciones médicas"""
        errors = []
        
        try:
            # Validar presión arterial si está presente
            if 'bp_systolic' in measurements_data and 'bp_diastolic' in measurements_data:
                bp_data = {
                    'sistolica': int(measurements_data['bp_systolic']),
                    'diastolica': int(measurements_data['bp_diastolic'])
                }
                BloodPressureValidator(**bp_data)
            
            # Validar glucosa si está presente
            if 'glucose' in measurements_data:
                glucose_data = {'glucosa': float(measurements_data['glucose'])}
                GlucoseValidator(**glucose_data)
            
            # Validar peso y altura si están presentes
            if 'peso_kg' in measurements_data or 'altura_cm' in measurements_data:
                wh_data = {}
                if 'peso_kg' in measurements_data:
                    wh_data['peso_kg'] = float(measurements_data['peso_kg'])
                if 'altura_cm' in measurements_data:
                    wh_data['altura_cm'] = float(measurements_data['altura_cm'])
                WeightHeightValidator(**wh_data)
            
            return {'valid': True, 'errors': []}
            
        except Exception as e:
            errors.append(str(e))
            return {'valid': False, 'errors': errors}
    
    def validate_lifestyle_data(self, lifestyle_data: Dict[str, Any]) -> Dict[str, Any]:
        """Valida datos de estilo de vida"""
        errors = []
        
        try:
            # Validar actividad física
            if 'minutos_actividad_fisica_semanal' in lifestyle_data:
                activity = int(lifestyle_data['minutos_actividad_fisica_semanal'])
                if activity < 0:
                    errors.append("Los minutos de actividad física no pueden ser negativos")
                if activity > 10080:  # Más de una semana
                    errors.append("Los minutos de actividad física no pueden exceder una semana")
            
            # Validar campos booleanos
            boolean_fields = ['fumador', 'consumo_alcohol', 'diagnostico_hipertension', 
                            'diagnostico_colesterol_alto', 'antecedente_acv', 'antecedente_enf_cardiaca']
            
            for field in boolean_fields:
                if field in lifestyle_data:
                    value = lifestyle_data[field]
                    if not isinstance(value, bool) and value not in ['true', 'false', '0', '1']:
                        errors.append(f"El campo {field} debe ser verdadero o falso")
            
            # Validar notas adicionales
            if 'condiciones_preexistentes_notas' in lifestyle_data:
                notes = lifestyle_data['condiciones_preexistentes_notas']
                if isinstance(notes, str) and len(notes) > 1000:
                    errors.append("Las notas adicionales no pueden exceder 1000 caracteres")
            
            return {'valid': len(errors) == 0, 'errors': errors}
            
        except Exception as e:
            errors.append(f"Error de validación: {str(e)}")
            return {'valid': False, 'errors': errors}
    
    def validate_patient_registration(self, patient_data: Dict[str, Any]) -> Dict[str, Any]:
        """Valida datos de registro de paciente"""
        errors = []
        
        try:
            # Validar campos requeridos
            required_fields = ['nombre', 'apellido', 'email', 'fecha_nacimiento', 'genero', 'password']
            for field in required_fields:
                if field not in patient_data or not patient_data[field]:
                    errors.append(f"El campo {field} es requerido")
            
            # Validar email
            if 'email' in patient_data:
                email = patient_data['email']
                if '@' not in email or '.' not in email:
                    errors.append("Formato de email inválido")
            
            # Validar fecha de nacimiento
            if 'fecha_nacimiento' in patient_data:
                from datetime import datetime
                try:
                    datetime.strptime(patient_data['fecha_nacimiento'], '%Y-%m-%d')
                except ValueError:
                    errors.append("Formato de fecha inválido. Use YYYY-MM-DD")
            
            # Validar género
            if 'genero' in patient_data:
                valid_genders = ['Masculino', 'Femenino', 'Otro']
                if patient_data['genero'] not in valid_genders:
                    errors.append(f"Género inválido. Valores permitidos: {', '.join(valid_genders)}")
            
            # Validar contraseña
            if 'password' in patient_data:
                password = patient_data['password']
                if len(password) < 8:
                    errors.append("La contraseña debe tener al menos 8 caracteres")
            
            return {'valid': len(errors) == 0, 'errors': errors}
            
        except Exception as e:
            errors.append(f"Error de validación: {str(e)}")
            return {'valid': False, 'errors': errors}
    
    def validate_doctor_registration(self, doctor_data: Dict[str, Any]) -> Dict[str, Any]:
        """Valida datos de registro de doctor"""
        errors = []
        
        try:
            # Validar campos requeridos
            required_fields = ['nombre', 'apellido', 'email', 'licencia_medica', 'password']
            for field in required_fields:
                if field not in doctor_data or not doctor_data[field]:
                    errors.append(f"El campo {field} es requerido")
            
            # Validar email
            if 'email' in doctor_data:
                email = doctor_data['email']
                if '@' not in email or '.' not in email:
                    errors.append("Formato de email inválido")
            
            # Validar licencia médica
            if 'licencia_medica' in doctor_data:
                license_num = doctor_data['licencia_medica']
                if len(license_num) < 5:
                    errors.append("La licencia médica debe tener al menos 5 caracteres")
            
            # Validar contraseña
            if 'password' in doctor_data:
                password = doctor_data['password']
                if len(password) < 8:
                    errors.append("La contraseña debe tener al menos 8 caracteres")
            
            return {'valid': len(errors) == 0, 'errors': errors}
            
        except Exception as e:
            errors.append(f"Error de validación: {str(e)}")
            return {'valid': False, 'errors': errors}
