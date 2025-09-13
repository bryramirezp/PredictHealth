# /database/optimized_schema.sql
# Esquema optimizado para consultas médicas complejas

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Tabla de doctores (sin cambios significativos)
CREATE TABLE doctores (
    id_doctor UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    licencia_medica VARCHAR(50) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    especialidad VARCHAR(100),
    zona_horaria VARCHAR(50) DEFAULT 'America/Mexico_City',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de usuarios/pacientes con particionado por fecha de creación
CREATE TABLE usuarios (
    id_usuario UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_doctor UUID NOT NULL REFERENCES doctores(id_doctor),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    fecha_nacimiento DATE NOT NULL, -- Cambiado a DATE para mejor rendimiento
    genero VARCHAR(20) NOT NULL CHECK (genero IN ('Masculino', 'Femenino', 'Otro')),
    contrasena_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    zona_horaria VARCHAR(50) DEFAULT 'America/Mexico_City',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (fecha_creacion);

-- Particiones mensuales para usuarios (mejora rendimiento en consultas históricas)
CREATE TABLE usuarios_2024_01 PARTITION OF usuarios
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE usuarios_2024_02 PARTITION OF usuarios
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Agregar más particiones según necesidad

-- Tabla de perfil de salud con índices optimizados
CREATE TABLE perfil_salud_general (
    id_perfil UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    -- Datos antropométricos con precisión decimal
    altura_cm DECIMAL(5,2) CHECK (altura_cm BETWEEN 50 AND 250),
    peso_kg DECIMAL(5,2) CHECK (peso_kg BETWEEN 10 AND 300),
    imc DECIMAL(4,1) GENERATED ALWAYS AS (peso_kg / POWER(altura_cm/100, 2)) STORED,
    -- Factores de riesgo
    fumador BOOLEAN DEFAULT FALSE,
    consumo_alcohol BOOLEAN DEFAULT FALSE,
    diagnostico_hipertension BOOLEAN DEFAULT FALSE,
    diagnostico_colesterol_alto BOOLEAN DEFAULT FALSE,
    antecedente_acv BOOLEAN DEFAULT FALSE,
    antecedente_enf_cardiaca BOOLEAN DEFAULT FALSE,
    condiciones_preexistentes_notas TEXT,
    -- Actividad física en minutos por semana
    minutos_actividad_fisica_semanal INTEGER DEFAULT 0 CHECK (minutos_actividad_fisica_semanal >= 0),
    -- Metadatos
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(id_usuario)
);

-- Tabla de datos biométricos con particionado por fecha
CREATE TABLE datos_biometricos (
    id_dato_biometrico UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    fecha_hora_medida TIMESTAMP WITH TIME ZONE NOT NULL,
    tipo_medida VARCHAR(50) NOT NULL CHECK (tipo_medida IN (
        'presion_arterial_sistolica', 'presion_arterial_diastolica', 'glucosa',
        'peso', 'altura', 'temperatura', 'frecuencia_cardiaca', 'saturacion_oxigeno',
        'colesterol_total', 'colesterol_ldl', 'colesterol_hdl', 'trigliceridos'
    )),
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    unidad VARCHAR(20) NOT NULL,
    fuente_dato VARCHAR(50) NOT NULL DEFAULT 'usuario_web',
    id_doctor_registro UUID REFERENCES doctores(id_doctor),
    notas TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (fecha_hora_medida);

-- Particiones mensuales para datos biométricos
CREATE TABLE datos_biometricos_2024_01 PARTITION OF datos_biometricos
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE datos_biometricos_2024_02 PARTITION OF datos_biometricos
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Tabla de predicciones de riesgo con índices especializados
CREATE TABLE predicciones_riesgo (
    id_prediccion UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    fecha_prediccion TIMESTAMP WITH TIME ZONE NOT NULL,
    tipo_riesgo VARCHAR(50) NOT NULL CHECK (tipo_riesgo IN (
        'diabetes_tipo_2', 'hipertension', 'enfermedad_cardiaca', 'acv'
    )),
    puntuacion_riesgo DECIMAL(5,2) NOT NULL CHECK (puntuacion_riesgo BETWEEN 0 AND 100),
    nivel_riesgo VARCHAR(20) NOT NULL CHECK (nivel_riesgo IN ('Bajo', 'Moderado', 'Alto')),
    factores_contribuyentes JSONB, -- Almacenar factores como JSON para flexibilidad
    detalles_prediccion TEXT,
    algoritmo_version VARCHAR(10) DEFAULT '1.0',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
) PARTITION BY RANGE (fecha_prediccion);

-- Particiones trimestrales para predicciones
CREATE TABLE predicciones_riesgo_2024_q1 PARTITION OF predicciones_riesgo
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- Tabla de recomendaciones médicas
CREATE TABLE recomendaciones_medicas (
    id_recomendacion UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    id_doctor UUID NOT NULL REFERENCES doctores(id_doctor),
    id_prediccion UUID REFERENCES predicciones_riesgo(id_prediccion),
    fecha_generacion TIMESTAMP WITH TIME ZONE NOT NULL,
    contenido_es TEXT NOT NULL,
    tipo_recomendacion VARCHAR(50) DEFAULT 'general' CHECK (tipo_recomendacion IN (
        'urgente', 'preventivo', 'general', 'seguimiento'
    )),
    estado_recomendacion VARCHAR(20) DEFAULT 'pendiente' CHECK (estado_recomendacion IN (
        'pendiente', 'leida', 'aplicada', 'rechazada'
    )),
    feedback_doctor TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ÍNDICES OPTIMIZADOS PARA CONSULTAS MÉDICAS COMPLEJAS

-- Índices para consultas por doctor
CREATE INDEX CONCURRENTLY idx_usuarios_doctor_activo ON usuarios(id_doctor, activo) WHERE activo = TRUE;
CREATE INDEX CONCURRENTLY idx_usuarios_doctor_fecha ON usuarios(id_doctor, fecha_creacion DESC);

-- Índices para análisis temporal de datos biométricos
CREATE INDEX CONCURRENTLY idx_datos_biometricos_usuario_fecha ON datos_biometricos(id_usuario, fecha_hora_medida DESC);
CREATE INDEX CONCURRENTLY idx_datos_biometricos_tipo_fecha ON datos_biometricos(tipo_medida, fecha_hora_medida DESC);
CREATE INDEX CONCURRENTLY idx_datos_biometricos_valor_rango ON datos_biometricos(tipo_medida, valor) WHERE valor IS NOT NULL;

-- Índices para análisis de riesgo
CREATE INDEX CONCURRENTLY idx_predicciones_usuario_tipo ON predicciones_riesgo(id_usuario, tipo_riesgo, fecha_prediccion DESC);
CREATE INDEX CONCURRENTLY idx_predicciones_riesgo_nivel ON predicciones_riesgo(nivel_riesgo, fecha_prediccion DESC);
CREATE INDEX CONCURRENTLY idx_predicciones_puntuacion ON predicciones_riesgo(puntuacion_riesgo DESC, fecha_prediccion DESC);

-- Índices para análisis de perfil de salud
CREATE INDEX CONCURRENTLY idx_perfil_imc ON perfil_salud_general(imc) WHERE imc IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_perfil_factores_riesgo ON perfil_salud_general(fumador, consumo_alcohol, diagnostico_hipertension);
CREATE INDEX CONCURRENTLY idx_perfil_actividad ON perfil_salud_general(minutos_actividad_fisica_semanal) WHERE minutos_actividad_fisica_semanal > 0;

-- Índices compuestos para consultas complejas
CREATE INDEX CONCURRENTLY idx_usuario_perfil_completo ON usuarios(id_usuario) INCLUDE (nombre, apellido, fecha_nacimiento, genero);
CREATE INDEX CONCURRENTLY idx_datos_biometricos_analisis ON datos_biometricos(id_usuario, tipo_medida, fecha_hora_medida, valor);

-- Índices GIN para búsquedas en JSONB
CREATE INDEX CONCURRENTLY idx_predicciones_factores_gin ON predicciones_riesgo USING GIN (factores_contribuyentes);

-- ÍNDICES PARA CONSULTAS DE ANÁLISIS MÉDICO

-- Vista materializada para estadísticas de riesgo por doctor
CREATE MATERIALIZED VIEW estadisticas_riesgo_por_doctor AS
SELECT 
    d.id_doctor,
    d.nombre || ' ' || d.apellido AS nombre_doctor,
    COUNT(DISTINCT u.id_usuario) AS total_pacientes,
    COUNT(DISTINCT pr.id_usuario) AS pacientes_con_predicciones,
    AVG(pr.puntuacion_riesgo) AS riesgo_promedio,
    COUNT(CASE WHEN pr.nivel_riesgo = 'Alto' THEN 1 END) AS pacientes_alto_riesgo,
    COUNT(CASE WHEN pr.nivel_riesgo = 'Moderado' THEN 1 END) AS pacientes_moderado_riesgo,
    COUNT(CASE WHEN pr.nivel_riesgo = 'Bajo' THEN 1 END) AS pacientes_bajo_riesgo,
    MAX(pr.fecha_prediccion) AS ultima_prediccion
FROM doctores d
LEFT JOIN usuarios u ON d.id_doctor = u.id_doctor AND u.activo = TRUE
LEFT JOIN predicciones_riesgo pr ON u.id_usuario = pr.id_usuario
GROUP BY d.id_doctor, d.nombre, d.apellido;

-- Vista materializada para tendencias temporales de mediciones
CREATE MATERIALIZED VIEW tendencias_mediciones_mensual AS
SELECT 
    DATE_TRUNC('month', fecha_hora_medida) AS mes,
    tipo_medida,
    COUNT(*) AS total_mediciones,
    AVG(valor) AS valor_promedio,
    MIN(valor) AS valor_minimo,
    MAX(valor) AS valor_maximo,
    STDDEV(valor) AS desviacion_estandar
FROM datos_biometricos
WHERE fecha_hora_medida >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', fecha_hora_medida), tipo_medida;

-- Vista materializada para análisis de factores de riesgo
CREATE MATERIALIZED VIEW analisis_factores_riesgo AS
SELECT 
    psg.id_usuario,
    u.nombre || ' ' || u.apellido AS nombre_paciente,
    psg.imc,
    psg.fumador,
    psg.consumo_alcohol,
    psg.diagnostico_hipertension,
    psg.diagnostico_colesterol_alto,
    psg.minutos_actividad_fisica_semanal,
    CASE 
        WHEN psg.imc < 18.5 THEN 'Bajo peso'
        WHEN psg.imc BETWEEN 18.5 AND 24.9 THEN 'Peso normal'
        WHEN psg.imc BETWEEN 25 AND 29.9 THEN 'Sobrepeso'
        WHEN psg.imc >= 30 THEN 'Obesidad'
    END AS categoria_imc,
    CASE 
        WHEN psg.minutos_actividad_fisica_semanal < 150 THEN 'Sedentario'
        WHEN psg.minutos_actividad_fisica_semanal BETWEEN 150 AND 300 THEN 'Activo moderado'
        WHEN psg.minutos_actividad_fisica_semanal > 300 THEN 'Muy activo'
    END AS categoria_actividad
FROM perfil_salud_general psg
JOIN usuarios u ON psg.id_usuario = u.id_usuario
WHERE u.activo = TRUE;

-- FUNCIONES PARA CONSULTAS MÉDICAS COMPLEJAS

-- Función para obtener evolución de mediciones de un paciente
CREATE OR REPLACE FUNCTION obtener_evolucion_mediciones(
    p_id_usuario UUID,
    p_tipo_medida VARCHAR(50),
    p_meses INTEGER DEFAULT 6
)
RETURNS TABLE (
    fecha_medida TIMESTAMP WITH TIME ZONE,
    valor DECIMAL(10,2),
    unidad VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        db.fecha_hora_medida,
        db.valor,
        db.unidad
    FROM datos_biometricos db
    WHERE db.id_usuario = p_id_usuario
        AND db.tipo_medida = p_tipo_medida
        AND db.fecha_hora_medida >= CURRENT_DATE - INTERVAL '1 month' * p_meses
    ORDER BY db.fecha_hora_medida DESC;
END;
$$ LANGUAGE plpgsql;

-- Función para calcular riesgo cardiovascular
CREATE OR REPLACE FUNCTION calcular_riesgo_cardiovascular(p_id_usuario UUID)
RETURNS TABLE (
    tipo_riesgo VARCHAR(50),
    puntuacion DECIMAL(5,2),
    nivel_riesgo VARCHAR(20),
    factores JSONB
) AS $$
DECLARE
    v_perfil RECORD;
    v_mediciones RECORD;
    v_puntuacion DECIMAL(5,2) := 0;
    v_factores JSONB := '[]'::jsonb;
BEGIN
    -- Obtener perfil del usuario
    SELECT * INTO v_perfil
    FROM perfil_salud_general
    WHERE id_usuario = p_id_usuario;
    
    -- Calcular puntuación basada en factores
    IF v_perfil.fumador THEN
        v_puntuacion := v_puntuacion + 20;
        v_factores := v_factores || '["Fumador"]'::jsonb;
    END IF;
    
    IF v_perfil.diagnostico_hipertension THEN
        v_puntuacion := v_puntuacion + 25;
        v_factores := v_factores || '["Hipertensión"]'::jsonb;
    END IF;
    
    IF v_perfil.imc > 30 THEN
        v_puntuacion := v_puntuacion + 15;
        v_factores := v_factores || '["Obesidad"]'::jsonb;
    END IF;
    
    -- Determinar nivel de riesgo
    RETURN QUERY SELECT 
        'enfermedad_cardiaca'::VARCHAR(50),
        v_puntuacion,
        CASE 
            WHEN v_puntuacion < 30 THEN 'Bajo'::VARCHAR(20)
            WHEN v_puntuacion < 60 THEN 'Moderado'::VARCHAR(20)
            ELSE 'Alto'::VARCHAR(20)
        END,
        v_factores;
END;
$$ LANGUAGE plpgsql;

-- TRIGGERS PARA MANTENIMIENTO AUTOMÁTICO

-- Trigger para actualizar fecha_actualizacion
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas relevantes
CREATE TRIGGER trigger_doctores_fecha_modificacion
    BEFORE UPDATE ON doctores
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_usuarios_fecha_modificacion
    BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_perfil_fecha_modificacion
    BEFORE UPDATE ON perfil_salud_general
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trigger_recomendaciones_fecha_modificacion
    BEFORE UPDATE ON recomendaciones_medicas
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

-- PROCEDIMIENTO PARA REFRESCAR VISTAS MATERIALIZADAS
CREATE OR REPLACE FUNCTION refrescar_vistas_medicas()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY estadisticas_riesgo_por_doctor;
    REFRESH MATERIALIZED VIEW CONCURRENTLY tendencias_mediciones_mensual;
    REFRESH MATERIALIZED VIEW CONCURRENTLY analisis_factores_riesgo;
END;
$$ LANGUAGE plpgsql;

-- Crear job para refrescar vistas materializadas (requiere pg_cron)
-- SELECT cron.schedule('refrescar-vistas-medicas', '0 2 * * *', 'SELECT refrescar_vistas_medicas();');

-- COMENTARIOS PARA DOCUMENTACIÓN
COMMENT ON TABLE usuarios IS 'Tabla particionada de usuarios/pacientes para optimizar consultas históricas';
COMMENT ON TABLE datos_biometricos IS 'Tabla particionada de mediciones biométricas con índices optimizados para análisis temporal';
COMMENT ON TABLE predicciones_riesgo IS 'Tabla de predicciones de riesgo con particionado temporal y índices especializados';
COMMENT ON MATERIALIZED VIEW estadisticas_riesgo_por_doctor IS 'Estadísticas agregadas de riesgo por doctor para dashboards';
COMMENT ON MATERIALIZED VIEW tendencias_mediciones_mensual IS 'Tendencias mensuales de mediciones para análisis temporal';
COMMENT ON FUNCTION obtener_evolucion_mediciones IS 'Función para obtener evolución de mediciones de un paciente específico';
COMMENT ON FUNCTION calcular_riesgo_cardiovascular IS 'Función para calcular riesgo cardiovascular basado en factores del paciente';
