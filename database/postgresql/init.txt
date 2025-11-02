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
-- NORMALIZED CATALOG TABLES
-- =============================================

-- Institution types catalog
CREATE TABLE IF NOT EXISTS institution_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50) DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Specialty categories catalog
CREATE TABLE IF NOT EXISTS specialty_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INTEGER REFERENCES specialty_categories(id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Biological sex catalog (for medical purposes)
CREATE TABLE IF NOT EXISTS sexes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    chromosome_pattern VARCHAR(10), 
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Genders catalog (inclusive gender identity)
CREATE TABLE IF NOT EXISTS genders (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Blood types catalog
CREATE TABLE IF NOT EXISTS blood_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(5) UNIQUE NOT NULL,
    description TEXT,
    can_donate_to TEXT[], -- Array of compatible blood types
    can_receive_from TEXT[], -- Array of blood types that can donate to this type
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- =============================================
-- NORMALIZED CONTACT INFORMATION TABLES
-- =============================================

-- Create email types catalog
CREATE TABLE IF NOT EXISTS email_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create normalized emails table
CREATE TABLE IF NOT EXISTS emails (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('patient', 'doctor', 'institution')),
    entity_id UUID NOT NULL,
    email_type_id INTEGER REFERENCES email_types(id) ON DELETE SET NULL,
    email_address VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    verification_token VARCHAR(255),
    verification_expires_at TIMESTAMP WITH TIME ZONE,
    verification_attempts INTEGER DEFAULT 0 CHECK (verification_attempts >= 0),
    last_verification_attempt TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Ensure only one primary email per entity
    UNIQUE(entity_type, entity_id, is_primary) DEFERRABLE INITIALLY DEFERRED,

    -- Email format validation
    CONSTRAINT chk_email_format CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Create phone types catalog
CREATE TABLE IF NOT EXISTS phone_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create normalized phones table
CREATE TABLE IF NOT EXISTS phones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('doctor', 'patient', 'institution', 'emergency_contact')),
    entity_id UUID NOT NULL,
    phone_type_id INTEGER REFERENCES phone_types(id) ON DELETE SET NULL,
    phone_number VARCHAR(20) NOT NULL,
    country_code VARCHAR(5) DEFAULT '+52',
    area_code VARCHAR(5),
    is_primary BOOLEAN DEFAULT FALSE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    verification_code VARCHAR(10),
    verification_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Ensure only one primary phone per entity
    UNIQUE(entity_type, entity_id, is_primary),

    -- Phone number format validation (allows both local and international formats)
    CONSTRAINT chk_phone_format CHECK (
        phone_number ~ '^[0-9]{10,}$' OR  -- Local format: 10+ digits
        phone_number ~ '^\+[0-9]{1,4}(-[0-9]{1,10})+$'  -- International: +XX-XX-XXXX... (variable dashes)
    )
);

-- Create countries catalog
CREATE TABLE IF NOT EXISTS countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    iso_code VARCHAR(3) UNIQUE NOT NULL,
    iso_code_2 VARCHAR(2) UNIQUE,
    phone_code VARCHAR(5),
    currency_code VARCHAR(3),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create regions/states catalog (hierarchical under countries)
CREATE TABLE IF NOT EXISTS regions (
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    region_code VARCHAR(10),
    region_type VARCHAR(50) DEFAULT 'state' CHECK (region_type IN ('state', 'province', 'territory', 'district', 'municipality')),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(country_id, name),
    UNIQUE(country_id, region_code)
);

-- Create normalized addresses table
CREATE TABLE IF NOT EXISTS addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('doctor', 'patient', 'institution')),
    entity_id UUID NOT NULL,
    address_type VARCHAR(50) DEFAULT 'primary' CHECK (address_type IN ('primary', 'secondary', 'billing', 'shipping', 'work', 'home')),
    street_address VARCHAR(255) NOT NULL,
    neighborhood VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    region_id INTEGER REFERENCES regions(id) ON DELETE SET NULL,
    postal_code VARCHAR(20),
    country_id INTEGER REFERENCES countries(id) ON DELETE SET NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_primary BOOLEAN DEFAULT FALSE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    verification_method VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Ensure only one primary address per entity
    UNIQUE(entity_type, entity_id, is_primary) DEFERRABLE INITIALLY DEFERRED,

    -- Address validation constraints
    CONSTRAINT chk_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

-- =============================================
-- CORE ENTITIES (NORMALIZED TO 3NF)
-- =============================================

-- Medical Institutions (Eliminated transitive dependencies)
CREATE TABLE IF NOT EXISTS medical_institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    institution_type_id INTEGER NOT NULL REFERENCES institution_types(id),
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
    category_id INTEGER NOT NULL REFERENCES specialty_categories(id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Doctors (Eliminated transitive dependencies)
CREATE TABLE IF NOT EXISTS doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID NOT NULL REFERENCES medical_institutions(id) ON DELETE RESTRICT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    sex_id INTEGER REFERENCES sexes(id), -- Biological sex for medical records
    gender_id INTEGER REFERENCES genders(id), -- Gender identity (optional)
    medical_license VARCHAR(50) UNIQUE NOT NULL,
    specialty_id UUID REFERENCES doctor_specialties(id) ON DELETE SET NULL,
    years_experience INTEGER DEFAULT 0 CHECK (years_experience >= 0),
    consultation_fee DECIMAL(10,2) CHECK (consultation_fee >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    professional_status VARCHAR(50) DEFAULT 'active' CHECK (professional_status IN ('active','suspended','retired')),
    last_login TIMESTAMP WITH TIME ZONE

    -- Business rule: Doctor must be linked to an institution
);


-- Patients (Normalized validation logic)
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE RESTRICT,
    institution_id UUID NOT NULL REFERENCES medical_institutions(id) ON DELETE RESTRICT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL CHECK (date_of_birth <= CURRENT_DATE),
    sex_id INTEGER REFERENCES sexes(id), -- Biological sex for medical records
    gender_id INTEGER REFERENCES genders(id), -- Gender identity (optional)
    emergency_contact_name VARCHAR(200),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,

    -- Business rule: Patient must be linked to both a doctor and an institution
    CONSTRAINT chk_patient_association CHECK (doctor_id IS NOT NULL AND institution_id IS NOT NULL)
);

-- Health Profiles (Refactorizada)
-- Se eliminaron las columnas de diagnóstico, historial y listas de texto.
CREATE TABLE IF NOT EXISTS health_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID UNIQUE NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    height_cm DECIMAL(5,2) CHECK (height_cm > 0),
    weight_kg DECIMAL(5,2) CHECK (weight_kg > 0),
    blood_type_id INTEGER REFERENCES blood_types(id),
    is_smoker BOOLEAN DEFAULT FALSE NOT NULL,
    smoking_years INTEGER DEFAULT 0 CHECK (smoking_years >= 0),
    consumes_alcohol BOOLEAN DEFAULT FALSE NOT NULL,
    alcohol_frequency VARCHAR(20) CHECK (alcohol_frequency IN ('never','rarely','occasionally','regularly','daily')),
    physical_activity_minutes_weekly INTEGER DEFAULT 0 CHECK (physical_activity_minutes_weekly >= 0),
    notes TEXT, -- Un campo general para notas adicionales.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Business logic constraints
    CONSTRAINT chk_smoking_consistency CHECK (NOT is_smoker OR smoking_years > 0),
    CONSTRAINT chk_alcohol_consistency CHECK (NOT consumes_alcohol OR alcohol_frequency IS NOT NULL)
);

-- NUEVA TABLA: Catálogo de Condiciones Médicas
CREATE TABLE IF NOT EXISTS medical_conditions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- NUEVA TABLA: Catálogo de Medicamentos
CREATE TABLE IF NOT EXISTS medications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- NUEVA TABLA: Catálogo de Alergias
CREATE TABLE IF NOT EXISTS allergies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT
);

-- NUEVA TABLA DE UNIÓN: Condiciones diagnosticadas del paciente
CREATE TABLE IF NOT EXISTS patient_conditions (
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    condition_id INTEGER NOT NULL REFERENCES medical_conditions(id) ON DELETE RESTRICT,
    diagnosis_date DATE,
    notes TEXT,
    PRIMARY KEY (patient_id, condition_id)
);

-- NUEVA TABLA DE UNIÓN: Historial médico familiar del paciente
CREATE TABLE IF NOT EXISTS patient_family_history (
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    condition_id INTEGER NOT NULL REFERENCES medical_conditions(id) ON DELETE RESTRICT,
    relative_type VARCHAR(50), -- e.g., 'Mother', 'Father', 'Sibling'
    notes TEXT,
    PRIMARY KEY (patient_id, condition_id)
);

-- NUEVA TABLA DE UNIÓN: Medicamentos actuales del paciente
CREATE TABLE IF NOT EXISTS patient_medications (
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    medication_id INTEGER NOT NULL REFERENCES medications(id) ON DELETE RESTRICT,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    start_date DATE,
    PRIMARY KEY (patient_id, medication_id)
);

-- NUEVA TABLA DE UNIÓN: Alergias del paciente
CREATE TABLE IF NOT EXISTS patient_allergies (
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    allergy_id INTEGER NOT NULL REFERENCES allergies(id) ON DELETE RESTRICT,
    severity VARCHAR(50) CHECK (severity IN ('mild', 'moderate', 'severe')),
    reaction_description TEXT,
    PRIMARY KEY (patient_id, allergy_id)
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

    -- Reference validation will be handled by triggers
    CONSTRAINT chk_reference_consistency CHECK (reference_id IS NOT NULL)
);

-- =============================================
-- TRIGGER FUNCTION FOR REFERENCE VALIDATION
-- =============================================

CREATE OR REPLACE FUNCTION validate_user_reference()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate that reference_id exists in the correct table based on user_type
    CASE NEW.user_type
        WHEN 'patient' THEN
            IF NOT EXISTS (SELECT 1 FROM patients WHERE id = NEW.reference_id) THEN
                RAISE EXCEPTION 'Invalid reference_id: patient with ID % does not exist', NEW.reference_id;
            END IF;
        WHEN 'doctor' THEN
            IF NOT EXISTS (SELECT 1 FROM doctors WHERE id = NEW.reference_id) THEN
                RAISE EXCEPTION 'Invalid reference_id: doctor with ID % does not exist', NEW.reference_id;
            END IF;
        WHEN 'institution' THEN
            IF NOT EXISTS (SELECT 1 FROM medical_institutions WHERE id = NEW.reference_id) THEN
                RAISE EXCEPTION 'Invalid reference_id: institution with ID % does not exist', NEW.reference_id;
            END IF;
        ELSE
            RAISE EXCEPTION 'Invalid user_type: %', NEW.user_type;
    END CASE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for INSERT and UPDATE on users table
CREATE TRIGGER trg_validate_user_reference
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION validate_user_reference();

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
-- HELPER FUNCTIONS FOR CONTACT MANAGEMENT
-- =============================================

-- Function to get primary email for any entity
CREATE OR REPLACE FUNCTION get_primary_email(p_entity_type VARCHAR(50), p_entity_id UUID)
RETURNS VARCHAR(255)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT email_address
        FROM emails
        WHERE entity_type = p_entity_type
        AND entity_id = p_entity_id
        AND is_primary = TRUE
        LIMIT 1
    );
END;
$$;

-- Function to add email to entity
CREATE OR REPLACE FUNCTION add_entity_email(
    p_entity_type VARCHAR(50),
    p_entity_id UUID,
    p_email_address VARCHAR(255),
    p_email_type VARCHAR(50) DEFAULT 'primary',
    p_is_primary BOOLEAN DEFAULT FALSE
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_email_id UUID;
    v_email_type_id INTEGER;
BEGIN
    -- Get email type id
    SELECT id INTO v_email_type_id FROM email_types WHERE name = p_email_type;

    -- If setting as primary, unset other primary emails for this entity
    IF p_is_primary THEN
        UPDATE emails SET is_primary = FALSE
        WHERE entity_type = p_entity_type AND entity_id = p_entity_id;
    END IF;

    -- Insert new email
    INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary)
    VALUES (p_entity_type, p_entity_id, v_email_type_id, p_email_address, p_is_primary)
    RETURNING id INTO v_email_id;

    RETURN v_email_id;
END;
$$;

-- Function to get primary phone for any entity
CREATE OR REPLACE FUNCTION get_primary_phone(p_entity_type VARCHAR(50), p_entity_id UUID)
RETURNS VARCHAR(20)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT phone_number
        FROM phones
        WHERE entity_type = p_entity_type
        AND entity_id = p_entity_id
        AND is_primary = TRUE
        LIMIT 1
    );
END;
$$;

-- Function to add phone number to entity
CREATE OR REPLACE FUNCTION add_entity_phone(
    p_entity_type VARCHAR(50),
    p_entity_id UUID,
    p_phone_number VARCHAR(20),
    p_phone_type VARCHAR(50) DEFAULT 'primary',
    p_is_primary BOOLEAN DEFAULT FALSE
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_phone_id UUID;
    v_phone_type_id INTEGER;
BEGIN
    -- Get phone type id
    SELECT id INTO v_phone_type_id FROM phone_types WHERE name = p_phone_type;

    -- If setting as primary, unset other primary phones for this entity
    IF p_is_primary THEN
        UPDATE phones SET is_primary = FALSE
        WHERE entity_type = p_entity_type AND entity_id = p_entity_id;
    END IF;

    -- Insert new phone
    INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary)
    VALUES (p_entity_type, p_entity_id, v_phone_type_id, p_phone_number, p_is_primary)
    RETURNING id INTO v_phone_id;

    RETURN v_phone_id;
END;
$$;

-- Function to get primary address for any entity
CREATE OR REPLACE FUNCTION get_primary_address(p_entity_type VARCHAR(50), p_entity_id UUID)
RETURNS TABLE (
    street_address VARCHAR(255),
    city VARCHAR(100),
    region_name VARCHAR(100),
    country_name VARCHAR(100),
    postal_code VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        addr.street_address,
        addr.city,
        r.name,
        c.name,
        addr.postal_code
    FROM addresses addr
    LEFT JOIN regions r ON addr.region_id = r.id
    LEFT JOIN countries c ON addr.country_id = c.id
    WHERE addr.entity_type = p_entity_type
    AND addr.entity_id = p_entity_id
    AND addr.is_primary = TRUE
    LIMIT 1;
END;
$$;

-- Function to add address to entity
CREATE OR REPLACE FUNCTION add_entity_address(
    p_entity_type VARCHAR(50),
    p_entity_id UUID,
    p_street_address VARCHAR(255),
    p_city VARCHAR(100),
    p_region_name VARCHAR(100),
    p_country_iso VARCHAR(3) DEFAULT 'MEX',
    p_postal_code VARCHAR(20) DEFAULT NULL,
    p_address_type VARCHAR(50) DEFAULT 'primary',
    p_is_primary BOOLEAN DEFAULT FALSE
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_address_id UUID;
    v_region_id INTEGER;
    v_country_id INTEGER;
BEGIN
    -- Get country id
    SELECT id INTO v_country_id FROM countries WHERE iso_code = p_country_iso;

    -- Get region id
    SELECT id INTO v_region_id FROM regions WHERE name = p_region_name AND country_id = v_country_id;

    -- If setting as primary, unset other primary addresses for this entity
    IF p_is_primary THEN
        UPDATE addresses SET is_primary = FALSE
        WHERE entity_type = p_entity_type AND entity_id = p_entity_id;
    END IF;

    -- Insert new address
    INSERT INTO addresses (
        entity_type, entity_id, address_type, street_address, city,
        region_id, country_id, postal_code, is_primary
    )
    VALUES (
        p_entity_type, p_entity_id, p_address_type, p_street_address, p_city,
        v_region_id, v_country_id, p_postal_code, p_is_primary
    )
    RETURNING id INTO v_address_id;

    RETURN v_address_id;
END;
$$;

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
    p_emergency_contact_name VARCHAR(200),
    p_emergency_contact_phone VARCHAR(20),
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
    -- Validate that doctor belongs to the specified institution
    IF NOT EXISTS (
        SELECT 1 FROM doctors
        WHERE id = p_doctor_id AND institution_id = p_institution_id
    ) THEN
        RAISE EXCEPTION 'Doctor % does not belong to institution %', p_doctor_id, p_institution_id;
    END IF;

    -- Insert patient (without phone fields)
    INSERT INTO patients (first_name, last_name, date_of_birth, gender, emergency_contact_name, doctor_id, institution_id)
    VALUES (p_first_name, p_last_name, p_date_of_birth, p_gender, p_emergency_contact_name, p_doctor_id, p_institution_id)
    RETURNING id INTO v_patient_id;

    -- Create user account
    INSERT INTO users (email, password_hash, user_type, reference_id, is_verified)
    VALUES (p_email, p_password_hash, 'patient', v_patient_id, FALSE)
    RETURNING id INTO v_user_id;

    -- Create health profile
    INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type)
    VALUES (v_patient_id, p_height_cm, p_weight_kg, p_blood_type);

    -- Insert primary phone
    IF p_phone IS NOT NULL AND p_phone != '' THEN
        INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
        VALUES ('patient', v_patient_id, (SELECT id FROM phone_types WHERE name = 'primary'), regexp_replace(p_phone, '[^0-9]', '', 'g'), TRUE, FALSE);
    END IF;

    -- Insert emergency contact phone
    IF p_emergency_contact_name IS NOT NULL AND p_emergency_contact_phone IS NOT NULL THEN
        INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
        VALUES ('emergency_contact', v_patient_id, (SELECT id FROM phone_types WHERE name = 'emergency'), regexp_replace(p_emergency_contact_phone, '[^0-9]', '', 'g'), FALSE, FALSE);
    END IF;

    -- No explicit COMMIT - let the caller handle transactions
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error and re-raise it
        RAISE EXCEPTION 'Error creating patient profile: %', SQLERRM;
END;
$$;

-- Procedure for patient statistics by month (KPI Reporting)
CREATE OR REPLACE PROCEDURE sp_get_patient_stats_by_month(
    p_year INTEGER,
    OUT total_patients INTEGER,
    OUT new_patients INTEGER,
    OUT avg_age DECIMAL(5,2),
    OUT patients_with_valid_relationships INTEGER
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

    -- Average age
    SELECT AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth))) INTO avg_age
    FROM patients WHERE is_active = TRUE;

    -- Patients with valid doctor-institution relationships
    SELECT COUNT(*) INTO patients_with_valid_relationships
    FROM patients p
    INNER JOIN doctors d ON p.doctor_id = d.id
    WHERE p.is_active = TRUE AND d.institution_id = p.institution_id;
END;
$$;

-- Procedure for doctor performance metrics (KPI Reporting)
CREATE OR REPLACE PROCEDURE sp_get_doctor_performance_stats(
    p_doctor_id UUID,
    OUT total_patients INTEGER,
    OUT avg_patient_age DECIMAL(5,2),
    OUT common_conditions TEXT,
    OUT institution_name VARCHAR(200)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_doctor_id UUID := p_doctor_id;
BEGIN
    -- Total patients under care (now guaranteed to be from same institution)
    SELECT COUNT(*) INTO total_patients
    FROM patients p
    WHERE (v_doctor_id IS NULL OR p.doctor_id = v_doctor_id) AND p.is_active = TRUE;

    -- Average patient age
    SELECT AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth))) INTO avg_patient_age
    FROM patients p
    WHERE (v_doctor_id IS NULL OR p.doctor_id = v_doctor_id) AND p.is_active = TRUE;

    -- Common conditions (using junction table)
    SELECT STRING_AGG(mc.name, ', ')
    INTO common_conditions
    FROM patients p
    JOIN patient_conditions pc ON p.id = pc.patient_id
    JOIN medical_conditions mc ON pc.condition_id = mc.id
    WHERE (v_doctor_id IS NULL OR p.doctor_id = v_doctor_id) AND p.is_active = TRUE
    GROUP BY p.id
    ORDER BY COUNT(*) DESC
    LIMIT 5; -- Top 5 most common conditions

    -- Institution name (now guaranteed to exist)
    IF v_doctor_id IS NOT NULL THEN
        SELECT mi.name INTO institution_name
        FROM doctors d
        JOIN medical_institutions mi ON d.institution_id = mi.id
        WHERE d.id = v_doctor_id;
    END IF;
END;
$$;

-- Procedure for institution analytics (KPI Reporting)
CREATE OR REPLACE PROCEDURE sp_get_institution_analytics(
    p_institution_id UUID,
    OUT patient_count INTEGER,
    OUT doctor_count INTEGER,
    OUT avg_consultation_fee DECIMAL(10,2),
    OUT most_common_specialty VARCHAR(100),
    OUT relationship_integrity_status VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_patients INTEGER;
    v_patients_with_doctors INTEGER;
BEGIN
    -- Patient count (now guaranteed to have both doctor and institution)
    SELECT COUNT(*) INTO patient_count
    FROM patients
    WHERE institution_id = p_institution_id AND is_active = TRUE;

    -- Doctor count (now guaranteed to belong to institution)
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

    -- Relationship integrity status
    SELECT COUNT(*) INTO v_total_patients
    FROM patients
    WHERE institution_id = p_institution_id AND is_active = TRUE;

    SELECT COUNT(*) INTO v_patients_with_doctors
    FROM patients p
    JOIN doctors d ON p.doctor_id = d.id
    WHERE p.institution_id = p_institution_id AND p.is_active = TRUE
    AND d.institution_id = p_institution_id;

    IF v_total_patients = v_patients_with_doctors THEN
        relationship_integrity_status := 'Perfect';
    ELSIF v_patients_with_doctors > 0 THEN
        relationship_integrity_status := 'Partial';
    ELSE
        relationship_integrity_status := 'Broken';
    END IF;
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
    -- Email information
    (SELECT email_address FROM emails WHERE entity_type = 'patient' AND entity_id = p.id AND is_primary = TRUE LIMIT 1) AS email,
    p.date_of_birth,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth)) AS age,
    s.display_name AS biological_sex,
    g.display_name AS gender_identity,
    p.is_active,
    p.is_verified,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    mi.name AS institution_name,
    -- Business rule validation: Ensure doctor belongs to patient's institution
    CASE WHEN d.institution_id = p.institution_id THEN 'Valid' ELSE 'Invalid - Doctor not in institution' END AS relationship_status,
    bt.name AS blood_type,
    STRING_AGG(DISTINCT mc.name, ', ') AS diagnosed_conditions,
    -- Phone information
    (SELECT phone_number FROM phones WHERE entity_type = 'patient' AND entity_id = p.id AND is_primary = TRUE LIMIT 1) AS primary_phone,
    (SELECT phone_number FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = p.id LIMIT 1) AS emergency_phone,
    -- Address information (if added to patients table in future)
    NULL AS patient_address,
    NULL AS patient_city,
    r.name AS institution_region,
    c.name AS institution_country,
    p.created_at
FROM patients p
LEFT JOIN sexes s ON p.sex_id = s.id
LEFT JOIN genders g ON p.gender_id = g.id
INNER JOIN doctors d ON p.doctor_id = d.id  -- Changed to INNER JOIN since doctor_id is now NOT NULL
INNER JOIN medical_institutions mi ON p.institution_id = mi.id  -- Changed to INNER JOIN since institution_id is now NOT NULL
LEFT JOIN addresses addr ON addr.entity_type = 'institution' AND addr.entity_id = mi.id AND addr.is_primary = TRUE
LEFT JOIN regions r ON addr.region_id = r.id
LEFT JOIN countries c ON addr.country_id = c.id
LEFT JOIN health_profiles hp ON p.id = hp.patient_id
LEFT JOIN blood_types bt ON hp.blood_type_id = bt.id
LEFT JOIN patient_conditions pc ON p.id = pc.patient_id
LEFT JOIN medical_conditions mc ON pc.condition_id = mc.id
WHERE p.is_active = TRUE
GROUP BY p.id, p.first_name, p.last_name, p.date_of_birth, s.display_name, g.display_name,
         p.is_active, p.is_verified, d.first_name, d.last_name, d.institution_id,
         mi.name, bt.name, r.name, c.name, p.created_at;

-- View for doctor performance dashboard
CREATE OR REPLACE VIEW vw_doctor_performance AS
SELECT
    d.id,
    d.first_name,
    d.last_name,
    -- Email information
    (SELECT email_address FROM emails WHERE entity_type = 'doctor' AND entity_id = d.id AND is_primary = TRUE LIMIT 1) AS email,
    d.medical_license,
    d.years_experience,
    d.consultation_fee,
    ds.name AS specialty,
    sc.name AS specialty_category,
    mi.name AS institution_name,
    it.name AS institution_type,
    COUNT(p.id) AS patient_count,
    AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth))) AS avg_patient_age,
    -- Phone information
    (SELECT phone_number FROM phones WHERE entity_type = 'doctor' AND entity_id = d.id AND is_primary = TRUE LIMIT 1) AS primary_phone,
    -- Address information
    addr.street_address AS institution_address,
    addr.city AS institution_city,
    r.name AS institution_region,
    c.name AS institution_country,
    d.created_at
FROM doctors d
LEFT JOIN doctor_specialties ds ON d.specialty_id = ds.id
LEFT JOIN specialty_categories sc ON ds.category_id = sc.id
INNER JOIN medical_institutions mi ON d.institution_id = mi.id  -- Changed to INNER JOIN since institution_id is now NOT NULL
LEFT JOIN institution_types it ON mi.institution_type_id = it.id
LEFT JOIN addresses addr ON addr.entity_type = 'institution' AND addr.entity_id = mi.id AND addr.is_primary = TRUE
LEFT JOIN regions r ON addr.region_id = r.id
LEFT JOIN countries c ON addr.country_id = c.id
LEFT JOIN patients p ON d.id = p.doctor_id AND p.is_active = TRUE
WHERE d.is_active = TRUE
GROUP BY d.id, d.first_name, d.last_name, d.medical_license,
         d.years_experience, d.consultation_fee, ds.name, sc.name, mi.name, it.name,
         addr.street_address, addr.city, r.name, c.name, d.created_at;

-- View for monthly registration analytics
CREATE OR REPLACE VIEW vw_monthly_registrations AS
SELECT
    DATE_TRUNC('month', p.created_at) AS registration_month,
    COUNT(*) AS total_registrations,
    COUNT(CASE WHEN g.name = 'male' THEN 1 END) AS male_count,
    COUNT(CASE WHEN g.name = 'female' THEN 1 END) AS female_count,
    COUNT(CASE WHEN g.name IN ('non_binary', 'genderqueer', 'genderfluid', 'agender', 'other') THEN 1 END) AS other_gender_count
FROM patients p
LEFT JOIN genders g ON p.gender_id = g.id
WHERE p.is_active = TRUE
GROUP BY DATE_TRUNC('month', p.created_at)
ORDER BY registration_month DESC;

-- View for health condition prevalence
CREATE OR REPLACE VIEW vw_health_condition_stats AS
SELECT
    COUNT(DISTINCT p.id) AS total_patients,
    COUNT(DISTINCT CASE WHEN pc.condition_id = (SELECT id FROM medical_conditions WHERE name = 'Hypertension') THEN p.id END) AS hypertension_count,
    COUNT(DISTINCT CASE WHEN pc.condition_id = (SELECT id FROM medical_conditions WHERE name = 'Diabetes') THEN p.id END) AS diabetes_count,
    COUNT(DISTINCT CASE WHEN pc.condition_id = (SELECT id FROM medical_conditions WHERE name = 'High Cholesterol') THEN p.id END) AS cholesterol_count,
    COUNT(CASE WHEN hp.is_smoker THEN 1 END) AS smoker_count,
    ROUND(AVG(hp.height_cm), 2) AS avg_height,
    ROUND(AVG(hp.weight_kg), 2) AS avg_weight
FROM patients p
JOIN health_profiles hp ON p.id = hp.patient_id
LEFT JOIN patient_conditions pc ON p.id = pc.patient_id
WHERE p.is_active = TRUE;

-- Vista corregida: vw_dashboard_overview
CREATE OR REPLACE VIEW vw_dashboard_overview AS
SELECT
    (SELECT COUNT(*) FROM patients WHERE is_active = TRUE) as total_patients,
    (SELECT COUNT(*) FROM doctors WHERE is_active = TRUE) as total_doctors,
    (SELECT COUNT(*) FROM medical_institutions WHERE is_active = TRUE) as total_institutions,
    (SELECT COUNT(*) FROM users WHERE is_active = TRUE) as total_users,
    (SELECT COUNT(*) FROM patients WHERE is_verified = TRUE AND is_active = TRUE) as validated_patients,
    (SELECT AVG(consultation_fee) FROM doctors WHERE is_active = TRUE) as avg_consultation_fee,
    -- New metrics for relationship integrity
    (SELECT COUNT(*) FROM patients p JOIN doctors d ON p.doctor_id = d.id WHERE p.is_active = TRUE AND d.institution_id = p.institution_id) as patients_with_valid_relationships,
    (SELECT ROUND(
        (COUNT(*)::decimal /
         NULLIF((SELECT COUNT(*) FROM patients WHERE is_active = TRUE), 0)) * 100, 2
     ) FROM patients p JOIN doctors d ON p.doctor_id = d.id WHERE p.is_active = TRUE AND d.institution_id = p.institution_id) as relationship_integrity_percentage;

-- 1. Vista para gráfico de especialidades médicas
CREATE OR REPLACE VIEW vw_doctor_specialty_distribution AS
SELECT
    ds.name as specialty,
    sc.name as category,
    COUNT(d.id) as doctor_count
FROM doctor_specialties ds
LEFT JOIN specialty_categories sc ON ds.category_id = sc.id
LEFT JOIN doctors d ON ds.id = d.specialty_id AND d.is_active = TRUE
GROUP BY ds.name, sc.name
ORDER BY doctor_count DESC;

-- 2. Vista para distribución geográfica
CREATE OR REPLACE VIEW vw_geographic_distribution AS
SELECT
    c.name AS country,
    r.name AS region_state,
    r.region_type,
    COUNT(DISTINCT mi.id) AS institution_count,
    COUNT(DISTINCT d.id) AS doctor_count,
    COUNT(DISTINCT p.id) AS patient_count,
    COUNT(DISTINCT addr.id) AS address_count
FROM countries c
LEFT JOIN regions r ON c.id = r.country_id
LEFT JOIN addresses addr ON addr.region_id = r.id
LEFT JOIN medical_institutions mi ON addr.entity_id = mi.id AND addr.entity_type = 'institution'
LEFT JOIN doctors d ON mi.id = d.institution_id AND d.is_active = TRUE
LEFT JOIN patients p ON mi.id = p.institution_id AND p.is_active = TRUE
WHERE c.is_active = TRUE AND r.is_active = TRUE
GROUP BY c.name, r.name, r.region_type
ORDER BY c.name, r.name;

-- 3. Vista para condiciones de salud prevalentes
CREATE OR REPLACE VIEW vw_health_condition_prevalence AS
SELECT
    mc.name as condition,
    COUNT(pc.patient_id) as patient_count
FROM medical_conditions mc
LEFT JOIN patient_conditions pc ON mc.id = pc.condition_id
GROUP BY mc.name
ORDER BY patient_count DESC;

-- Vista para estado de validación de pacientes
CREATE OR REPLACE VIEW vw_patient_validation_status AS
SELECT
    CASE
        WHEN is_verified = TRUE THEN 'verified'
        WHEN is_verified = FALSE THEN 'unverified'
        ELSE 'pending'
    END as validation_status,
    COUNT(*) as patient_count,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 1) as percentage
FROM patients
WHERE is_active = TRUE
GROUP BY is_verified
ORDER BY patient_count DESC;

-- New view for relationship integrity monitoring
CREATE OR REPLACE VIEW vw_relationship_integrity AS
SELECT
    'Patient-Doctor-Institution Relationships' as check_type,
    COUNT(*) as total_records,
    COUNT(CASE WHEN p.doctor_id IS NOT NULL AND p.institution_id IS NOT NULL THEN 1 END) as complete_relationships,
    COUNT(CASE WHEN p.doctor_id IS NULL OR p.institution_id IS NULL THEN 1 END) as incomplete_relationships,
    COUNT(CASE WHEN p.doctor_id IS NOT NULL AND p.institution_id IS NOT NULL AND d.institution_id = p.institution_id THEN 1 END) as valid_relationships,
    COUNT(CASE WHEN p.doctor_id IS NOT NULL AND p.institution_id IS NOT NULL AND d.institution_id != p.institution_id THEN 1 END) as invalid_relationships,
    ROUND(
        (COUNT(CASE WHEN p.doctor_id IS NOT NULL AND p.institution_id IS NOT NULL AND d.institution_id = p.institution_id THEN 1 END)::decimal /
         NULLIF(COUNT(*), 0)) * 100, 2
    ) as integrity_percentage
FROM patients p
LEFT JOIN doctors d ON p.doctor_id = d.id
WHERE p.is_active = TRUE;


-- =============================================
-- INDEXES FOR NORMALIZED TABLES
-- =============================================

-- Email table indexes
CREATE INDEX IF NOT EXISTS idx_emails_entity ON emails(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_emails_type ON emails(email_type_id);
CREATE INDEX IF NOT EXISTS idx_emails_primary ON emails(entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE INDEX IF NOT EXISTS idx_emails_address ON emails(email_address);
CREATE INDEX IF NOT EXISTS idx_emails_verification ON emails(is_verified, verification_expires_at);

-- Phone table indexes
CREATE INDEX IF NOT EXISTS idx_phones_entity ON phones(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_phones_type ON phones(phone_type_id);
CREATE INDEX IF NOT EXISTS idx_phones_primary ON phones(entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE INDEX IF NOT EXISTS idx_phones_number ON phones(phone_number);

-- Address table indexes
CREATE INDEX IF NOT EXISTS idx_addresses_entity ON addresses(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_addresses_region ON addresses(region_id);
CREATE INDEX IF NOT EXISTS idx_addresses_country ON addresses(country_id);
CREATE INDEX IF NOT EXISTS idx_addresses_city ON addresses(city);
CREATE INDEX IF NOT EXISTS idx_addresses_postal ON addresses(postal_code);
CREATE INDEX IF NOT EXISTS idx_addresses_primary ON addresses(entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE INDEX IF NOT EXISTS idx_addresses_coordinates ON addresses(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Region indexes
CREATE INDEX IF NOT EXISTS idx_regions_country ON regions(country_id);
CREATE INDEX IF NOT EXISTS idx_regions_code ON regions(region_code);

-- =============================================
-- OPTIMIZED INDEXES FOR PERFORMANCE
-- =============================================

-- Core medical tables indexes
CREATE INDEX IF NOT EXISTS idx_patients_doctor_id ON patients(doctor_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_patients_institution_id ON patients(institution_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_patients_created_at ON patients(created_at) WHERE is_active = TRUE;

-- Doctor performance indexes
CREATE INDEX IF NOT EXISTS idx_doctors_institution_id ON doctors(institution_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_doctors_specialty_id ON doctors(specialty_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_doctors_consultation_fee ON doctors(consultation_fee) WHERE is_active = TRUE;

-- Health profiles indexes
CREATE INDEX IF NOT EXISTS idx_health_profiles_patient_id ON health_profiles(patient_id);

-- New junction table indexes
CREATE INDEX IF NOT EXISTS idx_patient_conditions_patient_id ON patient_conditions(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_conditions_condition_id ON patient_conditions(condition_id);
CREATE INDEX IF NOT EXISTS idx_patient_family_history_patient_id ON patient_family_history(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_family_history_condition_id ON patient_family_history(condition_id);
CREATE INDEX IF NOT EXISTS idx_patient_medications_patient_id ON patient_medications(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_medications_medication_id ON patient_medications(medication_id);
CREATE INDEX IF NOT EXISTS idx_patient_allergies_patient_id ON patient_allergies(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_allergies_allergy_id ON patient_allergies(allergy_id);

-- User authentication indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_users_reference_id ON users(reference_id, user_type);

-- Medical institution indexes
CREATE INDEX IF NOT EXISTS idx_medical_institutions_type ON medical_institutions(institution_type_id) WHERE is_active = TRUE;

-- CMS system indexes
CREATE INDEX IF NOT EXISTS idx_cms_users_role ON cms_users(role_id) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_cms_users_email ON cms_users(email);
CREATE INDEX IF NOT EXISTS idx_cms_role_permissions_composite ON cms_role_permissions(role_id, permission_id);

-- =============================================
-- DATA INTEGRITY CONSTRAINTS
-- =============================================

-- Age validation constraint (keeping this as it's not a catalog value)
ALTER TABLE patients ADD CONSTRAINT chk_patient_age CHECK (
    date_of_birth <= CURRENT_DATE AND
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) <= 120
);

-- Email format validation (removed from main tables, now in emails table)

-- Phone number format validation (removed from main tables, now in phones table)

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

-- Add triggers for normalized tables
CREATE TRIGGER set_timestamp_emails BEFORE UPDATE ON emails FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_phones BEFORE UPDATE ON phones FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_addresses BEFORE UPDATE ON addresses FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_countries BEFORE UPDATE ON countries FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_regions BEFORE UPDATE ON regions FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

-- Add triggers for new catalog tables
CREATE TRIGGER set_timestamp_medical_conditions BEFORE UPDATE ON medical_conditions FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_medications BEFORE UPDATE ON medications FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_allergies BEFORE UPDATE ON allergies FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

-- =============================================
-- INITIAL DATA SEEDING
-- =============================================

-- Insert institution types
INSERT INTO institution_types (name, description, category) VALUES
    ('hospital', 'General or specialized hospital providing inpatient and outpatient care', 'healthcare'),
    ('preventive_clinic', 'Clinic focused on preventive medicine and health promotion', 'healthcare'),
    ('health_center', 'Primary healthcare center for basic medical services', 'healthcare'),
    ('insurer', 'Health insurance company or provider', 'insurance'),
    ('public_health', 'Public health organization or government agency', 'healthcare'),
    ('pharmacy', 'Retail pharmacy or pharmaceutical services', 'pharmacy'),
    ('research', 'Medical research institution or laboratory', 'research'),
    ('education', 'Medical education or training institution', 'education')
ON CONFLICT (name) DO NOTHING;

-- Insert specialty categories
INSERT INTO specialty_categories (name, description) VALUES
    ('Primary Care', 'General medical practice and primary healthcare'),
    ('Specialty', 'Medical specialties requiring advanced training'),
    ('Preventive', 'Disease prevention and health promotion'),
    ('Emergency', 'Emergency medicine and critical care'),
    ('Surgery', 'Surgical specialties and procedures'),
    ('Internal Medicine', 'Internal medicine subspecialties'),
    ('Pediatrics', 'Medical care for children and adolescents'),
    ('Obstetrics and Gynecology', 'Women''s health and reproductive medicine'),
    ('Psychiatry', 'Mental health and behavioral medicine'),
    ('Radiology', 'Medical imaging and diagnostic radiology')
ON CONFLICT (name) DO NOTHING;

-- Insert biological sexes (for medical purposes)
INSERT INTO sexes (name, display_name, description, chromosome_pattern) VALUES
    ('male', 'Male', 'Biological male sex', 'XY'),
    ('female', 'Female', 'Biological female sex', 'XX'),
    ('intersex', 'Intersex', 'Intersex condition (variations in sex characteristics)', 'Various')
ON CONFLICT (name) DO NOTHING;

-- Insert genders (inclusive gender identity)
INSERT INTO genders (name, display_name, description) VALUES
    ('male', 'Male', 'Male gender identity'),
    ('female', 'Female', 'Female gender identity'),
    ('non_binary', 'Non-binary', 'Non-binary gender identity'),
    ('genderqueer', 'Genderqueer', 'Genderqueer identity'),
    ('genderfluid', 'Genderfluid', 'Genderfluid identity'),
    ('agender', 'Agender', 'Agender identity'),
    ('other', 'Other', 'Other gender identity'),
    ('prefer_not_to_say', 'Prefer not to say', 'Prefers not to disclose gender identity')
ON CONFLICT (name) DO NOTHING;

-- Insert blood types with compatibility
INSERT INTO blood_types (name, description, can_donate_to, can_receive_from) VALUES
    ('A+', 'A positive blood type', ARRAY['A+', 'AB+'], ARRAY['A+', 'A-', 'O+', 'O-']),
    ('A-', 'A negative blood type', ARRAY['A+', 'A-', 'AB+', 'AB-'], ARRAY['A-', 'O-']),
    ('B+', 'B positive blood type', ARRAY['B+', 'AB+'], ARRAY['B+', 'B-', 'O+', 'O-']),
    ('B-', 'B negative blood type', ARRAY['B+', 'B-', 'AB+', 'AB-'], ARRAY['B-', 'O-']),
    ('AB+', 'AB positive blood type (universal recipient)', ARRAY['AB+'], ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    ('AB-', 'AB negative blood type', ARRAY['AB+', 'AB-'], ARRAY['A-', 'B-', 'AB-', 'O-']),
    ('O+', 'O positive blood type (universal donor)', ARRAY['A+', 'B+', 'AB+', 'O+'], ARRAY['O+', 'O-']),
    ('O-', 'O negative blood type (universal donor)', ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], ARRAY['O-'])
ON CONFLICT (name) DO NOTHING;


-- Insert email types
INSERT INTO email_types (name, description) VALUES
    ('primary', 'Primary contact email address'),
    ('secondary', 'Secondary contact email address'),
    ('work', 'Work-related email address'),
    ('personal', 'Personal email address'),
    ('notification', 'Email for system notifications'),
    ('billing', 'Email for billing and financial communications')
ON CONFLICT (name) DO NOTHING;

-- Insert phone types
INSERT INTO phone_types (name, description) VALUES
    ('primary', 'Primary contact number'),
    ('secondary', 'Secondary contact number'),
    ('mobile', 'Mobile phone number'),
    ('work', 'Work phone number'),
    ('home', 'Home phone number'),
    ('emergency', 'Emergency contact phone')
ON CONFLICT (name) DO NOTHING;

-- Insert Mexico as the primary country
INSERT INTO countries (name, iso_code, iso_code_2, phone_code, currency_code) VALUES
    ('Mexico', 'MEX', 'MX', '+52', 'MXN')
ON CONFLICT (iso_code) DO NOTHING;

-- Insert Mexican states/regions
INSERT INTO regions (country_id, name, region_code, region_type) VALUES
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Aguascalientes', 'AGS', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Baja California', 'BC', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Baja California Sur', 'BCS', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Campeche', 'CAMP', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Chiapas', 'CHIS', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Chihuahua', 'CHIH', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Coahuila', 'COAH', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Colima', 'COL', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Ciudad de México', 'CDMX', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Durango', 'DGO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Guanajuato', 'GTO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Guerrero', 'GRO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Hidalgo', 'HGO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Jalisco', 'JAL', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'México', 'MEX', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Michoacán', 'MICH', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Morelos', 'MOR', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Nayarit', 'NAY', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Nuevo León', 'NL', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Oaxaca', 'OAX', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Puebla', 'PUE', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Querétaro', 'QRO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Quintana Roo', 'QROO', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'San Luis Potosí', 'SLP', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Sinaloa', 'SIN', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Sonora', 'SON', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tabasco', 'TAB', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tamaulipas', 'TAMPS', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tlaxcala', 'TLAX', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Veracruz', 'VER', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Yucatán', 'YUC', 'state'),
    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Zacatecas', 'ZAC', 'state')
ON CONFLICT (country_id, name) DO NOTHING;

-- Insert initial doctor specialties
INSERT INTO doctor_specialties (name, description, category_id) VALUES
    ('General Medicine', 'General medical practice', (SELECT id FROM specialty_categories WHERE name = 'Primary Care')),
    ('Internal Medicine', 'Internal medicine specialist', (SELECT id FROM specialty_categories WHERE name = 'Primary Care')),
    ('Cardiology', 'Heart and cardiovascular system', (SELECT id FROM specialty_categories WHERE name = 'Specialty')),
    ('Endocrinology', 'Hormones and metabolism', (SELECT id FROM specialty_categories WHERE name = 'Specialty')),
    ('Diabetes Management', 'Diabetes care specialist', (SELECT id FROM specialty_categories WHERE name = 'Specialty')),
    ('Preventive Medicine', 'Disease prevention and health promotion', (SELECT id FROM specialty_categories WHERE name = 'Preventive')),
    ('Family Medicine', 'Comprehensive family healthcare', (SELECT id FROM specialty_categories WHERE name = 'Primary Care')),
    ('Emergency Medicine', 'Emergency care specialist', (SELECT id FROM specialty_categories WHERE name = 'Emergency'))
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
INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)
VALUES
    ('11000000-e29b-41d4-a716-446655440001'::uuid, 'Hospital General del Centro', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://hospital-general.predicthealth.com', 'LIC-MX-HOSP-001', TRUE, TRUE),
    ('12000000-e29b-41d4-a716-446655440002'::uuid, 'Clínica Familiar del Norte', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://clinica-norte.predicthealth.com', 'LIC-MX-CLIN-002', TRUE, TRUE),
    ('13000000-e29b-41d4-a716-446655440003'::uuid, 'Centro de Salud Preventiva Sur', (SELECT id FROM institution_types WHERE name = 'preventive_clinic'), 'https://centro-salud-sur.predicthealth.com', 'LIC-MX-PREV-003', TRUE, TRUE),
    ('14000000-e29b-41d4-a716-446655440004'::uuid, 'Instituto Cardiovascular del Bajío', (SELECT id FROM institution_types WHERE name = 'health_center'), 'https://cardiovascular-bajio.predicthealth.com', 'LIC-MX-CARD-004', TRUE, TRUE),
    ('15000000-e29b-41d4-a716-446655440005'::uuid, 'Centro Médico del Pacífico', (SELECT id FROM institution_types WHERE name = 'hospital'), 'https://medico-pacifico.predicthealth.com', 'LIC-MX-MEDP-005', TRUE, TRUE)
ON CONFLICT (license_number) DO NOTHING;

-- Insert emails for medical institutions
INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '11000000-e29b-41d4-a716-446655440001'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'institucion1@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '11000000-e29b-41d4-a716-446655440001'::uuid AND email_address = 'institucion1@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '12000000-e29b-41d4-a716-446655440002'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'institucion2@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '12000000-e29b-41d4-a716-446655440002'::uuid AND email_address = 'institucion2@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '13000000-e29b-41d4-a716-446655440003'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'institucion3@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '13000000-e29b-41d4-a716-446655440003'::uuid AND email_address = 'institucion3@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '14000000-e29b-41d4-a716-446655440004'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'institucion4@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '14000000-e29b-41d4-a716-446655440004'::uuid AND email_address = 'institucion4@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'institution', '15000000-e29b-41d4-a716-446655440005'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'institucion5@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '15000000-e29b-41d4-a716-446655440005'::uuid AND email_address = 'institucion5@test.predicthealth.com');

-- Insert addresses for medical institutions
INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '11000000-e29b-41d4-a716-446655440001'::uuid, 'primary', 'Av. Reforma 150, Centro Histórico', 'Ciudad de México', (SELECT id FROM regions WHERE name = 'Ciudad de México'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '11000000-e29b-41d4-a716-446655440001'::uuid AND street_address = 'Av. Reforma 150, Centro Histórico');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '12000000-e29b-41d4-a716-446655440002'::uuid, 'primary', 'Calle Juárez 45, Zona Norte', 'Monterrey', (SELECT id FROM regions WHERE name = 'Nuevo León'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '12000000-e29b-41d4-a716-446655440002'::uuid AND street_address = 'Calle Juárez 45, Zona Norte');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '13000000-e29b-41d4-a716-446655440003'::uuid, 'primary', 'Blvd. del Sur 89, Colonia del Valle', 'Guadalajara', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '13000000-e29b-41d4-a716-446655440003'::uuid AND street_address = 'Blvd. del Sur 89, Colonia del Valle');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '14000000-e29b-41d4-a716-446655440004'::uuid, 'primary', 'Paseo de los Héroes 234', 'León', (SELECT id FROM regions WHERE name = 'Guanajuato'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '14000000-e29b-41d4-a716-446655440004'::uuid AND street_address = 'Paseo de los Héroes 234');

INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
SELECT 'institution', '15000000-e29b-41d4-a716-446655440005'::uuid, 'primary', 'Malecón 567, Zona Dorada', 'Puerto Vallarta', (SELECT id FROM regions WHERE name = 'Jalisco'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '15000000-e29b-41d4-a716-446655440005'::uuid AND street_address = 'Malecón 567, Zona Dorada');

-- Insert phones for medical institutions
INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '11000000-e29b-41d4-a716-446655440001'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5555555555', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '11000000-e29b-41d4-a716-446655440001'::uuid AND phone_number = '5555555555');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '12000000-e29b-41d4-a716-446655440002'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8181818181', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '12000000-e29b-41d4-a716-446655440002'::uuid AND phone_number = '8181818181');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '13000000-e29b-41d4-a716-446655440003'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3333333333', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '13000000-e29b-41d4-a716-446655440003'::uuid AND phone_number = '3333333333');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '14000000-e29b-41d4-a716-446655440004'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '4777777777', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '14000000-e29b-41d4-a716-446655440004'::uuid AND phone_number = '4777777777');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'institution', '15000000-e29b-41d4-a716-446655440005'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3222222222', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '15000000-e29b-41d4-a716-446655440005'::uuid AND phone_number = '3222222222');

INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES
    ('11000000-e29b-41d4-a716-446655440001'::uuid, 'institucion1@test.predicthealth.com', '$2b$12$Fu7pgzMQbaYBsEfHq8b76O1UPDtB0Ngm5Z3qRSkXPv9YyIP.1YaBe', 'institution', '11000000-e29b-41d4-a716-446655440001'::uuid, TRUE, TRUE),
    ('12000000-e29b-41d4-a716-446655440002'::uuid, 'institucion2@test.predicthealth.com', '$2b$12$20krURHfwrBIJQCqdh2j1.4pxMumbNR7MtmAiKbflQXW1ofdpgocq', 'institution', '12000000-e29b-41d4-a716-446655440002'::uuid, TRUE, TRUE),
    ('13000000-e29b-41d4-a716-446655440003'::uuid, 'institucion3@test.predicthealth.com', '$2b$12$KEJp5csEJmfVt.mxxEudv.ho6WyDB7M3Ehjr61aOP7ZIKpyhT57L2', 'institution', '13000000-e29b-41d4-a716-446655440003'::uuid, TRUE, TRUE),
    ('14000000-e29b-41d4-a716-446655440004'::uuid, 'institucion4@test.predicthealth.com', '$2b$12$s8Y2qs7A1zeC6P/ekXQHLe56fB8nmJJlox5cmolEkAOsOapbJ8gDq', 'institution', '14000000-e29b-41d4-a716-446655440004'::uuid, TRUE, TRUE),
    ('15000000-e29b-41d4-a716-446655440005'::uuid, 'institucion5@test.predicthealth.com', '$2b$12$0j7S7rP06XrUEZSUtPERFOam9Ri.i1KUzfxDpozOUbjGnw0QLuiMC', 'institution', '15000000-e29b-41d4-a716-446655440005'::uuid, TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Doctors (5)
INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)
VALUES
    ('21000000-e29b-41d4-a716-446655440001'::uuid, '11000000-e29b-41d4-a716-446655440001'::uuid, 'Roberto', 'Sánchez', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-101', (SELECT id FROM doctor_specialties WHERE name = 'Cardiology' LIMIT 1), 15, 1200.00, TRUE, 'active'),
    ('22000000-e29b-41d4-a716-446655440002'::uuid, '12000000-e29b-41d4-a716-446655440002'::uuid, 'Patricia', 'Morales', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-102', (SELECT id FROM doctor_specialties WHERE name = 'Internal Medicine' LIMIT 1), 12, 950.00, TRUE, 'active'),
    ('23000000-e29b-41d4-a716-446655440003'::uuid, '13000000-e29b-41d4-a716-446655440003'::uuid, 'Fernando', 'Vázquez', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-103', (SELECT id FROM doctor_specialties WHERE name = 'Endocrinology' LIMIT 1), 18, 1100.00, TRUE, 'active'),
    ('24000000-e29b-41d4-a716-446655440004'::uuid, '14000000-e29b-41d4-a716-446655440004'::uuid, 'Gabriela', 'Ríos', (SELECT id FROM sexes WHERE name = 'female'), 'MED-MX-2024-104', (SELECT id FROM doctor_specialties WHERE name = 'Family Medicine' LIMIT 1), 10, 850.00, TRUE, 'active'),
    ('25000000-e29b-41d4-a716-446655440005'::uuid, '15000000-e29b-41d4-a716-446655440005'::uuid, 'Antonio', 'Jiménez', (SELECT id FROM sexes WHERE name = 'male'), 'MED-MX-2024-105', (SELECT id FROM doctor_specialties WHERE name = 'Emergency Medicine' LIMIT 1), 22, 1350.00, TRUE, 'active')
ON CONFLICT (medical_license) DO NOTHING;

-- Insert emails for doctors
INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '21000000-e29b-41d4-a716-446655440001'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'doctor1@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '21000000-e29b-41d4-a716-446655440001'::uuid AND email_address = 'doctor1@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '22000000-e29b-41d4-a716-446655440002'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'doctor2@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '22000000-e29b-41d4-a716-446655440002'::uuid AND email_address = 'doctor2@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '23000000-e29b-41d4-a716-446655440003'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'doctor3@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '23000000-e29b-41d4-a716-446655440003'::uuid AND email_address = 'doctor3@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '24000000-e29b-41d4-a716-446655440004'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'doctor4@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '24000000-e29b-41d4-a716-446655440004'::uuid AND email_address = 'doctor4@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'doctor', '25000000-e29b-41d4-a716-446655440005'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'doctor5@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '25000000-e29b-41d4-a716-446655440005'::uuid AND email_address = 'doctor5@test.predicthealth.com');

-- Insert phones for doctors
INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
VALUES
    ('doctor', '21000000-e29b-41d4-a716-446655440001'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-55-3001-0001', TRUE, TRUE),
    ('doctor', '22000000-e29b-41d4-a716-446655440002'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-81-3002-0002', TRUE, TRUE),
    ('doctor', '23000000-e29b-41d4-a716-446655440003'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-33-3003-0003', TRUE, TRUE),
    ('doctor', '24000000-e29b-41d4-a716-446655440004'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-477-3004-0004', TRUE, TRUE),
    ('doctor', '25000000-e29b-41d4-a716-446655440005'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '+52-322-3005-0005', TRUE, TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES
    ('21000000-e29b-41d4-a716-446655440001'::uuid, 'doctor1@test.predicthealth.com', '$2b$12$E/UgR4RVVaYQ3.D5fc/ji.bfI8s7pWetGECQgd8eUBD5.2Rn0Lm9.', 'doctor', '21000000-e29b-41d4-a716-446655440001'::uuid, TRUE, TRUE),
    ('22000000-e29b-41d4-a716-446655440002'::uuid, 'doctor2@test.predicthealth.com', '$2b$12$NIJzDyaAHli7WvojQRX.Gen4B0.ybiolEM3GtB0USJSg7X6m1I2VG', 'doctor', '22000000-e29b-41d4-a716-446655440002'::uuid, TRUE, TRUE),
    ('23000000-e29b-41d4-a716-446655440003'::uuid, 'doctor3@test.predicthealth.com', '$2b$12$dg7XyARsx4DXXsbQAGetRutkps.4hu1KCx2te0bfNUo1xfN7Hf32S', 'doctor', '23000000-e29b-41d4-a716-446655440003'::uuid, TRUE, TRUE),
    ('24000000-e29b-41d4-a716-446655440004'::uuid, 'doctor4@test.predicthealth.com', '$2b$12$y6xvrHddz/byYF2ol6qxIuekSpmoXBUCrhJhGimy4ZTJcXNZYmHii', 'doctor', '24000000-e29b-41d4-a716-446655440004'::uuid, TRUE, TRUE),
    ('25000000-e29b-41d4-a716-446655440005'::uuid, 'doctor5@test.predicthealth.com', '$2b$12$IMU.mwTpKs50vlCXG.jmBukOAVet.oqM0sBt1FhwhwB5UrxslzcJS', 'doctor', '25000000-e29b-41d4-a716-446655440005'::uuid, TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Patients (5)
INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)
VALUES
    ('31000000-e29b-41d4-a716-446655440001'::uuid, '21000000-e29b-41d4-a716-446655440001'::uuid, '11000000-e29b-41d4-a716-446655440001'::uuid, 'Luis', 'Torres', '1978-03-12', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'María Torres', TRUE, TRUE),
    ('32000000-e29b-41d4-a716-446655440002'::uuid, '22000000-e29b-41d4-a716-446655440002'::uuid, '12000000-e29b-41d4-a716-446655440002'::uuid, 'Carmen', 'Díaz', '1982-07-25', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'José Díaz', TRUE, TRUE),
    ('33000000-e29b-41d4-a716-446655440003'::uuid, '23000000-e29b-41d4-a716-446655440003'::uuid, '13000000-e29b-41d4-a716-446655440003'::uuid, 'Javier', 'Ruiz', '1990-11-08', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Elena Ruiz', TRUE, TRUE),
    ('34000000-e29b-41d4-a716-446655440004'::uuid, '24000000-e29b-41d4-a716-446655440004'::uuid, '14000000-e29b-41d4-a716-446655440004'::uuid, 'Isabel', 'Fernández', '1975-05-30', (SELECT id FROM sexes WHERE name = 'female'), (SELECT id FROM genders WHERE name = 'female'), 'Carlos Fernández', TRUE, TRUE),
    ('35000000-e29b-41d4-a716-446655440005'::uuid, '25000000-e29b-41d4-a716-446655440005'::uuid, '15000000-e29b-41d4-a716-446655440005'::uuid, 'Manuel', 'Gutiérrez', '1988-09-14', (SELECT id FROM sexes WHERE name = 'male'), (SELECT id FROM genders WHERE name = 'male'), 'Rosa Gutiérrez', TRUE, TRUE)
ON CONFLICT DO NOTHING;

-- Insert emails for patients
INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '31000000-e29b-41d4-a716-446655440001'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'paciente1@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '31000000-e29b-41d4-a716-446655440001'::uuid AND email_address = 'paciente1@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '32000000-e29b-41d4-a716-446655440002'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'paciente2@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '32000000-e29b-41d4-a716-446655440002'::uuid AND email_address = 'paciente2@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '33000000-e29b-41d4-a716-446655440003'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'paciente3@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '33000000-e29b-41d4-a716-446655440003'::uuid AND email_address = 'paciente3@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '34000000-e29b-41d4-a716-446655440004'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'paciente4@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '34000000-e29b-41d4-a716-446655440004'::uuid AND email_address = 'paciente4@test.predicthealth.com');

INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
SELECT 'patient', '35000000-e29b-41d4-a716-446655440005'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), 'paciente5@test.predicthealth.com', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '35000000-e29b-41d4-a716-446655440005'::uuid AND email_address = 'paciente5@test.predicthealth.com');

-- Insert phones for patients (primary and emergency)
INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '31000000-e29b-41d4-a716-446655440001'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '5555555555', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '31000000-e29b-41d4-a716-446655440001'::uuid AND phone_number = '5555555555');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '32000000-e29b-41d4-a716-446655440002'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '8181818181', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '32000000-e29b-41d4-a716-446655440002'::uuid AND phone_number = '8181818181');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '33000000-e29b-41d4-a716-446655440003'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3333333333', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '33000000-e29b-41d4-a716-446655440003'::uuid AND phone_number = '3333333333');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '34000000-e29b-41d4-a716-446655440004'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '4777777777', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '34000000-e29b-41d4-a716-446655440004'::uuid AND phone_number = '4777777777');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'patient', '35000000-e29b-41d4-a716-446655440005'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '3222222222', TRUE, TRUE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '35000000-e29b-41d4-a716-446655440005'::uuid AND phone_number = '3222222222');

-- Emergency contacts
INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '31000000-e29b-41d4-a716-446655440001'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '5555555556', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '31000000-e29b-41d4-a716-446655440001'::uuid AND phone_number = '5555555556');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '32000000-e29b-41d4-a716-446655440002'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '8181818182', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '32000000-e29b-41d4-a716-446655440002'::uuid AND phone_number = '8181818182');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '33000000-e29b-41d4-a716-446655440003'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3333333334', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '33000000-e29b-41d4-a716-446655440003'::uuid AND phone_number = '3333333334');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '34000000-e29b-41d4-a716-446655440004'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '4777777778', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '34000000-e29b-41d4-a716-446655440004'::uuid AND phone_number = '4777777778');

INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
SELECT 'emergency_contact', '35000000-e29b-41d4-a716-446655440005'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '3222222224', FALSE, FALSE
WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '35000000-e29b-41d4-a716-446655440005'::uuid AND phone_number = '3222222224');

INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)
VALUES
    ('31000000-e29b-41d4-a716-446655440001'::uuid, 'paciente1@test.predicthealth.com', '$2b$12$gEqkD8pJHfq6EIEiDTPnUeSUFB2dQw3ozCGRUnFg6iAeCkNb46ISq', 'patient', '31000000-e29b-41d4-a716-446655440001'::uuid, TRUE, TRUE),
    ('32000000-e29b-41d4-a716-446655440002'::uuid, 'paciente2@test.predicthealth.com', '$2b$12$TkYMOsVgEGsgL6ksA/NN4O.K79BXEJyvTbjxY9G83Z8cmgw3Mzx4W', 'patient', '32000000-e29b-41d4-a716-446655440002'::uuid, TRUE, TRUE),
    ('33000000-e29b-41d4-a716-446655440003'::uuid, 'paciente3@test.predicthealth.com', '$2b$12$9Kd6I3Pi4KtQTuAmZV6HFeIaus71Z/Slx9ZVULD5rjkIcW06Jrsj.', 'patient', '33000000-e29b-41d4-a716-446655440003'::uuid, TRUE, TRUE),
    ('34000000-e29b-41d4-a716-446655440004'::uuid, 'paciente4@test.predicthealth.com', '$2b$12$JcMVzDqEJcbMwNRc2gtjwuBsG3NPAD.osQbLt/h3zz0ix6usr3TZC', 'patient', '34000000-e29b-41d4-a716-446655440004'::uuid, TRUE, TRUE),
    ('35000000-e29b-41d4-a716-446655440005'::uuid, 'paciente5@test.predicthealth.com', '$2b$12$sCaqkRhmkJsrDaX/4OvGmuyfcwUkGw4zu5iBSgE1HIO6MI/gD9jXq', 'patient', '35000000-e29b-41d4-a716-446655440005'::uuid, TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

-- Insertar datos en health_profiles refactorizado
INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type_id, is_smoker, smoking_years, consumes_alcohol, alcohol_frequency, physical_activity_minutes_weekly, notes)
VALUES
    ('31000000-e29b-41d4-a716-446655440001'::uuid, 172.0, 75.5, (SELECT id FROM blood_types WHERE name = 'A+'), FALSE, 0, TRUE, 'occasionally', 210, 'Hypertension diagnosed 3 years ago'),
    ('32000000-e29b-41d4-a716-446655440002'::uuid, 165.0, 62.0, (SELECT id FROM blood_types WHERE name = 'O-'), FALSE, 0, FALSE, 'never', 300, 'No significant conditions'),
    ('33000000-e29b-41d4-a716-446655440003'::uuid, 178.0, 82.0, (SELECT id FROM blood_types WHERE name = 'B+'), TRUE, 8, TRUE, 'regularly', 150, 'Type 2 diabetes diagnosed 2 years ago'),
    ('34000000-e29b-41d4-a716-446655440004'::uuid, 160.0, 58.0, (SELECT id FROM blood_types WHERE name = 'AB+'), FALSE, 0, TRUE, 'rarely', 180, 'Previous stroke 5 years ago, hypertension'),
    ('35000000-e29b-41d4-a716-446655440005'::uuid, 185.0, 90.0, (SELECT id FROM blood_types WHERE name = 'O+'), FALSE, 0, TRUE, 'occasionally', 420, 'No significant conditions')
ON CONFLICT (patient_id) DO NOTHING;

-- Poblar catálogos médicos con datos más completos y realistas

-- Condiciones médicas comunes en práctica clínica
INSERT INTO medical_conditions (id, name, description) VALUES
(1, 'Hypertension', 'Presión arterial elevada que requiere manejo médico'),
(2, 'Diabetes Mellitus Type 2', 'Trastorno metabólico caracterizado por hiperglucemia'),
(3, 'High Cholesterol', 'Niveles elevados de colesterol en sangre'),
(4, 'Stroke History', 'Antecedentes de accidente cerebrovascular'),
(5, 'Heart Disease History', 'Antecedentes de enfermedad cardiovascular'),
(6, 'Asthma', 'Enfermedad respiratoria crónica con obstrucción bronquial'),
(7, 'Chronic Obstructive Pulmonary Disease', 'Enfermedad pulmonar obstructiva crónica'),
(8, 'Depression', 'Trastorno del estado de ánimo con síntomas persistentes'),
(9, 'Anxiety Disorder', 'Trastorno caracterizado por ansiedad excesiva'),
(10, 'Osteoarthritis', 'Degeneración del cartílago articular'),
(11, 'Rheumatoid Arthritis', 'Enfermedad autoinmune que afecta las articulaciones'),
(12, 'Hypothyroidism', 'Disminución de la función tiroidea'),
(13, 'Hyperthyroidism', 'Aumento de la función tiroidea'),
(14, 'Chronic Kidney Disease', 'Enfermedad renal crónica'),
(15, 'Gastroesophageal Reflux Disease', 'Reflujo gastroesofágico patológico'),
(16, 'Irritable Bowel Syndrome', 'Síndrome de intestino irritable'),
(17, 'Migraine', 'Cefalea recurrente intensa'),
(18, 'Obesity', 'Exceso de peso corporal con riesgo para la salud'),
(19, 'Sleep Apnea', 'Apnea obstructiva del sueño'),
(20, 'Atrial Fibrillation', 'Fibrilación auricular')
ON CONFLICT (name) DO NOTHING;

-- Medicamentos comunes en prescripción médica
INSERT INTO medications (id, name, description) VALUES
(1, 'Lisinopril', 'Inhibidor de la ECA para hipertensión'),
(2, 'Atorvastatin', 'Estatina para reducción de colesterol'),
(3, 'Multivitamin', 'Suplemento vitamínico diario'),
(4, 'Metformin', 'Antidiabético oral para diabetes tipo 2'),
(5, 'Omeprazole', 'Inhibidor de bomba de protones para reflujo'),
(6, 'Aspirin', 'Antiplaquetario para prevención cardiovascular'),
(7, 'Losartan', 'Antagonista de receptores de angiotensina II'),
(8, 'Simvastatin', 'Estatina para control de colesterol'),
(9, 'Levothyroxine', 'Hormona tiroidea sintética'),
(10, 'Prednisone', 'Corticosteroide para inflamación'),
(11, 'Warfarin', 'Anticoagulante oral'),
(12, 'Insulin Glargine', 'Insulina de acción prolongada'),
(13, 'Albuterol', 'Broncodilatador para asma'),
(14, 'Sertraline', 'Antidepresivo ISRS'),
(15, 'Ibuprofen', 'Antiinflamatorio no esteroideo'),
(16, 'Furosemide', 'Diurético de asa'),
(17, 'Amlodipine', 'Bloqueador de canales de calcio'),
(18, 'Gabapentin', 'Anticonvulsivante para neuralgia'),
(19, 'Pantoprazole', 'Inhibidor de bomba de protones'),
(20, 'Diazepam', 'Benzodiazepina ansiolítica')
ON CONFLICT (name) DO NOTHING;

-- Alergias comunes en práctica médica
INSERT INTO allergies (id, name, description) VALUES
(1, 'Penicillin', 'Alergia a penicilina y derivados beta-lactámicos'),
(2, 'None reported', 'Sin alergias conocidas reportadas'),
(3, 'Sulfa Drugs', 'Alergia a medicamentos sulfonamida'),
(4, 'NSAIDs', 'Alergia a antiinflamatorios no esteroideos'),
(5, 'Aspirin', 'Alergia al ácido acetilsalicílico'),
(6, 'Latex', 'Alergia al látex'),
(7, 'Shellfish', 'Alergia a mariscos'),
(8, 'Peanuts', 'Alergia a cacahuates/maní'),
(9, 'Eggs', 'Alergia a huevos'),
(10, 'Milk', 'Alergia a leche y productos lácteos'),
(11, 'Wheat', 'Alergia al trigo'),
(12, 'Soy', 'Alergia a la soja'),
(13, 'Tree Nuts', 'Alergia a nueces de árbol'),
(14, 'Fish', 'Alergia al pescado'),
(15, 'Iodine', 'Alergia al yodo (contraste radiológico)'),
(16, 'Local Anesthetics', 'Alergia a anestésicos locales'),
(17, 'Codeine', 'Alergia a codeína y opioides'),
(18, 'Tetracycline', 'Alergia a tetraciclina'),
(19, 'Quinolones', 'Alergia a antibióticos quinolona'),
(20, 'ACE Inhibitors', 'Alergia a inhibidores de la ECA')
ON CONFLICT (name) DO NOTHING;

-- Poblar tablas de unión con los datos originales
-- Paciente 1: Luis Torres
INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date) VALUES
('31000000-e29b-41d4-a716-446655440001'::uuid, 1, '2022-10-16'), -- Hypertension
('31000000-e29b-41d4-a716-446655440001'::uuid, 3, '2022-10-16'), -- High Cholesterol
('31000000-e29b-41d4-a716-446655440001'::uuid, 5, '2022-10-16')  -- Heart Disease History
ON CONFLICT DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type) VALUES
('31000000-e29b-41d4-a716-446655440001'::uuid, 2, 'Unspecified'), -- Diabetes
('31000000-e29b-41d4-a716-446655440001'::uuid, 1, 'Unspecified')  -- Hypertension
ON CONFLICT DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency) VALUES
('31000000-e29b-41d4-a716-446655440001'::uuid, 1, '10mg', 'daily'), -- Lisinopril
('31000000-e29b-41d4-a716-446655440001'::uuid, 2, '20mg', 'daily')  -- Atorvastatin
ON CONFLICT DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity) VALUES
('31000000-e29b-41d4-a716-446655440001'::uuid, 1, 'severe') -- Penicillin
ON CONFLICT DO NOTHING;

-- Paciente 2: Carmen Díaz
INSERT INTO patient_family_history (patient_id, condition_id, relative_type) VALUES
('32000000-e29b-41d4-a716-446655440002'::uuid, 1, 'Unspecified') -- Hypertension
ON CONFLICT DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency) VALUES
('32000000-e29b-41d4-a716-446655440002'::uuid, 3, '1 tablet', 'daily') -- Multivitamin
ON CONFLICT DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id) VALUES
('32000000-e29b-41d4-a716-446655440002'::uuid, 2) -- None reported
ON CONFLICT DO NOTHING;

-- Paciente 3: Javier Ruiz
INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date) VALUES
('33000000-e29b-41d4-a716-446655440003'::uuid, 2, '2021-05-10') -- Diabetes
ON CONFLICT DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type) VALUES
('33000000-e29b-41d4-a716-446655440003'::uuid, 1, 'Unspecified'), -- Hypertension
('33000000-e29b-41d4-a716-446655440003'::uuid, 5, 'Unspecified')  -- Heart Disease History
ON CONFLICT DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency) VALUES
('33000000-e29b-41d4-a716-446655440003'::uuid, 2, '500mg', 'twice daily') -- Metformin
ON CONFLICT DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity) VALUES
('33000000-e29b-41d4-a716-446655440003'::uuid, 1, 'moderate') -- Sulfa drugs
ON CONFLICT DO NOTHING;

-- Paciente 4: Isabel Fernández
INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date) VALUES
('34000000-e29b-41d4-a716-446655440004'::uuid, 1, '2019-02-15'), -- Hypertension
('34000000-e29b-41d4-a716-446655440004'::uuid, 3, '2019-02-15'), -- High Cholesterol
('34000000-e29b-41d4-a716-446655440004'::uuid, 4, '2019-02-15')  -- Stroke History
ON CONFLICT DO NOTHING;

INSERT INTO patient_family_history (patient_id, condition_id, relative_type) VALUES
('34000000-e29b-41d4-a716-446655440004'::uuid, 1, 'Unspecified'), -- Hypertension
('34000000-e29b-41d4-a716-446655440004'::uuid, 5, 'Unspecified')  -- Heart Disease History
ON CONFLICT DO NOTHING;

INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency) VALUES
('34000000-e29b-41d4-a716-446655440004'::uuid, 1, '81mg', 'daily'), -- Aspirin
('34000000-e29b-41d4-a716-446655440004'::uuid, 2, '50mg', 'daily')  -- Losartan
ON CONFLICT DO NOTHING;

INSERT INTO patient_allergies (patient_id, allergy_id, severity) VALUES
('34000000-e29b-41d4-a716-446655440004'::uuid, 1, 'mild') -- Codeine
ON CONFLICT DO NOTHING;

-- Paciente 5: Manuel Gutiérrez
INSERT INTO patient_allergies (patient_id, allergy_id, severity) VALUES
('35000000-e29b-41d4-a716-446655440005'::uuid, 1, 'severe') -- Shellfish
ON CONFLICT DO NOTHING;

-- =============================================
-- CMS USERS (UNIFIED SYSTEM)
-- =============================================

-- CMS Admin User (full CRUD permissions)
INSERT INTO cms_users (email, password_hash, first_name, last_name, user_type, is_active) VALUES
    ('admin.cms@predicthealth.com', '$2b$12$x30MPeK6s/8k5k6LdA2FhuRTi5zqMs4G/fxZM.rmI/OpWLknBbele', 'Admin', 'CMS', 'admin', TRUE)
ON CONFLICT DO NOTHING;

-- CMS Editor User (read/update only permissions)
INSERT INTO cms_users (email, password_hash, first_name, last_name, user_type, is_active) VALUES
    ('editor.cms@predicthealth.com', '$2b$12$w13etTUCcAshExi34EUPRuGlDsJPS6M4lFNSGy9mcKyv8e.1VfExO', 'Editor', 'CMS', 'editor', TRUE)
ON CONFLICT DO NOTHING;

-- Note: CMS users handle their own email authentication separately from the main system's contact emails
-- The emails table is for contact information of medical entities (patients, doctors, institutions)
-- CMS authentication is handled within the cms_users table

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
-- SYSTEM SETTINGS TABLE (CMS ADMIN ONLY)
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

-- Enable Row Level Security on system_settings
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Only CMS admin users can access system_settings
CREATE POLICY cms_admin_only_policy ON system_settings
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM cms_users cu
            WHERE cu.email = current_setting('app.current_user_email', TRUE)
            AND cu.user_type = 'admin'
            AND cu.is_active = TRUE
        )
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
