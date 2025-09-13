-- Script de inicialización de la base de datos
-- Este script se ejecuta automáticamente cuando se crea el contenedor de PostgreSQL

-- Crear la base de datos si no existe
SELECT 'CREATE DATABASE predicthealth_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'predicthealth_db')\gexec

-- Conectar a la base de datos predicthealth_db
\c predicthealth_db;

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear esquema si no existe
CREATE SCHEMA IF NOT EXISTS public;

-- Configurar permisos
GRANT ALL PRIVILEGES ON DATABASE predicthealth_db TO admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO admin;

-- =============================================
-- CREAR NUEVAS TABLAS SEGÚN EL DIAGRAMA ER
-- =============================================

-- Tabla: doctores
CREATE TABLE doctores (
    id_doctor UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    licencia_medica VARCHAR(50) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: usuarios (antes pacientes)
CREATE TABLE usuarios (
    id_usuario UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_doctor UUID NOT NULL REFERENCES doctores(id_doctor) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero VARCHAR(20) NOT NULL,
    zona_horaria VARCHAR(50) DEFAULT 'America/Mexico_City' NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: perfil_salud_general
CREATE TABLE perfil_salud_general (
    id_perfil UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    altura_cm DECIMAL(5,2),
    peso_kg DECIMAL(5,2),
    fumador BOOLEAN DEFAULT FALSE,
    consumo_alcohol BOOLEAN DEFAULT FALSE,
    diagnostico_hipertension BOOLEAN DEFAULT FALSE,
    diagnostico_colesterol_alto BOOLEAN DEFAULT FALSE,
    antecedente_acv BOOLEAN DEFAULT FALSE,
    antecedente_enf_cardiaca BOOLEAN DEFAULT FALSE,
    condiciones_preexistentes_notas TEXT,
    minutos_actividad_fisica_semanal INTEGER DEFAULT 0,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: datos_biometricos
CREATE TABLE datos_biometricos (
    id_dato_biometrico UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    fecha_hora_medida TIMESTAMP WITH TIME ZONE NOT NULL,
    tipo_medida VARCHAR(50) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    unidad VARCHAR(20) NOT NULL,
    fuente_dato VARCHAR(50) NOT NULL,
    id_doctor_registro UUID REFERENCES doctores(id_doctor) ON DELETE SET NULL,
    notas TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: predicciones_riesgo
CREATE TABLE predicciones_riesgo (
    id_prediccion UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    fecha_prediccion TIMESTAMP WITH TIME ZONE NOT NULL,
    tipo_riesgo VARCHAR(50) NOT NULL,
    puntuacion_riesgo DECIMAL(5,2) NOT NULL,
    nivel_riesgo VARCHAR(20) NOT NULL,
    detalles_prediccion TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: recomendaciones_medicas
CREATE TABLE recomendaciones_medicas (
    id_recomendacion UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario UUID NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    id_doctor UUID NOT NULL REFERENCES doctores(id_doctor) ON DELETE CASCADE,
    id_prediccion UUID REFERENCES predicciones_riesgo(id_prediccion) ON DELETE SET NULL,
    fecha_generacion TIMESTAMP WITH TIME ZONE NOT NULL,
    contenido_es TEXT NOT NULL,
    estado_recomendacion VARCHAR(20) DEFAULT 'pendiente',
    feedback_doctor TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- CREAR ÍNDICES PARA OPTIMIZAR CONSULTAS
-- =============================================

-- Índices para doctores
CREATE INDEX idx_doctores_email ON doctores(email);
CREATE INDEX idx_doctores_licencia ON doctores(licencia_medica);

-- Índices para usuarios
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_id_doctor ON usuarios(id_doctor);
CREATE INDEX idx_usuarios_fecha_nacimiento ON usuarios(fecha_nacimiento);

-- Índices para datos_biometricos
CREATE INDEX idx_datos_biometricos_id_usuario ON datos_biometricos(id_usuario);
CREATE INDEX idx_datos_biometricos_fecha ON datos_biometricos(fecha_hora_medida);
CREATE INDEX idx_datos_biometricos_tipo ON datos_biometricos(tipo_medida);

-- Índices para predicciones_riesgo
CREATE INDEX idx_predicciones_id_usuario ON predicciones_riesgo(id_usuario);
CREATE INDEX idx_predicciones_fecha ON predicciones_riesgo(fecha_prediccion);
CREATE INDEX idx_predicciones_tipo ON predicciones_riesgo(tipo_riesgo);

-- Índices para recomendaciones_medicas
CREATE INDEX idx_recomendaciones_id_usuario ON recomendaciones_medicas(id_usuario);
CREATE INDEX idx_recomendaciones_id_doctor ON recomendaciones_medicas(id_doctor);
CREATE INDEX idx_recomendaciones_fecha ON recomendaciones_medicas(fecha_generacion);
CREATE INDEX idx_recomendaciones_estado ON recomendaciones_medicas(estado_recomendacion);

-- =============================================
-- CREAR TRIGGERS PARA ACTUALIZAR TIMESTAMPS
-- =============================================

-- Función para actualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar fecha_actualizacion
CREATE TRIGGER update_doctores_updated_at BEFORE UPDATE ON doctores FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_perfil_salud_updated_at BEFORE UPDATE ON perfil_salud_general FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_recomendaciones_updated_at BEFORE UPDATE ON recomendaciones_medicas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();