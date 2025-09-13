# /shared_models/nomenclature_standards.py
# Estándares de nomenclatura para PredictHealth

from typing import Dict, Any, List
from enum import Enum

class NomenclatureStandards:
    """Estándares de nomenclatura para todo el sistema PredictHealth"""
    
    # TIPOS DE USUARIO
    USER_TYPES = {
        'patient': 'paciente',
        'doctor': 'doctor',
        'admin': 'administrador'
    }
    
    # CAMPOS DE DATOS PERSONALES
    PERSONAL_FIELDS = {
        'id': 'id',
        'nombre': 'nombre',
        'apellido': 'apellido',
        'email': 'email',
        'fecha_nacimiento': 'fecha_nacimiento',
        'genero': 'genero',
        'password': 'password',
        'activo': 'activo',
        'fecha_creacion': 'fecha_creacion',
        'fecha_actualizacion': 'fecha_actualizacion'
    }
    
    # CAMPOS MÉDICOS
    MEDICAL_FIELDS = {
        'altura_cm': 'altura_cm',
        'peso_kg': 'peso_kg',
        'imc': 'imc',
        'presion_sistolica': 'presion_sistolica',
        'presion_diastolica': 'presion_diastolica',
        'glucosa': 'glucosa',
        'temperatura': 'temperatura',
        'frecuencia_cardiaca': 'frecuencia_cardiaca',
        'saturacion_oxigeno': 'saturacion_oxigeno'
    }
    
    # FACTORES DE RIESGO
    RISK_FACTORS = {
        'fumador': 'fumador',
        'consumo_alcohol': 'consumo_alcohol',
        'diagnostico_hipertension': 'diagnostico_hipertension',
        'diagnostico_colesterol_alto': 'diagnostico_colesterol_alto',
        'antecedente_acv': 'antecedente_acv',
        'antecedente_enf_cardiaca': 'antecedente_enf_cardiaca',
        'minutos_actividad_fisica_semanal': 'minutos_actividad_fisica_semanal'
    }
    
    # TIPOS DE MEDICIONES
    MEASUREMENT_TYPES = {
        'presion_arterial_sistolica': 'presion_arterial_sistolica',
        'presion_arterial_diastolica': 'presion_arterial_diastolica',
        'glucosa': 'glucosa',
        'peso': 'peso',
        'altura': 'altura',
        'temperatura': 'temperatura',
        'frecuencia_cardiaca': 'frecuencia_cardiaca',
        'saturacion_oxigeno': 'saturacion_oxigeno',
        'colesterol_total': 'colesterol_total',
        'colesterol_ldl': 'colesterol_ldl',
        'colesterol_hdl': 'colesterol_hdl',
        'trigliceridos': 'trigliceridos'
    }
    
    # TIPOS DE RIESGO
    RISK_TYPES = {
        'diabetes_tipo_2': 'diabetes_tipo_2',
        'hipertension': 'hipertension',
        'enfermedad_cardiaca': 'enfermedad_cardiaca',
        'acv': 'acv'
    }
    
    # NIVELES DE RIESGO
    RISK_LEVELS = {
        'bajo': 'Bajo',
        'moderado': 'Moderado',
        'alto': 'Alto'
    }
    
    # ESTADOS DE RECOMENDACIONES
    RECOMMENDATION_STATES = {
        'pendiente': 'pendiente',
        'leida': 'leida',
        'aplicada': 'aplicada',
        'rechazada': 'rechazada'
    }
    
    # TIPOS DE RECOMENDACIONES
    RECOMMENDATION_TYPES = {
        'urgente': 'urgente',
        'preventivo': 'preventivo',
        'general': 'general',
        'seguimiento': 'seguimiento'
    }
    
    # UNIDADES DE MEDIDA
    MEASUREMENT_UNITS = {
        'mmHg': 'mmHg',
        'mg/dL': 'mg/dL',
        'kg': 'kg',
        'cm': 'cm',
        '°C': '°C',
        'bpm': 'bpm',
        '%': '%'
    }
    
    # FUENTES DE DATOS
    DATA_SOURCES = {
        'usuario_web': 'usuario_web',
        'doctor_registro': 'doctor_registro',
        'dispositivo_medico': 'dispositivo_medico',
        'laboratorio': 'laboratorio',
        'importacion': 'importacion'
    }

class DataTransferObjects:
    """DTOs para transferencia de datos entre frontend y backend"""
    
    @staticmethod
    def patient_to_frontend(patient_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convierte datos de paciente del backend al formato del frontend"""
        return {
            'id_paciente': patient_data.get('id_usuario'),
            'nombre': patient_data.get('nombre'),
            'apellido': patient_data.get('apellido'),
            'email': patient_data.get('email'),
            'fecha_nacimiento': patient_data.get('fecha_nacimiento'),
            'genero': patient_data.get('genero'),
            'activo': patient_data.get('activo'),
            'fecha_creacion': patient_data.get('fecha_creacion'),
            'id_doctor': patient_data.get('id_doctor')
        }
    
    @staticmethod
    def patient_from_frontend(patient_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convierte datos de paciente del frontend al formato del backend"""
        return {
            'id_usuario': patient_data.get('id_paciente'),
            'nombre': patient_data.get('nombre'),
            'apellido': patient_data.get('apellido'),
            'email': patient_data.get('email'),
            'fecha_nacimiento': patient_data.get('fecha_nacimiento'),
            'genero': patient_data.get('genero'),
            'activo': patient_data.get('activo', True),
            'id_doctor': patient_data.get('id_doctor')
        }
    
    @staticmethod
    def measurement_to_frontend(measurement_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convierte datos de medición del backend al formato del frontend"""
        return {
            'id_medicion': measurement_data.get('id_dato_biometrico'),
            'tipo_medida': measurement_data.get('tipo_medida'),
            'valor': float(measurement_data.get('valor', 0)),
            'unidad': measurement_data.get('unidad'),
            'fecha_medida': measurement_data.get('fecha_hora_medida'),
            'fuente_dato': measurement_data.get('fuente_dato'),
            'notas': measurement_data.get('notas')
        }
    
    @staticmethod
    def measurement_from_frontend(measurement_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convierte datos de medición del frontend al formato del backend"""
        return {
            'id_dato_biometrico': measurement_data.get('id_medicion'),
            'tipo_medida': measurement_data.get('tipo_medida'),
            'valor': measurement_data.get('valor'),
            'unidad': measurement_data.get('unidad'),
            'fecha_hora_medida': measurement_data.get('fecha_medida'),
            'fuente_dato': measurement_data.get('fuente_dato', 'usuario_web'),
            'notas': measurement_data.get('notas')
        }
    
    @staticmethod
    def prediction_to_frontend(prediction_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convierte datos de predicción del backend al formato del frontend"""
        return {
            'id_prediccion': prediction_data.get('id_prediccion'),
            'tipo_riesgo': prediction_data.get('tipo_riesgo'),
            'puntuacion_riesgo': float(prediction_data.get('puntuacion_riesgo', 0)),
            'nivel_riesgo': prediction_data.get('nivel_riesgo'),
            'factores_contribuyentes': prediction_data.get('factores_contribuyentes', []),
            'detalles_prediccion': prediction_data.get('detalles_prediccion'),
            'fecha_prediccion': prediction_data.get('fecha_prediccion'),
            'algoritmo_version': prediction_data.get('algoritmo_version', '1.0')
        }
    
    @staticmethod
    def recommendation_to_frontend(recommendation_data: Dict[str, Any]) -> Dict[str, Any]:
        """Convierte datos de recomendación del backend al formato del frontend"""
        return {
            'id_recomendacion': recommendation_data.get('id_recomendacion'),
            'contenido': recommendation_data.get('contenido_es'),
            'tipo': recommendation_data.get('tipo_recomendacion', 'general'),
            'estado': recommendation_data.get('estado_recomendacion', 'pendiente'),
            'fecha_generacion': recommendation_data.get('fecha_generacion'),
            'feedback_doctor': recommendation_data.get('feedback_doctor'),
            'id_prediccion': recommendation_data.get('id_prediccion')
        }

class FieldMapping:
    """Mapeo de campos entre diferentes capas del sistema"""
    
    # Mapeo de campos del formulario frontend a campos del backend
    FORM_TO_BACKEND_MAPPING = {
        # Campos de mediciones
        'bp_systolic': 'presion_sistolica',
        'bp_diastolic': 'presion_diastolica',
        'glucose': 'glucosa',
        'weight': 'peso_kg',
        'height': 'altura_cm',
        
        # Campos de estilo de vida
        'smoker': 'fumador',
        'alcohol_consumption': 'consumo_alcohol',
        'physical_activity': 'minutos_actividad_fisica_semanal',
        'hypertension': 'diagnostico_hipertension',
        'high_cholesterol': 'diagnostico_colesterol_alto',
        'stroke_history': 'antecedente_acv',
        'heart_disease_history': 'antecedente_enf_cardiaca',
        'additional_notes': 'condiciones_preexistentes_notas'
    }
    
    # Mapeo inverso: backend a frontend
    BACKEND_TO_FORM_MAPPING = {v: k for k, v in FORM_TO_BACKEND_MAPPING.items()}
    
    @classmethod
    def map_form_to_backend(cls, form_data: Dict[str, Any]) -> Dict[str, Any]:
        """Mapea datos del formulario frontend al formato del backend"""
        mapped_data = {}
        for frontend_field, value in form_data.items():
            backend_field = cls.FORM_TO_BACKEND_MAPPING.get(frontend_field, frontend_field)
            mapped_data[backend_field] = value
        return mapped_data
    
    @classmethod
    def map_backend_to_form(cls, backend_data: Dict[str, Any]) -> Dict[str, Any]:
        """Mapea datos del backend al formato del formulario frontend"""
        mapped_data = {}
        for backend_field, value in backend_data.items():
            frontend_field = cls.BACKEND_TO_FORM_MAPPING.get(backend_field, backend_field)
            mapped_data[frontend_field] = value
        return mapped_data

class ValidationRules:
    """Reglas de validación estándar para todo el sistema"""
    
    # Rangos válidos para mediciones médicas
    MEDICAL_RANGES = {
        'presion_sistolica': {'min': 50, 'max': 250, 'unit': 'mmHg'},
        'presion_diastolica': {'min': 30, 'max': 150, 'unit': 'mmHg'},
        'glucosa': {'min': 30, 'max': 600, 'unit': 'mg/dL'},
        'peso_kg': {'min': 10, 'max': 300, 'unit': 'kg'},
        'altura_cm': {'min': 50, 'max': 250, 'unit': 'cm'},
        'temperatura': {'min': 35, 'max': 42, 'unit': '°C'},
        'frecuencia_cardiaca': {'min': 40, 'max': 200, 'unit': 'bpm'},
        'saturacion_oxigeno': {'min': 70, 'max': 100, 'unit': '%'}
    }
    
    # Formatos de fecha válidos
    DATE_FORMATS = ['%Y-%m-%d', '%d/%m/%Y', '%m/%d/%Y']
    
    # Géneros válidos
    VALID_GENDERS = ['Masculino', 'Femenino', 'Otro']
    
    # Tipos de riesgo válidos
    VALID_RISK_TYPES = list(NomenclatureStandards.RISK_TYPES.keys())
    
    # Niveles de riesgo válidos
    VALID_RISK_LEVELS = list(NomenclatureStandards.RISK_LEVELS.values())
    
    @classmethod
    def validate_medical_value(cls, measurement_type: str, value: float) -> bool:
        """Valida que un valor médico esté dentro del rango permitido"""
        if measurement_type not in cls.MEDICAL_RANGES:
            return False
        
        range_config = cls.MEDICAL_RANGES[measurement_type]
        return range_config['min'] <= value <= range_config['max']
    
    @classmethod
    def get_validation_message(cls, measurement_type: str) -> str:
        """Obtiene mensaje de validación para un tipo de medición"""
        if measurement_type not in cls.MEDICAL_RANGES:
            return "Tipo de medición no válido"
        
        range_config = cls.MEDICAL_RANGES[measurement_type]
        return f"Valor debe estar entre {range_config['min']} y {range_config['max']} {range_config['unit']}"
