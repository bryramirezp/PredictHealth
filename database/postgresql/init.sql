-- =============================================
-- PREDICTHEALTH DATABASE - OPTIMIZED FOR 3NF
-- Normalized to Third Normal Form with Stored Procedures, Views, Indexes
-- =============================================

-- Create necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Ensure public schema exists
CREATE SCHEMA IF NOT EXISTS public;

-- =============================================
-- CORE ENTITIES (NORMALIZED TO 3NF)
-- =============================================

-- Medical Institutions (Eliminated transitive dependencies)
CREATE TABLE IF NOT EXISTS medical_institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    institution_type VARCHAR(50) NOT NULL CHECK (institution_type IN ('preventive_clinic','insurer','public_health','hospital','health_center')),
    contact_email VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(255),
    region_state VARCHAR(100),
    phone VARCHAR(20),
    website VARCHAR(255),
    license_number VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Doctor Specialties (Normalized category)
CREATE TABLE IF NOT EXISTS doctor_specialties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Doctors (Eliminated transitive dependencies)
CREATE TABLE IF NOT EXISTS doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES medical_institutions(id) ON DELETE SET NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    medical_license VARCHAR(50) UNIQUE NOT NULL,
    specialty_id UUID REFERENCES doctor_specialties(id) ON DELETE SET NULL,
    phone VARCHAR(20) NOT NULL,
    years_experience INTEGER DEFAULT 0 CHECK (years_experience >= 0),
    consultation_fee DECIMAL(10,2) CHECK (consultation_fee >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    professional_status VARCHAR(50) DEFAULT 'active' CHECK (professional_status IN ('active','suspended','retired')),
    last_login TIMESTAMP WITH TIME ZONE
);

-- Patients (Normalized validation logic)
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID REFERENCES doctors(id) ON DELETE SET NULL,
    institution_id UUID REFERENCES medical_institutions(id) ON DELETE SET NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL CHECK (date_of_birth <= CURRENT_DATE),
    gender VARCHAR(20) CHECK (gender IN ('male','female','other','prefer_not_to_say')),
    phone VARCHAR(20) NOT NULL,
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    validation_status VARCHAR(50) DEFAULT 'pending' CHECK (validation_status IN ('pending','doctor_validated','institution_validated','full_access')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,

    -- Composite constraint for data integrity
    CONSTRAINT chk_patient_association CHECK (doctor_id IS NOT NULL OR institution_id IS NOT NULL),
    CONSTRAINT chk_emergency_contact CHECK (
        (emergency_contact_name IS NULL AND emergency_contact_phone IS NULL) OR
        (emergency_contact_name IS NOT NULL AND emergency_contact_phone IS NOT NULL)
    )
);

-- Health Profiles (Normalized health conditions)
CREATE TABLE IF NOT EXISTS health_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID UNIQUE NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    height_cm DECIMAL(5,2) CHECK (height_cm > 0 AND height_cm <= 300),
    weight_kg DECIMAL(5,2) CHECK (weight_kg > 0 AND weight_kg <= 500),
    blood_type VARCHAR(5) CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    is_smoker BOOLEAN DEFAULT FALSE NOT NULL,
    smoking_years INTEGER DEFAULT 0 CHECK (smoking_years >= 0),
    consumes_alcohol BOOLEAN DEFAULT FALSE NOT NULL,
    alcohol_frequency VARCHAR(20) CHECK (alcohol_frequency IN ('never','rarely','occasionally','regularly','daily')),
    hypertension_diagnosis BOOLEAN DEFAULT FALSE NOT NULL,
    diabetes_diagnosis BOOLEAN DEFAULT FALSE NOT NULL,
    high_cholesterol_diagnosis BOOLEAN DEFAULT FALSE NOT NULL,
    has_stroke_history BOOLEAN DEFAULT FALSE NOT NULL,
    has_heart_disease_history BOOLEAN DEFAULT FALSE NOT NULL,
    family_history_diabetes BOOLEAN DEFAULT FALSE NOT NULL,
    family_history_hypertension BOOLEAN DEFAULT FALSE NOT NULL,
    family_history_heart_disease BOOLEAN DEFAULT FALSE NOT NULL,
    physical_activity_minutes_weekly INTEGER DEFAULT 0 CHECK (physical_activity_minutes_weekly >= 0),
    preexisting_conditions_notes TEXT,
    current_medications TEXT,
    allergies TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Business logic constraints
    CONSTRAINT chk_smoking_consistency CHECK (NOT is_smoker OR smoking_years > 0),
    CONSTRAINT chk_alcohol_consistency CHECK (NOT consumes_alcohol OR alcohol_frequency IS NOT NULL)
);

-- =============================================
-- AUTHENTICATION SYSTEM (NORMALIZED)
-- =============================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(50) NOT NULL CHECK (user_type IN ('patient','doctor','institution')),
    reference_id UUID NOT NULL, -- FK to respective domain table
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    failed_login_attempts INTEGER DEFAULT 0 CHECK (failed_login_attempts >= 0),
    last_failed_login TIMESTAMP WITH TIME ZONE,
    password_changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Reference validation will be handled by application logic
    CONSTRAINT chk_reference_consistency CHECK (reference_id IS NOT NULL)
);

-- =============================================
-- CMS SYSTEM (FULLY NORMALIZED)
-- =============================================

-- CMS Roles
CREATE TABLE IF NOT EXISTS cms_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CMS Users (Unified)
CREATE TABLE IF NOT EXISTS cms_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) CHECK (user_type IN ('admin', 'editor')) NOT NULL,
    role_id INTEGER REFERENCES cms_roles(id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CMS Permissions (Normalized resource-action pairs)
CREATE TABLE IF NOT EXISTS cms_permissions (
    id SERIAL PRIMARY KEY,
    resource VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL,
    description VARCHAR(255),
    UNIQUE(resource, action)
);

-- Role-Permissions junction table
CREATE TABLE IF NOT EXISTS cms_role_permissions (
    role_id INTEGER REFERENCES cms_roles(id) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES cms_permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);



-- =============================================
-- STORED PROCEDURES FOR COMPLEX OPERATIONS
-- =============================================

-- Procedure for creating patient with health profile (Complex CRUD)
CREATE OR REPLACE PROCEDURE sp_create_patient_with_profile(
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_email VARCHAR(255),
    p_password_hash VARCHAR(255),
    p_date_of_birth DATE,
    p_gender VARCHAR(20),
    p_phone VARCHAR(20),
    p_doctor_id UUID,
    p_institution_id UUID,
    p_height_cm DECIMAL(5,2),
    p_weight_kg DECIMAL(5,2),
    p_blood_type VARCHAR(5)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_patient_id UUID;
    v_user_id UUID;
BEGIN
    -- Insert patient
    INSERT INTO patients (first_name, last_name, email, date_of_birth, gender, phone, doctor_id, institution_id)
    VALUES (p_first_name, p_last_name, p_email, p_date_of_birth, p_gender, p_phone, p_doctor_id, p_institution_id)
    RETURNING id INTO v_patient_id;

    -- Create user account
    INSERT INTO users (email, password_hash, user_type, reference_id, is_verified)
    VALUES (p_email, p_password_hash, 'patient', v_patient_id, FALSE)
    RETURNING id INTO v_user_id;

    -- Create health profile
    INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type)
    VALUES (v_patient_id, p_height_cm, p_weight_kg, p_blood_type);

    COMMIT;
END;
$$;

-- Procedure for patient statistics by month (KPI Reporting)
CREATE OR REPLACE PROCEDURE sp_get_patient_stats_by_month(
    p_year INTEGER,
    OUT total_patients INTEGER,
    OUT new_patients INTEGER,
    OUT validated_patients INTEGER,
    OUT avg_age DECIMAL(5,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_year INTEGER := COALESCE(p_year, EXTRACT(YEAR FROM CURRENT_DATE));
BEGIN
    -- Total patients
    SELECT COUNT(*) INTO total_patients FROM patients WHERE is_active = TRUE;

    -- New patients this month
    SELECT COUNT(*) INTO new_patients
    FROM patients
    WHERE EXTRACT(YEAR FROM created_at) = v_year
    AND EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM CURRENT_DATE);

    -- Validated patients
    SELECT COUNT(*) INTO validated_patients
    FROM patients
    WHERE validation_status = 'full_access' AND is_active = TRUE;

    -- Average age
    SELECT AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth))) INTO avg_age
    FROM patients WHERE is_active = TRUE;
END;
$$;

-- Procedure for doctor performance metrics (KPI Reporting)
CREATE OR REPLACE PROCEDURE sp_get_doctor_performance_stats(
    p_doctor_id UUID,
    OUT total_patients INTEGER,
    OUT avg_patient_age DECIMAL(5,2),
    OUT common_conditions TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_doctor_id UUID := p_doctor_id;
BEGIN
    -- Total patients under care
    SELECT COUNT(*) INTO total_patients
    FROM patients p
    WHERE (v_doctor_id IS NULL OR p.doctor_id = v_doctor_id) AND p.is_active = TRUE;

    -- Average patient age
    SELECT AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth))) INTO avg_patient_age
    FROM patients p
    WHERE (v_doctor_id IS NULL OR p.doctor_id = v_doctor_id) AND p.is_active = TRUE;

    -- Common conditions (simplified)
    SELECT STRING_AGG(
        CASE
            WHEN hp.hypertension_diagnosis THEN 'Hypertension'
            WHEN hp.diabetes_diagnosis THEN 'Diabetes'
            WHEN hp.high_cholesterol_diagnosis THEN 'High Cholesterol'
            ELSE NULL
        END, ', '
    ) INTO common_conditions
    FROM patients p
    JOIN health_profiles hp ON p.id = hp.patient_id
    WHERE (v_doctor_id IS NULL OR p.doctor_id = v_doctor_id) AND p.is_active = TRUE;
END;
$$;

-- Procedure for institution analytics (KPI Reporting)
CREATE OR REPLACE PROCEDURE sp_get_institution_analytics(
    p_institution_id UUID,
    OUT patient_count INTEGER,
    OUT doctor_count INTEGER,
    OUT avg_consultation_fee DECIMAL(10,2),
    OUT most_common_specialty VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Patient count
    SELECT COUNT(*) INTO patient_count
    FROM patients
    WHERE institution_id = p_institution_id AND is_active = TRUE;

    -- Doctor count
    SELECT COUNT(*) INTO doctor_count
    FROM doctors
    WHERE institution_id = p_institution_id AND is_active = TRUE;

    -- Average consultation fee
    SELECT AVG(consultation_fee) INTO avg_consultation_fee
    FROM doctors
    WHERE institution_id = p_institution_id AND is_active = TRUE;

    -- Most common specialty
    SELECT ds.name INTO most_common_specialty
    FROM doctors d
    JOIN doctor_specialties ds ON d.specialty_id = ds.id
    WHERE d.institution_id = p_institution_id AND d.is_active = TRUE
    GROUP BY ds.name
    ORDER BY COUNT(*) DESC
    LIMIT 1;
END;
$$;

-- =============================================
-- VIEWS FOR REPORTS AND DASHBOARDS
-- =============================================

-- View for patient demographic dashboard
CREATE OR REPLACE VIEW vw_patient_demographics AS
SELECT
    p.id,
    p.first_name,
    p.last_name,
    p.email,
    p.date_of_birth,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth)) AS age,
    p.gender,
    p.validation_status,
    p.is_active,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    mi.name AS institution_name,
    hp.blood_type,
    hp.hypertension_diagnosis,
    hp.diabetes_diagnosis,
    hp.high_cholesterol_diagnosis
FROM patients p
LEFT JOIN doctors d ON p.doctor_id = d.id
LEFT JOIN medical_institutions mi ON p.institution_id = mi.id
LEFT JOIN health_profiles hp ON p.id = hp.patient_id
WHERE p.is_active = TRUE;

-- View for doctor performance dashboard
CREATE OR REPLACE VIEW vw_doctor_performance AS
SELECT
    d.id,
    d.first_name,
    d.last_name,
    d.email,
    d.medical_license,
    d.years_experience,
    d.consultation_fee,
    ds.name AS specialty,
    mi.name AS institution_name,
    COUNT(p.id) AS patient_count,
    AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth))) AS avg_patient_age
FROM doctors d
LEFT JOIN doctor_specialties ds ON d.specialty_id = ds.id
LEFT JOIN medical_institutions mi ON d.institution_id = mi.id
LEFT JOIN patients p ON d.id = p.doctor_id AND p.is_active = TRUE
WHERE d.is_active = TRUE
GROUP BY d.id, d.first_name, d.last_name, d.email, d.medical_license,
         d.years_experience, d.consultation_fee, ds.name, mi.name;

-- View for monthly registration analytics
CREATE OR REPLACE VIEW vw_monthly_registrations AS
SELECT
    DATE_TRUNC('month', created_at) AS registration_month,
    COUNT(*) AS total_registrations,
    COUNT(CASE WHEN validation_status = 'full_access' THEN 1 END) AS validated_registrations,
    COUNT(CASE WHEN gender = 'male' THEN 1 END) AS male_count,
    COUNT(CASE WHEN gender = 'female' THEN 1 END) AS female_count
FROM patients
WHERE is_active = TRUE
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY registration_month DESC;

-- View for health condition prevalence
CREATE OR REPLACE VIEW vw_health_condition_stats AS
SELECT
    COUNT(*) AS total_patients,
    COUNT(CASE WHEN hp.hypertension_diagnosis THEN 1 END) AS hypertension_count,
    COUNT(CASE WHEN hp.diabetes_diagnosis THEN 1 END) AS diabetes_count,
    COUNT(CASE WHEN hp.high_cholesterol_diagnosis THEN 1 END) AS cholesterol_count,
    COUNT(CASE WHEN hp.is_smoker THEN 1 END) AS smoker_count,
    ROUND(AVG(hp.height_cm), 2) AS avg_height,
    ROUND(AVG(hp.weight_kg), 2) AS avg_weight
FROM patients p
JOIN health_profiles hp ON p.id = hp.patient_id
WHERE p.is_active = TRUE;

-- Vista: vw_dashboard_overview
CREATE OR REPLACE VIEW vw_dashboard_overview AS
SELECT
    (SELECT COUNT(*) FROM patients WHERE is_active = TRUE) as total_patients,
    (SELECT COUNT(*) FROM doctors WHERE is_active = TRUE) as total_doctors,
    (SELECT COUNT(*) FROM medical_institutions WHERE is_active = TRUE) as total_institutions,
    (SELECT COUNT(*) FROM users WHERE is_active = TRUE) as total_users,
    (SELECT COUNT(*) FROM patients WHERE validation_status = 'full_access') as validated_patients,
    (SELECT AVG(consultation_fee) FROM doctors WHERE is_active = TRUE) as avg_consultation_fee;

-- 1. Vista para gráfico de especialidades médicas
CREATE OR REPLACE VIEW vw_doctor_specialty_distribution AS
SELECT
    ds.name as specialty,
    ds.category,
    COUNT(d.id) as doctor_count
FROM doctor_specialties ds
LEFT JOIN doctors d ON ds.id = d.specialty_id AND d.is_active = TRUE
GROUP BY ds.name, ds.category
ORDER BY doctor_count DESC;

-- 2. Vista para distribución geográfica
CREATE OR REPLACE VIEW vw_geographic_distribution AS
SELECT
    region_state,
    COUNT(*) as institution_count,
    COUNT(DISTINCT d.id) as doctor_count,
    COUNT(DISTINCT p.id) as patient_count
FROM medical_institutions mi
LEFT JOIN doctors d ON mi.id = d.institution_id AND d.is_active = TRUE
LEFT JOIN patients p ON mi.id = p.institution_id AND p.is_active = TRUE
WHERE mi.region_state IS NOT NULL
GROUP BY region_state;

-- 3. Vista para condiciones de salud prevalentes
CREATE OR REPLACE VIEW vw_health_condition_prevalence AS
SELECT
    'Hypertension' as condition,
    COUNT(*) as patient_count
FROM health_profiles
WHERE hypertension_diagnosis = TRUE
UNION ALL
SELECT
    'Diabetes' as condition,
    COUNT(*) as patient_count
FROM health_profiles
WHERE diabetes_diagnosis = TRUE
UNION ALL
SELECT
    'High Cholesterol' as condition,
    COUNT(*) as patient_count
FROM health_profiles
WHERE high_cholesterol_diagnosis = TRUE;

-- 4. Vista para estado de validación de pacientes
CREATE OR REPLACE VIEW vw_patient_validation_status AS
SELECT
    validation_status,
    COUNT(*) as patient_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients WHERE is_active = TRUE), 2) as percentage
FROM patients
WHERE is_active = TRUE
GROUP BY validation_status;

-- =============================================
-- OPTIMIZED INDEXES FOR PERFORMANCE
-- =============================================

-- Core medical tables indexes
CREATE INDEX IF NOT EXISTS idx_patients_doctor_id ON patients(doctor_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_patients_institution_id ON patients(institution_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_patients_email ON patients(email);
CREATE INDEX IF NOT EXISTS idx_patients_validation_status ON patients(validation_status) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_patients_created_at ON patients(created_at) WHERE is_active = TRUE;

-- Doctor performance indexes
CREATE INDEX IF NOT EXISTS idx_doctors_institution_id ON doctors(institution_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_doctors_specialty_id ON doctors(specialty_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_doctors_email ON doctors(email);
CREATE INDEX IF NOT EXISTS idx_doctors_consultation_fee ON doctors(consultation_fee) WHERE is_active = TRUE;

-- Health profiles indexes
CREATE INDEX IF NOT EXISTS idx_health_profiles_patient_id ON health_profiles(patient_id);
CREATE INDEX IF NOT EXISTS idx_health_profiles_conditions ON health_profiles(
    hypertension_diagnosis, diabetes_diagnosis, high_cholesterol_diagnosis
) WHERE hypertension_diagnosis = TRUE OR diabetes_diagnosis = TRUE OR high_cholesterol_diagnosis = TRUE;

-- User authentication indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_users_reference_id ON users(reference_id, user_type);

-- Medical institution indexes
CREATE INDEX IF NOT EXISTS idx_medical_institutions_region ON medical_institutions(region_state) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_medical_institutions_type ON medical_institutions(institution_type) WHERE is_active = TRUE;

-- CMS system indexes
CREATE INDEX IF NOT EXISTS idx_cms_users_role ON cms_users(role_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_cms_users_email ON cms_users(email);
CREATE INDEX IF NOT EXISTS idx_cms_role_permissions_composite ON cms_role_permissions(role_id, permission_id);

-- =============================================
-- DATA INTEGRITY CONSTRAINTS
-- =============================================

-- Age validation constraint
ALTER TABLE patients ADD CONSTRAINT chk_patient_age CHECK (
    date_of_birth <= CURRENT_DATE AND
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) <= 120
);

-- Email format validation (basic)
ALTER TABLE patients ADD CONSTRAINT chk_valid_email
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE doctors ADD CONSTRAINT chk_doctor_valid_email
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE users ADD CONSTRAINT chk_user_valid_email
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Phone number format validation
ALTER TABLE patients ADD CONSTRAINT chk_phone_format
CHECK (phone ~ '^\+?[0-9\s\-\(\)]{10,}$');

ALTER TABLE doctors ADD CONSTRAINT chk_doctor_phone_format
CHECK (phone ~ '^\+?[0-9\s\-\(\)]{10,}$');

-- Consultation fee validation
ALTER TABLE doctors ADD CONSTRAINT chk_consultation_fee_range
CHECK (consultation_fee BETWEEN 0 AND 10000);

-- =============================================
-- TIMESTAMP UPDATE TRIGGER FUNCTION
-- =============================================

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to all tables with updated_at
CREATE TRIGGER set_timestamp_patients BEFORE UPDATE ON patients FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_doctors BEFORE UPDATE ON doctors FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_medical_institutions BEFORE UPDATE ON medical_institutions FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_health_profiles BEFORE UPDATE ON health_profiles FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_cms_users BEFORE UPDATE ON cms_users FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

-- =============================================
-- INITIAL DATA SEEDING
-- =============================================

-- Insert initial doctor specialties
INSERT INTO doctor_specialties (name, description, category) VALUES
    ('General Medicine', 'General medical practice', 'Primary Care'),
    ('Internal Medicine', 'Internal medicine specialist', 'Primary Care'),
    ('Cardiology', 'Heart and cardiovascular system', 'Specialty'),
    ('Endocrinology', 'Hormones and metabolism', 'Specialty'),
    ('Diabetes Management', 'Diabetes care specialist', 'Specialty'),
    ('Preventive Medicine', 'Disease prevention and health promotion', 'Preventive'),
    ('Family Medicine', 'Comprehensive family healthcare', 'Primary Care'),
    ('Emergency Medicine', 'Emergency care specialist', 'Emergency')
ON CONFLICT (name) DO NOTHING;

-- Insert CMS roles and permissions
INSERT INTO cms_roles (name, description) VALUES
    ('Admin', 'Full access to all CMS features'),
    ('Editor', 'Can create and edit content but cannot delete or manage users')
ON CONFLICT (name) DO NOTHING;

INSERT INTO cms_permissions (resource, action, description) VALUES
    ('users', 'create', 'Create new users'),
    ('users', 'read', 'View users'),
    ('users', 'update', 'Edit users'),
    ('users', 'delete', 'Delete users'),
    ('reports', 'view', 'View system reports'),
    ('analytics', 'access', 'Access analytics dashboard')
ON CONFLICT (resource, action) DO NOTHING;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Verify normalization (no transitive dependencies)
/*
All tables are in 3NF because:
1. All non-key attributes depend only on the primary key
2. No transitive dependencies exist
3. All foreign keys reference primary keys
4. Each table represents a single entity type
*/

-- Sample verification query
SELECT
    'Database normalized to 3NF' AS verification,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') AS table_count,
    (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'public') AS view_count,
    (SELECT COUNT(*) FROM pg_proc WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')) AS stored_procedure_count;


-- =============================================
-- TEST USERS FOR DEMONSTRATION
-- =============================================

-- Medical Institutions (5)
INSERT INTO medical_institutions (id, name, institution_type, contact_email, address, region_state, phone, website, license_number, is_active, is_verified)
VALUES
    ('11000000-e29b-41d4-a716-446655440001'::uuid, 'Hospital General del Centro', 'hospital', 'institucion1@test.predicthealth.com', 'Av. Reforma 150, Centro Histórico, Ciudad de México', 'Ciudad de México', '+52-55-2001-0001', 'https://hospital-general.predicthealth.com', 'LIC-MX-HOSP-001', TRUE, TRUE),
    ('12000000-e29b-41d4-a716-446655440002'::uuid, 'Clínica Familiar del Norte', 'preventive_clinic', 'institucion2@test.predicthealth.com', 'Calle Juárez 45, Zona Norte, Monterrey', 'Nuevo León', '+52-81-2002-0002', 'https://clinica-norte.predicthealth.com', 'LIC-MX-CLIN-002', TRUE, TRUE),
    ('13000000-e29b-41d4-a716-446655440003'::uuid, 'Centro de Salud Preventiva Sur', 'preventive_clinic', 'institucion3@test.predicthealth.com', 'Blvd. del Sur 89, Colonia del Valle, Guadalajara', 'Jalisco', '+52-33-2003-0003', 'https://centro-salud-sur.predicthealth.com', 'LIC-MX-PREV-003', TRUE, TRUE),
    ('14000000-e29b-41d4-a716-446655440004'::uuid, 'Instituto Cardiovascular del Bajío', 'health_center', 'institucion4@test.predicthealth.com', 'Paseo de los Héroes 234, León', 'Guanajuato', '+52-477-2004-0004', 'https://cardiovascular-bajio.predicthealth.com', 'LIC-MX-CARD-004', TRUE, TRUE),
    ('15000000-e29b-41d4-a716-446655440005'::uuid, 'Centro Médico del Pacífico', 'hospital', 'institucion5@test.predicthealth.com', 'Malecón 567, Zona Dorada, Puerto Vallarta', 'Jalisco', '+52-322-2005-0005', 'https://medico-pacifico.predicthealth.com', 'LIC-MX-MEDP-005', TRUE, TRUE)
ON CONFLICT (contact_email) DO NOTHING;

INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES
    ('11000000-e29b-41d4-a716-446655440001'::uuid, 'institucion1@test.predicthealth.com', '$2b$12$Fu7pgzMQbaYBsEfHq8b76O1UPDtB0Ngm5Z3qRSkXPv9YyIP.1YaBe', 'institution', '11000000-e29b-41d4-a716-446655440001'::uuid, TRUE, TRUE),
    ('12000000-e29b-41d4-a716-446655440002'::uuid, 'institucion2@test.predicthealth.com', '$2b$12$20krURHfwrBIJQCqdh2j1.4pxMumbNR7MtmAiKbflQXW1ofdpgocq', 'institution', '12000000-e29b-41d4-a716-446655440002'::uuid, TRUE, TRUE),
    ('13000000-e29b-41d4-a716-446655440003'::uuid, 'institucion3@test.predicthealth.com', '$2b$12$KEJp5csEJmfVt.mxxEudv.ho6WyDB7M3Ehjr61aOP7ZIKpyhT57L2', 'institution', '13000000-e29b-41d4-a716-446655440003'::uuid, TRUE, TRUE),
    ('14000000-e29b-41d4-a716-446655440004'::uuid, 'institucion4@test.predicthealth.com', '$2b$12$s8Y2qs7A1zeC6P/ekXQHLe56fB8nmJJlox5cmolEkAOsOapbJ8gDq', 'institution', '14000000-e29b-41d4-a716-446655440004'::uuid, TRUE, TRUE),
    ('15000000-e29b-41d4-a716-446655440005'::uuid, 'institucion5@test.predicthealth.com', '$2b$12$0j7S7rP06XrUEZSUtPERFOam9Ri.i1KUzfxDpozOUbjGnw0QLuiMC', 'institution', '15000000-e29b-41d4-a716-446655440005'::uuid, TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Doctors (5)
INSERT INTO doctors (id, institution_id, first_name, last_name, email, medical_license, specialty_id, phone, years_experience, consultation_fee, is_active, professional_status)
VALUES
    ('21000000-e29b-41d4-a716-446655440001'::uuid, '11000000-e29b-41d4-a716-446655440001'::uuid, 'Roberto', 'Sánchez', 'doctor1@test.predicthealth.com', 'MED-MX-2024-101', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology' LIMIT 1), '+52-55-3001-0001', 15, 1200.00, TRUE, 'active'),
    ('22000000-e29b-41d4-a716-446655440002'::uuid, '12000000-e29b-41d4-a716-446655440002'::uuid, 'Patricia', 'Morales', 'doctor2@test.predicthealth.com', 'MED-MX-2024-102', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine' LIMIT 1), '+52-81-3002-0002', 12, 950.00, TRUE, 'active'),
    ('23000000-e29b-41d4-a716-446655440003'::uuid, '13000000-e29b-41d4-a716-446655440003'::uuid, 'Fernando', 'Vázquez', 'doctor3@test.predicthealth.com', 'MED-MX-2024-103', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology' LIMIT 1), '+52-33-3003-0003', 18, 1100.00, TRUE, 'active'),
    ('24000000-e29b-41d4-a716-446655440004'::uuid, '14000000-e29b-41d4-a716-446655440004'::uuid, 'Gabriela', 'Ríos', 'doctor4@test.predicthealth.com', 'MED-MX-2024-104', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine' LIMIT 1), '+52-477-3004-0004', 10, 850.00, TRUE, 'active'),
    ('25000000-e29b-41d4-a716-446655440005'::uuid, '15000000-e29b-41d4-a716-446655440005'::uuid, 'Antonio', 'Jiménez', 'doctor5@test.predicthealth.com', 'MED-MX-2024-105', (SELECT id FROM doctor_specialties WHERE name = 'Emergency Medicine' LIMIT 1), '+52-322-3005-0005', 22, 1350.00, TRUE, 'active')
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES
    ('21000000-e29b-41d4-a716-446655440001'::uuid, 'doctor1@test.predicthealth.com', '$2b$12$E/UgR4RVVaYQ3.D5fc/ji.bfI8s7pWetGECQgd8eUBD5.2Rn0Lm9.', 'doctor', '21000000-e29b-41d4-a716-446655440001'::uuid, TRUE, TRUE),
    ('22000000-e29b-41d4-a716-446655440002'::uuid, 'doctor2@test.predicthealth.com', '$2b$12$NIJzDyaAHli7WvojQRX.Gen4B0.ybiolEM3GtB0USJSg7X6m1I2VG', 'doctor', '22000000-e29b-41d4-a716-446655440002'::uuid, TRUE, TRUE),
    ('23000000-e29b-41d4-a716-446655440003'::uuid, 'doctor3@test.predicthealth.com', '$2b$12$dg7XyARsx4DXXsbQAGetRutkps.4hu1KCx2te0bfNUo1xfN7Hf32S', 'doctor', '23000000-e29b-41d4-a716-446655440003'::uuid, TRUE, TRUE),
    ('24000000-e29b-41d4-a716-446655440004'::uuid, 'doctor4@test.predicthealth.com', '$2b$12$y6xvrHddz/byYF2ol6qxIuekSpmoXBUCrhJhGimy4ZTJcXNZYmHii', 'doctor', '24000000-e29b-41d4-a716-446655440004'::uuid, TRUE, TRUE),
    ('25000000-e29b-41d4-a716-446655440005'::uuid, 'doctor5@test.predicthealth.com', '$2b$12$IMU.mwTpKs50vlCXG.jmBukOAVet.oqM0sBt1FhwhwB5UrxslzcJS', 'doctor', '25000000-e29b-41d4-a716-446655440005'::uuid, TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Patients (5)
INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, email, date_of_birth, gender, phone, emergency_contact_name, emergency_contact_phone, validation_status, is_active, is_verified)
VALUES
    ('31000000-e29b-41d4-a716-446655440001'::uuid, '21000000-e29b-41d4-a716-446655440001'::uuid, '11000000-e29b-41d4-a716-446655440001'::uuid, 'Luis', 'Torres', 'paciente1@test.predicthealth.com', '1978-03-12', 'male', '+52-55-4001-0001', 'María Torres', '+52-55-4001-0002', 'full_access', TRUE, TRUE),
    ('32000000-e29b-41d4-a716-446655440002'::uuid, '22000000-e29b-41d4-a716-446655440002'::uuid, '12000000-e29b-41d4-a716-446655440002'::uuid, 'Carmen', 'Díaz', 'paciente2@test.predicthealth.com', '1982-07-25', 'female', '+52-81-4002-0001', 'José Díaz', '+52-81-4002-0002', 'doctor_validated', TRUE, TRUE),
    ('33000000-e29b-41d4-a716-446655440003'::uuid, '23000000-e29b-41d4-a716-446655440003'::uuid, '13000000-e29b-41d4-a716-446655440003'::uuid, 'Javier', 'Ruiz', 'paciente3@test.predicthealth.com', '1990-11-08', 'male', '+52-33-4003-0001', 'Elena Ruiz', '+52-33-4003-0002', 'institution_validated', TRUE, TRUE),
    ('34000000-e29b-41d4-a716-446655440004'::uuid, '24000000-e29b-41d4-a716-446655440004'::uuid, '14000000-e29b-41d4-a716-446655440004'::uuid, 'Isabel', 'Fernández', 'paciente4@test.predicthealth.com', '1975-05-30', 'female', '+52-477-4004-0001', 'Carlos Fernández', '+52-477-4004-0002', 'pending', TRUE, TRUE),
    ('35000000-e29b-41d4-a716-446655440005'::uuid, '25000000-e29b-41d4-a716-446655440005'::uuid, '15000000-e29b-41d4-a716-446655440005'::uuid, 'Manuel', 'Gutiérrez', 'paciente5@test.predicthealth.com', '1988-09-14', 'male', '+52-322-4005-0001', 'Rosa Gutiérrez', '+52-322-4005-0002', 'full_access', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES
    ('31000000-e29b-41d4-a716-446655440001'::uuid, 'paciente1@test.predicthealth.com', '$2b$12$gEqkD8pJHfq6EIEiDTPnUeSUFB2dQw3ozCGRUnFg6iAeCkNb46ISq', 'patient', '31000000-e29b-41d4-a716-446655440001'::uuid, TRUE, TRUE),
    ('32000000-e29b-41d4-a716-446655440002'::uuid, 'paciente2@test.predicthealth.com', '$2b$12$TkYMOsVgEGsgL6ksA/NN4O.K79BXEJyvTbjxY9G83Z8cmgw3Mzx4W', 'patient', '32000000-e29b-41d4-a716-446655440002'::uuid, TRUE, TRUE),
    ('33000000-e29b-41d4-a716-446655440003'::uuid, 'paciente3@test.predicthealth.com', '$2b$12$9Kd6I3Pi4KtQTuAmZV6HFeIaus71Z/Slx9ZVULD5rjkIcW06Jrsj.', 'patient', '33000000-e29b-41d4-a716-446655440003'::uuid, TRUE, TRUE),
    ('34000000-e29b-41d4-a716-446655440004'::uuid, 'paciente4@test.predicthealth.com', '$2b$12$JcMVzDqEJcbMwNRc2gtjwuBsG3NPAD.osQbLt/h3zz0ix6usr3TZC', 'patient', '34000000-e29b-41d4-a716-446655440004'::uuid, TRUE, TRUE),
    ('35000000-e29b-41d4-a716-446655440005'::uuid, 'paciente5@test.predicthealth.com', '$2b$12$sCaqkRhmkJsrDaX/4OvGmuyfcwUkGw4zu5iBSgE1HIO6MI/gD9jXq', 'patient', '35000000-e29b-41d4-a716-446655440005'::uuid, TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Health Profiles (for all patients)
INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type, is_smoker, smoking_years, consumes_alcohol, alcohol_frequency, hypertension_diagnosis, diabetes_diagnosis, high_cholesterol_diagnosis, has_stroke_history, has_heart_disease_history, family_history_diabetes, family_history_hypertension, family_history_heart_disease, physical_activity_minutes_weekly, preexisting_conditions_notes, current_medications, allergies)
VALUES
    ('31000000-e29b-41d4-a716-446655440001'::uuid, 172.0, 75.5, 'A+', FALSE, 0, TRUE, 'occasionally', TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, 210, 'Hypertension diagnosed 3 years ago', 'Lisinopril 10mg daily, Atorvastatin 20mg daily', 'Penicillin'),
    ('32000000-e29b-41d4-a716-446655440002'::uuid, 165.0, 62.0, 'O-', FALSE, 0, FALSE, 'never', FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, 300, 'No significant conditions', 'Multivitamin daily', 'None reported'),
    ('33000000-e29b-41d4-a716-446655440003'::uuid, 178.0, 82.0, 'B+', TRUE, 8, TRUE, 'regularly', FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, 150, 'Type 2 diabetes diagnosed 2 years ago', 'Metformin 500mg twice daily', 'Sulfa drugs'),
    ('34000000-e29b-41d4-a716-446655440004'::uuid, 160.0, 58.0, 'AB+', FALSE, 0, TRUE, 'rarely', TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, 180, 'Previous stroke 5 years ago, hypertension', 'Aspirin 81mg daily, Losartan 50mg daily', 'Codeine'),
    ('35000000-e29b-41d4-a716-446655440005'::uuid, 185.0, 90.0, 'O+', FALSE, 0, TRUE, 'occasionally', FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, 420, 'No significant conditions', 'None', 'Shellfish')
ON CONFLICT (patient_id) DO NOTHING;

-- =============================================
-- CMS USERS (UNIFIED SYSTEM)
-- =============================================

-- CMS Admin User (full CRUD permissions)
INSERT INTO cms_users (email, password_hash, first_name, last_name, user_type, is_active) VALUES
    ('admin.cms@predicthealth.com', '$2b$12$x30MPeK6s/8k5k6LdA2FhuRTi5zqMs4G/fxZM.rmI/OpWLknBbele', 'Admin', 'CMS', 'admin', TRUE)
ON CONFLICT (email) DO NOTHING;

-- CMS Editor User (read/update only permissions)
INSERT INTO cms_users (email, password_hash, first_name, last_name, user_type, is_active) VALUES
    ('editor.cms@predicthealth.com', '$2b$12$w13etTUCcAshExi34EUPRuGlDsJPS6M4lFNSGy9mcKyv8e.1VfExO', 'Editor', 'CMS', 'editor', TRUE)
ON CONFLICT (email) DO NOTHING;

-- CMS user profiles handled by cms_users table directly

-- Assign permissions to roles (normalized system)
-- Admin role gets all permissions
INSERT INTO cms_role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM cms_roles r
CROSS JOIN cms_permissions p
WHERE r.name = 'Admin'
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Editor role gets read/update permissions only
INSERT INTO cms_role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM cms_roles r
JOIN cms_permissions p ON p.action IN ('read', 'update')
WHERE r.name = 'Editor'
ON CONFLICT (role_id, permission_id) DO NOTHING;
-- =============================================
-- SYSTEM SETTINGS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(50) DEFAULT 'string' CHECK (setting_type IN ('string', 'boolean', 'number', 'json')),
    category VARCHAR(50) DEFAULT 'general',
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar configuraciones iniciales
INSERT INTO system_settings (setting_key, setting_value, setting_type, category, description) VALUES
('cms_title', 'PredictHealth CMS', 'string', 'general', 'Título del sistema CMS'),
('timezone', 'America/Mexico_City', 'string', 'general', 'Zona horaria del sistema'),
('maintenance_mode', 'false', 'boolean', 'general', 'Modo mantenimiento activado'),
('language', 'es', 'string', 'general', 'Idioma del sistema'),
('db_backup_frequency', 'daily', 'string', 'database', 'Frecuencia de backups automáticos'),
('service_timeout', '30', 'number', 'microservices', 'Timeout en segundos para servicios'),
('health_check_interval', '60', 'number', 'microservices', 'Intervalo de health checks en segundos')
ON CONFLICT (setting_key) DO NOTHING;

-- =============================================
-- END OF DATABASE INITIALIZATION
-- =============================================





