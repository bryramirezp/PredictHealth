# /backend/shared_models/validators.py
# Validadores médicos robustos para datos de salud

from pydantic import BaseModel, validator, Field
from typing import Optional, Union
from datetime import datetime, date
import re

class MedicalDataValidator(BaseModel):
    """Validador base para datos médicos"""
    
    email: Optional[str] = Field(None, description="Email del usuario")
    
    @validator('email')
    def validate_email(cls, v):
        if v is not None:
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if not re.match(email_pattern, v):
                raise ValueError('Formato de email inválido')
            return v.lower()
        return v

class BloodPressureValidator(MedicalDataValidator):
    """Validador específico para presión arterial"""
    sistolica: int = Field(..., ge=50, le=250, description="Presión sistólica entre 50-250 mmHg")
    diastolica: int = Field(..., ge=30, le=150, description="Presión diastólica entre 30-150 mmHg")
    
    @validator('diastolica')
    def validate_diastolic_vs_systolic(cls, v, values):
        if 'sistolica' in values and v >= values['sistolica']:
            raise ValueError('La presión diastólica debe ser menor que la sistólica')
        return v

class GlucoseValidator(MedicalDataValidator):
    """Validador específico para glucosa"""
    glucosa: float = Field(..., ge=30.0, le=600.0, description="Glucosa entre 30-600 mg/dL")

class WeightHeightValidator(MedicalDataValidator):
    """Validador para peso y altura"""
    peso_kg: Optional[float] = Field(None, ge=10.0, le=300.0, description="Peso entre 10-300 kg")
    altura_cm: Optional[float] = Field(None, ge=50.0, le=250.0, description="Altura entre 50-250 cm")
    
    @validator('peso_kg', 'altura_cm')
    def validate_numeric_precision(cls, v):
        if v is not None:
            # Redondear a 2 decimales para evitar problemas de precisión
            return round(float(v), 2)
        return v

class RiskScoreValidator(MedicalDataValidator):
    """Validador para puntuaciones de riesgo"""
    puntuacion: float = Field(..., ge=0.0, le=100.0, description="Puntuación de riesgo entre 0-100%")
    
    @validator('puntuacion')
    def validate_risk_score(cls, v):
        return round(float(v), 2)

class DateValidator(MedicalDataValidator):
    """Validador para fechas médicas"""
    fecha_nacimiento: str = Field(..., description="Fecha de nacimiento en formato YYYY-MM-DD")
    
    @validator('fecha_nacimiento')
    def validate_birth_date(cls, v):
        try:
            birth_date = datetime.strptime(v, '%Y-%m-%d').date()
            today = date.today()
            age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
            
            if age < 0 or age > 150:
                raise ValueError('Edad inválida')
            return v
        except ValueError as e:
            if 'time data' in str(e):
                raise ValueError('Formato de fecha inválido. Use YYYY-MM-DD')
            raise e

class MedicalMeasurementValidator(MedicalDataValidator):
    """Validador para mediciones médicas generales"""
    tipo_medida: str = Field(..., description="Tipo de medición")
    valor: float = Field(..., gt=0, description="Valor de la medición")
    unidad: str = Field(..., description="Unidad de medida")
    
    @validator('tipo_medida')
    def validate_measurement_type(cls, v):
        allowed_types = [
            'presion_arterial', 'glucosa', 'peso', 'altura', 'temperatura',
            'frecuencia_cardiaca', 'saturacion_oxigeno', 'colesterol_total',
            'colesterol_ldl', 'colesterol_hdl', 'trigliceridos'
        ]
        if v.lower() not in allowed_types:
            raise ValueError(f'Tipo de medición no válido. Tipos permitidos: {", ".join(allowed_types)}')
        return v.lower()
    
    @validator('valor')
    def validate_measurement_value(cls, v, values):
        if 'tipo_medida' in values:
            tipo = values['tipo_medida'].lower()
            if tipo == 'presion_arterial' and (v < 50 or v > 250):
                raise ValueError('Valor de presión arterial fuera del rango válido (50-250)')
            elif tipo == 'glucosa' and (v < 30 or v > 600):
                raise ValueError('Valor de glucosa fuera del rango válido (30-600)')
            elif tipo == 'peso' and (v < 10 or v > 300):
                raise ValueError('Valor de peso fuera del rango válido (10-300)')
            elif tipo == 'altura' and (v < 50 or v > 250):
                raise ValueError('Valor de altura fuera del rango válido (50-250)')
        return round(float(v), 2)
