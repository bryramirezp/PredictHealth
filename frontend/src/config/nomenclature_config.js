// /frontend\src\config\nomenclature_config.js
# /frontend/config/nomenclature_config.js
# Configuración de nomenclatura estándar para el frontend

const NomenclatureConfig = {
    // Mapeo de campos del formulario a campos del backend
    fieldMapping: {
        // Campos de mediciones
        'bp_systolic': 'presion_sistolica',
        'bp_diastolic': 'presion_diastolica',
        'glucose': 'glucosa',
        'weight': 'peso_kg',
        'height': 'altura_cm',
        
        // Campos de estilo de vida
        'smoker': 'fumador',
        'alcohol_consumption': 'consumo_alcohol',
        'physical_activity': 'minutos_actividad_fisica_semanal',
        'hypertension': 'diagnostico_hipertension',
        'high_cholesterol': 'diagnostico_colesterol_alto',
        'stroke_history': 'antecedente_acv',
        'heart_disease_history': 'antecedente_enf_cardiaca',
        'additional_notes': 'condiciones_preexistentes_notas'
    },
    
    // Rangos válidos para mediciones médicas
    medicalRanges: {
        'presion_sistolica': { min: 50, max: 250, unit: 'mmHg' },
        'presion_diastolica': { min: 30, max: 150, unit: 'mmHg' },
        'glucosa': { min: 30, max: 600, unit: 'mg/dL' },
        'peso_kg': { min: 10, max: 300, unit: 'kg' },
        'altura_cm': { min: 50, max: 250, unit: 'cm' },
        'temperatura': { min: 35, max: 42, unit: '°C' },
        'frecuencia_cardiaca': { min: 40, max: 200, unit: 'bpm' },
        'saturacion_oxigeno': { min: 70, max: 100, unit: '%' }
    },
    
    // Tipos de mediciones válidos
    validMeasurementTypes: [
        'presion_arterial_sistolica',
        'presion_arterial_diastolica',
        'glucosa',
        'peso',
        'altura',
        'temperatura',
        'frecuencia_cardiaca',
        'saturacion_oxigeno',
        'colesterol_total',
        'colesterol_ldl',
        'colesterol_hdl',
        'trigliceridos'
    ],
    
    // Tipos de riesgo válidos
    validRiskTypes: [
        'diabetes_tipo_2',
        'hipertension',
        'enfermedad_cardiaca',
        'acv'
    ],
    
    // Niveles de riesgo válidos
    validRiskLevels: ['Bajo', 'Moderado', 'Alto'],
    
    // Géneros válidos
    validGenders: ['Masculino', 'Femenino', 'Otro'],
    
    // Estados de recomendaciones válidos
    validRecommendationStates: ['pendiente', 'leida', 'aplicada', 'rechazada'],
    
    // Tipos de recomendaciones válidos
    validRecommendationTypes: ['urgente', 'preventivo', 'general', 'seguimiento'],
    
    // Unidades de medida válidas
    validUnits: ['mmHg', 'mg/dL', 'kg', 'cm', '°C', 'bpm', '%'],
    
    // Fuentes de datos válidas
    validDataSources: ['usuario_web', 'doctor_registro', 'dispositivo_medico', 'laboratorio', 'importacion']
};

// Funciones de utilidad para nomenclatura
const NomenclatureUtils = {
    // Mapear datos del formulario al backend
    mapFormToBackend: function(formData) {
        const mappedData = {};
        for (const [frontendField, value] of Object.entries(formData)) {
            const backendField = NomenclatureConfig.fieldMapping[frontendField] || frontendField;
            mappedData[backendField] = value;
        }
        return mappedData;
    },
    
    // Mapear datos del backend al formulario
    mapBackendToForm: function(backendData) {
        const mappedData = {};
        const reverseMapping = {};
        
        // Crear mapeo inverso
        for (const [frontendField, backendField] of Object.entries(NomenclatureConfig.fieldMapping)) {
            reverseMapping[backendField] = frontendField;
        }
        
        for (const [backendField, value] of Object.entries(backendData)) {
            const frontendField = reverseMapping[backendField] || backendField;
            mappedData[frontendField] = value;
        }
        return mappedData;
    },
    
    // Validar valor médico
    validateMedicalValue: function(measurementType, value) {
        const range = NomenclatureConfig.medicalRanges[measurementType];
        if (!range) return false;
        
        const numValue = parseFloat(value);
        return !isNaN(numValue) && numValue >= range.min && numValue <= range.max;
    },
    
    // Obtener mensaje de validación
    getValidationMessage: function(measurementType) {
        const range = NomenclatureConfig.medicalRanges[measurementType];
        if (!range) return "Tipo de medición no válido";
        
        return `Valor debe estar entre ${range.min} y ${range.max} ${range.unit}`;
    },
    
    // Validar presión arterial
    validateBloodPressure: function(systolic, diastolic) {
        const sysValid = this.validateMedicalValue('presion_sistolica', systolic);
        const diaValid = this.validateMedicalValue('presion_diastolica', diastolic);
        
        if (!sysValid || !diaValid) return false;
        
        return parseFloat(diastolic) < parseFloat(systolic);
    },
    
    // Formatear datos para el dashboard
    formatDashboardData: function(backendData) {
        return {
            updatedAt: backendData.updatedAt || new Date().toLocaleString(),
            diabetesRisk: parseFloat(backendData.diabetesRisk || 0),
            hypertensionRisk: parseFloat(backendData.hypertensionRisk || 0),
            factors: backendData.factors || [],
            recommendations: backendData.recommendations || [],
            riskLevels: {
                diabetes: backendData.riskLevels?.diabetes || 'Bajo',
                hypertension: backendData.riskLevels?.hypertension || 'Bajo'
            },
            evolution: backendData.evolution || [],
            distribution: backendData.distribution || []
        };
    },
    
    // Formatear datos de paciente para el frontend
    formatPatientData: function(backendData) {
        return {
            id_paciente: backendData.id_usuario,
            nombre: backendData.nombre,
            apellido: backendData.apellido,
            email: backendData.email,
            fecha_nacimiento: backendData.fecha_nacimiento,
            genero: backendData.genero,
            activo: backendData.activo,
            fecha_creacion: backendData.fecha_creacion,
            id_doctor: backendData.id_doctor
        };
    },
    
    // Formatear datos de medición para el frontend
    formatMeasurementData: function(backendData) {
        return {
            id_medicion: backendData.id_dato_biometrico,
            tipo_medida: backendData.tipo_medida,
            valor: parseFloat(backendData.valor || 0),
            unidad: backendData.unidad,
            fecha_medida: backendData.fecha_hora_medida,
            fuente_dato: backendData.fuente_dato,
            notas: backendData.notas
        };
    },
    
    // Formatear datos de predicción para el frontend
    formatPredictionData: function(backendData) {
        return {
            id_prediccion: backendData.id_prediccion,
            tipo_riesgo: backendData.tipo_riesgo,
            puntuacion_riesgo: parseFloat(backendData.puntuacion_riesgo || 0),
            nivel_riesgo: backendData.nivel_riesgo,
            factores_contribuyentes: backendData.factores_contribuyentes || [],
            detalles_prediccion: backendData.detalles_prediccion,
            fecha_prediccion: backendData.fecha_prediccion,
            algoritmo_version: backendData.algoritmo_version || '1.0'
        };
    },
    
    // Formatear datos de recomendación para el frontend
    formatRecommendationData: function(backendData) {
        return {
            id_recomendacion: backendData.id_recomendacion,
            contenido: backendData.contenido_es,
            tipo: backendData.tipo_recomendacion || 'general',
            estado: backendData.estado_recomendacion || 'pendiente',
            fecha_generacion: backendData.fecha_generacion,
            feedback_doctor: backendData.feedback_doctor,
            id_prediccion: backendData.id_prediccion
        };
    }
};

// Exportar para uso en otros archivos
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { NomenclatureConfig, NomenclatureUtils };
}
