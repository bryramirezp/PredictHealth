// /frontend\static\js\nomenclature_config.js
// Configuración de nomenclatura estándar para el frontend (versión navegador)

const NomenclatureConfig = {
    fieldMapping: {
        'bp_systolic': 'presion_sistolica',
        'bp_diastolic': 'presion_diastolica',
        'glucose': 'glucosa',
        'weight': 'peso_kg',
        'height': 'altura_cm',
        'smoker': 'fumador',
        'alcohol_consumption': 'consumo_alcohol',
        'physical_activity': 'minutos_actividad_fisica_semanal',
        'hypertension': 'diagnostico_hipertension',
        'high_cholesterol': 'diagnostico_colesterol_alto',
        'stroke_history': 'antecedente_acv',
        'heart_disease_history': 'antecedente_enf_cardiaca',
        'additional_notes': 'condiciones_preexistentes_notas'
    },

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

    validRiskTypes: [
        'diabetes_tipo_2',
        'hipertension',
        'enfermedad_cardiaca',
        'acv'
    ],

    validRiskLevels: ['Bajo', 'Moderado', 'Alto'],
    validGenders: ['Masculino', 'Femenino', 'Otro'],
    validRecommendationStates: ['pendiente', 'leida', 'aplicada', 'rechazada'],
    validRecommendationTypes: ['urgente', 'preventivo', 'general', 'seguimiento'],
    validUnits: ['mmHg', 'mg/dL', 'kg', 'cm', '°C', 'bpm', '%'],
    validDataSources: ['usuario_web', 'doctor_registro', 'dispositivo_medico', 'laboratorio', 'importacion']
};

const NomenclatureUtils = {
    mapFormToBackend(formData) {
        const mappedData = {};
        for (const [frontendField, value] of Object.entries(formData)) {
            const backendField = NomenclatureConfig.fieldMapping[frontendField] || frontendField;
            mappedData[backendField] = value;
        }
        return mappedData;
    },

    mapBackendToForm(backendData) {
        const mappedData = {};
        const reverseMapping = {};
        for (const [frontendField, backendField] of Object.entries(NomenclatureConfig.fieldMapping)) {
            reverseMapping[backendField] = frontendField;
        }
        for (const [backendField, value] of Object.entries(backendData)) {
            const frontendField = reverseMapping[backendField] || backendField;
            mappedData[frontendField] = value;
        }
        return mappedData;
    },

    validateMedicalValue(measurementType, value) {
        const range = NomenclatureConfig.medicalRanges[measurementType];
        if (!range) return false;
        const numValue = parseFloat(value);
        return !isNaN(numValue) && numValue >= range.min && numValue <= range.max;
    },

    getValidationMessage(measurementType) {
        const range = NomenclatureConfig.medicalRanges[measurementType];
        if (!range) return 'Tipo de medición no válido';
        return `Valor debe estar entre ${range.min} y ${range.max} ${range.unit}`;
    },

    validateBloodPressure(systolic, diastolic) {
        const sysValid = this.validateMedicalValue('presion_sistolica', systolic);
        const diaValid = this.validateMedicalValue('presion_diastolica', diastolic);
        if (!sysValid || !diaValid) return false;
        return parseFloat(diastolic) < parseFloat(systolic);
    },

    formatDashboardData(backendData) {
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

    formatPatientData(backendData) {
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

    formatMeasurementData(backendData) {
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

    formatPredictionData(backendData) {
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

    formatRecommendationData(backendData) {
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

// Exponer en window para consumo desde app.js
window.NomenclatureUtils = NomenclatureUtils;


