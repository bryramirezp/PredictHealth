# /backend/shared_models/prediction_algorithms.py
# Algoritmos de predicción de riesgo de salud basados en datos médicos reales

from typing import Dict, List, Optional, Tuple
from datetime import datetime, date
from decimal import Decimal
import math

class HealthRiskPredictor:
    """Clase principal para predicciones de riesgo de salud"""
    
    def __init__(self):
        self.diabetes_risk_factors = {
            'age_weight': 0.3,
            'bmi_weight': 0.25,
            'family_history_weight': 0.2,
            'lifestyle_weight': 0.15,
            'glucose_weight': 0.1
        }
        
        self.hypertension_risk_factors = {
            'age_weight': 0.25,
            'bmi_weight': 0.3,
            'family_history_weight': 0.2,
            'lifestyle_weight': 0.15,
            'current_bp_weight': 0.1
        }

    def calculate_bmi(self, weight_kg: float, height_cm: float) -> float:
        """Calcula el IMC (Índice de Masa Corporal)"""
        if height_cm <= 0:
            raise ValueError("La altura debe ser mayor a 0")
        height_m = height_cm / 100
        return round(weight_kg / (height_m ** 2), 2)

    def get_age_from_birth_date(self, birth_date_str: str) -> int:
        """Calcula la edad a partir de la fecha de nacimiento"""
        try:
            birth_date = datetime.strptime(birth_date_str, '%Y-%m-%d').date()
            today = date.today()
            age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
            return age
        except ValueError:
            raise ValueError("Formato de fecha inválido")

    def predict_diabetes_risk(self, user_data: Dict) -> Dict:
        """
        Predice el riesgo de diabetes tipo 2 basado en factores de riesgo
        
        Args:
            user_data: Diccionario con datos del usuario y perfil de salud
            
        Returns:
            Dict con puntuación de riesgo, nivel y factores contribuyentes
        """
        try:
            # Calcular edad
            age = self.get_age_from_birth_date(user_data.get('fecha_nacimiento', ''))
            
            # Calcular IMC si tenemos peso y altura
            bmi = None
            if user_data.get('peso_kg') and user_data.get('altura_cm'):
                bmi = self.calculate_bmi(
                    float(user_data['peso_kg']), 
                    float(user_data['altura_cm'])
                )
            
            # Factor de edad (riesgo aumenta con la edad)
            age_score = min(age / 80 * 100, 100)  # Normalizado a 0-100
            
            # Factor de IMC
            bmi_score = 0
            if bmi:
                if bmi < 18.5:
                    bmi_score = 20  # Bajo peso
                elif 18.5 <= bmi < 25:
                    bmi_score = 30  # Peso normal
                elif 25 <= bmi < 30:
                    bmi_score = 50  # Sobrepeso
                elif 30 <= bmi < 35:
                    bmi_score = 70  # Obesidad grado I
                else:
                    bmi_score = 90  # Obesidad grado II+
            
            # Factor de historial familiar (simulado - en producción vendría de datos reales)
            family_history_score = 0
            if user_data.get('condiciones_preexistentes_notas'):
                notes = user_data['condiciones_preexistentes_notas'].lower()
                if any(keyword in notes for keyword in ['diabetes', 'diabético', 'azúcar']):
                    family_history_score = 60
            
            # Factor de estilo de vida
            lifestyle_score = 0
            if user_data.get('fumador'):
                lifestyle_score += 20
            if user_data.get('consumo_alcohol'):
                lifestyle_score += 15
            
            # Actividad física (inversamente proporcional al riesgo)
            activity_minutes = user_data.get('minutos_actividad_fisica_semanal', 0)
            if activity_minutes < 150:  # Menos de 2.5 horas por semana
                lifestyle_score += 25
            elif activity_minutes < 300:  # Entre 2.5-5 horas
                lifestyle_score += 10
            
            # Factor de glucosa actual (si está disponible)
            glucose_score = 0
            if user_data.get('glucosa_actual'):
                glucose = float(user_data['glucosa_actual'])
                if glucose > 126:  # Diabetes
                    glucose_score = 80
                elif glucose > 100:  # Prediabetes
                    glucose_score = 50
                elif glucose > 70:  # Normal
                    glucose_score = 20
                else:  # Hipoglucemia
                    glucose_score = 30
            
            # Calcular puntuación total ponderada
            total_score = (
                age_score * self.diabetes_risk_factors['age_weight'] +
                bmi_score * self.diabetes_risk_factors['bmi_weight'] +
                family_history_score * self.diabetes_risk_factors['family_history_weight'] +
                lifestyle_score * self.diabetes_risk_factors['lifestyle_weight'] +
                glucose_score * self.diabetes_risk_factors['glucose_weight']
            )
            
            # Determinar nivel de riesgo
            if total_score < 30:
                risk_level = "Bajo"
            elif total_score < 60:
                risk_level = "Moderado"
            else:
                risk_level = "Alto"
            
            # Factores contribuyentes
            contributing_factors = []
            if bmi and bmi >= 30:
                contributing_factors.append("IMC alto (obesidad)")
            if age > 45:
                contributing_factors.append("Edad avanzada")
            if family_history_score > 0:
                contributing_factors.append("Historial familiar")
            if lifestyle_score > 30:
                contributing_factors.append("Estilo de vida sedentario")
            if glucose_score > 50:
                contributing_factors.append("Glucosa elevada")
            
            return {
                'puntuacion_riesgo': round(total_score, 2),
                'nivel_riesgo': risk_level,
                'tipo_riesgo': 'diabetes_tipo_2',
                'factores_contribuyentes': contributing_factors,
                'detalles_prediccion': f"Riesgo de diabetes tipo 2: {risk_level} ({total_score:.1f}%)",
                'fecha_prediccion': datetime.now(),
                'metodologia': 'Algoritmo basado en factores de riesgo estándar (ADA Guidelines)'
            }
            
        except Exception as e:
            raise ValueError(f"Error en predicción de diabetes: {str(e)}")

    def predict_hypertension_risk(self, user_data: Dict) -> Dict:
        """
        Predice el riesgo de hipertensión basado en factores de riesgo
        
        Args:
            user_data: Diccionario con datos del usuario y perfil de salud
            
        Returns:
            Dict con puntuación de riesgo, nivel y factores contribuyentes
        """
        try:
            # Calcular edad
            age = self.get_age_from_birth_date(user_data.get('fecha_nacimiento', ''))
            
            # Calcular IMC
            bmi = None
            if user_data.get('peso_kg') and user_data.get('altura_cm'):
                bmi = self.calculate_bmi(
                    float(user_data['peso_kg']), 
                    float(user_data['altura_cm'])
                )
            
            # Factor de edad
            age_score = min(age / 80 * 100, 100)
            
            # Factor de IMC
            bmi_score = 0
            if bmi:
                if bmi < 25:
                    bmi_score = 20
                elif 25 <= bmi < 30:
                    bmi_score = 50
                else:
                    bmi_score = 80
            
            # Factor de historial familiar
            family_history_score = 0
            if user_data.get('diagnostico_hipertension'):
                family_history_score = 70
            elif user_data.get('condiciones_preexistentes_notas'):
                notes = user_data['condiciones_preexistentes_notas'].lower()
                if any(keyword in notes for keyword in ['hipertensión', 'presión alta', 'hta']):
                    family_history_score = 60
            
            # Factor de estilo de vida
            lifestyle_score = 0
            if user_data.get('fumador'):
                lifestyle_score += 30
            if user_data.get('consumo_alcohol'):
                lifestyle_score += 20
            
            # Actividad física
            activity_minutes = user_data.get('minutos_actividad_fisica_semanal', 0)
            if activity_minutes < 150:
                lifestyle_score += 25
            
            # Factor de presión arterial actual
            bp_score = 0
            if user_data.get('presion_sistolica') and user_data.get('presion_diastolica'):
                sistolica = float(user_data['presion_sistolica'])
                diastolica = float(user_data['presion_diastolica'])
                
                if sistolica >= 140 or diastolica >= 90:
                    bp_score = 80  # Hipertensión
                elif sistolica >= 130 or diastolica >= 80:
                    bp_score = 50  # Presión arterial elevada
                elif sistolica >= 120 or diastolica >= 80:
                    bp_score = 30  # Presión arterial normal-alta
                else:
                    bp_score = 10  # Normal
            
            # Calcular puntuación total
            total_score = (
                age_score * self.hypertension_risk_factors['age_weight'] +
                bmi_score * self.hypertension_risk_factors['bmi_weight'] +
                family_history_score * self.hypertension_risk_factors['family_history_weight'] +
                lifestyle_score * self.hypertension_risk_factors['lifestyle_weight'] +
                bp_score * self.hypertension_risk_factors['current_bp_weight']
            )
            
            # Determinar nivel de riesgo
            if total_score < 25:
                risk_level = "Bajo"
            elif total_score < 60:
                risk_level = "Moderado"
            else:
                risk_level = "Alto"
            
            # Factores contribuyentes
            contributing_factors = []
            if bmi and bmi >= 25:
                contributing_factors.append("IMC elevado")
            if age > 40:
                contributing_factors.append("Edad avanzada")
            if family_history_score > 0:
                contributing_factors.append("Historial de hipertensión")
            if lifestyle_score > 30:
                contributing_factors.append("Factores de estilo de vida")
            if bp_score > 50:
                contributing_factors.append("Presión arterial elevada")
            
            return {
                'puntuacion_riesgo': round(total_score, 2),
                'nivel_riesgo': risk_level,
                'tipo_riesgo': 'hipertension',
                'factores_contribuyentes': contributing_factors,
                'detalles_prediccion': f"Riesgo de hipertensión: {risk_level} ({total_score:.1f}%)",
                'fecha_prediccion': datetime.now(),
                'metodologia': 'Algoritmo basado en factores de riesgo cardiovascular (AHA Guidelines)'
            }
            
        except Exception as e:
            raise ValueError(f"Error en predicción de hipertensión: {str(e)}")

    def generate_health_recommendations(self, predictions: List[Dict], user_data: Dict) -> List[Dict]:
        """
        Genera recomendaciones médicas basadas en las predicciones de riesgo
        
        Args:
            predictions: Lista de predicciones de riesgo
            user_data: Datos del usuario
            
        Returns:
            Lista de recomendaciones personalizadas
        """
        recommendations = []
        
        for prediction in predictions:
            risk_type = prediction['tipo_riesgo']
            risk_level = prediction['nivel_riesgo']
            factors = prediction['factores_contribuyentes']
            
            if risk_type == 'diabetes_tipo_2':
                if risk_level == "Alto":
                    recommendations.append({
                        'tipo': 'urgente',
                        'titulo': 'Control médico inmediato recomendado',
                        'contenido': 'Su riesgo de diabetes es alto. Se recomienda consulta médica inmediata y monitoreo de glucosa regular.',
                        'acciones': ['Consulta médica urgente', 'Monitoreo de glucosa diario', 'Dieta baja en carbohidratos']
                    })
                elif risk_level == "Moderado":
                    recommendations.append({
                        'tipo': 'preventivo',
                        'titulo': 'Medidas preventivas para diabetes',
                        'contenido': 'Su riesgo es moderado. Implemente cambios en estilo de vida para reducir el riesgo.',
                        'acciones': ['Ejercicio regular (150 min/semana)', 'Dieta balanceada', 'Control de peso']
                    })
            
            elif risk_type == 'hipertension':
                if risk_level == "Alto":
                    recommendations.append({
                        'tipo': 'urgente',
                        'titulo': 'Control de presión arterial urgente',
                        'contenido': 'Su riesgo de hipertensión es alto. Monitoreo médico inmediato necesario.',
                        'acciones': ['Consulta cardiológica', 'Monitoreo de PA diario', 'Reducción de sodio']
                    })
                elif risk_level == "Moderado":
                    recommendations.append({
                        'tipo': 'preventivo',
                        'titulo': 'Prevención de hipertensión',
                        'contenido': 'Implemente cambios en estilo de vida para prevenir hipertensión.',
                        'acciones': ['Ejercicio cardiovascular', 'Dieta DASH', 'Control del estrés']
                    })
        
        # Recomendaciones generales basadas en factores comunes
        if any('IMC' in factor for factor in [f for pred in predictions for f in pred['factores_contribuyentes']]):
            recommendations.append({
                'tipo': 'general',
                'titulo': 'Control de peso',
                'contenido': 'Mantener un peso saludable reduce significativamente el riesgo cardiovascular.',
                'acciones': ['Dieta balanceada', 'Ejercicio regular', 'Control de porciones']
            })
        
        return recommendations
