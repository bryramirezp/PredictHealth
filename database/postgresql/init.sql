-- =============================================
-- PREDICTHEALTH DATABASE INITIALIZATION SCRIPT
-- Simplified schema for core microservices functionality
-- =============================================

-- Create necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Ensure public schema exists
CREATE SCHEMA IF NOT EXISTS public;

-- =============================================
-- CENTRALIZED AUTHENTICATION (SERVICE-JWT)
-- =============================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(50) NOT NULL CHECK (user_type IN ('patient','doctor','admin','institution')),
    reference_id UUID NOT NULL, -- domain table id
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    failed_login_attempts INTEGER DEFAULT 0,
    last_failed_login TIMESTAMP WITH TIME ZONE,
    password_changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- =============================================
-- DOMAIN TABLES
-- =============================================

-- Institutions
CREATE TABLE IF NOT EXISTS medical_institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    institution_type VARCHAR(50) NOT NULL CHECK (institution_type IN ('preventive_clinic','insurer','public_health','hospital','health_center')),
    contact_email VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(255),
    region_state VARCHAR(100),
    phone VARCHAR(20),
    website VARCHAR(255),
    license_number VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_verified BOOLEAN DEFAULT TRUE NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Doctor specialties
CREATE TABLE IF NOT EXISTS doctor_specialties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Doctors
CREATE TABLE IF NOT EXISTS doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID, -- soft reference
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    medical_license VARCHAR(50) UNIQUE NOT NULL,
    specialty_id UUID REFERENCES doctor_specialties(id) ON DELETE SET NULL,
    secondary_specialty_id UUID REFERENCES doctor_specialties(id) ON DELETE SET NULL,
    phone VARCHAR(20),
    years_experience INTEGER DEFAULT 0,
    consultation_fee DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    professional_status VARCHAR(50) DEFAULT 'active' CHECK (professional_status IN ('active','suspended','retired')),
    last_login TIMESTAMP WITH TIME ZONE
);

-- Patients
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID, -- soft reference
    institution_id UUID, -- soft reference
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) CHECK (gender IN ('male','female','other','prefer_not_to_say')),
    phone VARCHAR(20),
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    validation_status VARCHAR(50) DEFAULT 'pending' CHECK (validation_status IN ('pending','doctor_validated','institution_validated','full_access')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Health profiles
CREATE TABLE IF NOT EXISTS health_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID UNIQUE NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    blood_type VARCHAR(5),
    is_smoker BOOLEAN DEFAULT FALSE,
    smoking_years INTEGER DEFAULT 0,
    consumes_alcohol BOOLEAN DEFAULT FALSE,
    alcohol_frequency VARCHAR(20) CHECK (alcohol_frequency IN ('never','rarely','occasionally','regularly','daily')),
    hypertension_diagnosis BOOLEAN DEFAULT FALSE,
    diabetes_diagnosis BOOLEAN DEFAULT FALSE,
    high_cholesterol_diagnosis BOOLEAN DEFAULT FALSE,
    has_stroke_history BOOLEAN DEFAULT FALSE,
    has_heart_disease_history BOOLEAN DEFAULT FALSE,
    family_history_diabetes BOOLEAN DEFAULT FALSE,
    family_history_hypertension BOOLEAN DEFAULT FALSE,
    family_history_heart_disease BOOLEAN DEFAULT FALSE,
    preexisting_conditions_notes TEXT,
    current_medications TEXT,
    allergies TEXT,
    physical_activity_minutes_weekly INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- ADMIN TABLES
-- =============================================

-- Admin users table (separate from users table for admin-specific data)
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    employee_id VARCHAR(50) UNIQUE,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin audit logs
CREATE TABLE IF NOT EXISTS admin_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    details TEXT,
    ip_address INET,
    user_agent VARCHAR(512),
    success BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- =============================================
-- BASIC CONSTRAINTS AND VALIDATION
-- =============================================

ALTER TABLE patients DROP CONSTRAINT IF EXISTS check_patient_has_association;
ALTER TABLE patients ADD CONSTRAINT check_patient_has_association CHECK (doctor_id IS NOT NULL OR institution_id IS NOT NULL);

ALTER TABLE health_profiles DROP CONSTRAINT IF EXISTS check_positive_height;
ALTER TABLE health_profiles ADD CONSTRAINT check_positive_height CHECK (height_cm IS NULL OR height_cm > 0);

ALTER TABLE health_profiles DROP CONSTRAINT IF EXISTS check_positive_weight;
ALTER TABLE health_profiles ADD CONSTRAINT check_positive_weight CHECK (weight_kg IS NULL OR weight_kg > 0);

ALTER TABLE health_profiles DROP CONSTRAINT IF EXISTS check_positive_physical_activity;
ALTER TABLE health_profiles ADD CONSTRAINT check_positive_physical_activity CHECK (physical_activity_minutes_weekly >= 0);

ALTER TABLE health_profiles DROP CONSTRAINT IF EXISTS check_smoking_years_consistency;
ALTER TABLE health_profiles ADD CONSTRAINT check_smoking_years_consistency CHECK (smoking_years >= 0);


-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_admins_user_id ON admins(user_id);
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_employee_id ON admins(employee_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_admin_id ON admin_audit_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_resource ON admin_audit_logs(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_created_at ON admin_audit_logs(created_at DESC);

-- =============================================
-- TIMESTAMP TRIGGER
-- =============================================

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply timestamp triggers
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='updated_at') THEN
        EXECUTE 'CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='medical_institutions' AND column_name='updated_at') THEN
        EXECUTE 'CREATE TRIGGER set_timestamp_medical_institutions BEFORE UPDATE ON medical_institutions FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='doctors' AND column_name='updated_at') THEN
        EXECUTE 'CREATE TRIGGER set_timestamp_doctors BEFORE UPDATE ON doctors FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='patients' AND column_name='updated_at') THEN
        EXECUTE 'CREATE TRIGGER set_timestamp_patients BEFORE UPDATE ON patients FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='health_profiles' AND column_name='updated_at') THEN
        EXECUTE 'CREATE TRIGGER set_timestamp_health_profiles BEFORE UPDATE ON health_profiles FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();';
    END IF;

    -- Admin tables
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='admins' AND column_name='updated_at') THEN
        EXECUTE 'CREATE TRIGGER set_timestamp_admins BEFORE UPDATE ON admins FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='admin_audit_logs' AND column_name='updated_at') THEN
        EXECUTE 'CREATE TRIGGER set_timestamp_admin_audit_logs BEFORE UPDATE ON admin_audit_logs FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();';
    END IF;

END;
$$;

-- =============================================
-- INITIAL DATA SEEDING
-- =============================================

INSERT INTO doctor_specialties (name, description, category) VALUES
('General Medicine','General medical practice','Primary Care'),
('Internal Medicine','Internal medicine specialist','Primary Care'),
('Cardiology','Heart and cardiovascular system','Specialty'),
('Endocrinology','Hormones and metabolism','Specialty'),
('Diabetes Management','Diabetes care specialist','Specialty'),
('Preventive Medicine','Disease prevention and health promotion','Preventive'),
('Family Medicine','Comprehensive family healthcare','Primary Care'),
('Emergency Medicine','Emergency care specialist','Emergency')
ON CONFLICT (name) DO NOTHING;

-- =============================================
-- DEFAULT ADMIN USER
-- =============================================

-- Create default admin user
-- Password: Admin123! (bcrypt hashed)
INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'admin@predicthealth.com',
    '$2b$12$sWYu0EcbVtmUBH5jI/zU3eROZRVA7AbtaOmF4DaxQRhXPt8/JbTCy', -- Admin123!
    'admin',
    '550e8400-e29b-41d4-a716-446655440000'::uuid, -- Same as user ID for admin reference
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- Create corresponding admin profile
INSERT INTO admins (id, user_id, email, first_name, last_name, department, employee_id, is_active)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'admin@predicthealth.com',
    'System',
    'Administrator',
    'IT',
    'ADMIN001',
    TRUE
) ON CONFLICT (user_id) DO NOTHING;

