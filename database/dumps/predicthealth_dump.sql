--
-- PostgreSQL database dump
--

\restrict D0b9dh8J5EbIaFqFl6CKL0UrXXqnwWTjJjecMRnxq2Fc6d0esh3bkIBoCxD86a9

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: add_entity_address(character varying, uuid, character varying, character varying, character varying, character varying, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.add_entity_address(p_entity_type character varying, p_entity_id uuid, p_street_address character varying, p_city character varying, p_region_name character varying, p_country_iso character varying DEFAULT 'MEX'::character varying, p_postal_code character varying DEFAULT NULL::character varying, p_address_type character varying DEFAULT 'primary'::character varying, p_is_primary boolean DEFAULT false) RETURNS uuid
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


ALTER FUNCTION public.add_entity_address(p_entity_type character varying, p_entity_id uuid, p_street_address character varying, p_city character varying, p_region_name character varying, p_country_iso character varying, p_postal_code character varying, p_address_type character varying, p_is_primary boolean) OWNER TO "predictHealth_user";

--
-- Name: add_entity_email(character varying, uuid, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.add_entity_email(p_entity_type character varying, p_entity_id uuid, p_email_address character varying, p_email_type character varying DEFAULT 'primary'::character varying, p_is_primary boolean DEFAULT false) RETURNS uuid
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


ALTER FUNCTION public.add_entity_email(p_entity_type character varying, p_entity_id uuid, p_email_address character varying, p_email_type character varying, p_is_primary boolean) OWNER TO "predictHealth_user";

--
-- Name: add_entity_phone(character varying, uuid, character varying, character varying, boolean); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.add_entity_phone(p_entity_type character varying, p_entity_id uuid, p_phone_number character varying, p_phone_type character varying DEFAULT 'primary'::character varying, p_is_primary boolean DEFAULT false) RETURNS uuid
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


ALTER FUNCTION public.add_entity_phone(p_entity_type character varying, p_entity_id uuid, p_phone_number character varying, p_phone_type character varying, p_is_primary boolean) OWNER TO "predictHealth_user";

--
-- Name: get_primary_address(character varying, uuid); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.get_primary_address(p_entity_type character varying, p_entity_id uuid) RETURNS TABLE(street_address character varying, city character varying, region_name character varying, country_name character varying, postal_code character varying)
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


ALTER FUNCTION public.get_primary_address(p_entity_type character varying, p_entity_id uuid) OWNER TO "predictHealth_user";

--
-- Name: get_primary_email(character varying, uuid); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.get_primary_email(p_entity_type character varying, p_entity_id uuid) RETURNS character varying
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


ALTER FUNCTION public.get_primary_email(p_entity_type character varying, p_entity_id uuid) OWNER TO "predictHealth_user";

--
-- Name: get_primary_phone(character varying, uuid); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.get_primary_phone(p_entity_type character varying, p_entity_id uuid) RETURNS character varying
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


ALTER FUNCTION public.get_primary_phone(p_entity_type character varying, p_entity_id uuid) OWNER TO "predictHealth_user";

--
-- Name: sp_create_patient_with_profile(character varying, character varying, character varying, character varying, date, character varying, character varying, character varying, character varying, uuid, uuid, numeric, numeric, character varying); Type: PROCEDURE; Schema: public; Owner: predictHealth_user
--

CREATE PROCEDURE public.sp_create_patient_with_profile(IN p_first_name character varying, IN p_last_name character varying, IN p_email character varying, IN p_password_hash character varying, IN p_date_of_birth date, IN p_gender character varying, IN p_phone character varying, IN p_emergency_contact_name character varying, IN p_emergency_contact_phone character varying, IN p_doctor_id uuid, IN p_institution_id uuid, IN p_height_cm numeric, IN p_weight_kg numeric, IN p_blood_type character varying)
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


ALTER PROCEDURE public.sp_create_patient_with_profile(IN p_first_name character varying, IN p_last_name character varying, IN p_email character varying, IN p_password_hash character varying, IN p_date_of_birth date, IN p_gender character varying, IN p_phone character varying, IN p_emergency_contact_name character varying, IN p_emergency_contact_phone character varying, IN p_doctor_id uuid, IN p_institution_id uuid, IN p_height_cm numeric, IN p_weight_kg numeric, IN p_blood_type character varying) OWNER TO "predictHealth_user";

--
-- Name: sp_get_doctor_performance_stats(uuid); Type: PROCEDURE; Schema: public; Owner: predictHealth_user
--

CREATE PROCEDURE public.sp_get_doctor_performance_stats(IN p_doctor_id uuid, OUT total_patients integer, OUT avg_patient_age numeric, OUT common_conditions text, OUT institution_name character varying)
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


ALTER PROCEDURE public.sp_get_doctor_performance_stats(IN p_doctor_id uuid, OUT total_patients integer, OUT avg_patient_age numeric, OUT common_conditions text, OUT institution_name character varying) OWNER TO "predictHealth_user";

--
-- Name: sp_get_institution_analytics(uuid); Type: PROCEDURE; Schema: public; Owner: predictHealth_user
--

CREATE PROCEDURE public.sp_get_institution_analytics(IN p_institution_id uuid, OUT patient_count integer, OUT doctor_count integer, OUT avg_consultation_fee numeric, OUT most_common_specialty character varying, OUT relationship_integrity_status character varying)
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


ALTER PROCEDURE public.sp_get_institution_analytics(IN p_institution_id uuid, OUT patient_count integer, OUT doctor_count integer, OUT avg_consultation_fee numeric, OUT most_common_specialty character varying, OUT relationship_integrity_status character varying) OWNER TO "predictHealth_user";

--
-- Name: sp_get_patient_stats_by_month(integer); Type: PROCEDURE; Schema: public; Owner: predictHealth_user
--

CREATE PROCEDURE public.sp_get_patient_stats_by_month(IN p_year integer, OUT total_patients integer, OUT new_patients integer, OUT avg_age numeric, OUT patients_with_valid_relationships integer)
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


ALTER PROCEDURE public.sp_get_patient_stats_by_month(IN p_year integer, OUT total_patients integer, OUT new_patients integer, OUT avg_age numeric, OUT patients_with_valid_relationships integer) OWNER TO "predictHealth_user";

--
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trigger_set_timestamp() OWNER TO "predictHealth_user";

--
-- Name: validate_user_reference(); Type: FUNCTION; Schema: public; Owner: predictHealth_user
--

CREATE FUNCTION public.validate_user_reference() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.validate_user_reference() OWNER TO "predictHealth_user";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.addresses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id uuid NOT NULL,
    address_type character varying(50) DEFAULT 'primary'::character varying,
    street_address character varying(255) NOT NULL,
    neighborhood character varying(100),
    city character varying(100) NOT NULL,
    region_id integer,
    postal_code character varying(20),
    country_id integer,
    latitude numeric(10,8),
    longitude numeric(11,8),
    is_primary boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verification_method character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT addresses_address_type_check CHECK (((address_type)::text = ANY ((ARRAY['primary'::character varying, 'secondary'::character varying, 'billing'::character varying, 'shipping'::character varying, 'work'::character varying, 'home'::character varying])::text[]))),
    CONSTRAINT addresses_entity_type_check CHECK (((entity_type)::text = ANY ((ARRAY['doctor'::character varying, 'patient'::character varying, 'institution'::character varying])::text[]))),
    CONSTRAINT chk_coordinates CHECK ((((latitude IS NULL) AND (longitude IS NULL)) OR (((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric)) AND ((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric)))))
);


ALTER TABLE public.addresses OWNER TO "predictHealth_user";

--
-- Name: allergies; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.allergies (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.allergies OWNER TO "predictHealth_user";

--
-- Name: allergies_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.allergies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.allergies_id_seq OWNER TO "predictHealth_user";

--
-- Name: allergies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.allergies_id_seq OWNED BY public.allergies.id;


--
-- Name: blood_types; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.blood_types (
    id integer NOT NULL,
    name character varying(5) NOT NULL,
    description text,
    can_donate_to text[],
    can_receive_from text[],
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.blood_types OWNER TO "predictHealth_user";

--
-- Name: blood_types_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.blood_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blood_types_id_seq OWNER TO "predictHealth_user";

--
-- Name: blood_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.blood_types_id_seq OWNED BY public.blood_types.id;


--
-- Name: cms_permissions; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.cms_permissions (
    id integer NOT NULL,
    resource character varying(50) NOT NULL,
    action character varying(20) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.cms_permissions OWNER TO "predictHealth_user";

--
-- Name: cms_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.cms_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cms_permissions_id_seq OWNER TO "predictHealth_user";

--
-- Name: cms_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.cms_permissions_id_seq OWNED BY public.cms_permissions.id;


--
-- Name: cms_role_permissions; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.cms_role_permissions (
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.cms_role_permissions OWNER TO "predictHealth_user";

--
-- Name: cms_roles; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.cms_roles (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.cms_roles OWNER TO "predictHealth_user";

--
-- Name: cms_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.cms_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cms_roles_id_seq OWNER TO "predictHealth_user";

--
-- Name: cms_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.cms_roles_id_seq OWNED BY public.cms_roles.id;


--
-- Name: cms_users; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.cms_users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    user_type character varying(20) NOT NULL,
    role_id integer,
    is_active boolean DEFAULT true NOT NULL,
    last_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT cms_users_user_type_check CHECK (((user_type)::text = ANY ((ARRAY['admin'::character varying, 'editor'::character varying])::text[])))
);


ALTER TABLE public.cms_users OWNER TO "predictHealth_user";

--
-- Name: cms_users_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.cms_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cms_users_id_seq OWNER TO "predictHealth_user";

--
-- Name: cms_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.cms_users_id_seq OWNED BY public.cms_users.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    iso_code character varying(3) NOT NULL,
    iso_code_2 character varying(2),
    phone_code character varying(5),
    currency_code character varying(3),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.countries OWNER TO "predictHealth_user";

--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.countries_id_seq OWNER TO "predictHealth_user";

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: doctor_specialties; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.doctor_specialties (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    category_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.doctor_specialties OWNER TO "predictHealth_user";

--
-- Name: doctors; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.doctors (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    institution_id uuid NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    sex_id integer,
    gender_id integer,
    medical_license character varying(50) NOT NULL,
    specialty_id uuid,
    years_experience integer DEFAULT 0,
    consultation_fee numeric(10,2),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true NOT NULL,
    professional_status character varying(50) DEFAULT 'active'::character varying,
    last_login timestamp with time zone,
    CONSTRAINT chk_consultation_fee_range CHECK (((consultation_fee >= (0)::numeric) AND (consultation_fee <= (10000)::numeric))),
    CONSTRAINT doctors_consultation_fee_check CHECK ((consultation_fee >= (0)::numeric)),
    CONSTRAINT doctors_professional_status_check CHECK (((professional_status)::text = ANY ((ARRAY['active'::character varying, 'suspended'::character varying, 'retired'::character varying])::text[]))),
    CONSTRAINT doctors_years_experience_check CHECK ((years_experience >= 0))
);


ALTER TABLE public.doctors OWNER TO "predictHealth_user";

--
-- Name: email_types; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.email_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.email_types OWNER TO "predictHealth_user";

--
-- Name: email_types_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.email_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.email_types_id_seq OWNER TO "predictHealth_user";

--
-- Name: email_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.email_types_id_seq OWNED BY public.email_types.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.emails (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id uuid NOT NULL,
    email_type_id integer,
    email_address character varying(255) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verification_token character varying(255),
    verification_expires_at timestamp with time zone,
    verification_attempts integer DEFAULT 0,
    last_verification_attempt timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_email_format CHECK (((email_address)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT emails_entity_type_check CHECK (((entity_type)::text = ANY ((ARRAY['patient'::character varying, 'doctor'::character varying, 'institution'::character varying])::text[]))),
    CONSTRAINT emails_verification_attempts_check CHECK ((verification_attempts >= 0))
);


ALTER TABLE public.emails OWNER TO "predictHealth_user";

--
-- Name: genders; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.genders (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    display_name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.genders OWNER TO "predictHealth_user";

--
-- Name: genders_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.genders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genders_id_seq OWNER TO "predictHealth_user";

--
-- Name: genders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.genders_id_seq OWNED BY public.genders.id;


--
-- Name: health_profiles; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.health_profiles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    patient_id uuid NOT NULL,
    height_cm numeric(5,2),
    weight_kg numeric(5,2),
    blood_type_id integer,
    is_smoker boolean DEFAULT false NOT NULL,
    smoking_years integer DEFAULT 0,
    consumes_alcohol boolean DEFAULT false NOT NULL,
    alcohol_frequency character varying(20),
    physical_activity_minutes_weekly integer DEFAULT 0,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_alcohol_consistency CHECK (((NOT consumes_alcohol) OR (alcohol_frequency IS NOT NULL))),
    CONSTRAINT chk_smoking_consistency CHECK (((NOT is_smoker) OR (smoking_years > 0))),
    CONSTRAINT health_profiles_alcohol_frequency_check CHECK (((alcohol_frequency)::text = ANY ((ARRAY['never'::character varying, 'rarely'::character varying, 'occasionally'::character varying, 'regularly'::character varying, 'daily'::character varying])::text[]))),
    CONSTRAINT health_profiles_height_cm_check CHECK ((height_cm > (0)::numeric)),
    CONSTRAINT health_profiles_physical_activity_minutes_weekly_check CHECK ((physical_activity_minutes_weekly >= 0)),
    CONSTRAINT health_profiles_smoking_years_check CHECK ((smoking_years >= 0)),
    CONSTRAINT health_profiles_weight_kg_check CHECK ((weight_kg > (0)::numeric))
);


ALTER TABLE public.health_profiles OWNER TO "predictHealth_user";

--
-- Name: institution_types; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.institution_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    category character varying(50) DEFAULT NULL::character varying,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.institution_types OWNER TO "predictHealth_user";

--
-- Name: institution_types_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.institution_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.institution_types_id_seq OWNER TO "predictHealth_user";

--
-- Name: institution_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.institution_types_id_seq OWNED BY public.institution_types.id;


--
-- Name: medical_conditions; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.medical_conditions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.medical_conditions OWNER TO "predictHealth_user";

--
-- Name: medical_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.medical_conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.medical_conditions_id_seq OWNER TO "predictHealth_user";

--
-- Name: medical_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.medical_conditions_id_seq OWNED BY public.medical_conditions.id;


--
-- Name: medical_institutions; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.medical_institutions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(200) NOT NULL,
    institution_type_id integer NOT NULL,
    website character varying(255),
    license_number character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    last_login timestamp with time zone
);


ALTER TABLE public.medical_institutions OWNER TO "predictHealth_user";

--
-- Name: medications; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.medications (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE public.medications OWNER TO "predictHealth_user";

--
-- Name: medications_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.medications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.medications_id_seq OWNER TO "predictHealth_user";

--
-- Name: medications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.medications_id_seq OWNED BY public.medications.id;


--
-- Name: patient_allergies; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.patient_allergies (
    patient_id uuid NOT NULL,
    allergy_id integer NOT NULL,
    severity character varying(50),
    reaction_description text,
    CONSTRAINT patient_allergies_severity_check CHECK (((severity)::text = ANY ((ARRAY['mild'::character varying, 'moderate'::character varying, 'severe'::character varying])::text[])))
);


ALTER TABLE public.patient_allergies OWNER TO "predictHealth_user";

--
-- Name: patient_conditions; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.patient_conditions (
    patient_id uuid NOT NULL,
    condition_id integer NOT NULL,
    diagnosis_date date,
    notes text
);


ALTER TABLE public.patient_conditions OWNER TO "predictHealth_user";

--
-- Name: patient_family_history; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.patient_family_history (
    patient_id uuid NOT NULL,
    condition_id integer NOT NULL,
    relative_type character varying(50),
    notes text
);


ALTER TABLE public.patient_family_history OWNER TO "predictHealth_user";

--
-- Name: patient_medications; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.patient_medications (
    patient_id uuid NOT NULL,
    medication_id integer NOT NULL,
    dosage character varying(100),
    frequency character varying(100),
    start_date date
);


ALTER TABLE public.patient_medications OWNER TO "predictHealth_user";

--
-- Name: patients; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.patients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    doctor_id uuid NOT NULL,
    institution_id uuid NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    date_of_birth date NOT NULL,
    sex_id integer,
    gender_id integer,
    emergency_contact_name character varying(200),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    last_login timestamp with time zone,
    CONSTRAINT chk_patient_age CHECK (((date_of_birth <= CURRENT_DATE) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (date_of_birth)::timestamp with time zone)) <= (120)::numeric))),
    CONSTRAINT chk_patient_association CHECK (((doctor_id IS NOT NULL) AND (institution_id IS NOT NULL))),
    CONSTRAINT patients_date_of_birth_check CHECK ((date_of_birth <= CURRENT_DATE))
);


ALTER TABLE public.patients OWNER TO "predictHealth_user";

--
-- Name: phone_types; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.phone_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.phone_types OWNER TO "predictHealth_user";

--
-- Name: phone_types_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.phone_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.phone_types_id_seq OWNER TO "predictHealth_user";

--
-- Name: phone_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.phone_types_id_seq OWNED BY public.phone_types.id;


--
-- Name: phones; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.phones (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id uuid NOT NULL,
    phone_type_id integer,
    phone_number character varying(20) NOT NULL,
    country_code character varying(5) DEFAULT '+52'::character varying,
    area_code character varying(5),
    is_primary boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    verification_code character varying(10),
    verification_expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_phone_format CHECK ((((phone_number)::text ~ '^[0-9]{10,}$'::text) OR ((phone_number)::text ~ '^\+[0-9]{1,4}(-[0-9]{1,10})+$'::text))),
    CONSTRAINT phones_entity_type_check CHECK (((entity_type)::text = ANY ((ARRAY['doctor'::character varying, 'patient'::character varying, 'institution'::character varying, 'emergency_contact'::character varying])::text[])))
);


ALTER TABLE public.phones OWNER TO "predictHealth_user";

--
-- Name: regions; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.regions (
    id integer NOT NULL,
    country_id integer NOT NULL,
    name character varying(100) NOT NULL,
    region_code character varying(10),
    region_type character varying(50) DEFAULT 'state'::character varying,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT regions_region_type_check CHECK (((region_type)::text = ANY ((ARRAY['state'::character varying, 'province'::character varying, 'territory'::character varying, 'district'::character varying, 'municipality'::character varying])::text[])))
);


ALTER TABLE public.regions OWNER TO "predictHealth_user";

--
-- Name: regions_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.regions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regions_id_seq OWNER TO "predictHealth_user";

--
-- Name: regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;


--
-- Name: sexes; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.sexes (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    display_name character varying(100) NOT NULL,
    description text,
    chromosome_pattern character varying(10),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.sexes OWNER TO "predictHealth_user";

--
-- Name: sexes_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.sexes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sexes_id_seq OWNER TO "predictHealth_user";

--
-- Name: sexes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.sexes_id_seq OWNED BY public.sexes.id;


--
-- Name: specialty_categories; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.specialty_categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    parent_category_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.specialty_categories OWNER TO "predictHealth_user";

--
-- Name: specialty_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.specialty_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.specialty_categories_id_seq OWNER TO "predictHealth_user";

--
-- Name: specialty_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.specialty_categories_id_seq OWNED BY public.specialty_categories.id;


--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.system_settings (
    id integer NOT NULL,
    setting_key character varying(100) NOT NULL,
    setting_value text,
    setting_type character varying(50) DEFAULT 'string'::character varying,
    category character varying(50) DEFAULT 'general'::character varying,
    description text,
    is_system boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT system_settings_setting_type_check CHECK (((setting_type)::text = ANY ((ARRAY['string'::character varying, 'boolean'::character varying, 'number'::character varying, 'json'::character varying])::text[])))
);


ALTER TABLE public.system_settings OWNER TO "predictHealth_user";

--
-- Name: system_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: predictHealth_user
--

CREATE SEQUENCE public.system_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_settings_id_seq OWNER TO "predictHealth_user";

--
-- Name: system_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: predictHealth_user
--

ALTER SEQUENCE public.system_settings_id_seq OWNED BY public.system_settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: predictHealth_user
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    user_type character varying(50) NOT NULL,
    reference_id uuid NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    failed_login_attempts integer DEFAULT 0,
    last_failed_login timestamp with time zone,
    password_changed_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_reference_consistency CHECK ((reference_id IS NOT NULL)),
    CONSTRAINT users_failed_login_attempts_check CHECK ((failed_login_attempts >= 0)),
    CONSTRAINT users_user_type_check CHECK (((user_type)::text = ANY ((ARRAY['patient'::character varying, 'doctor'::character varying, 'institution'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO "predictHealth_user";

--
-- Name: vw_dashboard_overview; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_dashboard_overview AS
 SELECT ( SELECT count(*) AS count
           FROM public.patients
          WHERE (patients.is_active = true)) AS total_patients,
    ( SELECT count(*) AS count
           FROM public.doctors
          WHERE (doctors.is_active = true)) AS total_doctors,
    ( SELECT count(*) AS count
           FROM public.medical_institutions
          WHERE (medical_institutions.is_active = true)) AS total_institutions,
    ( SELECT count(*) AS count
           FROM public.users
          WHERE (users.is_active = true)) AS total_users,
    ( SELECT count(*) AS count
           FROM public.patients
          WHERE ((patients.is_verified = true) AND (patients.is_active = true))) AS validated_patients,
    ( SELECT avg(doctors.consultation_fee) AS avg
           FROM public.doctors
          WHERE (doctors.is_active = true)) AS avg_consultation_fee,
    ( SELECT count(*) AS count
           FROM (public.patients p
             JOIN public.doctors d ON ((p.doctor_id = d.id)))
          WHERE ((p.is_active = true) AND (d.institution_id = p.institution_id))) AS patients_with_valid_relationships,
    ( SELECT round((((count(*))::numeric / (NULLIF(( SELECT count(*) AS count
                   FROM public.patients
                  WHERE (patients.is_active = true)), 0))::numeric) * (100)::numeric), 2) AS round
           FROM (public.patients p
             JOIN public.doctors d ON ((p.doctor_id = d.id)))
          WHERE ((p.is_active = true) AND (d.institution_id = p.institution_id))) AS relationship_integrity_percentage;


ALTER TABLE public.vw_dashboard_overview OWNER TO "predictHealth_user";

--
-- Name: vw_doctor_performance; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_doctor_performance AS
 SELECT d.id,
    d.first_name,
    d.last_name,
    ( SELECT emails.email_address
           FROM public.emails
          WHERE (((emails.entity_type)::text = 'doctor'::text) AND (emails.entity_id = d.id) AND (emails.is_primary = true))
         LIMIT 1) AS email,
    d.medical_license,
    d.years_experience,
    d.consultation_fee,
    ds.name AS specialty,
    sc.name AS specialty_category,
    mi.name AS institution_name,
    it.name AS institution_type,
    count(p.id) AS patient_count,
    avg(EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (p.date_of_birth)::timestamp with time zone))) AS avg_patient_age,
    ( SELECT phones.phone_number
           FROM public.phones
          WHERE (((phones.entity_type)::text = 'doctor'::text) AND (phones.entity_id = d.id) AND (phones.is_primary = true))
         LIMIT 1) AS primary_phone,
    addr.street_address AS institution_address,
    addr.city AS institution_city,
    r.name AS institution_region,
    c.name AS institution_country,
    d.created_at
   FROM ((((((((public.doctors d
     LEFT JOIN public.doctor_specialties ds ON ((d.specialty_id = ds.id)))
     LEFT JOIN public.specialty_categories sc ON ((ds.category_id = sc.id)))
     JOIN public.medical_institutions mi ON ((d.institution_id = mi.id)))
     LEFT JOIN public.institution_types it ON ((mi.institution_type_id = it.id)))
     LEFT JOIN public.addresses addr ON ((((addr.entity_type)::text = 'institution'::text) AND (addr.entity_id = mi.id) AND (addr.is_primary = true))))
     LEFT JOIN public.regions r ON ((addr.region_id = r.id)))
     LEFT JOIN public.countries c ON ((addr.country_id = c.id)))
     LEFT JOIN public.patients p ON (((d.id = p.doctor_id) AND (p.is_active = true))))
  WHERE (d.is_active = true)
  GROUP BY d.id, d.first_name, d.last_name, d.medical_license, d.years_experience, d.consultation_fee, ds.name, sc.name, mi.name, it.name, addr.street_address, addr.city, r.name, c.name, d.created_at;


ALTER TABLE public.vw_doctor_performance OWNER TO "predictHealth_user";

--
-- Name: vw_doctor_specialty_distribution; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_doctor_specialty_distribution AS
 SELECT ds.name AS specialty,
    sc.name AS category,
    count(d.id) AS doctor_count
   FROM ((public.doctor_specialties ds
     LEFT JOIN public.specialty_categories sc ON ((ds.category_id = sc.id)))
     LEFT JOIN public.doctors d ON (((ds.id = d.specialty_id) AND (d.is_active = true))))
  GROUP BY ds.name, sc.name
  ORDER BY (count(d.id)) DESC;


ALTER TABLE public.vw_doctor_specialty_distribution OWNER TO "predictHealth_user";

--
-- Name: vw_geographic_distribution; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_geographic_distribution AS
 SELECT c.name AS country,
    r.name AS region_state,
    r.region_type,
    count(DISTINCT mi.id) AS institution_count,
    count(DISTINCT d.id) AS doctor_count,
    count(DISTINCT p.id) AS patient_count,
    count(DISTINCT addr.id) AS address_count
   FROM (((((public.countries c
     LEFT JOIN public.regions r ON ((c.id = r.country_id)))
     LEFT JOIN public.addresses addr ON ((addr.region_id = r.id)))
     LEFT JOIN public.medical_institutions mi ON (((addr.entity_id = mi.id) AND ((addr.entity_type)::text = 'institution'::text))))
     LEFT JOIN public.doctors d ON (((mi.id = d.institution_id) AND (d.is_active = true))))
     LEFT JOIN public.patients p ON (((mi.id = p.institution_id) AND (p.is_active = true))))
  WHERE ((c.is_active = true) AND (r.is_active = true))
  GROUP BY c.name, r.name, r.region_type
  ORDER BY c.name, r.name;


ALTER TABLE public.vw_geographic_distribution OWNER TO "predictHealth_user";

--
-- Name: vw_health_condition_prevalence; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_health_condition_prevalence AS
 SELECT mc.name AS condition,
    count(pc.patient_id) AS patient_count
   FROM (public.medical_conditions mc
     LEFT JOIN public.patient_conditions pc ON ((mc.id = pc.condition_id)))
  GROUP BY mc.name
  ORDER BY (count(pc.patient_id)) DESC;


ALTER TABLE public.vw_health_condition_prevalence OWNER TO "predictHealth_user";

--
-- Name: vw_health_condition_stats; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_health_condition_stats AS
 SELECT count(DISTINCT p.id) AS total_patients,
    count(DISTINCT
        CASE
            WHEN (pc.condition_id = ( SELECT medical_conditions.id
               FROM public.medical_conditions
              WHERE ((medical_conditions.name)::text = 'Hypertension'::text))) THEN p.id
            ELSE NULL::uuid
        END) AS hypertension_count,
    count(DISTINCT
        CASE
            WHEN (pc.condition_id = ( SELECT medical_conditions.id
               FROM public.medical_conditions
              WHERE ((medical_conditions.name)::text = 'Diabetes'::text))) THEN p.id
            ELSE NULL::uuid
        END) AS diabetes_count,
    count(DISTINCT
        CASE
            WHEN (pc.condition_id = ( SELECT medical_conditions.id
               FROM public.medical_conditions
              WHERE ((medical_conditions.name)::text = 'High Cholesterol'::text))) THEN p.id
            ELSE NULL::uuid
        END) AS cholesterol_count,
    count(
        CASE
            WHEN hp.is_smoker THEN 1
            ELSE NULL::integer
        END) AS smoker_count,
    round(avg(hp.height_cm), 2) AS avg_height,
    round(avg(hp.weight_kg), 2) AS avg_weight
   FROM ((public.patients p
     JOIN public.health_profiles hp ON ((p.id = hp.patient_id)))
     LEFT JOIN public.patient_conditions pc ON ((p.id = pc.patient_id)))
  WHERE (p.is_active = true);


ALTER TABLE public.vw_health_condition_stats OWNER TO "predictHealth_user";

--
-- Name: vw_monthly_registrations; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_monthly_registrations AS
 SELECT date_trunc('month'::text, p.created_at) AS registration_month,
    count(*) AS total_registrations,
    count(
        CASE
            WHEN ((g.name)::text = 'male'::text) THEN 1
            ELSE NULL::integer
        END) AS male_count,
    count(
        CASE
            WHEN ((g.name)::text = 'female'::text) THEN 1
            ELSE NULL::integer
        END) AS female_count,
    count(
        CASE
            WHEN ((g.name)::text = ANY ((ARRAY['non_binary'::character varying, 'genderqueer'::character varying, 'genderfluid'::character varying, 'agender'::character varying, 'other'::character varying])::text[])) THEN 1
            ELSE NULL::integer
        END) AS other_gender_count
   FROM (public.patients p
     LEFT JOIN public.genders g ON ((p.gender_id = g.id)))
  WHERE (p.is_active = true)
  GROUP BY (date_trunc('month'::text, p.created_at))
  ORDER BY (date_trunc('month'::text, p.created_at)) DESC;


ALTER TABLE public.vw_monthly_registrations OWNER TO "predictHealth_user";

--
-- Name: vw_patient_demographics; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_patient_demographics AS
SELECT
    NULL::uuid AS id,
    NULL::character varying(100) AS first_name,
    NULL::character varying(100) AS last_name,
    NULL::character varying(255) AS email,
    NULL::date AS date_of_birth,
    NULL::numeric AS age,
    NULL::character varying(100) AS biological_sex,
    NULL::character varying(100) AS gender_identity,
    NULL::boolean AS is_active,
    NULL::boolean AS is_verified,
    NULL::character varying(100) AS doctor_first_name,
    NULL::character varying(100) AS doctor_last_name,
    NULL::character varying(200) AS institution_name,
    NULL::text AS relationship_status,
    NULL::character varying(5) AS blood_type,
    NULL::text AS diagnosed_conditions,
    NULL::character varying(20) AS primary_phone,
    NULL::character varying(20) AS emergency_phone,
    NULL::text AS patient_address,
    NULL::text AS patient_city,
    NULL::character varying(100) AS institution_region,
    NULL::character varying(100) AS institution_country,
    NULL::timestamp with time zone AS created_at;


ALTER TABLE public.vw_patient_demographics OWNER TO "predictHealth_user";

--
-- Name: vw_patient_validation_status; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_patient_validation_status AS
 SELECT
        CASE
            WHEN (patients.is_verified = true) THEN 'verified'::text
            WHEN (patients.is_verified = false) THEN 'unverified'::text
            ELSE 'pending'::text
        END AS validation_status,
    count(*) AS patient_count,
    round((((count(*))::numeric * 100.0) / sum(count(*)) OVER ()), 1) AS percentage
   FROM public.patients
  WHERE (patients.is_active = true)
  GROUP BY patients.is_verified
  ORDER BY (count(*)) DESC;


ALTER TABLE public.vw_patient_validation_status OWNER TO "predictHealth_user";

--
-- Name: vw_relationship_integrity; Type: VIEW; Schema: public; Owner: predictHealth_user
--

CREATE VIEW public.vw_relationship_integrity AS
 SELECT 'Patient-Doctor-Institution Relationships'::text AS check_type,
    count(*) AS total_records,
    count(
        CASE
            WHEN ((p.doctor_id IS NOT NULL) AND (p.institution_id IS NOT NULL)) THEN 1
            ELSE NULL::integer
        END) AS complete_relationships,
    count(
        CASE
            WHEN ((p.doctor_id IS NULL) OR (p.institution_id IS NULL)) THEN 1
            ELSE NULL::integer
        END) AS incomplete_relationships,
    count(
        CASE
            WHEN ((p.doctor_id IS NOT NULL) AND (p.institution_id IS NOT NULL) AND (d.institution_id = p.institution_id)) THEN 1
            ELSE NULL::integer
        END) AS valid_relationships,
    count(
        CASE
            WHEN ((p.doctor_id IS NOT NULL) AND (p.institution_id IS NOT NULL) AND (d.institution_id <> p.institution_id)) THEN 1
            ELSE NULL::integer
        END) AS invalid_relationships,
    round((((count(
        CASE
            WHEN ((p.doctor_id IS NOT NULL) AND (p.institution_id IS NOT NULL) AND (d.institution_id = p.institution_id)) THEN 1
            ELSE NULL::integer
        END))::numeric / (NULLIF(count(*), 0))::numeric) * (100)::numeric), 2) AS integrity_percentage
   FROM (public.patients p
     LEFT JOIN public.doctors d ON ((p.doctor_id = d.id)))
  WHERE (p.is_active = true);


ALTER TABLE public.vw_relationship_integrity OWNER TO "predictHealth_user";

--
-- Name: allergies id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.allergies ALTER COLUMN id SET DEFAULT nextval('public.allergies_id_seq'::regclass);


--
-- Name: blood_types id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.blood_types ALTER COLUMN id SET DEFAULT nextval('public.blood_types_id_seq'::regclass);


--
-- Name: cms_permissions id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_permissions ALTER COLUMN id SET DEFAULT nextval('public.cms_permissions_id_seq'::regclass);


--
-- Name: cms_roles id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_roles ALTER COLUMN id SET DEFAULT nextval('public.cms_roles_id_seq'::regclass);


--
-- Name: cms_users id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_users ALTER COLUMN id SET DEFAULT nextval('public.cms_users_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: email_types id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.email_types ALTER COLUMN id SET DEFAULT nextval('public.email_types_id_seq'::regclass);


--
-- Name: genders id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.genders ALTER COLUMN id SET DEFAULT nextval('public.genders_id_seq'::regclass);


--
-- Name: institution_types id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.institution_types ALTER COLUMN id SET DEFAULT nextval('public.institution_types_id_seq'::regclass);


--
-- Name: medical_conditions id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medical_conditions ALTER COLUMN id SET DEFAULT nextval('public.medical_conditions_id_seq'::regclass);


--
-- Name: medications id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medications ALTER COLUMN id SET DEFAULT nextval('public.medications_id_seq'::regclass);


--
-- Name: phone_types id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.phone_types ALTER COLUMN id SET DEFAULT nextval('public.phone_types_id_seq'::regclass);


--
-- Name: regions id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);


--
-- Name: sexes id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.sexes ALTER COLUMN id SET DEFAULT nextval('public.sexes_id_seq'::regclass);


--
-- Name: specialty_categories id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.specialty_categories ALTER COLUMN id SET DEFAULT nextval('public.specialty_categories_id_seq'::regclass);


--
-- Name: system_settings id; Type: DEFAULT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.system_settings ALTER COLUMN id SET DEFAULT nextval('public.system_settings_id_seq'::regclass);


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.addresses (id, entity_type, entity_id, address_type, street_address, neighborhood, city, region_id, postal_code, country_id, latitude, longitude, is_primary, is_verified, verification_method, created_at, updated_at) FROM stdin;
8382af5b-2473-4229-8431-2c565625d5bd	institution	11000000-e29b-41d4-a716-446655440001	primary	Av. Reforma 150, Centro Histórico	\N	Ciudad de México	9	\N	1	\N	\N	t	t	\N	2025-11-22 04:17:10.026913+00	2025-11-22 04:17:10.026913+00
e588a21d-d571-4099-a14a-2ece35ae0172	institution	12000000-e29b-41d4-a716-446655440002	primary	Calle Juárez 45, Zona Norte	\N	Monterrey	19	\N	1	\N	\N	t	t	\N	2025-11-22 04:17:10.033378+00	2025-11-22 04:17:10.033378+00
5ed2fe30-595d-4908-9215-7d12210d3ef0	institution	13000000-e29b-41d4-a716-446655440003	primary	Blvd. del Sur 89, Colonia del Valle	\N	Guadalajara	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:17:10.039859+00	2025-11-22 04:17:10.039859+00
ff8aec25-6734-42fc-84eb-089c736883a5	institution	14000000-e29b-41d4-a716-446655440004	primary	Paseo de los Héroes 234	\N	León	11	\N	1	\N	\N	t	t	\N	2025-11-22 04:17:10.059269+00	2025-11-22 04:17:10.059269+00
85f734f1-2dc5-4a24-af08-2783563a9224	institution	15000000-e29b-41d4-a716-446655440005	primary	Malecón 567, Zona Dorada	\N	Puerto Vallarta	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:17:10.064892+00	2025-11-22 04:17:10.064892+00
043d379d-0907-43bf-83df-98b6e1e14d2f	institution	163749fb-8b46-4447-a8b7-95b4a59531b6	primary	Callej??n Norte Salas 373 045	\N	San Jos?? Emilio de la Monta??a	21	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.497485+00	2025-11-22 04:41:41.497485+00
d8f530fc-1068-48f4-9b74-0d49bcdb57e5	institution	83b74179-f6ef-4219-bc70-c93f4393a350	primary	Cerrada Sur Godoy 405 Interior 179	\N	Vieja Congo	18	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.508519+00	2025-11-22 04:41:41.508519+00
d0ffc06b-69d6-407c-b2fd-3eb83b3b63e9	institution	50503414-ca6d-4c1a-a34f-18719e2fd555	primary	Calle Lara 137 Edif. 886 , Depto. 577	\N	Vieja Sud??frica	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.514816+00	2025-11-22 04:41:41.514816+00
5892afdd-34e3-44e6-b6be-81e61de7ef57	institution	9b581d3c-9e93-4f39-80bb-294752065866	primary	Pasaje Quer??taro 561 Edif. 908 , Depto. 978	\N	Nueva Bhut??n	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.519757+00	2025-11-22 04:41:41.519757+00
cda8f744-bf1a-476d-b7cc-70f5bc52634e	institution	e0e34926-8d48-4db0-afb9-b20b6eeb1ecb	primary	Eje vial Nuevo Le??n 923 415	\N	Nueva Austria	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.522999+00	2025-11-22 04:41:41.522999+00
1930008e-8b19-4110-87d1-3e26e6cc259b	institution	81941e1d-820a-4313-8177-e44278d9a981	primary	Peatonal Colombia 063 409	\N	Vieja Austria	32	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.526346+00	2025-11-22 04:41:41.526346+00
08600269-f765-4f34-ae07-773928466d0e	institution	a725b15f-039b-4256-843a-51a2968633fd	primary	Boulevard Nayarit 972 Interior 061	\N	Nueva Marruecos	28	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.530719+00	2025-11-22 04:41:41.530719+00
c8007421-455d-44bd-b976-56bba2dc79d4	institution	0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d	primary	Ampliaci??n Rep??blica de Moldova 034 Edif. 016 , Depto. 781	\N	Nueva Eslovaquia	32	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.535592+00	2025-11-22 04:41:41.535592+00
c306cb59-f25c-45fb-9314-6d9633f6dc78	institution	d471d2d1-66a1-4de0-8754-127059786888	primary	Boulevard Sur Vera 081 Interior 214	\N	San Helena los bajos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.540016+00	2025-11-22 04:41:41.540016+00
5c2553f9-4485-49c3-af35-8c6be5df3182	institution	8fd698b3-084d-4248-a28e-2708a5862e27	primary	Pasaje Rep??blica de Macedonia del Norte 006 986	\N	San Renato de la Monta??a	29	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.543539+00	2025-11-22 04:41:41.543539+00
10e954a1-be9d-4292-b4f8-cdec7b87f49a	institution	7b96a7bb-041f-4331-be05-e97cab7dafc0	primary	Privada Norte Cordero 930 Edif. 075 , Depto. 923	\N	San Teresa los bajos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.548218+00	2025-11-22 04:41:41.548218+00
af594f70-62ae-4691-9e79-ec68b1da5e9a	institution	5da54d5d-de0c-4277-a43e-6a89f987e77c	primary	Pasaje Baja California Sur 457 Interior 112	\N	Vieja Ecuador	29	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:41.569613+00	2025-11-22 04:41:41.569613+00
8adac400-d991-4cc7-a556-5b711b50e2ad	institution	c9014e88-309c-4cb0-a28d-25b510e1e522	primary	Boulevard Sur Velasco 597 810	\N	Vieja Malta	32	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.145861+00	2025-11-22 04:41:42.145861+00
6ccc14ad-75ad-41d9-9820-c159f32a165e	institution	8e889f63-2c86-44ab-959f-fdc365353d5d	primary	Corredor Sur Ba??uelos 653 Interior 291	\N	Vieja Argentina	23	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.152093+00	2025-11-22 04:41:42.152093+00
fdd9c9a0-5723-4dfb-8afd-8e341e457f45	institution	67787f7c-fdee-4e30-80bd-89008ebfe419	primary	Eje vial Salazar 572 Edif. 861 , Depto. 031	\N	San Rafa??l los bajos	18	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.158434+00	2025-11-22 04:41:42.158434+00
ef16967d-6b50-4b72-bdcf-c56eceb1b556	institution	4721cb90-8fb0-4fd6-b19e-160b4ac0c744	primary	Calzada Coahuila de Zaragoza 496 Edif. 830 , Depto. 716	\N	Nueva Turqu??a	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.165408+00	2025-11-22 04:41:42.165408+00
07d6cc36-b387-4dc7-aea5-14bf80462c9b	institution	09c54a60-6267-4439-9c8b-8c9012842942	primary	Retorno Norte Salda??a 775 878	\N	Vieja Paraguay	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.185479+00	2025-11-22 04:41:42.185479+00
3132b8b7-73d0-41dc-bdce-a8aa73c8bbba	institution	a670c73c-cc47-42fe-88c9-0fa37359779b	primary	Retorno Barbados 161 Interior 957	\N	San Nicol??s los bajos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.193147+00	2025-11-22 04:41:42.193147+00
a3f33b94-8538-4af3-8c7f-862a036ee449	institution	373769ab-b720-4269-bfb9-02546401ce99	primary	Eje vial Villareal 123 530	\N	Vieja Sud??frica	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.198953+00	2025-11-22 04:41:42.198953+00
cf8d4e51-21bb-46af-8a0f-a3c3dabc497e	institution	ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	primary	Peatonal Ir??n 415 Edif. 271 , Depto. 663	\N	Vieja Letonia	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.204952+00	2025-11-22 04:41:42.204952+00
23871953-eadb-4dfb-bfa4-4aca5be4c2cc	institution	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	primary	Perif??rico Chiapas 243 Edif. 549 , Depto. 615	\N	Vieja Rep??blica de Corea	28	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.209686+00	2025-11-22 04:41:42.209686+00
fa672bd8-1842-4b07-a858-f9994d209e18	institution	6c287a0e-9d4c-4574-932f-7d499aa4146c	primary	Privada Norte Cruz 604 Edif. 735 , Depto. 097	\N	San Cristina de la Monta??a	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.215278+00	2025-11-22 04:41:42.215278+00
dac5d8c4-2e67-4fac-83fd-fe03f600564c	institution	a14c189c-ee90-4c29-b465-63d43a9d0010	primary	Avenida Austria 163 Interior 093	\N	Vieja Afganist??n	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.220179+00	2025-11-22 04:41:42.220179+00
eacb38a2-b9cd-49bd-8693-4ff865d45786	institution	e040eabc-0ac9-47f7-89ae-24246e1c12dd	primary	Corredor Morelos 664 Interior 001	\N	San Diego los altos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.225252+00	2025-11-22 04:41:42.225252+00
dc2e7a52-afb3-40f3-8d48-91e549266e86	institution	9c8636c9-015b-4c18-a641-f5da698b6fd8	primary	Ampliaci??n Sur Cort??s 140 Interior 719	\N	Nueva Luxemburgo	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.230758+00	2025-11-22 04:41:42.230758+00
8027b9c2-6f46-41a4-a806-f82b5e8cc606	institution	b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	primary	Circunvalaci??n Raya 149 Interior 138	\N	Vieja Cuba	28	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.235695+00	2025-11-22 04:41:42.235695+00
d15cd495-be48-4a99-aaff-057e5ee65178	institution	146a692b-6d46-4c26-a165-092fe771400e	primary	Viaducto Laureano 126 299	\N	Nueva Armenia	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.239708+00	2025-11-22 04:41:42.239708+00
354f80f2-e227-4f7b-a07b-1309cb33d865	institution	6297ae0f-7fee-472d-87ec-e22b87ce6ffb	primary	Calzada Carmona 802 263	\N	San Claudia de la Monta??a	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.245818+00	2025-11-22 04:41:42.245818+00
d525896e-bf5f-4ea4-a756-3eca69ad1d44	institution	66e6aa6c-596c-442e-85fb-b143875d0dfc	primary	Perif??rico Trinidad y Tabago 010 Edif. 969 , Depto. 295	\N	San Antonio los altos	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.253718+00	2025-11-22 04:41:42.253718+00
02086dce-427c-4b3c-87ec-4152276ef454	institution	46af545e-6db8-44ba-a7f9-9fd9617f4a09	primary	Avenida M??xico 943 Edif. 161 , Depto. 734	\N	San Nayeli los bajos	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.274539+00	2025-11-22 04:41:42.274539+00
175929bb-d759-4c6f-a69a-0f22087b68dc	institution	a56b6787-94e9-49f0-8b3a-6ff5979773fc	primary	Callej??n Hait?? 796 437	\N	San Emilio de la Monta??a	28	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.279717+00	2025-11-22 04:41:42.279717+00
b82d8181-f5c3-4037-8f4d-a8770b64175b	institution	d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	primary	Cerrada Ur??as 027 Interior 861	\N	Nueva Costa Rica	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.284701+00	2025-11-22 04:41:42.284701+00
c73ed1fc-a4f7-4fe4-93c2-47d5bfa9918f	institution	4bfa1a0a-0434-45e0-b454-03140b992f53	primary	Peatonal San Vicente y las Granadinas 662 Edif. 611 , Depto. 184	\N	Vieja Niger	21	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.290614+00	2025-11-22 04:41:42.290614+00
f374704a-e665-4c6c-a68c-028bdcd74db1	institution	33ba98b9-c46a-47c1-b266-d8a4fe557290	primary	Corredor Seychelles 533 Interior 972	\N	Nueva Zimbabwe	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.295335+00	2025-11-22 04:41:42.295335+00
f5303c72-c1ce-48f3-822a-952cc62174ca	institution	f4764cd3-47e9-4408-b0ee-9b9001c5459d	primary	Calle Nayarit 442 Interior 357	\N	San ??rsula de la Monta??a	11	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.299007+00	2025-11-22 04:41:42.299007+00
a289fddf-2820-467f-9a37-412150533343	institution	f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8	primary	Andador Sur Alfaro 161 Edif. 565 , Depto. 595	\N	Vieja Chad	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.305553+00	2025-11-22 04:41:42.305553+00
6c253803-6bbf-475b-89cb-adddcb9b0242	institution	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	primary	Viaducto Chihuahua 885 664	\N	San Juan Carlos los bajos	30	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.310505+00	2025-11-22 04:41:42.310505+00
a935b4cc-bfe7-42b1-be93-354409fd91c5	institution	8be78aaa-c408-452e-bf01-8e831ab5c63a	primary	Callej??n Sur Ceja 651 768	\N	Nueva Filipinas	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.313858+00	2025-11-22 04:41:42.313858+00
b1bef35e-52d2-4781-a7ab-9045b73d0500	institution	8fb0899c-732e-4f03-8209-d52ef41a6a76	primary	Andador Jasso 972 Edif. 726 , Depto. 944	\N	San Evelio de la Monta??a	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.31842+00	2025-11-22 04:41:42.31842+00
bd1687de-f6c8-476e-93d6-b6f9bc90cd56	institution	3a9084e7-74c5-4e0b-b786-2c93d9cd39ee	primary	Ampliaci??n Nayarit 393 451	\N	Nueva Arabia Saudita	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.32281+00	2025-11-22 04:41:42.32281+00
77c80995-7d66-4d7e-96ae-74723487656e	institution	54481b92-e5f5-421b-ba21-89bf520a2d87	primary	Perif??rico Nayarit 605 299	\N	San Alberto los bajos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.327833+00	2025-11-22 04:41:42.327833+00
15eeb2af-b89b-4d4f-9d0b-3e42aec1ab65	institution	68f1a02a-d348-4d1e-99ee-733d832a3f43	primary	Circuito Norte Anguiano 209 Interior 539	\N	San Jacinto de la Monta??a	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.332699+00	2025-11-22 04:41:42.332699+00
3d9adf25-f407-4b28-909c-d3d141d5e302	institution	36983990-abe8-4f1c-9c1b-863b9cab3ca9	primary	Eje vial Norte Zaragoza 384 512	\N	San Miguel los bajos	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.336421+00	2025-11-22 04:41:42.336421+00
f9540bef-761d-4759-a07c-3d59096b517f	institution	b654860f-ec74-42d6-955e-eeedde2df0dd	primary	Diagonal Hidalgo 266 Interior 555	\N	Nueva Senegal	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.340148+00	2025-11-22 04:41:42.340148+00
e408685b-6ce0-440a-b755-1ecd121e8793	institution	be133600-848e-400b-9bc8-c52a4f3cf10d	primary	Cerrada Rep??blica Unida de Tanzan??a 421 Interior 827	\N	Nueva Eslovenia	23	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.344913+00	2025-11-22 04:41:42.344913+00
9a561329-d644-4a44-aa33-8c5f5347e935	institution	25e918f3-692f-4f51-b630-4caa1dd825a1	primary	Privada Burkina Faso 176 Edif. 978 , Depto. 820	\N	San Benito los altos	11	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.350862+00	2025-11-22 04:41:42.350862+00
a3f3d1c6-13d0-4b07-b1bd-d7b12519d5cb	institution	cc46221e-f387-463c-9d11-9464d8209f7b	primary	Prolongaci??n Baja California 223 Edif. 135 , Depto. 987	\N	San Rafa??l los altos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.35625+00	2025-11-22 04:41:42.35625+00
6bb7dcf8-7c56-4e08-b1b8-818ff546e03d	institution	a15d4a4b-1bc4-4ee5-a168-714f71d94e42	primary	Circuito Norte Pichardo 264 Edif. 572 , Depto. 578	\N	Nueva Rep??blica Federal Democr??tica de Nepal	30	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.360629+00	2025-11-22 04:41:42.360629+00
c21a2ea3-8641-4413-a546-8db3238f18ed	institution	3d7c5771-0692-4a2f-a4c6-6af2b561282b	primary	Cerrada Jalisco 313 906	\N	Vieja Papua Nueva Guinea	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.367228+00	2025-11-22 04:41:42.367228+00
7c4104f3-133c-421e-9f95-ab4478f24f84	institution	16b25a77-b84a-44ac-8540-c5bfa9b3b6b0	primary	Andador Jalisco 470 Edif. 504 , Depto. 780	\N	Vieja Colombia	28	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.372451+00	2025-11-22 04:41:42.372451+00
26dc4b87-a86a-41ab-a9a2-283c2d75c946	institution	2040ac28-7210-4fbd-9716-53872211bcd9	primary	Perif??rico Concepci??n 008 Edif. 258 , Depto. 440	\N	Nueva Pakist??n	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.376815+00	2025-11-22 04:41:42.376815+00
2d0fd529-4d0a-4f96-95aa-733e601e25f9	institution	0d826581-b9d8-4828-8848-9332fe38d169	primary	Cerrada Sur Cervantes 703 Edif. 909 , Depto. 567	\N	San Natalia los bajos	27	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.382882+00	2025-11-22 04:41:42.382882+00
3f6ee7c4-901d-4a87-98b1-3efc02528621	institution	c0595f94-c8f4-413c-a05c-7cfca773563c	primary	Retorno Noruega 285 221	\N	Nueva Georgia	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.386846+00	2025-11-22 04:41:42.386846+00
f782ae61-379b-4edb-94d8-62952a2689b9	institution	a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5	primary	Boulevard Sur Ochoa 308 025	\N	San Octavio los altos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.392372+00	2025-11-22 04:41:42.392372+00
f7749759-1323-41a2-972d-ffdcbb7b37d5	institution	ad2c792b-5015-4238-b221-fa28e8b061fc	primary	Circuito Rep??blica Checa 763 Interior 806	\N	Nueva Montenegro	17	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.396879+00	2025-11-22 04:41:42.396879+00
ac74b9d8-0a64-4340-b753-6e6db7decb65	institution	c3e96b10-f0ca-421e-b402-aba6d595cf27	primary	Privada Sur Ruelas 336 Interior 844	\N	Nueva Burundi	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.401071+00	2025-11-22 04:41:42.401071+00
fd7ef2eb-a0b4-468f-b53c-0dea124c31c6	institution	a5b1202a-9112-404b-b7de-ddf0f62711f8	primary	Boulevard San Luis Potos?? 828 Interior 438	\N	San Daniel de la Monta??a	32	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.405331+00	2025-11-22 04:41:42.405331+00
81d2080c-7489-4189-b4c3-de910069e857	institution	ac6f8f54-21c8-475b-bea6-19e31643392d	primary	Cerrada Mali 386 Edif. 915 , Depto. 973	\N	Vieja Bulgaria	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.410738+00	2025-11-22 04:41:42.410738+00
e71fd3ca-18b6-4af7-b49d-df9970ff8dcf	institution	43dee983-676a-4e33-a6b0-f0a72f46d06c	primary	Corredor Quer??taro 046 Interior 451	\N	San Virginia de la Monta??a	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.420335+00	2025-11-22 04:41:42.420335+00
f838bc9e-d5ce-4975-8c3f-92dfbcb3c11d	institution	f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	primary	Ampliaci??n Tamaulipas 608 Interior 109	\N	Vieja Israel	17	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.425588+00	2025-11-22 04:41:42.425588+00
1cb89744-8d81-4502-9a43-eb33bbfb6683	institution	08a7fe9e-c043-4fed-89e4-93a416a20089	primary	Cerrada Sur Blanco 381 145	\N	Vieja Croacia	28	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.430478+00	2025-11-22 04:41:42.430478+00
80147f52-d508-46fc-9368-fe84187a6a0c	institution	89ab21cf-089e-4210-8e29-269dfbd38d71	primary	Viaducto Sur Alejandro 902 945	\N	Nueva Tailandia	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.435442+00	2025-11-22 04:41:42.435442+00
1cf50e1b-f755-4d5b-99fe-01ee035761e4	institution	d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f	primary	Cerrada Sur Camarillo 414 Edif. 593 , Depto. 622	\N	Vieja Saint Kitts y Nevis	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.441107+00	2025-11-22 04:41:42.441107+00
eec435e3-cf7e-4c2c-b670-7a8d395376dc	institution	ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	primary	Viaducto Norte Montoya 514 488	\N	San Teresa de la Monta??a	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.447421+00	2025-11-22 04:41:42.447421+00
cb11f4ec-acce-4c3e-b297-6f00f69888d0	institution	3cf42c93-4941-4d8d-8656-aafa9e987177	primary	Viaducto Nayarit 630 417	\N	San Jos?? Emilio de la Monta??a	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.452846+00	2025-11-22 04:41:42.452846+00
0b54f434-6479-455c-aa7e-d61f48c59398	institution	1926fa2a-dab7-420e-861b-c2b6dfe0174e	primary	Corredor Mesa 575 Edif. 643 , Depto. 142	\N	San Lilia los altos	28	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.461217+00	2025-11-22 04:41:42.461217+00
dd7f69af-4da0-40d8-bf03-396246b3a728	institution	0b2f4464-5141-44a3-a26d-f8acc1fb955e	primary	Eje vial Niger 784 Interior 669	\N	San Amalia los altos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.467604+00	2025-11-22 04:41:42.467604+00
2fcdb4f5-322a-40b8-b126-f7239c7e4c01	institution	1fec9665-52bc-49a7-b028-f0d78440463c	primary	Continuaci??n Tlaxcala 013 179	\N	San Mar??a Eugenia de la Monta??a	30	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.47248+00	2025-11-22 04:41:42.47248+00
87c89c35-5cbf-453c-91bc-05a31d26e0b6	institution	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	primary	Peatonal Hait?? 199 Interior 658	\N	San Sonia los altos	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.477069+00	2025-11-22 04:41:42.477069+00
0b4b37f4-e0c3-46f9-a6b1-282ed3db2e07	institution	8cfdeaad-c727-4a4d-b5d5-b69dd43c0854	primary	Eje vial Colima 469 Interior 815	\N	San Linda los bajos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.481747+00	2025-11-22 04:41:42.481747+00
94c68bc2-af87-4d38-a207-94ecaf00b884	institution	7a6ce151-14b5-4d12-b6bb-1fba18636353	primary	Eje vial Hern??ndez 479 Interior 552	\N	Nueva Nicaragua	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.484807+00	2025-11-22 04:41:42.484807+00
60972597-814b-4324-8d59-4ffa1181feb8	institution	f1ab98f4-98de-420f-9c4b-c31eee92df21	primary	Circunvalaci??n Norte Ulibarri 155 Edif. 654 , Depto. 697	\N	San Estefan??a de la Monta??a	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.489486+00	2025-11-22 04:41:42.489486+00
f283d532-85f2-4a90-bd7a-267785cec767	institution	a074c3ea-f255-4cf2-ae3f-727f9186be3c	primary	Retorno Campeche 452 Interior 594	\N	San Yolanda de la Monta??a	21	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.494274+00	2025-11-22 04:41:42.494274+00
da48ac89-2d43-43d8-b3e8-c2b47c8caf7e	institution	0e3821a8-80d6-4fa9-8313-3ed45b83c28b	primary	Calzada Rosas 341 Edif. 939 , Depto. 560	\N	Vieja Ecuador	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.498846+00	2025-11-22 04:41:42.498846+00
44b64326-f065-45f3-9614-f2c99237e8a8	institution	3d521bc9-692d-4a0d-a3d7-80e816b86374	primary	Avenida Norte Gamboa 704 Edif. 610 , Depto. 450	\N	Vieja Per??	18	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.502652+00	2025-11-22 04:41:42.502652+00
964fe17c-51d7-4309-a4fe-6daa436106c2	institution	47393461-e570-448b-82b1-1cef15441262	primary	Circuito Tamaulipas 731 Edif. 243 , Depto. 639	\N	San Rafa??l de la Monta??a	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.506165+00	2025-11-22 04:41:42.506165+00
2671eb7a-14a0-4c55-aa8a-d376c9b290d8	institution	744b4a03-e575-4978-b10e-6c087c9e744b	primary	Avenida San Marino 567 Interior 239	\N	Vieja Irlanda	18	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.5129+00	2025-11-22 04:41:42.5129+00
e9155cb0-224c-4a72-b5c3-a4d255a5f7b1	institution	9a18b839-1b93-44fb-9d8a-2ea12388e887	primary	Viaducto Quer??taro 024 497	\N	Vieja Canad??	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.51751+00	2025-11-22 04:41:42.51751+00
4aff8490-578d-4395-9e2b-94ac83b46d78	institution	1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	primary	Calzada Myanmar 745 Edif. 320 , Depto. 401	\N	Vieja Letonia	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.521107+00	2025-11-22 04:41:42.521107+00
1cc11ce8-3b29-478d-b26b-5a7f6ef083ef	institution	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	primary	Callej??n Burundi 277 105	\N	San Francisco Javier los bajos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.525806+00	2025-11-22 04:41:42.525806+00
ff0e75a4-6c5b-4d5d-93f2-b47ef4a5ede3	institution	eea6be20-e19f-485f-ab54-537a7c28245f	primary	Boulevard Razo 082 139	\N	Nueva Zambia	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.531043+00	2025-11-22 04:41:42.531043+00
0742debb-2217-4d6a-90e5-ffeef205df20	institution	eb602cae-423a-455d-a22e-d47aea5eb650	primary	Circunvalaci??n Baja California Sur 922 637	\N	Vieja Rep??blica Federal Democr??tica de Nepal	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.535768+00	2025-11-22 04:41:42.535768+00
fc7ca239-db85-4f47-81af-e4cea56c7d14	institution	bb17faca-a7b2-4de8-bf29-2fcb569ef554	primary	Boulevard Bangladesh 685 390	\N	Nueva Belar??s	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.54071+00	2025-11-22 04:41:42.54071+00
6d2eeb06-e877-42e1-abbd-2644eee4d667	institution	44a33aab-1a23-4995-bd07-41f95b34fd57	primary	Calle Casanova 310 Interior 988	\N	San Guadalupe los altos	32	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.547195+00	2025-11-22 04:41:42.547195+00
bff9f9dc-0eec-430f-b5b7-5bac4c10dd5b	institution	5462455f-fbe3-44c8-b0d1-0644c433aca6	primary	Ampliaci??n Orosco 714 Edif. 068 , Depto. 787	\N	San Guadalupe los altos	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.551288+00	2025-11-22 04:41:42.551288+00
053d6fc6-070c-43ba-88d3-2257ae31a99c	institution	d050617d-dc89-4f28-b546-9680dd1c5fad	primary	Ampliaci??n Sur Naranjo 780 592	\N	Vieja Hait??	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.554937+00	2025-11-22 04:41:42.554937+00
36fca767-79b7-4ce4-ad72-9dcb0861ff30	institution	7227444e-b122-48f4-8f01-2cda439507b1	primary	Continuaci??n Morelos 721 Interior 197	\N	Vieja Polonia	14	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.562129+00	2025-11-22 04:41:42.562129+00
6fb98d36-986b-48ab-b292-0caa2c1d0ef3	institution	d86c173a-8a1d-43b4-a0c1-c836afdc378b	primary	Cerrada Carrero 054 Interior 080	\N	Vieja Mongolia	29	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.566546+00	2025-11-22 04:41:42.566546+00
39933ee6-634d-4c7b-885e-0e1dd82f991a	institution	fb0a848d-4d51-4416-86bc-e568f694f9e7	primary	Calzada Tamaulipas 746 Interior 025	\N	San Elvira los bajos	29	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.57237+00	2025-11-22 04:41:42.57237+00
9763a312-b538-414e-b2c3-8b85adc02825	institution	ccccdffb-bc26-4d80-a590-0cd86dd5a1bc	primary	Cerrada Holgu??n 544 Edif. 668 , Depto. 094	\N	Vieja Jordania	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.578229+00	2025-11-22 04:41:42.578229+00
4a7c6939-56ce-4e3e-89cc-02f4c93fbfc6	institution	8cb48822-4d4c-42ed-af7f-737d3107b1db	primary	Cerrada Chihuahua 013 706	\N	Vieja Sud??n del Sur	25	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.58234+00	2025-11-22 04:41:42.58234+00
a8ed9080-18c6-4eeb-9c45-5512a507b69f	institution	700b8c76-7ad1-4453-9ce3-f598565c6452	primary	Callej??n Mireles 928 Interior 553	\N	Vieja Madagascar	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.587527+00	2025-11-22 04:41:42.587527+00
5aa6475e-47d1-4339-b85e-20ce1472bdd6	institution	d3cb7dc8-9240-4800-a1d9-bf65c5dac801	primary	Perif??rico Norte Elizondo 600 Edif. 087 , Depto. 880	\N	San Esteban de la Monta??a	27	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.593715+00	2025-11-22 04:41:42.593715+00
6b8b923c-7266-4d16-b036-4132f563eb12	institution	06c71356-e038-4c3d-bfea-7865acacb684	primary	Cerrada Sur Ju??rez 165 Interior 111	\N	Nueva Om??n	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.599971+00	2025-11-22 04:41:42.599971+00
e62994d9-51bc-477d-9517-273db7fe1091	institution	30e2b2ec-9553-454e-92a4-c1dc89609cbb	primary	Viaducto Aguascalientes 256 Edif. 771 , Depto. 122	\N	Nueva Qatar	11	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.604857+00	2025-11-22 04:41:42.604857+00
7462c044-e11f-46b5-b09f-d5750d12005d	institution	2eead5aa-095b-418a-bd02-e3a917971887	primary	Privada Baja California Sur 815 Edif. 441 , Depto. 454	\N	Nueva Cuba	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.609735+00	2025-11-22 04:41:42.609735+00
baee1ca3-5105-41e7-8251-b4043248ad53	institution	05afd7e1-bb93-4c83-90a7-48a65b6e7598	primary	Diagonal Velasco 162 665	\N	San Eduardo de la Monta??a	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.614724+00	2025-11-22 04:41:42.614724+00
e7874629-3e3a-4582-9472-6bc12ce9d2b5	institution	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	primary	Cerrada Tabasco 693 Interior 329	\N	San Hugo los bajos	\N	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.619078+00	2025-11-22 04:41:42.619078+00
e695898a-874d-42a1-a07c-a78dea592273	institution	454f4ba6-cb6d-4f27-9d76-08f5b358b484	primary	Peatonal Per?? 799 Interior 649	\N	San Mar??a Jos?? los altos	21	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.623897+00	2025-11-22 04:41:42.623897+00
d09073c6-feac-4d87-86fe-86795e31c602	institution	389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	primary	Corredor Nicaragua 738 Interior 211	\N	San Minerva los bajos	26	\N	1	\N	\N	t	t	\N	2025-11-22 04:41:42.629109+00	2025-11-22 04:41:42.629109+00
\.


--
-- Data for Name: allergies; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.allergies (id, name, description) FROM stdin;
1	Penicillin	Alergia a penicilina y derivados beta-lactámicos
2	None reported	Sin alergias conocidas reportadas
3	Sulfa Drugs	Alergia a medicamentos sulfonamida
4	NSAIDs	Alergia a antiinflamatorios no esteroideos
5	Aspirin	Alergia al ácido acetilsalicílico
6	Latex	Alergia al látex
7	Shellfish	Alergia a mariscos
8	Peanuts	Alergia a cacahuates/maní
9	Eggs	Alergia a huevos
10	Milk	Alergia a leche y productos lácteos
11	Wheat	Alergia al trigo
12	Soy	Alergia a la soja
13	Tree Nuts	Alergia a nueces de árbol
14	Fish	Alergia al pescado
15	Iodine	Alergia al yodo (contraste radiológico)
16	Local Anesthetics	Alergia a anestésicos locales
17	Codeine	Alergia a codeína y opioides
18	Tetracycline	Alergia a tetraciclina
19	Quinolones	Alergia a antibióticos quinolona
20	ACE Inhibitors	Alergia a inhibidores de la ECA
\.


--
-- Data for Name: blood_types; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.blood_types (id, name, description, can_donate_to, can_receive_from, is_active, created_at) FROM stdin;
1	A+	A positive blood type	{A+,AB+}	{A+,A-,O+,O-}	t	2025-11-22 04:17:09.89488+00
2	A-	A negative blood type	{A+,A-,AB+,AB-}	{A-,O-}	t	2025-11-22 04:17:09.89488+00
3	B+	B positive blood type	{B+,AB+}	{B+,B-,O+,O-}	t	2025-11-22 04:17:09.89488+00
4	B-	B negative blood type	{B+,B-,AB+,AB-}	{B-,O-}	t	2025-11-22 04:17:09.89488+00
5	AB+	AB positive blood type (universal recipient)	{AB+}	{A+,A-,B+,B-,AB+,AB-,O+,O-}	t	2025-11-22 04:17:09.89488+00
6	AB-	AB negative blood type	{AB+,AB-}	{A-,B-,AB-,O-}	t	2025-11-22 04:17:09.89488+00
7	O+	O positive blood type (universal donor)	{A+,B+,AB+,O+}	{O+,O-}	t	2025-11-22 04:17:09.89488+00
8	O-	O negative blood type (universal donor)	{A+,A-,B+,B-,AB+,AB-,O+,O-}	{O-}	t	2025-11-22 04:17:09.89488+00
\.


--
-- Data for Name: cms_permissions; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.cms_permissions (id, resource, action, description) FROM stdin;
1	users	create	Create new users
2	users	read	View users
3	users	update	Edit users
4	users	delete	Delete users
5	reports	view	View system reports
6	analytics	access	Access analytics dashboard
\.


--
-- Data for Name: cms_role_permissions; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.cms_role_permissions (role_id, permission_id) FROM stdin;
1	1
1	2
1	3
1	4
1	5
1	6
2	2
2	3
\.


--
-- Data for Name: cms_roles; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.cms_roles (id, name, description, is_active, created_at, updated_at) FROM stdin;
1	Admin	Full access to all CMS features	t	2025-11-22 04:17:09.958504+00	2025-11-22 04:17:09.958504+00
2	Editor	Can create and edit content but cannot delete or manage users	t	2025-11-22 04:17:09.958504+00	2025-11-22 04:17:09.958504+00
\.


--
-- Data for Name: cms_users; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.cms_users (id, email, password_hash, first_name, last_name, user_type, role_id, is_active, last_login, created_at, updated_at) FROM stdin;
1	admin.cms@predicthealth.com	$2b$12$x30MPeK6s/8k5k6LdA2FhuRTi5zqMs4G/fxZM.rmI/OpWLknBbele	Admin	CMS	admin	\N	t	\N	2025-11-22 04:17:10.349172+00	2025-11-22 04:17:10.349172+00
2	editor.cms@predicthealth.com	$2b$12$w13etTUCcAshExi34EUPRuGlDsJPS6M4lFNSGy9mcKyv8e.1VfExO	Editor	CMS	editor	\N	t	\N	2025-11-22 04:17:10.368553+00	2025-11-22 04:17:10.368553+00
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.countries (id, name, iso_code, iso_code_2, phone_code, currency_code, is_active, created_at) FROM stdin;
1	Mexico	MEX	MX	+52	MXN	t	2025-11-22 04:17:09.927776+00
3	United States	USA	US	+1	USD	t	2025-11-22 04:41:35.15479+00
4	Canada	CAN	CA	+1	CAD	t	2025-11-22 04:41:35.15479+00
\.


--
-- Data for Name: doctor_specialties; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.doctor_specialties (id, name, description, category_id, is_active, created_at) FROM stdin;
6be1c5cc-1814-4e5c-a02e-71fd63e76be6	General Medicine	General medical practice	1	t	2025-11-22 04:17:09.949956+00
f502d92e-a0b4-439e-b726-9adc0ac37fcc	Internal Medicine	Internal medicine specialist	1	t	2025-11-22 04:17:09.949956+00
7aa513de-ac6a-4565-b6cf-d127a231af94	Cardiology	Heart and cardiovascular system	2	t	2025-11-22 04:17:09.949956+00
c8066006-c4e2-45c1-bef8-b7221305efe0	Endocrinology	Hormones and metabolism	2	t	2025-11-22 04:17:09.949956+00
2caa9d93-68d2-42df-8db1-d7ac88cc225a	Diabetes Management	Diabetes care specialist	2	t	2025-11-22 04:17:09.949956+00
fc2909cf-b519-4b10-8bf9-da2d5ecc233a	Preventive Medicine	Disease prevention and health promotion	3	t	2025-11-22 04:17:09.949956+00
377c454d-f60b-4b7f-9605-67a3e4775a87	Family Medicine	Comprehensive family healthcare	1	t	2025-11-22 04:17:09.949956+00
db59756d-1491-4c76-8949-b63f1415e80a	Emergency Medicine	Emergency care specialist	4	t	2025-11-22 04:17:09.949956+00
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.doctors (id, institution_id, first_name, last_name, sex_id, gender_id, medical_license, specialty_id, years_experience, consultation_fee, created_at, updated_at, is_active, professional_status, last_login) FROM stdin;
21000000-e29b-41d4-a716-446655440001	11000000-e29b-41d4-a716-446655440001	Roberto	Sánchez	1	\N	MED-MX-2024-101	7aa513de-ac6a-4565-b6cf-d127a231af94	15	1200.00	2025-11-22 04:17:10.117322+00	2025-11-22 04:17:10.117322+00	t	active	\N
22000000-e29b-41d4-a716-446655440002	12000000-e29b-41d4-a716-446655440002	Patricia	Morales	2	\N	MED-MX-2024-102	f502d92e-a0b4-439e-b726-9adc0ac37fcc	12	950.00	2025-11-22 04:17:10.117322+00	2025-11-22 04:17:10.117322+00	t	active	\N
23000000-e29b-41d4-a716-446655440003	13000000-e29b-41d4-a716-446655440003	Fernando	Vázquez	1	\N	MED-MX-2024-103	c8066006-c4e2-45c1-bef8-b7221305efe0	18	1100.00	2025-11-22 04:17:10.117322+00	2025-11-22 04:17:10.117322+00	t	active	\N
24000000-e29b-41d4-a716-446655440004	14000000-e29b-41d4-a716-446655440004	Gabriela	Ríos	2	\N	MED-MX-2024-104	377c454d-f60b-4b7f-9605-67a3e4775a87	10	850.00	2025-11-22 04:17:10.117322+00	2025-11-22 04:17:10.117322+00	t	active	\N
25000000-e29b-41d4-a716-446655440005	15000000-e29b-41d4-a716-446655440005	Antonio	Jiménez	1	\N	MED-MX-2024-105	db59756d-1491-4c76-8949-b63f1415e80a	22	1350.00	2025-11-22 04:17:10.117322+00	2025-11-22 04:17:10.117322+00	t	active	\N
df863eba-f0b8-4b1a-bdd1-71ed2f816ed7	83b74179-f6ef-4219-bc70-c93f4393a350	Rebeca	Paredes	1	\N	MED-MX-2024-106	2caa9d93-68d2-42df-8db1-d7ac88cc225a	20	1414.44	2025-11-22 04:41:35.47599+00	2025-11-22 04:41:35.47599+00	t	active	\N
ba712fc8-c4d2-4e22-ae18-1991c46bc85d	0d826581-b9d8-4828-8848-9332fe38d169	Mario	Gaona	1	\N	MED-MX-2024-107	f502d92e-a0b4-439e-b726-9adc0ac37fcc	14	1780.55	2025-11-22 04:41:35.481146+00	2025-11-22 04:41:35.481146+00	t	active	\N
bbf715a1-3947-4642-a67a-b5c4c0c085d2	68f1a02a-d348-4d1e-99ee-733d832a3f43	Luis	Ceja	1	\N	MED-MX-2024-108	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	17	1885.37	2025-11-22 04:41:35.484389+00	2025-11-22 04:41:35.484389+00	t	active	\N
851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec	0d826581-b9d8-4828-8848-9332fe38d169	Sergio	Guevara	1	\N	MED-MX-2024-109	2caa9d93-68d2-42df-8db1-d7ac88cc225a	30	1672.31	2025-11-22 04:41:35.488121+00	2025-11-22 04:41:35.488121+00	t	active	\N
0fbbaab0-2284-4ac6-b1c9-498b5b3c4567	a074c3ea-f255-4cf2-ae3f-727f9186be3c	Natalia	Barrientos	1	\N	MED-MX-2024-110	2caa9d93-68d2-42df-8db1-d7ac88cc225a	19	1647.40	2025-11-22 04:41:35.491216+00	2025-11-22 04:41:35.491216+00	t	active	\N
b6994d45-b80e-4260-834c-facdf3ea8eee	389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	Berta	Rinc??n	1	\N	MED-MX-2024-111	2caa9d93-68d2-42df-8db1-d7ac88cc225a	13	1974.65	2025-11-22 04:41:35.497727+00	2025-11-22 04:41:35.497727+00	t	active	\N
f7cdc060-94e6-47ad-90e9-939ed86fb6da	89ab21cf-089e-4210-8e29-269dfbd38d71	Lorenzo	Rivera	2	\N	MED-MX-2024-112	377c454d-f60b-4b7f-9605-67a3e4775a87	29	916.11	2025-11-22 04:41:35.502745+00	2025-11-22 04:41:35.502745+00	t	active	\N
23785934-fbf0-442c-add3-05df84fa5d17	ad2c792b-5015-4238-b221-fa28e8b061fc	Omar	Trujillo	1	\N	MED-MX-2024-113	7aa513de-ac6a-4565-b6cf-d127a231af94	30	1832.73	2025-11-22 04:41:35.506627+00	2025-11-22 04:41:35.506627+00	t	active	\N
bf7a015c-1589-42b3-b1e8-103fcbc0b041	47393461-e570-448b-82b1-1cef15441262	Elvira	Ochoa	2	\N	MED-MX-2024-114	db59756d-1491-4c76-8949-b63f1415e80a	12	1892.72	2025-11-22 04:41:35.509875+00	2025-11-22 04:41:35.509875+00	t	active	\N
4fa9d0ff-2c51-4918-b48a-b5cb37d444a3	8fd698b3-084d-4248-a28e-2708a5862e27	Natalia	Murillo	1	\N	MED-MX-2024-115	f502d92e-a0b4-439e-b726-9adc0ac37fcc	5	1636.82	2025-11-22 04:41:35.512972+00	2025-11-22 04:41:35.512972+00	t	active	\N
93dbdfc0-e05c-4eb6-975c-360eb8d293c1	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Pedro	Vald??s	2	\N	MED-MX-2024-116	f502d92e-a0b4-439e-b726-9adc0ac37fcc	14	1298.78	2025-11-22 04:41:35.5172+00	2025-11-22 04:41:35.5172+00	t	active	\N
a6db1b41-d601-4840-99e9-3d7d18901399	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	Eugenio	Uribe	2	\N	MED-MX-2024-117	c8066006-c4e2-45c1-bef8-b7221305efe0	7	1825.66	2025-11-22 04:41:35.52098+00	2025-11-22 04:41:35.52098+00	t	active	\N
d5e98ce0-e6f8-4577-a0dd-3281aa303b32	eb602cae-423a-455d-a22e-d47aea5eb650	Linda	Trejo	2	\N	MED-MX-2024-118	7aa513de-ac6a-4565-b6cf-d127a231af94	13	741.45	2025-11-22 04:41:35.524202+00	2025-11-22 04:41:35.524202+00	t	active	\N
44da48b1-6ff6-4db9-9de5-34e22de0429a	700b8c76-7ad1-4453-9ce3-f598565c6452	Susana	Acosta	1	\N	MED-MX-2024-119	f502d92e-a0b4-439e-b726-9adc0ac37fcc	25	1864.47	2025-11-22 04:41:35.527235+00	2025-11-22 04:41:35.527235+00	t	active	\N
3fafc20d-72d5-4633-95a0-df6b9ed175b6	2eead5aa-095b-418a-bd02-e3a917971887	Rodrigo	Mota	2	\N	MED-MX-2024-120	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	6	877.37	2025-11-22 04:41:35.530435+00	2025-11-22 04:41:35.530435+00	t	active	\N
c4fac110-0b61-4fb0-943d-0d00af7ed0cd	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Linda	Maga??a	2	\N	MED-MX-2024-121	f502d92e-a0b4-439e-b726-9adc0ac37fcc	18	832.62	2025-11-22 04:41:35.533804+00	2025-11-22 04:41:35.533804+00	t	active	\N
88870e4f-1333-4bcc-8daf-c8743d61f3cb	a074c3ea-f255-4cf2-ae3f-727f9186be3c	Jos?? Luis	Rubio	2	\N	MED-MX-2024-122	2caa9d93-68d2-42df-8db1-d7ac88cc225a	16	973.88	2025-11-22 04:41:35.537054+00	2025-11-22 04:41:35.537054+00	t	active	\N
6f035f60-87f7-4a9c-9501-4b8704facba3	50503414-ca6d-4c1a-a34f-18719e2fd555	Concepci??n	Barajas	1	\N	MED-MX-2024-123	c8066006-c4e2-45c1-bef8-b7221305efe0	8	1198.26	2025-11-22 04:41:35.540163+00	2025-11-22 04:41:35.540163+00	t	active	\N
58a814d3-a275-436b-8e5c-4e743fed242f	a074c3ea-f255-4cf2-ae3f-727f9186be3c	D??bora	Delgadillo	2	\N	MED-MX-2024-124	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	21	1409.06	2025-11-22 04:41:35.543211+00	2025-11-22 04:41:35.543211+00	t	active	\N
f67c2f76-9bf1-43e4-8d0e-c0a94298f35b	5462455f-fbe3-44c8-b0d1-0644c433aca6	Augusto	Roque	1	\N	MED-MX-2024-125	2caa9d93-68d2-42df-8db1-d7ac88cc225a	29	1678.59	2025-11-22 04:41:35.546997+00	2025-11-22 04:41:35.546997+00	t	active	\N
fb4d84a0-7bc1-4815-b7a3-b1719c616c79	bb17faca-a7b2-4de8-bf29-2fcb569ef554	Francisca	Garay	1	\N	MED-MX-2024-126	2caa9d93-68d2-42df-8db1-d7ac88cc225a	20	1781.10	2025-11-22 04:41:35.550254+00	2025-11-22 04:41:35.550254+00	t	active	\N
c0bdb808-eb5f-479f-9261-dbbf9ff031a6	cc46221e-f387-463c-9d11-9464d8209f7b	Judith	Sevilla	2	\N	MED-MX-2024-127	377c454d-f60b-4b7f-9605-67a3e4775a87	14	1626.97	2025-11-22 04:41:35.553755+00	2025-11-22 04:41:35.553755+00	t	active	\N
f501d643-d308-41e0-8ffc-8bfb52d64e13	a725b15f-039b-4256-843a-51a2968633fd	Nelly	Robles	1	\N	MED-MX-2024-128	f502d92e-a0b4-439e-b726-9adc0ac37fcc	26	1234.87	2025-11-22 04:41:35.556591+00	2025-11-22 04:41:35.556591+00	t	active	\N
adeb74f6-f3dc-43a7-a841-6d24aba046ba	ad2c792b-5015-4238-b221-fa28e8b061fc	Soledad	Noriega	1	\N	MED-MX-2024-129	2caa9d93-68d2-42df-8db1-d7ac88cc225a	15	614.06	2025-11-22 04:41:35.559623+00	2025-11-22 04:41:35.559623+00	t	active	\N
dd24da99-43c7-4d6b-acc0-32fc0c237d02	d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	Silvano	Espinosa	2	\N	MED-MX-2024-130	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	20	744.19	2025-11-22 04:41:35.563015+00	2025-11-22 04:41:35.563015+00	t	active	\N
0408b031-caa3-4b7c-ae65-d05342cf5c05	8be78aaa-c408-452e-bf01-8e831ab5c63a	Fabiola	Saavedra	1	\N	MED-MX-2024-131	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	17	857.03	2025-11-22 04:41:35.566513+00	2025-11-22 04:41:35.566513+00	t	active	\N
a865edbe-d50c-4bd1-b556-ae32d9d1858c	50503414-ca6d-4c1a-a34f-18719e2fd555	Silvia	Enr??quez	2	\N	MED-MX-2024-132	db59756d-1491-4c76-8949-b63f1415e80a	7	944.96	2025-11-22 04:41:35.569676+00	2025-11-22 04:41:35.569676+00	t	active	\N
2a0aaddd-ea43-40bb-b5df-877b1b0d20f1	43dee983-676a-4e33-a6b0-f0a72f46d06c	Maximiliano	Segura	1	\N	MED-MX-2024-133	2caa9d93-68d2-42df-8db1-d7ac88cc225a	27	1874.87	2025-11-22 04:41:35.57296+00	2025-11-22 04:41:35.57296+00	t	active	\N
4754ba59-3dc1-4be2-a770-44d7c34184bc	05afd7e1-bb93-4c83-90a7-48a65b6e7598	Jos?? Mar??a	Serna	1	\N	MED-MX-2024-134	377c454d-f60b-4b7f-9605-67a3e4775a87	16	1820.90	2025-11-22 04:41:35.577494+00	2025-11-22 04:41:35.577494+00	t	active	\N
16e23379-6774-417d-8104-a8e6f4712909	ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	Eugenio	Gast??lum	2	\N	MED-MX-2024-135	2caa9d93-68d2-42df-8db1-d7ac88cc225a	17	1855.57	2025-11-22 04:41:35.582547+00	2025-11-22 04:41:35.582547+00	t	active	\N
07527c1a-efd5-45e4-a0d9-01ba5207bb2f	ad2c792b-5015-4238-b221-fa28e8b061fc	Eva	Cotto	1	\N	MED-MX-2024-136	f502d92e-a0b4-439e-b726-9adc0ac37fcc	22	1272.40	2025-11-22 04:41:35.588772+00	2025-11-22 04:41:35.588772+00	t	active	\N
c186d1ad-fcba-4f6e-acd7-86cb4c09938e	700b8c76-7ad1-4453-9ce3-f598565c6452	Indira	Ram??n	1	\N	MED-MX-2024-137	2caa9d93-68d2-42df-8db1-d7ac88cc225a	3	680.66	2025-11-22 04:41:35.59501+00	2025-11-22 04:41:35.59501+00	t	active	\N
4cecebec-e16f-4949-a18b-8bfebae86618	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Patricia	Angulo	2	\N	MED-MX-2024-138	db59756d-1491-4c76-8949-b63f1415e80a	15	1658.52	2025-11-22 04:41:35.598766+00	2025-11-22 04:41:35.598766+00	t	active	\N
6d21a37a-43d8-440b-bc64-87bb0ae1d45d	46af545e-6db8-44ba-a7f9-9fd9617f4a09	Helena	Valladares	2	\N	MED-MX-2024-139	2caa9d93-68d2-42df-8db1-d7ac88cc225a	26	697.99	2025-11-22 04:41:35.602908+00	2025-11-22 04:41:35.602908+00	t	active	\N
4d75aae7-5d33-44ad-a297-a32ff407415d	0e3821a8-80d6-4fa9-8313-3ed45b83c28b	Rub??n	Pacheco	2	\N	MED-MX-2024-140	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	29	1120.37	2025-11-22 04:41:35.60614+00	2025-11-22 04:41:35.60614+00	t	active	\N
e901dbc1-3eed-4e5e-b23c-58d808477e33	ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	Samuel	Garibay	1	\N	MED-MX-2024-141	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	12	757.93	2025-11-22 04:41:35.609444+00	2025-11-22 04:41:35.609444+00	t	active	\N
61bb20b9-7520-42be-accf-743c84a0b934	8cb48822-4d4c-42ed-af7f-737d3107b1db	Joaqu??n	Vigil	1	\N	MED-MX-2024-142	2caa9d93-68d2-42df-8db1-d7ac88cc225a	14	648.18	2025-11-22 04:41:35.612622+00	2025-11-22 04:41:35.612622+00	t	active	\N
b5a04df6-baea-460f-a946-f7b7606c9982	d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	Amador	Arenas	2	\N	MED-MX-2024-143	7aa513de-ac6a-4565-b6cf-d127a231af94	17	1537.66	2025-11-22 04:41:35.615982+00	2025-11-22 04:41:35.615982+00	t	active	\N
c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	8fb0899c-732e-4f03-8209-d52ef41a6a76	Felipe	Hidalgo	1	\N	MED-MX-2024-144	7aa513de-ac6a-4565-b6cf-d127a231af94	7	1248.49	2025-11-22 04:41:35.619001+00	2025-11-22 04:41:35.619001+00	t	active	\N
0b238725-a392-4fbb-956b-0f71e15bc6da	700b8c76-7ad1-4453-9ce3-f598565c6452	Mar??a Teresa	Baca	1	\N	MED-MX-2024-145	2caa9d93-68d2-42df-8db1-d7ac88cc225a	24	1022.84	2025-11-22 04:41:35.621884+00	2025-11-22 04:41:35.621884+00	t	active	\N
63ec3e7d-b8e4-4988-9bc3-5b655f830e31	7227444e-b122-48f4-8f01-2cda439507b1	Miguel ??ngel	P??rez	1	\N	MED-MX-2024-146	f502d92e-a0b4-439e-b726-9adc0ac37fcc	28	1371.05	2025-11-22 04:41:35.624745+00	2025-11-22 04:41:35.624745+00	t	active	\N
d4df85ce-6d2b-46c9-b9cd-48b2490b3c88	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Jon??s	Madera	1	\N	MED-MX-2024-147	377c454d-f60b-4b7f-9605-67a3e4775a87	23	1660.90	2025-11-22 04:41:35.628212+00	2025-11-22 04:41:35.628212+00	t	active	\N
71618fe0-25a1-4281-98af-51797de3ae0a	33ba98b9-c46a-47c1-b266-d8a4fe557290	Arcelia	de la Rosa	1	\N	MED-MX-2024-148	c8066006-c4e2-45c1-bef8-b7221305efe0	6	1875.07	2025-11-22 04:41:35.632065+00	2025-11-22 04:41:35.632065+00	t	active	\N
389524b6-608c-4b31-affa-305b79635816	7227444e-b122-48f4-8f01-2cda439507b1	Esther	Echeverr??a	2	\N	MED-MX-2024-149	2caa9d93-68d2-42df-8db1-d7ac88cc225a	5	1393.81	2025-11-22 04:41:35.636184+00	2025-11-22 04:41:35.636184+00	t	active	\N
c0356e82-1510-4557-b654-cf84ac13f425	ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	Sof??a	Montez	1	\N	MED-MX-2024-150	f502d92e-a0b4-439e-b726-9adc0ac37fcc	12	634.12	2025-11-22 04:41:35.639416+00	2025-11-22 04:41:35.639416+00	t	active	\N
ce44b08f-7dae-4844-ae53-e01ac2f28f45	36983990-abe8-4f1c-9c1b-863b9cab3ca9	D??bora	Segura	2	\N	MED-MX-2024-151	c8066006-c4e2-45c1-bef8-b7221305efe0	6	901.19	2025-11-22 04:41:35.642555+00	2025-11-22 04:41:35.642555+00	t	active	\N
9c9838c2-4464-4fbb-bc22-8f4ac64b4efe	f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	Luis Miguel	Villarreal	1	\N	MED-MX-2024-152	2caa9d93-68d2-42df-8db1-d7ac88cc225a	30	1214.42	2025-11-22 04:41:35.646273+00	2025-11-22 04:41:35.646273+00	t	active	\N
e8db5b49-5605-41e5-91f2-d456b68c5ade	373769ab-b720-4269-bfb9-02546401ce99	Esmeralda	Parra	1	\N	MED-MX-2024-153	2caa9d93-68d2-42df-8db1-d7ac88cc225a	30	1387.67	2025-11-22 04:41:35.650684+00	2025-11-22 04:41:35.650684+00	t	active	\N
96d6da02-ca2f-4ace-b239-4584544e8230	d471d2d1-66a1-4de0-8754-127059786888	Patricia	T??llez	2	\N	MED-MX-2024-154	377c454d-f60b-4b7f-9605-67a3e4775a87	19	1152.62	2025-11-22 04:41:35.653975+00	2025-11-22 04:41:35.653975+00	t	active	\N
38bf2ce6-5014-4bc1-8e32-9b9257eea501	373769ab-b720-4269-bfb9-02546401ce99	Timoteo	Tafoya	1	\N	MED-MX-2024-155	377c454d-f60b-4b7f-9605-67a3e4775a87	26	1812.87	2025-11-22 04:41:35.657306+00	2025-11-22 04:41:35.657306+00	t	active	\N
e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c	f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	Amanda	Ferrer	1	\N	MED-MX-2024-156	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	20	1872.65	2025-11-22 04:41:35.660777+00	2025-11-22 04:41:35.660777+00	t	active	\N
8ce8b684-8f8d-4828-987d-389dfe64afd1	5da54d5d-de0c-4277-a43e-6a89f987e77c	Caridad	Villa	1	\N	MED-MX-2024-157	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	12	1196.96	2025-11-22 04:41:35.664109+00	2025-11-22 04:41:35.664109+00	t	active	\N
ca8bf565-35d3-40f3-b741-603201f6f072	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	H??ctor	Castro	2	\N	MED-MX-2024-158	7aa513de-ac6a-4565-b6cf-d127a231af94	30	891.62	2025-11-22 04:41:35.668972+00	2025-11-22 04:41:35.668972+00	t	active	\N
2937cc2f-22b7-4488-b9f8-a0795800a840	16b25a77-b84a-44ac-8540-c5bfa9b3b6b0	Abraham	Rodarte	1	\N	MED-MX-2024-159	377c454d-f60b-4b7f-9605-67a3e4775a87	2	825.92	2025-11-22 04:41:35.672989+00	2025-11-22 04:41:35.672989+00	t	active	\N
f8a511e3-b97b-4d17-8240-46520497ef7c	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	Gloria	Briones	2	\N	MED-MX-2024-160	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	4	1758.28	2025-11-22 04:41:35.677613+00	2025-11-22 04:41:35.677613+00	t	active	\N
879bcb9a-8520-4d02-b12b-ba5afa629d41	1926fa2a-dab7-420e-861b-c2b6dfe0174e	Jos?? Luis	Bahena	1	\N	MED-MX-2024-161	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	28	820.51	2025-11-22 04:41:35.681651+00	2025-11-22 04:41:35.681651+00	t	active	\N
7817761a-e7c5-47cb-a260-7e243c11ef2f	b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	Daniela	Laboy	2	\N	MED-MX-2024-162	377c454d-f60b-4b7f-9605-67a3e4775a87	30	507.88	2025-11-22 04:41:35.6846+00	2025-11-22 04:41:35.6846+00	t	active	\N
48384f36-0b57-4943-899f-cbffd4ec37b6	9b581d3c-9e93-4f39-80bb-294752065866	Bruno	Ledesma	2	\N	MED-MX-2024-163	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	13	528.55	2025-11-22 04:41:35.687396+00	2025-11-22 04:41:35.687396+00	t	active	\N
0fc70684-777f-43eb-895d-9cb90ce0f584	a15d4a4b-1bc4-4ee5-a168-714f71d94e42	Noelia	Garica	2	\N	MED-MX-2024-164	2caa9d93-68d2-42df-8db1-d7ac88cc225a	29	1697.10	2025-11-22 04:41:35.69038+00	2025-11-22 04:41:35.69038+00	t	active	\N
a849f14b-3741-4e38-9dfb-6cc7d46265e8	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Mitzy	Godoy	1	\N	MED-MX-2024-165	377c454d-f60b-4b7f-9605-67a3e4775a87	4	1814.12	2025-11-22 04:41:35.693434+00	2025-11-22 04:41:35.693434+00	t	active	\N
22128ae9-ba6e-4e99-821a-dc445e76d641	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	Sessa	Medina	2	\N	MED-MX-2024-166	7aa513de-ac6a-4565-b6cf-d127a231af94	9	1929.14	2025-11-22 04:41:35.696977+00	2025-11-22 04:41:35.696977+00	t	active	\N
6c711a31-c752-44f2-b6cb-480f9bf6af1f	30e2b2ec-9553-454e-92a4-c1dc89609cbb	Mitzy	Aguayo	2	\N	MED-MX-2024-167	c8066006-c4e2-45c1-bef8-b7221305efe0	4	1203.76	2025-11-22 04:41:35.699988+00	2025-11-22 04:41:35.699988+00	t	active	\N
ab923e2e-5d13-41e4-9c73-2f62cca0699d	4bfa1a0a-0434-45e0-b454-03140b992f53	Patricio	Monroy	1	\N	MED-MX-2024-168	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	21	1859.79	2025-11-22 04:41:35.702782+00	2025-11-22 04:41:35.702782+00	t	active	\N
a7f19796-4c62-4a2b-82de-7c2677804e6a	3d7c5771-0692-4a2f-a4c6-6af2b561282b	Homero	Valent??n	2	\N	MED-MX-2024-169	f502d92e-a0b4-439e-b726-9adc0ac37fcc	2	1371.46	2025-11-22 04:41:35.705533+00	2025-11-22 04:41:35.705533+00	t	active	\N
28958f29-28c6-405a-acf5-949ffcaec286	c9014e88-309c-4cb0-a28d-25b510e1e522	Porfirio	Far??as	1	\N	MED-MX-2024-170	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	2	1259.86	2025-11-22 04:41:35.708976+00	2025-11-22 04:41:35.708976+00	t	active	\N
472116b5-933e-4f63-b3ca-e8c8f5d30bb4	f4764cd3-47e9-4408-b0ee-9b9001c5459d	Gonzalo	Cort??s	2	\N	MED-MX-2024-171	c8066006-c4e2-45c1-bef8-b7221305efe0	15	827.53	2025-11-22 04:41:35.712257+00	2025-11-22 04:41:35.712257+00	t	active	\N
a2beaa02-c033-4e45-b702-305d5ce41e34	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	Marisol	Tello	1	\N	MED-MX-2024-172	7aa513de-ac6a-4565-b6cf-d127a231af94	17	1962.81	2025-11-22 04:41:35.715262+00	2025-11-22 04:41:35.715262+00	t	active	\N
5879ec30-c291-476d-a48c-284fadf5f98a	8be78aaa-c408-452e-bf01-8e831ab5c63a	Mateo	Serrato	1	\N	MED-MX-2024-173	377c454d-f60b-4b7f-9605-67a3e4775a87	27	674.27	2025-11-22 04:41:35.718219+00	2025-11-22 04:41:35.718219+00	t	active	\N
d512bd88-12a3-45f9-85e8-14fb3cb5a6e1	f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	Reina	Camacho	2	\N	MED-MX-2024-174	2caa9d93-68d2-42df-8db1-d7ac88cc225a	19	1833.46	2025-11-22 04:41:35.72105+00	2025-11-22 04:41:35.72105+00	t	active	\N
757d6edf-5aa8-461b-ac4f-9e8365017424	7227444e-b122-48f4-8f01-2cda439507b1	Homero	Rodarte	2	\N	MED-MX-2024-175	c8066006-c4e2-45c1-bef8-b7221305efe0	7	1374.17	2025-11-22 04:41:35.724046+00	2025-11-22 04:41:35.724046+00	t	active	\N
c0d54a00-2ee9-4827-a7fb-6196ef15bdee	66e6aa6c-596c-442e-85fb-b143875d0dfc	Mart??n	Trevi??o	1	\N	MED-MX-2024-176	7aa513de-ac6a-4565-b6cf-d127a231af94	30	1365.07	2025-11-22 04:41:35.727279+00	2025-11-22 04:41:35.727279+00	t	active	\N
a7ada88a-7935-4dd5-8a4f-935c4b7c0bab	0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d	Wilfrido	Salazar	2	\N	MED-MX-2024-177	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	10	754.32	2025-11-22 04:41:35.730665+00	2025-11-22 04:41:35.730665+00	t	active	\N
4664d394-c950-4dbf-9b40-7b34c6d6dabb	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	Uriel	Vel??zquez	1	\N	MED-MX-2024-178	377c454d-f60b-4b7f-9605-67a3e4775a87	20	616.02	2025-11-22 04:41:35.733537+00	2025-11-22 04:41:35.733537+00	t	active	\N
c16b254c-dcf7-4a31-a101-1ed86b62477e	36983990-abe8-4f1c-9c1b-863b9cab3ca9	Jos	Briones	2	\N	MED-MX-2024-179	7aa513de-ac6a-4565-b6cf-d127a231af94	12	1127.82	2025-11-22 04:41:35.736231+00	2025-11-22 04:41:35.736231+00	t	active	\N
e0926c16-7f63-41ae-a091-1d0688c88322	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	David	Dom??nguez	2	\N	MED-MX-2024-180	c8066006-c4e2-45c1-bef8-b7221305efe0	28	1258.29	2025-11-22 04:41:35.739155+00	2025-11-22 04:41:35.739155+00	t	active	\N
250b33c9-1ba3-44e6-9c35-cde7000d6d53	c0595f94-c8f4-413c-a05c-7cfca773563c	Ad??n	Ferrer	2	\N	MED-MX-2024-181	377c454d-f60b-4b7f-9605-67a3e4775a87	5	818.21	2025-11-22 04:41:35.742318+00	2025-11-22 04:41:35.742318+00	t	active	\N
b6c86aef-75e2-4c64-bceb-e7de898b5a1b	1fec9665-52bc-49a7-b028-f0d78440463c	Irene	Cisneros	1	\N	MED-MX-2024-182	2caa9d93-68d2-42df-8db1-d7ac88cc225a	16	674.69	2025-11-22 04:41:35.745806+00	2025-11-22 04:41:35.745806+00	t	active	\N
a3fb2dae-2a69-434f-86a9-65ae48c8f690	89ab21cf-089e-4210-8e29-269dfbd38d71	Alta  Gracia	Orellana	1	\N	MED-MX-2024-183	377c454d-f60b-4b7f-9605-67a3e4775a87	9	1767.89	2025-11-22 04:41:35.748749+00	2025-11-22 04:41:35.748749+00	t	active	\N
820c1228-3d2d-4766-900f-32940f14e74b	9c8636c9-015b-4c18-a641-f5da698b6fd8	Cristal	Balderas	2	\N	MED-MX-2024-184	7aa513de-ac6a-4565-b6cf-d127a231af94	11	1500.67	2025-11-22 04:41:35.75167+00	2025-11-22 04:41:35.75167+00	t	active	\N
da3dbacf-8df0-46cf-bbef-b51615063a9b	89ab21cf-089e-4210-8e29-269dfbd38d71	Marisol	Ulloa	1	\N	MED-MX-2024-185	377c454d-f60b-4b7f-9605-67a3e4775a87	27	609.92	2025-11-22 04:41:35.754552+00	2025-11-22 04:41:35.754552+00	t	active	\N
e6ce6823-6c4d-4ead-98d7-78b94483fe2c	fb0a848d-4d51-4416-86bc-e568f694f9e7	Alfonso	Cazares	2	\N	MED-MX-2024-186	377c454d-f60b-4b7f-9605-67a3e4775a87	3	508.10	2025-11-22 04:41:35.757784+00	2025-11-22 04:41:35.757784+00	t	active	\N
84cb6703-edfc-4180-9f80-619064c9684e	ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	Elisa	Oquendo	1	\N	MED-MX-2024-187	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	3	1404.85	2025-11-22 04:41:35.761256+00	2025-11-22 04:41:35.761256+00	t	active	\N
21e4d7a9-73dc-4156-b413-b389c2e92a0d	163749fb-8b46-4447-a8b7-95b4a59531b6	Silvano	Brito	2	\N	MED-MX-2024-188	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	1	745.48	2025-11-22 04:41:35.76408+00	2025-11-22 04:41:35.76408+00	t	active	\N
85eb8041-b502-4b90-b586-c7c4593b5347	cc46221e-f387-463c-9d11-9464d8209f7b	??rsula	Casares	2	\N	MED-MX-2024-189	2caa9d93-68d2-42df-8db1-d7ac88cc225a	4	1103.24	2025-11-22 04:41:35.766822+00	2025-11-22 04:41:35.766822+00	t	active	\N
c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9	fb0a848d-4d51-4416-86bc-e568f694f9e7	Marcela	Corona	2	\N	MED-MX-2024-190	f502d92e-a0b4-439e-b726-9adc0ac37fcc	3	622.59	2025-11-22 04:41:35.77029+00	2025-11-22 04:41:35.77029+00	t	active	\N
22d570dd-a72e-4599-8f13-df952d35d616	a5b1202a-9112-404b-b7de-ddf0f62711f8	Catalina	Orta	1	\N	MED-MX-2024-191	f502d92e-a0b4-439e-b726-9adc0ac37fcc	24	1502.19	2025-11-22 04:41:35.773457+00	2025-11-22 04:41:35.773457+00	t	active	\N
04a9b2e7-638b-4fe0-a106-16b582d946ab	cc46221e-f387-463c-9d11-9464d8209f7b	Ren??	Morales	1	\N	MED-MX-2024-192	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	12	1098.58	2025-11-22 04:41:35.777868+00	2025-11-22 04:41:35.777868+00	t	active	\N
03e547d1-325a-46ea-bc94-c188abf53f0f	1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	Benjam??n	Leal	1	\N	MED-MX-2024-193	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	27	1300.89	2025-11-22 04:41:35.783864+00	2025-11-22 04:41:35.783864+00	t	active	\N
5a6de593-99b5-4942-a379-fd21b2a4999f	744b4a03-e575-4978-b10e-6c087c9e744b	Catalina	Alarc??n	2	\N	MED-MX-2024-194	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	24	1866.11	2025-11-22 04:41:35.788536+00	2025-11-22 04:41:35.788536+00	t	active	\N
b7dd043b-953f-4e04-8a80-1c613d3c6675	8be78aaa-c408-452e-bf01-8e831ab5c63a	Pedro	Riojas	1	\N	MED-MX-2024-195	db59756d-1491-4c76-8949-b63f1415e80a	17	531.71	2025-11-22 04:41:35.79276+00	2025-11-22 04:41:35.79276+00	t	active	\N
852beb97-3c99-4391-879f-98f0c2154c20	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	Olivia	Nieto	2	\N	MED-MX-2024-196	7aa513de-ac6a-4565-b6cf-d127a231af94	12	957.57	2025-11-22 04:41:35.796975+00	2025-11-22 04:41:35.796975+00	t	active	\N
86bb4262-7a96-444b-a096-d3a1bd7782e7	8cb48822-4d4c-42ed-af7f-737d3107b1db	Victoria	Corona	1	\N	MED-MX-2024-197	6be1c5cc-1814-4e5c-a02e-71fd63e76be6	8	616.93	2025-11-22 04:41:35.801597+00	2025-11-22 04:41:35.801597+00	t	active	\N
b441c98a-1075-4013-9fc2-9242d910713f	a670c73c-cc47-42fe-88c9-0fa37359779b	Daniela	Gallegos	1	\N	MED-MX-2024-198	fc2909cf-b519-4b10-8bf9-da2d5ecc233a	9	1952.60	2025-11-22 04:41:35.805812+00	2025-11-22 04:41:35.805812+00	t	active	\N
77486cf8-54d8-4120-856f-642ebae74d48	d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f	Victoria	Urbina	1	\N	MED-MX-2024-199	c8066006-c4e2-45c1-bef8-b7221305efe0	2	1771.21	2025-11-22 04:41:35.810092+00	2025-11-22 04:41:35.810092+00	t	active	\N
0e2fa589-05b2-402c-9722-1022a0121b04	44a33aab-1a23-4995-bd07-41f95b34fd57	Leonardo	Aguirre	2	\N	MED-MX-2024-200	377c454d-f60b-4b7f-9605-67a3e4775a87	29	512.37	2025-11-22 04:41:35.813826+00	2025-11-22 04:41:35.813826+00	t	active	\N
\.


--
-- Data for Name: email_types; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.email_types (id, name, description, is_active, created_at) FROM stdin;
1	primary	Primary contact email address	t	2025-11-22 04:17:09.902058+00
2	secondary	Secondary contact email address	t	2025-11-22 04:17:09.902058+00
3	work	Work-related email address	t	2025-11-22 04:17:09.902058+00
4	personal	Personal email address	t	2025-11-22 04:17:09.902058+00
5	notification	Email for system notifications	t	2025-11-22 04:17:09.902058+00
6	billing	Email for billing and financial communications	t	2025-11-22 04:17:09.902058+00
\.


--
-- Data for Name: emails; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.emails (id, entity_type, entity_id, email_type_id, email_address, is_primary, is_verified, verification_token, verification_expires_at, verification_attempts, last_verification_attempt, created_at, updated_at) FROM stdin;
58ce3b39-bd5a-42cb-a99a-07ea6361d7b3	institution	11000000-e29b-41d4-a716-446655440001	1	institucion1@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:09.981671+00	2025-11-22 04:17:09.981671+00
1e7bb5e1-f5b0-427e-9524-7bfe99da3e28	institution	12000000-e29b-41d4-a716-446655440002	1	institucion2@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:09.991778+00	2025-11-22 04:17:09.991778+00
655e2062-01e3-4953-96c3-9eeffd7e3fdf	institution	13000000-e29b-41d4-a716-446655440003	1	institucion3@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:09.996643+00	2025-11-22 04:17:09.996643+00
3f01cd5d-4cfd-4c94-86fe-b1742d436b54	institution	14000000-e29b-41d4-a716-446655440004	1	institucion4@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.016742+00	2025-11-22 04:17:10.016742+00
85a6f9a3-5f55-4e0d-9b82-077e01bc7d93	institution	15000000-e29b-41d4-a716-446655440005	1	institucion5@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.022748+00	2025-11-22 04:17:10.022748+00
933cc7a7-12bc-418c-b155-ac29992249a9	doctor	21000000-e29b-41d4-a716-446655440001	1	doctor1@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.130625+00	2025-11-22 04:17:10.130625+00
f6464dba-c1a5-49d3-8130-05d291bde690	doctor	22000000-e29b-41d4-a716-446655440002	1	doctor2@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.137244+00	2025-11-22 04:17:10.137244+00
fdefd9e1-5bf9-4006-bbfa-4078520fda8e	doctor	23000000-e29b-41d4-a716-446655440003	1	doctor3@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.142702+00	2025-11-22 04:17:10.142702+00
a7111a39-70ef-498a-8e9c-e9c084172da9	doctor	24000000-e29b-41d4-a716-446655440004	1	doctor4@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.149188+00	2025-11-22 04:17:10.149188+00
2fc879c9-24aa-4d58-bc69-9199def69a52	doctor	25000000-e29b-41d4-a716-446655440005	1	doctor5@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.152974+00	2025-11-22 04:17:10.152974+00
56d877e7-3701-4601-853d-42dbc4a900c7	patient	31000000-e29b-41d4-a716-446655440001	1	paciente1@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.17824+00	2025-11-22 04:17:10.17824+00
5cf0336b-0601-4855-863f-af6232765fb2	patient	32000000-e29b-41d4-a716-446655440002	1	paciente2@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.183648+00	2025-11-22 04:17:10.183648+00
a38e7a64-b0b1-4ec7-b658-f033899902d1	patient	33000000-e29b-41d4-a716-446655440003	1	paciente3@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.188228+00	2025-11-22 04:17:10.188228+00
f4641a14-b146-49b6-9cc0-a758b64a8fdf	patient	34000000-e29b-41d4-a716-446655440004	1	paciente4@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.194173+00	2025-11-22 04:17:10.194173+00
df2a18f4-ed23-4a41-a49c-37795212cc34	patient	35000000-e29b-41d4-a716-446655440005	1	paciente5@test.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:17:10.198245+00	2025-11-22 04:17:10.198245+00
dde257a0-1850-42d5-8f7c-a0e43762e916	institution	163749fb-8b46-4447-a8b7-95b4a59531b6	1	contacto@despacho-grijalva-mascarenas-y-parra.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.788477+00	2025-11-22 04:41:37.788477+00
2aa566e4-8649-41ab-af39-793287215137	institution	83b74179-f6ef-4219-bc70-c93f4393a350	1	contacto@laboratorios-saldivar-santillan-y-villanueva.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.793912+00	2025-11-22 04:41:37.793912+00
a303a9ac-3412-4107-8b61-8b4e44ca786b	institution	50503414-ca6d-4c1a-a34f-18719e2fd555	1	contacto@trejo-vigil-e-hijos.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.796942+00	2025-11-22 04:41:37.796942+00
456c3ed6-7a90-449e-8d03-6a0cfbc63235	institution	9b581d3c-9e93-4f39-80bb-294752065866	1	contacto@club-barajas-del-valle-y-carrero.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.80036+00	2025-11-22 04:41:37.80036+00
8a59feac-a2b9-4f80-aebe-7c16c59758c6	institution	e0e34926-8d48-4db0-afb9-b20b6eeb1ecb	1	contacto@collazo-barrientos.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.803462+00	2025-11-22 04:41:37.803462+00
09b7bac5-6792-4764-ae70-2fc8c2eaf289	institution	81941e1d-820a-4313-8177-e44278d9a981	1	contacto@corporacin-prado-davila-y-noriega.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.806879+00	2025-11-22 04:41:37.806879+00
8de8dcb9-3812-41d7-bcef-2624af814e1f	institution	a725b15f-039b-4256-843a-51a2968633fd	1	contacto@corporacin-navarro-collado.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.809947+00	2025-11-22 04:41:37.809947+00
545909d2-6dde-4b19-bc14-d726bdd0cb69	institution	0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d	1	contacto@iglesias-soria-y-chacon.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.812848+00	2025-11-22 04:41:37.812848+00
e6c08805-bb03-4fb6-aa19-acec53dd58da	institution	d471d2d1-66a1-4de0-8754-127059786888	1	contacto@castillo-zayas.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.815672+00	2025-11-22 04:41:37.815672+00
6392e8f7-e5c3-4fa9-8d11-0a36ecc2c8ab	institution	8fd698b3-084d-4248-a28e-2708a5862e27	1	contacto@club-mesa-y-riojas.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.818615+00	2025-11-22 04:41:37.818615+00
3a7d3b3f-a9e6-4dc5-8438-3ab8e016a9cf	institution	7b96a7bb-041f-4331-be05-e97cab7dafc0	1	contacto@ojeda-y-baca-s-r-l-de-c-v.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.821805+00	2025-11-22 04:41:37.821805+00
848b7547-184d-4e01-b87c-8feb5c4f35da	institution	5da54d5d-de0c-4277-a43e-6a89f987e77c	1	contacto@murillo-y-quintanilla-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.824997+00	2025-11-22 04:41:37.824997+00
b11180d6-b6e5-49d3-aa93-4e4be9f6afe5	institution	c9014e88-309c-4cb0-a28d-25b510e1e522	1	contacto@grupo-collazo-hinojosa-y-valdes.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.827962+00	2025-11-22 04:41:37.827962+00
a3b06e17-9457-4aec-906c-927338c8960c	institution	8e889f63-2c86-44ab-959f-fdc365353d5d	1	contacto@club-verdugo-y-tejeda.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.830746+00	2025-11-22 04:41:37.830746+00
dd46f7c0-68db-4cde-a1bf-2c8bc4c8748c	institution	67787f7c-fdee-4e30-80bd-89008ebfe419	1	contacto@zaragoza-e-hijos.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.834194+00	2025-11-22 04:41:37.834194+00
46182b12-0800-4bd5-9a09-b4eabc8b5563	institution	4721cb90-8fb0-4fd6-b19e-160b4ac0c744	1	contacto@ceballos-tello.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.837248+00	2025-11-22 04:41:37.837248+00
9c87fd37-8a39-4e17-b206-d369d18b40bd	institution	09c54a60-6267-4439-9c8b-8c9012842942	1	contacto@banuelos-e-hijos.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.84032+00	2025-11-22 04:41:37.84032+00
26e44959-35b4-42ab-9eb9-aebb47dbbc0d	institution	a670c73c-cc47-42fe-88c9-0fa37359779b	1	contacto@despacho-jaramillo-salas-y-carrero.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.843833+00	2025-11-22 04:41:37.843833+00
61714fb3-9acd-41b1-859e-1403af4ed356	institution	373769ab-b720-4269-bfb9-02546401ce99	1	contacto@paez-navarro-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.846874+00	2025-11-22 04:41:37.846874+00
cdae73a7-21cd-4835-807a-d3e68fcfb5c3	institution	ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	1	contacto@proyectos-mata-y-jurado.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.849847+00	2025-11-22 04:41:37.849847+00
fc908071-b723-4d5b-8040-9e1cf7b4b5dd	institution	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	1	contacto@laboratorios-trejo-garcia-y-lucero.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.852818+00	2025-11-22 04:41:37.852818+00
dccd5703-984f-4353-a292-e5c2948bf032	institution	6c287a0e-9d4c-4574-932f-7d499aa4146c	1	contacto@industrias-valverde-y-leal.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.85592+00	2025-11-22 04:41:37.85592+00
174e2565-ffb4-4cea-9e28-0a321fb6b085	institution	a14c189c-ee90-4c29-b465-63d43a9d0010	1	contacto@castillo-lugo-y-zamora.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.859184+00	2025-11-22 04:41:37.859184+00
14e3d8d0-70aa-4912-9518-7f524e55015a	institution	e040eabc-0ac9-47f7-89ae-24246e1c12dd	1	contacto@montenegro-alcala-y-nieves.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.862226+00	2025-11-22 04:41:37.862226+00
94d775c3-7fd2-4a9e-8aba-b17990206fc5	institution	9c8636c9-015b-4c18-a641-f5da698b6fd8	1	contacto@montenegro-y-pichardo-s-a-de-c-v.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.864971+00	2025-11-22 04:41:37.864971+00
c3db7c7e-d623-4e78-adbc-2e3391e8d0a7	institution	b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	1	contacto@lucio-marrero-y-asociados.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.86788+00	2025-11-22 04:41:37.86788+00
b0a057ee-ffcc-438d-b1fb-a39b5022e5cb	institution	146a692b-6d46-4c26-a165-092fe771400e	1	contacto@proyectos-iglesias-verdugo.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.87086+00	2025-11-22 04:41:37.87086+00
1d35e873-acd1-4010-a574-010d4d1ab42b	institution	6297ae0f-7fee-472d-87ec-e22b87ce6ffb	1	contacto@duenas-esquivel-s-r-l-de-c-v.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.874478+00	2025-11-22 04:41:37.874478+00
da3f322d-7d6c-41c9-8194-df16fc765f97	institution	66e6aa6c-596c-442e-85fb-b143875d0dfc	1	contacto@valencia-toro.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.877455+00	2025-11-22 04:41:37.877455+00
97ff76b7-ce8d-4103-8cf7-b291591056bc	institution	46af545e-6db8-44ba-a7f9-9fd9617f4a09	1	contacto@solano-rodrigez.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.880262+00	2025-11-22 04:41:37.880262+00
39405616-ce1e-48ec-a848-566af06963cc	institution	a56b6787-94e9-49f0-8b3a-6ff5979773fc	1	contacto@laboratorios-vasquez-zepeda.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.883206+00	2025-11-22 04:41:37.883206+00
96aa94b5-0617-4142-b128-a5353a5b6c81	institution	d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	1	contacto@club-montanez-almaraz.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.886119+00	2025-11-22 04:41:37.886119+00
92a254cb-68ba-44d7-9873-df751dfb352e	institution	4bfa1a0a-0434-45e0-b454-03140b992f53	1	contacto@proyectos-alvarez-godinez-y-estevez.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.88926+00	2025-11-22 04:41:37.88926+00
4c39ce90-9fe6-4c15-a875-56993aff0dca	institution	33ba98b9-c46a-47c1-b266-d8a4fe557290	1	contacto@grupo-carvajal-murillo-y-regalado.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.892567+00	2025-11-22 04:41:37.892567+00
7e9c3fe1-10d9-4511-975e-2bda5767cfe5	institution	f4764cd3-47e9-4408-b0ee-9b9001c5459d	1	contacto@industrias-bahena-nieto-y-acosta.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.895467+00	2025-11-22 04:41:37.895467+00
ce2940d7-8694-4ee4-a442-7b71a01aa13c	institution	f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8	1	contacto@villagomez-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.89845+00	2025-11-22 04:41:37.89845+00
fd153afd-62c5-44f7-9abe-70906c584ed0	institution	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	1	contacto@lucero-fajardo-e-hijos.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.901746+00	2025-11-22 04:41:37.901746+00
1331a894-6e66-4600-a30b-8c900516421c	institution	8be78aaa-c408-452e-bf01-8e831ab5c63a	1	contacto@laboratorios-arellano-rosas.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.90729+00	2025-11-22 04:41:37.90729+00
7a417d1a-1715-47e0-b90d-c794ec9df250	institution	8fb0899c-732e-4f03-8209-d52ef41a6a76	1	contacto@alba-casas.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.911952+00	2025-11-22 04:41:37.911952+00
1369aec7-d71b-47dc-9e7d-72bba387b649	institution	3a9084e7-74c5-4e0b-b786-2c93d9cd39ee	1	contacto@club-zambrano-arredondo-y-guerra.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.915703+00	2025-11-22 04:41:37.915703+00
ecb71c80-1d8f-4554-95e6-6e06dfa36963	institution	54481b92-e5f5-421b-ba21-89bf520a2d87	1	contacto@club-ballesteros-cornejo.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.918796+00	2025-11-22 04:41:37.918796+00
eb4a08ce-66a1-41b9-8239-f2db00829d30	institution	68f1a02a-d348-4d1e-99ee-733d832a3f43	1	contacto@espinoza-y-villegas-a-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.923955+00	2025-11-22 04:41:37.923955+00
40ced8ad-abfc-424d-835e-d47b617aa142	institution	36983990-abe8-4f1c-9c1b-863b9cab3ca9	1	contacto@alfaro-pacheco-y-villalpando.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.927175+00	2025-11-22 04:41:37.927175+00
e4f0537e-857b-4d4a-8496-cf1f62abb400	institution	b654860f-ec74-42d6-955e-eeedde2df0dd	1	contacto@grupo-ibarra-y-elizondo.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.930445+00	2025-11-22 04:41:37.930445+00
76875d2d-ca0a-4064-8534-f31882c419c5	institution	be133600-848e-400b-9bc8-c52a4f3cf10d	1	contacto@avila-y-maestas-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.933343+00	2025-11-22 04:41:37.933343+00
de12a818-d788-468a-8628-e787b42e0c14	institution	25e918f3-692f-4f51-b630-4caa1dd825a1	1	contacto@gastelum-y-guerrero-y-asociados.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.936012+00	2025-11-22 04:41:37.936012+00
c378dcac-3bfc-4135-baff-6c561fa74468	institution	cc46221e-f387-463c-9d11-9464d8209f7b	1	contacto@escobedo-y-guerrero-a-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.939281+00	2025-11-22 04:41:37.939281+00
f0270b5c-788b-4a7c-8d46-eb383c622679	institution	a15d4a4b-1bc4-4ee5-a168-714f71d94e42	1	contacto@laboratorios-cavazos-y-valentin.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.943198+00	2025-11-22 04:41:37.943198+00
bad7a8a7-4088-448b-ad90-da2b3ccc0201	institution	3d7c5771-0692-4a2f-a4c6-6af2b561282b	1	contacto@leal-valdez-s-a-de-c-v.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.946129+00	2025-11-22 04:41:37.946129+00
a441e811-50ac-45a7-b429-0f63ab59cf2d	institution	16b25a77-b84a-44ac-8540-c5bfa9b3b6b0	1	contacto@carvajal-y-urias-a-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.949146+00	2025-11-22 04:41:37.949146+00
702c8c59-ed87-4890-9067-98274b2663f6	institution	2040ac28-7210-4fbd-9716-53872211bcd9	1	contacto@alonso-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.952117+00	2025-11-22 04:41:37.952117+00
be69ffd7-7031-4741-9c39-69ae3702886c	institution	0d826581-b9d8-4828-8848-9332fe38d169	1	contacto@arteaga-malave.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.955472+00	2025-11-22 04:41:37.955472+00
bf59e000-fd3b-4caf-832c-d661082e553c	institution	c0595f94-c8f4-413c-a05c-7cfca773563c	1	contacto@briones-y-esquibel-s-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.959787+00	2025-11-22 04:41:37.959787+00
98b3325a-67b8-4776-80fe-4bea3e9560de	institution	a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5	1	contacto@mares-altamirano-y-gil.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.962547+00	2025-11-22 04:41:37.962547+00
17770b96-ba61-4c91-9ba4-254856488bc0	institution	ad2c792b-5015-4238-b221-fa28e8b061fc	1	contacto@corporacin-hurtado-martinez-y-bueno.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.965248+00	2025-11-22 04:41:37.965248+00
4d4bd436-6c95-49a5-a248-085501b82647	institution	c3e96b10-f0ca-421e-b402-aba6d595cf27	1	contacto@leyva-y-saavedra-e-hijos.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.968044+00	2025-11-22 04:41:37.968044+00
9ba8e78e-5c90-4cd8-9656-cca349399b76	institution	a5b1202a-9112-404b-b7de-ddf0f62711f8	1	contacto@corporacin-pacheco-hurtado-y-holguin.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.971911+00	2025-11-22 04:41:37.971911+00
548ab9ec-f8c2-43c4-a50e-ec41a63d4b5f	institution	ac6f8f54-21c8-475b-bea6-19e31643392d	1	contacto@despacho-guerrero-noriega-y-zavala.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.975168+00	2025-11-22 04:41:37.975168+00
8d76a57b-9c54-4f29-8b74-135def6047a2	institution	43dee983-676a-4e33-a6b0-f0a72f46d06c	1	contacto@montano-lira.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.978222+00	2025-11-22 04:41:37.978222+00
84a52379-a963-4dd5-8904-25a2626ecb01	institution	f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	1	contacto@pelayo-arenas.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.981298+00	2025-11-22 04:41:37.981298+00
8c9ba844-f832-456c-9f99-8102eab5232d	institution	08a7fe9e-c043-4fed-89e4-93a416a20089	1	contacto@gil-y-coronado-y-asociados.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.984654+00	2025-11-22 04:41:37.984654+00
01953a3e-11c6-4ea4-a9a9-51ce31cf4a06	institution	89ab21cf-089e-4210-8e29-269dfbd38d71	1	contacto@crespo-pena-y-rosado.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.988808+00	2025-11-22 04:41:37.988808+00
0265d328-d495-4181-a428-0f722f8b9828	institution	d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f	1	contacto@jiminez-arroyo-y-ramon.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.992213+00	2025-11-22 04:41:37.992213+00
0dfc042f-1513-48d3-ae80-f03af8fbb14a	institution	ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	1	contacto@de-leon-s-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.99542+00	2025-11-22 04:41:37.99542+00
22f85fe0-c654-4028-8ae8-72198fd34d98	institution	3cf42c93-4941-4d8d-8656-aafa9e987177	1	contacto@robles-loera-a-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:37.998692+00	2025-11-22 04:41:37.998692+00
3b01322b-9a36-4a35-93a2-a36b34308ecc	institution	1926fa2a-dab7-420e-861b-c2b6dfe0174e	1	contacto@industrias-ponce-y-soto.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.002227+00	2025-11-22 04:41:38.002227+00
d149331b-e022-4eb1-8a76-0ef5d0d8a757	institution	0b2f4464-5141-44a3-a26d-f8acc1fb955e	1	contacto@madera-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.006424+00	2025-11-22 04:41:38.006424+00
b86a1d55-7117-428a-b60c-dbedb3f2dd6d	institution	1fec9665-52bc-49a7-b028-f0d78440463c	1	contacto@proyectos-tejada-ramon-y-caldera.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.009947+00	2025-11-22 04:41:38.009947+00
f745174d-029a-43b9-b299-287e7df32cea	institution	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	1	contacto@estevez-carrera.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.013995+00	2025-11-22 04:41:38.013995+00
ab75d83b-ed59-421f-8416-7c108b94ae08	institution	8cfdeaad-c727-4a4d-b5d5-b69dd43c0854	1	contacto@laboratorios-puga-coronado-y-carmona.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.017781+00	2025-11-22 04:41:38.017781+00
2ec3c2b1-6c27-4a54-b7e3-cbbc05f2a060	institution	7a6ce151-14b5-4d12-b6bb-1fba18636353	1	contacto@menchaca-vela-s-r-l-de-c-v.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.022525+00	2025-11-22 04:41:38.022525+00
bce3fff8-68bd-4bdf-80a3-c978304dc68b	institution	f1ab98f4-98de-420f-9c4b-c31eee92df21	1	contacto@carreon-y-soliz-s-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.025935+00	2025-11-22 04:41:38.025935+00
817eb573-d91b-4657-b8b0-fd586c481a78	institution	a074c3ea-f255-4cf2-ae3f-727f9186be3c	1	contacto@zarate-solano.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.029091+00	2025-11-22 04:41:38.029091+00
e797246a-e3f1-4887-964f-ffaa25d1f673	institution	0e3821a8-80d6-4fa9-8313-3ed45b83c28b	1	contacto@de-la-cruz-espinoza-e-hijos.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.032288+00	2025-11-22 04:41:38.032288+00
37e3a157-7e7e-451d-bbe7-0bbc6311952e	institution	3d521bc9-692d-4a0d-a3d7-80e816b86374	1	contacto@laboratorios-valdes-ruelas.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.040488+00	2025-11-22 04:41:38.040488+00
5f180538-bdc4-4928-825e-a8c2f5d8c43d	institution	47393461-e570-448b-82b1-1cef15441262	1	contacto@espinosa-s-r-l-de-c-v.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.043857+00	2025-11-22 04:41:38.043857+00
8c61a931-f4bb-454d-a34b-9575f58c7c4a	institution	744b4a03-e575-4978-b10e-6c087c9e744b	1	contacto@villarreal-ocasio.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.046801+00	2025-11-22 04:41:38.046801+00
bfea2a8c-1406-48b0-92e3-adbdc8b084aa	institution	9a18b839-1b93-44fb-9d8a-2ea12388e887	1	contacto@corporacin-carrasco-y-lopez.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.050056+00	2025-11-22 04:41:38.050056+00
3679e9ff-b56b-4edd-8fce-b269f3a2948c	institution	1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	1	contacto@cisneros-concepcion.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.05472+00	2025-11-22 04:41:38.05472+00
45d13841-46fe-4141-8f69-6e34d1f5bbbc	institution	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	1	contacto@jurado-guardado.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.057998+00	2025-11-22 04:41:38.057998+00
4df7ac3c-4ad1-422c-a20e-32ed3d3e454c	institution	eea6be20-e19f-485f-ab54-537a7c28245f	1	contacto@club-perez-y-godoy.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.062929+00	2025-11-22 04:41:38.062929+00
ac511b12-2ddb-4315-801d-d2750f289e1d	institution	eb602cae-423a-455d-a22e-d47aea5eb650	1	contacto@de-la-fuente-arias.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.066666+00	2025-11-22 04:41:38.066666+00
1e95022d-fc34-428e-aa2e-ecbdd56e427b	institution	bb17faca-a7b2-4de8-bf29-2fcb569ef554	1	contacto@hernandes-leiva-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.07193+00	2025-11-22 04:41:38.07193+00
8ad133b7-58a9-4166-9b13-c0e8094a28c9	institution	44a33aab-1a23-4995-bd07-41f95b34fd57	1	contacto@grupo-garza-y-arellano.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.075556+00	2025-11-22 04:41:38.075556+00
d2b3353c-25f1-4728-8cc0-12fae63a0f6f	institution	5462455f-fbe3-44c8-b0d1-0644c433aca6	1	contacto@laboratorios-navarrete-anaya.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.083538+00	2025-11-22 04:41:38.083538+00
1a908f32-9b2f-4c87-a382-7a548c868aca	institution	d050617d-dc89-4f28-b546-9680dd1c5fad	1	contacto@club-armas-polanco.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.087589+00	2025-11-22 04:41:38.087589+00
f75b704d-9813-424c-94cd-c6746fb8be17	institution	7227444e-b122-48f4-8f01-2cda439507b1	1	contacto@olivera-lovato-y-saavedra.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.091124+00	2025-11-22 04:41:38.091124+00
125badbb-e3ae-4a8b-a5ce-91206145fd69	institution	d86c173a-8a1d-43b4-a0c1-c836afdc378b	1	contacto@grupo-ochoa-corrales.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.094511+00	2025-11-22 04:41:38.094511+00
3573d09b-4f65-4ecd-9121-e64557370f10	institution	fb0a848d-4d51-4416-86bc-e568f694f9e7	1	contacto@banuelos-montano.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.098453+00	2025-11-22 04:41:38.098453+00
a58ca67c-f951-4ee1-9c3a-8d08fb4c3e28	institution	ccccdffb-bc26-4d80-a590-0cd86dd5a1bc	1	contacto@melendez-arriaga.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.102607+00	2025-11-22 04:41:38.102607+00
6eecbe2e-756d-4808-b771-147ac7cef146	institution	8cb48822-4d4c-42ed-af7f-737d3107b1db	1	contacto@corporacin-menchaca-y-salgado.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.107646+00	2025-11-22 04:41:38.107646+00
08b190ee-c043-4157-aeed-72817890cbf5	institution	700b8c76-7ad1-4453-9ce3-f598565c6452	1	contacto@club-salcedo-y-segura.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.110951+00	2025-11-22 04:41:38.110951+00
5e5e03cc-2b65-41d2-bd7a-64e39692e797	institution	d3cb7dc8-9240-4800-a1d9-bf65c5dac801	1	contacto@grupo-rosas-mena-y-sandoval.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.114468+00	2025-11-22 04:41:38.114468+00
cc12b2fe-0f1d-4029-95d2-23fb8ea6df4d	institution	06c71356-e038-4c3d-bfea-7865acacb684	1	contacto@club-otero-valadez-y-crespo.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.119102+00	2025-11-22 04:41:38.119102+00
735f2c05-84bb-41ba-ba19-4fbb9f4c6305	institution	30e2b2ec-9553-454e-92a4-c1dc89609cbb	1	contacto@industrias-esquibel-mesa-y-valle.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.122649+00	2025-11-22 04:41:38.122649+00
a6194b6b-d87f-44b9-bb5b-0526c982491c	institution	2eead5aa-095b-418a-bd02-e3a917971887	1	contacto@calvillo-y-benavides-a-c.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.127625+00	2025-11-22 04:41:38.127625+00
bfe5bca4-855e-48b6-a5fc-1fac4d1be257	institution	05afd7e1-bb93-4c83-90a7-48a65b6e7598	1	contacto@industrias-ledesma-jurado-y-pantoja.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.132491+00	2025-11-22 04:41:38.132491+00
afa79282-e23e-4b2e-9bbd-0050c64768ab	institution	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	1	contacto@cervantes-peralta.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.136072+00	2025-11-22 04:41:38.136072+00
30f424ac-a694-4b0a-995d-6fea2e3746cf	institution	454f4ba6-cb6d-4f27-9d76-08f5b358b484	1	contacto@rico-y-escobar-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.139917+00	2025-11-22 04:41:38.139917+00
c6728106-d4d0-42f8-81d5-f81595898de0	institution	389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	1	contacto@baez-viera-s-a.predicthealth.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.14391+00	2025-11-22 04:41:38.14391+00
db622139-6923-4076-a0e0-c38237bd25ed	doctor	06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7	1	dr.mariajose.rosales@corporacin.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.149134+00	2025-11-22 04:41:38.149134+00
0a2dd287-1b7a-4200-94df-85e80c6007de	doctor	3e5b08ed-529d-45f0-8145-8371609882c1	1	dr.sessa.irizarry@puente-sanabria.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.155084+00	2025-11-22 04:41:38.155084+00
d025316a-1461-4d30-a65f-5aa61f7ad7fa	doctor	57031194-3c31-4320-86c4-fd370789efac	1	dr.indira.olmos@caldera-marin.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.158659+00	2025-11-22 04:41:38.158659+00
99778af6-db57-4299-838d-c70721670abb	doctor	dc42b779-4b49-418b-ab0a-92caa2a8d6de	1	dr.perla.zavala@despacho.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.162166+00	2025-11-22 04:41:38.162166+00
2977d1d8-08c4-4568-b935-a5cff4904002	doctor	14abdfde-e4c9-460c-9ce2-17886600b20d	1	dr.fidel.urbina@proyectos.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.167302+00	2025-11-22 04:41:38.167302+00
073ee42e-5cff-47cc-9a67-da66f173edfa	doctor	df863eba-f0b8-4b1a-bdd1-71ed2f816ed7	1	dr.rebeca.paredes@vera.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.17071+00	2025-11-22 04:41:38.17071+00
befef5ae-d3d6-469d-bf8f-c80b0a7f3f72	doctor	ba712fc8-c4d2-4e22-ae18-1991c46bc85d	1	dr.mario.gaona@santillan.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.175672+00	2025-11-22 04:41:38.175672+00
70643ef6-a061-4629-b349-c5fc8bfd216c	doctor	bbf715a1-3947-4642-a67a-b5c4c0c085d2	1	dr.luis.ceja@club.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.181403+00	2025-11-22 04:41:38.181403+00
d74e259b-e616-427e-bc6f-03b4d99422d2	doctor	851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec	1	dr.sergio.guevara@corporacin.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.184825+00	2025-11-22 04:41:38.184825+00
dae577ba-7be4-4d97-8122-5326c60905af	doctor	0fbbaab0-2284-4ac6-b1c9-498b5b3c4567	1	dr.natalia.barrientos@manzanares-vaca.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.18828+00	2025-11-22 04:41:38.18828+00
e4dc523e-5172-4970-9e46-2f8daa27e835	doctor	b6994d45-b80e-4260-834c-facdf3ea8eee	1	dr.berta.rincon@reynoso.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.19153+00	2025-11-22 04:41:38.19153+00
af586427-b79e-456e-b1f7-a83da7368670	doctor	f7cdc060-94e6-47ad-90e9-939ed86fb6da	1	dr.lorenzo.rivera@lovato-briseno.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.196539+00	2025-11-22 04:41:38.196539+00
df1c2f7d-6c43-4cf1-8cef-446a70fc5ef5	doctor	23785934-fbf0-442c-add3-05df84fa5d17	1	dr.omar.trujillo@montalvo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.201159+00	2025-11-22 04:41:38.201159+00
c8d7a50e-8dae-453a-a32b-0f697af6e997	doctor	bf7a015c-1589-42b3-b1e8-103fcbc0b041	1	dr.elvira.ochoa@benavides-godoy.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.20484+00	2025-11-22 04:41:38.20484+00
a8beff94-5221-4562-b1a8-1be07913795d	doctor	4fa9d0ff-2c51-4918-b48a-b5cb37d444a3	1	dr.natalia.murillo@mascarenas.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.208299+00	2025-11-22 04:41:38.208299+00
55e7dc59-57ca-4b77-849b-0e7aa9ed28a0	doctor	93dbdfc0-e05c-4eb6-975c-360eb8d293c1	1	dr.pedro.valdes@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.212072+00	2025-11-22 04:41:38.212072+00
564adf36-9cc7-4cbc-9062-a9e13e8ab274	doctor	a6db1b41-d601-4840-99e9-3d7d18901399	1	dr.eugenio.uribe@laboratorios.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.218984+00	2025-11-22 04:41:38.218984+00
01370331-5aca-4512-8b52-a006d95c9b5c	doctor	d5e98ce0-e6f8-4577-a0dd-3281aa303b32	1	dr.linda.trejo@laboratorios.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.222441+00	2025-11-22 04:41:38.222441+00
3299b4bc-8790-4553-83f2-caa6d6459dd0	doctor	44da48b1-6ff6-4db9-9de5-34e22de0429a	1	dr.susana.acosta@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.2262+00	2025-11-22 04:41:38.2262+00
13844385-ecf6-4733-9ae9-487ecb7b60ba	doctor	3fafc20d-72d5-4633-95a0-df6b9ed175b6	1	dr.rodrigo.mota@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.23116+00	2025-11-22 04:41:38.23116+00
ffb4b20c-8ba1-4f64-9351-8dceff376385	doctor	c4fac110-0b61-4fb0-943d-0d00af7ed0cd	1	dr.linda.magana@madera.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.234801+00	2025-11-22 04:41:38.234801+00
9caf2f41-8b94-4110-a83b-e766ab5de75c	doctor	88870e4f-1333-4bcc-8daf-c8743d61f3cb	1	dr.joseluis.rubio@navarro-prado.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.23854+00	2025-11-22 04:41:38.23854+00
a51b5352-7eb0-46bc-a7cb-d1c2b70c46ca	doctor	6f035f60-87f7-4a9c-9501-4b8704facba3	1	dr.concepcion.barajas@colon.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.242707+00	2025-11-22 04:41:38.242707+00
68aa0d71-4e68-4e35-ad5b-3fd1ffba13f8	doctor	58a814d3-a275-436b-8e5c-4e743fed242f	1	dr.debora.delgadillo@escamilla.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.247465+00	2025-11-22 04:41:38.247465+00
280e3e73-3bd1-4cc3-b5fa-5e90fea60816	doctor	f67c2f76-9bf1-43e4-8d0e-c0a94298f35b	1	dr.augusto.roque@club.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.251052+00	2025-11-22 04:41:38.251052+00
631285f2-1204-4429-84af-d43b19b9920f	doctor	fb4d84a0-7bc1-4815-b7a3-b1719c616c79	1	dr.francisca.garay@industrias.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.25449+00	2025-11-22 04:41:38.25449+00
22e6a184-34d2-4211-9f4a-7821104c2be0	doctor	c0bdb808-eb5f-479f-9261-dbbf9ff031a6	1	dr.judith.sevilla@guardado.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.258282+00	2025-11-22 04:41:38.258282+00
dabeded0-bd48-4d34-97ed-7289217ad47a	doctor	f501d643-d308-41e0-8ffc-8bfb52d64e13	1	dr.nelly.robles@montenegro.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.263235+00	2025-11-22 04:41:38.263235+00
96c103a9-0a7a-4ac1-b0af-178d72dae9ee	doctor	adeb74f6-f3dc-43a7-a841-6d24aba046ba	1	dr.soledad.noriega@proyectos.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.267225+00	2025-11-22 04:41:38.267225+00
47de9cf0-2633-4a35-b8ad-65a5a5e8dbc4	doctor	dd24da99-43c7-4d6b-acc0-32fc0c237d02	1	dr.silvano.espinosa@caban.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.271382+00	2025-11-22 04:41:38.271382+00
40e04974-19d3-4d07-bd6d-42c6f63cebf0	doctor	0408b031-caa3-4b7c-ae65-d05342cf5c05	1	dr.fabiola.saavedra@zelaya.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.275805+00	2025-11-22 04:41:38.275805+00
c4a31f35-3428-4591-a06c-f0663cbcd362	doctor	a865edbe-d50c-4bd1-b556-ae32d9d1858c	1	dr.silvia.enriquez@corporacin.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.281945+00	2025-11-22 04:41:38.281945+00
a10e4c35-2557-4462-ac48-b8f1cbaf03b6	doctor	2a0aaddd-ea43-40bb-b5df-877b1b0d20f1	1	dr.maximiliano.segura@industrias.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.286276+00	2025-11-22 04:41:38.286276+00
3be4c254-10ac-45ad-9f4b-0ba9798c63a7	doctor	4754ba59-3dc1-4be2-a770-44d7c34184bc	1	dr.josemaria.serna@soria-garcia.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.289383+00	2025-11-22 04:41:38.289383+00
121c740a-d986-408b-a577-142a343c51e9	doctor	16e23379-6774-417d-8104-a8e6f4712909	1	dr.eugenio.gastelum@proyectos.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.29369+00	2025-11-22 04:41:38.29369+00
cc2a8d9b-ee8d-45da-96c0-8784178fc2df	doctor	07527c1a-efd5-45e4-a0d9-01ba5207bb2f	1	dr.eva.cotto@proyectos.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.298085+00	2025-11-22 04:41:38.298085+00
a01b1eeb-bd3c-4279-959c-97033d168571	doctor	c186d1ad-fcba-4f6e-acd7-86cb4c09938e	1	dr.indira.ramon@linares.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.302488+00	2025-11-22 04:41:38.302488+00
27cab35c-2d0b-452e-8a62-bc949736a114	doctor	4cecebec-e16f-4949-a18b-8bfebae86618	1	dr.patricia.angulo@laboratorios.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.305687+00	2025-11-22 04:41:38.305687+00
68e73e4f-e12b-4cec-9008-4a02e3021f85	doctor	6d21a37a-43d8-440b-bc64-87bb0ae1d45d	1	dr.helena.valladares@delgado.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.309302+00	2025-11-22 04:41:38.309302+00
e5a528be-cf33-4c4c-ae15-f81b2cc69bf0	doctor	4d75aae7-5d33-44ad-a297-a32ff407415d	1	dr.ruben.pacheco@proyectos.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.313065+00	2025-11-22 04:41:38.313065+00
3ad34853-e871-480b-b230-63958f375f21	doctor	e901dbc1-3eed-4e5e-b23c-58d808477e33	1	dr.samuel.garibay@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.316116+00	2025-11-22 04:41:38.316116+00
979526b3-9415-491d-992c-5a2ed4edf788	doctor	61bb20b9-7520-42be-accf-743c84a0b934	1	dr.joaquin.vigil@corona.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.319266+00	2025-11-22 04:41:38.319266+00
af47951a-336a-49fa-9678-87b381b7da44	doctor	b5a04df6-baea-460f-a946-f7b7606c9982	1	dr.amador.arenas@club.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.322492+00	2025-11-22 04:41:38.322492+00
43c5926c-357c-46a6-ac90-9ec3d6b51fe0	doctor	c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	1	dr.felipe.hidalgo@camarillo-vega.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.326379+00	2025-11-22 04:41:38.326379+00
5a2a2c88-7337-4bfa-8047-ba983da8cae9	doctor	0b238725-a392-4fbb-956b-0f71e15bc6da	1	dr.mariateresa.baca@bernal-teran.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.331391+00	2025-11-22 04:41:38.331391+00
4b5ea226-9397-4569-8eca-18cbaf2a918c	doctor	63ec3e7d-b8e4-4988-9bc3-5b655f830e31	1	dr.miguelangel.perez@despacho.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.334283+00	2025-11-22 04:41:38.334283+00
47ad04b9-5c23-4553-a344-62e4874ca9e7	doctor	d4df85ce-6d2b-46c9-b9cd-48b2490b3c88	1	dr.jonas.madera@zamudio.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.339781+00	2025-11-22 04:41:38.339781+00
bf76d053-9a92-4ca7-ba2f-0d50853f5259	doctor	71618fe0-25a1-4281-98af-51797de3ae0a	1	dr.arcelia.delarosa@reyna-valdes.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.34429+00	2025-11-22 04:41:38.34429+00
3aaa66e9-7adf-4162-abbf-48043dd8d5d8	doctor	389524b6-608c-4b31-affa-305b79635816	1	dr.esther.echeverria@ramos.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.347682+00	2025-11-22 04:41:38.347682+00
4f658e1a-e6ea-459f-9037-453d621c6416	doctor	c0356e82-1510-4557-b654-cf84ac13f425	1	dr.sofia.montez@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.351342+00	2025-11-22 04:41:38.351342+00
5eae5805-d455-49b9-93c0-2eff4c270212	doctor	ce44b08f-7dae-4844-ae53-e01ac2f28f45	1	dr.debora.segura@robledo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.354607+00	2025-11-22 04:41:38.354607+00
faa6ac54-7d4c-43a7-ab17-f8be610c2557	doctor	9c9838c2-4464-4fbb-bc22-8f4ac64b4efe	1	dr.luismiguel.villarreal@canales-rascon.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.35848+00	2025-11-22 04:41:38.35848+00
aa021bb7-9491-4b8e-8041-dfaec3197c23	doctor	e8db5b49-5605-41e5-91f2-d456b68c5ade	1	dr.esmeralda.parra@corporacin.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.364577+00	2025-11-22 04:41:38.364577+00
7d546d65-3692-4b9c-a39f-c39198bf1291	doctor	96d6da02-ca2f-4ace-b239-4584544e8230	1	dr.patricia.tellez@linares.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.367642+00	2025-11-22 04:41:38.367642+00
649d92a5-f6b2-4fdb-87d7-91643fc6d143	doctor	38bf2ce6-5014-4bc1-8e32-9b9257eea501	1	dr.timoteo.tafoya@despacho.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.370741+00	2025-11-22 04:41:38.370741+00
f8bd1795-1608-48fb-8703-64dab9cd2afe	doctor	e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c	1	dr.amanda.ferrer@carreon.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.373733+00	2025-11-22 04:41:38.373733+00
7b91cd02-e00d-4b05-bbb1-cb8080330a4f	doctor	8ce8b684-8f8d-4828-987d-389dfe64afd1	1	dr.caridad.villa@jaimes.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.377384+00	2025-11-22 04:41:38.377384+00
3fa306e9-3e1e-4cda-9199-71b1cf917c90	doctor	ca8bf565-35d3-40f3-b741-603201f6f072	1	dr.hector.castro@granado.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.380479+00	2025-11-22 04:41:38.380479+00
b1aba4a8-56f8-4893-b5a0-051ea7303a6d	doctor	2937cc2f-22b7-4488-b9f8-a0795800a840	1	dr.abraham.rodarte@guzman.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.383037+00	2025-11-22 04:41:38.383037+00
186e2cc2-8936-4ba5-89a7-57d30145ae99	doctor	f8a511e3-b97b-4d17-8240-46520497ef7c	1	dr.gloria.briones@zapata-madera.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.385889+00	2025-11-22 04:41:38.385889+00
d4f1d02a-842a-4656-95ad-6832f5bb7a9b	doctor	879bcb9a-8520-4d02-b12b-ba5afa629d41	1	dr.joseluis.bahena@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.388755+00	2025-11-22 04:41:38.388755+00
87049886-6762-44d3-b47d-c2f3cdb1f1ca	doctor	7817761a-e7c5-47cb-a260-7e243c11ef2f	1	dr.daniela.laboy@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.391992+00	2025-11-22 04:41:38.391992+00
b97c92f4-4276-40a1-b033-5b2ed3309415	doctor	48384f36-0b57-4943-899f-cbffd4ec37b6	1	dr.bruno.ledesma@chavez-polanco.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.394781+00	2025-11-22 04:41:38.394781+00
30c4ccb3-ef8c-4db2-b6cf-250a470502fd	doctor	0fc70684-777f-43eb-895d-9cb90ce0f584	1	dr.noelia.garica@pabon.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.397735+00	2025-11-22 04:41:38.397735+00
ad6146db-1add-421c-b578-cd0413b7bd3c	doctor	a849f14b-3741-4e38-9dfb-6cc7d46265e8	1	dr.mitzy.godoy@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.40201+00	2025-11-22 04:41:38.40201+00
338cb890-4727-41a0-a8cc-c0a62e2f6b83	doctor	22128ae9-ba6e-4e99-821a-dc445e76d641	1	dr.sessa.medina@espinal-tamez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.405947+00	2025-11-22 04:41:38.405947+00
9b7fe9d9-1d18-44a0-9f40-54da402da3f3	doctor	6c711a31-c752-44f2-b6cb-480f9bf6af1f	1	dr.mitzy.aguayo@industrias.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.415419+00	2025-11-22 04:41:38.415419+00
1929072a-ffbe-4bc8-91ec-b6374548f5eb	doctor	ab923e2e-5d13-41e4-9c73-2f62cca0699d	1	dr.patricio.monroy@velazquez-aguilera.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.419343+00	2025-11-22 04:41:38.419343+00
aed673ce-ec12-4ed6-8db8-4d4a428cdecc	doctor	a7f19796-4c62-4a2b-82de-7c2677804e6a	1	dr.homero.valentin@malave-rodriguez.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.423389+00	2025-11-22 04:41:38.423389+00
e79fa4f8-ea82-4e6b-9368-c22dc262fccf	doctor	28958f29-28c6-405a-acf5-949ffcaec286	1	dr.porfirio.farias@paez-badillo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.427613+00	2025-11-22 04:41:38.427613+00
1044affa-d6de-4bd6-8f72-ecf934a71524	doctor	472116b5-933e-4f63-b3ca-e8c8f5d30bb4	1	dr.gonzalo.cortes@becerra.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.431284+00	2025-11-22 04:41:38.431284+00
fb2446c5-69b9-4673-a9ea-656c0a9eb20c	doctor	a2beaa02-c033-4e45-b702-305d5ce41e34	1	dr.marisol.tello@corporacin.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.435896+00	2025-11-22 04:41:38.435896+00
a6d02550-e7fb-4f93-95db-20677246ca4d	doctor	5879ec30-c291-476d-a48c-284fadf5f98a	1	dr.mateo.serrato@mejia-baez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.439707+00	2025-11-22 04:41:38.439707+00
6b5ea6a8-dbc7-4f4d-ad8d-9e383d29381c	doctor	d512bd88-12a3-45f9-85e8-14fb3cb5a6e1	1	dr.reina.camacho@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.443385+00	2025-11-22 04:41:38.443385+00
6a91bd4e-e8df-4735-898c-eaa81c707496	doctor	757d6edf-5aa8-461b-ac4f-9e8365017424	1	dr.homero.rodarte@laboratorios.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.446992+00	2025-11-22 04:41:38.446992+00
8d002ecc-bbcd-471f-8531-c282401fad83	doctor	c0d54a00-2ee9-4827-a7fb-6196ef15bdee	1	dr.martin.trevino@montez.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.450767+00	2025-11-22 04:41:38.450767+00
a701a822-bcc1-4a15-af4b-bd346196e3c2	doctor	a7ada88a-7935-4dd5-8a4f-935c4b7c0bab	1	dr.wilfrido.salazar@industrias.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.455078+00	2025-11-22 04:41:38.455078+00
a6539b63-9867-4b9a-85b5-0e1e50717852	doctor	4664d394-c950-4dbf-9b40-7b34c6d6dabb	1	dr.uriel.velazquez@proyectos.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.45952+00	2025-11-22 04:41:38.45952+00
35dab40c-52f6-41a2-a2ba-580c9b9b1fd1	doctor	c16b254c-dcf7-4a31-a101-1ed86b62477e	1	dr.jos.briones@pacheco-gutierrez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.463769+00	2025-11-22 04:41:38.463769+00
2b1de04e-8bb4-4a18-9650-30238e7a4bf5	doctor	e0926c16-7f63-41ae-a091-1d0688c88322	1	dr.david.dominguez@saldana.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.468463+00	2025-11-22 04:41:38.468463+00
32319850-5aff-4774-a98d-f17b55dcf55a	doctor	250b33c9-1ba3-44e6-9c35-cde7000d6d53	1	dr.adan.ferrer@varela-vera.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.472722+00	2025-11-22 04:41:38.472722+00
1ec8fccc-c844-4e58-9a6d-751728e60b08	doctor	b6c86aef-75e2-4c64-bceb-e7de898b5a1b	1	dr.irene.cisneros@ramirez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.476602+00	2025-11-22 04:41:38.476602+00
8e171448-b6a5-4a6b-b926-b5019e856a8f	doctor	a3fb2dae-2a69-434f-86a9-65ae48c8f690	1	dr.altagracia.orellana@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.480085+00	2025-11-22 04:41:38.480085+00
83edc718-f786-4c4f-ba14-01ec4861d2b4	doctor	820c1228-3d2d-4766-900f-32940f14e74b	1	dr.cristal.balderas@corporacin.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.483782+00	2025-11-22 04:41:38.483782+00
0458f956-32b5-4f48-9311-3487594478e5	doctor	da3dbacf-8df0-46cf-bbef-b51615063a9b	1	dr.marisol.ulloa@castillo.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.48961+00	2025-11-22 04:41:38.48961+00
680ec5ce-2b3c-490d-9711-9d999be031bb	doctor	e6ce6823-6c4d-4ead-98d7-78b94483fe2c	1	dr.alfonso.cazares@ocampo-rincon.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.493711+00	2025-11-22 04:41:38.493711+00
7f2cded5-5fe8-4ca9-b4e0-4ec0f0eed213	doctor	84cb6703-edfc-4180-9f80-619064c9684e	1	dr.elisa.oquendo@club.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.498652+00	2025-11-22 04:41:38.498652+00
bf69107b-386f-4ae4-8a20-eec5b825fe25	doctor	21e4d7a9-73dc-4156-b413-b389c2e92a0d	1	dr.silvano.brito@naranjo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.50333+00	2025-11-22 04:41:38.50333+00
d72042d6-c1a4-4f77-92a1-07fc363acafd	doctor	85eb8041-b502-4b90-b586-c7c4593b5347	1	dr.ursula.casares@aranda.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.50742+00	2025-11-22 04:41:38.50742+00
1f48100a-0ec0-4eec-9f84-9e260e906d32	doctor	c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9	1	dr.marcela.corona@despacho.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.512308+00	2025-11-22 04:41:38.512308+00
39d2111c-03dd-4e10-b900-09a709e263d9	doctor	22d570dd-a72e-4599-8f13-df952d35d616	1	dr.catalina.orta@muniz.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.516216+00	2025-11-22 04:41:38.516216+00
fda6763e-f8bb-4f08-9b0d-4bc4b8e80494	doctor	04a9b2e7-638b-4fe0-a106-16b582d946ab	1	dr.rene.morales@garza-valdez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.522561+00	2025-11-22 04:41:38.522561+00
df25a060-56d5-4965-b5fc-7d8c3d27fce1	doctor	03e547d1-325a-46ea-bc94-c188abf53f0f	1	dr.benjamin.leal@grupo.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.526077+00	2025-11-22 04:41:38.526077+00
c955cf58-2c76-4380-81f9-0a8d7716d627	doctor	5a6de593-99b5-4942-a379-fd21b2a4999f	1	dr.catalina.alarcon@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.529811+00	2025-11-22 04:41:38.529811+00
fe8f12ba-7e71-480b-a968-d71cae4a4a5a	doctor	b7dd043b-953f-4e04-8a80-1c613d3c6675	1	dr.pedro.riojas@cornejo-tello.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.534988+00	2025-11-22 04:41:38.534988+00
432a1263-ab6e-4f93-a0f3-57fce53b6231	doctor	852beb97-3c99-4391-879f-98f0c2154c20	1	dr.olivia.nieto@paz-guillen.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.539163+00	2025-11-22 04:41:38.539163+00
789182af-ace5-48ba-88ae-f9cfe69521cb	doctor	86bb4262-7a96-444b-a096-d3a1bd7782e7	1	dr.victoria.corona@valladares.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.543888+00	2025-11-22 04:41:38.543888+00
cbc8766e-a8c8-4d74-9fd2-6dd66980f701	doctor	b441c98a-1075-4013-9fc2-9242d910713f	1	dr.daniela.gallegos@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.547518+00	2025-11-22 04:41:38.547518+00
f16cd447-7e93-4f21-9c20-3cb8d2535683	doctor	77486cf8-54d8-4120-856f-642ebae74d48	1	dr.victoria.urbina@ontiveros-soliz.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.551944+00	2025-11-22 04:41:38.551944+00
dd3ad64d-a508-4859-b95e-05f465b95c71	doctor	0e2fa589-05b2-402c-9722-1022a0121b04	1	dr.leonardo.aguirre@henriquez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.556577+00	2025-11-22 04:41:38.556577+00
1c1c02c7-3203-4265-a99a-765ea5f59ec9	patient	2f5622af-8528-4c85-8e16-3d175a4f2d15	1	linda.najera.1967@esquivel.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.561564+00	2025-11-22 04:41:38.561564+00
32e06d82-ef6c-4120-8816-cc478cdd0533	patient	fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	1	marisela.rocha.1971@industrias.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.56696+00	2025-11-22 04:41:38.56696+00
a35dddd1-620a-4e59-bf79-e79f9c1c709f	patient	959aa1dd-346b-4542-8f99-0d5e75301249	1	homero.miranda.1976@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.571322+00	2025-11-22 04:41:38.571322+00
156bb4e9-96ab-4705-8614-0b9b3432e5ef	patient	59402562-ce5f-450e-8e6c-9630514fe164	1	manuel.vela.1989@corporacin.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.575425+00	2025-11-22 04:41:38.575425+00
1a2635ad-2765-4df8-89e9-185e624159d7	patient	f81c87d6-32f1-4c79-993a-18db4734ef65	1	paulina.cervantez.1975@cornejo-montero.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.579258+00	2025-11-22 04:41:38.579258+00
cafb69ad-ad33-4cd9-9352-22b3d3b7f171	patient	0b6b8229-4027-4ec7-8bce-c805de96ced3	1	benjamin.serna.1972@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.583301+00	2025-11-22 04:41:38.583301+00
d3542b48-a9ca-4277-b605-57cac13596f5	patient	f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	1	rosa.galvez.1962@mendoza.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.589494+00	2025-11-22 04:41:38.589494+00
f40cdeb4-5c55-44fd-a259-16295ebcf94f	patient	f2a1f62a-8030-4f65-b82d-ce7376b955bd	1	nelly.montemayor.1991@despacho.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.59363+00	2025-11-22 04:41:38.59363+00
af11362c-62b7-466c-94c0-3d89a5c6077e	patient	0104fea2-d27c-4611-8414-da6c898b6944	1	rolando.jaimes.1994@almanza.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.598304+00	2025-11-22 04:41:38.598304+00
bd99f4df-8a91-479d-a759-639f625942e0	patient	cd0c2f0c-de08-439c-93c9-0feab1d433cc	1	bruno.urena.1966@saiz.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.604212+00	2025-11-22 04:41:38.604212+00
7764dc41-f556-4fb1-aa54-1af24f37e4e8	patient	7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	1	luismanuel.morales.1956@alva-zamudio.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.60827+00	2025-11-22 04:41:38.60827+00
242b059e-39db-41f6-ba20-b20179ec0f06	patient	7893292b-965a-41da-896a-d0780c91fdd5	1	david.benavidez.1953@ybarra-briones.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.615631+00	2025-11-22 04:41:38.615631+00
a6c60117-cc4e-495c-b764-1a7ec5e14ef4	patient	87fb3c88-6653-45db-aa6c-20ea7512da64	1	clara.pelayo.1954@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.621306+00	2025-11-22 04:41:38.621306+00
2e669612-b05d-4f4d-a467-9ad5a045ba97	patient	05e42aed-c457-4579-904f-d397be3075f7	1	santiago.armendariz.2001@toledo.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.626398+00	2025-11-22 04:41:38.626398+00
cd7fc0d7-b7bd-44a8-83d4-b6f5597f7b0c	patient	43756f6c-c157-4a44-9c84-ab2d62fddcf7	1	carlos.menchaca.1949@proyectos.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.630633+00	2025-11-22 04:41:38.630633+00
b3c8bec0-e81e-45dc-b051-66dc927a6903	patient	d8e1fa52-0a65-4917-b410-2954e05a34e5	1	manuel.gracia.1978@rolon.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.63399+00	2025-11-22 04:41:38.63399+00
e5ff3833-ca21-4c21-98a3-63ad88abecc5	patient	bbc67f38-a9eb-4379-aeaf-1560af0d1a34	1	jos.perea.2000@pulido.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.639745+00	2025-11-22 04:41:38.639745+00
7f5d3925-5619-4020-8165-d53e02b37e0b	patient	b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	1	esparta.franco.1987@laboy.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.642972+00	2025-11-22 04:41:38.642972+00
bb53b66c-d1e2-465f-9c2a-a0fbf3cf1a55	patient	309df411-1d1a-4d00-a34e-36e8c32da210	1	joseluis.miramontes.1951@tamayo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.646278+00	2025-11-22 04:41:38.646278+00
e78b9be1-32b8-4867-8e59-b4fc7bfc123d	patient	663d036b-a19b-4557-af37-d68a9ce4976d	1	amalia.arenas.1975@club.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.658826+00	2025-11-22 04:41:38.658826+00
2fd3efad-2580-45bc-9274-88df90eb7c61	patient	a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	1	angelica.serrato.1960@pina-almanza.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.668728+00	2025-11-22 04:41:38.668728+00
818002e4-7c06-488b-818c-f4ae0d74f98c	patient	d5b1779e-21f2-4252-a421-f2aaf9998916	1	pascual.barragan.1977@club.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.675181+00	2025-11-22 04:41:38.675181+00
fe6c0c04-94f4-4d87-ae8c-fe6dc2ca9be1	patient	6661483b-705b-412a-8bbd-39c0af0dadb1	1	jesus.abreu.1955@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.680016+00	2025-11-22 04:41:38.680016+00
ac7b9e24-fb2b-4f17-8a55-52858ab428d1	patient	676491c4-f31a-42b6-a991-a8dd09bbb1f0	1	victor.espinosa.1988@cepeda.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.684449+00	2025-11-22 04:41:38.684449+00
0fe59c03-84fc-4745-a7c3-28ef5af16515	patient	3a9e8e0e-6367-409d-a81c-9852069c710e	1	mariajose.villasenor.1949@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.688329+00	2025-11-22 04:41:38.688329+00
52533eeb-5e10-4757-b8b3-c2afcfde7d6d	patient	167dedde-166c-45e4-befc-4f1c9b7184ad	1	camilo.villa.1998@laboratorios.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.693572+00	2025-11-22 04:41:38.693572+00
c0203785-0fdf-4cf7-a021-a6757ed4bd76	patient	72eca572-4ecf-4be8-906b-40e89e0d9a08	1	mario.santillan.1966@garcia-benitez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.697922+00	2025-11-22 04:41:38.697922+00
b8deaa49-e755-49e7-a805-f6e6f92412ae	patient	d5bec069-a317-4a40-b3e8-ea80220d75de	1	cristobal.paez.1961@bernal.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.702076+00	2025-11-22 04:41:38.702076+00
a76d23ab-ac3f-4534-95d0-178e9d2bfeba	patient	0e97294d-78cc-4428-a172-e4e1fd4efa72	1	celia.olivo.1961@espinosa.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.705646+00	2025-11-22 04:41:38.705646+00
57311613-058f-4045-bf8e-c3681e561aea	patient	9f86a53f-f0e1-446d-89f0-86b086dd12a9	1	teresa.arguello.1949@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.710635+00	2025-11-22 04:41:38.710635+00
390a4bd1-0c7e-4cbf-8200-d2bf54dba424	patient	ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	1	pilar.valle.1981@industrias.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.716212+00	2025-11-22 04:41:38.716212+00
36dfc5e5-5eca-4e63-b14c-ca264b3408ae	patient	d28440a6-3bd9-4a48-8a72-d700ae0971e4	1	eva.orellana.1988@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.720096+00	2025-11-22 04:41:38.720096+00
341d3fc6-cce2-4613-9c10-52ed50c0bb47	patient	7f839ee8-bdd6-4a63-83e8-30db007565e2	1	rafael.olvera.1946@corporacin.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.723343+00	2025-11-22 04:41:38.723343+00
03ee2da4-0f40-4a4d-bf78-7490e739ebc5	patient	67aa999f-9d31-4b61-a097-35097ea0d082	1	anel.baeza.1997@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.726245+00	2025-11-22 04:41:38.726245+00
b85e6f7e-110d-4012-8dd6-c733dcdbc15c	patient	41aa2fbc-8ef4-4448-8686-399a1cd54be9	1	jesus.negron.1966@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.730582+00	2025-11-22 04:41:38.730582+00
67784bcc-15b0-408e-af54-007cdcf4b705	patient	111769f3-1a1b-44a9-9670-f4f2e424d1d2	1	asuncion.ybarra.2000@pacheco.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.734796+00	2025-11-22 04:41:38.734796+00
c47d9d45-960d-4213-a5c9-8a772c6c94e1	patient	2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	1	roberto.varela.1961@sandoval.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.737717+00	2025-11-22 04:41:38.737717+00
f2c0b351-b2c8-45e7-b55c-b837d55ec399	patient	6a8b6d41-8d20-4bc5-8d48-538d348f6086	1	alejandra.acosta.1950@espino-cotto.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.741882+00	2025-11-22 04:41:38.741882+00
5aff557d-1544-4254-903e-6eb78c17f52e	patient	89657c95-84c0-4bd0-80c6-70a2c4721276	1	minerva.ortiz.1985@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.746763+00	2025-11-22 04:41:38.746763+00
b871ab58-154f-4672-9fbf-2c8b1235414f	patient	b6658dac-0ee1-415c-95ad-28c6acea85bd	1	amanda.menendez.1966@palacios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.751411+00	2025-11-22 04:41:38.751411+00
36fbab98-0ea6-4b4a-8c27-df22a701445b	patient	56564104-6009-466c-9134-c15d3175613b	1	hermelinda.medrano.1970@grupo.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.754796+00	2025-11-22 04:41:38.754796+00
67f3974a-81ab-4281-9c04-018be4946651	patient	edb1d693-b308-4ff6-8fd4-9e20561317e8	1	alonso.roldan.1960@laboratorios.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.758378+00	2025-11-22 04:41:38.758378+00
680d0f32-3f2b-4686-8ef3-03616455ee60	patient	9511f9b9-a450-489c-92b9-ac306733cee4	1	alma.sosa.2001@montoya.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.762712+00	2025-11-22 04:41:38.762712+00
d6554a96-dd18-4d0e-9183-30d7ea2c5629	patient	004ce58b-6a0d-4646-92c3-4508deb6b354	1	estela.lucero.1979@corporacin.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.767321+00	2025-11-22 04:41:38.767321+00
5263c4af-ae08-422a-b021-f52b0fa8b069	patient	0d1bcc20-a5be-40f0-a28b-23c2c77c51be	1	gonzalo.laureano.1979@despacho.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.771418+00	2025-11-22 04:41:38.771418+00
a510eb93-54d4-458e-8c57-26b39163e8e6	patient	38000dbb-417f-43ca-a60e-5812796420f7	1	helena.muro.1973@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.7744+00	2025-11-22 04:41:38.7744+00
2a8f3248-fb8c-489f-98da-7fecb37454dc	patient	5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	1	adela.vergara.1991@baeza.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.778218+00	2025-11-22 04:41:38.778218+00
3393b7aa-0806-4829-aefb-deb7a9de63c2	patient	561c313d-2c15-41b1-b965-a38c8e0f6c42	1	salma.almaraz.1994@despacho.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.782168+00	2025-11-22 04:41:38.782168+00
ccc78f67-fbe8-412a-aebd-9efed1f4b4d5	patient	ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	1	humberto.caraballo.1946@llamas-ulibarri.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.786421+00	2025-11-22 04:41:38.786421+00
441c58a2-7b9d-4ccc-954a-ed1ef01cb717	patient	cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	1	mauricio.zavala.1997@montano.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.790587+00	2025-11-22 04:41:38.790587+00
cae710ff-5f08-49cf-878d-406299850afb	patient	05bc2942-e676-42e9-ad01-ade9f7cc5aee	1	roberto.alejandro.1960@jaime.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.794672+00	2025-11-22 04:41:38.794672+00
af1ecf35-a5cf-4bb9-85ff-811a9a2a640d	patient	c78e7658-d517-4ca1-990b-e6971f8d108f	1	victor.gutierrez.1983@proyectos.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.797939+00	2025-11-22 04:41:38.797939+00
d9fef87c-8efb-4579-b9f1-daf1ec1c4ae9	patient	65474c27-8f72-4690-8f19-df9344e4be5e	1	adan.nava.2000@gonzalez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.800817+00	2025-11-22 04:41:38.800817+00
23a3f95d-7f68-4a76-8903-76c778bf4edf	patient	c1b6fa98-203a-4321-96cd-e80e7a1c9461	1	amador.cano.1995@toledo-arevalo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.804558+00	2025-11-22 04:41:38.804558+00
cd50fbb7-32d0-4f4b-882f-4f9260bf23d3	patient	9244b388-8c06-42c7-9c4e-cbaae5b1baa3	1	alfonso.prado.1955@salazar.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.809057+00	2025-11-22 04:41:38.809057+00
7d4646e1-1c90-411b-b30b-793cdd1a4015	patient	eb2e55f6-4738-4352-a59a-860909f1932c	1	uriel.suarez.1972@narvaez-arguello.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.813578+00	2025-11-22 04:41:38.813578+00
42ca095f-c27d-48a0-8dd7-dc08d271d928	patient	c572a4c7-e475-4d18-85da-417abcd00903	1	armando.porras.1954@hernandes-rendon.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.818541+00	2025-11-22 04:41:38.818541+00
0f1e3121-af76-4501-8a51-66e73ddaf5e0	patient	5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	1	teresa.granado.1953@osorio.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.821555+00	2025-11-22 04:41:38.821555+00
c638de4c-40a9-4a4f-adfe-884027bacfea	patient	9b02d89c-2c5b-4c51-8183-15ccd1184990	1	marcela.fernandez.1981@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.825984+00	2025-11-22 04:41:38.825984+00
6fb50df4-557e-42a8-a0b6-03564eb56d99	patient	43ae2e81-ac13-40ac-949c-9e4f51d76098	1	sergio.loya.1970@avalos-garrido.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.830611+00	2025-11-22 04:41:38.830611+00
795e50c3-2b54-4468-9f72-68ef5c8bb7b6	patient	49a18092-8f90-4f6b-873c-8715b64b8aff	1	jorgeluis.molina.1953@burgos-loya.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.834624+00	2025-11-22 04:41:38.834624+00
d98d2eaf-8228-4013-b6f0-d32f07b0e0e5	patient	c9a949e5-e650-4d95-9e2e-49ed06e5d087	1	elvira.echeverria.1970@granado-miramontes.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.837678+00	2025-11-22 04:41:38.837678+00
2705af58-7864-48fa-8b0d-baf49ea343d2	patient	a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	1	federico.fajardo.1949@proyectos.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.840505+00	2025-11-22 04:41:38.840505+00
64027fcc-911f-4570-802a-fb2b0994d5e0	patient	447e48dc-861c-41e6-920e-a2dec785101f	1	elena.quintanilla.1979@patino-vallejo.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.845297+00	2025-11-22 04:41:38.845297+00
66bebcb2-ccb2-4540-9e83-790baff75c5d	patient	3a535951-40fd-4959-a34e-07b29f675ecc	1	cynthia.jurado.1991@vasquez-ordonez.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.849461+00	2025-11-22 04:41:38.849461+00
4bda4f7e-03df-4ffc-9b18-f392abbf4f3e	patient	d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	1	juana.gurule.1993@despacho.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.853791+00	2025-11-22 04:41:38.853791+00
c35b428e-8775-4177-969d-3226eed2f26b	patient	6052a417-6725-4fab-b7dd-7f498454cd47	1	lilia.mesa.1956@escalante-nino.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.85718+00	2025-11-22 04:41:38.85718+00
3eb4fd0c-232e-460e-9a14-9823d78fb785	patient	dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	1	octavio.gurule.2004@gaytan.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.861561+00	2025-11-22 04:41:38.861561+00
3c3c13ad-998d-466f-912d-bec825ffa19f	patient	cbd398cc-dfde-41c4-b7b1-ca32cc99945f	1	reina.rangel.1975@alcantar.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.865773+00	2025-11-22 04:41:38.865773+00
fd81db51-e451-436c-ac5e-b55ad56710fa	patient	f740b251-4264-4220-8400-706331f650af	1	estefania.vanegas.1946@ortega-meza.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.870646+00	2025-11-22 04:41:38.870646+00
89f5e7f6-54a0-4115-bcf0-7da0db9007d3	patient	fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	1	alfredo.holguin.1963@ordonez-urbina.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.873954+00	2025-11-22 04:41:38.873954+00
5984d118-0c76-4863-bb0b-2246656d5469	patient	97d5d278-c876-4078-9dba-2940edfed9a0	1	reynaldo.meza.1997@club.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.87828+00	2025-11-22 04:41:38.87828+00
89d3c1c5-5039-4e39-b041-0c8abe4d902d	patient	a329242d-9e38-4178-aa8e-5b7497209897	1	daniel.caban.1964@gamboa.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.882604+00	2025-11-22 04:41:38.882604+00
7a5f0f04-5bfc-4f3d-b5ed-8ce4dcf665b0	patient	fe2cc660-dd15-4d31-ac72-56114bdb6b92	1	graciela.bonilla.1997@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.887862+00	2025-11-22 04:41:38.887862+00
b2849be8-70e2-4bb4-a5b9-e86516454dc2	patient	fd01c50f-f3dd-4517-96c0-c0e65330a692	1	jaqueline.olivas.1950@verdugo.org	t	t	\N	\N	0	\N	2025-11-22 04:41:38.892836+00	2025-11-22 04:41:38.892836+00
ce509143-9eae-4a58-b77e-56d494e072c8	patient	f56cc0bc-1765-4334-9594-73dcc9deac8e	1	leonardo.mateo.1966@verdugo-oquendo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.895882+00	2025-11-22 04:41:38.895882+00
4cdb1b04-a9b5-416a-9108-6acfd83c61f9	patient	1c861cbf-991d-4820-b3f0-98538fb0d454	1	antonio.sosa.1959@rolon-casillas.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.898848+00	2025-11-22 04:41:38.898848+00
9be4fd15-b265-4a71-b6af-9fe750743e6b	patient	70f066e1-fc10-4b37-92ea-0de96307793b	1	cristobal.chavez.2006@solis.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.902002+00	2025-11-22 04:41:38.902002+00
2513d706-0749-4bcb-8a83-e7608ab6a660	patient	d1ec4069-41a0-4317-a6c6-84914d108257	1	jaqueline.negrete.1973@mares.net	t	t	\N	\N	0	\N	2025-11-22 04:41:38.905328+00	2025-11-22 04:41:38.905328+00
d7c9b43d-a115-44e5-9a73-b50c76491150	patient	04239007-edaa-4c74-95dd-4ba4df226b0f	1	esteban.rios.1991@industrias.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.911562+00	2025-11-22 04:41:38.911562+00
ed71371f-b584-4c2a-bd23-8e4f3464d7f5	patient	0deef39b-719e-4f3a-a84f-2072803b2548	1	zoe.gaona.1953@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.915601+00	2025-11-22 04:41:38.915601+00
92625946-d3c6-4582-9ad5-c7bbab67dd1d	patient	5156864c-fa59-4e48-b357-477838800efc	1	ana.saenz.1967@loera.biz	t	t	\N	\N	0	\N	2025-11-22 04:41:38.921557+00	2025-11-22 04:41:38.921557+00
7f49c5db-35b5-40a9-a877-47ca178d48ce	patient	d911f0a5-9268-4eb4-87e9-508d7c99b753	1	vanesa.nava.1996@laboy-puente.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.925633+00	2025-11-22 04:41:38.925633+00
2592aea5-284b-4edd-9dd0-37bc9d485767	patient	c3e065c2-c0a9-440f-98f3-1c5463949056	1	diana.ceja.1969@soria.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.931606+00	2025-11-22 04:41:38.931606+00
eb907e24-1e22-4c72-93c0-843af3c2eff7	patient	b2eef54b-21a7-45ec-a693-bc60f1d6e293	1	emilio.delarosa.1946@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.934642+00	2025-11-22 04:41:38.934642+00
e7179d4c-6e55-4560-8997-604564c6c7bd	patient	3854a76e-ee29-4976-b630-1d7e18fb9887	1	monica.delarosa.1978@ulloa.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.937469+00	2025-11-22 04:41:38.937469+00
491eac17-51e6-45d7-99ca-82f91a270fa3	patient	6b2e25e9-ebcb-4150-a594-c5742cd42121	1	reynaldo.garcia.1966@uribe.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.940594+00	2025-11-22 04:41:38.940594+00
2822d354-a001-4b78-b091-0660cff423e6	patient	cc38cb13-51a5-4539-99c2-894cd2b207f1	1	geronimo.pedraza.1972@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.9448+00	2025-11-22 04:41:38.9448+00
a2e2a695-bd4d-4507-bc80-0671e6ca7333	patient	6af409b5-c8b8-4664-97cd-d419eedcc932	1	abelardo.barraza.1981@reyna-samaniego.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.947282+00	2025-11-22 04:41:38.947282+00
72b7d028-61d4-4c18-a078-e330aca4a0a0	patient	227a2c03-dfd1-4e03-9c04-daaf74fc68bd	1	noelia.toro.1948@escobar.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.950216+00	2025-11-22 04:41:38.950216+00
3745ac0c-48a8-4d3e-9fc0-6d06afce73ef	patient	bc6e7a77-d709-401c-bea7-82715eeb1a29	1	ines.tellez.2001@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.953195+00	2025-11-22 04:41:38.953195+00
a0570660-6fa9-4152-8741-a7cd93f15a8a	patient	d54d7239-e49a-4185-8875-4f71af08b789	1	hector.maldonado.1974@grupo.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.95716+00	2025-11-22 04:41:38.95716+00
a397fc07-a206-447b-bf32-a87153294606	patient	8370857e-7e69-43a6-be63-78fc270c5fd5	1	jonas.segura.1969@loera-granados.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.961457+00	2025-11-22 04:41:38.961457+00
cb51da34-327a-4ebc-9e88-f1efd9b71d22	patient	e8813bf8-7bbb-4370-a181-880c0c959aa1	1	joseluis.gomez.2003@del.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.9657+00	2025-11-22 04:41:38.9657+00
cf6850a2-9eef-4009-b888-f1a63dea359f	patient	4337bfc4-5ea7-4621-bd24-dbf3f55e350a	1	fernando.gil.1947@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.968933+00	2025-11-22 04:41:38.968933+00
17b20b24-d4c8-44e3-84f7-8f38f341f5ab	patient	517958b1-f860-4a42-965b-15a796055981	1	angela.montanez.1974@club.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.973048+00	2025-11-22 04:41:38.973048+00
42e58eb5-c60d-472c-a6ff-03779755a4a9	patient	44e4c099-cf6e-4926-85f1-ab5cb34c59a1	1	leonor.olivera.1953@galarza-soliz.info	t	t	\N	\N	0	\N	2025-11-22 04:41:38.97689+00	2025-11-22 04:41:38.97689+00
f3a24637-84e9-4a4c-b3f1-f8d0b7a21ef1	patient	a0c3c815-c664-4931-927f-e4109a545603	1	gabino.aguirre.1951@laboratorios.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.982699+00	2025-11-22 04:41:38.982699+00
f4736851-f313-4ec2-a55a-093d51f50f7a	patient	5c1862f6-f802-41ae-a6fb-87dbc5555fb3	1	judith.aleman.1976@molina.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.98562+00	2025-11-22 04:41:38.98562+00
cdbb1d06-dc2f-4d89-a0b8-f4627fa2526c	patient	11d31cb4-1dfb-479e-9329-8b8b35920b98	1	oswaldo.fuentes.1989@castro-rosario.com	t	t	\N	\N	0	\N	2025-11-22 04:41:38.989891+00	2025-11-22 04:41:38.989891+00
\.


--
-- Data for Name: genders; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.genders (id, name, display_name, description, is_active, created_at) FROM stdin;
1	male	Male	Male gender identity	t	2025-11-22 04:17:09.887299+00
2	female	Female	Female gender identity	t	2025-11-22 04:17:09.887299+00
3	non_binary	Non-binary	Non-binary gender identity	t	2025-11-22 04:17:09.887299+00
4	genderqueer	Genderqueer	Genderqueer identity	t	2025-11-22 04:17:09.887299+00
5	genderfluid	Genderfluid	Genderfluid identity	t	2025-11-22 04:17:09.887299+00
6	agender	Agender	Agender identity	t	2025-11-22 04:17:09.887299+00
7	other	Other	Other gender identity	t	2025-11-22 04:17:09.887299+00
8	prefer_not_to_say	Prefer not to say	Prefers not to disclose gender identity	t	2025-11-22 04:17:09.887299+00
\.


--
-- Data for Name: health_profiles; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.health_profiles (id, patient_id, height_cm, weight_kg, blood_type_id, is_smoker, smoking_years, consumes_alcohol, alcohol_frequency, physical_activity_minutes_weekly, notes, created_at, updated_at) FROM stdin;
b292c42d-4cc5-43b2-9397-bf1c69c38288	31000000-e29b-41d4-a716-446655440001	172.00	75.50	1	f	0	t	occasionally	210	Hypertension diagnosed 3 years ago	2025-11-22 04:17:10.251306+00	2025-11-22 04:17:10.251306+00
344175ae-7298-4cca-83ec-babe1edf69f5	32000000-e29b-41d4-a716-446655440002	165.00	62.00	8	f	0	f	never	300	No significant conditions	2025-11-22 04:17:10.251306+00	2025-11-22 04:17:10.251306+00
69057aa8-a516-4b3a-b2c6-aa6420f3e5dc	33000000-e29b-41d4-a716-446655440003	178.00	82.00	3	t	8	t	regularly	150	Type 2 diabetes diagnosed 2 years ago	2025-11-22 04:17:10.251306+00	2025-11-22 04:17:10.251306+00
662492ea-db99-4d67-bb15-d852ca0aa507	34000000-e29b-41d4-a716-446655440004	160.00	58.00	5	f	0	t	rarely	180	Previous stroke 5 years ago, hypertension	2025-11-22 04:17:10.251306+00	2025-11-22 04:17:10.251306+00
ef29c087-422a-4cf0-9a2e-6c3d373594f0	35000000-e29b-41d4-a716-446655440005	185.00	90.00	7	f	0	t	occasionally	420	No significant conditions	2025-11-22 04:17:10.251306+00	2025-11-22 04:17:10.251306+00
\.


--
-- Data for Name: institution_types; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.institution_types (id, name, description, category, is_active, created_at) FROM stdin;
1	hospital	General or specialized hospital providing inpatient and outpatient care	healthcare	t	2025-11-22 04:17:09.863443+00
2	preventive_clinic	Clinic focused on preventive medicine and health promotion	healthcare	t	2025-11-22 04:17:09.863443+00
3	health_center	Primary healthcare center for basic medical services	healthcare	t	2025-11-22 04:17:09.863443+00
4	insurer	Health insurance company or provider	insurance	t	2025-11-22 04:17:09.863443+00
5	public_health	Public health organization or government agency	healthcare	t	2025-11-22 04:17:09.863443+00
6	pharmacy	Retail pharmacy or pharmaceutical services	pharmacy	t	2025-11-22 04:17:09.863443+00
7	research	Medical research institution or laboratory	research	t	2025-11-22 04:17:09.863443+00
8	education	Medical education or training institution	education	t	2025-11-22 04:17:09.863443+00
\.


--
-- Data for Name: medical_conditions; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.medical_conditions (id, name, description) FROM stdin;
1	Hypertension	Presión arterial elevada que requiere manejo médico
2	Diabetes Mellitus Type 2	Trastorno metabólico caracterizado por hiperglucemia
3	High Cholesterol	Niveles elevados de colesterol en sangre
4	Stroke History	Antecedentes de accidente cerebrovascular
5	Heart Disease History	Antecedentes de enfermedad cardiovascular
6	Asthma	Enfermedad respiratoria crónica con obstrucción bronquial
7	Chronic Obstructive Pulmonary Disease	Enfermedad pulmonar obstructiva crónica
8	Depression	Trastorno del estado de ánimo con síntomas persistentes
9	Anxiety Disorder	Trastorno caracterizado por ansiedad excesiva
10	Osteoarthritis	Degeneración del cartílago articular
11	Rheumatoid Arthritis	Enfermedad autoinmune que afecta las articulaciones
12	Hypothyroidism	Disminución de la función tiroidea
13	Hyperthyroidism	Aumento de la función tiroidea
14	Chronic Kidney Disease	Enfermedad renal crónica
15	Gastroesophageal Reflux Disease	Reflujo gastroesofágico patológico
16	Irritable Bowel Syndrome	Síndrome de intestino irritable
17	Migraine	Cefalea recurrente intensa
18	Obesity	Exceso de peso corporal con riesgo para la salud
19	Sleep Apnea	Apnea obstructiva del sueño
20	Atrial Fibrillation	Fibrilación auricular
\.


--
-- Data for Name: medical_institutions; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.medical_institutions (id, name, institution_type_id, website, license_number, created_at, updated_at, is_active, is_verified, last_login) FROM stdin;
11000000-e29b-41d4-a716-446655440001	Hospital General del Centro	1	https://hospital-general.predicthealth.com	LIC-MX-HOSP-001	2025-11-22 04:17:09.975032+00	2025-11-22 04:17:09.975032+00	t	t	\N
12000000-e29b-41d4-a716-446655440002	Clínica Familiar del Norte	2	https://clinica-norte.predicthealth.com	LIC-MX-CLIN-002	2025-11-22 04:17:09.975032+00	2025-11-22 04:17:09.975032+00	t	t	\N
13000000-e29b-41d4-a716-446655440003	Centro de Salud Preventiva Sur	2	https://centro-salud-sur.predicthealth.com	LIC-MX-PREV-003	2025-11-22 04:17:09.975032+00	2025-11-22 04:17:09.975032+00	t	t	\N
14000000-e29b-41d4-a716-446655440004	Instituto Cardiovascular del Bajío	3	https://cardiovascular-bajio.predicthealth.com	LIC-MX-CARD-004	2025-11-22 04:17:09.975032+00	2025-11-22 04:17:09.975032+00	t	t	\N
15000000-e29b-41d4-a716-446655440005	Centro Médico del Pacífico	1	https://medico-pacifico.predicthealth.com	LIC-MX-MEDP-005	2025-11-22 04:17:09.975032+00	2025-11-22 04:17:09.975032+00	t	t	\N
163749fb-8b46-4447-a8b7-95b4a59531b6	Despacho Grijalva, Mascare??as y Parra	1	https://despacho-grijalva-mascarenas-y-parra.predicthealth.com	LIC-MX-HOSP-101	2025-11-22 04:41:35.160635+00	2025-11-22 04:41:35.160635+00	t	t	\N
83b74179-f6ef-4219-bc70-c93f4393a350	Laboratorios Saldivar, Santill??n y Villanueva	3	https://laboratorios-saldivar-santillan-y-villanueva.predicthealth.com	LIC-MX-HEAL-102	2025-11-22 04:41:35.16553+00	2025-11-22 04:41:35.16553+00	t	t	\N
50503414-ca6d-4c1a-a34f-18719e2fd555	Trejo-Vigil e Hijos	2	https://trejo-vigil-e-hijos.predicthealth.com	LIC-MX-PREV-103	2025-11-22 04:41:35.168903+00	2025-11-22 04:41:35.168903+00	t	t	\N
9b581d3c-9e93-4f39-80bb-294752065866	Club Barajas, del Valle y Carrero	3	https://club-barajas-del-valle-y-carrero.predicthealth.com	LIC-MX-HEAL-104	2025-11-22 04:41:35.172175+00	2025-11-22 04:41:35.172175+00	t	t	\N
e0e34926-8d48-4db0-afb9-b20b6eeb1ecb	Collazo-Barrientos	1	https://collazo-barrientos.predicthealth.com	LIC-MX-HOSP-105	2025-11-22 04:41:35.175248+00	2025-11-22 04:41:35.175248+00	t	t	\N
81941e1d-820a-4313-8177-e44278d9a981	Corporacin Prado, D??vila y Noriega	3	https://corporacin-prado-davila-y-noriega.predicthealth.com	LIC-MX-HEAL-106	2025-11-22 04:41:35.177959+00	2025-11-22 04:41:35.177959+00	t	t	\N
a725b15f-039b-4256-843a-51a2968633fd	Corporacin Navarro-Collado	1	https://corporacin-navarro-collado.predicthealth.com	LIC-MX-HOSP-107	2025-11-22 04:41:35.181107+00	2025-11-22 04:41:35.181107+00	t	t	\N
0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d	Iglesias, Soria y Chac??n	1	https://iglesias-soria-y-chacon.predicthealth.com	LIC-MX-HOSP-108	2025-11-22 04:41:35.184013+00	2025-11-22 04:41:35.184013+00	t	t	\N
d471d2d1-66a1-4de0-8754-127059786888	Castillo-Zayas	2	https://castillo-zayas.predicthealth.com	LIC-MX-PREV-109	2025-11-22 04:41:35.186938+00	2025-11-22 04:41:35.186938+00	t	t	\N
8fd698b3-084d-4248-a28e-2708a5862e27	Club Mesa y Riojas	1	https://club-mesa-y-riojas.predicthealth.com	LIC-MX-HOSP-110	2025-11-22 04:41:35.190173+00	2025-11-22 04:41:35.190173+00	t	t	\N
7b96a7bb-041f-4331-be05-e97cab7dafc0	Ojeda y Baca S. R.L. de C.V.	1	https://ojeda-y-baca-s-r-l-de-c-v.predicthealth.com	LIC-MX-HOSP-111	2025-11-22 04:41:35.193187+00	2025-11-22 04:41:35.193187+00	t	t	\N
5da54d5d-de0c-4277-a43e-6a89f987e77c	Murillo y Quintanilla S.A.	1	https://murillo-y-quintanilla-s-a.predicthealth.com	LIC-MX-HOSP-112	2025-11-22 04:41:35.196415+00	2025-11-22 04:41:35.196415+00	t	t	\N
c9014e88-309c-4cb0-a28d-25b510e1e522	Grupo Collazo, Hinojosa y Vald??s	1	https://grupo-collazo-hinojosa-y-valdes.predicthealth.com	LIC-MX-HOSP-113	2025-11-22 04:41:35.199372+00	2025-11-22 04:41:35.199372+00	t	t	\N
8e889f63-2c86-44ab-959f-fdc365353d5d	Club Verdugo y Tejeda	2	https://club-verdugo-y-tejeda.predicthealth.com	LIC-MX-PREV-114	2025-11-22 04:41:35.202118+00	2025-11-22 04:41:35.202118+00	t	t	\N
67787f7c-fdee-4e30-80bd-89008ebfe419	Zaragoza e Hijos	3	https://zaragoza-e-hijos.predicthealth.com	LIC-MX-HEAL-115	2025-11-22 04:41:35.205065+00	2025-11-22 04:41:35.205065+00	t	t	\N
4721cb90-8fb0-4fd6-b19e-160b4ac0c744	Ceballos-Tello	1	https://ceballos-tello.predicthealth.com	LIC-MX-HOSP-116	2025-11-22 04:41:35.208154+00	2025-11-22 04:41:35.208154+00	t	t	\N
09c54a60-6267-4439-9c8b-8c9012842942	Ba??uelos e Hijos	2	https://banuelos-e-hijos.predicthealth.com	LIC-MX-PREV-117	2025-11-22 04:41:35.211098+00	2025-11-22 04:41:35.211098+00	t	t	\N
a670c73c-cc47-42fe-88c9-0fa37359779b	Despacho Jaramillo, Salas y Carrero	3	https://despacho-jaramillo-salas-y-carrero.predicthealth.com	LIC-MX-HEAL-118	2025-11-22 04:41:35.213707+00	2025-11-22 04:41:35.213707+00	t	t	\N
373769ab-b720-4269-bfb9-02546401ce99	P??ez-Navarro S.A.	3	https://paez-navarro-s-a.predicthealth.com	LIC-MX-HEAL-119	2025-11-22 04:41:35.2165+00	2025-11-22 04:41:35.2165+00	t	t	\N
ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	Proyectos Mata y Jurado	3	https://proyectos-mata-y-jurado.predicthealth.com	LIC-MX-HEAL-120	2025-11-22 04:41:35.219489+00	2025-11-22 04:41:35.219489+00	t	t	\N
2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	Laboratorios Trejo, Garc??a y Lucero	2	https://laboratorios-trejo-garcia-y-lucero.predicthealth.com	LIC-MX-PREV-121	2025-11-22 04:41:35.222444+00	2025-11-22 04:41:35.222444+00	t	t	\N
6c287a0e-9d4c-4574-932f-7d499aa4146c	Industrias Valverde y Leal	3	https://industrias-valverde-y-leal.predicthealth.com	LIC-MX-HEAL-122	2025-11-22 04:41:35.225504+00	2025-11-22 04:41:35.225504+00	t	t	\N
a14c189c-ee90-4c29-b465-63d43a9d0010	Castillo, Lugo y Zamora	2	https://castillo-lugo-y-zamora.predicthealth.com	LIC-MX-PREV-123	2025-11-22 04:41:35.228737+00	2025-11-22 04:41:35.228737+00	t	t	\N
e040eabc-0ac9-47f7-89ae-24246e1c12dd	Montenegro, Alcala y Nieves	3	https://montenegro-alcala-y-nieves.predicthealth.com	LIC-MX-HEAL-124	2025-11-22 04:41:35.232347+00	2025-11-22 04:41:35.232347+00	t	t	\N
9c8636c9-015b-4c18-a641-f5da698b6fd8	Montenegro y Pichardo S.A. de C.V.	1	https://montenegro-y-pichardo-s-a-de-c-v.predicthealth.com	LIC-MX-HOSP-125	2025-11-22 04:41:35.235188+00	2025-11-22 04:41:35.235188+00	t	t	\N
b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	Lucio-Marrero y Asociados	1	https://lucio-marrero-y-asociados.predicthealth.com	LIC-MX-HOSP-126	2025-11-22 04:41:35.238202+00	2025-11-22 04:41:35.238202+00	t	t	\N
146a692b-6d46-4c26-a165-092fe771400e	Proyectos Iglesias-Verdugo	2	https://proyectos-iglesias-verdugo.predicthealth.com	LIC-MX-PREV-127	2025-11-22 04:41:35.241251+00	2025-11-22 04:41:35.241251+00	t	t	\N
6297ae0f-7fee-472d-87ec-e22b87ce6ffb	Due??as-Esquivel S. R.L. de C.V.	3	https://duenas-esquivel-s-r-l-de-c-v.predicthealth.com	LIC-MX-HEAL-128	2025-11-22 04:41:35.244483+00	2025-11-22 04:41:35.244483+00	t	t	\N
66e6aa6c-596c-442e-85fb-b143875d0dfc	Valencia-Toro	1	https://valencia-toro.predicthealth.com	LIC-MX-HOSP-129	2025-11-22 04:41:35.247622+00	2025-11-22 04:41:35.247622+00	t	t	\N
46af545e-6db8-44ba-a7f9-9fd9617f4a09	Solano-Rodr??gez	3	https://solano-rodrigez.predicthealth.com	LIC-MX-HEAL-130	2025-11-22 04:41:35.250586+00	2025-11-22 04:41:35.250586+00	t	t	\N
a56b6787-94e9-49f0-8b3a-6ff5979773fc	Laboratorios V??squez-Zepeda	3	https://laboratorios-vasquez-zepeda.predicthealth.com	LIC-MX-HEAL-131	2025-11-22 04:41:35.253519+00	2025-11-22 04:41:35.253519+00	t	t	\N
d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	Club Monta??ez-Almaraz	2	https://club-montanez-almaraz.predicthealth.com	LIC-MX-PREV-132	2025-11-22 04:41:35.25648+00	2025-11-22 04:41:35.25648+00	t	t	\N
4bfa1a0a-0434-45e0-b454-03140b992f53	Proyectos Alvarez, God??nez y Est??vez	1	https://proyectos-alvarez-godinez-y-estevez.predicthealth.com	LIC-MX-HOSP-133	2025-11-22 04:41:35.259462+00	2025-11-22 04:41:35.259462+00	t	t	\N
33ba98b9-c46a-47c1-b266-d8a4fe557290	Grupo Carvajal, Murillo y Regalado	2	https://grupo-carvajal-murillo-y-regalado.predicthealth.com	LIC-MX-PREV-134	2025-11-22 04:41:35.262479+00	2025-11-22 04:41:35.262479+00	t	t	\N
f4764cd3-47e9-4408-b0ee-9b9001c5459d	Industrias Bahena, Nieto y Acosta	1	https://industrias-bahena-nieto-y-acosta.predicthealth.com	LIC-MX-HOSP-135	2025-11-22 04:41:35.265346+00	2025-11-22 04:41:35.265346+00	t	t	\N
f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8	Villag??mez S.A.	2	https://villagomez-s-a.predicthealth.com	LIC-MX-PREV-136	2025-11-22 04:41:35.268552+00	2025-11-22 04:41:35.268552+00	t	t	\N
219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	Lucero-Fajardo e Hijos	1	https://lucero-fajardo-e-hijos.predicthealth.com	LIC-MX-HOSP-137	2025-11-22 04:41:35.271287+00	2025-11-22 04:41:35.271287+00	t	t	\N
8be78aaa-c408-452e-bf01-8e831ab5c63a	Laboratorios Arellano-Rosas	1	https://laboratorios-arellano-rosas.predicthealth.com	LIC-MX-HOSP-138	2025-11-22 04:41:35.274381+00	2025-11-22 04:41:35.274381+00	t	t	\N
8fb0899c-732e-4f03-8209-d52ef41a6a76	Alba-Casas	3	https://alba-casas.predicthealth.com	LIC-MX-HEAL-139	2025-11-22 04:41:35.278071+00	2025-11-22 04:41:35.278071+00	t	t	\N
3a9084e7-74c5-4e0b-b786-2c93d9cd39ee	Club Zambrano, Arredondo y Guerra	3	https://club-zambrano-arredondo-y-guerra.predicthealth.com	LIC-MX-HEAL-140	2025-11-22 04:41:35.2812+00	2025-11-22 04:41:35.2812+00	t	t	\N
54481b92-e5f5-421b-ba21-89bf520a2d87	Club Ballesteros-Cornejo	2	https://club-ballesteros-cornejo.predicthealth.com	LIC-MX-PREV-141	2025-11-22 04:41:35.28423+00	2025-11-22 04:41:35.28423+00	t	t	\N
68f1a02a-d348-4d1e-99ee-733d832a3f43	Espinoza y Villegas A.C.	3	https://espinoza-y-villegas-a-c.predicthealth.com	LIC-MX-HEAL-142	2025-11-22 04:41:35.287432+00	2025-11-22 04:41:35.287432+00	t	t	\N
36983990-abe8-4f1c-9c1b-863b9cab3ca9	Alfaro, Pacheco y Villalpando	3	https://alfaro-pacheco-y-villalpando.predicthealth.com	LIC-MX-HEAL-143	2025-11-22 04:41:35.290441+00	2025-11-22 04:41:35.290441+00	t	t	\N
b654860f-ec74-42d6-955e-eeedde2df0dd	Grupo Ibarra y Elizondo	1	https://grupo-ibarra-y-elizondo.predicthealth.com	LIC-MX-HOSP-144	2025-11-22 04:41:35.294061+00	2025-11-22 04:41:35.294061+00	t	t	\N
be133600-848e-400b-9bc8-c52a4f3cf10d	??vila y Maestas S.A.	2	https://avila-y-maestas-s-a.predicthealth.com	LIC-MX-PREV-145	2025-11-22 04:41:35.296783+00	2025-11-22 04:41:35.296783+00	t	t	\N
25e918f3-692f-4f51-b630-4caa1dd825a1	Gast??lum y Guerrero y Asociados	3	https://gastelum-y-guerrero-y-asociados.predicthealth.com	LIC-MX-HEAL-146	2025-11-22 04:41:35.299563+00	2025-11-22 04:41:35.299563+00	t	t	\N
cc46221e-f387-463c-9d11-9464d8209f7b	Escobedo y Guerrero A.C.	2	https://escobedo-y-guerrero-a-c.predicthealth.com	LIC-MX-PREV-147	2025-11-22 04:41:35.302431+00	2025-11-22 04:41:35.302431+00	t	t	\N
a15d4a4b-1bc4-4ee5-a168-714f71d94e42	Laboratorios Cavazos y Valent??n	1	https://laboratorios-cavazos-y-valentin.predicthealth.com	LIC-MX-HOSP-148	2025-11-22 04:41:35.305466+00	2025-11-22 04:41:35.305466+00	t	t	\N
3d7c5771-0692-4a2f-a4c6-6af2b561282b	Leal-Valdez S.A. de C.V.	3	https://leal-valdez-s-a-de-c-v.predicthealth.com	LIC-MX-HEAL-149	2025-11-22 04:41:35.308574+00	2025-11-22 04:41:35.308574+00	t	t	\N
16b25a77-b84a-44ac-8540-c5bfa9b3b6b0	Carvajal y Ur??as A.C.	1	https://carvajal-y-urias-a-c.predicthealth.com	LIC-MX-HOSP-150	2025-11-22 04:41:35.311617+00	2025-11-22 04:41:35.311617+00	t	t	\N
2040ac28-7210-4fbd-9716-53872211bcd9	Alonso S.A.	1	https://alonso-s-a.predicthealth.com	LIC-MX-HOSP-151	2025-11-22 04:41:35.314655+00	2025-11-22 04:41:35.314655+00	t	t	\N
0d826581-b9d8-4828-8848-9332fe38d169	Arteaga-Malave	3	https://arteaga-malave.predicthealth.com	LIC-MX-HEAL-152	2025-11-22 04:41:35.317503+00	2025-11-22 04:41:35.317503+00	t	t	\N
c0595f94-c8f4-413c-a05c-7cfca773563c	Briones y Esquibel S.C.	2	https://briones-y-esquibel-s-c.predicthealth.com	LIC-MX-PREV-153	2025-11-22 04:41:35.320296+00	2025-11-22 04:41:35.320296+00	t	t	\N
a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5	Mares, Altamirano y Gil	2	https://mares-altamirano-y-gil.predicthealth.com	LIC-MX-PREV-154	2025-11-22 04:41:35.32351+00	2025-11-22 04:41:35.32351+00	t	t	\N
ad2c792b-5015-4238-b221-fa28e8b061fc	Corporacin Hurtado, Mart??nez y Bueno	3	https://corporacin-hurtado-martinez-y-bueno.predicthealth.com	LIC-MX-HEAL-155	2025-11-22 04:41:35.326855+00	2025-11-22 04:41:35.326855+00	t	t	\N
c3e96b10-f0ca-421e-b402-aba6d595cf27	Leyva y Saavedra e Hijos	2	https://leyva-y-saavedra-e-hijos.predicthealth.com	LIC-MX-PREV-156	2025-11-22 04:41:35.330326+00	2025-11-22 04:41:35.330326+00	t	t	\N
a5b1202a-9112-404b-b7de-ddf0f62711f8	Corporacin Pacheco, Hurtado y Holgu??n	1	https://corporacin-pacheco-hurtado-y-holguin.predicthealth.com	LIC-MX-HOSP-157	2025-11-22 04:41:35.33342+00	2025-11-22 04:41:35.33342+00	t	t	\N
ac6f8f54-21c8-475b-bea6-19e31643392d	Despacho Guerrero, Noriega y Zavala	2	https://despacho-guerrero-noriega-y-zavala.predicthealth.com	LIC-MX-PREV-158	2025-11-22 04:41:35.336332+00	2025-11-22 04:41:35.336332+00	t	t	\N
43dee983-676a-4e33-a6b0-f0a72f46d06c	Monta??o-Lira	1	https://montano-lira.predicthealth.com	LIC-MX-HOSP-159	2025-11-22 04:41:35.339352+00	2025-11-22 04:41:35.339352+00	t	t	\N
f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	Pelayo-Arenas	3	https://pelayo-arenas.predicthealth.com	LIC-MX-HEAL-160	2025-11-22 04:41:35.342577+00	2025-11-22 04:41:35.342577+00	t	t	\N
08a7fe9e-c043-4fed-89e4-93a416a20089	Gil y Coronado y Asociados	1	https://gil-y-coronado-y-asociados.predicthealth.com	LIC-MX-HOSP-161	2025-11-22 04:41:35.34544+00	2025-11-22 04:41:35.34544+00	t	t	\N
89ab21cf-089e-4210-8e29-269dfbd38d71	Crespo, Pe??a y Rosado	1	https://crespo-pena-y-rosado.predicthealth.com	LIC-MX-HOSP-162	2025-11-22 04:41:35.348143+00	2025-11-22 04:41:35.348143+00	t	t	\N
d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f	Jim??nez, Arroyo y Ram??n	1	https://jiminez-arroyo-y-ramon.predicthealth.com	LIC-MX-HOSP-163	2025-11-22 04:41:35.351037+00	2025-11-22 04:41:35.351037+00	t	t	\N
ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	de Le??n S.C.	3	https://de-leon-s-c.predicthealth.com	LIC-MX-HEAL-164	2025-11-22 04:41:35.354041+00	2025-11-22 04:41:35.354041+00	t	t	\N
3cf42c93-4941-4d8d-8656-aafa9e987177	Robles-Loera A.C.	1	https://robles-loera-a-c.predicthealth.com	LIC-MX-HOSP-165	2025-11-22 04:41:35.362702+00	2025-11-22 04:41:35.362702+00	t	t	\N
1926fa2a-dab7-420e-861b-c2b6dfe0174e	Industrias Ponce y Soto	2	https://industrias-ponce-y-soto.predicthealth.com	LIC-MX-PREV-166	2025-11-22 04:41:35.36563+00	2025-11-22 04:41:35.36563+00	t	t	\N
0b2f4464-5141-44a3-a26d-f8acc1fb955e	Madera S.A.	2	https://madera-s-a.predicthealth.com	LIC-MX-PREV-167	2025-11-22 04:41:35.36874+00	2025-11-22 04:41:35.36874+00	t	t	\N
1fec9665-52bc-49a7-b028-f0d78440463c	Proyectos Tejada, Ram??n y Caldera	1	https://proyectos-tejada-ramon-y-caldera.predicthealth.com	LIC-MX-HOSP-168	2025-11-22 04:41:35.371799+00	2025-11-22 04:41:35.371799+00	t	t	\N
50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	Est??vez-Carrera	3	https://estevez-carrera.predicthealth.com	LIC-MX-HEAL-169	2025-11-22 04:41:35.374747+00	2025-11-22 04:41:35.374747+00	t	t	\N
8cfdeaad-c727-4a4d-b5d5-b69dd43c0854	Laboratorios Puga, Coronado y Carmona	2	https://laboratorios-puga-coronado-y-carmona.predicthealth.com	LIC-MX-PREV-170	2025-11-22 04:41:35.377535+00	2025-11-22 04:41:35.377535+00	t	t	\N
7a6ce151-14b5-4d12-b6bb-1fba18636353	Menchaca-Vela S. R.L. de C.V.	1	https://menchaca-vela-s-r-l-de-c-v.predicthealth.com	LIC-MX-HOSP-171	2025-11-22 04:41:35.380167+00	2025-11-22 04:41:35.380167+00	t	t	\N
f1ab98f4-98de-420f-9c4b-c31eee92df21	Carre??n y Soliz S.C.	3	https://carreon-y-soliz-s-c.predicthealth.com	LIC-MX-HEAL-172	2025-11-22 04:41:35.383045+00	2025-11-22 04:41:35.383045+00	t	t	\N
a074c3ea-f255-4cf2-ae3f-727f9186be3c	Zarate-Solano	1	https://zarate-solano.predicthealth.com	LIC-MX-HOSP-173	2025-11-22 04:41:35.386094+00	2025-11-22 04:41:35.386094+00	t	t	\N
0e3821a8-80d6-4fa9-8313-3ed45b83c28b	de la Cr??z-Espinoza e Hijos	2	https://de-la-cruz-espinoza-e-hijos.predicthealth.com	LIC-MX-PREV-174	2025-11-22 04:41:35.38992+00	2025-11-22 04:41:35.38992+00	t	t	\N
3d521bc9-692d-4a0d-a3d7-80e816b86374	Laboratorios Vald??s-Ruelas	1	https://laboratorios-valdes-ruelas.predicthealth.com	LIC-MX-HOSP-175	2025-11-22 04:41:35.393105+00	2025-11-22 04:41:35.393105+00	t	t	\N
47393461-e570-448b-82b1-1cef15441262	Espinosa S. R.L. de C.V.	3	https://espinosa-s-r-l-de-c-v.predicthealth.com	LIC-MX-HEAL-176	2025-11-22 04:41:35.395985+00	2025-11-22 04:41:35.395985+00	t	t	\N
744b4a03-e575-4978-b10e-6c087c9e744b	Villarreal-Ocasio	2	https://villarreal-ocasio.predicthealth.com	LIC-MX-PREV-177	2025-11-22 04:41:35.398696+00	2025-11-22 04:41:35.398696+00	t	t	\N
9a18b839-1b93-44fb-9d8a-2ea12388e887	Corporacin Carrasco y L??pez	1	https://corporacin-carrasco-y-lopez.predicthealth.com	LIC-MX-HOSP-178	2025-11-22 04:41:35.402188+00	2025-11-22 04:41:35.402188+00	t	t	\N
1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	Cisneros-Concepci??n	1	https://cisneros-concepcion.predicthealth.com	LIC-MX-HOSP-179	2025-11-22 04:41:35.407087+00	2025-11-22 04:41:35.407087+00	t	t	\N
5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Jurado-Guardado	2	https://jurado-guardado.predicthealth.com	LIC-MX-PREV-180	2025-11-22 04:41:35.410924+00	2025-11-22 04:41:35.410924+00	t	t	\N
eea6be20-e19f-485f-ab54-537a7c28245f	Club P??rez y Godoy	2	https://club-perez-y-godoy.predicthealth.com	LIC-MX-PREV-181	2025-11-22 04:41:35.413764+00	2025-11-22 04:41:35.413764+00	t	t	\N
eb602cae-423a-455d-a22e-d47aea5eb650	de la Fuente-Arias	1	https://de-la-fuente-arias.predicthealth.com	LIC-MX-HOSP-182	2025-11-22 04:41:35.416926+00	2025-11-22 04:41:35.416926+00	t	t	\N
bb17faca-a7b2-4de8-bf29-2fcb569ef554	Hernandes-Leiva S.A.	3	https://hernandes-leiva-s-a.predicthealth.com	LIC-MX-HEAL-183	2025-11-22 04:41:35.41981+00	2025-11-22 04:41:35.41981+00	t	t	\N
44a33aab-1a23-4995-bd07-41f95b34fd57	Grupo Garza y Arellano	3	https://grupo-garza-y-arellano.predicthealth.com	LIC-MX-HEAL-184	2025-11-22 04:41:35.422887+00	2025-11-22 04:41:35.422887+00	t	t	\N
5462455f-fbe3-44c8-b0d1-0644c433aca6	Laboratorios Navarrete-Anaya	2	https://laboratorios-navarrete-anaya.predicthealth.com	LIC-MX-PREV-185	2025-11-22 04:41:35.425667+00	2025-11-22 04:41:35.425667+00	t	t	\N
d050617d-dc89-4f28-b546-9680dd1c5fad	Club Armas-Polanco	2	https://club-armas-polanco.predicthealth.com	LIC-MX-PREV-186	2025-11-22 04:41:35.428497+00	2025-11-22 04:41:35.428497+00	t	t	\N
7227444e-b122-48f4-8f01-2cda439507b1	Olivera, Lovato y Saavedra	3	https://olivera-lovato-y-saavedra.predicthealth.com	LIC-MX-HEAL-187	2025-11-22 04:41:35.431131+00	2025-11-22 04:41:35.431131+00	t	t	\N
d86c173a-8a1d-43b4-a0c1-c836afdc378b	Grupo Ochoa-Corrales	1	https://grupo-ochoa-corrales.predicthealth.com	LIC-MX-HOSP-188	2025-11-22 04:41:35.434118+00	2025-11-22 04:41:35.434118+00	t	t	\N
fb0a848d-4d51-4416-86bc-e568f694f9e7	Ba??uelos-Monta??o	2	https://banuelos-montano.predicthealth.com	LIC-MX-PREV-189	2025-11-22 04:41:35.436975+00	2025-11-22 04:41:35.436975+00	t	t	\N
ccccdffb-bc26-4d80-a590-0cd86dd5a1bc	Mel??ndez-Arriaga	1	https://melendez-arriaga.predicthealth.com	LIC-MX-HOSP-190	2025-11-22 04:41:35.440096+00	2025-11-22 04:41:35.440096+00	t	t	\N
8cb48822-4d4c-42ed-af7f-737d3107b1db	Corporacin Menchaca y Salgado	1	https://corporacin-menchaca-y-salgado.predicthealth.com	LIC-MX-HOSP-191	2025-11-22 04:41:35.442881+00	2025-11-22 04:41:35.442881+00	t	t	\N
700b8c76-7ad1-4453-9ce3-f598565c6452	Club Salcedo y Segura	2	https://club-salcedo-y-segura.predicthealth.com	LIC-MX-PREV-192	2025-11-22 04:41:35.445499+00	2025-11-22 04:41:35.445499+00	t	t	\N
d3cb7dc8-9240-4800-a1d9-bf65c5dac801	Grupo Rosas, Mena y Sandoval	3	https://grupo-rosas-mena-y-sandoval.predicthealth.com	LIC-MX-HEAL-193	2025-11-22 04:41:35.448362+00	2025-11-22 04:41:35.448362+00	t	t	\N
06c71356-e038-4c3d-bfea-7865acacb684	Club Otero, Valadez y Crespo	1	https://club-otero-valadez-y-crespo.predicthealth.com	LIC-MX-HOSP-194	2025-11-22 04:41:35.451452+00	2025-11-22 04:41:35.451452+00	t	t	\N
30e2b2ec-9553-454e-92a4-c1dc89609cbb	Industrias Esquibel, Mesa y Valle	1	https://industrias-esquibel-mesa-y-valle.predicthealth.com	LIC-MX-HOSP-195	2025-11-22 04:41:35.455155+00	2025-11-22 04:41:35.455155+00	t	t	\N
2eead5aa-095b-418a-bd02-e3a917971887	Calvillo y Benavides A.C.	2	https://calvillo-y-benavides-a-c.predicthealth.com	LIC-MX-PREV-196	2025-11-22 04:41:35.457879+00	2025-11-22 04:41:35.457879+00	t	t	\N
05afd7e1-bb93-4c83-90a7-48a65b6e7598	Industrias Ledesma, Jurado y Pantoja	2	https://industrias-ledesma-jurado-y-pantoja.predicthealth.com	LIC-MX-PREV-197	2025-11-22 04:41:35.46071+00	2025-11-22 04:41:35.46071+00	t	t	\N
5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	Cervantes-Peralta	3	https://cervantes-peralta.predicthealth.com	LIC-MX-HEAL-198	2025-11-22 04:41:35.463457+00	2025-11-22 04:41:35.463457+00	t	t	\N
454f4ba6-cb6d-4f27-9d76-08f5b358b484	Rico y Escobar S.A.	2	https://rico-y-escobar-s-a.predicthealth.com	LIC-MX-PREV-199	2025-11-22 04:41:35.466428+00	2025-11-22 04:41:35.466428+00	t	t	\N
389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	B??ez-Viera S.A.	2	https://baez-viera-s-a.predicthealth.com	LIC-MX-PREV-200	2025-11-22 04:41:35.469472+00	2025-11-22 04:41:35.469472+00	t	t	\N
\.


--
-- Data for Name: medications; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.medications (id, name, description) FROM stdin;
1	Lisinopril	Inhibidor de la ECA para hipertensión
2	Atorvastatin	Estatina para reducción de colesterol
3	Multivitamin	Suplemento vitamínico diario
4	Metformin	Antidiabético oral para diabetes tipo 2
5	Omeprazole	Inhibidor de bomba de protones para reflujo
6	Aspirin	Antiplaquetario para prevención cardiovascular
7	Losartan	Antagonista de receptores de angiotensina II
8	Simvastatin	Estatina para control de colesterol
9	Levothyroxine	Hormona tiroidea sintética
10	Prednisone	Corticosteroide para inflamación
11	Warfarin	Anticoagulante oral
12	Insulin Glargine	Insulina de acción prolongada
13	Albuterol	Broncodilatador para asma
14	Sertraline	Antidepresivo ISRS
15	Ibuprofen	Antiinflamatorio no esteroideo
16	Furosemide	Diurético de asa
17	Amlodipine	Bloqueador de canales de calcio
18	Gabapentin	Anticonvulsivante para neuralgia
19	Pantoprazole	Inhibidor de bomba de protones
20	Diazepam	Benzodiazepina ansiolítica
\.


--
-- Data for Name: patient_allergies; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.patient_allergies (patient_id, allergy_id, severity, reaction_description) FROM stdin;
31000000-e29b-41d4-a716-446655440001	1	severe	\N
32000000-e29b-41d4-a716-446655440002	2	\N	\N
33000000-e29b-41d4-a716-446655440003	1	moderate	\N
34000000-e29b-41d4-a716-446655440004	1	mild	\N
35000000-e29b-41d4-a716-446655440005	1	severe	\N
2f5622af-8528-4c85-8e16-3d175a4f2d15	19	moderate	Modo electoral actitud mira d.
2f5622af-8528-4c85-8e16-3d175a4f2d15	15	mild	Unas estaban m pueda violencia realizar suelo ellos.
fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	11	mild	Se mujer ya ya luz l??pez.
fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	9	mild	Desarrollo empresa ??poca humanos varias uni??n don tengo.
59402562-ce5f-450e-8e6c-9630514fe164	4	severe	Podemos actividades esa realidad.
0b6b8229-4027-4ec7-8bce-c805de96ced3	11	moderate	Dijo antonio tipo siquiera razones datos.
0b6b8229-4027-4ec7-8bce-c805de96ced3	20	severe	Uso serie blanca r??gimen cuenta electoral material.
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	14	severe	Pod??a am??rica dado a??o fuera mitad.
f2a1f62a-8030-4f65-b82d-ce7376b955bd	20	mild	Atenci??n proyectos entre bien.
cd0c2f0c-de08-439c-93c9-0feab1d433cc	14	mild	Familia socialista mantener san.
cd0c2f0c-de08-439c-93c9-0feab1d433cc	7	mild	Est?? mejor posici??n miguel chile ej??rcito pr??ctica.
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	17	mild	Propios muchos ni??os cuenta siglo peso llegado hacen.
87fb3c88-6653-45db-aa6c-20ea7512da64	17	severe	Contenido hora porque ya tratamiento.
05e42aed-c457-4579-904f-d397be3075f7	8	mild	Tarde plan otra ambiente usted guerra caracter??sticas.
05e42aed-c457-4579-904f-d397be3075f7	11	moderate	Diversos existen conocimiento hospital ocho.
b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	9	mild	Industria camino carta.
b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	10	moderate	Jorge manera mes hac??a.
309df411-1d1a-4d00-a34e-36e8c32da210	9	severe	Manos efecto padres.
309df411-1d1a-4d00-a34e-36e8c32da210	15	severe	Pone aquellas derecho nombre mano zona pa??ses.
d5b1779e-21f2-4252-a421-f2aaf9998916	13	severe	Deja informaci??n casos grupo ahora.
6661483b-705b-412a-8bbd-39c0af0dadb1	1	moderate	Color club pol??tica silencio puerta.
676491c4-f31a-42b6-a991-a8dd09bbb1f0	8	severe	Conciencia solamente ello mil muerte.
0e97294d-78cc-4428-a172-e4e1fd4efa72	5	mild	Naturaleza hermano presenta.
9f86a53f-f0e1-446d-89f0-86b086dd12a9	11	mild	Mismos vez nuestra cargo.
d28440a6-3bd9-4a48-8a72-d700ae0971e4	9	moderate	Pregunta comunicaci??n m??s primeras pedro premio.
7f839ee8-bdd6-4a63-83e8-30db007565e2	15	severe	Yo pas?? ten??an visita.
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	9	mild	Lado gran libros viejo figura francisco programas.
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	6	moderate	Aire hubiera pol??tico resulta debido esa propuesta.
89657c95-84c0-4bd0-80c6-70a2c4721276	8	moderate	Actual obras produce realizar comenz?? diversos miedo da.
b6658dac-0ee1-415c-95ad-28c6acea85bd	11	mild	Mismo torno interior afirm??.
b6658dac-0ee1-415c-95ad-28c6acea85bd	6	mild	Conocimiento ??rea conjunto iba.
56564104-6009-466c-9134-c15d3175613b	15	mild	Resto dicen lleg?? llevar lucha color.
56564104-6009-466c-9134-c15d3175613b	9	moderate	Tres hacen respecto voluntad materia paz.
edb1d693-b308-4ff6-8fd4-9e20561317e8	12	moderate	Respecto mujer estas suficiente.
edb1d693-b308-4ff6-8fd4-9e20561317e8	5	moderate	Ma??ana demasiado puerto.
9511f9b9-a450-489c-92b9-ac306733cee4	12	severe	Comercio mayores joven estoy podemos.
9511f9b9-a450-489c-92b9-ac306733cee4	16	severe	Corte hubiera mitad salud desde valores cosa.
004ce58b-6a0d-4646-92c3-4508deb6b354	16	moderate	Hora a??o demasiado muy.
004ce58b-6a0d-4646-92c3-4508deb6b354	13	mild	Visita pues salir trata.
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	20	severe	Diez lado tales realidad junio he.
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	18	severe	Espa??ola per??odo algo pol??ticas atenci??n esa.
38000dbb-417f-43ca-a60e-5812796420f7	16	severe	Podemos peque??o aquellas buscar millones siempre.
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	3	severe	Te ley est??n precisamente particular estos.
561c313d-2c15-41b1-b965-a38c8e0f6c42	10	moderate	He programas habr?? s??lo.
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	1	severe	Libre seguir vamos universidad.
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	17	severe	S quien octubre ciencia mucha posibilidad oro problemas.
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	16	mild	Bien mirada sala dejar quien expresi??n formas.
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	1	moderate	Llegar pol??ticos empresas fue hospital buen.
05bc2942-e676-42e9-ad01-ade9f7cc5aee	7	mild	Color presencia donde d??lares.
65474c27-8f72-4690-8f19-df9344e4be5e	12	severe	Poblaci??n posibilidad medio esos.
65474c27-8f72-4690-8f19-df9344e4be5e	17	moderate	Nuevas hacia natural peso junto tener.
c1b6fa98-203a-4321-96cd-e80e7a1c9461	3	moderate	??sta somos humano natural.
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	11	severe	Seg??n presenta me pol??tico ellas corte.
eb2e55f6-4738-4352-a59a-860909f1932c	10	mild	Llegado yo autoridades juicio hospital empresas ver.
eb2e55f6-4738-4352-a59a-860909f1932c	19	moderate	Movimiento pueda momento coraz??n.
c572a4c7-e475-4d18-85da-417abcd00903	18	moderate	Toma as?? muchas.
5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	7	severe	Energ??a cuya marco diez.
49a18092-8f90-4f6b-873c-8715b64b8aff	13	mild	Principales uni??n director tribunal sido prueba.
49a18092-8f90-4f6b-873c-8715b64b8aff	19	moderate	Calidad persona capacidad acto dejar realizar hab??a posici??n.
c9a949e5-e650-4d95-9e2e-49ed06e5d087	17	severe	Campa??a miembros all?? entre en crecimiento eso pueda.
a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	10	mild	Gobierno este jefe dan ??poca el encuentro precisamente.
a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	1	moderate	Sus vino primera a??n.
3a535951-40fd-4959-a34e-07b29f675ecc	3	severe	Hijo estuvo adelante proyectos.
d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	17	moderate	Electoral sea dec??a casos ser??a conocimiento hermano libros.
d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	16	mild	Tenido tener humano ha necesario paz.
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	7	moderate	Aquellos principio c??mo mujeres del.
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	11	severe	Quiere bien u hemos sistema rey salir.
f740b251-4264-4220-8400-706331f650af	8	mild	Edad distintas marzo podemos personal.
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	14	moderate	Pesar mesa habr??a socialista nombre pedro.
a329242d-9e38-4178-aa8e-5b7497209897	7	mild	Verdad zona teor??a condiciones acerca.
a329242d-9e38-4178-aa8e-5b7497209897	14	mild	Nuevas boca unos piel espera carne vamos.
fe2cc660-dd15-4d31-ac72-56114bdb6b92	4	severe	Qui??n derecha intereses santa.
fe2cc660-dd15-4d31-ac72-56114bdb6b92	8	severe	Supuesto ??xito caso aun.
fd01c50f-f3dd-4517-96c0-c0e65330a692	12	moderate	Forma ??ste mejores vuelta persona puerto mientras.
d1ec4069-41a0-4317-a6c6-84914d108257	18	mild	??ltimo octubre principal elementos debido mejor metros nuestros.
d1ec4069-41a0-4317-a6c6-84914d108257	7	moderate	Mundo mira junio ii peque??a deseo educaci??n persona.
0deef39b-719e-4f3a-a84f-2072803b2548	16	severe	Consumo pedro trabajar persona all?? adelante movimiento hace.
d911f0a5-9268-4eb4-87e9-508d7c99b753	5	moderate	Nosotros decisi??n ayer t??rminos.
d911f0a5-9268-4eb4-87e9-508d7c99b753	13	moderate	Propio justicia tendr?? r hijo precios.
c3e065c2-c0a9-440f-98f3-1c5463949056	18	severe	Poner formas dice poco cama operaci??n porque.
c3e065c2-c0a9-440f-98f3-1c5463949056	12	severe	Volver capital he costa problema origen viejo.
b2eef54b-21a7-45ec-a693-bc60f1d6e293	8	moderate	Trabajadores club especie l??nea am??rica.
3854a76e-ee29-4976-b630-1d7e18fb9887	6	mild	Explic?? cabo asimismo comisi??n da animales mano sistemas.
6b2e25e9-ebcb-4150-a594-c5742cd42121	15	severe	Llega encontrar plaza sangre.
cc38cb13-51a5-4539-99c2-894cd2b207f1	13	severe	Marzo centro rosa zonas p??blica.
cc38cb13-51a5-4539-99c2-894cd2b207f1	18	mild	M centro efecto peso.
6af409b5-c8b8-4664-97cd-d419eedcc932	16	severe	Control nuevas hora ideas.
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	16	severe	Ese deben hijo primero industria caracter??sticas ejemplo.
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	15	mild	Paz finalmente mil trabajadores peque??a particular.
bc6e7a77-d709-401c-bea7-82715eeb1a29	17	moderate	Primeras dec??a resultados consecuencia.
d54d7239-e49a-4185-8875-4f71af08b789	11	severe	Grandes mucho distintas.
d54d7239-e49a-4185-8875-4f71af08b789	3	severe	P??blico servicio espa??ol nuevas.
e8813bf8-7bbb-4370-a181-880c0c959aa1	10	moderate	Muestra partidos deben joven grandes.
517958b1-f860-4a42-965b-15a796055981	7	severe	Podr??a rosa sab??a.
44e4c099-cf6e-4926-85f1-ab5cb34c59a1	17	moderate	Cabeza pr??ximo favor julio dinero miembros metros.
44e4c099-cf6e-4926-85f1-ab5cb34c59a1	18	mild	Toda pasado varios eran.
\.


--
-- Data for Name: patient_conditions; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.patient_conditions (patient_id, condition_id, diagnosis_date, notes) FROM stdin;
31000000-e29b-41d4-a716-446655440001	1	2022-10-16	\N
31000000-e29b-41d4-a716-446655440001	3	2022-10-16	\N
31000000-e29b-41d4-a716-446655440001	5	2022-10-16	\N
33000000-e29b-41d4-a716-446655440003	2	2021-05-10	\N
34000000-e29b-41d4-a716-446655440004	1	2019-02-15	\N
34000000-e29b-41d4-a716-446655440004	3	2019-02-15	\N
34000000-e29b-41d4-a716-446655440004	4	2019-02-15	\N
2f5622af-8528-4c85-8e16-3d175a4f2d15	18	2020-04-24	Conocer trata servicios diciembre presente ??l mantener.
2f5622af-8528-4c85-8e16-3d175a4f2d15	11	2020-03-07	Instituciones tambi??n doctor econ??mica pol??tica.
2f5622af-8528-4c85-8e16-3d175a4f2d15	14	2024-11-01	Da est??n pacientes.
fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	10	2016-10-23	Tema no incluso semanas semanas.
959aa1dd-346b-4542-8f99-0d5e75301249	4	2017-07-09	Social pensar polic??a mil siete sectores estaba.
959aa1dd-346b-4542-8f99-0d5e75301249	16	2025-08-28	Pasa grande dado.
959aa1dd-346b-4542-8f99-0d5e75301249	10	2017-03-01	M??sica n??mero principio sin mar??a volver miedo.
59402562-ce5f-450e-8e6c-9630514fe164	4	2025-03-22	Amigos arte gobierno sus seis nacional del.
f81c87d6-32f1-4c79-993a-18db4734ef65	20	2015-11-03	Mucha boca car??cter dolor deseo ellos grado.
0b6b8229-4027-4ec7-8bce-c805de96ced3	12	2021-02-08	Vuelve considera junio deb??a nuestros.
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	15	2023-11-22	Riesgo oro dicen oposici??n mientras grandes esas.
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	2	2025-03-09	Ni??os se??or espa??oles diversas dado esa acerca.
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	11	2023-04-06	Uso puedo oposici??n anterior participaci??n entre ??ltima.
f2a1f62a-8030-4f65-b82d-ce7376b955bd	14	2023-06-15	Organizaci??n comisi??n estudio norte opini??n relaci??n.
f2a1f62a-8030-4f65-b82d-ce7376b955bd	8	2018-04-28	Siglo futuro ir usted ocasi??n.
f2a1f62a-8030-4f65-b82d-ce7376b955bd	11	2024-02-20	Espacio ministro entrada guerra.
0104fea2-d27c-4611-8414-da6c898b6944	8	2021-12-07	Cuales oficial precisamente deja deseo fiscal.
0104fea2-d27c-4611-8414-da6c898b6944	9	2023-12-21	Hechos m??s investigaci??n est??n partir r??o fin.
0104fea2-d27c-4611-8414-da6c898b6944	1	2017-09-09	Nuevas iglesia calle central club jefe.
cd0c2f0c-de08-439c-93c9-0feab1d433cc	5	2020-08-24	Fuerzas habr?? an??lisis algo.
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	3	2024-04-13	Larga tratamiento alta primeros nueva con solamente e.
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	11	2024-08-27	A uno debe orden natural pese ojos.
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	17	2016-06-01	Algunos cuanto ocho estar.
7893292b-965a-41da-896a-d0780c91fdd5	16	2024-11-06	Deja hermano fuerza.
7893292b-965a-41da-896a-d0780c91fdd5	4	2016-08-18	Con compa????a pasado ser?? ocho ??sta.
87fb3c88-6653-45db-aa6c-20ea7512da64	19	2021-08-17	Par??s t??tulo el tiene llega.
05e42aed-c457-4579-904f-d397be3075f7	20	2021-02-01	Problemas aquella volver pa??s pregunta r hemos claro.
05e42aed-c457-4579-904f-d397be3075f7	10	2024-03-17	Futuro volvi?? llevar cultura mal ah??.
43756f6c-c157-4a44-9c84-ab2d62fddcf7	14	2025-06-13	Esto cambio adelante estos ha.
43756f6c-c157-4a44-9c84-ab2d62fddcf7	8	2018-11-18	Igual pesar mientras.
43756f6c-c157-4a44-9c84-ab2d62fddcf7	4	2025-03-06	Flores aun plaza julio peor operaci??n partir.
d8e1fa52-0a65-4917-b410-2954e05a34e5	6	2025-02-22	Quiero queda campo estas has.
d8e1fa52-0a65-4917-b410-2954e05a34e5	8	2017-08-22	Poco ??sta primer mano electoral estaba llevar.
bbc67f38-a9eb-4379-aeaf-1560af0d1a34	4	2024-12-04	Don millones busca tengo bien pasar sigue poder.
bbc67f38-a9eb-4379-aeaf-1560af0d1a34	19	2017-04-13	Posici??n cuando hasta semana central bueno bajo.
b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	2	2017-02-12	Voy ma??ana libros ser jos??.
309df411-1d1a-4d00-a34e-36e8c32da210	16	2023-07-21	Luego existe quiere suerte.
309df411-1d1a-4d00-a34e-36e8c32da210	14	2020-07-08	Julio puso pacientes.
663d036b-a19b-4557-af37-d68a9ce4976d	8	2019-06-10	Cantidad otra deja humanos im??genes.
663d036b-a19b-4557-af37-d68a9ce4976d	5	2019-08-10	Francia pone operaci??n consecuencia esos domingo.
663d036b-a19b-4557-af37-d68a9ce4976d	17	2022-04-30	Propuesta afirm?? mediante industria aquellas.
a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	19	2019-05-17	Paciente final cual.
a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	20	2019-07-03	Cuya proyecto santa trav??s van.
d5b1779e-21f2-4252-a421-f2aaf9998916	11	2023-10-06	Julio aquel dios vivir premio porque.
d5b1779e-21f2-4252-a421-f2aaf9998916	12	2019-01-21	Baja jos?? nuevo ??rea.
d5b1779e-21f2-4252-a421-f2aaf9998916	8	2018-09-26	En cerca rodr??guez poder autoridades apoyo bastante figura.
6661483b-705b-412a-8bbd-39c0af0dadb1	3	2017-10-11	Luz barcelona partidos defensa largo esto.
676491c4-f31a-42b6-a991-a8dd09bbb1f0	13	2019-06-21	Trav??s ??xito acuerdo partido pesetas lado mart??n.
676491c4-f31a-42b6-a991-a8dd09bbb1f0	10	2023-08-18	Medio todos tales pr??ctica pod??a.
676491c4-f31a-42b6-a991-a8dd09bbb1f0	6	2016-09-20	Pedro pese luz estamos demasiado cuenta.
167dedde-166c-45e4-befc-4f1c9b7184ad	15	2018-03-12	Primeras sentido tal segundo dicen.
167dedde-166c-45e4-befc-4f1c9b7184ad	3	2021-08-12	A??o es est??n cinco pel??cula pensar.
72eca572-4ecf-4be8-906b-40e89e0d9a08	17	2023-07-27	Podemos diversos unas cambios minutos aumento.
72eca572-4ecf-4be8-906b-40e89e0d9a08	6	2017-11-16	Puesto partidos problema elementos salir.
72eca572-4ecf-4be8-906b-40e89e0d9a08	8	2017-07-01	Muerto puesto n mismos propuesta resto mundo.
d5bec069-a317-4a40-b3e8-ea80220d75de	20	2025-10-07	Segundo sobre administraci??n.
d5bec069-a317-4a40-b3e8-ea80220d75de	7	2024-04-14	Papel europa habla color gobierno profesional.
0e97294d-78cc-4428-a172-e4e1fd4efa72	11	2018-07-09	Llamado juicio s??lo m??xico.
0e97294d-78cc-4428-a172-e4e1fd4efa72	8	2023-10-31	Hab??an acci??n tuvo posible pero tratamiento.
0e97294d-78cc-4428-a172-e4e1fd4efa72	16	2023-11-17	Buena con mar nuevos agua aquel.
9f86a53f-f0e1-446d-89f0-86b086dd12a9	3	2025-01-27	U principales negro.
9f86a53f-f0e1-446d-89f0-86b086dd12a9	7	2021-11-16	Local explic?? felipe todos.
9f86a53f-f0e1-446d-89f0-86b086dd12a9	15	2022-08-08	Pr??ximo tuvo igual poder saber hijos sala.
ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	2	2019-07-12	??xito actitud obra tomar fuentes como.
d28440a6-3bd9-4a48-8a72-d700ae0971e4	10	2020-01-03	Espa??oles tiene congreso estos.
d28440a6-3bd9-4a48-8a72-d700ae0971e4	16	2018-07-14	J??venes quien pol??tico n.
d28440a6-3bd9-4a48-8a72-d700ae0971e4	18	2019-01-08	Raz??n reuni??n pensar esta tuvo.
7f839ee8-bdd6-4a63-83e8-30db007565e2	19	2022-12-06	Segundo considera civil distintos p??blico.
7f839ee8-bdd6-4a63-83e8-30db007565e2	13	2024-10-01	Origen como ??ltimos llega muerte.
67aa999f-9d31-4b61-a097-35097ea0d082	17	2020-02-22	Espa??oles tema comercio arte.
67aa999f-9d31-4b61-a097-35097ea0d082	11	2017-12-23	Pablo tendr?? elementos.
67aa999f-9d31-4b61-a097-35097ea0d082	8	2020-10-10	Presenta despu??s puesto tu ser??a.
41aa2fbc-8ef4-4448-8686-399a1cd54be9	19	2018-08-29	Mesa solo pasar importancia art??culo encima c??mara.
111769f3-1a1b-44a9-9670-f4f2e424d1d2	13	2016-08-20	Se??ora grandes mercado grupo era m??ximo peso.
111769f3-1a1b-44a9-9670-f4f2e424d1d2	11	2022-08-21	He voluntad electoral mis.
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	1	2022-03-04	Vuelta estaba crisis.
6a8b6d41-8d20-4bc5-8d48-538d348f6086	4	2017-07-11	Le poco acci??n tratamiento deja mil.
89657c95-84c0-4bd0-80c6-70a2c4721276	6	2022-08-15	Asimismo t??rminos nunca nuestro realizar c??mo mil varias.
89657c95-84c0-4bd0-80c6-70a2c4721276	10	2016-05-23	Desarrollo comisi??n instituto saber hablar sentido m??dico.
89657c95-84c0-4bd0-80c6-70a2c4721276	1	2019-07-30	Estos u mart??n.
b6658dac-0ee1-415c-95ad-28c6acea85bd	5	2017-10-06	Doctor fueron padre en arte econ??mica.
b6658dac-0ee1-415c-95ad-28c6acea85bd	1	2021-06-11	Lleva centros ??ltima j??venes.
b6658dac-0ee1-415c-95ad-28c6acea85bd	13	2019-04-03	Derechos hacer f??cil blanca ??poca tampoco.
56564104-6009-466c-9134-c15d3175613b	11	2019-11-12	A??os ella estas seg??n conocimiento all?? nadie.
56564104-6009-466c-9134-c15d3175613b	10	2017-01-30	Gente inter??s estaba j??venes diversos revoluci??n.
56564104-6009-466c-9134-c15d3175613b	20	2018-02-17	Iba estados cerca peque??o seguridad esfuerzo sigue.
edb1d693-b308-4ff6-8fd4-9e20561317e8	11	2022-03-04	Pese producci??n las buena creaci??n.
edb1d693-b308-4ff6-8fd4-9e20561317e8	1	2018-02-08	Junto arriba guerra estudios muerto ej??rcito partir.
9511f9b9-a450-489c-92b9-ac306733cee4	3	2017-12-27	Agua toda ??ltima est??n nuestra participaci??n.
9511f9b9-a450-489c-92b9-ac306733cee4	7	2021-11-01	Mismos habr?? san ??nica mes forma muestra luego.
004ce58b-6a0d-4646-92c3-4508deb6b354	15	2022-05-28	Enfermedad dar me sean.
004ce58b-6a0d-4646-92c3-4508deb6b354	14	2021-07-12	Garc??a proyecto historia voluntad dios oposici??n agua silencio.
004ce58b-6a0d-4646-92c3-4508deb6b354	19	2024-08-27	Precisamente ocasi??n costa cabeza podr??a.
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	1	2018-10-26	Mejores alguien oro propia peque??a.
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	17	2018-01-11	Principales algo r mano valores atr??s enfermedad.
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	20	2018-09-21	T??tulo ello social puntos ayer sino ning??n.
38000dbb-417f-43ca-a60e-5812796420f7	3	2017-04-28	Domingo suelo resultados propuesta me autoridades.
38000dbb-417f-43ca-a60e-5812796420f7	5	2022-08-09	Pasar iba nivel otra concepto autor alrededor.
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	20	2019-07-19	Dec??a fernando obra habla.
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	15	2022-11-09	Tratamiento cerca su interior hab??an enfermedad.
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	8	2023-06-16	He primeras el el muestra atr??s.
561c313d-2c15-41b1-b965-a38c8e0f6c42	16	2024-04-02	Conseguir causa llega fuerte.
561c313d-2c15-41b1-b965-a38c8e0f6c42	10	2016-04-02	Embargo segundo diversas serie resultados aire presencia.
561c313d-2c15-41b1-b965-a38c8e0f6c42	2	2015-12-08	Sociedad arte peso naturaleza.
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	6	2021-07-19	Relaciones d??nde pa??s dif??cil nuevas ministerio expresi??n.
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	5	2023-12-21	Diez minutos veces santa gonz??lez.
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	15	2022-04-06	Existe lugar real todas solamente.
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	18	2016-01-16	Octubre ocasi??n intereses regi??n cuba solamente.
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	13	2022-09-08	Estado administraci??n empresas tienen corte dice dicen.
05bc2942-e676-42e9-ad01-ade9f7cc5aee	9	2023-11-04	Precios seis distintas segundo.
c78e7658-d517-4ca1-990b-e6971f8d108f	19	2020-03-20	Plan m respuesta memoria todo juan nuevo.
65474c27-8f72-4690-8f19-df9344e4be5e	6	2021-10-16	Relaci??n del favor.
65474c27-8f72-4690-8f19-df9344e4be5e	14	2024-06-13	Central perdido inter??s enfermedad.
65474c27-8f72-4690-8f19-df9344e4be5e	16	2024-08-24	Zonas incluso congreso edad boca deja congreso ellos.
c1b6fa98-203a-4321-96cd-e80e7a1c9461	7	2021-02-15	Producci??n rep??blica crisis semana.
c1b6fa98-203a-4321-96cd-e80e7a1c9461	4	2023-02-14	Crisis radio momento juicio realidad a formas estudio.
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	9	2024-06-22	Comenz?? tenido llevar zonas.
eb2e55f6-4738-4352-a59a-860909f1932c	19	2019-06-16	Favor tendr?? algo abril toma algo.
eb2e55f6-4738-4352-a59a-860909f1932c	6	2018-03-08	Peque??a dif??cil importante.
eb2e55f6-4738-4352-a59a-860909f1932c	3	2017-05-21	P??blica es afirm??.
c572a4c7-e475-4d18-85da-417abcd00903	16	2019-08-20	Hacia unidos aquellas espacio organizaci??n antes nuestras.
5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	3	2022-12-03	Produce vio electoral queda libertad primero.
5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	17	2022-01-14	En escuela grande iba alg??n hacia.
9b02d89c-2c5b-4c51-8183-15ccd1184990	4	2024-10-16	Julio mes izquierda personal lleva cerca.
43ae2e81-ac13-40ac-949c-9e4f51d76098	2	2022-02-11	Violencia habla ma??ana electoral interior.
43ae2e81-ac13-40ac-949c-9e4f51d76098	20	2022-12-16	T??cnica ??xito llegar estos dice unas.
49a18092-8f90-4f6b-873c-8715b64b8aff	9	2016-08-10	Acuerdo l??pez importante violencia.
49a18092-8f90-4f6b-873c-8715b64b8aff	1	2023-12-23	??nica semanas m??s peso principales existe.
c9a949e5-e650-4d95-9e2e-49ed06e5d087	19	2020-01-17	Hay cultura siquiera supuesto gran.
c9a949e5-e650-4d95-9e2e-49ed06e5d087	7	2025-07-07	Amigo viaje acto com??n.
a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	20	2023-03-29	Ninguna si muerto datos pie vez.
447e48dc-861c-41e6-920e-a2dec785101f	16	2020-06-01	Otra m?? l??pez realidad jam??s.
447e48dc-861c-41e6-920e-a2dec785101f	15	2021-05-05	Pa??ses primeros entrada capacidad vida.
3a535951-40fd-4959-a34e-07b29f675ecc	18	2018-07-14	Sab??a salud habr??a precios serie piel.
d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	13	2019-10-10	Secretario energ??a autoridades.
d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	1	2016-02-29	S??lo si presente aquellas ma??ana.
6052a417-6725-4fab-b7dd-7f498454cd47	15	2018-04-18	Siquiera sido acuerdo.
6052a417-6725-4fab-b7dd-7f498454cd47	5	2017-03-14	Precisamente algunas despu??s un ser??a.
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	9	2025-06-16	Mal pregunta est?? se??or.
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	17	2021-07-18	Norte en comunidad vivir.
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	20	2023-06-28	Rep??blica deja importante en siguientes unidad fiscal.
f740b251-4264-4220-8400-706331f650af	11	2022-11-16	Cosas estamos fuera una est??.
f740b251-4264-4220-8400-706331f650af	19	2024-05-02	??sta arte tomar informe.
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	10	2016-06-04	Suelo t??cnica regi??n tampoco.
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	2	2023-12-12	Local cuatro d??nde pudo.
a329242d-9e38-4178-aa8e-5b7497209897	11	2018-01-08	Podemos siete estaban internacional.
fe2cc660-dd15-4d31-ac72-56114bdb6b92	10	2020-02-29	Dicho tenemos sistema algunos dio.
fd01c50f-f3dd-4517-96c0-c0e65330a692	1	2016-11-10	Siguientes an??lisis formaci??n miembros actitud cuenta he.
fd01c50f-f3dd-4517-96c0-c0e65330a692	10	2021-04-22	Suerte producci??n entrar capaz.
f56cc0bc-1765-4334-9594-73dcc9deac8e	5	2022-08-27	Me pregunta c abril anterior partir raz??n.
f56cc0bc-1765-4334-9594-73dcc9deac8e	7	2015-11-03	Puso unidad peque??o producto.
1c861cbf-991d-4820-b3f0-98538fb0d454	19	2018-08-08	Espa??ol niveles ni??o se??ora c??mo piel estoy.
d1ec4069-41a0-4317-a6c6-84914d108257	7	2025-06-30	Uso decisi??n europea m??s somos es sociedad.
d1ec4069-41a0-4317-a6c6-84914d108257	8	2021-03-08	Larga estados me causa claro septiembre les an??lisis.
0deef39b-719e-4f3a-a84f-2072803b2548	18	2024-08-20	Sino comunicaci??n popular estamos ser?? mayor??a recuerdo adem??s.
0deef39b-719e-4f3a-a84f-2072803b2548	7	2019-12-20	Crisis grande sur tu ministerio premio s??lo.
0deef39b-719e-4f3a-a84f-2072803b2548	15	2016-11-19	Regi??n van propia quiz?? d??as.
d911f0a5-9268-4eb4-87e9-508d7c99b753	5	2025-07-13	Modo obra en hora.
c3e065c2-c0a9-440f-98f3-1c5463949056	14	2022-01-31	Ya pesetas sistemas unos.
c3e065c2-c0a9-440f-98f3-1c5463949056	15	2018-08-18	Posibilidad perdido t??rminos pasa.
c3e065c2-c0a9-440f-98f3-1c5463949056	17	2023-11-13	Ve entrada plaza universidad.
b2eef54b-21a7-45ec-a693-bc60f1d6e293	20	2023-09-04	Favor hermano televisi??n cosas teor??a fuego cultural se??al??.
b2eef54b-21a7-45ec-a693-bc60f1d6e293	9	2023-06-17	Dar situaci??n uno voy principio de.
b2eef54b-21a7-45ec-a693-bc60f1d6e293	8	2017-05-29	Organizaci??n blanca actitud.
3854a76e-ee29-4976-b630-1d7e18fb9887	15	2015-12-22	Joven torno pol??tica intereses.
6b2e25e9-ebcb-4150-a594-c5742cd42121	13	2023-06-13	Formas nuestras momento decir.
6b2e25e9-ebcb-4150-a594-c5742cd42121	10	2019-08-04	Com??n vida pie propia ??nico presente valores.
6b2e25e9-ebcb-4150-a594-c5742cd42121	16	2017-10-09	Cinco presenta principios durante hospital con alrededor.
cc38cb13-51a5-4539-99c2-894cd2b207f1	11	2024-11-10	Estilo jorge francisco cargo alto dan pacientes.
cc38cb13-51a5-4539-99c2-894cd2b207f1	9	2017-02-15	Pol??tica hijos sean polic??a hacia all?? evitar cuenta.
cc38cb13-51a5-4539-99c2-894cd2b207f1	10	2018-11-17	Qui??n movimiento a siempre.
6af409b5-c8b8-4664-97cd-d419eedcc932	4	2016-06-06	Ser ellos enfermedad direcci??n.
6af409b5-c8b8-4664-97cd-d419eedcc932	3	2021-08-19	Poblaci??n esta el a??n guerra acerca.
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	15	2015-12-01	Fueron ideas mayo boca pa??s.
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	13	2025-06-21	Riesgo concepto vez puede.
bc6e7a77-d709-401c-bea7-82715eeb1a29	16	2020-03-24	Mejores europea calle estaba a??n congreso.
d54d7239-e49a-4185-8875-4f71af08b789	15	2020-04-07	Ambos bien expresi??n siglo constituci??n.
d54d7239-e49a-4185-8875-4f71af08b789	4	2022-09-04	Aspecto reforma algo rosa trav??s ministro m??.
8370857e-7e69-43a6-be63-78fc270c5fd5	12	2018-02-03	Paso amigo mujeres llamado.
e8813bf8-7bbb-4370-a181-880c0c959aa1	2	2024-10-18	Blanca t??rminos da bien hizo revoluci??n.
517958b1-f860-4a42-965b-15a796055981	11	2025-10-04	I tres atr??s informe dio noviembre peso antonio.
517958b1-f860-4a42-965b-15a796055981	1	2022-01-28	Expresi??n podr?? idea experiencia esto.
44e4c099-cf6e-4926-85f1-ab5cb34c59a1	10	2020-12-01	Control deja ellos les casi resulta.
a0c3c815-c664-4931-927f-e4109a545603	7	2019-01-02	Gente respuesta realidad mano servicio necesario.
5c1862f6-f802-41ae-a6fb-87dbc5555fb3	20	2018-03-31	Metros cierto tiene comisi??n industria poblaci??n.
5c1862f6-f802-41ae-a6fb-87dbc5555fb3	7	2022-12-21	Siempre marcha hubo expresi??n marco.
11d31cb4-1dfb-479e-9329-8b8b35920b98	16	2018-12-08	Aquel mi noche.
11d31cb4-1dfb-479e-9329-8b8b35920b98	5	2019-10-23	M??ximo intereses grado siquiera producto.
11d31cb4-1dfb-479e-9329-8b8b35920b98	9	2015-12-28	P??blica peque??o hemos.
\.


--
-- Data for Name: patient_family_history; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.patient_family_history (patient_id, condition_id, relative_type, notes) FROM stdin;
31000000-e29b-41d4-a716-446655440001	2	Unspecified	\N
31000000-e29b-41d4-a716-446655440001	1	Unspecified	\N
32000000-e29b-41d4-a716-446655440002	1	Unspecified	\N
33000000-e29b-41d4-a716-446655440003	1	Unspecified	\N
33000000-e29b-41d4-a716-446655440003	5	Unspecified	\N
34000000-e29b-41d4-a716-446655440004	1	Unspecified	\N
34000000-e29b-41d4-a716-446655440004	5	Unspecified	\N
2f5622af-8528-4c85-8e16-3d175a4f2d15	18	Sibling	Ocho humano ha nuestra ayer primeros voy.
fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	10	Father	Zonas a larga aumento profesional jefe poder.
959aa1dd-346b-4542-8f99-0d5e75301249	10	Grandparent	Misma semana a color unas.
f81c87d6-32f1-4c79-993a-18db4734ef65	20	Mother	Sab??a eran estuvo como.
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	15	Sibling	Octubre oposici??n grupos volver humanos viejo.
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	2	Mother	Pp poblaci??n hasta.
f2a1f62a-8030-4f65-b82d-ce7376b955bd	14	Unspecified	Estructura marco siglo quien seguir.
0104fea2-d27c-4611-8414-da6c898b6944	8	Father	Se??or momentos recursos mar??a puede.
0104fea2-d27c-4611-8414-da6c898b6944	9	Father	Popular hombre mis manos cerca tierra lejos.
0104fea2-d27c-4611-8414-da6c898b6944	1	Sibling	Propia elementos polic??a uno.
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	17	Unspecified	Santiago hospital tiempos no s tal padre importantes.
7893292b-965a-41da-896a-d0780c91fdd5	4	Sibling	Texto estaba servicios.
87fb3c88-6653-45db-aa6c-20ea7512da64	19	Mother	Ojos estuvo operaci??n madrid d??a saber.
05e42aed-c457-4579-904f-d397be3075f7	10	Sibling	Hay aspecto acerca.
43756f6c-c157-4a44-9c84-ab2d62fddcf7	14	Unspecified	Tiempo deben peor.
bbc67f38-a9eb-4379-aeaf-1560af0d1a34	4	Sibling	Hablar sola corte algunas.
a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	19	Father	Tener peor siguientes nos escuela autoridades rey.
d5b1779e-21f2-4252-a421-f2aaf9998916	12	Mother	Alta carlos habr?? sobre casa existencia importancia.
167dedde-166c-45e4-befc-4f1c9b7184ad	3	Unspecified	Hasta sean ejemplo cual habr?? contrario persona.
72eca572-4ecf-4be8-906b-40e89e0d9a08	17	Sibling	Espacio modo ??nica militar mira alrededor.
d5bec069-a317-4a40-b3e8-ea80220d75de	20	Unspecified	Mujeres esa aunque estas desarrollo.
d5bec069-a317-4a40-b3e8-ea80220d75de	7	Father	Sectores mayo pol??tico decir.
d28440a6-3bd9-4a48-8a72-d700ae0971e4	18	Sibling	Aquella ten??a hablar.
89657c95-84c0-4bd0-80c6-70a2c4721276	10	Grandparent	Radio santiago secretario club en ejemplo sociedad.
b6658dac-0ee1-415c-95ad-28c6acea85bd	5	Father	Podr?? dio buenos volver.
b6658dac-0ee1-415c-95ad-28c6acea85bd	1	Unspecified	Este hemos quiz?? encontrar valor.
56564104-6009-466c-9134-c15d3175613b	20	Unspecified	D??nde gonz??lez proyecto.
edb1d693-b308-4ff6-8fd4-9e20561317e8	11	Unspecified	Zonas clase luz f??tbol mantener.
004ce58b-6a0d-4646-92c3-4508deb6b354	19	Father	Efecto comunicaci??n puerto grandes plaza r??gimen cada creo.
38000dbb-417f-43ca-a60e-5812796420f7	3	Sibling	All?? siete a??n gracias.
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	8	Sibling	Haber se veces ni??os ya uno.
561c313d-2c15-41b1-b965-a38c8e0f6c42	16	Mother	Quer??a gran espa??a estar has.
561c313d-2c15-41b1-b965-a38c8e0f6c42	2	Unspecified	Don nuestros tener tema soy sectores cabeza.
c1b6fa98-203a-4321-96cd-e80e7a1c9461	4	Mother	Haciendo grupo el com??n libertad oro eso.
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	9	Unspecified	Muchos consecuencia m??xico deseo.
eb2e55f6-4738-4352-a59a-860909f1932c	19	Father	Puntos m atr??s pues encuentran fiscal ocasi??n conseguir.
eb2e55f6-4738-4352-a59a-860909f1932c	6	Grandparent	Llegado empresa si pensar carne ante siendo.
c572a4c7-e475-4d18-85da-417abcd00903	16	Grandparent	Atr??s ni??os estudio todav??a elementos obstante.
43ae2e81-ac13-40ac-949c-9e4f51d76098	20	Grandparent	Voluntad izquierda enfermedad hac??a.
a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	20	Sibling	Argentina santa rey quiz?? metros menos posibilidades.
6052a417-6725-4fab-b7dd-7f498454cd47	15	Father	Encontrar precisamente carlos educaci??n programas y.
f740b251-4264-4220-8400-706331f650af	19	Mother	Ya ha ayuda parte tierra noche estado.
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	2	Unspecified	Pa??s partidos juego mismos desde.
fe2cc660-dd15-4d31-ac72-56114bdb6b92	10	Sibling	Servicio rafael tarde tenemos.
fd01c50f-f3dd-4517-96c0-c0e65330a692	1	Grandparent	R unos historia necesidad tambi??n proceso mitad.
1c861cbf-991d-4820-b3f0-98538fb0d454	19	Grandparent	Ojos social lejos nuevas quer??a.
c3e065c2-c0a9-440f-98f3-1c5463949056	17	Unspecified	Siguiente visto ese esas.
6b2e25e9-ebcb-4150-a594-c5742cd42121	10	Unspecified	Voy finalmente diversas.
6b2e25e9-ebcb-4150-a594-c5742cd42121	16	Mother	Metros posici??n han con fueron felipe noche.
cc38cb13-51a5-4539-99c2-894cd2b207f1	9	Mother	Grupos tanto habla partidos pasar primeras vida todav??a.
6af409b5-c8b8-4664-97cd-d419eedcc932	3	Mother	Socialista d lucha francia natural voz.
d54d7239-e49a-4185-8875-4f71af08b789	4	Mother	Soy norte salud tengo estoy.
517958b1-f860-4a42-965b-15a796055981	11	Father	Capital considera primeros civil contra energ??a tres va.
44e4c099-cf6e-4926-85f1-ab5cb34c59a1	10	Mother	Oficial m?? zonas existen estar mundial precisamente.
5c1862f6-f802-41ae-a6fb-87dbc5555fb3	7	Unspecified	Produce total tipo pr??ximo.
11d31cb4-1dfb-479e-9329-8b8b35920b98	16	Mother	Medio momentos as?? pol??tico muerte amor.
\.


--
-- Data for Name: patient_medications; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.patient_medications (patient_id, medication_id, dosage, frequency, start_date) FROM stdin;
31000000-e29b-41d4-a716-446655440001	1	10mg	daily	\N
31000000-e29b-41d4-a716-446655440001	2	20mg	daily	\N
32000000-e29b-41d4-a716-446655440002	3	1 tablet	daily	\N
33000000-e29b-41d4-a716-446655440003	2	500mg	twice daily	\N
34000000-e29b-41d4-a716-446655440004	1	81mg	daily	\N
34000000-e29b-41d4-a716-446655440004	2	50mg	daily	\N
2f5622af-8528-4c85-8e16-3d175a4f2d15	5	216mcg	twice daily	2025-07-23
2f5622af-8528-4c85-8e16-3d175a4f2d15	3	360mcg	daily	2023-11-28
2f5622af-8528-4c85-8e16-3d175a4f2d15	16	413ml	twice daily	2023-08-11
fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	17	423ml	three times daily	2021-01-22
959aa1dd-346b-4542-8f99-0d5e75301249	12	430ml	weekly	2022-12-03
59402562-ce5f-450e-8e6c-9630514fe164	1	361mg	weekly	2023-10-01
59402562-ce5f-450e-8e6c-9630514fe164	19	228mg	three times daily	2024-07-10
f81c87d6-32f1-4c79-993a-18db4734ef65	18	231mg	three times daily	2021-10-21
f81c87d6-32f1-4c79-993a-18db4734ef65	11	108mcg	weekly	2022-09-09
0b6b8229-4027-4ec7-8bce-c805de96ced3	18	300mcg	as needed	2025-10-15
0b6b8229-4027-4ec7-8bce-c805de96ced3	20	47mcg	as needed	2024-02-07
0b6b8229-4027-4ec7-8bce-c805de96ced3	12	344ml	weekly	2023-09-16
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	10	62ml	daily	2023-10-10
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	18	432mcg	three times daily	2023-07-21
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	14	466ml	as needed	2024-12-14
f2a1f62a-8030-4f65-b82d-ce7376b955bd	3	318mg	twice daily	2025-04-20
f2a1f62a-8030-4f65-b82d-ce7376b955bd	9	144mg	twice daily	2024-03-26
0104fea2-d27c-4611-8414-da6c898b6944	14	56mcg	twice daily	2021-10-15
0104fea2-d27c-4611-8414-da6c898b6944	6	492ml	twice daily	2025-06-01
0104fea2-d27c-4611-8414-da6c898b6944	1	336mg	weekly	2025-08-23
cd0c2f0c-de08-439c-93c9-0feab1d433cc	3	460mcg	three times daily	2023-04-06
cd0c2f0c-de08-439c-93c9-0feab1d433cc	6	455ml	weekly	2022-03-04
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	2	370ml	twice daily	2021-09-01
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	1	369mcg	weekly	2023-11-22
7893292b-965a-41da-896a-d0780c91fdd5	17	275ml	twice daily	2025-01-08
7893292b-965a-41da-896a-d0780c91fdd5	9	121ml	three times daily	2024-01-21
7893292b-965a-41da-896a-d0780c91fdd5	5	378ml	as needed	2022-08-21
87fb3c88-6653-45db-aa6c-20ea7512da64	4	370mg	twice daily	2023-08-09
87fb3c88-6653-45db-aa6c-20ea7512da64	17	32mcg	weekly	2022-07-08
05e42aed-c457-4579-904f-d397be3075f7	8	425ml	as needed	2023-06-14
05e42aed-c457-4579-904f-d397be3075f7	17	118mg	twice daily	2022-11-07
43756f6c-c157-4a44-9c84-ab2d62fddcf7	13	116mcg	twice daily	2022-12-21
43756f6c-c157-4a44-9c84-ab2d62fddcf7	5	35mg	twice daily	2024-08-17
d8e1fa52-0a65-4917-b410-2954e05a34e5	12	453ml	twice daily	2023-01-18
d8e1fa52-0a65-4917-b410-2954e05a34e5	11	166mg	twice daily	2023-05-03
d8e1fa52-0a65-4917-b410-2954e05a34e5	6	365ml	daily	2023-11-21
bbc67f38-a9eb-4379-aeaf-1560af0d1a34	10	58mg	daily	2021-01-19
b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	10	9mcg	daily	2023-10-25
309df411-1d1a-4d00-a34e-36e8c32da210	15	119ml	daily	2021-05-05
309df411-1d1a-4d00-a34e-36e8c32da210	11	71mg	three times daily	2023-10-13
663d036b-a19b-4557-af37-d68a9ce4976d	15	391mg	as needed	2025-02-17
663d036b-a19b-4557-af37-d68a9ce4976d	9	50ml	three times daily	2020-11-01
663d036b-a19b-4557-af37-d68a9ce4976d	8	184mcg	weekly	2025-09-29
a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	6	496ml	as needed	2025-07-28
a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	18	99ml	three times daily	2022-05-24
d5b1779e-21f2-4252-a421-f2aaf9998916	10	290mg	weekly	2022-11-27
d5b1779e-21f2-4252-a421-f2aaf9998916	7	349mcg	twice daily	2023-11-01
d5b1779e-21f2-4252-a421-f2aaf9998916	6	397mg	three times daily	2021-11-30
6661483b-705b-412a-8bbd-39c0af0dadb1	18	148mg	three times daily	2024-05-21
676491c4-f31a-42b6-a991-a8dd09bbb1f0	10	89mcg	daily	2023-08-08
167dedde-166c-45e4-befc-4f1c9b7184ad	6	85ml	daily	2023-03-13
72eca572-4ecf-4be8-906b-40e89e0d9a08	11	495mcg	three times daily	2022-11-27
72eca572-4ecf-4be8-906b-40e89e0d9a08	18	24ml	three times daily	2022-09-07
d5bec069-a317-4a40-b3e8-ea80220d75de	13	202mg	twice daily	2022-10-26
d5bec069-a317-4a40-b3e8-ea80220d75de	2	359mcg	daily	2025-06-21
d5bec069-a317-4a40-b3e8-ea80220d75de	17	69mg	daily	2024-11-02
0e97294d-78cc-4428-a172-e4e1fd4efa72	8	84mg	twice daily	2022-01-25
0e97294d-78cc-4428-a172-e4e1fd4efa72	5	456mg	three times daily	2024-05-09
0e97294d-78cc-4428-a172-e4e1fd4efa72	18	6mg	daily	2020-11-10
9f86a53f-f0e1-446d-89f0-86b086dd12a9	9	461mcg	daily	2023-11-07
9f86a53f-f0e1-446d-89f0-86b086dd12a9	20	287mcg	daily	2022-03-07
ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	13	13mcg	as needed	2021-03-30
ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	4	177ml	twice daily	2023-06-27
ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	16	152mcg	weekly	2023-12-26
d28440a6-3bd9-4a48-8a72-d700ae0971e4	16	149ml	twice daily	2023-12-01
d28440a6-3bd9-4a48-8a72-d700ae0971e4	1	134mg	as needed	2021-05-11
7f839ee8-bdd6-4a63-83e8-30db007565e2	5	443ml	three times daily	2024-10-16
7f839ee8-bdd6-4a63-83e8-30db007565e2	20	494mcg	weekly	2024-07-16
67aa999f-9d31-4b61-a097-35097ea0d082	18	233mcg	twice daily	2022-11-21
41aa2fbc-8ef4-4448-8686-399a1cd54be9	16	163ml	as needed	2024-07-06
111769f3-1a1b-44a9-9670-f4f2e424d1d2	1	12ml	as needed	2025-09-25
111769f3-1a1b-44a9-9670-f4f2e424d1d2	19	317mcg	weekly	2021-04-04
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	14	457mg	three times daily	2025-08-26
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	16	251mcg	as needed	2023-03-20
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	2	52ml	three times daily	2022-09-03
6a8b6d41-8d20-4bc5-8d48-538d348f6086	2	137mg	weekly	2021-03-20
6a8b6d41-8d20-4bc5-8d48-538d348f6086	9	337mg	twice daily	2023-10-16
89657c95-84c0-4bd0-80c6-70a2c4721276	2	483mg	as needed	2021-03-17
89657c95-84c0-4bd0-80c6-70a2c4721276	13	171ml	three times daily	2023-03-18
89657c95-84c0-4bd0-80c6-70a2c4721276	19	36mcg	as needed	2021-10-03
b6658dac-0ee1-415c-95ad-28c6acea85bd	5	341mcg	three times daily	2023-11-23
b6658dac-0ee1-415c-95ad-28c6acea85bd	6	266mg	weekly	2023-08-27
b6658dac-0ee1-415c-95ad-28c6acea85bd	9	269ml	three times daily	2023-08-27
56564104-6009-466c-9134-c15d3175613b	11	363mg	twice daily	2023-10-19
56564104-6009-466c-9134-c15d3175613b	16	174mcg	as needed	2021-01-01
edb1d693-b308-4ff6-8fd4-9e20561317e8	13	305ml	as needed	2022-04-23
9511f9b9-a450-489c-92b9-ac306733cee4	18	392ml	three times daily	2021-04-23
9511f9b9-a450-489c-92b9-ac306733cee4	15	461mcg	daily	2023-03-19
004ce58b-6a0d-4646-92c3-4508deb6b354	16	300mg	twice daily	2023-07-11
004ce58b-6a0d-4646-92c3-4508deb6b354	1	334mcg	daily	2021-03-22
004ce58b-6a0d-4646-92c3-4508deb6b354	17	94mg	three times daily	2024-04-22
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	13	320ml	weekly	2021-05-21
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	4	394mcg	daily	2023-10-30
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	8	143mcg	three times daily	2022-02-28
38000dbb-417f-43ca-a60e-5812796420f7	7	91mcg	weekly	2022-08-05
38000dbb-417f-43ca-a60e-5812796420f7	12	66mg	daily	2021-03-26
38000dbb-417f-43ca-a60e-5812796420f7	5	205mcg	twice daily	2024-01-07
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	13	391mcg	weekly	2023-05-28
561c313d-2c15-41b1-b965-a38c8e0f6c42	4	382mg	weekly	2025-01-07
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	7	303mg	three times daily	2022-04-19
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	16	314ml	weekly	2023-11-23
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	1	207mcg	three times daily	2022-01-14
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	8	431mcg	three times daily	2021-07-21
05bc2942-e676-42e9-ad01-ade9f7cc5aee	7	79ml	three times daily	2021-04-07
c78e7658-d517-4ca1-990b-e6971f8d108f	5	147ml	daily	2020-12-10
c78e7658-d517-4ca1-990b-e6971f8d108f	8	190ml	twice daily	2022-03-11
c78e7658-d517-4ca1-990b-e6971f8d108f	13	463ml	as needed	2022-04-13
65474c27-8f72-4690-8f19-df9344e4be5e	8	309mcg	twice daily	2024-04-05
c1b6fa98-203a-4321-96cd-e80e7a1c9461	15	349ml	twice daily	2024-06-02
c1b6fa98-203a-4321-96cd-e80e7a1c9461	5	60ml	three times daily	2022-02-28
c1b6fa98-203a-4321-96cd-e80e7a1c9461	3	303mcg	daily	2022-04-20
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	15	59mcg	weekly	2023-08-22
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	11	430mcg	twice daily	2023-07-24
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	16	435mcg	three times daily	2022-12-20
eb2e55f6-4738-4352-a59a-860909f1932c	10	149mg	three times daily	2022-11-05
eb2e55f6-4738-4352-a59a-860909f1932c	16	118mcg	daily	2022-05-06
c572a4c7-e475-4d18-85da-417abcd00903	18	366mg	as needed	2021-03-25
5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	2	253mg	weekly	2022-10-16
5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	4	449mcg	weekly	2024-03-10
9b02d89c-2c5b-4c51-8183-15ccd1184990	4	411mcg	twice daily	2023-04-25
43ae2e81-ac13-40ac-949c-9e4f51d76098	12	246mcg	three times daily	2024-10-06
43ae2e81-ac13-40ac-949c-9e4f51d76098	7	299ml	weekly	2021-09-11
49a18092-8f90-4f6b-873c-8715b64b8aff	19	238ml	daily	2020-12-15
c9a949e5-e650-4d95-9e2e-49ed06e5d087	18	352ml	twice daily	2023-10-20
a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	11	84mg	three times daily	2025-03-17
447e48dc-861c-41e6-920e-a2dec785101f	16	403ml	weekly	2024-09-27
447e48dc-861c-41e6-920e-a2dec785101f	1	178mcg	as needed	2022-01-09
447e48dc-861c-41e6-920e-a2dec785101f	20	197mcg	weekly	2021-02-10
3a535951-40fd-4959-a34e-07b29f675ecc	19	196mcg	twice daily	2024-02-25
d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	7	433mg	twice daily	2023-12-20
6052a417-6725-4fab-b7dd-7f498454cd47	20	57ml	daily	2025-06-19
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	4	462mg	weekly	2022-05-03
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	6	26mg	as needed	2025-04-23
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	16	102mcg	daily	2022-08-20
f740b251-4264-4220-8400-706331f650af	3	487mg	as needed	2021-09-23
f740b251-4264-4220-8400-706331f650af	9	101mcg	as needed	2023-01-13
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	13	464ml	daily	2022-03-22
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	12	237mg	three times daily	2021-08-28
a329242d-9e38-4178-aa8e-5b7497209897	9	101mcg	as needed	2022-07-10
a329242d-9e38-4178-aa8e-5b7497209897	17	65mcg	daily	2025-05-20
a329242d-9e38-4178-aa8e-5b7497209897	13	332ml	weekly	2023-12-10
fe2cc660-dd15-4d31-ac72-56114bdb6b92	2	311mg	three times daily	2025-01-01
fe2cc660-dd15-4d31-ac72-56114bdb6b92	13	424mcg	twice daily	2023-09-19
fd01c50f-f3dd-4517-96c0-c0e65330a692	8	358mcg	twice daily	2025-08-24
f56cc0bc-1765-4334-9594-73dcc9deac8e	20	417mcg	weekly	2024-04-06
f56cc0bc-1765-4334-9594-73dcc9deac8e	8	368ml	weekly	2024-04-23
f56cc0bc-1765-4334-9594-73dcc9deac8e	14	8mg	as needed	2024-06-11
1c861cbf-991d-4820-b3f0-98538fb0d454	12	184mcg	daily	2021-02-14
d1ec4069-41a0-4317-a6c6-84914d108257	10	157ml	twice daily	2024-09-20
d1ec4069-41a0-4317-a6c6-84914d108257	20	232mg	as needed	2022-02-10
0deef39b-719e-4f3a-a84f-2072803b2548	12	20mcg	weekly	2022-04-10
0deef39b-719e-4f3a-a84f-2072803b2548	20	178mcg	daily	2025-06-19
d911f0a5-9268-4eb4-87e9-508d7c99b753	16	125ml	weekly	2021-04-13
c3e065c2-c0a9-440f-98f3-1c5463949056	4	162ml	as needed	2023-02-04
c3e065c2-c0a9-440f-98f3-1c5463949056	9	97mcg	three times daily	2023-10-03
c3e065c2-c0a9-440f-98f3-1c5463949056	5	156ml	twice daily	2023-03-13
b2eef54b-21a7-45ec-a693-bc60f1d6e293	20	239mcg	twice daily	2024-05-17
3854a76e-ee29-4976-b630-1d7e18fb9887	18	186mg	three times daily	2021-09-12
6b2e25e9-ebcb-4150-a594-c5742cd42121	7	458mg	twice daily	2021-02-25
6b2e25e9-ebcb-4150-a594-c5742cd42121	6	165mg	three times daily	2022-05-11
6b2e25e9-ebcb-4150-a594-c5742cd42121	9	49mcg	three times daily	2021-02-08
cc38cb13-51a5-4539-99c2-894cd2b207f1	11	431mg	as needed	2023-12-20
cc38cb13-51a5-4539-99c2-894cd2b207f1	3	22mcg	three times daily	2024-01-25
cc38cb13-51a5-4539-99c2-894cd2b207f1	10	47ml	daily	2021-01-17
6af409b5-c8b8-4664-97cd-d419eedcc932	18	158ml	as needed	2025-09-29
6af409b5-c8b8-4664-97cd-d419eedcc932	3	43mcg	as needed	2024-04-12
6af409b5-c8b8-4664-97cd-d419eedcc932	9	139mg	weekly	2025-03-22
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	1	36mcg	daily	2025-03-17
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	13	139mg	twice daily	2025-04-10
bc6e7a77-d709-401c-bea7-82715eeb1a29	5	48mg	three times daily	2025-04-08
bc6e7a77-d709-401c-bea7-82715eeb1a29	3	175ml	as needed	2020-11-02
bc6e7a77-d709-401c-bea7-82715eeb1a29	2	20mg	daily	2021-05-07
d54d7239-e49a-4185-8875-4f71af08b789	14	251mcg	daily	2025-06-16
8370857e-7e69-43a6-be63-78fc270c5fd5	18	150ml	three times daily	2020-11-18
e8813bf8-7bbb-4370-a181-880c0c959aa1	7	151ml	daily	2021-04-02
517958b1-f860-4a42-965b-15a796055981	5	399ml	three times daily	2022-07-12
517958b1-f860-4a42-965b-15a796055981	16	232mg	three times daily	2023-05-26
517958b1-f860-4a42-965b-15a796055981	7	445ml	three times daily	2024-04-11
44e4c099-cf6e-4926-85f1-ab5cb34c59a1	3	225mcg	weekly	2023-10-23
a0c3c815-c664-4931-927f-e4109a545603	10	21mcg	as needed	2020-11-27
a0c3c815-c664-4931-927f-e4109a545603	20	358ml	daily	2022-05-10
a0c3c815-c664-4931-927f-e4109a545603	16	415mcg	three times daily	2024-08-08
5c1862f6-f802-41ae-a6fb-87dbc5555fb3	3	183mcg	as needed	2025-09-14
11d31cb4-1dfb-479e-9329-8b8b35920b98	13	291mg	as needed	2024-07-10
11d31cb4-1dfb-479e-9329-8b8b35920b98	7	379mg	weekly	2023-10-03
11d31cb4-1dfb-479e-9329-8b8b35920b98	5	381ml	three times daily	2024-04-07
\.


--
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, created_at, updated_at, is_active, is_verified, last_login) FROM stdin;
31000000-e29b-41d4-a716-446655440001	21000000-e29b-41d4-a716-446655440001	11000000-e29b-41d4-a716-446655440001	Luis	Torres	1978-03-12	1	1	María Torres	2025-11-22 04:17:10.170592+00	2025-11-22 04:17:10.170592+00	t	t	\N
32000000-e29b-41d4-a716-446655440002	22000000-e29b-41d4-a716-446655440002	12000000-e29b-41d4-a716-446655440002	Carmen	Díaz	1982-07-25	2	2	José Díaz	2025-11-22 04:17:10.170592+00	2025-11-22 04:17:10.170592+00	t	t	\N
33000000-e29b-41d4-a716-446655440003	23000000-e29b-41d4-a716-446655440003	13000000-e29b-41d4-a716-446655440003	Javier	Ruiz	1990-11-08	1	1	Elena Ruiz	2025-11-22 04:17:10.170592+00	2025-11-22 04:17:10.170592+00	t	t	\N
34000000-e29b-41d4-a716-446655440004	24000000-e29b-41d4-a716-446655440004	14000000-e29b-41d4-a716-446655440004	Isabel	Fernández	1975-05-30	2	2	Carlos Fernández	2025-11-22 04:17:10.170592+00	2025-11-22 04:17:10.170592+00	t	t	\N
35000000-e29b-41d4-a716-446655440005	25000000-e29b-41d4-a716-446655440005	15000000-e29b-41d4-a716-446655440005	Manuel	Gutiérrez	1988-09-14	1	1	Rosa Gutiérrez	2025-11-22 04:17:10.170592+00	2025-11-22 04:17:10.170592+00	t	t	\N
2f5622af-8528-4c85-8e16-3d175a4f2d15	0408b031-caa3-4b7c-ae65-d05342cf5c05	7a6ce151-14b5-4d12-b6bb-1fba18636353	Linda	N??jera	1967-11-10	2	2	Mariano Munguia Romero	2025-11-22 04:41:35.817548+00	2025-11-22 04:41:35.817548+00	t	t	\N
fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	b6c86aef-75e2-4c64-bceb-e7de898b5a1b	a725b15f-039b-4256-843a-51a2968633fd	Marisela	Rocha	1971-08-16	2	2	Oswaldo Montoya	2025-11-22 04:41:35.824794+00	2025-11-22 04:41:35.824794+00	t	t	\N
959aa1dd-346b-4542-8f99-0d5e75301249	b5a04df6-baea-460f-a946-f7b7606c9982	83b74179-f6ef-4219-bc70-c93f4393a350	Homero	Miranda	1976-02-23	1	1	Genaro Arredondo Mota	2025-11-22 04:41:35.828531+00	2025-11-22 04:41:35.828531+00	t	t	\N
59402562-ce5f-450e-8e6c-9630514fe164	4664d394-c950-4dbf-9b40-7b34c6d6dabb	81941e1d-820a-4313-8177-e44278d9a981	Manuel	Vela	1989-09-27	2	2	Dr. Yuridia Galvez	2025-11-22 04:41:35.832112+00	2025-11-22 04:41:35.832112+00	t	t	\N
f81c87d6-32f1-4c79-993a-18db4734ef65	f7cdc060-94e6-47ad-90e9-939ed86fb6da	d050617d-dc89-4f28-b546-9680dd1c5fad	Paulina	Cerv??ntez	1975-03-12	2	2	Timoteo Arredondo Corral	2025-11-22 04:41:35.83582+00	2025-11-22 04:41:35.83582+00	t	t	\N
0b6b8229-4027-4ec7-8bce-c805de96ced3	ca8bf565-35d3-40f3-b741-603201f6f072	f1ab98f4-98de-420f-9c4b-c31eee92df21	Benjam??n	Serna	1972-08-13	1	1	Silvia Jose Luis Flores Alcaraz	2025-11-22 04:41:35.839652+00	2025-11-22 04:41:35.839652+00	t	t	\N
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	820c1228-3d2d-4766-900f-32940f14e74b	9c8636c9-015b-4c18-a641-f5da698b6fd8	Rosa	G??lvez	1962-06-23	2	2	Ilse Jeronimo de Leon	2025-11-22 04:41:35.844592+00	2025-11-22 04:41:35.844592+00	t	t	\N
f2a1f62a-8030-4f65-b82d-ce7376b955bd	a2beaa02-c033-4e45-b702-305d5ce41e34	1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	Nelly	Montemayor	1991-08-01	1	1	Adalberto Saldivar Curiel	2025-11-22 04:41:35.849108+00	2025-11-22 04:41:35.849108+00	t	t	\N
0104fea2-d27c-4611-8414-da6c898b6944	c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Rolando	Jaimes	1994-12-27	1	1	Antonia Patricio Roldan	2025-11-22 04:41:35.852465+00	2025-11-22 04:41:35.852465+00	t	t	\N
cd0c2f0c-de08-439c-93c9-0feab1d433cc	0e2fa589-05b2-402c-9722-1022a0121b04	ad2c792b-5015-4238-b221-fa28e8b061fc	Bruno	Ure??a	1966-01-16	2	2	Ursula Patricio Madrid	2025-11-22 04:41:35.855875+00	2025-11-22 04:41:35.855875+00	t	t	\N
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	0fbbaab0-2284-4ac6-b1c9-498b5b3c4567	a074c3ea-f255-4cf2-ae3f-727f9186be3c	Luis Manuel	Morales	1956-10-02	2	2	Alfredo Abril Matos	2025-11-22 04:41:35.859276+00	2025-11-22 04:41:35.859276+00	t	t	\N
7893292b-965a-41da-896a-d0780c91fdd5	5a6de593-99b5-4942-a379-fd21b2a4999f	cc46221e-f387-463c-9d11-9464d8209f7b	David	Benav??dez	1953-01-17	1	1	Debora Elias Guerra	2025-11-22 04:41:35.862219+00	2025-11-22 04:41:35.862219+00	t	t	\N
87fb3c88-6653-45db-aa6c-20ea7512da64	a2beaa02-c033-4e45-b702-305d5ce41e34	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	Clara	Pelayo	1954-12-26	1	1	Benito Arredondo Venegas	2025-11-22 04:41:35.865132+00	2025-11-22 04:41:35.865132+00	t	t	\N
05e42aed-c457-4579-904f-d397be3075f7	bbf715a1-3947-4642-a67a-b5c4c0c085d2	08a7fe9e-c043-4fed-89e4-93a416a20089	Santiago	Armend??riz	2001-01-02	2	2	Ing. Beatriz Concepcion	2025-11-22 04:41:35.868012+00	2025-11-22 04:41:35.868012+00	t	t	\N
43756f6c-c157-4a44-9c84-ab2d62fddcf7	93dbdfc0-e05c-4eb6-975c-360eb8d293c1	a670c73c-cc47-42fe-88c9-0fa37359779b	Carlos	Menchaca	1949-07-12	2	2	Ofelia Rufino Cadena Amaya	2025-11-22 04:41:35.871057+00	2025-11-22 04:41:35.871057+00	t	t	\N
d8e1fa52-0a65-4917-b410-2954e05a34e5	472116b5-933e-4f63-b3ca-e8c8f5d30bb4	30e2b2ec-9553-454e-92a4-c1dc89609cbb	Manuel	Gracia	1978-11-21	1	1	Miguel Angel Vicente Mondragon Segura	2025-11-22 04:41:35.874828+00	2025-11-22 04:41:35.874828+00	t	t	\N
bbc67f38-a9eb-4379-aeaf-1560af0d1a34	4664d394-c950-4dbf-9b40-7b34c6d6dabb	43dee983-676a-4e33-a6b0-f0a72f46d06c	Jos	Perea	2000-04-29	2	2	Augusto Navarro	2025-11-22 04:41:35.877822+00	2025-11-22 04:41:35.877822+00	t	t	\N
b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	38bf2ce6-5014-4bc1-8e32-9b9257eea501	7227444e-b122-48f4-8f01-2cda439507b1	Esparta	Franco	1987-01-26	2	2	Maria Ignacio Ruiz	2025-11-22 04:41:35.880722+00	2025-11-22 04:41:35.880722+00	t	t	\N
309df411-1d1a-4d00-a34e-36e8c32da210	2a0aaddd-ea43-40bb-b5df-877b1b0d20f1	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	Jos?? Luis	Miramontes	1951-01-12	1	1	Zacarias Arcelia Orozco del Valle	2025-11-22 04:41:35.883559+00	2025-11-22 04:41:35.883559+00	t	t	\N
663d036b-a19b-4557-af37-d68a9ce4976d	ba712fc8-c4d2-4e22-ae18-1991c46bc85d	cc46221e-f387-463c-9d11-9464d8209f7b	Amalia	Arenas	1975-03-31	1	1	Ing. Ofelia Duenas	2025-11-22 04:41:35.886763+00	2025-11-22 04:41:35.886763+00	t	t	\N
a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	71618fe0-25a1-4281-98af-51797de3ae0a	3cf42c93-4941-4d8d-8656-aafa9e987177	Ang??lica	Serrato	1960-12-06	2	2	Virginia Cristina Navarro Carbajal	2025-11-22 04:41:35.890561+00	2025-11-22 04:41:35.890561+00	t	t	\N
d5b1779e-21f2-4252-a421-f2aaf9998916	3fafc20d-72d5-4633-95a0-df6b9ed175b6	5462455f-fbe3-44c8-b0d1-0644c433aca6	Pascual	Barrag??n	1977-05-01	2	2	Minerva Otero	2025-11-22 04:41:35.893507+00	2025-11-22 04:41:35.893507+00	t	t	\N
6661483b-705b-412a-8bbd-39c0af0dadb1	4cecebec-e16f-4949-a18b-8bfebae86618	9a18b839-1b93-44fb-9d8a-2ea12388e887	Jes??s	Abreu	1955-05-22	1	1	Abel Avalos	2025-11-22 04:41:35.896583+00	2025-11-22 04:41:35.896583+00	t	t	\N
676491c4-f31a-42b6-a991-a8dd09bbb1f0	85eb8041-b502-4b90-b586-c7c4593b5347	6297ae0f-7fee-472d-87ec-e22b87ce6ffb	V??ctor	Espinosa	1988-08-16	2	2	Carlota Luz Sanchez Velez	2025-11-22 04:41:35.899716+00	2025-11-22 04:41:35.899716+00	t	t	\N
167dedde-166c-45e4-befc-4f1c9b7184ad	a7f19796-4c62-4a2b-82de-7c2677804e6a	744b4a03-e575-4978-b10e-6c087c9e744b	Camilo	Villa	1998-07-21	2	2	Anel Esther Corona Benavides	2025-11-22 04:41:35.904925+00	2025-11-22 04:41:35.904925+00	t	t	\N
72eca572-4ecf-4be8-906b-40e89e0d9a08	e8db5b49-5605-41e5-91f2-d456b68c5ade	a670c73c-cc47-42fe-88c9-0fa37359779b	Mario	Santill??n	1966-11-18	1	1	Abraham Jasso	2025-11-22 04:41:35.908767+00	2025-11-22 04:41:35.908767+00	t	t	\N
d5bec069-a317-4a40-b3e8-ea80220d75de	4d75aae7-5d33-44ad-a297-a32ff407415d	c9014e88-309c-4cb0-a28d-25b510e1e522	Cristobal	P??ez	1961-12-17	2	2	Sr(a). Anabel Tejeda	2025-11-22 04:41:35.912651+00	2025-11-22 04:41:35.912651+00	t	t	\N
0e97294d-78cc-4428-a172-e4e1fd4efa72	07527c1a-efd5-45e4-a0d9-01ba5207bb2f	44a33aab-1a23-4995-bd07-41f95b34fd57	Celia	Olivo	1961-08-18	1	1	Rebeca Saavedra	2025-11-22 04:41:35.915417+00	2025-11-22 04:41:35.915417+00	t	t	\N
9f86a53f-f0e1-446d-89f0-86b086dd12a9	e0926c16-7f63-41ae-a091-1d0688c88322	83b74179-f6ef-4219-bc70-c93f4393a350	Teresa	Arguello	1949-12-23	1	1	Leonel Veronica Pena	2025-11-22 04:41:35.91871+00	2025-11-22 04:41:35.91871+00	t	t	\N
ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	e0926c16-7f63-41ae-a091-1d0688c88322	2040ac28-7210-4fbd-9716-53872211bcd9	Pilar	Valle	1981-10-06	2	2	Emilia Torrez	2025-11-22 04:41:35.922432+00	2025-11-22 04:41:35.922432+00	t	t	\N
d28440a6-3bd9-4a48-8a72-d700ae0971e4	8ce8b684-8f8d-4828-987d-389dfe64afd1	0d826581-b9d8-4828-8848-9332fe38d169	Eva	Orellana	1988-03-24	2	2	Ing. Emiliano Baca	2025-11-22 04:41:35.925877+00	2025-11-22 04:41:35.925877+00	t	t	\N
7f839ee8-bdd6-4a63-83e8-30db007565e2	4d75aae7-5d33-44ad-a297-a32ff407415d	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	Rafa??l	Olvera	1946-10-16	1	1	Graciela Abril Robles Ulibarri	2025-11-22 04:41:35.928873+00	2025-11-22 04:41:35.928873+00	t	t	\N
67aa999f-9d31-4b61-a097-35097ea0d082	0fc70684-777f-43eb-895d-9cb90ce0f584	4bfa1a0a-0434-45e0-b454-03140b992f53	Anel	Baeza	1997-09-03	2	2	Esteban Irizarry Torrez	2025-11-22 04:41:35.931879+00	2025-11-22 04:41:35.931879+00	t	t	\N
41aa2fbc-8ef4-4448-8686-399a1cd54be9	d512bd88-12a3-45f9-85e8-14fb3cb5a6e1	5da54d5d-de0c-4277-a43e-6a89f987e77c	Jes??s	Negr??n	1966-09-21	2	2	Dr. Jeronimo Rico	2025-11-22 04:41:35.93516+00	2025-11-22 04:41:35.93516+00	t	t	\N
111769f3-1a1b-44a9-9670-f4f2e424d1d2	38bf2ce6-5014-4bc1-8e32-9b9257eea501	d050617d-dc89-4f28-b546-9680dd1c5fad	Asunci??n	Ybarra	2000-01-06	2	2	Nelly Jonas Urbina	2025-11-22 04:41:35.938337+00	2025-11-22 04:41:35.938337+00	t	t	\N
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	63ec3e7d-b8e4-4988-9bc3-5b655f830e31	9b581d3c-9e93-4f39-80bb-294752065866	Roberto	Varela	1961-07-16	2	2	Juan Carlos Veronica Menendez	2025-11-22 04:41:35.941626+00	2025-11-22 04:41:35.941626+00	t	t	\N
6a8b6d41-8d20-4bc5-8d48-538d348f6086	757d6edf-5aa8-461b-ac4f-9e8365017424	0b2f4464-5141-44a3-a26d-f8acc1fb955e	Alejandra	Acosta	1950-08-04	1	1	Sonia Calderon	2025-11-22 04:41:35.944331+00	2025-11-22 04:41:35.944331+00	t	t	\N
89657c95-84c0-4bd0-80c6-70a2c4721276	2a0aaddd-ea43-40bb-b5df-877b1b0d20f1	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	Minerva	Ortiz	1985-03-08	2	2	Abril Pascual Segura Avila	2025-11-22 04:41:35.947136+00	2025-11-22 04:41:35.947136+00	t	t	\N
b6658dac-0ee1-415c-95ad-28c6acea85bd	58a814d3-a275-436b-8e5c-4e743fed242f	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	Amanda	Men??ndez	1966-02-13	2	2	Andrea Hilda Esparza Rivero	2025-11-22 04:41:35.949996+00	2025-11-22 04:41:35.949996+00	t	t	\N
56564104-6009-466c-9134-c15d3175613b	ab923e2e-5d13-41e4-9c73-2f62cca0699d	54481b92-e5f5-421b-ba21-89bf520a2d87	Hermelinda	Medrano	1970-06-28	1	1	Benito Octavio Villarreal Aponte	2025-11-22 04:41:35.953506+00	2025-11-22 04:41:35.953506+00	t	t	\N
edb1d693-b308-4ff6-8fd4-9e20561317e8	16e23379-6774-417d-8104-a8e6f4712909	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	Alonso	Rold??n	1960-01-13	1	1	Jesus Rosa Matos Vanegas	2025-11-22 04:41:35.956712+00	2025-11-22 04:41:35.956712+00	t	t	\N
9511f9b9-a450-489c-92b9-ac306733cee4	0408b031-caa3-4b7c-ae65-d05342cf5c05	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	Alma	Sosa	2001-12-10	2	2	Barbara Estela Martinez Anguiano	2025-11-22 04:41:35.959551+00	2025-11-22 04:41:35.959551+00	t	t	\N
004ce58b-6a0d-4646-92c3-4508deb6b354	96d6da02-ca2f-4ace-b239-4584544e8230	3cf42c93-4941-4d8d-8656-aafa9e987177	Estela	Lucero	1979-10-25	2	2	Angel Gaona Flores	2025-11-22 04:41:35.962274+00	2025-11-22 04:41:35.962274+00	t	t	\N
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	0e2fa589-05b2-402c-9722-1022a0121b04	a725b15f-039b-4256-843a-51a2968633fd	Gonzalo	Laureano	1979-09-02	1	1	Virginia Garibay Romero	2025-11-22 04:41:35.964883+00	2025-11-22 04:41:35.964883+00	t	t	\N
38000dbb-417f-43ca-a60e-5812796420f7	96d6da02-ca2f-4ace-b239-4584544e8230	389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	Helena	Muro	1973-10-22	1	1	Isaac Ignacio Samaniego	2025-11-22 04:41:35.967903+00	2025-11-22 04:41:35.967903+00	t	t	\N
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	22d570dd-a72e-4599-8f13-df952d35d616	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	Adela	Vergara	1991-10-16	2	2	Maximiliano Villa	2025-11-22 04:41:35.9725+00	2025-11-22 04:41:35.9725+00	t	t	\N
561c313d-2c15-41b1-b965-a38c8e0f6c42	44da48b1-6ff6-4db9-9de5-34e22de0429a	3d7c5771-0692-4a2f-a4c6-6af2b561282b	Salma	Almaraz	1994-03-16	2	2	Alonso Raul Serrato Palacios	2025-11-22 04:41:35.97519+00	2025-11-22 04:41:35.97519+00	t	t	\N
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	f501d643-d308-41e0-8ffc-8bfb52d64e13	05afd7e1-bb93-4c83-90a7-48a65b6e7598	Humberto	Caraballo	1946-08-05	2	2	Micaela Maria del Carmen Villanueva Florez	2025-11-22 04:41:35.978018+00	2025-11-22 04:41:35.978018+00	t	t	\N
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	e6ce6823-6c4d-4ead-98d7-78b94483fe2c	163749fb-8b46-4447-a8b7-95b4a59531b6	Mauricio	Zavala	1997-06-08	1	1	Maria Elena Calderon Munoz	2025-11-22 04:41:35.980871+00	2025-11-22 04:41:35.980871+00	t	t	\N
05bc2942-e676-42e9-ad01-ade9f7cc5aee	c4fac110-0b61-4fb0-943d-0d00af7ed0cd	a15d4a4b-1bc4-4ee5-a168-714f71d94e42	Roberto	Alejandro	1960-11-23	2	2	Magdalena Mercedes Sauceda	2025-11-22 04:41:35.98482+00	2025-11-22 04:41:35.98482+00	t	t	\N
c78e7658-d517-4ca1-990b-e6971f8d108f	a3fb2dae-2a69-434f-86a9-65ae48c8f690	ac6f8f54-21c8-475b-bea6-19e31643392d	V??ctor	Guti??rrez	1983-10-12	1	1	Mayte Partida Lemus	2025-11-22 04:41:35.987953+00	2025-11-22 04:41:35.987953+00	t	t	\N
65474c27-8f72-4690-8f19-df9344e4be5e	3fafc20d-72d5-4633-95a0-df6b9ed175b6	a14c189c-ee90-4c29-b465-63d43a9d0010	Ad??n	Nava	2000-03-28	2	2	Cristal Adan Murillo Briones	2025-11-22 04:41:35.991216+00	2025-11-22 04:41:35.991216+00	t	t	\N
c1b6fa98-203a-4321-96cd-e80e7a1c9461	c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	8e889f63-2c86-44ab-959f-fdc365353d5d	Amador	Cano	1995-01-25	1	1	Claudia Hector Zelaya Jaimes	2025-11-22 04:41:35.994362+00	2025-11-22 04:41:35.994362+00	t	t	\N
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	0408b031-caa3-4b7c-ae65-d05342cf5c05	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	Alfonso	Prado	1955-01-12	2	2	Mtro. Renato Galarza	2025-11-22 04:41:35.997423+00	2025-11-22 04:41:35.997423+00	t	t	\N
eb2e55f6-4738-4352-a59a-860909f1932c	a6db1b41-d601-4840-99e9-3d7d18901399	8e889f63-2c86-44ab-959f-fdc365353d5d	Uriel	Su??rez	1972-06-25	1	1	Luisa Alvarez	2025-11-22 04:41:36.00061+00	2025-11-22 04:41:36.00061+00	t	t	\N
c572a4c7-e475-4d18-85da-417abcd00903	852beb97-3c99-4391-879f-98f0c2154c20	36983990-abe8-4f1c-9c1b-863b9cab3ca9	Armando	Porras	1954-05-14	2	2	Humberto Esther Quesada	2025-11-22 04:41:36.004706+00	2025-11-22 04:41:36.004706+00	t	t	\N
5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	a7f19796-4c62-4a2b-82de-7c2677804e6a	c0595f94-c8f4-413c-a05c-7cfca773563c	Teresa	Granado	1953-03-03	2	2	Cristobal Miguel Fernandez Saavedra	2025-11-22 04:41:36.007381+00	2025-11-22 04:41:36.007381+00	t	t	\N
9b02d89c-2c5b-4c51-8183-15ccd1184990	e8db5b49-5605-41e5-91f2-d456b68c5ade	46af545e-6db8-44ba-a7f9-9fd9617f4a09	Marcela	Fern??ndez	1981-09-04	1	1	Gloria Aurora Lozano Rincon	2025-11-22 04:41:36.010134+00	2025-11-22 04:41:36.010134+00	t	t	\N
43ae2e81-ac13-40ac-949c-9e4f51d76098	0fc70684-777f-43eb-895d-9cb90ce0f584	d471d2d1-66a1-4de0-8754-127059786888	Sergio	Loya	1970-04-10	2	2	Marco Antonio Geronimo Collazo Reyna	2025-11-22 04:41:36.013118+00	2025-11-22 04:41:36.013118+00	t	t	\N
49a18092-8f90-4f6b-873c-8715b64b8aff	bbf715a1-3947-4642-a67a-b5c4c0c085d2	be133600-848e-400b-9bc8-c52a4f3cf10d	Jorge Luis	Molina	1953-02-05	2	2	Emilio Romo	2025-11-22 04:41:36.01616+00	2025-11-22 04:41:36.01616+00	t	t	\N
c9a949e5-e650-4d95-9e2e-49ed06e5d087	84cb6703-edfc-4180-9f80-619064c9684e	e040eabc-0ac9-47f7-89ae-24246e1c12dd	Elvira	Echeverr??a	1970-05-24	1	1	Sessa Conchita de la Torre	2025-11-22 04:41:36.019121+00	2025-11-22 04:41:36.019121+00	t	t	\N
a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	85eb8041-b502-4b90-b586-c7c4593b5347	1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	Federico	Fajardo	1949-06-14	1	1	Guillermina Llamas	2025-11-22 04:41:36.021828+00	2025-11-22 04:41:36.021828+00	t	t	\N
447e48dc-861c-41e6-920e-a2dec785101f	86bb4262-7a96-444b-a096-d3a1bd7782e7	8cb48822-4d4c-42ed-af7f-737d3107b1db	Elena	Quintanilla	1979-01-02	1	1	Micaela Fernando Ledesma	2025-11-22 04:41:36.024531+00	2025-11-22 04:41:36.024531+00	t	t	\N
3a535951-40fd-4959-a34e-07b29f675ecc	e8db5b49-5605-41e5-91f2-d456b68c5ade	3d521bc9-692d-4a0d-a3d7-80e816b86374	Cynthia	Jurado	1991-03-08	2	2	Nicolas Espartaco Castellanos Mireles	2025-11-22 04:41:36.027384+00	2025-11-22 04:41:36.027384+00	t	t	\N
d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	c186d1ad-fcba-4f6e-acd7-86cb4c09938e	47393461-e570-448b-82b1-1cef15441262	Juana	Gurule	1993-03-05	2	2	Yolanda Oscar Mendoza	2025-11-22 04:41:36.030164+00	2025-11-22 04:41:36.030164+00	t	t	\N
6052a417-6725-4fab-b7dd-7f498454cd47	85eb8041-b502-4b90-b586-c7c4593b5347	ac6f8f54-21c8-475b-bea6-19e31643392d	Lilia	Mesa	1956-01-07	1	1	Federico Perla Mendoza Flores	2025-11-22 04:41:36.033385+00	2025-11-22 04:41:36.033385+00	t	t	\N
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	93dbdfc0-e05c-4eb6-975c-360eb8d293c1	ad2c792b-5015-4238-b221-fa28e8b061fc	Octavio	Gurule	2004-06-28	2	2	Luis Miguel Ceballos Pantoja	2025-11-22 04:41:36.036736+00	2025-11-22 04:41:36.036736+00	t	t	\N
f740b251-4264-4220-8400-706331f650af	e0926c16-7f63-41ae-a091-1d0688c88322	0e3821a8-80d6-4fa9-8313-3ed45b83c28b	Estefan??a	Vanegas	1946-07-16	1	1	Ing. Carolina Godinez	2025-11-22 04:41:36.04025+00	2025-11-22 04:41:36.04025+00	t	t	\N
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	df863eba-f0b8-4b1a-bdd1-71ed2f816ed7	d050617d-dc89-4f28-b546-9680dd1c5fad	Alfredo	Holgu??n	1963-03-03	2	2	Felipe Sofia Padilla	2025-11-22 04:41:36.043632+00	2025-11-22 04:41:36.043632+00	t	t	\N
a329242d-9e38-4178-aa8e-5b7497209897	22128ae9-ba6e-4e99-821a-dc445e76d641	a56b6787-94e9-49f0-8b3a-6ff5979773fc	Daniel	Cab??n	1964-03-09	2	2	Blanca Aurelio Beltran Navarrete	2025-11-22 04:41:36.046946+00	2025-11-22 04:41:36.046946+00	t	t	\N
fe2cc660-dd15-4d31-ac72-56114bdb6b92	28958f29-28c6-405a-acf5-949ffcaec286	8cfdeaad-c727-4a4d-b5d5-b69dd43c0854	Graciela	Bonilla	1997-08-04	2	2	Augusto Diana Ramos Palomino	2025-11-22 04:41:36.050405+00	2025-11-22 04:41:36.050405+00	t	t	\N
fd01c50f-f3dd-4517-96c0-c0e65330a692	c0d54a00-2ee9-4827-a7fb-6196ef15bdee	eb602cae-423a-455d-a22e-d47aea5eb650	Jaqueline	Olivas	1950-01-18	2	2	Jose Emilio Camarillo Escobedo	2025-11-22 04:41:36.054455+00	2025-11-22 04:41:36.054455+00	t	t	\N
f56cc0bc-1765-4334-9594-73dcc9deac8e	bbf715a1-3947-4642-a67a-b5c4c0c085d2	3d521bc9-692d-4a0d-a3d7-80e816b86374	Leonardo	Mateo	1966-11-16	2	2	Mauricio Alonso Olvera	2025-11-22 04:41:36.057726+00	2025-11-22 04:41:36.057726+00	t	t	\N
1c861cbf-991d-4820-b3f0-98538fb0d454	a7ada88a-7935-4dd5-8a4f-935c4b7c0bab	0e3821a8-80d6-4fa9-8313-3ed45b83c28b	Antonio	Sosa	1959-10-11	2	2	Martha Torres	2025-11-22 04:41:36.060907+00	2025-11-22 04:41:36.060907+00	t	t	\N
d1ec4069-41a0-4317-a6c6-84914d108257	6c711a31-c752-44f2-b6cb-480f9bf6af1f	a14c189c-ee90-4c29-b465-63d43a9d0010	Jaqueline	Negrete	1973-10-23	2	2	Esmeralda Saenz	2025-11-22 04:41:36.065055+00	2025-11-22 04:41:36.065055+00	t	t	\N
0deef39b-719e-4f3a-a84f-2072803b2548	5879ec30-c291-476d-a48c-284fadf5f98a	a725b15f-039b-4256-843a-51a2968633fd	Zo??	Gaona	1953-01-20	2	2	Olga Marisol Beltran	2025-11-22 04:41:36.070837+00	2025-11-22 04:41:36.070837+00	t	t	\N
d911f0a5-9268-4eb4-87e9-508d7c99b753	852beb97-3c99-4391-879f-98f0c2154c20	9c8636c9-015b-4c18-a641-f5da698b6fd8	Vanesa	Nava	1996-10-22	2	2	Eloisa Chacon	2025-11-22 04:41:36.075066+00	2025-11-22 04:41:36.075066+00	t	t	\N
c3e065c2-c0a9-440f-98f3-1c5463949056	e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c	67787f7c-fdee-4e30-80bd-89008ebfe419	Diana	Ceja	1969-09-11	2	2	Eric Regalado Olivo	2025-11-22 04:41:36.078094+00	2025-11-22 04:41:36.078094+00	t	t	\N
b2eef54b-21a7-45ec-a693-bc60f1d6e293	c4fac110-0b61-4fb0-943d-0d00af7ed0cd	44a33aab-1a23-4995-bd07-41f95b34fd57	Emilio	de la Rosa	1946-08-04	2	2	Tania Moya	2025-11-22 04:41:36.08116+00	2025-11-22 04:41:36.08116+00	t	t	\N
3854a76e-ee29-4976-b630-1d7e18fb9887	a3fb2dae-2a69-434f-86a9-65ae48c8f690	1926fa2a-dab7-420e-861b-c2b6dfe0174e	M??nica	de la Rosa	1978-12-21	2	2	Esperanza Eloisa Torres	2025-11-22 04:41:36.084432+00	2025-11-22 04:41:36.084432+00	t	t	\N
6b2e25e9-ebcb-4150-a594-c5742cd42121	b5a04df6-baea-460f-a946-f7b7606c9982	3d7c5771-0692-4a2f-a4c6-6af2b561282b	Reynaldo	Garc??a	1966-02-04	2	2	Agustin Baez	2025-11-22 04:41:36.087221+00	2025-11-22 04:41:36.087221+00	t	t	\N
cc38cb13-51a5-4539-99c2-894cd2b207f1	4cecebec-e16f-4949-a18b-8bfebae86618	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	Ger??nimo	Pedraza	1972-11-13	2	2	Zacarias Ochoa Torres	2025-11-22 04:41:36.090085+00	2025-11-22 04:41:36.090085+00	t	t	\N
6af409b5-c8b8-4664-97cd-d419eedcc932	bbf715a1-3947-4642-a67a-b5c4c0c085d2	9b581d3c-9e93-4f39-80bb-294752065866	Abelardo	Barraza	1981-03-11	2	2	Tania Reina Urena	2025-11-22 04:41:36.092788+00	2025-11-22 04:41:36.092788+00	t	t	\N
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	b7dd043b-953f-4e04-8a80-1c613d3c6675	ccccdffb-bc26-4d80-a590-0cd86dd5a1bc	Noelia	Toro	1948-04-16	2	2	Elsa Marin	2025-11-22 04:41:36.09574+00	2025-11-22 04:41:36.09574+00	t	t	\N
bc6e7a77-d709-401c-bea7-82715eeb1a29	b6994d45-b80e-4260-834c-facdf3ea8eee	b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	In??s	T??llez	2001-07-07	2	2	Isaac Rolando Apodaca Valle	2025-11-22 04:41:36.098716+00	2025-11-22 04:41:36.098716+00	t	t	\N
d54d7239-e49a-4185-8875-4f71af08b789	a2beaa02-c033-4e45-b702-305d5ce41e34	08a7fe9e-c043-4fed-89e4-93a416a20089	H??ctor	Maldonado	1974-05-05	1	1	Yeni Rosario Colunga	2025-11-22 04:41:36.101815+00	2025-11-22 04:41:36.101815+00	t	t	\N
8370857e-7e69-43a6-be63-78fc270c5fd5	c0d54a00-2ee9-4827-a7fb-6196ef15bdee	373769ab-b720-4269-bfb9-02546401ce99	Jon??s	Segura	1969-09-21	2	2	Clemente Antonia Orellana	2025-11-22 04:41:36.104595+00	2025-11-22 04:41:36.104595+00	t	t	\N
e8813bf8-7bbb-4370-a181-880c0c959aa1	58a814d3-a275-436b-8e5c-4e743fed242f	06c71356-e038-4c3d-bfea-7865acacb684	Jos?? Luis	G??mez	2003-03-23	1	1	Noemi Zoe Aparicio	2025-11-22 04:41:36.10733+00	2025-11-22 04:41:36.10733+00	t	t	\N
517958b1-f860-4a42-965b-15a796055981	f501d643-d308-41e0-8ffc-8bfb52d64e13	44a33aab-1a23-4995-bd07-41f95b34fd57	??ngela	Monta??ez	1974-10-26	2	2	Alvaro Sofia Rojas	2025-11-22 04:41:36.110705+00	2025-11-22 04:41:36.110705+00	t	t	\N
44e4c099-cf6e-4926-85f1-ab5cb34c59a1	2937cc2f-22b7-4488-b9f8-a0795800a840	ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	Leonor	Olivera	1953-12-23	1	1	Abel Correa	2025-11-22 04:41:36.113854+00	2025-11-22 04:41:36.113854+00	t	t	\N
a0c3c815-c664-4931-927f-e4109a545603	b441c98a-1075-4013-9fc2-9242d910713f	7b96a7bb-041f-4331-be05-e97cab7dafc0	Gabino	Aguirre	1951-06-03	1	1	Daniel Villasenor Robles	2025-11-22 04:41:36.116649+00	2025-11-22 04:41:36.116649+00	t	t	\N
5c1862f6-f802-41ae-a6fb-87dbc5555fb3	ab923e2e-5d13-41e4-9c73-2f62cca0699d	7b96a7bb-041f-4331-be05-e97cab7dafc0	Judith	Alem??n	1976-05-31	1	1	Israel Mojica	2025-11-22 04:41:36.119443+00	2025-11-22 04:41:36.119443+00	t	t	\N
11d31cb4-1dfb-479e-9329-8b8b35920b98	c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	Oswaldo	Fuentes	1989-06-16	1	1	Lic. Mayte Abreu	2025-11-22 04:41:36.122442+00	2025-11-22 04:41:36.122442+00	t	t	\N
\.


--
-- Data for Name: phone_types; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.phone_types (id, name, description, is_active, created_at) FROM stdin;
1	primary	Primary contact number	t	2025-11-22 04:17:09.90784+00
2	secondary	Secondary contact number	t	2025-11-22 04:17:09.90784+00
3	mobile	Mobile phone number	t	2025-11-22 04:17:09.90784+00
4	work	Work phone number	t	2025-11-22 04:17:09.90784+00
5	home	Home phone number	t	2025-11-22 04:17:09.90784+00
6	emergency	Emergency contact phone	t	2025-11-22 04:17:09.90784+00
\.


--
-- Data for Name: phones; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.phones (id, entity_type, entity_id, phone_type_id, phone_number, country_code, area_code, is_primary, is_verified, verification_code, verification_expires_at, created_at, updated_at) FROM stdin;
f5946cf6-f6d2-459b-a78e-956fc5f0e2c6	institution	11000000-e29b-41d4-a716-446655440001	1	5555555555	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.070962+00	2025-11-22 04:17:10.070962+00
4e8dffe4-4584-45ad-91a1-583386d941c3	institution	12000000-e29b-41d4-a716-446655440002	1	8181818181	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.078946+00	2025-11-22 04:17:10.078946+00
68531425-fd17-405c-aeb9-0ca4ffcc0751	institution	13000000-e29b-41d4-a716-446655440003	1	3333333333	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.087037+00	2025-11-22 04:17:10.087037+00
8c606f79-2210-4d01-a8cd-f38c758af6a9	institution	14000000-e29b-41d4-a716-446655440004	1	4777777777	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.094383+00	2025-11-22 04:17:10.094383+00
29e4fe13-f953-4e1c-8d6a-b750a117de3f	institution	15000000-e29b-41d4-a716-446655440005	1	3222222222	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.100636+00	2025-11-22 04:17:10.100636+00
7051fcd2-31fa-41ba-89f4-0991ba435367	doctor	21000000-e29b-41d4-a716-446655440001	1	+52-55-3001-0001	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.158469+00	2025-11-22 04:17:10.158469+00
6eb881bb-59c8-4d81-aff1-fe4e33661b1f	doctor	22000000-e29b-41d4-a716-446655440002	1	+52-81-3002-0002	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.158469+00	2025-11-22 04:17:10.158469+00
0e4e368d-3e1f-40ca-b19d-79cee8997822	doctor	23000000-e29b-41d4-a716-446655440003	1	+52-33-3003-0003	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.158469+00	2025-11-22 04:17:10.158469+00
f461fcc4-c063-477e-b937-3a5fa42c19bb	doctor	24000000-e29b-41d4-a716-446655440004	1	+52-477-3004-0004	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.158469+00	2025-11-22 04:17:10.158469+00
2e9fdef6-6777-4a26-9291-3c539b958104	doctor	25000000-e29b-41d4-a716-446655440005	1	+52-322-3005-0005	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.158469+00	2025-11-22 04:17:10.158469+00
0fdcb300-1474-460f-bf8e-ca1e05d5ce31	patient	31000000-e29b-41d4-a716-446655440001	1	5555555555	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.202522+00	2025-11-22 04:17:10.202522+00
94753647-fbbb-445a-94c3-81f232bf84a1	patient	32000000-e29b-41d4-a716-446655440002	1	8181818181	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.206627+00	2025-11-22 04:17:10.206627+00
7098848b-f9bf-4cdb-8eaa-8c062fc75983	patient	33000000-e29b-41d4-a716-446655440003	1	3333333333	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.211788+00	2025-11-22 04:17:10.211788+00
af39602b-10e8-4302-b14a-5e6abd046033	patient	34000000-e29b-41d4-a716-446655440004	1	4777777777	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.216732+00	2025-11-22 04:17:10.216732+00
761236d8-deba-4b02-82af-6e3d98d0b9b0	patient	35000000-e29b-41d4-a716-446655440005	1	3222222222	+52	\N	t	t	\N	\N	2025-11-22 04:17:10.22027+00	2025-11-22 04:17:10.22027+00
60e9f58e-853d-4de9-8b9b-a49ff1b7aae8	emergency_contact	31000000-e29b-41d4-a716-446655440001	6	5555555556	+52	\N	f	f	\N	\N	2025-11-22 04:17:10.224069+00	2025-11-22 04:17:10.224069+00
16a5695d-b0db-4452-815e-83eb10525b28	emergency_contact	32000000-e29b-41d4-a716-446655440002	6	8181818182	+52	\N	f	f	\N	\N	2025-11-22 04:17:10.228048+00	2025-11-22 04:17:10.228048+00
27f35b4d-385b-4d93-a19b-113d46b9f96b	emergency_contact	33000000-e29b-41d4-a716-446655440003	6	3333333334	+52	\N	f	f	\N	\N	2025-11-22 04:17:10.233273+00	2025-11-22 04:17:10.233273+00
a7f49c52-201b-441d-a502-d66e9d41d875	emergency_contact	34000000-e29b-41d4-a716-446655440004	6	4777777778	+52	\N	f	f	\N	\N	2025-11-22 04:17:10.237655+00	2025-11-22 04:17:10.237655+00
1030a2a4-f20d-4e46-9f7d-5b22b374e46b	emergency_contact	35000000-e29b-41d4-a716-446655440005	6	3222222224	+52	\N	f	f	\N	\N	2025-11-22 04:17:10.242035+00	2025-11-22 04:17:10.242035+00
9766b58b-1eea-416f-967f-cf8c4b9b53c2	institution	163749fb-8b46-4447-a8b7-95b4a59531b6	1	3371522360	+52	\N	t	t	\N	\N	2025-11-22 04:41:38.994305+00	2025-11-22 04:41:38.994305+00
2980bfb1-0988-438c-8215-9179316aac3c	institution	83b74179-f6ef-4219-bc70-c93f4393a350	1	47710848429	+52	\N	t	t	\N	\N	2025-11-22 04:41:38.999404+00	2025-11-22 04:41:38.999404+00
1267e79b-aba2-48c8-b749-6576008f48e0	institution	50503414-ca6d-4c1a-a34f-18719e2fd555	1	47740431756	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.002279+00	2025-11-22 04:41:39.002279+00
f4ad2b59-e292-4e61-9585-aa113b37379f	institution	9b581d3c-9e93-4f39-80bb-294752065866	1	8132350509	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.007086+00	2025-11-22 04:41:39.007086+00
9ab7052b-604d-4a30-abb3-948ff94e4045	institution	e0e34926-8d48-4db0-afb9-b20b6eeb1ecb	1	5593961023	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.01121+00	2025-11-22 04:41:39.01121+00
b6fe522e-5eff-433e-b000-f544e434e153	institution	81941e1d-820a-4313-8177-e44278d9a981	1	3392879825	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.014631+00	2025-11-22 04:41:39.014631+00
c9aeb5c3-ee19-450b-81e0-3a90276006ba	institution	a725b15f-039b-4256-843a-51a2968633fd	1	5563189795	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.017901+00	2025-11-22 04:41:39.017901+00
2bbedead-478b-4bdf-a4e1-677698f05638	institution	0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d	1	5569070701	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.023534+00	2025-11-22 04:41:39.023534+00
8fcdc713-5535-49d8-9d78-78aece6b80c1	institution	d471d2d1-66a1-4de0-8754-127059786888	1	5580154634	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.028931+00	2025-11-22 04:41:39.028931+00
d422bb64-1782-4f72-96c8-8efc6eda0baf	institution	8fd698b3-084d-4248-a28e-2708a5862e27	1	3364725703	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.033799+00	2025-11-22 04:41:39.033799+00
d7559d11-375c-4f41-88b1-a909d2ac6296	institution	7b96a7bb-041f-4331-be05-e97cab7dafc0	1	5536602749	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.038296+00	2025-11-22 04:41:39.038296+00
ca893094-d414-4ecc-b585-1af30e7a23ab	institution	5da54d5d-de0c-4277-a43e-6a89f987e77c	1	8141990637	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.041362+00	2025-11-22 04:41:39.041362+00
fd6bbfd2-7cfb-41ae-90db-a917c367d22f	institution	c9014e88-309c-4cb0-a28d-25b510e1e522	1	5536357624	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.044241+00	2025-11-22 04:41:39.044241+00
11d22677-f26f-4e45-8a7b-dcfaace1a85e	institution	8e889f63-2c86-44ab-959f-fdc365353d5d	1	5531647646	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.047293+00	2025-11-22 04:41:39.047293+00
c2ea00f2-1002-49e8-8fea-ad7861d052f5	institution	67787f7c-fdee-4e30-80bd-89008ebfe419	1	5573657880	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.050274+00	2025-11-22 04:41:39.050274+00
84333280-8777-4dc5-a131-e0b2ef5f5425	institution	4721cb90-8fb0-4fd6-b19e-160b4ac0c744	1	5523095343	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.056253+00	2025-11-22 04:41:39.056253+00
bdb40670-35f2-4fc0-b9bd-f00be1ce43f8	institution	09c54a60-6267-4439-9c8b-8c9012842942	1	47784565029	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.060187+00	2025-11-22 04:41:39.060187+00
1845ef0c-31b4-4ccb-91e2-026b9cb0d3dd	institution	a670c73c-cc47-42fe-88c9-0fa37359779b	1	3335604109	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.063535+00	2025-11-22 04:41:39.063535+00
d60a237f-eabf-4337-9bc6-87b979a05320	institution	373769ab-b720-4269-bfb9-02546401ce99	1	3387415163	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.066858+00	2025-11-22 04:41:39.066858+00
c4139b24-d29a-4c79-b134-c935e1c71a3f	institution	ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	1	3371732241	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.070965+00	2025-11-22 04:41:39.070965+00
b826aab2-698d-4548-ba1c-d0d4bd9539c5	institution	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	1	47773120537	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.07542+00	2025-11-22 04:41:39.07542+00
2025a440-e5f8-49a0-b8e6-468575bba1b1	institution	6c287a0e-9d4c-4574-932f-7d499aa4146c	1	8127073578	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.078468+00	2025-11-22 04:41:39.078468+00
1ddd6a59-dde1-4e30-8837-945683c8c70f	institution	a14c189c-ee90-4c29-b465-63d43a9d0010	1	47793180489	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.081467+00	2025-11-22 04:41:39.081467+00
3bbc5c22-1878-490b-a687-c3fad5a90de8	institution	e040eabc-0ac9-47f7-89ae-24246e1c12dd	1	47769806180	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.085681+00	2025-11-22 04:41:39.085681+00
348ce7e9-637f-42a3-869e-466350d96bf8	institution	9c8636c9-015b-4c18-a641-f5da698b6fd8	1	5551040756	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.091224+00	2025-11-22 04:41:39.091224+00
d0a88bcb-9b18-4219-be55-cf05a01e26a7	institution	b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	1	3338349676	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.094231+00	2025-11-22 04:41:39.094231+00
f31cae11-3bff-4002-b9cc-725b3f5e4596	institution	146a692b-6d46-4c26-a165-092fe771400e	1	32230861106	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.098804+00	2025-11-22 04:41:39.098804+00
ba16498e-4520-4507-b638-52c0f88df9de	institution	6297ae0f-7fee-472d-87ec-e22b87ce6ffb	1	47739482818	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.103733+00	2025-11-22 04:41:39.103733+00
138e41dc-591b-405e-85ef-2f776ca309f9	institution	66e6aa6c-596c-442e-85fb-b143875d0dfc	1	47796574625	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.107783+00	2025-11-22 04:41:39.107783+00
ca4ea4e8-d9e4-47a2-98ef-343d28423e9a	institution	46af545e-6db8-44ba-a7f9-9fd9617f4a09	1	8125874092	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.110738+00	2025-11-22 04:41:39.110738+00
fe718fd2-37d9-40ac-8266-b2316077fbb0	institution	a56b6787-94e9-49f0-8b3a-6ff5979773fc	1	5572538845	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.11379+00	2025-11-22 04:41:39.11379+00
cf85cfe0-6c19-41ae-9fec-116ec48c9ea6	institution	d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	1	47711832832	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.118216+00	2025-11-22 04:41:39.118216+00
ef8e9e02-021a-4229-9388-882cbd712357	institution	4bfa1a0a-0434-45e0-b454-03140b992f53	1	47731133700	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.122318+00	2025-11-22 04:41:39.122318+00
91fb6a13-d857-4d3e-834a-d5dadc618730	institution	33ba98b9-c46a-47c1-b266-d8a4fe557290	1	5551548989	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.125101+00	2025-11-22 04:41:39.125101+00
e74802f4-f354-4d43-bbcf-f9b1d5a5a2e3	institution	f4764cd3-47e9-4408-b0ee-9b9001c5459d	1	3375586924	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.12793+00	2025-11-22 04:41:39.12793+00
4cd5dcb4-e876-4949-b057-28a78f0e298e	institution	f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8	1	3390639484	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.132731+00	2025-11-22 04:41:39.132731+00
53976833-147c-4286-9c9a-c0f0b53f92d5	institution	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	1	5586439727	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.136081+00	2025-11-22 04:41:39.136081+00
c8225b3d-b274-4013-8be6-eb253fc6cd7c	institution	8be78aaa-c408-452e-bf01-8e831ab5c63a	1	5563882660	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.138949+00	2025-11-22 04:41:39.138949+00
66cc1fe2-935e-4efb-831c-d995d7169a4f	institution	8fb0899c-732e-4f03-8209-d52ef41a6a76	1	47752673618	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.142059+00	2025-11-22 04:41:39.142059+00
1e08d53c-0e48-4632-8eba-30633ccaac03	institution	3a9084e7-74c5-4e0b-b786-2c93d9cd39ee	1	5525184251	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.145086+00	2025-11-22 04:41:39.145086+00
7e1ee324-b342-434a-8bab-5e8d5c205392	institution	54481b92-e5f5-421b-ba21-89bf520a2d87	1	5546313692	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.150168+00	2025-11-22 04:41:39.150168+00
2a09517e-6320-4040-b16c-e39febc1fd1b	institution	68f1a02a-d348-4d1e-99ee-733d832a3f43	1	5536266540	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.153849+00	2025-11-22 04:41:39.153849+00
c680c105-1d63-4260-8403-695ccca90881	institution	36983990-abe8-4f1c-9c1b-863b9cab3ca9	1	3362895531	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.156836+00	2025-11-22 04:41:39.156836+00
53d53c9b-b5e6-4c1d-8367-e47c04726f50	institution	b654860f-ec74-42d6-955e-eeedde2df0dd	1	5590490534	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.159841+00	2025-11-22 04:41:39.159841+00
c4056553-10d8-4df1-82c8-71bd6add6c7d	institution	be133600-848e-400b-9bc8-c52a4f3cf10d	1	8171124647	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.164245+00	2025-11-22 04:41:39.164245+00
7340beb9-abc1-4948-843b-4ddcc286e379	institution	25e918f3-692f-4f51-b630-4caa1dd825a1	1	3312013008	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.169419+00	2025-11-22 04:41:39.169419+00
df87a775-35f2-42eb-9e19-cd04aec6041b	institution	cc46221e-f387-463c-9d11-9464d8209f7b	1	47731972760	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.172797+00	2025-11-22 04:41:39.172797+00
3616c17a-af7e-4ac6-a8f8-15b1863b53c5	institution	a15d4a4b-1bc4-4ee5-a168-714f71d94e42	1	5512789651	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.175863+00	2025-11-22 04:41:39.175863+00
9222fbd6-0ce4-45c7-accd-9f4a6e70b39e	institution	3d7c5771-0692-4a2f-a4c6-6af2b561282b	1	47755839275	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.179362+00	2025-11-22 04:41:39.179362+00
bab07549-d422-4b49-8d07-7724034f7c25	institution	16b25a77-b84a-44ac-8540-c5bfa9b3b6b0	1	32266246979	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.18452+00	2025-11-22 04:41:39.18452+00
9308457b-c4b1-4ea3-b34c-9ace7cd8e4b2	institution	2040ac28-7210-4fbd-9716-53872211bcd9	1	5569522073	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.189244+00	2025-11-22 04:41:39.189244+00
8df0f2e2-b4a3-4ead-a36f-ec6ba13d8153	institution	0d826581-b9d8-4828-8848-9332fe38d169	1	47712938580	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.193285+00	2025-11-22 04:41:39.193285+00
1fdfeb13-6c3b-4d13-851a-c4f804eba992	institution	c0595f94-c8f4-413c-a05c-7cfca773563c	1	47732874842	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.19799+00	2025-11-22 04:41:39.19799+00
d2a4ac87-8354-45a3-a189-d55d9e7782dd	institution	a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5	1	5528016555	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.202946+00	2025-11-22 04:41:39.202946+00
47a7bec9-7204-4d96-b52a-602761061e56	institution	ad2c792b-5015-4238-b221-fa28e8b061fc	1	3337567197	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.207343+00	2025-11-22 04:41:39.207343+00
d5ef981a-8b07-403f-a1d8-e145e0170945	institution	c3e96b10-f0ca-421e-b402-aba6d595cf27	1	5560304824	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.212379+00	2025-11-22 04:41:39.212379+00
c5502e36-35fc-46ef-9b0d-23f192ffd785	institution	a5b1202a-9112-404b-b7de-ddf0f62711f8	1	5543588535	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.217068+00	2025-11-22 04:41:39.217068+00
119d0b7c-190e-43ce-8140-8e60787c226b	institution	ac6f8f54-21c8-475b-bea6-19e31643392d	1	3370017140	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.221063+00	2025-11-22 04:41:39.221063+00
d4df90e4-0d5f-41fa-a413-ea427effcd12	institution	43dee983-676a-4e33-a6b0-f0a72f46d06c	1	8179974813	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.2242+00	2025-11-22 04:41:39.2242+00
599c6268-022a-4bee-a61e-ff512efd3967	institution	f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	1	5558498859	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.227146+00	2025-11-22 04:41:39.227146+00
2c621621-3a97-4051-8c50-680ccccc1149	institution	08a7fe9e-c043-4fed-89e4-93a416a20089	1	47797830994	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.231569+00	2025-11-22 04:41:39.231569+00
42c4b6e6-0fc6-417c-9703-44f693a89bf7	institution	89ab21cf-089e-4210-8e29-269dfbd38d71	1	32277266734	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.23548+00	2025-11-22 04:41:39.23548+00
316f8d6f-4aa5-41c5-833a-6d77bf7dbac3	institution	d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f	1	5539911148	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.238846+00	2025-11-22 04:41:39.238846+00
4012333f-5b06-4605-b4cb-9b4cd9d6b0bd	institution	ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	1	3386263805	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.242023+00	2025-11-22 04:41:39.242023+00
5aa445b2-05e0-4654-a8be-4919940a9189	institution	3cf42c93-4941-4d8d-8656-aafa9e987177	1	47785457044	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.244893+00	2025-11-22 04:41:39.244893+00
f90534f9-9499-4406-a9e0-c9663d2c9f3e	institution	1926fa2a-dab7-420e-861b-c2b6dfe0174e	1	32229847340	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.249808+00	2025-11-22 04:41:39.249808+00
4eb47e3d-dfbc-40e5-ac48-a38c37be2cdd	institution	0b2f4464-5141-44a3-a26d-f8acc1fb955e	1	8189695283	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.254005+00	2025-11-22 04:41:39.254005+00
90ba5df6-f9df-4123-a96d-fd20d18440a4	institution	1fec9665-52bc-49a7-b028-f0d78440463c	1	3381134604	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.257222+00	2025-11-22 04:41:39.257222+00
ed7d19d5-9668-468e-8b31-628102ead5a3	institution	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	1	8146729225	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.261848+00	2025-11-22 04:41:39.261848+00
f0213baa-1e88-4ea4-b372-9b7f89b043e1	institution	8cfdeaad-c727-4a4d-b5d5-b69dd43c0854	1	3396048181	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.265041+00	2025-11-22 04:41:39.265041+00
5f713030-45a6-43c1-a1b3-62f319b98b03	institution	7a6ce151-14b5-4d12-b6bb-1fba18636353	1	47779106285	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.268407+00	2025-11-22 04:41:39.268407+00
b4e4f748-57da-4dc5-80cf-1ff0b16f1e54	institution	f1ab98f4-98de-420f-9c4b-c31eee92df21	1	5549218125	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.271535+00	2025-11-22 04:41:39.271535+00
e6551cae-e3ab-4049-9c8e-a9d2ee375ec7	institution	a074c3ea-f255-4cf2-ae3f-727f9186be3c	1	32261602068	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.274766+00	2025-11-22 04:41:39.274766+00
8f870f32-cfce-4787-bd0e-ef44645be1cb	institution	0e3821a8-80d6-4fa9-8313-3ed45b83c28b	1	32265458833	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.278627+00	2025-11-22 04:41:39.278627+00
f4c6069b-2a50-49ed-99c7-67e418ab626c	institution	3d521bc9-692d-4a0d-a3d7-80e816b86374	1	5538270003	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.28374+00	2025-11-22 04:41:39.28374+00
6960f685-1c6e-452e-aa9d-167e67b2b3c6	institution	47393461-e570-448b-82b1-1cef15441262	1	32236153532	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.287787+00	2025-11-22 04:41:39.287787+00
48e22776-2005-4d75-ac58-7bfa54f90ba7	institution	744b4a03-e575-4978-b10e-6c087c9e744b	1	3374016317	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.291394+00	2025-11-22 04:41:39.291394+00
5cb4fe53-400c-47fe-acaa-9c95720a3b2f	institution	9a18b839-1b93-44fb-9d8a-2ea12388e887	1	3327117670	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.295426+00	2025-11-22 04:41:39.295426+00
8edb07d6-59d2-4bc5-b0f2-efc5ebffbdbc	institution	1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	1	47791284627	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.299297+00	2025-11-22 04:41:39.299297+00
83e43d79-c099-4796-a231-d0ad25b56b8c	institution	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	1	3347494645	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.305932+00	2025-11-22 04:41:39.305932+00
f7c4f65d-9d59-4309-989b-ef2bba581821	institution	eea6be20-e19f-485f-ab54-537a7c28245f	1	32266477281	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.310182+00	2025-11-22 04:41:39.310182+00
55a6edbd-3693-45e7-be3d-b71d3f95edf7	institution	eb602cae-423a-455d-a22e-d47aea5eb650	1	5550417646	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.315195+00	2025-11-22 04:41:39.315195+00
b96a9c86-5a01-4b86-b396-7354a03bf6d3	institution	bb17faca-a7b2-4de8-bf29-2fcb569ef554	1	8168716203	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.319839+00	2025-11-22 04:41:39.319839+00
dce9be4a-4326-49a9-b696-e991b7ded50a	institution	44a33aab-1a23-4995-bd07-41f95b34fd57	1	32233606764	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.323112+00	2025-11-22 04:41:39.323112+00
ffb62c59-165b-4588-b696-06859578512c	institution	5462455f-fbe3-44c8-b0d1-0644c433aca6	1	5516600818	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.327298+00	2025-11-22 04:41:39.327298+00
302ecffd-f570-46cc-a06b-ac491530ff0f	institution	d050617d-dc89-4f28-b546-9680dd1c5fad	1	5553664978	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.330639+00	2025-11-22 04:41:39.330639+00
e6822f89-800e-4994-9b24-d5b176d62bb9	institution	7227444e-b122-48f4-8f01-2cda439507b1	1	8115853052	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.335404+00	2025-11-22 04:41:39.335404+00
6be075c9-6177-4f82-b415-74d56a62824d	institution	d86c173a-8a1d-43b4-a0c1-c836afdc378b	1	47785315931	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.339802+00	2025-11-22 04:41:39.339802+00
d06b2f51-478b-4fda-a875-2f334dbcb820	institution	fb0a848d-4d51-4416-86bc-e568f694f9e7	1	32294844660	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.34437+00	2025-11-22 04:41:39.34437+00
8324f8c1-c4a7-493a-888f-6751a4ea3c50	institution	ccccdffb-bc26-4d80-a590-0cd86dd5a1bc	1	47722520092	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.348239+00	2025-11-22 04:41:39.348239+00
e1891cf3-e7bd-40ed-94c4-306412212ec4	institution	8cb48822-4d4c-42ed-af7f-737d3107b1db	1	32267361080	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.351799+00	2025-11-22 04:41:39.351799+00
b6219fba-8ce3-4e5c-9d06-e88795c88ef8	institution	700b8c76-7ad1-4453-9ce3-f598565c6452	1	8141115029	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.355749+00	2025-11-22 04:41:39.355749+00
2b75afac-b939-4b2c-a9d3-c9ddac1cf106	institution	d3cb7dc8-9240-4800-a1d9-bf65c5dac801	1	47759537736	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.361927+00	2025-11-22 04:41:39.361927+00
40efef16-04e2-4d13-9297-b12d0087f86f	institution	06c71356-e038-4c3d-bfea-7865acacb684	1	32277960079	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.36565+00	2025-11-22 04:41:39.36565+00
69e8ce07-1fae-43c0-bfba-ae85114cba2c	institution	30e2b2ec-9553-454e-92a4-c1dc89609cbb	1	3388792805	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.370425+00	2025-11-22 04:41:39.370425+00
bfdd4b62-8169-4e01-8196-1588ee19d379	institution	2eead5aa-095b-418a-bd02-e3a917971887	1	32279210570	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.375148+00	2025-11-22 04:41:39.375148+00
2dd2aab7-fc1e-4041-b3d3-a0c6cdda4e5e	institution	05afd7e1-bb93-4c83-90a7-48a65b6e7598	1	32230602922	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.379391+00	2025-11-22 04:41:39.379391+00
f511ecc6-b696-4953-bbac-eb757305fb22	institution	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	1	47744376047	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.382537+00	2025-11-22 04:41:39.382537+00
7d49106f-28eb-454d-bab1-29f16aad06e2	institution	454f4ba6-cb6d-4f27-9d76-08f5b358b484	1	5565348409	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.387257+00	2025-11-22 04:41:39.387257+00
2e226c0e-cfad-4607-ad24-1c6fe35c74b8	institution	389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	1	32265917881	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.392465+00	2025-11-22 04:41:39.392465+00
44c000f3-91ce-4ca3-9b17-29a4de9e4ab9	doctor	06e938ee-f7e4-4ed5-bcf3-dbbaafa89db7	1	+52-322-3394-3614	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.396866+00	2025-11-22 04:41:39.396866+00
804b6133-436c-4430-b808-622fc8ff7147	doctor	3e5b08ed-529d-45f0-8145-8371609882c1	1	+52-81-3363-8293	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.399616+00	2025-11-22 04:41:39.399616+00
828bcc37-c87f-4e9b-981b-68662c9aaf26	doctor	57031194-3c31-4320-86c4-fd370789efac	1	+52-322-7563-1830	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.402586+00	2025-11-22 04:41:39.402586+00
4a957872-4425-4cf5-9a5b-9db74d4375d6	doctor	dc42b779-4b49-418b-ab0a-92caa2a8d6de	1	+52-322-9394-7823	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.407341+00	2025-11-22 04:41:39.407341+00
e4ae1f56-87b6-46d3-8e68-818ed5545dde	doctor	14abdfde-e4c9-460c-9ce2-17886600b20d	1	+52-322-5183-1669	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.410526+00	2025-11-22 04:41:39.410526+00
0977ed5e-a75c-4a59-a8f9-6145f5af8dd1	doctor	df863eba-f0b8-4b1a-bdd1-71ed2f816ed7	1	+52-81-9565-6802	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.413568+00	2025-11-22 04:41:39.413568+00
c21334cb-f0c6-443b-9d05-1c9ef5c97cf3	doctor	ba712fc8-c4d2-4e22-ae18-1991c46bc85d	1	+52-81-4141-7561	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.418153+00	2025-11-22 04:41:39.418153+00
b96bbfd8-dcce-4eb2-9d4f-373ee7032cb3	doctor	bbf715a1-3947-4642-a67a-b5c4c0c085d2	1	+52-55-5100-9719	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.422708+00	2025-11-22 04:41:39.422708+00
d3447ba6-915e-408b-95a0-f45740446471	doctor	851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec	1	+52-477-5034-1601	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.426545+00	2025-11-22 04:41:39.426545+00
e5b02405-8965-4114-8357-310f67f6251b	doctor	0fbbaab0-2284-4ac6-b1c9-498b5b3c4567	1	+52-477-1562-6872	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.430067+00	2025-11-22 04:41:39.430067+00
e2d48b27-759e-49f7-9071-9b4f18766f30	doctor	b6994d45-b80e-4260-834c-facdf3ea8eee	1	+52-477-8080-4957	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.434202+00	2025-11-22 04:41:39.434202+00
7dded03d-f7d3-4c60-97b7-9b1a8abd0b1a	doctor	f7cdc060-94e6-47ad-90e9-939ed86fb6da	1	+52-322-5323-5705	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.438228+00	2025-11-22 04:41:39.438228+00
c2af91c1-26e1-449e-b957-adc9573d0527	doctor	23785934-fbf0-442c-add3-05df84fa5d17	1	+52-33-1157-2790	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.444255+00	2025-11-22 04:41:39.444255+00
91031d23-6d84-4e4e-9d56-487b47d1997b	doctor	bf7a015c-1589-42b3-b1e8-103fcbc0b041	1	+52-477-2945-4642	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.447903+00	2025-11-22 04:41:39.447903+00
875fe74d-47eb-4853-b382-9b35f1948278	doctor	4fa9d0ff-2c51-4918-b48a-b5cb37d444a3	1	+52-55-8962-4540	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.452058+00	2025-11-22 04:41:39.452058+00
6b58c446-d9ed-47ec-8b3b-f4990ed519dd	doctor	93dbdfc0-e05c-4eb6-975c-360eb8d293c1	1	+52-81-8045-7756	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.456051+00	2025-11-22 04:41:39.456051+00
0e41c8e4-a0f0-4df6-9b3c-46015854c8fd	doctor	a6db1b41-d601-4840-99e9-3d7d18901399	1	+52-322-7009-9717	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.461472+00	2025-11-22 04:41:39.461472+00
2423875e-0a98-447e-a8a0-9d1f5c033950	doctor	d5e98ce0-e6f8-4577-a0dd-3281aa303b32	1	+52-33-9398-3998	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.469122+00	2025-11-22 04:41:39.469122+00
aa621fc7-d597-4d8d-9f0b-d9be977c4eb0	doctor	44da48b1-6ff6-4db9-9de5-34e22de0429a	1	+52-55-2866-8056	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.474479+00	2025-11-22 04:41:39.474479+00
ccd2f301-fab0-4501-a55b-3fd2445ab1a9	doctor	3fafc20d-72d5-4633-95a0-df6b9ed175b6	1	+52-322-3663-1685	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.480378+00	2025-11-22 04:41:39.480378+00
3c149094-8da5-44e8-b43a-2a25efdb6260	doctor	c4fac110-0b61-4fb0-943d-0d00af7ed0cd	1	+52-81-7146-5995	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.484958+00	2025-11-22 04:41:39.484958+00
b3c5c858-7e6c-4324-89fd-25d793344a76	doctor	88870e4f-1333-4bcc-8daf-c8743d61f3cb	1	+52-81-6252-2821	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.489581+00	2025-11-22 04:41:39.489581+00
42702204-144e-45f5-bdf5-ca25adb60ecd	doctor	6f035f60-87f7-4a9c-9501-4b8704facba3	1	+52-81-8352-1711	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.495139+00	2025-11-22 04:41:39.495139+00
68dcf6f1-b2eb-47de-9267-7a0a58b74dca	doctor	58a814d3-a275-436b-8e5c-4e743fed242f	1	+52-33-7762-6936	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.49958+00	2025-11-22 04:41:39.49958+00
1d6b3751-a472-4fff-b5b2-741d77e23eae	doctor	f67c2f76-9bf1-43e4-8d0e-c0a94298f35b	1	+52-81-4324-9871	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.504121+00	2025-11-22 04:41:39.504121+00
97f74c83-66fe-42a1-9fc7-2ab1c8a41bf5	doctor	fb4d84a0-7bc1-4815-b7a3-b1719c616c79	1	+52-33-9176-3434	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.508658+00	2025-11-22 04:41:39.508658+00
3c175655-145b-48ce-9a3d-337422af6a13	doctor	c0bdb808-eb5f-479f-9261-dbbf9ff031a6	1	+52-477-2455-1510	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.514602+00	2025-11-22 04:41:39.514602+00
58534463-654a-4016-865f-ec6427d35362	doctor	f501d643-d308-41e0-8ffc-8bfb52d64e13	1	+52-55-6386-4972	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.518333+00	2025-11-22 04:41:39.518333+00
cfaf22c9-d96b-49db-afdf-c07393895f2c	doctor	adeb74f6-f3dc-43a7-a841-6d24aba046ba	1	+52-477-7930-5677	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.523023+00	2025-11-22 04:41:39.523023+00
d97d3b8e-b341-4640-9ae2-45e94aac5153	doctor	dd24da99-43c7-4d6b-acc0-32fc0c237d02	1	+52-55-8635-4389	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.526489+00	2025-11-22 04:41:39.526489+00
63be9916-acf6-4fbf-ab17-5872b35d5f77	doctor	0408b031-caa3-4b7c-ae65-d05342cf5c05	1	+52-55-7611-8419	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.530435+00	2025-11-22 04:41:39.530435+00
acfe1cfa-e111-4ed2-85bb-e2d6428a5dc8	doctor	a865edbe-d50c-4bd1-b556-ae32d9d1858c	1	+52-55-6989-3692	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.534684+00	2025-11-22 04:41:39.534684+00
df8a7251-a143-437e-9489-5aa8c933b6a0	doctor	2a0aaddd-ea43-40bb-b5df-877b1b0d20f1	1	+52-33-1488-2230	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.540455+00	2025-11-22 04:41:39.540455+00
8388e2c9-5510-46ea-9ee6-9342edd8010d	doctor	4754ba59-3dc1-4be2-a770-44d7c34184bc	1	+52-477-5636-3465	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.545259+00	2025-11-22 04:41:39.545259+00
8bdf4978-5590-4a16-aec7-7a997fab031b	doctor	16e23379-6774-417d-8104-a8e6f4712909	1	+52-55-2025-6399	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.551038+00	2025-11-22 04:41:39.551038+00
571c34e3-1909-4bc4-8542-cbb7e404757f	doctor	07527c1a-efd5-45e4-a0d9-01ba5207bb2f	1	+52-55-6307-9700	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.555735+00	2025-11-22 04:41:39.555735+00
6d703b1e-6305-45ba-b1d4-2a5461263467	doctor	c186d1ad-fcba-4f6e-acd7-86cb4c09938e	1	+52-55-8108-5000	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.559892+00	2025-11-22 04:41:39.559892+00
cabf1b53-1e23-4b60-b15c-25e9332b49a9	doctor	4cecebec-e16f-4949-a18b-8bfebae86618	1	+52-477-6319-3357	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.566502+00	2025-11-22 04:41:39.566502+00
207d1769-4824-4436-ad37-dc11fc58853d	doctor	6d21a37a-43d8-440b-bc64-87bb0ae1d45d	1	+52-81-5709-2479	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.571026+00	2025-11-22 04:41:39.571026+00
d157b68f-c583-47bd-bf42-64fcb61ecd28	doctor	4d75aae7-5d33-44ad-a297-a32ff407415d	1	+52-55-1880-1065	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.576901+00	2025-11-22 04:41:39.576901+00
802bc6eb-7c72-4840-97a0-2afa4faaf6cf	doctor	e901dbc1-3eed-4e5e-b23c-58d808477e33	1	+52-33-7421-4169	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.582207+00	2025-11-22 04:41:39.582207+00
ecf478fa-8fe5-4d7e-948d-7649d99ba467	doctor	61bb20b9-7520-42be-accf-743c84a0b934	1	+52-477-7885-3204	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.587742+00	2025-11-22 04:41:39.587742+00
8f7e27e4-0b82-4140-91ce-2a5ffe41ed84	doctor	b5a04df6-baea-460f-a946-f7b7606c9982	1	+52-33-3164-7783	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.592227+00	2025-11-22 04:41:39.592227+00
8a9660d2-83a9-44f6-8048-e88983e35c8c	doctor	c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	1	+52-322-3786-5736	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.59737+00	2025-11-22 04:41:39.59737+00
b426fc52-b056-44be-ac53-33c53aefa1c3	doctor	0b238725-a392-4fbb-956b-0f71e15bc6da	1	+52-81-5910-2235	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.604642+00	2025-11-22 04:41:39.604642+00
943e9809-871f-459b-9c9a-bde3d402818f	doctor	63ec3e7d-b8e4-4988-9bc3-5b655f830e31	1	+52-81-3497-5247	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.611555+00	2025-11-22 04:41:39.611555+00
284bb26a-7e30-4d21-af4e-9e0105e39cbc	doctor	d4df85ce-6d2b-46c9-b9cd-48b2490b3c88	1	+52-55-6842-1764	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.615631+00	2025-11-22 04:41:39.615631+00
58fa7010-d768-436b-a2c1-b9ed2723c864	doctor	71618fe0-25a1-4281-98af-51797de3ae0a	1	+52-33-2421-9011	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.620032+00	2025-11-22 04:41:39.620032+00
d73d18f2-8c36-4612-ac01-293ea2b98da8	doctor	389524b6-608c-4b31-affa-305b79635816	1	+52-33-9520-2823	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.623519+00	2025-11-22 04:41:39.623519+00
0f7b2a30-e1ea-4514-93d1-54d8fbbb363a	doctor	c0356e82-1510-4557-b654-cf84ac13f425	1	+52-81-5120-2469	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.627088+00	2025-11-22 04:41:39.627088+00
dca7459c-eedb-4057-86ab-27a593e0162d	doctor	ce44b08f-7dae-4844-ae53-e01ac2f28f45	1	+52-33-7506-8164	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.630046+00	2025-11-22 04:41:39.630046+00
48ec3879-28e8-4d55-99fe-8085f2b9ab3c	doctor	9c9838c2-4464-4fbb-bc22-8f4ac64b4efe	1	+52-322-4353-7797	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.633273+00	2025-11-22 04:41:39.633273+00
d0ec0018-e826-405d-85d0-6ccaba04bf71	doctor	e8db5b49-5605-41e5-91f2-d456b68c5ade	1	+52-55-5541-5639	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.637888+00	2025-11-22 04:41:39.637888+00
d08acbbb-2689-484f-b358-3a9ccec22976	doctor	96d6da02-ca2f-4ace-b239-4584544e8230	1	+52-33-6078-9976	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.641211+00	2025-11-22 04:41:39.641211+00
9ba7576b-73b4-42ce-a069-720f5dc33d86	doctor	38bf2ce6-5014-4bc1-8e32-9b9257eea501	1	+52-322-8261-8204	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.644286+00	2025-11-22 04:41:39.644286+00
a08a6598-64af-4df1-ae04-33c656d1f3bd	doctor	e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c	1	+52-81-9275-1034	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.647221+00	2025-11-22 04:41:39.647221+00
509782a1-812c-48e6-af08-d097bf1160fa	doctor	8ce8b684-8f8d-4828-987d-389dfe64afd1	1	+52-55-4349-3546	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.650622+00	2025-11-22 04:41:39.650622+00
1e26ea2d-0957-4de4-a304-011992aa4cb6	doctor	ca8bf565-35d3-40f3-b741-603201f6f072	1	+52-322-6605-6510	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.654972+00	2025-11-22 04:41:39.654972+00
29a4addc-c3ba-4cb7-85c1-bebe177f9f1c	doctor	2937cc2f-22b7-4488-b9f8-a0795800a840	1	+52-33-7670-2662	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.658994+00	2025-11-22 04:41:39.658994+00
56036a7b-6e57-4828-bd9b-552210df4093	doctor	f8a511e3-b97b-4d17-8240-46520497ef7c	1	+52-55-5164-9244	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.661888+00	2025-11-22 04:41:39.661888+00
6afff2cf-1342-4807-bbc9-64d4637d2774	doctor	879bcb9a-8520-4d02-b12b-ba5afa629d41	1	+52-81-6982-4326	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.66551+00	2025-11-22 04:41:39.66551+00
b1e896c2-2a04-4b0f-ac74-6b083638aa9a	doctor	7817761a-e7c5-47cb-a260-7e243c11ef2f	1	+52-477-3969-4235	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.668922+00	2025-11-22 04:41:39.668922+00
524c1747-c387-43c5-9e77-4565d69965a9	doctor	48384f36-0b57-4943-899f-cbffd4ec37b6	1	+52-81-7123-5544	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.675484+00	2025-11-22 04:41:39.675484+00
ed2b9885-8d19-4271-a3a9-d6618f44af4f	doctor	0fc70684-777f-43eb-895d-9cb90ce0f584	1	+52-33-4386-2045	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.680263+00	2025-11-22 04:41:39.680263+00
76e64a80-25ad-4cd0-9273-9cee2db8b5ad	doctor	a849f14b-3741-4e38-9dfb-6cc7d46265e8	1	+52-477-7392-9529	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.68485+00	2025-11-22 04:41:39.68485+00
da236a3e-1227-40a2-9301-e67dda642ecc	doctor	22128ae9-ba6e-4e99-821a-dc445e76d641	1	+52-33-4348-2715	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.688876+00	2025-11-22 04:41:39.688876+00
e44aeb12-284a-429d-a8cf-08d67afd1966	doctor	6c711a31-c752-44f2-b6cb-480f9bf6af1f	1	+52-55-9342-3860	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.692222+00	2025-11-22 04:41:39.692222+00
bf69a733-af61-4150-9d8e-508e5c15390d	doctor	ab923e2e-5d13-41e4-9c73-2f62cca0699d	1	+52-33-4821-8108	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.696582+00	2025-11-22 04:41:39.696582+00
a188bf78-10a3-4223-b855-2e4b5ea168de	doctor	a7f19796-4c62-4a2b-82de-7c2677804e6a	1	+52-322-8468-7927	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.703067+00	2025-11-22 04:41:39.703067+00
51de6d19-f94a-42e4-bf5b-2606747e3714	doctor	28958f29-28c6-405a-acf5-949ffcaec286	1	+52-477-9822-2482	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.707864+00	2025-11-22 04:41:39.707864+00
e7b73593-faef-4527-a48e-3c5a3c4a7570	doctor	472116b5-933e-4f63-b3ca-e8c8f5d30bb4	1	+52-322-6587-7860	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.713615+00	2025-11-22 04:41:39.713615+00
45538d40-2046-4f0e-89ba-759ac9147bb0	doctor	a2beaa02-c033-4e45-b702-305d5ce41e34	1	+52-322-2224-6053	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.718455+00	2025-11-22 04:41:39.718455+00
284c994a-4f7f-4d21-91ff-9f6800e9d567	doctor	5879ec30-c291-476d-a48c-284fadf5f98a	1	+52-322-8639-6757	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.722475+00	2025-11-22 04:41:39.722475+00
c818ac6a-7eef-4c37-a809-efb2c0787f16	doctor	d512bd88-12a3-45f9-85e8-14fb3cb5a6e1	1	+52-55-1799-6512	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.72655+00	2025-11-22 04:41:39.72655+00
fc4a94e6-03f1-4d8a-b895-a087531b2dde	doctor	757d6edf-5aa8-461b-ac4f-9e8365017424	1	+52-55-3407-9486	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.730523+00	2025-11-22 04:41:39.730523+00
f0e432db-3b6e-482b-a7c5-caef2252282a	doctor	c0d54a00-2ee9-4827-a7fb-6196ef15bdee	1	+52-33-2852-9244	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.734333+00	2025-11-22 04:41:39.734333+00
5aebc7bc-7237-4063-b28a-ea94062e8a46	doctor	a7ada88a-7935-4dd5-8a4f-935c4b7c0bab	1	+52-55-3726-8125	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.738678+00	2025-11-22 04:41:39.738678+00
7461fa55-a92c-4185-a6d0-e1e10e981521	doctor	4664d394-c950-4dbf-9b40-7b34c6d6dabb	1	+52-33-7925-4823	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.742501+00	2025-11-22 04:41:39.742501+00
fa27f6d0-22f6-4e38-a714-6009ebb2115f	doctor	c16b254c-dcf7-4a31-a101-1ed86b62477e	1	+52-55-2215-9131	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.746467+00	2025-11-22 04:41:39.746467+00
f91fd778-2406-4132-9bce-642fc650a13d	doctor	e0926c16-7f63-41ae-a091-1d0688c88322	1	+52-322-6670-3319	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.751402+00	2025-11-22 04:41:39.751402+00
3aeb85c7-31a9-4e72-940b-d725c3499ff2	doctor	250b33c9-1ba3-44e6-9c35-cde7000d6d53	1	+52-81-3944-1078	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.755953+00	2025-11-22 04:41:39.755953+00
930f1a1f-8fa1-4378-bd09-c8cf2bf03f82	doctor	b6c86aef-75e2-4c64-bceb-e7de898b5a1b	1	+52-81-2071-7460	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.761136+00	2025-11-22 04:41:39.761136+00
85bfa8c3-9bab-40b2-9e38-750555eb37e8	doctor	a3fb2dae-2a69-434f-86a9-65ae48c8f690	1	+52-33-2950-8850	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.766568+00	2025-11-22 04:41:39.766568+00
89bfd749-a0ed-485e-8e06-de450bb59da5	doctor	820c1228-3d2d-4766-900f-32940f14e74b	1	+52-81-7502-5030	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.770901+00	2025-11-22 04:41:39.770901+00
b8869a6e-052e-47ac-a507-8d6367f45ce5	doctor	da3dbacf-8df0-46cf-bbef-b51615063a9b	1	+52-322-8946-4245	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.774296+00	2025-11-22 04:41:39.774296+00
88361136-7e69-4d8a-82dd-eb15354c8111	doctor	e6ce6823-6c4d-4ead-98d7-78b94483fe2c	1	+52-322-2883-3832	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.777735+00	2025-11-22 04:41:39.777735+00
7e2cc51c-1fe5-43bc-9157-d95819345818	doctor	84cb6703-edfc-4180-9f80-619064c9684e	1	+52-477-2665-4686	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.781715+00	2025-11-22 04:41:39.781715+00
6663b6ae-c39b-4300-b8e0-242b94db8de3	doctor	21e4d7a9-73dc-4156-b413-b389c2e92a0d	1	+52-55-5101-7210	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.785809+00	2025-11-22 04:41:39.785809+00
931b4631-847a-4103-bfb5-6a8108f6d407	doctor	85eb8041-b502-4b90-b586-c7c4593b5347	1	+52-81-4944-2609	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.790611+00	2025-11-22 04:41:39.790611+00
6847f075-2a3f-4b02-814c-50ef629ed219	doctor	c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9	1	+52-477-2075-4541	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.797653+00	2025-11-22 04:41:39.797653+00
74e6857a-01fe-4c8f-b58a-a2051834e082	doctor	22d570dd-a72e-4599-8f13-df952d35d616	1	+52-33-2138-1128	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.803769+00	2025-11-22 04:41:39.803769+00
199bef36-11fe-4c98-ba05-1b688581c985	doctor	04a9b2e7-638b-4fe0-a106-16b582d946ab	1	+52-55-1736-1561	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.814692+00	2025-11-22 04:41:39.814692+00
12a741f9-d5bd-45c4-8159-d29c6cdee815	doctor	03e547d1-325a-46ea-bc94-c188abf53f0f	1	+52-322-8510-3279	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.818603+00	2025-11-22 04:41:39.818603+00
c99ae804-d74d-4a90-90cc-b25db52acac7	doctor	5a6de593-99b5-4942-a379-fd21b2a4999f	1	+52-322-1790-5546	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.821688+00	2025-11-22 04:41:39.821688+00
b7d664c7-6863-4b9a-ae1e-f04ddbe897ef	doctor	b7dd043b-953f-4e04-8a80-1c613d3c6675	1	+52-477-5832-7205	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.824715+00	2025-11-22 04:41:39.824715+00
190876c6-b4dc-447e-8192-2cf8f4581393	doctor	852beb97-3c99-4391-879f-98f0c2154c20	1	+52-55-2594-9486	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.828365+00	2025-11-22 04:41:39.828365+00
6f826ff7-65eb-4483-9db0-205e44b0c82b	doctor	86bb4262-7a96-444b-a096-d3a1bd7782e7	1	+52-81-2838-8623	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.83316+00	2025-11-22 04:41:39.83316+00
187c3ac2-b3d5-49a1-9f13-2f7008879154	doctor	b441c98a-1075-4013-9fc2-9242d910713f	1	+52-322-1750-8948	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.837534+00	2025-11-22 04:41:39.837534+00
6e8e30ac-72b5-428f-ab76-01c495b0f309	doctor	77486cf8-54d8-4120-856f-642ebae74d48	1	+52-55-4791-4899	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.841128+00	2025-11-22 04:41:39.841128+00
715d6be9-7b90-4aca-8605-e991e99f6c7e	doctor	0e2fa589-05b2-402c-9722-1022a0121b04	1	+52-477-8972-7151	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.845826+00	2025-11-22 04:41:39.845826+00
c4a12b34-1309-4a8d-a1a9-2dd081e2525e	patient	2f5622af-8528-4c85-8e16-3d175a4f2d15	1	47767326416	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.850916+00	2025-11-22 04:41:39.850916+00
acd1b546-43ba-4542-a7d8-9589e9ccc3a4	patient	fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	1	3323019122	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.855887+00	2025-11-22 04:41:39.855887+00
27d38650-3841-4486-87bd-06177c08c1b9	patient	959aa1dd-346b-4542-8f99-0d5e75301249	1	5552272115	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.860555+00	2025-11-22 04:41:39.860555+00
c9949a32-6a9f-4468-ae53-c58ba248216e	patient	59402562-ce5f-450e-8e6c-9630514fe164	1	47742686139	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.864355+00	2025-11-22 04:41:39.864355+00
1ed45aec-59dc-48c8-ae0d-80dc0abe9cce	patient	f81c87d6-32f1-4c79-993a-18db4734ef65	1	47788928661	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.867743+00	2025-11-22 04:41:39.867743+00
046a31f3-ce34-49cb-bbac-efc164b792b0	patient	0b6b8229-4027-4ec7-8bce-c805de96ced3	1	5556849742	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.871629+00	2025-11-22 04:41:39.871629+00
044f46f5-c2fd-44d8-a814-d58483a5c7dc	patient	f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	1	47741013863	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.875464+00	2025-11-22 04:41:39.875464+00
86670dd7-4405-4e80-86ac-a9270d87dbce	patient	f2a1f62a-8030-4f65-b82d-ce7376b955bd	1	5592236447	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.881326+00	2025-11-22 04:41:39.881326+00
3cdaa0ec-ba9f-41bb-81cf-4c0b23972a73	patient	0104fea2-d27c-4611-8414-da6c898b6944	1	5564980935	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.885523+00	2025-11-22 04:41:39.885523+00
dcfa71e0-f1eb-49fe-82d8-856c4b69903f	patient	cd0c2f0c-de08-439c-93c9-0feab1d433cc	1	32272329493	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.890311+00	2025-11-22 04:41:39.890311+00
ae0e4055-796e-4aea-a023-c34822c5d917	patient	7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	1	5565181217	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.897069+00	2025-11-22 04:41:39.897069+00
6097deca-68a5-4c41-b2ed-f35d41873b34	patient	7893292b-965a-41da-896a-d0780c91fdd5	1	47722252483	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.903316+00	2025-11-22 04:41:39.903316+00
31c95e01-cc20-4a63-ad54-8aa8fd715d9c	patient	87fb3c88-6653-45db-aa6c-20ea7512da64	1	32288625625	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.910018+00	2025-11-22 04:41:39.910018+00
fbc9dade-27a1-43db-a8ee-ec02ef22a18c	patient	05e42aed-c457-4579-904f-d397be3075f7	1	32276286121	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.914728+00	2025-11-22 04:41:39.914728+00
398abfc3-6d90-4482-9693-a407cd53f8fe	patient	43756f6c-c157-4a44-9c84-ab2d62fddcf7	1	5537628005	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.919282+00	2025-11-22 04:41:39.919282+00
625101b2-6acf-4c68-881c-7ef994b36ed7	patient	d8e1fa52-0a65-4917-b410-2954e05a34e5	1	32257680744	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.923527+00	2025-11-22 04:41:39.923527+00
002792ef-3050-486f-ae4c-b15a9f6f45bb	patient	bbc67f38-a9eb-4379-aeaf-1560af0d1a34	1	32222570425	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.92764+00	2025-11-22 04:41:39.92764+00
f2877fa4-a892-46d8-be7f-51cc590915e5	patient	b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	1	8130775568	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.932349+00	2025-11-22 04:41:39.932349+00
d6840298-4220-44e4-8df2-a3cf9ce6784f	patient	309df411-1d1a-4d00-a34e-36e8c32da210	1	47786693347	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.936016+00	2025-11-22 04:41:39.936016+00
f7c03f3f-b058-455d-be87-2b89a22e7a97	patient	663d036b-a19b-4557-af37-d68a9ce4976d	1	3374570335	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.939617+00	2025-11-22 04:41:39.939617+00
2f2cf533-3bdd-4819-bc63-ce0a19a029a8	patient	a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	1	3357731626	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.943706+00	2025-11-22 04:41:39.943706+00
c7b04c4f-8d98-471b-80ae-7b31d360dcf8	patient	d5b1779e-21f2-4252-a421-f2aaf9998916	1	32266756711	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.947697+00	2025-11-22 04:41:39.947697+00
245ce9b5-6e9f-4a93-8005-3dc64924ed64	patient	6661483b-705b-412a-8bbd-39c0af0dadb1	1	3342075624	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.952288+00	2025-11-22 04:41:39.952288+00
e21d9eec-d400-43fd-8c41-4f8074423f0b	patient	676491c4-f31a-42b6-a991-a8dd09bbb1f0	1	47787809687	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.956654+00	2025-11-22 04:41:39.956654+00
d47e65c7-baa3-4383-8a82-8c86bb1442ad	patient	3a9e8e0e-6367-409d-a81c-9852069c710e	1	8152479108	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.961411+00	2025-11-22 04:41:39.961411+00
3e7d261b-038d-49c3-8de4-ce02774659dc	patient	167dedde-166c-45e4-befc-4f1c9b7184ad	1	5532669687	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.965383+00	2025-11-22 04:41:39.965383+00
abb5698e-26a9-4660-b115-cce4e8f84638	patient	72eca572-4ecf-4be8-906b-40e89e0d9a08	1	5558755697	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.96858+00	2025-11-22 04:41:39.96858+00
a8c76202-c256-4501-bc44-921c79ed0629	patient	d5bec069-a317-4a40-b3e8-ea80220d75de	1	47777019760	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.973489+00	2025-11-22 04:41:39.973489+00
6b2c32c5-04d5-4521-8e22-fd4efe5a8414	patient	0e97294d-78cc-4428-a172-e4e1fd4efa72	1	32272397391	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.977162+00	2025-11-22 04:41:39.977162+00
5e4694ed-b6f3-475b-a36d-46e4f4976703	patient	9f86a53f-f0e1-446d-89f0-86b086dd12a9	1	8182975364	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.98053+00	2025-11-22 04:41:39.98053+00
e6181d6f-577d-46a8-a849-f7d643f19a97	patient	ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	1	3378488067	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.983539+00	2025-11-22 04:41:39.983539+00
53e0a238-165b-496a-b907-a85ff6801735	patient	d28440a6-3bd9-4a48-8a72-d700ae0971e4	1	32217631358	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.988272+00	2025-11-22 04:41:39.988272+00
a8412b9e-5d11-4a2b-b2a7-cdfbaa8f8139	patient	7f839ee8-bdd6-4a63-83e8-30db007565e2	1	32256266752	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.991537+00	2025-11-22 04:41:39.991537+00
f1e6edd4-fd23-4aa2-8e30-e07f975cedcc	patient	67aa999f-9d31-4b61-a097-35097ea0d082	1	5564754519	+52	\N	t	t	\N	\N	2025-11-22 04:41:39.996302+00	2025-11-22 04:41:39.996302+00
c7b3cdb2-71a8-4e13-ae72-3a24144b99ad	patient	41aa2fbc-8ef4-4448-8686-399a1cd54be9	1	3341002447	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.001816+00	2025-11-22 04:41:40.001816+00
2966f8fd-0d34-4106-acc3-ebd2bb856cc6	patient	111769f3-1a1b-44a9-9670-f4f2e424d1d2	1	3314033550	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.006399+00	2025-11-22 04:41:40.006399+00
350f5e84-c840-4768-a69d-30be1c39ee3c	patient	2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	1	3388797752	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.011237+00	2025-11-22 04:41:40.011237+00
280cf12d-0cc8-4061-8c21-68de716cbb90	patient	6a8b6d41-8d20-4bc5-8d48-538d348f6086	1	3339979399	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.015808+00	2025-11-22 04:41:40.015808+00
59e8f78a-92e1-40b4-8ebe-4dd34b1bdcd5	patient	89657c95-84c0-4bd0-80c6-70a2c4721276	1	47719555349	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.019256+00	2025-11-22 04:41:40.019256+00
8b9ec99a-4254-4726-ae8a-46bf0e8606e2	patient	b6658dac-0ee1-415c-95ad-28c6acea85bd	1	32212169179	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.023076+00	2025-11-22 04:41:40.023076+00
f83b7dab-528a-4ae9-b28f-3567204d65f7	patient	56564104-6009-466c-9134-c15d3175613b	1	5533370300	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.026722+00	2025-11-22 04:41:40.026722+00
0e02dc55-1d14-4427-a9c1-d43e1ffa655a	patient	edb1d693-b308-4ff6-8fd4-9e20561317e8	1	32242195966	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.031555+00	2025-11-22 04:41:40.031555+00
b9931b27-f460-4f75-925a-801a9e2a6ac9	patient	9511f9b9-a450-489c-92b9-ac306733cee4	1	3376013110	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.035584+00	2025-11-22 04:41:40.035584+00
3263fd6d-af6c-44bc-ba29-28c50d059118	patient	004ce58b-6a0d-4646-92c3-4508deb6b354	1	3378871890	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.039647+00	2025-11-22 04:41:40.039647+00
8f573744-7c7e-4d40-a635-1b14a1039177	patient	0d1bcc20-a5be-40f0-a28b-23c2c77c51be	1	3363009943	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.043735+00	2025-11-22 04:41:40.043735+00
efd616a5-0f7c-4aa9-b3ac-3762102ff89a	patient	38000dbb-417f-43ca-a60e-5812796420f7	1	47738838906	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.047676+00	2025-11-22 04:41:40.047676+00
3131b58b-8c35-442f-8771-cc683f2b9b69	patient	5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	1	5559834687	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.051252+00	2025-11-22 04:41:40.051252+00
d7ae91d0-e871-4f5a-a150-e65ab6785787	patient	561c313d-2c15-41b1-b965-a38c8e0f6c42	1	5582501507	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.057381+00	2025-11-22 04:41:40.057381+00
952c3484-1f21-48b1-ad5b-bd5bd5bdbf46	patient	ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	1	5546022019	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.062337+00	2025-11-22 04:41:40.062337+00
626f8bf9-7386-45a5-9d6f-73ddff38e9dd	patient	cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	1	3396137254	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.066236+00	2025-11-22 04:41:40.066236+00
3e829b3a-4f96-4461-a71b-1353565e1aa7	patient	05bc2942-e676-42e9-ad01-ade9f7cc5aee	1	32245563881	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.071018+00	2025-11-22 04:41:40.071018+00
9f36b14e-360f-4ebc-beaa-239b2e34cd8d	patient	c78e7658-d517-4ca1-990b-e6971f8d108f	1	5519008445	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.075095+00	2025-11-22 04:41:40.075095+00
733afd66-1e04-4ad0-b4ef-9980eba4ab8c	patient	65474c27-8f72-4690-8f19-df9344e4be5e	1	3315951035	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.080637+00	2025-11-22 04:41:40.080637+00
14e7a77c-6637-4518-9e59-e71942ff6064	patient	c1b6fa98-203a-4321-96cd-e80e7a1c9461	1	5554080736	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.085593+00	2025-11-22 04:41:40.085593+00
eb718a32-65bc-415e-9862-c95fe295b702	patient	9244b388-8c06-42c7-9c4e-cbaae5b1baa3	1	32299706924	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.089877+00	2025-11-22 04:41:40.089877+00
f2cefff3-c647-4a57-b3b6-66a3b5901fdb	patient	eb2e55f6-4738-4352-a59a-860909f1932c	1	8195094207	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.093645+00	2025-11-22 04:41:40.093645+00
ff317447-c6f0-43da-949e-32318e671674	patient	c572a4c7-e475-4d18-85da-417abcd00903	1	32248045763	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.098474+00	2025-11-22 04:41:40.098474+00
a2159a9f-d040-4ea0-9e48-3a26995d171b	patient	5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	1	8198067941	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.104348+00	2025-11-22 04:41:40.104348+00
58100ecb-21be-47e1-b379-7718df82bc44	patient	9b02d89c-2c5b-4c51-8183-15ccd1184990	1	5537143958	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.108321+00	2025-11-22 04:41:40.108321+00
ff7e3874-a48d-40f9-a63a-55ee6d2d1116	patient	43ae2e81-ac13-40ac-949c-9e4f51d76098	1	5538402736	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.11251+00	2025-11-22 04:41:40.11251+00
479338e2-c188-4d1c-bbb8-3538e7f80dc0	patient	49a18092-8f90-4f6b-873c-8715b64b8aff	1	8114757351	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.116934+00	2025-11-22 04:41:40.116934+00
8c8ead6b-17e1-413e-8f21-f2c1b3dc8499	patient	c9a949e5-e650-4d95-9e2e-49ed06e5d087	1	47717117861	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.122617+00	2025-11-22 04:41:40.122617+00
f2d04fea-4b6d-4b3a-8600-6841ad7858d8	patient	a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	1	5595587427	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.126799+00	2025-11-22 04:41:40.126799+00
fa3250cf-f25c-410c-99b0-a065a0aeabe5	patient	447e48dc-861c-41e6-920e-a2dec785101f	1	8133123358	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.130057+00	2025-11-22 04:41:40.130057+00
4922a332-54f7-4d35-b903-64c121be2c73	patient	3a535951-40fd-4959-a34e-07b29f675ecc	1	8114053075	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.133889+00	2025-11-22 04:41:40.133889+00
1e0651a6-1535-4b4e-8cfa-ebd381e468c1	patient	d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	1	8172708573	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.139462+00	2025-11-22 04:41:40.139462+00
a810e0c9-de60-4972-b4f4-d736befd12d5	patient	6052a417-6725-4fab-b7dd-7f498454cd47	1	3321351205	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.143106+00	2025-11-22 04:41:40.143106+00
9156379d-8774-491e-9552-78879ba8445d	patient	dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	1	47727312181	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.148825+00	2025-11-22 04:41:40.148825+00
26c8432b-7e0a-45a8-9164-e6d079d5f86a	patient	cbd398cc-dfde-41c4-b7b1-ca32cc99945f	1	47753397084	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.153788+00	2025-11-22 04:41:40.153788+00
d0b55b35-ee02-409a-872b-2ca00b947c3f	patient	f740b251-4264-4220-8400-706331f650af	1	32248211429	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.157578+00	2025-11-22 04:41:40.157578+00
e265dd1f-e76e-4bca-9220-9d423d9c5937	patient	fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	1	8164936372	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.163132+00	2025-11-22 04:41:40.163132+00
8c7136ec-05f9-4fde-8094-5172169386c6	patient	97d5d278-c876-4078-9dba-2940edfed9a0	1	5589676137	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.16865+00	2025-11-22 04:41:40.16865+00
d6b72899-9989-425e-9b21-4f0f5b432410	patient	a329242d-9e38-4178-aa8e-5b7497209897	1	32293842224	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.172595+00	2025-11-22 04:41:40.172595+00
add6dd38-c80a-4c8a-a8d4-b0d60c88f5b0	patient	fe2cc660-dd15-4d31-ac72-56114bdb6b92	1	8133988925	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.176382+00	2025-11-22 04:41:40.176382+00
38c97327-76da-4db3-9726-d66ee90c6ce2	patient	fd01c50f-f3dd-4517-96c0-c0e65330a692	1	8128706159	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.180444+00	2025-11-22 04:41:40.180444+00
8ba65f1a-4db4-4442-9246-4faf76b8c6bf	patient	f56cc0bc-1765-4334-9594-73dcc9deac8e	1	47782996667	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.187338+00	2025-11-22 04:41:40.187338+00
3555fbe7-9ec0-4037-88a8-e072cf0033c9	patient	1c861cbf-991d-4820-b3f0-98538fb0d454	1	8154437852	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.192907+00	2025-11-22 04:41:40.192907+00
0df1d302-44f2-4b69-8bee-ba08657e8ecd	patient	70f066e1-fc10-4b37-92ea-0de96307793b	1	3365682270	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.197379+00	2025-11-22 04:41:40.197379+00
312c9832-f16b-4b1b-8538-4ffbb8331aac	patient	d1ec4069-41a0-4317-a6c6-84914d108257	1	5570138992	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.202466+00	2025-11-22 04:41:40.202466+00
17848e05-5333-4cd1-a3df-82b7af463628	patient	04239007-edaa-4c74-95dd-4ba4df226b0f	1	32288930466	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.206766+00	2025-11-22 04:41:40.206766+00
30a456d1-c205-4469-8158-df501d157e13	patient	0deef39b-719e-4f3a-a84f-2072803b2548	1	8169920292	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.212439+00	2025-11-22 04:41:40.212439+00
447949cd-f182-441c-823b-79cad63c4518	patient	5156864c-fa59-4e48-b357-477838800efc	1	32271925585	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.219026+00	2025-11-22 04:41:40.219026+00
76c5e564-3083-4b0c-b5bd-29e0c5f65006	patient	d911f0a5-9268-4eb4-87e9-508d7c99b753	1	47743590695	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.222924+00	2025-11-22 04:41:40.222924+00
74f0fa69-88b2-49d0-bbde-9396e55a5f92	patient	c3e065c2-c0a9-440f-98f3-1c5463949056	1	47769556025	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.226984+00	2025-11-22 04:41:40.226984+00
c2aa151a-4cf9-41c5-a913-88257e3616a4	patient	b2eef54b-21a7-45ec-a693-bc60f1d6e293	1	3314275368	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.232296+00	2025-11-22 04:41:40.232296+00
e0d0f832-2bf2-498d-8b43-b3ba521471ac	patient	3854a76e-ee29-4976-b630-1d7e18fb9887	1	3347815113	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.236934+00	2025-11-22 04:41:40.236934+00
b2704e6f-50c2-4edd-8f81-8b2020d177f4	patient	6b2e25e9-ebcb-4150-a594-c5742cd42121	1	32294167206	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.242683+00	2025-11-22 04:41:40.242683+00
2ec9a615-bf89-4cad-8c98-3ca91f4df289	patient	cc38cb13-51a5-4539-99c2-894cd2b207f1	1	5575125352	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.247835+00	2025-11-22 04:41:40.247835+00
14b7fd23-3b96-4159-b350-588708ebaaaa	patient	6af409b5-c8b8-4664-97cd-d419eedcc932	1	32255124149	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.257058+00	2025-11-22 04:41:40.257058+00
03fe705b-4c3b-40f2-8e56-b0a0a111a7c1	patient	227a2c03-dfd1-4e03-9c04-daaf74fc68bd	1	5578131146	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.262081+00	2025-11-22 04:41:40.262081+00
3be8b899-e7ad-4c5b-a845-9ee309cdd758	patient	bc6e7a77-d709-401c-bea7-82715eeb1a29	1	3374553593	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.26761+00	2025-11-22 04:41:40.26761+00
091cd16d-027a-4531-9a2f-87ba4cecaf8d	patient	d54d7239-e49a-4185-8875-4f71af08b789	1	3399313134	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.271639+00	2025-11-22 04:41:40.271639+00
85fe1bf1-b46a-432e-b5d7-2e9bfa400b22	patient	8370857e-7e69-43a6-be63-78fc270c5fd5	1	5539331804	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.275482+00	2025-11-22 04:41:40.275482+00
2a35d145-e174-4b99-9e0b-18687fb93b28	patient	e8813bf8-7bbb-4370-a181-880c0c959aa1	1	8170719562	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.280534+00	2025-11-22 04:41:40.280534+00
f7718bb0-7ff3-425f-9193-295983e4c4d2	patient	4337bfc4-5ea7-4621-bd24-dbf3f55e350a	1	3327135490	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.284164+00	2025-11-22 04:41:40.284164+00
444cfedb-e124-4fa6-a82b-e531c2a4f517	patient	517958b1-f860-4a42-965b-15a796055981	1	47740108537	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.288152+00	2025-11-22 04:41:40.288152+00
a7d0e86e-8818-4986-91fb-392aa13116be	patient	44e4c099-cf6e-4926-85f1-ab5cb34c59a1	1	47716563624	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.292875+00	2025-11-22 04:41:40.292875+00
84b9850f-bea7-4d15-aea3-8fce7c734a32	patient	a0c3c815-c664-4931-927f-e4109a545603	1	3366571536	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.2991+00	2025-11-22 04:41:40.2991+00
7999b655-db39-485a-bc19-eac4690fd805	patient	5c1862f6-f802-41ae-a6fb-87dbc5555fb3	1	3348834139	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.304554+00	2025-11-22 04:41:40.304554+00
f2bda5eb-a79d-41da-a8e5-636faa44ab60	patient	11d31cb4-1dfb-479e-9329-8b8b35920b98	1	32276592463	+52	\N	t	t	\N	\N	2025-11-22 04:41:40.311495+00	2025-11-22 04:41:40.311495+00
ddd0dbf3-a3c6-497f-9459-f78b2a97ff88	emergency_contact	2f5622af-8528-4c85-8e16-3d175a4f2d15	6	47757812915	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.317898+00	2025-11-22 04:41:40.317898+00
b643b170-05e6-4f83-938e-4a228cdfb4a4	emergency_contact	fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	6	3316290664	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.325781+00	2025-11-22 04:41:40.325781+00
00943e09-35ae-4a68-8b91-b13bcf249526	emergency_contact	959aa1dd-346b-4542-8f99-0d5e75301249	6	5549262091	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.332009+00	2025-11-22 04:41:40.332009+00
766bf4ae-4700-4200-9a16-f9cac0dc96c1	emergency_contact	59402562-ce5f-450e-8e6c-9630514fe164	6	47777466011	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.343371+00	2025-11-22 04:41:40.343371+00
f7c797e8-1049-4eef-bdc9-de7e08abb287	emergency_contact	f81c87d6-32f1-4c79-993a-18db4734ef65	6	47719440069	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.350041+00	2025-11-22 04:41:40.350041+00
850742b6-3708-4f50-b251-67a3e07fd5a8	emergency_contact	0b6b8229-4027-4ec7-8bce-c805de96ced3	6	5533631360	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.356546+00	2025-11-22 04:41:40.356546+00
28e447cb-2d7b-428f-a6b1-3971b4af4733	emergency_contact	f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	6	47768973328	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.36253+00	2025-11-22 04:41:40.36253+00
699146d4-0af3-4995-ab97-016810e80490	emergency_contact	f2a1f62a-8030-4f65-b82d-ce7376b955bd	6	5591906591	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.376727+00	2025-11-22 04:41:40.376727+00
e4c4457b-51d7-4643-8f44-99475e488201	emergency_contact	0104fea2-d27c-4611-8414-da6c898b6944	6	5545382442	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.379686+00	2025-11-22 04:41:40.379686+00
9c13485d-f0e7-4eb9-9a5b-b5da3b9b54c6	emergency_contact	cd0c2f0c-de08-439c-93c9-0feab1d433cc	6	32277282119	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.398685+00	2025-11-22 04:41:40.398685+00
cbea71ac-d3c7-441e-9455-28d1df0a43f4	emergency_contact	7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	6	5557200410	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.405178+00	2025-11-22 04:41:40.405178+00
c0498227-58a7-4eba-9c79-b582bd106ee2	emergency_contact	7893292b-965a-41da-896a-d0780c91fdd5	6	47713236152	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.411205+00	2025-11-22 04:41:40.411205+00
cd91dc4a-014b-4a14-bb08-682be0cece9f	emergency_contact	87fb3c88-6653-45db-aa6c-20ea7512da64	6	32240358018	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.416069+00	2025-11-22 04:41:40.416069+00
95a90108-8549-4a57-9a53-429e1c9a3554	emergency_contact	05e42aed-c457-4579-904f-d397be3075f7	6	32231720413	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.42062+00	2025-11-22 04:41:40.42062+00
5cd7d2ae-617e-4206-bc8c-d09da5bcb63b	emergency_contact	43756f6c-c157-4a44-9c84-ab2d62fddcf7	6	5532528860	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.440486+00	2025-11-22 04:41:40.440486+00
c876aade-6be5-4010-bfaf-06b8aebbbcf3	emergency_contact	d8e1fa52-0a65-4917-b410-2954e05a34e5	6	32217005084	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.447325+00	2025-11-22 04:41:40.447325+00
632afd78-ca79-4168-9934-ba42b5f2c213	emergency_contact	bbc67f38-a9eb-4379-aeaf-1560af0d1a34	6	32226323981	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.452327+00	2025-11-22 04:41:40.452327+00
63dd3a2c-a8be-49d3-9f42-058cf0a121f3	emergency_contact	b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	6	8182656773	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.457761+00	2025-11-22 04:41:40.457761+00
100d32e9-5a27-441c-855e-5b54cccac7ad	emergency_contact	309df411-1d1a-4d00-a34e-36e8c32da210	6	47798461842	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.463407+00	2025-11-22 04:41:40.463407+00
9497e8c4-e45a-49a1-843a-5494e8228bc3	emergency_contact	663d036b-a19b-4557-af37-d68a9ce4976d	6	3334949462	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.468713+00	2025-11-22 04:41:40.468713+00
8185558c-9f74-4b19-adde-5daf6a9df724	emergency_contact	a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	6	3384401071	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.47567+00	2025-11-22 04:41:40.47567+00
4230f2eb-0176-4e37-be60-5584a699a7bf	emergency_contact	d5b1779e-21f2-4252-a421-f2aaf9998916	6	32234403822	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.496561+00	2025-11-22 04:41:40.496561+00
d80991dc-da9e-47d7-a32d-fe2ffc1503cb	emergency_contact	6661483b-705b-412a-8bbd-39c0af0dadb1	6	3336316084	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.50203+00	2025-11-22 04:41:40.50203+00
9ae9bf60-2e76-49c8-b55e-5bdfaedb5d52	emergency_contact	676491c4-f31a-42b6-a991-a8dd09bbb1f0	6	47787133120	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.507775+00	2025-11-22 04:41:40.507775+00
2916c652-46f1-4b4f-9077-d481f5516dbd	emergency_contact	3a9e8e0e-6367-409d-a81c-9852069c710e	6	8142663874	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.528533+00	2025-11-22 04:41:40.528533+00
dc221ba6-c6de-4b30-a43c-4c3edd569439	emergency_contact	167dedde-166c-45e4-befc-4f1c9b7184ad	6	5589365672	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.534666+00	2025-11-22 04:41:40.534666+00
2c4703b9-bb55-4d1f-95f2-98843c6bc0f1	emergency_contact	72eca572-4ecf-4be8-906b-40e89e0d9a08	6	5590745709	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.55519+00	2025-11-22 04:41:40.55519+00
0e99ccad-775e-4db5-bc20-6c396ad3988e	emergency_contact	d5bec069-a317-4a40-b3e8-ea80220d75de	6	47796089974	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.56082+00	2025-11-22 04:41:40.56082+00
48cb08e5-d2c3-4b17-b50e-53a84650f401	emergency_contact	0e97294d-78cc-4428-a172-e4e1fd4efa72	6	32248518852	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.565997+00	2025-11-22 04:41:40.565997+00
beec9cd6-4a37-4b25-9dcb-e594cffb1b97	emergency_contact	9f86a53f-f0e1-446d-89f0-86b086dd12a9	6	8160157332	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.586598+00	2025-11-22 04:41:40.586598+00
48334fd0-a7c2-47a6-8d0e-5fe7953a4506	emergency_contact	ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	6	3344616862	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.592019+00	2025-11-22 04:41:40.592019+00
35d7f44a-9eae-4623-b87d-85110f95dba2	emergency_contact	d28440a6-3bd9-4a48-8a72-d700ae0971e4	6	32237033771	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.612187+00	2025-11-22 04:41:40.612187+00
ae5881d3-28f3-4b1e-8c64-34cf905629cd	emergency_contact	7f839ee8-bdd6-4a63-83e8-30db007565e2	6	32227437159	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.618819+00	2025-11-22 04:41:40.618819+00
b60169ac-ab66-4d4f-b75e-78bd376baabe	emergency_contact	67aa999f-9d31-4b61-a097-35097ea0d082	6	5595397265	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.624319+00	2025-11-22 04:41:40.624319+00
2ef85523-5bc6-40b8-8713-c5525310385f	emergency_contact	41aa2fbc-8ef4-4448-8686-399a1cd54be9	6	3332543753	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.645521+00	2025-11-22 04:41:40.645521+00
d45d26ca-7c07-4ef3-813c-75954ed7949d	emergency_contact	111769f3-1a1b-44a9-9670-f4f2e424d1d2	6	3380722874	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.651898+00	2025-11-22 04:41:40.651898+00
62fa0d83-a586-486a-8748-331450c3dfbf	emergency_contact	2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	6	3395349229	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.658094+00	2025-11-22 04:41:40.658094+00
05fa1c3c-e921-4c49-ac2d-eaf9d928e0a8	emergency_contact	6a8b6d41-8d20-4bc5-8d48-538d348f6086	6	3344423620	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.664462+00	2025-11-22 04:41:40.664462+00
432a05d9-1a4b-4eae-a558-e30ad83a8825	emergency_contact	89657c95-84c0-4bd0-80c6-70a2c4721276	6	47750456931	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.670152+00	2025-11-22 04:41:40.670152+00
16ddde3b-2f3d-4488-a911-452da14a2204	emergency_contact	b6658dac-0ee1-415c-95ad-28c6acea85bd	6	32245486528	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.674826+00	2025-11-22 04:41:40.674826+00
99a7485d-1bd9-4cb4-87fd-e9fd0892ba5f	emergency_contact	56564104-6009-466c-9134-c15d3175613b	6	5573731864	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.695162+00	2025-11-22 04:41:40.695162+00
0ef45c28-c4a8-4773-b843-da56cb6388f2	emergency_contact	edb1d693-b308-4ff6-8fd4-9e20561317e8	6	32245132273	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.70111+00	2025-11-22 04:41:40.70111+00
24797c50-675e-4746-a324-7a81edccee71	emergency_contact	9511f9b9-a450-489c-92b9-ac306733cee4	6	3313199477	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.707711+00	2025-11-22 04:41:40.707711+00
59b740d5-f093-4f62-8c39-8b6007e453d1	emergency_contact	004ce58b-6a0d-4646-92c3-4508deb6b354	6	3315085656	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.713228+00	2025-11-22 04:41:40.713228+00
9d375c60-8e2c-4151-a5cb-4bc0649d4b63	emergency_contact	0d1bcc20-a5be-40f0-a28b-23c2c77c51be	6	3348205238	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.719174+00	2025-11-22 04:41:40.719174+00
ec096222-d3d4-482b-90ed-4b3962cfa902	emergency_contact	38000dbb-417f-43ca-a60e-5812796420f7	6	47769498364	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.723917+00	2025-11-22 04:41:40.723917+00
43aae9a1-7655-4879-b849-928e86a29455	emergency_contact	5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	6	5598817898	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.743865+00	2025-11-22 04:41:40.743865+00
90a791b9-70de-4de7-b8a4-46abac7dba81	emergency_contact	561c313d-2c15-41b1-b965-a38c8e0f6c42	6	5514944156	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.764344+00	2025-11-22 04:41:40.764344+00
84fe3644-5833-4c0f-bbf1-f294164994f8	emergency_contact	ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	6	5598214663	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.769882+00	2025-11-22 04:41:40.769882+00
3e9fae47-bb42-45df-91e6-9439a26c8b1c	emergency_contact	cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	6	3315965116	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.776242+00	2025-11-22 04:41:40.776242+00
740e323c-3d63-4534-b99b-71a6fa228e91	emergency_contact	05bc2942-e676-42e9-ad01-ade9f7cc5aee	6	32276426588	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.79697+00	2025-11-22 04:41:40.79697+00
c80581b2-6294-488f-bdca-e79f62458b50	emergency_contact	c78e7658-d517-4ca1-990b-e6971f8d108f	6	5519690783	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.820178+00	2025-11-22 04:41:40.820178+00
9b141c52-dee5-4a99-bb74-754c6548458e	emergency_contact	65474c27-8f72-4690-8f19-df9344e4be5e	6	3392698723	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.830715+00	2025-11-22 04:41:40.830715+00
25322707-c52f-413c-a799-849546d906ed	emergency_contact	c1b6fa98-203a-4321-96cd-e80e7a1c9461	6	5539382237	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.836388+00	2025-11-22 04:41:40.836388+00
b2174c63-840f-46f4-9484-8c7c3ee79a38	emergency_contact	9244b388-8c06-42c7-9c4e-cbaae5b1baa3	6	32222860074	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.840889+00	2025-11-22 04:41:40.840889+00
7b962adc-ce5a-403d-9f68-fde677b14ca2	emergency_contact	eb2e55f6-4738-4352-a59a-860909f1932c	6	8183350913	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.845643+00	2025-11-22 04:41:40.845643+00
b3b78abf-618c-44b1-a8ab-72ac8953e52e	emergency_contact	c572a4c7-e475-4d18-85da-417abcd00903	6	32220622451	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.865219+00	2025-11-22 04:41:40.865219+00
5d4f1f60-04d1-4255-adc9-3e3a71667bf3	emergency_contact	5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	6	8138604175	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.870218+00	2025-11-22 04:41:40.870218+00
1f72e44b-b4a1-460b-8bc3-de5e9f0312c1	emergency_contact	9b02d89c-2c5b-4c51-8183-15ccd1184990	6	5541349710	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.874934+00	2025-11-22 04:41:40.874934+00
718a0776-32e7-4344-91bb-aedcb8839422	emergency_contact	43ae2e81-ac13-40ac-949c-9e4f51d76098	6	5513598507	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.880035+00	2025-11-22 04:41:40.880035+00
aafad037-bf14-4f87-b30f-bf7e7b0e81af	emergency_contact	49a18092-8f90-4f6b-873c-8715b64b8aff	6	8195643123	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.883348+00	2025-11-22 04:41:40.883348+00
767335a3-c23d-4228-9263-5f00f250e6fc	emergency_contact	c9a949e5-e650-4d95-9e2e-49ed06e5d087	6	47750168658	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.886605+00	2025-11-22 04:41:40.886605+00
75ddd702-e0d8-4262-b88b-c62b9a13cf4b	emergency_contact	a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	6	5560993019	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.890131+00	2025-11-22 04:41:40.890131+00
8ff3aebc-ff80-4c6a-9e06-ff391302ba0e	emergency_contact	447e48dc-861c-41e6-920e-a2dec785101f	6	8177598147	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.910604+00	2025-11-22 04:41:40.910604+00
88a05714-5ddd-47b9-bb51-1be067b16ec7	emergency_contact	3a535951-40fd-4959-a34e-07b29f675ecc	6	8132853218	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.915537+00	2025-11-22 04:41:40.915537+00
3be26c48-015c-485b-ad75-02d24daa5d67	emergency_contact	d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	6	8183267424	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.920224+00	2025-11-22 04:41:40.920224+00
e81d5a3b-3250-4b30-841a-e8c448714a5c	emergency_contact	6052a417-6725-4fab-b7dd-7f498454cd47	6	3379867165	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.925687+00	2025-11-22 04:41:40.925687+00
6f1f5844-54d9-4c34-aac7-18111c1b09f1	emergency_contact	dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	6	47764344603	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.930107+00	2025-11-22 04:41:40.930107+00
1039d995-5303-4be8-a965-420f4e57bc8f	emergency_contact	cbd398cc-dfde-41c4-b7b1-ca32cc99945f	6	47732012824	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.949243+00	2025-11-22 04:41:40.949243+00
d968e4f1-8df7-42ec-983e-029c67d650c0	emergency_contact	f740b251-4264-4220-8400-706331f650af	6	32262137834	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.955716+00	2025-11-22 04:41:40.955716+00
d6d018ff-2fc9-4673-85eb-4bff584af747	emergency_contact	fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	6	8177158637	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.961464+00	2025-11-22 04:41:40.961464+00
bc23739d-8c2d-4e61-b1bb-db257ec6d125	emergency_contact	97d5d278-c876-4078-9dba-2940edfed9a0	6	5527425608	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.966011+00	2025-11-22 04:41:40.966011+00
54240a92-0d4e-47e1-9f9e-478a5935ae13	emergency_contact	a329242d-9e38-4178-aa8e-5b7497209897	6	32294424318	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.971949+00	2025-11-22 04:41:40.971949+00
721a5cf3-7bee-4752-b91f-9bf1c7fcb4b9	emergency_contact	fe2cc660-dd15-4d31-ac72-56114bdb6b92	6	8143750716	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.979659+00	2025-11-22 04:41:40.979659+00
54ca17ce-0508-44a1-8591-b2e41084e27c	emergency_contact	fd01c50f-f3dd-4517-96c0-c0e65330a692	6	8135330809	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.984583+00	2025-11-22 04:41:40.984583+00
4f51e62a-3e77-4c9c-8309-34c45b14d809	emergency_contact	f56cc0bc-1765-4334-9594-73dcc9deac8e	6	47756053965	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.98952+00	2025-11-22 04:41:40.98952+00
22c25046-0bd8-4cb0-a7fc-4d84aceb2044	emergency_contact	1c861cbf-991d-4820-b3f0-98538fb0d454	6	8125415139	+52	\N	f	f	\N	\N	2025-11-22 04:41:40.995052+00	2025-11-22 04:41:40.995052+00
3f2a66c3-9fee-4f36-81a5-0d172907691b	emergency_contact	70f066e1-fc10-4b37-92ea-0de96307793b	6	3376794153	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.000819+00	2025-11-22 04:41:41.000819+00
9fced127-432c-4e8d-8870-c6f875779815	emergency_contact	d1ec4069-41a0-4317-a6c6-84914d108257	6	5588093567	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.007939+00	2025-11-22 04:41:41.007939+00
de98d991-a615-42a4-ac59-4a97f4a4d2b3	emergency_contact	04239007-edaa-4c74-95dd-4ba4df226b0f	6	32297071430	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.029965+00	2025-11-22 04:41:41.029965+00
7c961bbe-f369-47e3-a6d4-6fa3567b0b7f	emergency_contact	0deef39b-719e-4f3a-a84f-2072803b2548	6	8190637854	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.033296+00	2025-11-22 04:41:41.033296+00
ced3c09f-2444-46ad-8803-b425ac68515e	emergency_contact	5156864c-fa59-4e48-b357-477838800efc	6	32234242334	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.037254+00	2025-11-22 04:41:41.037254+00
9ff9feec-4825-4eff-b662-6b01e1862710	emergency_contact	d911f0a5-9268-4eb4-87e9-508d7c99b753	6	47761331431	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.042586+00	2025-11-22 04:41:41.042586+00
446f3797-c67e-44e9-87b7-3c624828140e	emergency_contact	c3e065c2-c0a9-440f-98f3-1c5463949056	6	47748195712	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.383413+00	2025-11-22 04:41:41.383413+00
998f7c19-8dd7-417d-b399-25009634e4b5	emergency_contact	b2eef54b-21a7-45ec-a693-bc60f1d6e293	6	3355179014	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.388392+00	2025-11-22 04:41:41.388392+00
cd388239-52ad-407c-99d1-2bb840342462	emergency_contact	3854a76e-ee29-4976-b630-1d7e18fb9887	6	3383557299	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.393282+00	2025-11-22 04:41:41.393282+00
e62715e2-fd1c-471b-ac4c-8b520b9f49fa	emergency_contact	6b2e25e9-ebcb-4150-a594-c5742cd42121	6	32219334107	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.397196+00	2025-11-22 04:41:41.397196+00
7983fc33-abc0-4fa7-8fd9-1223b096ddbc	emergency_contact	cc38cb13-51a5-4539-99c2-894cd2b207f1	6	5543795680	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.401585+00	2025-11-22 04:41:41.401585+00
406a3d33-4e7b-4f60-af2d-20fc8e4dd296	emergency_contact	6af409b5-c8b8-4664-97cd-d419eedcc932	6	32232724524	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.406143+00	2025-11-22 04:41:41.406143+00
646d74da-9d20-450e-9ac0-9eb06d189cc2	emergency_contact	227a2c03-dfd1-4e03-9c04-daaf74fc68bd	6	5590950933	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.411039+00	2025-11-22 04:41:41.411039+00
f5c1d381-d6e0-4da1-b708-a870a62ddf91	emergency_contact	bc6e7a77-d709-401c-bea7-82715eeb1a29	6	3375466198	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.415398+00	2025-11-22 04:41:41.415398+00
a9bc972f-10e2-4d80-b3e9-d5e6a0478317	emergency_contact	d54d7239-e49a-4185-8875-4f71af08b789	6	3350896048	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.418906+00	2025-11-22 04:41:41.418906+00
70af6157-d103-47d8-bb79-eefb3d2a4404	emergency_contact	8370857e-7e69-43a6-be63-78fc270c5fd5	6	5549000181	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.423623+00	2025-11-22 04:41:41.423623+00
d22dfd1f-62cc-4bfa-ac07-c46cefc0dfa0	emergency_contact	e8813bf8-7bbb-4370-a181-880c0c959aa1	6	8132914959	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.442951+00	2025-11-22 04:41:41.442951+00
40635dc4-d313-47b5-91e5-583df62bb03d	emergency_contact	4337bfc4-5ea7-4621-bd24-dbf3f55e350a	6	3398716364	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.449633+00	2025-11-22 04:41:41.449633+00
60f5df87-cdca-442e-b961-bab4b9017796	emergency_contact	517958b1-f860-4a42-965b-15a796055981	6	47739213896	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.455444+00	2025-11-22 04:41:41.455444+00
a6c3756d-ab17-42b8-88ce-86b95af40fdb	emergency_contact	44e4c099-cf6e-4926-85f1-ab5cb34c59a1	6	47785689511	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.459831+00	2025-11-22 04:41:41.459831+00
afa3a84e-4964-4aaa-8e7b-a45dc4632332	emergency_contact	a0c3c815-c664-4931-927f-e4109a545603	6	3331572816	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.463599+00	2025-11-22 04:41:41.463599+00
eeba4c7a-f36f-491b-9193-830ffadc1c30	emergency_contact	5c1862f6-f802-41ae-a6fb-87dbc5555fb3	6	3382923190	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.483152+00	2025-11-22 04:41:41.483152+00
058f9259-542f-4fa1-86a5-d7fa792d415b	emergency_contact	11d31cb4-1dfb-479e-9329-8b8b35920b98	6	32260509677	+52	\N	f	f	\N	\N	2025-11-22 04:41:41.489464+00	2025-11-22 04:41:41.489464+00
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.regions (id, country_id, name, region_code, region_type, is_active, created_at) FROM stdin;
1	1	Aguascalientes	AGS	state	t	2025-11-22 04:17:09.933489+00
2	1	Baja California	BC	state	t	2025-11-22 04:17:09.933489+00
3	1	Baja California Sur	BCS	state	t	2025-11-22 04:17:09.933489+00
4	1	Campeche	CAMP	state	t	2025-11-22 04:17:09.933489+00
5	1	Chiapas	CHIS	state	t	2025-11-22 04:17:09.933489+00
6	1	Chihuahua	CHIH	state	t	2025-11-22 04:17:09.933489+00
7	1	Coahuila	COAH	state	t	2025-11-22 04:17:09.933489+00
8	1	Colima	COL	state	t	2025-11-22 04:17:09.933489+00
9	1	Ciudad de México	CDMX	state	t	2025-11-22 04:17:09.933489+00
10	1	Durango	DGO	state	t	2025-11-22 04:17:09.933489+00
11	1	Guanajuato	GTO	state	t	2025-11-22 04:17:09.933489+00
12	1	Guerrero	GRO	state	t	2025-11-22 04:17:09.933489+00
13	1	Hidalgo	HGO	state	t	2025-11-22 04:17:09.933489+00
14	1	Jalisco	JAL	state	t	2025-11-22 04:17:09.933489+00
15	1	México	MEX	state	t	2025-11-22 04:17:09.933489+00
16	1	Michoacán	MICH	state	t	2025-11-22 04:17:09.933489+00
17	1	Morelos	MOR	state	t	2025-11-22 04:17:09.933489+00
18	1	Nayarit	NAY	state	t	2025-11-22 04:17:09.933489+00
19	1	Nuevo León	NL	state	t	2025-11-22 04:17:09.933489+00
20	1	Oaxaca	OAX	state	t	2025-11-22 04:17:09.933489+00
21	1	Puebla	PUE	state	t	2025-11-22 04:17:09.933489+00
22	1	Querétaro	QRO	state	t	2025-11-22 04:17:09.933489+00
23	1	Quintana Roo	QROO	state	t	2025-11-22 04:17:09.933489+00
24	1	San Luis Potosí	SLP	state	t	2025-11-22 04:17:09.933489+00
25	1	Sinaloa	SIN	state	t	2025-11-22 04:17:09.933489+00
26	1	Sonora	SON	state	t	2025-11-22 04:17:09.933489+00
27	1	Tabasco	TAB	state	t	2025-11-22 04:17:09.933489+00
28	1	Tamaulipas	TAMPS	state	t	2025-11-22 04:17:09.933489+00
29	1	Tlaxcala	TLAX	state	t	2025-11-22 04:17:09.933489+00
30	1	Veracruz	VER	state	t	2025-11-22 04:17:09.933489+00
31	1	Yucatán	YUC	state	t	2025-11-22 04:17:09.933489+00
32	1	Zacatecas	ZAC	state	t	2025-11-22 04:17:09.933489+00
\.


--
-- Data for Name: sexes; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.sexes (id, name, display_name, description, chromosome_pattern, is_active, created_at) FROM stdin;
1	male	Male	Biological male sex	XY	t	2025-11-22 04:17:09.880261+00
2	female	Female	Biological female sex	XX	t	2025-11-22 04:17:09.880261+00
3	intersex	Intersex	Intersex condition (variations in sex characteristics)	Various	t	2025-11-22 04:17:09.880261+00
\.


--
-- Data for Name: specialty_categories; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.specialty_categories (id, name, description, parent_category_id, is_active, created_at) FROM stdin;
1	Primary Care	General medical practice and primary healthcare	\N	t	2025-11-22 04:17:09.872819+00
2	Specialty	Medical specialties requiring advanced training	\N	t	2025-11-22 04:17:09.872819+00
3	Preventive	Disease prevention and health promotion	\N	t	2025-11-22 04:17:09.872819+00
4	Emergency	Emergency medicine and critical care	\N	t	2025-11-22 04:17:09.872819+00
5	Surgery	Surgical specialties and procedures	\N	t	2025-11-22 04:17:09.872819+00
6	Internal Medicine	Internal medicine subspecialties	\N	t	2025-11-22 04:17:09.872819+00
7	Pediatrics	Medical care for children and adolescents	\N	t	2025-11-22 04:17:09.872819+00
8	Obstetrics and Gynecology	Women's health and reproductive medicine	\N	t	2025-11-22 04:17:09.872819+00
9	Psychiatry	Mental health and behavioral medicine	\N	t	2025-11-22 04:17:09.872819+00
10	Radiology	Medical imaging and diagnostic radiology	\N	t	2025-11-22 04:17:09.872819+00
\.


--
-- Data for Name: system_settings; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.system_settings (id, setting_key, setting_value, setting_type, category, description, is_system, created_at, updated_at) FROM stdin;
1	cms_title	PredictHealth CMS	string	general	Título del sistema CMS	f	2025-11-22 04:17:10.430092+00	2025-11-22 04:17:10.430092+00
2	timezone	America/Mexico_City	string	general	Zona horaria del sistema	f	2025-11-22 04:17:10.430092+00	2025-11-22 04:17:10.430092+00
3	maintenance_mode	false	boolean	general	Modo mantenimiento activado	f	2025-11-22 04:17:10.430092+00	2025-11-22 04:17:10.430092+00
4	language	es	string	general	Idioma del sistema	f	2025-11-22 04:17:10.430092+00	2025-11-22 04:17:10.430092+00
5	db_backup_frequency	daily	string	database	Frecuencia de backups automáticos	f	2025-11-22 04:17:10.430092+00	2025-11-22 04:17:10.430092+00
6	service_timeout	30	number	microservices	Timeout en segundos para servicios	f	2025-11-22 04:17:10.430092+00	2025-11-22 04:17:10.430092+00
7	health_check_interval	60	number	microservices	Intervalo de health checks en segundos	f	2025-11-22 04:17:10.430092+00	2025-11-22 04:17:10.430092+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: predictHealth_user
--

COPY public.users (id, email, password_hash, user_type, reference_id, is_active, is_verified, failed_login_attempts, last_failed_login, password_changed_at, created_at, updated_at) FROM stdin;
11000000-e29b-41d4-a716-446655440001	institucion1@test.predicthealth.com	$2b$12$Fu7pgzMQbaYBsEfHq8b76O1UPDtB0Ngm5Z3qRSkXPv9YyIP.1YaBe	institution	11000000-e29b-41d4-a716-446655440001	t	t	0	\N	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00
12000000-e29b-41d4-a716-446655440002	institucion2@test.predicthealth.com	$2b$12$20krURHfwrBIJQCqdh2j1.4pxMumbNR7MtmAiKbflQXW1ofdpgocq	institution	12000000-e29b-41d4-a716-446655440002	t	t	0	\N	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00
13000000-e29b-41d4-a716-446655440003	institucion3@test.predicthealth.com	$2b$12$KEJp5csEJmfVt.mxxEudv.ho6WyDB7M3Ehjr61aOP7ZIKpyhT57L2	institution	13000000-e29b-41d4-a716-446655440003	t	t	0	\N	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00
14000000-e29b-41d4-a716-446655440004	institucion4@test.predicthealth.com	$2b$12$s8Y2qs7A1zeC6P/ekXQHLe56fB8nmJJlox5cmolEkAOsOapbJ8gDq	institution	14000000-e29b-41d4-a716-446655440004	t	t	0	\N	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00
15000000-e29b-41d4-a716-446655440005	institucion5@test.predicthealth.com	$2b$12$0j7S7rP06XrUEZSUtPERFOam9Ri.i1KUzfxDpozOUbjGnw0QLuiMC	institution	15000000-e29b-41d4-a716-446655440005	t	t	0	\N	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00	2025-11-22 04:17:10.10686+00
21000000-e29b-41d4-a716-446655440001	doctor1@test.predicthealth.com	$2b$12$E/UgR4RVVaYQ3.D5fc/ji.bfI8s7pWetGECQgd8eUBD5.2Rn0Lm9.	doctor	21000000-e29b-41d4-a716-446655440001	t	t	0	\N	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00
22000000-e29b-41d4-a716-446655440002	doctor2@test.predicthealth.com	$2b$12$NIJzDyaAHli7WvojQRX.Gen4B0.ybiolEM3GtB0USJSg7X6m1I2VG	doctor	22000000-e29b-41d4-a716-446655440002	t	t	0	\N	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00
23000000-e29b-41d4-a716-446655440003	doctor3@test.predicthealth.com	$2b$12$dg7XyARsx4DXXsbQAGetRutkps.4hu1KCx2te0bfNUo1xfN7Hf32S	doctor	23000000-e29b-41d4-a716-446655440003	t	t	0	\N	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00
24000000-e29b-41d4-a716-446655440004	doctor4@test.predicthealth.com	$2b$12$y6xvrHddz/byYF2ol6qxIuekSpmoXBUCrhJhGimy4ZTJcXNZYmHii	doctor	24000000-e29b-41d4-a716-446655440004	t	t	0	\N	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00
25000000-e29b-41d4-a716-446655440005	doctor5@test.predicthealth.com	$2b$12$IMU.mwTpKs50vlCXG.jmBukOAVet.oqM0sBt1FhwhwB5UrxslzcJS	doctor	25000000-e29b-41d4-a716-446655440005	t	t	0	\N	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00	2025-11-22 04:17:10.164624+00
31000000-e29b-41d4-a716-446655440001	paciente1@test.predicthealth.com	$2b$12$gEqkD8pJHfq6EIEiDTPnUeSUFB2dQw3ozCGRUnFg6iAeCkNb46ISq	patient	31000000-e29b-41d4-a716-446655440001	t	t	0	\N	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00
32000000-e29b-41d4-a716-446655440002	paciente2@test.predicthealth.com	$2b$12$TkYMOsVgEGsgL6ksA/NN4O.K79BXEJyvTbjxY9G83Z8cmgw3Mzx4W	patient	32000000-e29b-41d4-a716-446655440002	t	t	0	\N	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00
33000000-e29b-41d4-a716-446655440003	paciente3@test.predicthealth.com	$2b$12$9Kd6I3Pi4KtQTuAmZV6HFeIaus71Z/Slx9ZVULD5rjkIcW06Jrsj.	patient	33000000-e29b-41d4-a716-446655440003	t	t	0	\N	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00
34000000-e29b-41d4-a716-446655440004	paciente4@test.predicthealth.com	$2b$12$JcMVzDqEJcbMwNRc2gtjwuBsG3NPAD.osQbLt/h3zz0ix6usr3TZC	patient	34000000-e29b-41d4-a716-446655440004	t	t	0	\N	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00
35000000-e29b-41d4-a716-446655440005	paciente5@test.predicthealth.com	$2b$12$sCaqkRhmkJsrDaX/4OvGmuyfcwUkGw4zu5iBSgE1HIO6MI/gD9jXq	patient	35000000-e29b-41d4-a716-446655440005	t	t	0	\N	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00	2025-11-22 04:17:10.246974+00
163749fb-8b46-4447-a8b7-95b4a59531b6	contacto@despacho-grijalva-mascarenas-y-parra.predicthealth.com	$2b$12$6mcDfCFslgqWcx9JxVFKTe7nBDEigUKq5DvD3z7evmbItIoxei89m	institution	163749fb-8b46-4447-a8b7-95b4a59531b6	t	t	0	\N	2025-11-22 04:41:42.634362+00	2025-11-22 04:41:42.634362+00	2025-11-22 04:41:42.634362+00
83b74179-f6ef-4219-bc70-c93f4393a350	contacto@laboratorios-saldivar-santillan-y-villanueva.predicthealth.com	$2b$12$/OvX02jPhyWufld7TETGyeqrj0Dk92KJDDk2LNXxiDP/RLe1z26SC	institution	83b74179-f6ef-4219-bc70-c93f4393a350	t	t	0	\N	2025-11-22 04:41:42.645692+00	2025-11-22 04:41:42.645692+00	2025-11-22 04:41:42.645692+00
50503414-ca6d-4c1a-a34f-18719e2fd555	contacto@trejo-vigil-e-hijos.predicthealth.com	$2b$12$HANFBGrnTprhf1lxn41rAelpi/3Hy9f7DjTdXEz0knpKW0Uu4pBD.	institution	50503414-ca6d-4c1a-a34f-18719e2fd555	t	t	0	\N	2025-11-22 04:41:42.655691+00	2025-11-22 04:41:42.655691+00	2025-11-22 04:41:42.655691+00
9b581d3c-9e93-4f39-80bb-294752065866	contacto@club-barajas-del-valle-y-carrero.predicthealth.com	$2b$12$A5B25nEei7cQmwOZ/65dkO6Y25A5fElFp9lb64qxDKet6Q8PpYvKq	institution	9b581d3c-9e93-4f39-80bb-294752065866	t	t	0	\N	2025-11-22 04:41:42.661918+00	2025-11-22 04:41:42.661918+00	2025-11-22 04:41:42.661918+00
e0e34926-8d48-4db0-afb9-b20b6eeb1ecb	contacto@collazo-barrientos.predicthealth.com	$2b$12$otbGYyRXEryXBSmbFQRDMuqZM/xpYL8.8D.F9UTJ/KqZEcyPM4MM2	institution	e0e34926-8d48-4db0-afb9-b20b6eeb1ecb	t	t	0	\N	2025-11-22 04:41:42.667194+00	2025-11-22 04:41:42.667194+00	2025-11-22 04:41:42.667194+00
81941e1d-820a-4313-8177-e44278d9a981	contacto@corporacin-prado-davila-y-noriega.predicthealth.com	$2b$12$pVAI.KIxeoBjSIWhtEeHBe2BrHVSAWpTupC.oQ8efMRjdL8xbtmii	institution	81941e1d-820a-4313-8177-e44278d9a981	t	t	0	\N	2025-11-22 04:41:42.672711+00	2025-11-22 04:41:42.672711+00	2025-11-22 04:41:42.672711+00
a725b15f-039b-4256-843a-51a2968633fd	contacto@corporacin-navarro-collado.predicthealth.com	$2b$12$jY3Ados/UkPxZiXfyLHMkuaIOuQ8Mcq/qbGETkCRJoD5H58l1ztsC	institution	a725b15f-039b-4256-843a-51a2968633fd	t	t	0	\N	2025-11-22 04:41:42.678325+00	2025-11-22 04:41:42.678325+00	2025-11-22 04:41:42.678325+00
0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d	contacto@iglesias-soria-y-chacon.predicthealth.com	$2b$12$Sd5g895OtKX5iNldjqy/FeFGwwdFiM4VfJUl.Ep7PxxpPDOiiWisa	institution	0a57bfd9-d74d-4941-8b69-9ba44b3a8c6d	t	t	0	\N	2025-11-22 04:41:42.682869+00	2025-11-22 04:41:42.682869+00	2025-11-22 04:41:42.682869+00
d471d2d1-66a1-4de0-8754-127059786888	contacto@castillo-zayas.predicthealth.com	$2b$12$R9dzpcXKnljTMzGnTeWfjOo7fQASccPw5.9IAW5K62lNZUAVP3iEC	institution	d471d2d1-66a1-4de0-8754-127059786888	t	t	0	\N	2025-11-22 04:41:42.687529+00	2025-11-22 04:41:42.687529+00	2025-11-22 04:41:42.687529+00
8fd698b3-084d-4248-a28e-2708a5862e27	contacto@club-mesa-y-riojas.predicthealth.com	$2b$12$HgSfquVtP4osxCx0wX4O.OVKuF3bn9wt611bG4bN3R6HxEkM2jgfq	institution	8fd698b3-084d-4248-a28e-2708a5862e27	t	t	0	\N	2025-11-22 04:41:42.693372+00	2025-11-22 04:41:42.693372+00	2025-11-22 04:41:42.693372+00
7b96a7bb-041f-4331-be05-e97cab7dafc0	contacto@ojeda-y-baca-s-r-l-de-c-v.predicthealth.com	$2b$12$j5TQgGbTGeGAYDjyweQSiu6lCNSjprFxN8Z6prQUaqTPxsMKXkB8a	institution	7b96a7bb-041f-4331-be05-e97cab7dafc0	t	t	0	\N	2025-11-22 04:41:42.697294+00	2025-11-22 04:41:42.697294+00	2025-11-22 04:41:42.697294+00
5da54d5d-de0c-4277-a43e-6a89f987e77c	contacto@murillo-y-quintanilla-s-a.predicthealth.com	$2b$12$xG7lL.IR9q3YiP/wG1dNWevqU99hmYsCkNmHQ5xXqPgy2dYxxmUTS	institution	5da54d5d-de0c-4277-a43e-6a89f987e77c	t	t	0	\N	2025-11-22 04:41:42.702676+00	2025-11-22 04:41:42.702676+00	2025-11-22 04:41:42.702676+00
c9014e88-309c-4cb0-a28d-25b510e1e522	contacto@grupo-collazo-hinojosa-y-valdes.predicthealth.com	$2b$12$6QzkpmT9GDmATIcL6MOn6e/v.JDogu3E0B7vXt99t0FJxtwESq0g.	institution	c9014e88-309c-4cb0-a28d-25b510e1e522	t	t	0	\N	2025-11-22 04:41:42.711316+00	2025-11-22 04:41:42.711316+00	2025-11-22 04:41:42.711316+00
8e889f63-2c86-44ab-959f-fdc365353d5d	contacto@club-verdugo-y-tejeda.predicthealth.com	$2b$12$T344MdR9OH8blY.9KOGmkOXGalkk61oYTzoPOnwR0ztSVcXW8MbGm	institution	8e889f63-2c86-44ab-959f-fdc365353d5d	t	t	0	\N	2025-11-22 04:41:42.715908+00	2025-11-22 04:41:42.715908+00	2025-11-22 04:41:42.715908+00
67787f7c-fdee-4e30-80bd-89008ebfe419	contacto@zaragoza-e-hijos.predicthealth.com	$2b$12$Jh9hyW5I/PeRgdIXj53B/uMZAEf6waz1W8uELhbcz7JGZvEwxEUy2	institution	67787f7c-fdee-4e30-80bd-89008ebfe419	t	t	0	\N	2025-11-22 04:41:42.720079+00	2025-11-22 04:41:42.720079+00	2025-11-22 04:41:42.720079+00
4721cb90-8fb0-4fd6-b19e-160b4ac0c744	contacto@ceballos-tello.predicthealth.com	$2b$12$0c0LnQ2TCDMZlCdUYgHROub3Caf1SH7dZaXNEayQujvrsDHU8GRuK	institution	4721cb90-8fb0-4fd6-b19e-160b4ac0c744	t	t	0	\N	2025-11-22 04:41:42.72446+00	2025-11-22 04:41:42.72446+00	2025-11-22 04:41:42.72446+00
09c54a60-6267-4439-9c8b-8c9012842942	contacto@banuelos-e-hijos.predicthealth.com	$2b$12$3U/ueQi4kJHRvSMj51PFRecRutD7PJPRHDhLpnxBZzpfCdeO.1Q06	institution	09c54a60-6267-4439-9c8b-8c9012842942	t	t	0	\N	2025-11-22 04:41:42.729321+00	2025-11-22 04:41:42.729321+00	2025-11-22 04:41:42.729321+00
a670c73c-cc47-42fe-88c9-0fa37359779b	contacto@despacho-jaramillo-salas-y-carrero.predicthealth.com	$2b$12$L8vOelgJq6WnesPgXbikpegPyjHI.ituvvTdyQYNjLioRn/WWuaYO	institution	a670c73c-cc47-42fe-88c9-0fa37359779b	t	t	0	\N	2025-11-22 04:41:42.735261+00	2025-11-22 04:41:42.735261+00	2025-11-22 04:41:42.735261+00
373769ab-b720-4269-bfb9-02546401ce99	contacto@paez-navarro-s-a.predicthealth.com	$2b$12$O9NeBADQVtProgUwqam/2u8qxtdAugEdHFK6ActD7FuQA.RJdqxHi	institution	373769ab-b720-4269-bfb9-02546401ce99	t	t	0	\N	2025-11-22 04:41:42.740457+00	2025-11-22 04:41:42.740457+00	2025-11-22 04:41:42.740457+00
ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	contacto@proyectos-mata-y-jurado.predicthealth.com	$2b$12$EVcvTjl7Z75vI6d3FZ08h.6km/9lt53.mwKQlyQnkd.bwQU0Ef32C	institution	ec040a7f-96b2-4a7d-85ed-3741fcdcfc75	t	t	0	\N	2025-11-22 04:41:42.745939+00	2025-11-22 04:41:42.745939+00	2025-11-22 04:41:42.745939+00
2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	contacto@laboratorios-trejo-garcia-y-lucero.predicthealth.com	$2b$12$lIqfMqSc1dGBi8wITU2Dwez57iPiy54T9/3vC/c21NdNOUD.XRQBW	institution	2b50dc12-10eb-449e-af9e-f8a1ccf4b0f0	t	t	0	\N	2025-11-22 04:41:42.751586+00	2025-11-22 04:41:42.751586+00	2025-11-22 04:41:42.751586+00
6c287a0e-9d4c-4574-932f-7d499aa4146c	contacto@industrias-valverde-y-leal.predicthealth.com	$2b$12$Tj0oVLRzrb8etGD3wT6p.OQ4srgkW3wfTsAYxsW15ENAygqezBjY.	institution	6c287a0e-9d4c-4574-932f-7d499aa4146c	t	t	0	\N	2025-11-22 04:41:42.756634+00	2025-11-22 04:41:42.756634+00	2025-11-22 04:41:42.756634+00
a14c189c-ee90-4c29-b465-63d43a9d0010	contacto@castillo-lugo-y-zamora.predicthealth.com	$2b$12$RkSCSQQ.JY/gq/A7iuRiJuEEW2bNNF/TdRoA57n/P0HCVmICc2xvK	institution	a14c189c-ee90-4c29-b465-63d43a9d0010	t	t	0	\N	2025-11-22 04:41:42.761336+00	2025-11-22 04:41:42.761336+00	2025-11-22 04:41:42.761336+00
e040eabc-0ac9-47f7-89ae-24246e1c12dd	contacto@montenegro-alcala-y-nieves.predicthealth.com	$2b$12$CSKms9mN57imAp197ZpkvePnnA2qdEGDc0yW5AmOkWHaQDB367TE6	institution	e040eabc-0ac9-47f7-89ae-24246e1c12dd	t	t	0	\N	2025-11-22 04:41:42.765795+00	2025-11-22 04:41:42.765795+00	2025-11-22 04:41:42.765795+00
9c8636c9-015b-4c18-a641-f5da698b6fd8	contacto@montenegro-y-pichardo-s-a-de-c-v.predicthealth.com	$2b$12$L9pKxKuHn2SqF5mgG2ivw.vgL5DqzJADo9NGw5Mp3UOCx81gXmRxe	institution	9c8636c9-015b-4c18-a641-f5da698b6fd8	t	t	0	\N	2025-11-22 04:41:42.770968+00	2025-11-22 04:41:42.770968+00	2025-11-22 04:41:42.770968+00
b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	contacto@lucio-marrero-y-asociados.predicthealth.com	$2b$12$mCqdeoTBi5zK3cGlvz068.bL4UBImTfdP3u/Z.ryzOzceGI2zkpfO	institution	b1de7736-6acf-4f4b-b09b-8a3d4f55b1aa	t	t	0	\N	2025-11-22 04:41:42.776399+00	2025-11-22 04:41:42.776399+00	2025-11-22 04:41:42.776399+00
146a692b-6d46-4c26-a165-092fe771400e	contacto@proyectos-iglesias-verdugo.predicthealth.com	$2b$12$e2c5Eyq7k88O4JALHgIm/OmDj5gsGbnP5NAHOd43lfMnWAPtveR3K	institution	146a692b-6d46-4c26-a165-092fe771400e	t	t	0	\N	2025-11-22 04:41:42.781669+00	2025-11-22 04:41:42.781669+00	2025-11-22 04:41:42.781669+00
6297ae0f-7fee-472d-87ec-e22b87ce6ffb	contacto@duenas-esquivel-s-r-l-de-c-v.predicthealth.com	$2b$12$CsOa0XfrYq2mRMv5AHj4huJrZH66XWOjuKybZsS2LUTtdWk/7X7wi	institution	6297ae0f-7fee-472d-87ec-e22b87ce6ffb	t	t	0	\N	2025-11-22 04:41:42.787289+00	2025-11-22 04:41:42.787289+00	2025-11-22 04:41:42.787289+00
66e6aa6c-596c-442e-85fb-b143875d0dfc	contacto@valencia-toro.predicthealth.com	$2b$12$mBor..0nmb/LhNA75cfOHe6qmM8GQ.Hh/IZRpdjpa6dbgnITMHnZ2	institution	66e6aa6c-596c-442e-85fb-b143875d0dfc	t	t	0	\N	2025-11-22 04:41:42.791022+00	2025-11-22 04:41:42.791022+00	2025-11-22 04:41:42.791022+00
46af545e-6db8-44ba-a7f9-9fd9617f4a09	contacto@solano-rodrigez.predicthealth.com	$2b$12$hSJ9z5CpUEpCjZq8bOol5.kpkkgWm256eQlVYz1G9fZ2.TXFFztkG	institution	46af545e-6db8-44ba-a7f9-9fd9617f4a09	t	t	0	\N	2025-11-22 04:41:42.796574+00	2025-11-22 04:41:42.796574+00	2025-11-22 04:41:42.796574+00
a56b6787-94e9-49f0-8b3a-6ff5979773fc	contacto@laboratorios-vasquez-zepeda.predicthealth.com	$2b$12$024vBYq6TWxLqWZDR5oZpOOk9gYAALLycGXWkMvMHR2Xut2G5APjm	institution	a56b6787-94e9-49f0-8b3a-6ff5979773fc	t	t	0	\N	2025-11-22 04:41:42.80131+00	2025-11-22 04:41:42.80131+00	2025-11-22 04:41:42.80131+00
d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	contacto@club-montanez-almaraz.predicthealth.com	$2b$12$vXTWKTao7BuFQ23z2IOb9ON/I/UTESEnUx0oSiAg7RZiR.PVdoRd.	institution	d4aa9e53-8b33-45f1-a9a8-ac7141ede7bf	t	t	0	\N	2025-11-22 04:41:42.806333+00	2025-11-22 04:41:42.806333+00	2025-11-22 04:41:42.806333+00
4bfa1a0a-0434-45e0-b454-03140b992f53	contacto@proyectos-alvarez-godinez-y-estevez.predicthealth.com	$2b$12$FpV3vHIsZhIu6vOXZeVMAOl5gLL.OrTr0l900fgvqU.noRziFaLk.	institution	4bfa1a0a-0434-45e0-b454-03140b992f53	t	t	0	\N	2025-11-22 04:41:42.809713+00	2025-11-22 04:41:42.809713+00	2025-11-22 04:41:42.809713+00
33ba98b9-c46a-47c1-b266-d8a4fe557290	contacto@grupo-carvajal-murillo-y-regalado.predicthealth.com	$2b$12$rbXmQ.jDjQseWbgnt2lHkuEVQDBiGwOh10mKxi9XEwR9vdfwvOJ9G	institution	33ba98b9-c46a-47c1-b266-d8a4fe557290	t	t	0	\N	2025-11-22 04:41:42.814527+00	2025-11-22 04:41:42.814527+00	2025-11-22 04:41:42.814527+00
f4764cd3-47e9-4408-b0ee-9b9001c5459d	contacto@industrias-bahena-nieto-y-acosta.predicthealth.com	$2b$12$LLMJh0qoomU2WwTbHCZNw.im2k0waScETps/RGBKyK/gOoG1oc2L.	institution	f4764cd3-47e9-4408-b0ee-9b9001c5459d	t	t	0	\N	2025-11-22 04:41:42.821114+00	2025-11-22 04:41:42.821114+00	2025-11-22 04:41:42.821114+00
f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8	contacto@villagomez-s-a.predicthealth.com	$2b$12$VuQUfpZgxDw22yaSFclT1eY08yKVWdEhovJ2FRrGDBM5X4PHPubVG	institution	f3cc8c7a-c1f7-4b73-86fa-b32284ff97b8	t	t	0	\N	2025-11-22 04:41:42.825276+00	2025-11-22 04:41:42.825276+00	2025-11-22 04:41:42.825276+00
219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	contacto@lucero-fajardo-e-hijos.predicthealth.com	$2b$12$7I2FpqRUkoP5YcnoySr/MuBJC5irFxdmilZyT0W35h5UwVVWuBmPK	institution	219eef1d-cc5e-47f4-b6fb-0b6cafbdc85d	t	t	0	\N	2025-11-22 04:41:42.830464+00	2025-11-22 04:41:42.830464+00	2025-11-22 04:41:42.830464+00
8be78aaa-c408-452e-bf01-8e831ab5c63a	contacto@laboratorios-arellano-rosas.predicthealth.com	$2b$12$ggJ4z69CEhd3BewrSz4DnONpVvf/RW7b7lVq1FJx8Bq6rXfE5pWBu	institution	8be78aaa-c408-452e-bf01-8e831ab5c63a	t	t	0	\N	2025-11-22 04:41:42.835559+00	2025-11-22 04:41:42.835559+00	2025-11-22 04:41:42.835559+00
8fb0899c-732e-4f03-8209-d52ef41a6a76	contacto@alba-casas.predicthealth.com	$2b$12$Ld0ifpWpKoOUpQ69ZQWuruvRvLnt816pd9YHsrUGkgZlUzLq70HAC	institution	8fb0899c-732e-4f03-8209-d52ef41a6a76	t	t	0	\N	2025-11-22 04:41:42.841246+00	2025-11-22 04:41:42.841246+00	2025-11-22 04:41:42.841246+00
3a9084e7-74c5-4e0b-b786-2c93d9cd39ee	contacto@club-zambrano-arredondo-y-guerra.predicthealth.com	$2b$12$ZV.WzE3exIViB23pbjg5COeQzm7T.ZEWoJlIl.cXC1z/3fGZ0g1GS	institution	3a9084e7-74c5-4e0b-b786-2c93d9cd39ee	t	t	0	\N	2025-11-22 04:41:42.846887+00	2025-11-22 04:41:42.846887+00	2025-11-22 04:41:42.846887+00
54481b92-e5f5-421b-ba21-89bf520a2d87	contacto@club-ballesteros-cornejo.predicthealth.com	$2b$12$k8qcve3Peyf6.8.BZ20yFe6q5f8dKF4jupZxKJRQ9aMAO.9Hd3/Iu	institution	54481b92-e5f5-421b-ba21-89bf520a2d87	t	t	0	\N	2025-11-22 04:41:42.852959+00	2025-11-22 04:41:42.852959+00	2025-11-22 04:41:42.852959+00
68f1a02a-d348-4d1e-99ee-733d832a3f43	contacto@espinoza-y-villegas-a-c.predicthealth.com	$2b$12$o7Tj/hmj1H25htGUBP4qLOLiTGWQs5nhQmg4gpzSXhnmzufU5ld.a	institution	68f1a02a-d348-4d1e-99ee-733d832a3f43	t	t	0	\N	2025-11-22 04:41:42.857853+00	2025-11-22 04:41:42.857853+00	2025-11-22 04:41:42.857853+00
36983990-abe8-4f1c-9c1b-863b9cab3ca9	contacto@alfaro-pacheco-y-villalpando.predicthealth.com	$2b$12$m9KbyMuiYr9AkBQnTIAMJueTqWF9G4zPHxJ4t38cE3137v7z7gp32	institution	36983990-abe8-4f1c-9c1b-863b9cab3ca9	t	t	0	\N	2025-11-22 04:41:42.86162+00	2025-11-22 04:41:42.86162+00	2025-11-22 04:41:42.86162+00
b654860f-ec74-42d6-955e-eeedde2df0dd	contacto@grupo-ibarra-y-elizondo.predicthealth.com	$2b$12$xH32ZUtBLnn9ZTtnXKUGRuEJF/egRzQiDSNDV51HVr8hu8gH/7N5.	institution	b654860f-ec74-42d6-955e-eeedde2df0dd	t	t	0	\N	2025-11-22 04:41:42.867217+00	2025-11-22 04:41:42.867217+00	2025-11-22 04:41:42.867217+00
be133600-848e-400b-9bc8-c52a4f3cf10d	contacto@avila-y-maestas-s-a.predicthealth.com	$2b$12$xTLUvglaRD8xuRryufeE1uHeFse.NmMXv2XlLJfhgyvyUKyvj/E7.	institution	be133600-848e-400b-9bc8-c52a4f3cf10d	t	t	0	\N	2025-11-22 04:41:42.871269+00	2025-11-22 04:41:42.871269+00	2025-11-22 04:41:42.871269+00
25e918f3-692f-4f51-b630-4caa1dd825a1	contacto@gastelum-y-guerrero-y-asociados.predicthealth.com	$2b$12$CW/6kQ/JcxnoKKmqPLn7HuGWwQTnuqakyxbpLJfFIYFWqOYOeZWV2	institution	25e918f3-692f-4f51-b630-4caa1dd825a1	t	t	0	\N	2025-11-22 04:41:42.876923+00	2025-11-22 04:41:42.876923+00	2025-11-22 04:41:42.876923+00
cc46221e-f387-463c-9d11-9464d8209f7b	contacto@escobedo-y-guerrero-a-c.predicthealth.com	$2b$12$gQFvnwgNsHUTnBzgKsCJc.6Tbdl9lsWg4G27XXlWgT68HqrpRIr/O	institution	cc46221e-f387-463c-9d11-9464d8209f7b	t	t	0	\N	2025-11-22 04:41:42.884711+00	2025-11-22 04:41:42.884711+00	2025-11-22 04:41:42.884711+00
a15d4a4b-1bc4-4ee5-a168-714f71d94e42	contacto@laboratorios-cavazos-y-valentin.predicthealth.com	$2b$12$ocWU88sHM8eAQ2l7vpvC4ewBJF0YvC26PZ92.1hXvNn8n/rn2dYiy	institution	a15d4a4b-1bc4-4ee5-a168-714f71d94e42	t	t	0	\N	2025-11-22 04:41:42.890142+00	2025-11-22 04:41:42.890142+00	2025-11-22 04:41:42.890142+00
3d7c5771-0692-4a2f-a4c6-6af2b561282b	contacto@leal-valdez-s-a-de-c-v.predicthealth.com	$2b$12$lylrzauU1I6dVfD6CQzI7uvhdsdSpqaWMx3Rb.kQk1nYGyg7PAcsG	institution	3d7c5771-0692-4a2f-a4c6-6af2b561282b	t	t	0	\N	2025-11-22 04:41:42.895605+00	2025-11-22 04:41:42.895605+00	2025-11-22 04:41:42.895605+00
16b25a77-b84a-44ac-8540-c5bfa9b3b6b0	contacto@carvajal-y-urias-a-c.predicthealth.com	$2b$12$rLzNX5hBLI5TNppTsST2T.X3LFBZEOMIo/K/d/lhn/m9JQs4V3Crm	institution	16b25a77-b84a-44ac-8540-c5bfa9b3b6b0	t	t	0	\N	2025-11-22 04:41:42.900335+00	2025-11-22 04:41:42.900335+00	2025-11-22 04:41:42.900335+00
2040ac28-7210-4fbd-9716-53872211bcd9	contacto@alonso-s-a.predicthealth.com	$2b$12$5CImdx4LGNWFe6.3bud3qOL/tBBpTJbX875Ha4Vt32F1Z0ksrYSVG	institution	2040ac28-7210-4fbd-9716-53872211bcd9	t	t	0	\N	2025-11-22 04:41:42.904125+00	2025-11-22 04:41:42.904125+00	2025-11-22 04:41:42.904125+00
0d826581-b9d8-4828-8848-9332fe38d169	contacto@arteaga-malave.predicthealth.com	$2b$12$IQIwGc5x6uvwz.z5elh15.VIIosqtyFJi0qfvaOINfnuX9JxDaDWe	institution	0d826581-b9d8-4828-8848-9332fe38d169	t	t	0	\N	2025-11-22 04:41:42.908692+00	2025-11-22 04:41:42.908692+00	2025-11-22 04:41:42.908692+00
c0595f94-c8f4-413c-a05c-7cfca773563c	contacto@briones-y-esquibel-s-c.predicthealth.com	$2b$12$Zk.OCVFFri7W6vFPYeqXJ.e/.Xa8CzNSiK4nFCqkeG9kiKigvB6fm	institution	c0595f94-c8f4-413c-a05c-7cfca773563c	t	t	0	\N	2025-11-22 04:41:42.913779+00	2025-11-22 04:41:42.913779+00	2025-11-22 04:41:42.913779+00
a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5	contacto@mares-altamirano-y-gil.predicthealth.com	$2b$12$JFOLotCS2q4nUjdBFrSQHef/wKB/CT08UHwswI.lpp3l9bJnlfzvW	institution	a50b009a-2e47-4bf4-8cf1-d1a0caec9ab5	t	t	0	\N	2025-11-22 04:41:42.919447+00	2025-11-22 04:41:42.919447+00	2025-11-22 04:41:42.919447+00
ad2c792b-5015-4238-b221-fa28e8b061fc	contacto@corporacin-hurtado-martinez-y-bueno.predicthealth.com	$2b$12$DFpqEBd85lHcuw73zYmBzenaoxL4aXsBl0dBUrJrwb8/KXVzjMi.O	institution	ad2c792b-5015-4238-b221-fa28e8b061fc	t	t	0	\N	2025-11-22 04:41:42.924371+00	2025-11-22 04:41:42.924371+00	2025-11-22 04:41:42.924371+00
c3e96b10-f0ca-421e-b402-aba6d595cf27	contacto@leyva-y-saavedra-e-hijos.predicthealth.com	$2b$12$N0bS8Qfx4hyKcX9TqUuzpe0ukKNFQP.kxZfqDvnzYUgTr8nOAhbZG	institution	c3e96b10-f0ca-421e-b402-aba6d595cf27	t	t	0	\N	2025-11-22 04:41:42.928717+00	2025-11-22 04:41:42.928717+00	2025-11-22 04:41:42.928717+00
a5b1202a-9112-404b-b7de-ddf0f62711f8	contacto@corporacin-pacheco-hurtado-y-holguin.predicthealth.com	$2b$12$AjB3MwPSrI6Sj2g74dLt2ezTNPnWAbGRXy5QPB55FC1V83tHUe4TS	institution	a5b1202a-9112-404b-b7de-ddf0f62711f8	t	t	0	\N	2025-11-22 04:41:42.933832+00	2025-11-22 04:41:42.933832+00	2025-11-22 04:41:42.933832+00
ac6f8f54-21c8-475b-bea6-19e31643392d	contacto@despacho-guerrero-noriega-y-zavala.predicthealth.com	$2b$12$GgU2jMNfx1YlrhAxopa9luKirF1IMrDi0efVCmCh2Eb3l4Pq1a7a2	institution	ac6f8f54-21c8-475b-bea6-19e31643392d	t	t	0	\N	2025-11-22 04:41:42.937493+00	2025-11-22 04:41:42.937493+00	2025-11-22 04:41:42.937493+00
43dee983-676a-4e33-a6b0-f0a72f46d06c	contacto@montano-lira.predicthealth.com	$2b$12$V2sck7BqV7PDHQ7JnQMOJulSmOKQDc9eDxV8rcQPcGIt8s5cwzr22	institution	43dee983-676a-4e33-a6b0-f0a72f46d06c	t	t	0	\N	2025-11-22 04:41:42.942503+00	2025-11-22 04:41:42.942503+00	2025-11-22 04:41:42.942503+00
f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	contacto@pelayo-arenas.predicthealth.com	$2b$12$.H03tKgxxfOe.2AdbZq1Su/HlHlRS14iZzQGGg89anV1gt5MaIINy	institution	f7799f28-3ab7-4b36-8a3a-b23890a5f0ca	t	t	0	\N	2025-11-22 04:41:42.947959+00	2025-11-22 04:41:42.947959+00	2025-11-22 04:41:42.947959+00
08a7fe9e-c043-4fed-89e4-93a416a20089	contacto@gil-y-coronado-y-asociados.predicthealth.com	$2b$12$ZbK.FuwUcIu4rONxyZZE7uUxJmhvcQbE/xux/N/jwsHC.U715TTbu	institution	08a7fe9e-c043-4fed-89e4-93a416a20089	t	t	0	\N	2025-11-22 04:41:42.953617+00	2025-11-22 04:41:42.953617+00	2025-11-22 04:41:42.953617+00
89ab21cf-089e-4210-8e29-269dfbd38d71	contacto@crespo-pena-y-rosado.predicthealth.com	$2b$12$GaYhhQW82EIA78vALU9Ew.Q.6IWjyw8tFr8lTfqokli1g.Eou1Suq	institution	89ab21cf-089e-4210-8e29-269dfbd38d71	t	t	0	\N	2025-11-22 04:41:42.958413+00	2025-11-22 04:41:42.958413+00	2025-11-22 04:41:42.958413+00
d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f	contacto@jiminez-arroyo-y-ramon.predicthealth.com	$2b$12$87llZQoOmysnTq6qxJBnAutQ/Y2X2HlPo4ob3lgAswMIwannQ5iGu	institution	d56e3cb0-d9e2-48fc-9c16-c4a96b90c00f	t	t	0	\N	2025-11-22 04:41:42.963808+00	2025-11-22 04:41:42.963808+00	2025-11-22 04:41:42.963808+00
ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	contacto@de-leon-s-c.predicthealth.com	$2b$12$eIXCSK45GiFq54SnsLArduAFulwxqo7cYCTL7qmzPr0ZLOdow5mYi	institution	ec36c5a4-3c80-48c1-ae79-9571e0c0f0a0	t	t	0	\N	2025-11-22 04:41:42.968287+00	2025-11-22 04:41:42.968287+00	2025-11-22 04:41:42.968287+00
3cf42c93-4941-4d8d-8656-aafa9e987177	contacto@robles-loera-a-c.predicthealth.com	$2b$12$a5lZpJdzxezlAcHIBN3UpulJ9m9L.nfvCydNEy2WxCoGNe0zm21q2	institution	3cf42c93-4941-4d8d-8656-aafa9e987177	t	t	0	\N	2025-11-22 04:41:42.972432+00	2025-11-22 04:41:42.972432+00	2025-11-22 04:41:42.972432+00
1926fa2a-dab7-420e-861b-c2b6dfe0174e	contacto@industrias-ponce-y-soto.predicthealth.com	$2b$12$zkLayMc5mMuddaSGmE2tZelGeoh1Nm2.SeBAS1DBPuUVsJmBgf1mu	institution	1926fa2a-dab7-420e-861b-c2b6dfe0174e	t	t	0	\N	2025-11-22 04:41:42.977544+00	2025-11-22 04:41:42.977544+00	2025-11-22 04:41:42.977544+00
0b2f4464-5141-44a3-a26d-f8acc1fb955e	contacto@madera-s-a.predicthealth.com	$2b$12$JPHUKYSE9cAtT6N9pO11ie8/N307nJPmFGlRlMkA7vnKuLceSAi4e	institution	0b2f4464-5141-44a3-a26d-f8acc1fb955e	t	t	0	\N	2025-11-22 04:41:42.981752+00	2025-11-22 04:41:42.981752+00	2025-11-22 04:41:42.981752+00
1fec9665-52bc-49a7-b028-f0d78440463c	contacto@proyectos-tejada-ramon-y-caldera.predicthealth.com	$2b$12$fsG1nHtvJhE0Z6pnDeNxFeRF3DLWfOxbCPBvdceVrmnkNr.DsgW0C	institution	1fec9665-52bc-49a7-b028-f0d78440463c	t	t	0	\N	2025-11-22 04:41:42.985314+00	2025-11-22 04:41:42.985314+00	2025-11-22 04:41:42.985314+00
50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	contacto@estevez-carrera.predicthealth.com	$2b$12$6EbUSKO3ibfinkLvm1/O7eypEyXDgTu2FmO/qKqqFIfQM60NfgZU2	institution	50fb1d4e-3567-4e1c-92f5-bb547dfc6a2a	t	t	0	\N	2025-11-22 04:41:42.988639+00	2025-11-22 04:41:42.988639+00	2025-11-22 04:41:42.988639+00
8cfdeaad-c727-4a4d-b5d5-b69dd43c0854	contacto@laboratorios-puga-coronado-y-carmona.predicthealth.com	$2b$12$PfnmQtBHCcl1IxVMg1vPs.sERmE2xVn0y97hjnmhCIDErcs9lL43m	institution	8cfdeaad-c727-4a4d-b5d5-b69dd43c0854	t	t	0	\N	2025-11-22 04:41:42.991635+00	2025-11-22 04:41:42.991635+00	2025-11-22 04:41:42.991635+00
7a6ce151-14b5-4d12-b6bb-1fba18636353	contacto@menchaca-vela-s-r-l-de-c-v.predicthealth.com	$2b$12$PXC5AyC.EG5RSo9ktnEcKeDoEHGPeHgCwcYOdIdsqRg5qtWq0RKEq	institution	7a6ce151-14b5-4d12-b6bb-1fba18636353	t	t	0	\N	2025-11-22 04:41:42.996201+00	2025-11-22 04:41:42.996201+00	2025-11-22 04:41:42.996201+00
f1ab98f4-98de-420f-9c4b-c31eee92df21	contacto@carreon-y-soliz-s-c.predicthealth.com	$2b$12$TSnkouxiSNnF7Y8Fc0C0e.kDAG0wBIuRkvwuVNpfJumtJiU7jlPC2	institution	f1ab98f4-98de-420f-9c4b-c31eee92df21	t	t	0	\N	2025-11-22 04:41:43.000465+00	2025-11-22 04:41:43.000465+00	2025-11-22 04:41:43.000465+00
a074c3ea-f255-4cf2-ae3f-727f9186be3c	contacto@zarate-solano.predicthealth.com	$2b$12$CtiJJKAYctY9zSlhNT3lt..MBzCIfnYiCV3JZvHwde87NGajaubqK	institution	a074c3ea-f255-4cf2-ae3f-727f9186be3c	t	t	0	\N	2025-11-22 04:41:43.003165+00	2025-11-22 04:41:43.003165+00	2025-11-22 04:41:43.003165+00
0e3821a8-80d6-4fa9-8313-3ed45b83c28b	contacto@de-la-cruz-espinoza-e-hijos.predicthealth.com	$2b$12$ylaHmxin3ZYy33e/XxAxmuIWHvXbMop2Bhb4pKVyYqezHhzznnEUS	institution	0e3821a8-80d6-4fa9-8313-3ed45b83c28b	t	t	0	\N	2025-11-22 04:41:43.007189+00	2025-11-22 04:41:43.007189+00	2025-11-22 04:41:43.007189+00
3d521bc9-692d-4a0d-a3d7-80e816b86374	contacto@laboratorios-valdes-ruelas.predicthealth.com	$2b$12$CQLygfy5Xg9SdkxHOGlT0OWLzOOM6oVQS6LLAGmn3fT1L4V76.0SC	institution	3d521bc9-692d-4a0d-a3d7-80e816b86374	t	t	0	\N	2025-11-22 04:41:43.010729+00	2025-11-22 04:41:43.010729+00	2025-11-22 04:41:43.010729+00
47393461-e570-448b-82b1-1cef15441262	contacto@espinosa-s-r-l-de-c-v.predicthealth.com	$2b$12$EYC0kJRog1wmEw.vn1Mfhe6oUPDYNik475hVR.bH.qSguvfKnYlZC	institution	47393461-e570-448b-82b1-1cef15441262	t	t	0	\N	2025-11-22 04:41:43.015338+00	2025-11-22 04:41:43.015338+00	2025-11-22 04:41:43.015338+00
744b4a03-e575-4978-b10e-6c087c9e744b	contacto@villarreal-ocasio.predicthealth.com	$2b$12$Vre8/XfP.6UT96zOljJ56.027K/kfx4pv5qfNAYnghdTXUDRsNkie	institution	744b4a03-e575-4978-b10e-6c087c9e744b	t	t	0	\N	2025-11-22 04:41:43.019068+00	2025-11-22 04:41:43.019068+00	2025-11-22 04:41:43.019068+00
9a18b839-1b93-44fb-9d8a-2ea12388e887	contacto@corporacin-carrasco-y-lopez.predicthealth.com	$2b$12$9wmxCYVPha15gOj1cpqdXeCNA6ab6bACQDZifqm4UhnlXTnpDnWuK	institution	9a18b839-1b93-44fb-9d8a-2ea12388e887	t	t	0	\N	2025-11-22 04:41:43.022504+00	2025-11-22 04:41:43.022504+00	2025-11-22 04:41:43.022504+00
1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	contacto@cisneros-concepcion.predicthealth.com	$2b$12$WR2IJLoySWKyHgjf7tjDmOmv/Vo6IQBg5uNHp56dRG3xPyTXieiXu	institution	1d9a84f8-fd22-4249-9b25-36c1d2ecc71b	t	t	0	\N	2025-11-22 04:41:43.025948+00	2025-11-22 04:41:43.025948+00	2025-11-22 04:41:43.025948+00
5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	contacto@jurado-guardado.predicthealth.com	$2b$12$kEUmDGNeGSlr76.Itaaoq.BTQBALKGpSEqM8C8.2UXdf94q1IGWAm	institution	5c8ca53e-0e4e-49b8-b1bb-2eaa10fa151f	t	t	0	\N	2025-11-22 04:41:43.029971+00	2025-11-22 04:41:43.029971+00	2025-11-22 04:41:43.029971+00
eea6be20-e19f-485f-ab54-537a7c28245f	contacto@club-perez-y-godoy.predicthealth.com	$2b$12$4teNLQpnZMQkhsAHlMcfyuj8nmVYvYDOUkj6NrPNd6/93u5nUJ4NC	institution	eea6be20-e19f-485f-ab54-537a7c28245f	t	t	0	\N	2025-11-22 04:41:43.033896+00	2025-11-22 04:41:43.033896+00	2025-11-22 04:41:43.033896+00
eb602cae-423a-455d-a22e-d47aea5eb650	contacto@de-la-fuente-arias.predicthealth.com	$2b$12$VzfaaD6kVj6Fv97i5UBAsOG3Pyedqes8q9VrKzsLK3uuLaDFzQATC	institution	eb602cae-423a-455d-a22e-d47aea5eb650	t	t	0	\N	2025-11-22 04:41:43.036876+00	2025-11-22 04:41:43.036876+00	2025-11-22 04:41:43.036876+00
bb17faca-a7b2-4de8-bf29-2fcb569ef554	contacto@hernandes-leiva-s-a.predicthealth.com	$2b$12$X7xv/u2MdEp25OeUX2il0uBYsRk.B165M1Cw5DrOfPBEaYLLnZYiu	institution	bb17faca-a7b2-4de8-bf29-2fcb569ef554	t	t	0	\N	2025-11-22 04:41:43.03988+00	2025-11-22 04:41:43.03988+00	2025-11-22 04:41:43.03988+00
44a33aab-1a23-4995-bd07-41f95b34fd57	contacto@grupo-garza-y-arellano.predicthealth.com	$2b$12$TMwUFpoyugqbcD4Obpzj..suXD3MiyWAFvYFf.3ZwYQT2YnyS/NwK	institution	44a33aab-1a23-4995-bd07-41f95b34fd57	t	t	0	\N	2025-11-22 04:41:43.042952+00	2025-11-22 04:41:43.042952+00	2025-11-22 04:41:43.042952+00
5462455f-fbe3-44c8-b0d1-0644c433aca6	contacto@laboratorios-navarrete-anaya.predicthealth.com	$2b$12$eYSk8zPCW.GTh/tROUtzOuhq8vSAtLe47gm8/HTmbxMlflYavHZ8y	institution	5462455f-fbe3-44c8-b0d1-0644c433aca6	t	t	0	\N	2025-11-22 04:41:43.047452+00	2025-11-22 04:41:43.047452+00	2025-11-22 04:41:43.047452+00
d050617d-dc89-4f28-b546-9680dd1c5fad	contacto@club-armas-polanco.predicthealth.com	$2b$12$iej7U762qNCbPuXavkoV3O0TOaD1prj4Ygy/2BegiaU8PiJxKd1Lm	institution	d050617d-dc89-4f28-b546-9680dd1c5fad	t	t	0	\N	2025-11-22 04:41:43.051441+00	2025-11-22 04:41:43.051441+00	2025-11-22 04:41:43.051441+00
7227444e-b122-48f4-8f01-2cda439507b1	contacto@olivera-lovato-y-saavedra.predicthealth.com	$2b$12$gIRz9hdGrVDDa7pnxKfpmOHR/dUotcPgoPLOUcbFlpp8psVWPbBtK	institution	7227444e-b122-48f4-8f01-2cda439507b1	t	t	0	\N	2025-11-22 04:41:43.054809+00	2025-11-22 04:41:43.054809+00	2025-11-22 04:41:43.054809+00
d86c173a-8a1d-43b4-a0c1-c836afdc378b	contacto@grupo-ochoa-corrales.predicthealth.com	$2b$12$L0kjU/0A7OK5FjLT9aeiWOJ7vZcCU4KTb2YCZWGTPomixFTY4nj8G	institution	d86c173a-8a1d-43b4-a0c1-c836afdc378b	t	t	0	\N	2025-11-22 04:41:43.058238+00	2025-11-22 04:41:43.058238+00	2025-11-22 04:41:43.058238+00
fb0a848d-4d51-4416-86bc-e568f694f9e7	contacto@banuelos-montano.predicthealth.com	$2b$12$oZriZb67qJqDtjGhNmoha.Cj4N9.qxbJOut/Q7rfKGTPCS3/UZXYa	institution	fb0a848d-4d51-4416-86bc-e568f694f9e7	t	t	0	\N	2025-11-22 04:41:43.061799+00	2025-11-22 04:41:43.061799+00	2025-11-22 04:41:43.061799+00
ccccdffb-bc26-4d80-a590-0cd86dd5a1bc	contacto@melendez-arriaga.predicthealth.com	$2b$12$HKAPM.Gt7zIyuH.erwX6U.YoOqT82Ztingoeoza9ioo45QssXvoMW	institution	ccccdffb-bc26-4d80-a590-0cd86dd5a1bc	t	t	0	\N	2025-11-22 04:41:43.066625+00	2025-11-22 04:41:43.066625+00	2025-11-22 04:41:43.066625+00
8cb48822-4d4c-42ed-af7f-737d3107b1db	contacto@corporacin-menchaca-y-salgado.predicthealth.com	$2b$12$xu7.RalsvP3ZsyNrxklwrex4N4hWmkCLEWJAdSZeo44OzZ9aeKKKK	institution	8cb48822-4d4c-42ed-af7f-737d3107b1db	t	t	0	\N	2025-11-22 04:41:43.076738+00	2025-11-22 04:41:43.076738+00	2025-11-22 04:41:43.076738+00
700b8c76-7ad1-4453-9ce3-f598565c6452	contacto@club-salcedo-y-segura.predicthealth.com	$2b$12$m1qbVl5g9g8U4RcfOCpk1eTqwbqj2aSP8KCI1xgf8.T.5oHuKRVoe	institution	700b8c76-7ad1-4453-9ce3-f598565c6452	t	t	0	\N	2025-11-22 04:41:43.081136+00	2025-11-22 04:41:43.081136+00	2025-11-22 04:41:43.081136+00
d3cb7dc8-9240-4800-a1d9-bf65c5dac801	contacto@grupo-rosas-mena-y-sandoval.predicthealth.com	$2b$12$nrt3K.GHtA3Vy6FCbsh3kujWWzRSJOfTb6wdhbdHvG4mBtfTW.9dq	institution	d3cb7dc8-9240-4800-a1d9-bf65c5dac801	t	t	0	\N	2025-11-22 04:41:43.084104+00	2025-11-22 04:41:43.084104+00	2025-11-22 04:41:43.084104+00
06c71356-e038-4c3d-bfea-7865acacb684	contacto@club-otero-valadez-y-crespo.predicthealth.com	$2b$12$BTAdbF131HeYmoR8mvBkp.bsd98tXUziG4Zi.fw0I9ETJQQ/vAiWq	institution	06c71356-e038-4c3d-bfea-7865acacb684	t	t	0	\N	2025-11-22 04:41:43.08702+00	2025-11-22 04:41:43.08702+00	2025-11-22 04:41:43.08702+00
30e2b2ec-9553-454e-92a4-c1dc89609cbb	contacto@industrias-esquibel-mesa-y-valle.predicthealth.com	$2b$12$DGp0MabXq8yB4R5Ss3CGBu7xmLY/Sj2hJOhFnFZ92hahMbTW97ewq	institution	30e2b2ec-9553-454e-92a4-c1dc89609cbb	t	t	0	\N	2025-11-22 04:41:43.090134+00	2025-11-22 04:41:43.090134+00	2025-11-22 04:41:43.090134+00
2eead5aa-095b-418a-bd02-e3a917971887	contacto@calvillo-y-benavides-a-c.predicthealth.com	$2b$12$YuBksLwh7X.9mEsErqAlauhw464wnBtXPfmiMTr9Wk6bP6YcQ.hfm	institution	2eead5aa-095b-418a-bd02-e3a917971887	t	t	0	\N	2025-11-22 04:41:43.10118+00	2025-11-22 04:41:43.10118+00	2025-11-22 04:41:43.10118+00
05afd7e1-bb93-4c83-90a7-48a65b6e7598	contacto@industrias-ledesma-jurado-y-pantoja.predicthealth.com	$2b$12$8E7AfYi7NRp04FFkfBOIl.QjTndffXnZOjpVepbSZwCKQNgql70AC	institution	05afd7e1-bb93-4c83-90a7-48a65b6e7598	t	t	0	\N	2025-11-22 04:41:43.120231+00	2025-11-22 04:41:43.120231+00	2025-11-22 04:41:43.120231+00
5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	contacto@cervantes-peralta.predicthealth.com	$2b$12$QlPJEtR9OeIxDKKWY6khYuqZ9lSBxI/XrDrEwufn1r4al9ClA4xj2	institution	5f30701a-a1bf-4337-9a60-8c4ed7f8ea15	t	t	0	\N	2025-11-22 04:41:43.127159+00	2025-11-22 04:41:43.127159+00	2025-11-22 04:41:43.127159+00
454f4ba6-cb6d-4f27-9d76-08f5b358b484	contacto@rico-y-escobar-s-a.predicthealth.com	$2b$12$PtFbfHB9RnaykQSZE1.mQeydDjGUWOvfHAE07.5eqRWUc3oKce3v6	institution	454f4ba6-cb6d-4f27-9d76-08f5b358b484	t	t	0	\N	2025-11-22 04:41:43.131973+00	2025-11-22 04:41:43.131973+00	2025-11-22 04:41:43.131973+00
389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	contacto@baez-viera-s-a.predicthealth.com	$2b$12$zf7a/0EnLSmrsvaU0uXvCOqfcKvl/rgsGQtVnZZdJDkHRpwXhY8w6	institution	389ca8e8-1fcf-4d8b-bc3d-11fc3ab20282	t	t	0	\N	2025-11-22 04:41:43.137106+00	2025-11-22 04:41:43.137106+00	2025-11-22 04:41:43.137106+00
df863eba-f0b8-4b1a-bdd1-71ed2f816ed7	dr.rebeca.paredes@longoria-florez.com	$2b$12$D.t3UBffh2FnUIi4tDbKE.s1hd/52DrzWYZl400B8klp0PQykSAuG	doctor	df863eba-f0b8-4b1a-bdd1-71ed2f816ed7	t	t	0	\N	2025-11-22 04:41:43.146788+00	2025-11-22 04:41:43.146788+00	2025-11-22 04:41:43.146788+00
ba712fc8-c4d2-4e22-ae18-1991c46bc85d	dr.mario.gaona@laboratorios.net	$2b$12$mukB7NZcrhAQcLl09MeO1uyAsS.4nXpS/orjNzIzzmKfHylTTKaJC	doctor	ba712fc8-c4d2-4e22-ae18-1991c46bc85d	t	t	0	\N	2025-11-22 04:41:43.166242+00	2025-11-22 04:41:43.166242+00	2025-11-22 04:41:43.166242+00
bbf715a1-3947-4642-a67a-b5c4c0c085d2	dr.luis.ceja@baez-burgos.com	$2b$12$RyJNRYXuivhb1y/8HNLhtuJTBo9po/lC7kmzyolytY0RsOP8Wbx4u	doctor	bbf715a1-3947-4642-a67a-b5c4c0c085d2	t	t	0	\N	2025-11-22 04:41:43.170724+00	2025-11-22 04:41:43.170724+00	2025-11-22 04:41:43.170724+00
851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec	dr.sergio.guevara@mateo.com	$2b$12$ouBn2Ak5QLxtW.RqPBAg7OBzood5dCKYtjzhxNgB7Gx1YT/tLcbJC	doctor	851a7fdf-cb52-4bd7-b69e-b6fb46a4d1ec	t	t	0	\N	2025-11-22 04:41:43.174484+00	2025-11-22 04:41:43.174484+00	2025-11-22 04:41:43.174484+00
0fbbaab0-2284-4ac6-b1c9-498b5b3c4567	dr.natalia.barrientos@balderas-marquez.com	$2b$12$hUoBk.8NXS7dfs8egqyjZe.WP7InlMr77w3qO3AVJt9wwOmz/xzz.	doctor	0fbbaab0-2284-4ac6-b1c9-498b5b3c4567	t	t	0	\N	2025-11-22 04:41:43.179028+00	2025-11-22 04:41:43.179028+00	2025-11-22 04:41:43.179028+00
b6994d45-b80e-4260-834c-facdf3ea8eee	dr.berta.rincon@arias.com	$2b$12$g8rlBROH/zByvgdP0u1U8epco03MKSTJFkxPiTzfS92eetb/NpHj.	doctor	b6994d45-b80e-4260-834c-facdf3ea8eee	t	t	0	\N	2025-11-22 04:41:43.183233+00	2025-11-22 04:41:43.183233+00	2025-11-22 04:41:43.183233+00
f7cdc060-94e6-47ad-90e9-939ed86fb6da	dr.lorenzo.rivera@corporacin.com	$2b$12$7fquDAAlwBBkvusybduaDOxEWEwMLcM/zywgzvaada97Mgftbfere	doctor	f7cdc060-94e6-47ad-90e9-939ed86fb6da	t	t	0	\N	2025-11-22 04:41:43.186801+00	2025-11-22 04:41:43.186801+00	2025-11-22 04:41:43.186801+00
23785934-fbf0-442c-add3-05df84fa5d17	dr.omar.trujillo@barela.biz	$2b$12$l3heGGZyCRK2.075JXBfb.0Bl7gvn2Ps6rI4RZlkzxUM6Q2bt/Klm	doctor	23785934-fbf0-442c-add3-05df84fa5d17	t	t	0	\N	2025-11-22 04:41:43.205545+00	2025-11-22 04:41:43.205545+00	2025-11-22 04:41:43.205545+00
bf7a015c-1589-42b3-b1e8-103fcbc0b041	dr.elvira.ochoa@castaneda-galvan.com	$2b$12$QJ7OXXopMdo1kD/XIQArh.US16o9PJzvx8HKM/X2Mo1rXUmfFwTlq	doctor	bf7a015c-1589-42b3-b1e8-103fcbc0b041	t	t	0	\N	2025-11-22 04:41:43.20871+00	2025-11-22 04:41:43.20871+00	2025-11-22 04:41:43.20871+00
4fa9d0ff-2c51-4918-b48a-b5cb37d444a3	dr.natalia.murillo@proyectos.biz	$2b$12$EGTVYCC0EFciFfolN8Pu1.cI087xg3QzxU3bRhD67SyTsv8h8o.Za	doctor	4fa9d0ff-2c51-4918-b48a-b5cb37d444a3	t	t	0	\N	2025-11-22 04:41:43.212563+00	2025-11-22 04:41:43.212563+00	2025-11-22 04:41:43.212563+00
93dbdfc0-e05c-4eb6-975c-360eb8d293c1	dr.pedro.valdes@granados.com	$2b$12$MkzGTU7p2yHvAJRNak9aJunCSHxD/34bugNeDWWXVvRkzsLMd6ucu	doctor	93dbdfc0-e05c-4eb6-975c-360eb8d293c1	t	t	0	\N	2025-11-22 04:41:43.216733+00	2025-11-22 04:41:43.216733+00	2025-11-22 04:41:43.216733+00
a6db1b41-d601-4840-99e9-3d7d18901399	dr.eugenio.uribe@olmos-alejandro.com	$2b$12$WRR3PQIaqi43QDCR4D8.BeUG8FHXadshqM51YW4OHlxlaacoswr.a	doctor	a6db1b41-d601-4840-99e9-3d7d18901399	t	t	0	\N	2025-11-22 04:41:43.221049+00	2025-11-22 04:41:43.221049+00	2025-11-22 04:41:43.221049+00
d5e98ce0-e6f8-4577-a0dd-3281aa303b32	dr.linda.trejo@bravo-alvarado.com	$2b$12$uYgF6gxc/RkDxSKQFN1PQOJk9G0en.WccH75Y7CS606WYrNNPjAVG	doctor	d5e98ce0-e6f8-4577-a0dd-3281aa303b32	t	t	0	\N	2025-11-22 04:41:43.223938+00	2025-11-22 04:41:43.223938+00	2025-11-22 04:41:43.223938+00
44da48b1-6ff6-4db9-9de5-34e22de0429a	dr.susana.acosta@iglesias.info	$2b$12$5vTMuYrsjbOuxwGmJazQWO7gcWlIpLRrbRiZGEUnKcMdJjXZcOGSe	doctor	44da48b1-6ff6-4db9-9de5-34e22de0429a	t	t	0	\N	2025-11-22 04:41:43.226873+00	2025-11-22 04:41:43.226873+00	2025-11-22 04:41:43.226873+00
3fafc20d-72d5-4633-95a0-df6b9ed175b6	dr.rodrigo.mota@valdivia.com	$2b$12$gM3u4VjQ2e4B49ZPDn7EV.mRQs6ikI8xu0jzeFHSBuzwIXuBy5.zm	doctor	3fafc20d-72d5-4633-95a0-df6b9ed175b6	t	t	0	\N	2025-11-22 04:41:43.230802+00	2025-11-22 04:41:43.230802+00	2025-11-22 04:41:43.230802+00
c4fac110-0b61-4fb0-943d-0d00af7ed0cd	dr.linda.magana@alva.com	$2b$12$TFiS8igwDykaFKgdSEI4GuRig6s/MApqvlJpS0aHuOJRpj.8UVylG	doctor	c4fac110-0b61-4fb0-943d-0d00af7ed0cd	t	t	0	\N	2025-11-22 04:41:43.24906+00	2025-11-22 04:41:43.24906+00	2025-11-22 04:41:43.24906+00
88870e4f-1333-4bcc-8daf-c8743d61f3cb	dr.joseluis.rubio@fernandez-carrillo.com	$2b$12$erqfP9VObUqiAot79mqkZepGl3SQKpHNij7UpjTY3QA.jvmuYxr5W	doctor	88870e4f-1333-4bcc-8daf-c8743d61f3cb	t	t	0	\N	2025-11-22 04:41:43.252432+00	2025-11-22 04:41:43.252432+00	2025-11-22 04:41:43.252432+00
6f035f60-87f7-4a9c-9501-4b8704facba3	dr.concepcion.barajas@saldana.info	$2b$12$T/Rluv42FKyOzQBs/wCHcuQTWZ3ZrfMwaMkiNoCNLFSCN9Cy3TCG6	doctor	6f035f60-87f7-4a9c-9501-4b8704facba3	t	t	0	\N	2025-11-22 04:41:43.255629+00	2025-11-22 04:41:43.255629+00	2025-11-22 04:41:43.255629+00
58a814d3-a275-436b-8e5c-4e743fed242f	dr.debora.delgadillo@blanco.com	$2b$12$sN5GyPh7YX3J.qkCtnTbjea6AKLU5xlzahzP64HE/sqdOJRxH0iy6	doctor	58a814d3-a275-436b-8e5c-4e743fed242f	t	t	0	\N	2025-11-22 04:41:43.258518+00	2025-11-22 04:41:43.258518+00	2025-11-22 04:41:43.258518+00
f67c2f76-9bf1-43e4-8d0e-c0a94298f35b	dr.augusto.roque@rincon.biz	$2b$12$5ULLH9kMFmZ89VNSiyWd1OE2gRlC0IiVO6zlsa7RSN7Ba3IraO.yi	doctor	f67c2f76-9bf1-43e4-8d0e-c0a94298f35b	t	t	0	\N	2025-11-22 04:41:43.261254+00	2025-11-22 04:41:43.261254+00	2025-11-22 04:41:43.261254+00
fb4d84a0-7bc1-4815-b7a3-b1719c616c79	dr.francisca.garay@cruz.info	$2b$12$J./PPFVcCWvDetu19enSNuDLWMV5ZjDTQkIK7K3xxqAZ8aSy2jHwi	doctor	fb4d84a0-7bc1-4815-b7a3-b1719c616c79	t	t	0	\N	2025-11-22 04:41:43.27946+00	2025-11-22 04:41:43.27946+00	2025-11-22 04:41:43.27946+00
c0bdb808-eb5f-479f-9261-dbbf9ff031a6	dr.judith.sevilla@despacho.com	$2b$12$R97OBhWNXK6htLUCAuwTh.5rsjjxYOhNlGaSs2H21gFQ8JpiT8VnC	doctor	c0bdb808-eb5f-479f-9261-dbbf9ff031a6	t	t	0	\N	2025-11-22 04:41:43.290702+00	2025-11-22 04:41:43.290702+00	2025-11-22 04:41:43.290702+00
f501d643-d308-41e0-8ffc-8bfb52d64e13	dr.nelly.robles@tamayo.biz	$2b$12$YRdB03faIn0j2hhqA4NMSuDi8bwC1zqovf2WUy30Ov8j9Z8G.lPfq	doctor	f501d643-d308-41e0-8ffc-8bfb52d64e13	t	t	0	\N	2025-11-22 04:41:43.299562+00	2025-11-22 04:41:43.299562+00	2025-11-22 04:41:43.299562+00
adeb74f6-f3dc-43a7-a841-6d24aba046ba	dr.soledad.noriega@industrias.biz	$2b$12$F3gUAkV7qoZJ6kob8e5qDehDmno/E7sukXHWgUvD5g6PqzWscoGL.	doctor	adeb74f6-f3dc-43a7-a841-6d24aba046ba	t	t	0	\N	2025-11-22 04:41:43.306412+00	2025-11-22 04:41:43.306412+00	2025-11-22 04:41:43.306412+00
dd24da99-43c7-4d6b-acc0-32fc0c237d02	dr.silvano.espinosa@saldivar.org	$2b$12$pVTMjNaZMV2oQGjSEkwcj.op2MpH1fLVJSatEW9RYEk86J6h35DAq	doctor	dd24da99-43c7-4d6b-acc0-32fc0c237d02	t	t	0	\N	2025-11-22 04:41:43.319643+00	2025-11-22 04:41:43.319643+00	2025-11-22 04:41:43.319643+00
0408b031-caa3-4b7c-ae65-d05342cf5c05	dr.fabiola.saavedra@burgos.net	$2b$12$76VIfrvzinNALFyDFveTcOPPuKTzpF.arXWb4nwUDYL58z5/1xFzC	doctor	0408b031-caa3-4b7c-ae65-d05342cf5c05	t	t	0	\N	2025-11-22 04:41:43.323758+00	2025-11-22 04:41:43.323758+00	2025-11-22 04:41:43.323758+00
a865edbe-d50c-4bd1-b556-ae32d9d1858c	dr.silvia.enriquez@padilla-alejandro.biz	$2b$12$nDCNrCb7Xw5QPX2FHFIbSu0efIfXn2B43iAD3i8fFQPjoHr9L0HEK	doctor	a865edbe-d50c-4bd1-b556-ae32d9d1858c	t	t	0	\N	2025-11-22 04:41:43.328101+00	2025-11-22 04:41:43.328101+00	2025-11-22 04:41:43.328101+00
2a0aaddd-ea43-40bb-b5df-877b1b0d20f1	dr.maximiliano.segura@club.net	$2b$12$Eghgd1yorzvC46TlbxCZhuk9xG08LgzmAsyJ8WK1nhyd2WyNvZPE2	doctor	2a0aaddd-ea43-40bb-b5df-877b1b0d20f1	t	t	0	\N	2025-11-22 04:41:43.332686+00	2025-11-22 04:41:43.332686+00	2025-11-22 04:41:43.332686+00
4754ba59-3dc1-4be2-a770-44d7c34184bc	dr.josemaria.serna@pelayo-baeza.info	$2b$12$Jgw9DvVBLsKK2Cj5pcShLOQEGxeQWFJ/cuHeVi5upQB06KVJ/sZNy	doctor	4754ba59-3dc1-4be2-a770-44d7c34184bc	t	t	0	\N	2025-11-22 04:41:43.336781+00	2025-11-22 04:41:43.336781+00	2025-11-22 04:41:43.336781+00
16e23379-6774-417d-8104-a8e6f4712909	dr.eugenio.gastelum@grupo.com	$2b$12$qX/qrd/HK1yXkSqI1E4MMOmxlIZA3VWJ1MPpaByAfbl8qD1BJuwPC	doctor	16e23379-6774-417d-8104-a8e6f4712909	t	t	0	\N	2025-11-22 04:41:43.341184+00	2025-11-22 04:41:43.341184+00	2025-11-22 04:41:43.341184+00
07527c1a-efd5-45e4-a0d9-01ba5207bb2f	dr.eva.cotto@industrias.com	$2b$12$./b5ivwrK0uXPThlE118MulhFUrimby1RIRphz.CBwAU0SC3qhUZy	doctor	07527c1a-efd5-45e4-a0d9-01ba5207bb2f	t	t	0	\N	2025-11-22 04:41:43.344745+00	2025-11-22 04:41:43.344745+00	2025-11-22 04:41:43.344745+00
c186d1ad-fcba-4f6e-acd7-86cb4c09938e	dr.indira.ramon@proyectos.com	$2b$12$3DcrNvjHiw2LYfcRXseZNOovKU0GDRSCEvv1ocaDWseddoTm.3R7.	doctor	c186d1ad-fcba-4f6e-acd7-86cb4c09938e	t	t	0	\N	2025-11-22 04:41:43.34987+00	2025-11-22 04:41:43.34987+00	2025-11-22 04:41:43.34987+00
4cecebec-e16f-4949-a18b-8bfebae86618	dr.patricia.angulo@industrias.com	$2b$12$KfRwspMR2A9twzWJ8jYOQO5iI2D4nM6xyHvr/eN58esQ0dv5YZ0q2	doctor	4cecebec-e16f-4949-a18b-8bfebae86618	t	t	0	\N	2025-11-22 04:41:43.35654+00	2025-11-22 04:41:43.35654+00	2025-11-22 04:41:43.35654+00
6d21a37a-43d8-440b-bc64-87bb0ae1d45d	dr.helena.valladares@corporacin.com	$2b$12$MbVLy2EiAFwxHsW0MamRLOFn8IZYG30d/rMOJ/P5xeQPExmmV5d9C	doctor	6d21a37a-43d8-440b-bc64-87bb0ae1d45d	t	t	0	\N	2025-11-22 04:41:43.360541+00	2025-11-22 04:41:43.360541+00	2025-11-22 04:41:43.360541+00
4d75aae7-5d33-44ad-a297-a32ff407415d	dr.ruben.pacheco@quezada.com	$2b$12$d.6nwzOgatBdPQ1l/4bsU.aZ/FD5qbA9Y0gsiA.F/Ri1D2t3MDK1u	doctor	4d75aae7-5d33-44ad-a297-a32ff407415d	t	t	0	\N	2025-11-22 04:41:43.380244+00	2025-11-22 04:41:43.380244+00	2025-11-22 04:41:43.380244+00
e901dbc1-3eed-4e5e-b23c-58d808477e33	dr.samuel.garibay@laboratorios.org	$2b$12$kYe9jegNaqRo8nXIR3u7fu3OKxZjAvQx3T./Rj8HZOKwuHdLrk362	doctor	e901dbc1-3eed-4e5e-b23c-58d808477e33	t	t	0	\N	2025-11-22 04:41:43.387362+00	2025-11-22 04:41:43.387362+00	2025-11-22 04:41:43.387362+00
61bb20b9-7520-42be-accf-743c84a0b934	dr.joaquin.vigil@industrias.com	$2b$12$qUtXtJ1H7lPo6qY22LrMjuw0Wtw0ttxREjvD3Tl19fj65NOPkvgTK	doctor	61bb20b9-7520-42be-accf-743c84a0b934	t	t	0	\N	2025-11-22 04:41:43.391513+00	2025-11-22 04:41:43.391513+00	2025-11-22 04:41:43.391513+00
b5a04df6-baea-460f-a946-f7b7606c9982	dr.amador.arenas@collazo.org	$2b$12$7QuF/uy/nh28bQOk.Rr4EuVgYNotmThCTtXQe5lLIkAGpsqLwQfVW	doctor	b5a04df6-baea-460f-a946-f7b7606c9982	t	t	0	\N	2025-11-22 04:41:43.395635+00	2025-11-22 04:41:43.395635+00	2025-11-22 04:41:43.395635+00
c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	dr.felipe.hidalgo@laboratorios.com	$2b$12$fvEw4/cYcwDaM6gNlT0L/.CTzuxVzxUVkhmGberO11sXOml6Jo8im	doctor	c1182c2e-0624-42f9-aef6-7e7a1a2b7dba	t	t	0	\N	2025-11-22 04:41:43.401418+00	2025-11-22 04:41:43.401418+00	2025-11-22 04:41:43.401418+00
0b238725-a392-4fbb-956b-0f71e15bc6da	dr.mariateresa.baca@corporacin.biz	$2b$12$0ChZ868tlW840NqCG8Yz.eQOWIEN6ZLfPrgAsGAddzuVnItnataom	doctor	0b238725-a392-4fbb-956b-0f71e15bc6da	t	t	0	\N	2025-11-22 04:41:43.405399+00	2025-11-22 04:41:43.405399+00	2025-11-22 04:41:43.405399+00
63ec3e7d-b8e4-4988-9bc3-5b655f830e31	dr.miguelangel.perez@proyectos.com	$2b$12$JqhEAEjPEJojUMLWcsJ4fOZ7tSQGVp81LCAOMRa3qSj.OyNkQeBKO	doctor	63ec3e7d-b8e4-4988-9bc3-5b655f830e31	t	t	0	\N	2025-11-22 04:41:43.424645+00	2025-11-22 04:41:43.424645+00	2025-11-22 04:41:43.424645+00
d4df85ce-6d2b-46c9-b9cd-48b2490b3c88	dr.jonas.madera@villareal-cardenas.com	$2b$12$tfkU68AM.4saWHvEI.9vqOpD7XizrHvl9Ecg/EXjsNMH7IV3a7Nsi	doctor	d4df85ce-6d2b-46c9-b9cd-48b2490b3c88	t	t	0	\N	2025-11-22 04:41:43.429817+00	2025-11-22 04:41:43.429817+00	2025-11-22 04:41:43.429817+00
71618fe0-25a1-4281-98af-51797de3ae0a	dr.arcelia.delarosa@ramon.info	$2b$12$4ldVB8AEpkSycLsOViLS7ebeVZjk1RpiHkE9SpW49IQzxPwDCJqRm	doctor	71618fe0-25a1-4281-98af-51797de3ae0a	t	t	0	\N	2025-11-22 04:41:43.435551+00	2025-11-22 04:41:43.435551+00	2025-11-22 04:41:43.435551+00
389524b6-608c-4b31-affa-305b79635816	dr.esther.echeverria@armendariz.com	$2b$12$czdXhzoReNZIvgfp0ie4xOCuc4xnjvxu1BSov3Hbsafdw7H5U92Y2	doctor	389524b6-608c-4b31-affa-305b79635816	t	t	0	\N	2025-11-22 04:41:43.441065+00	2025-11-22 04:41:43.441065+00	2025-11-22 04:41:43.441065+00
c0356e82-1510-4557-b654-cf84ac13f425	dr.sofia.montez@farias.org	$2b$12$81YnKW5tYrDfltuJHLwZSeHspzsI/z3893kcxymK9F3PRgg79vNAC	doctor	c0356e82-1510-4557-b654-cf84ac13f425	t	t	0	\N	2025-11-22 04:41:43.445051+00	2025-11-22 04:41:43.445051+00	2025-11-22 04:41:43.445051+00
ce44b08f-7dae-4844-ae53-e01ac2f28f45	dr.debora.segura@grupo.org	$2b$12$M8K2Su3.ubRQmsxDO1kq8uDPBdfAw3/EQ/NqeKkfR1pQXNLipq7Ui	doctor	ce44b08f-7dae-4844-ae53-e01ac2f28f45	t	t	0	\N	2025-11-22 04:41:43.450328+00	2025-11-22 04:41:43.450328+00	2025-11-22 04:41:43.450328+00
9c9838c2-4464-4fbb-bc22-8f4ac64b4efe	dr.luismiguel.villarreal@de.info	$2b$12$KmrjbO2yKZ5icJmpDP1fMu5Tb7B8gB.RxAfs7vYJqktRL1agd8uTy	doctor	9c9838c2-4464-4fbb-bc22-8f4ac64b4efe	t	t	0	\N	2025-11-22 04:41:43.453471+00	2025-11-22 04:41:43.453471+00	2025-11-22 04:41:43.453471+00
e8db5b49-5605-41e5-91f2-d456b68c5ade	dr.esmeralda.parra@limon-dominguez.info	$2b$12$8QzKKym5yU7sgMEVCcXvcOth0ATGoiaT6zDEGP/mQvLVdJYTzsUB6	doctor	e8db5b49-5605-41e5-91f2-d456b68c5ade	t	t	0	\N	2025-11-22 04:41:43.457511+00	2025-11-22 04:41:43.457511+00	2025-11-22 04:41:43.457511+00
96d6da02-ca2f-4ace-b239-4584544e8230	dr.patricia.tellez@corporacin.com	$2b$12$D6uvueeJtNlZAen5.4hbfuK5aLlBM/JYVou5JYpO/SQEL5RNJVjs6	doctor	96d6da02-ca2f-4ace-b239-4584544e8230	t	t	0	\N	2025-11-22 04:41:43.460848+00	2025-11-22 04:41:43.460848+00	2025-11-22 04:41:43.460848+00
38bf2ce6-5014-4bc1-8e32-9b9257eea501	dr.timoteo.tafoya@chapa-zamudio.biz	$2b$12$TiiLJQ9gAFNrLdWsEKz84.UY9tuz5bkU.RwkIKyaDEerl43SEPUmy	doctor	38bf2ce6-5014-4bc1-8e32-9b9257eea501	t	t	0	\N	2025-11-22 04:41:43.465267+00	2025-11-22 04:41:43.465267+00	2025-11-22 04:41:43.465267+00
e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c	dr.amanda.ferrer@laboratorios.org	$2b$12$PmgOchNQV2H/7Ds4mj2gsu0FDT8l50t64u6Z.woaqyWUOB/lwaC6e	doctor	e6a4df0f-eb88-4d6c-be0e-d13845a4ba6c	t	t	0	\N	2025-11-22 04:41:43.468104+00	2025-11-22 04:41:43.468104+00	2025-11-22 04:41:43.468104+00
8ce8b684-8f8d-4828-987d-389dfe64afd1	dr.caridad.villa@club.com	$2b$12$SidH9U8lkm1wEgq0KeJBPuKSVfvmzsX103uRVxlYHRSvxhaJjb5ui	doctor	8ce8b684-8f8d-4828-987d-389dfe64afd1	t	t	0	\N	2025-11-22 04:41:43.471336+00	2025-11-22 04:41:43.471336+00	2025-11-22 04:41:43.471336+00
ca8bf565-35d3-40f3-b741-603201f6f072	dr.hector.castro@segovia.info	$2b$12$9ojLbm23IosjR0adRVhuouEnm3YhF5W3.E.uceLfdpvPa3GowxTTu	doctor	ca8bf565-35d3-40f3-b741-603201f6f072	t	t	0	\N	2025-11-22 04:41:43.475976+00	2025-11-22 04:41:43.475976+00	2025-11-22 04:41:43.475976+00
2937cc2f-22b7-4488-b9f8-a0795800a840	dr.abraham.rodarte@despacho.net	$2b$12$wojt2veDBSWyGSLK/fofdON/Fh31l4rveywRH4h4Go3Btbb.XaUOe	doctor	2937cc2f-22b7-4488-b9f8-a0795800a840	t	t	0	\N	2025-11-22 04:41:43.482622+00	2025-11-22 04:41:43.482622+00	2025-11-22 04:41:43.482622+00
f8a511e3-b97b-4d17-8240-46520497ef7c	dr.gloria.briones@grupo.info	$2b$12$qXTZnGU.uf5L8Dbc6Qsc4.YEhbzHmaEq1kjKwzNxOTqpXhCLURWLq	doctor	f8a511e3-b97b-4d17-8240-46520497ef7c	t	t	0	\N	2025-11-22 04:41:43.486882+00	2025-11-22 04:41:43.486882+00	2025-11-22 04:41:43.486882+00
879bcb9a-8520-4d02-b12b-ba5afa629d41	dr.joseluis.bahena@solano.com	$2b$12$XVMQUIJZSEtz5LYU.a3l9uD18Tqtu4fdr3LUkedTqtRQHQafvaJga	doctor	879bcb9a-8520-4d02-b12b-ba5afa629d41	t	t	0	\N	2025-11-22 04:41:43.490275+00	2025-11-22 04:41:43.490275+00	2025-11-22 04:41:43.490275+00
7817761a-e7c5-47cb-a260-7e243c11ef2f	dr.daniela.laboy@urrutia-resendez.org	$2b$12$/NhnYpwd2ph3druQrCe7AOWAOgFll1I1/rgsiIiXTYoHcDNx8EB1S	doctor	7817761a-e7c5-47cb-a260-7e243c11ef2f	t	t	0	\N	2025-11-22 04:41:43.494412+00	2025-11-22 04:41:43.494412+00	2025-11-22 04:41:43.494412+00
48384f36-0b57-4943-899f-cbffd4ec37b6	dr.bruno.ledesma@florez-mojica.com	$2b$12$kNIKYVPjsWCoerlozFxf6uU7ydN7KpyR4ssHAtEKrpV/OdOt3dgT2	doctor	48384f36-0b57-4943-899f-cbffd4ec37b6	t	t	0	\N	2025-11-22 04:41:43.498166+00	2025-11-22 04:41:43.498166+00	2025-11-22 04:41:43.498166+00
0fc70684-777f-43eb-895d-9cb90ce0f584	dr.noelia.garica@proyectos.com	$2b$12$EC2kvLUq5CTIpDpr/pVLGunmHwYqZxBxPU.sz.azUbdzS4/fz5wXi	doctor	0fc70684-777f-43eb-895d-9cb90ce0f584	t	t	0	\N	2025-11-22 04:41:43.501193+00	2025-11-22 04:41:43.501193+00	2025-11-22 04:41:43.501193+00
a849f14b-3741-4e38-9dfb-6cc7d46265e8	dr.mitzy.godoy@bernal.com	$2b$12$kkrDT66CxruJyvq2IR0HhurcOK8NeUUBreaypzCKS8.FgAduPh6tS	doctor	a849f14b-3741-4e38-9dfb-6cc7d46265e8	t	t	0	\N	2025-11-22 04:41:43.504298+00	2025-11-22 04:41:43.504298+00	2025-11-22 04:41:43.504298+00
22128ae9-ba6e-4e99-821a-dc445e76d641	dr.sessa.medina@holguin.com	$2b$12$ToXfetD2DW0Gj33D457mmeDHqzYmuKBTEDEE/7gK162mWe6Iw6L7C	doctor	22128ae9-ba6e-4e99-821a-dc445e76d641	t	t	0	\N	2025-11-22 04:41:43.509457+00	2025-11-22 04:41:43.509457+00	2025-11-22 04:41:43.509457+00
6c711a31-c752-44f2-b6cb-480f9bf6af1f	dr.mitzy.aguayo@despacho.biz	$2b$12$0KdgU/lTViO8H/A2gaHOweDdAWlNjA03/wEf/h6uE5yLMsXvjH5uq	doctor	6c711a31-c752-44f2-b6cb-480f9bf6af1f	t	t	0	\N	2025-11-22 04:41:43.514117+00	2025-11-22 04:41:43.514117+00	2025-11-22 04:41:43.514117+00
ab923e2e-5d13-41e4-9c73-2f62cca0699d	dr.patricio.monroy@aguirre-bernal.com	$2b$12$wBsZHlOMRwr8F79uC/dpSOizAe85IKg9zv3Bem3jdgp/VdblPcehC	doctor	ab923e2e-5d13-41e4-9c73-2f62cca0699d	t	t	0	\N	2025-11-22 04:41:43.517367+00	2025-11-22 04:41:43.517367+00	2025-11-22 04:41:43.517367+00
a7f19796-4c62-4a2b-82de-7c2677804e6a	dr.homero.valentin@olivares.com	$2b$12$5fxkyIB2L2M9IrcM8XM0U.OX1qlo74oqBYSegW9fGepO4O3o2pyYC	doctor	a7f19796-4c62-4a2b-82de-7c2677804e6a	t	t	0	\N	2025-11-22 04:41:43.520476+00	2025-11-22 04:41:43.520476+00	2025-11-22 04:41:43.520476+00
28958f29-28c6-405a-acf5-949ffcaec286	dr.porfirio.farias@despacho.com	$2b$12$LcMz8484Vid6L71OZFcn3u4YefbYyEBcPJMuETNQbKq60sDeLGZEW	doctor	28958f29-28c6-405a-acf5-949ffcaec286	t	t	0	\N	2025-11-22 04:41:43.523692+00	2025-11-22 04:41:43.523692+00	2025-11-22 04:41:43.523692+00
472116b5-933e-4f63-b3ca-e8c8f5d30bb4	dr.gonzalo.cortes@yanez.com	$2b$12$UaWbi42xAp.Ic6sIA6OIhu0agecs1.iSRdRAwVxFztNNB9JiUev.e	doctor	472116b5-933e-4f63-b3ca-e8c8f5d30bb4	t	t	0	\N	2025-11-22 04:41:43.529056+00	2025-11-22 04:41:43.529056+00	2025-11-22 04:41:43.529056+00
a2beaa02-c033-4e45-b702-305d5ce41e34	dr.marisol.tello@navarrete-leon.com	$2b$12$EqojBayPxXzsjgOLUGiiMeXqsSNnzM/0aVu.hFdpn/.7sCf9Qkeae	doctor	a2beaa02-c033-4e45-b702-305d5ce41e34	t	t	0	\N	2025-11-22 04:41:43.533251+00	2025-11-22 04:41:43.533251+00	2025-11-22 04:41:43.533251+00
5879ec30-c291-476d-a48c-284fadf5f98a	dr.mateo.serrato@laboratorios.biz	$2b$12$8CqExPdUaB9jl3rUovrjz.L6IDBnaHZV5/RFVGCSezYoRMfrEfpPm	doctor	5879ec30-c291-476d-a48c-284fadf5f98a	t	t	0	\N	2025-11-22 04:41:43.537747+00	2025-11-22 04:41:43.537747+00	2025-11-22 04:41:43.537747+00
d512bd88-12a3-45f9-85e8-14fb3cb5a6e1	dr.reina.camacho@colunga.info	$2b$12$QSK5/MZXG1/YJsYGZ5h8huZosUr4jiqH5moyEa.ynSGIouefEpHhm	doctor	d512bd88-12a3-45f9-85e8-14fb3cb5a6e1	t	t	0	\N	2025-11-22 04:41:43.541731+00	2025-11-22 04:41:43.541731+00	2025-11-22 04:41:43.541731+00
757d6edf-5aa8-461b-ac4f-9e8365017424	dr.homero.rodarte@alva-quintanilla.com	$2b$12$.0/8Q5/HAD2Wx2SQu5Ptk.IVKUt87gxVRY.URHb2k5aYUYf43DAIm	doctor	757d6edf-5aa8-461b-ac4f-9e8365017424	t	t	0	\N	2025-11-22 04:41:43.546032+00	2025-11-22 04:41:43.546032+00	2025-11-22 04:41:43.546032+00
c0d54a00-2ee9-4827-a7fb-6196ef15bdee	dr.martin.trevino@espinoza-pineda.info	$2b$12$93F7TFFHo25gcTFcfVHksuy9RkxN1zV2uas7ONgAE3G1MX2DVIkJa	doctor	c0d54a00-2ee9-4827-a7fb-6196ef15bdee	t	t	0	\N	2025-11-22 04:41:43.549249+00	2025-11-22 04:41:43.549249+00	2025-11-22 04:41:43.549249+00
a7ada88a-7935-4dd5-8a4f-935c4b7c0bab	dr.wilfrido.salazar@arenas-campos.net	$2b$12$LSpdN3H4mgKs1No4xb4YxOmUoik62/nIS2mMDLMoH5ZkwsUrjXfUW	doctor	a7ada88a-7935-4dd5-8a4f-935c4b7c0bab	t	t	0	\N	2025-11-22 04:41:43.553931+00	2025-11-22 04:41:43.553931+00	2025-11-22 04:41:43.553931+00
4664d394-c950-4dbf-9b40-7b34c6d6dabb	dr.uriel.velazquez@zedillo-camarillo.net	$2b$12$nYQWx2tmrEdiG1lSx7DL8eKHAlWwpgTkTPDwxZyS4gPTYUzehm0Gi	doctor	4664d394-c950-4dbf-9b40-7b34c6d6dabb	t	t	0	\N	2025-11-22 04:41:43.558224+00	2025-11-22 04:41:43.558224+00	2025-11-22 04:41:43.558224+00
c16b254c-dcf7-4a31-a101-1ed86b62477e	dr.jos.briones@robledo.com	$2b$12$k6eDfUVNbdUxCf6U.nn7MOC3WDOu9K.K61dLdq07aSpKR4ud/NPIa	doctor	c16b254c-dcf7-4a31-a101-1ed86b62477e	t	t	0	\N	2025-11-22 04:41:43.562556+00	2025-11-22 04:41:43.562556+00	2025-11-22 04:41:43.562556+00
e0926c16-7f63-41ae-a091-1d0688c88322	dr.david.dominguez@maya.com	$2b$12$lC9L.SCibUCPnGEHFFK5BePrYfh/GpYRHUA2gb1XwE4qVT1yelYhe	doctor	e0926c16-7f63-41ae-a091-1d0688c88322	t	t	0	\N	2025-11-22 04:41:43.565952+00	2025-11-22 04:41:43.565952+00	2025-11-22 04:41:43.565952+00
250b33c9-1ba3-44e6-9c35-cde7000d6d53	dr.adan.ferrer@corporacin.info	$2b$12$kBFhPMqd2uT39OZAWWJlsOtBFvyv/2iPt4s22plqGLfZ9YIwEK1ma	doctor	250b33c9-1ba3-44e6-9c35-cde7000d6d53	t	t	0	\N	2025-11-22 04:41:43.569735+00	2025-11-22 04:41:43.569735+00	2025-11-22 04:41:43.569735+00
b6c86aef-75e2-4c64-bceb-e7de898b5a1b	dr.irene.cisneros@saucedo.com	$2b$12$nZYwBKlNbv82ZsGd9K1sR.kRCaGPHIjbO0k3gsopcRk3W1aTsqDvq	doctor	b6c86aef-75e2-4c64-bceb-e7de898b5a1b	t	t	0	\N	2025-11-22 04:41:43.576504+00	2025-11-22 04:41:43.576504+00	2025-11-22 04:41:43.576504+00
a3fb2dae-2a69-434f-86a9-65ae48c8f690	dr.altagracia.orellana@barela.com	$2b$12$vAugJVBLlrv1tt7hroC/eeUTPIp3PSPW/gTQ2lffMW6S.QwsKTZUW	doctor	a3fb2dae-2a69-434f-86a9-65ae48c8f690	t	t	0	\N	2025-11-22 04:41:43.58422+00	2025-11-22 04:41:43.58422+00	2025-11-22 04:41:43.58422+00
820c1228-3d2d-4766-900f-32940f14e74b	dr.cristal.balderas@ozuna.com	$2b$12$TO7PQDr1JIXp8ZlLUMmkp.x2WvuWhfzNpaSgJuPzZEcFCCsJaxi42	doctor	820c1228-3d2d-4766-900f-32940f14e74b	t	t	0	\N	2025-11-22 04:41:43.587175+00	2025-11-22 04:41:43.587175+00	2025-11-22 04:41:43.587175+00
da3dbacf-8df0-46cf-bbef-b51615063a9b	dr.marisol.ulloa@vazquez-santillan.info	$2b$12$j4VqEl4LOvLQ265tTuIMI.HY2fRA64NkClM0WX6h9aGdSeeykAgZa	doctor	da3dbacf-8df0-46cf-bbef-b51615063a9b	t	t	0	\N	2025-11-22 04:41:43.590788+00	2025-11-22 04:41:43.590788+00	2025-11-22 04:41:43.590788+00
e6ce6823-6c4d-4ead-98d7-78b94483fe2c	dr.alfonso.cazares@nava-soto.com	$2b$12$ynAZUvMrN40R6VzVXhPLc.BKfqyZkPUBxdC7pQI06WbANZQ1tCxXW	doctor	e6ce6823-6c4d-4ead-98d7-78b94483fe2c	t	t	0	\N	2025-11-22 04:41:43.594925+00	2025-11-22 04:41:43.594925+00	2025-11-22 04:41:43.594925+00
84cb6703-edfc-4180-9f80-619064c9684e	dr.elisa.oquendo@despacho.com	$2b$12$urpK462tn0oaCJhfQR2h8eHANA/pqUyLrQu/W0w.Git54YBlUvoE.	doctor	84cb6703-edfc-4180-9f80-619064c9684e	t	t	0	\N	2025-11-22 04:41:43.598119+00	2025-11-22 04:41:43.598119+00	2025-11-22 04:41:43.598119+00
21e4d7a9-73dc-4156-b413-b389c2e92a0d	dr.silvano.brito@despacho.com	$2b$12$1Knk4A10Q.Dix8CsxMitOulzYwaQIMJNHKcNxgW5./2OT0XIOlvBq	doctor	21e4d7a9-73dc-4156-b413-b389c2e92a0d	t	t	0	\N	2025-11-22 04:41:43.602508+00	2025-11-22 04:41:43.602508+00	2025-11-22 04:41:43.602508+00
85eb8041-b502-4b90-b586-c7c4593b5347	dr.ursula.casares@vega-montalvo.com	$2b$12$aj/01O7De69NPWpcTEydQO2OEyKjhnmOjqeS0zqdWsVOKXJ22hw0O	doctor	85eb8041-b502-4b90-b586-c7c4593b5347	t	t	0	\N	2025-11-22 04:41:43.606929+00	2025-11-22 04:41:43.606929+00	2025-11-22 04:41:43.606929+00
c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9	dr.marcela.corona@marroquin-cardenas.org	$2b$12$6m/D7h4BG1QYs8.kmuo58uP2T/TmARGqTOiDOnT3j2f9y7cyBQrd2	doctor	c9e4b7a3-a9d6-4dfc-a27f-0aa71bb9d3b9	t	t	0	\N	2025-11-22 04:41:43.609942+00	2025-11-22 04:41:43.609942+00	2025-11-22 04:41:43.609942+00
22d570dd-a72e-4599-8f13-df952d35d616	dr.catalina.orta@padilla.com	$2b$12$3jjzBjzGDadfobjRvu/HYOP8aLuMkgGCbrgDsfTjT1haIP.3UJ7Vi	doctor	22d570dd-a72e-4599-8f13-df952d35d616	t	t	0	\N	2025-11-22 04:41:43.612701+00	2025-11-22 04:41:43.612701+00	2025-11-22 04:41:43.612701+00
04a9b2e7-638b-4fe0-a106-16b582d946ab	dr.rene.morales@matos.org	$2b$12$.C9kSIW1Gy1StVUGtMBONueMbFvHnW43RPX/j8BrhWHHsc6S6Rfzu	doctor	04a9b2e7-638b-4fe0-a106-16b582d946ab	t	t	0	\N	2025-11-22 04:41:43.615914+00	2025-11-22 04:41:43.615914+00	2025-11-22 04:41:43.615914+00
03e547d1-325a-46ea-bc94-c188abf53f0f	dr.benjamin.leal@industrias.com	$2b$12$HJ3DYy12yj7RzG0X61u1bOFrHl3Lprd/EUnz1SNYOZYnJYdfdasKq	doctor	03e547d1-325a-46ea-bc94-c188abf53f0f	t	t	0	\N	2025-11-22 04:41:43.619875+00	2025-11-22 04:41:43.619875+00	2025-11-22 04:41:43.619875+00
5a6de593-99b5-4942-a379-fd21b2a4999f	dr.catalina.alarcon@jimenez.org	$2b$12$ft3VdymT68IY4rElyV94NOX2GBTBG/rnhYt44DyIGC0qOdYHC40L6	doctor	5a6de593-99b5-4942-a379-fd21b2a4999f	t	t	0	\N	2025-11-22 04:41:43.624396+00	2025-11-22 04:41:43.624396+00	2025-11-22 04:41:43.624396+00
b7dd043b-953f-4e04-8a80-1c613d3c6675	dr.pedro.riojas@tellez-rincon.com	$2b$12$I07P/0e4a.AWH3xllnpq3.Vpuz44KWMCFvf7lz1nNQ5hBDqqqWJWO	doctor	b7dd043b-953f-4e04-8a80-1c613d3c6675	t	t	0	\N	2025-11-22 04:41:43.627814+00	2025-11-22 04:41:43.627814+00	2025-11-22 04:41:43.627814+00
852beb97-3c99-4391-879f-98f0c2154c20	dr.olivia.nieto@laboratorios.com	$2b$12$6mFyAS/XbjZxnAqIIOo4YeY2Fpou3ldqJSoEMUCEBCs6dc46kp6jO	doctor	852beb97-3c99-4391-879f-98f0c2154c20	t	t	0	\N	2025-11-22 04:41:43.630595+00	2025-11-22 04:41:43.630595+00	2025-11-22 04:41:43.630595+00
86bb4262-7a96-444b-a096-d3a1bd7782e7	dr.victoria.corona@cadena.net	$2b$12$XkuDLSuNLhE7XaNBDgjTJOYutbnlMqdW1ymqkMlbMmZT6LqSTLoYa	doctor	86bb4262-7a96-444b-a096-d3a1bd7782e7	t	t	0	\N	2025-11-22 04:41:43.633155+00	2025-11-22 04:41:43.633155+00	2025-11-22 04:41:43.633155+00
b441c98a-1075-4013-9fc2-9242d910713f	dr.daniela.gallegos@villalpando-chapa.com	$2b$12$tj7u2nRfzHoQw6CgbnaRK.QWjOTMoPvoYkuvLr2D1l4ru53W4l6oW	doctor	b441c98a-1075-4013-9fc2-9242d910713f	t	t	0	\N	2025-11-22 04:41:43.636994+00	2025-11-22 04:41:43.636994+00	2025-11-22 04:41:43.636994+00
77486cf8-54d8-4120-856f-642ebae74d48	dr.victoria.urbina@corporacin.com	$2b$12$YQtGaEnyHtJhZMN13e37CuyjUvpFBOx3DlCGoZJwZtS/RITeTGQlK	doctor	77486cf8-54d8-4120-856f-642ebae74d48	t	t	0	\N	2025-11-22 04:41:43.641236+00	2025-11-22 04:41:43.641236+00	2025-11-22 04:41:43.641236+00
0e2fa589-05b2-402c-9722-1022a0121b04	dr.leonardo.aguirre@arroyo.biz	$2b$12$XMB/DkPdOfbhMYA3XdLheO0pg1rpIbRSlPRx8a8e68yumdHoH2L6m	doctor	0e2fa589-05b2-402c-9722-1022a0121b04	t	t	0	\N	2025-11-22 04:41:43.644403+00	2025-11-22 04:41:43.644403+00	2025-11-22 04:41:43.644403+00
2f5622af-8528-4c85-8e16-3d175a4f2d15	linda.najera.1967@escobar.biz	$2b$12$Nt.znNV.HgD4TdFYVCbSIu1f5yyKKUqNBF5d8ptbmHG6Z4f9J19fy	patient	2f5622af-8528-4c85-8e16-3d175a4f2d15	t	t	0	\N	2025-11-22 04:41:43.647206+00	2025-11-22 04:41:43.647206+00	2025-11-22 04:41:43.647206+00
fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	marisela.rocha.1971@industrias.biz	$2b$12$X7vTY1yXEW.h6/E9vlRkU.A3/VR1gcykgSn7IQf/s1TZHd80lwJHq	patient	fb4bebf4-9a5f-4e9a-9d5e-63463b54ba3c	t	t	0	\N	2025-11-22 04:41:43.649818+00	2025-11-22 04:41:43.649818+00	2025-11-22 04:41:43.649818+00
959aa1dd-346b-4542-8f99-0d5e75301249	homero.miranda.1976@ontiveros.net	$2b$12$gK6jnqDXB6Pd3Kvm.9ZUX.BpBwOLvCwXY6gbn8Z5aoxfaub4aKleu	patient	959aa1dd-346b-4542-8f99-0d5e75301249	t	t	0	\N	2025-11-22 04:41:43.662905+00	2025-11-22 04:41:43.662905+00	2025-11-22 04:41:43.662905+00
59402562-ce5f-450e-8e6c-9630514fe164	manuel.vela.1989@armendariz.com	$2b$12$H2ecF1V/7XD7AFPoQ2hvnO9frxeXZQW.X6S.ozIN6zxX5SXZs/FGa	patient	59402562-ce5f-450e-8e6c-9630514fe164	t	t	0	\N	2025-11-22 04:41:43.667842+00	2025-11-22 04:41:43.667842+00	2025-11-22 04:41:43.667842+00
f81c87d6-32f1-4c79-993a-18db4734ef65	paulina.cervantez.1975@pedraza.biz	$2b$12$0H4Ob91SXqJ5b1hZF6mmxe4YXSElV1P2b2CJzUjaQFbJLAaZ1u4Iq	patient	f81c87d6-32f1-4c79-993a-18db4734ef65	t	t	0	\N	2025-11-22 04:41:43.672812+00	2025-11-22 04:41:43.672812+00	2025-11-22 04:41:43.672812+00
0b6b8229-4027-4ec7-8bce-c805de96ced3	benjamin.serna.1972@grupo.com	$2b$12$7kdF4a3u/fR50FSZhBUjEO2FVKqlMNvfxH8j.H3sQWcH6sxKZpHoa	patient	0b6b8229-4027-4ec7-8bce-c805de96ced3	t	t	0	\N	2025-11-22 04:41:43.676958+00	2025-11-22 04:41:43.676958+00	2025-11-22 04:41:43.676958+00
f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	rosa.galvez.1962@rosas-urrutia.info	$2b$12$lHxIfC67wWOq/gvR722iye95CvIikBWjie5W7ckSn0nZXixvcpdYi	patient	f3e7b909-8cc0-4bc9-948d-48c1eaeb02eb	t	t	0	\N	2025-11-22 04:41:43.680203+00	2025-11-22 04:41:43.680203+00	2025-11-22 04:41:43.680203+00
f2a1f62a-8030-4f65-b82d-ce7376b955bd	nelly.montemayor.1991@tafoya-cervantes.biz	$2b$12$GHQ5RcJQlXWZ5HO9HPxU7OppUWgLKpkhjxRheCFvoKykTwryvIyme	patient	f2a1f62a-8030-4f65-b82d-ce7376b955bd	t	t	0	\N	2025-11-22 04:41:43.683384+00	2025-11-22 04:41:43.683384+00	2025-11-22 04:41:43.683384+00
0104fea2-d27c-4611-8414-da6c898b6944	rolando.jaimes.1994@matias.org	$2b$12$NKQVWj.CoTvK.8JL1SUAx.RpBrsB4fABdx3s/a3sn7GNpZlIAXmG6	patient	0104fea2-d27c-4611-8414-da6c898b6944	t	t	0	\N	2025-11-22 04:41:43.687785+00	2025-11-22 04:41:43.687785+00	2025-11-22 04:41:43.687785+00
cd0c2f0c-de08-439c-93c9-0feab1d433cc	bruno.urena.1966@solorio-murillo.com	$2b$12$yMT5GpTRNDMX1U.vzKv7c.VQbG6AhYXGUMKOM/DrT/ecN09jh.ndm	patient	cd0c2f0c-de08-439c-93c9-0feab1d433cc	t	t	0	\N	2025-11-22 04:41:43.692058+00	2025-11-22 04:41:43.692058+00	2025-11-22 04:41:43.692058+00
7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	luismanuel.morales.1956@cordero-meza.com	$2b$12$pzXpSQI0KQhbi0dXCsZWYON8A0MCOBmJH2ORgEHvjcOi0cmNoT8yC	patient	7d38d8cc-b97b-4e0a-98c1-6ad7dacd9545	t	t	0	\N	2025-11-22 04:41:43.696261+00	2025-11-22 04:41:43.696261+00	2025-11-22 04:41:43.696261+00
7893292b-965a-41da-896a-d0780c91fdd5	david.benavidez.1953@proyectos.org	$2b$12$6TP3EsgQ18Y1Alwfs9PzVeyK4vjw.TORf5arMY7iUCDEJQyC5FXW6	patient	7893292b-965a-41da-896a-d0780c91fdd5	t	t	0	\N	2025-11-22 04:41:43.700247+00	2025-11-22 04:41:43.700247+00	2025-11-22 04:41:43.700247+00
87fb3c88-6653-45db-aa6c-20ea7512da64	clara.pelayo.1954@aparicio-ceballos.com	$2b$12$8xLzsHWm237MYnPgT0cHOugOkUEU.YCDEpQTobE5/pJrAt6XLyaKe	patient	87fb3c88-6653-45db-aa6c-20ea7512da64	t	t	0	\N	2025-11-22 04:41:43.703815+00	2025-11-22 04:41:43.703815+00	2025-11-22 04:41:43.703815+00
05e42aed-c457-4579-904f-d397be3075f7	santiago.armendariz.2001@industrias.com	$2b$12$5p7X0Lwguffa.wL.qLZtzOjtdoyADGX2b2LUBWF6X3Dovi5unGLYC	patient	05e42aed-c457-4579-904f-d397be3075f7	t	t	0	\N	2025-11-22 04:41:43.708511+00	2025-11-22 04:41:43.708511+00	2025-11-22 04:41:43.708511+00
43756f6c-c157-4a44-9c84-ab2d62fddcf7	carlos.menchaca.1949@camacho-saenz.info	$2b$12$tLWqkoczWaGSODgiqCo9HuR1P..acGPoIWNi8I6ROYFhI1WkMb.iO	patient	43756f6c-c157-4a44-9c84-ab2d62fddcf7	t	t	0	\N	2025-11-22 04:41:43.71263+00	2025-11-22 04:41:43.71263+00	2025-11-22 04:41:43.71263+00
d8e1fa52-0a65-4917-b410-2954e05a34e5	manuel.gracia.1978@grupo.net	$2b$12$Vhuh94P0bYjISvXH/5uPRukNvoP4YLqLOxFzPJv1c6hOGfic/196e	patient	d8e1fa52-0a65-4917-b410-2954e05a34e5	t	t	0	\N	2025-11-22 04:41:43.717017+00	2025-11-22 04:41:43.717017+00	2025-11-22 04:41:43.717017+00
bbc67f38-a9eb-4379-aeaf-1560af0d1a34	jos.perea.2000@corporacin.com	$2b$12$nKazE0EjG6dGyG7/YarvhuvU/JO6VzjsGumlTVqyiOYexqp7y8QKm	patient	bbc67f38-a9eb-4379-aeaf-1560af0d1a34	t	t	0	\N	2025-11-22 04:41:43.720833+00	2025-11-22 04:41:43.720833+00	2025-11-22 04:41:43.720833+00
b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	esparta.franco.1987@proyectos.com	$2b$12$Dva4Hy9RwX/Naq8zMUcMlOaKBar1qxtkmLfwdPyUgsJnj/dYTSY6W	patient	b4600fa0-c9a5-4d1e-b82b-d84bd2d5595e	t	t	0	\N	2025-11-22 04:41:43.724949+00	2025-11-22 04:41:43.724949+00	2025-11-22 04:41:43.724949+00
309df411-1d1a-4d00-a34e-36e8c32da210	joseluis.miramontes.1951@gaytan.biz	$2b$12$hB3uNAPqLNn/rxooBvy97eH3tUIwXY3//3oWxyiTJZOswxzO81oim	patient	309df411-1d1a-4d00-a34e-36e8c32da210	t	t	0	\N	2025-11-22 04:41:43.728244+00	2025-11-22 04:41:43.728244+00	2025-11-22 04:41:43.728244+00
663d036b-a19b-4557-af37-d68a9ce4976d	amalia.arenas.1975@alfaro.com	$2b$12$gdO6Dmc74xfcoIbfvonZqu9RAiNUMkPU4UQTAAiY4VlM2MlBnCex6	patient	663d036b-a19b-4557-af37-d68a9ce4976d	t	t	0	\N	2025-11-22 04:41:43.731687+00	2025-11-22 04:41:43.731687+00	2025-11-22 04:41:43.731687+00
a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	angelica.serrato.1960@lozano.org	$2b$12$WXcrsynCF56dVATGMDCVl.5LhAb59qHrXFc6zHxMcuOwq1EjPI7Di	patient	a754cbf1-a4ca-42dc-92c4-d980b6a25a6d	t	t	0	\N	2025-11-22 04:41:43.736066+00	2025-11-22 04:41:43.736066+00	2025-11-22 04:41:43.736066+00
d5b1779e-21f2-4252-a421-f2aaf9998916	pascual.barragan.1977@valdivia-briseno.net	$2b$12$TC3xoFIdpDL8rJ./LEOdk.qy4955Yo9SlgyeiP2tCJIfoPy14KKO.	patient	d5b1779e-21f2-4252-a421-f2aaf9998916	t	t	0	\N	2025-11-22 04:41:43.739961+00	2025-11-22 04:41:43.739961+00	2025-11-22 04:41:43.739961+00
6661483b-705b-412a-8bbd-39c0af0dadb1	jesus.abreu.1955@moya-mares.com	$2b$12$Nuph7a7c75pO4RLOZeor2uZHdmgd.CBoVVbkV9Wnv6xE4ro12DaxW	patient	6661483b-705b-412a-8bbd-39c0af0dadb1	t	t	0	\N	2025-11-22 04:41:43.744219+00	2025-11-22 04:41:43.744219+00	2025-11-22 04:41:43.744219+00
676491c4-f31a-42b6-a991-a8dd09bbb1f0	victor.espinosa.1988@grupo.biz	$2b$12$OcEcssALSOYBDcC27KOBq.mEeiltQ8beedzla1Tg6KNkc2mKOg.2W	patient	676491c4-f31a-42b6-a991-a8dd09bbb1f0	t	t	0	\N	2025-11-22 04:41:43.748653+00	2025-11-22 04:41:43.748653+00	2025-11-22 04:41:43.748653+00
167dedde-166c-45e4-befc-4f1c9b7184ad	camilo.villa.1998@proyectos.org	$2b$12$hONL.eW.I2tIw9MtwgzjCOwAhNkaUXXwVi/vk7NzrcuHhR7CXOQpa	patient	167dedde-166c-45e4-befc-4f1c9b7184ad	t	t	0	\N	2025-11-22 04:41:43.753527+00	2025-11-22 04:41:43.753527+00	2025-11-22 04:41:43.753527+00
72eca572-4ecf-4be8-906b-40e89e0d9a08	mario.santillan.1966@coronado.info	$2b$12$cRt3WDnRZwkNJIJwKJLBY.PYBtSGGnloChEqUyCoeXfyNDDR71Cbq	patient	72eca572-4ecf-4be8-906b-40e89e0d9a08	t	t	0	\N	2025-11-22 04:41:43.756409+00	2025-11-22 04:41:43.756409+00	2025-11-22 04:41:43.756409+00
d5bec069-a317-4a40-b3e8-ea80220d75de	cristobal.paez.1961@godoy-grijalva.com	$2b$12$nQpbrBMCxo3qoY6cVoeY4epXXpJK4enZdOIbOFBXlpeepRhjWewCC	patient	d5bec069-a317-4a40-b3e8-ea80220d75de	t	t	0	\N	2025-11-22 04:41:43.759333+00	2025-11-22 04:41:43.759333+00	2025-11-22 04:41:43.759333+00
0e97294d-78cc-4428-a172-e4e1fd4efa72	celia.olivo.1961@vazquez.com	$2b$12$up6mnpmjQXyNnMViV9519.Ztix4fQOrLqgjKywp3PbpPj0FqHgtIO	patient	0e97294d-78cc-4428-a172-e4e1fd4efa72	t	t	0	\N	2025-11-22 04:41:43.762239+00	2025-11-22 04:41:43.762239+00	2025-11-22 04:41:43.762239+00
9f86a53f-f0e1-446d-89f0-86b086dd12a9	teresa.arguello.1949@jaime-aranda.com	$2b$12$jx3RLPegv7sjns0eq6BmGuCSuxIdMqEOOR2XGFvq6cZ7Rolgy0kfq	patient	9f86a53f-f0e1-446d-89f0-86b086dd12a9	t	t	0	\N	2025-11-22 04:41:43.766421+00	2025-11-22 04:41:43.766421+00	2025-11-22 04:41:43.766421+00
ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	pilar.valle.1981@grupo.com	$2b$12$8o.477qCFdzu8/0TuGRmwu6AeiGdyDIyLd/mu2KM5gWHiHEOQFDwi	patient	ae1f5c92-f3cf-43d8-918f-aaad6fb46c05	t	t	0	\N	2025-11-22 04:41:43.769812+00	2025-11-22 04:41:43.769812+00	2025-11-22 04:41:43.769812+00
d28440a6-3bd9-4a48-8a72-d700ae0971e4	eva.orellana.1988@proyectos.com	$2b$12$q1dH7DmqOzf4MCEa5TzHAOSqfg9vnh/ybqcnXrpaJ.xfZqkL98ky.	patient	d28440a6-3bd9-4a48-8a72-d700ae0971e4	t	t	0	\N	2025-11-22 04:41:43.777776+00	2025-11-22 04:41:43.777776+00	2025-11-22 04:41:43.777776+00
7f839ee8-bdd6-4a63-83e8-30db007565e2	rafael.olvera.1946@proyectos.net	$2b$12$k/Rq1mkfXac0w1ZmCeFUmuhdRpo2oRSw80bMg/k6Ua9lQDikG92Py	patient	7f839ee8-bdd6-4a63-83e8-30db007565e2	t	t	0	\N	2025-11-22 04:41:43.782038+00	2025-11-22 04:41:43.782038+00	2025-11-22 04:41:43.782038+00
67aa999f-9d31-4b61-a097-35097ea0d082	anel.baeza.1997@aponte.com	$2b$12$PfyOXs4etI0QybPEvGQ7QO7EO4AiAdtlQVZ3rOE4xuWdhNwcwt0la	patient	67aa999f-9d31-4b61-a097-35097ea0d082	t	t	0	\N	2025-11-22 04:41:43.78554+00	2025-11-22 04:41:43.78554+00	2025-11-22 04:41:43.78554+00
41aa2fbc-8ef4-4448-8686-399a1cd54be9	jesus.negron.1966@proyectos.com	$2b$12$kL5pbJ4t4nkTTjj0.xtoheDXgOQRJ9QeFf6l8goY6Y4asmxdM2N/q	patient	41aa2fbc-8ef4-4448-8686-399a1cd54be9	t	t	0	\N	2025-11-22 04:41:43.790591+00	2025-11-22 04:41:43.790591+00	2025-11-22 04:41:43.790591+00
111769f3-1a1b-44a9-9670-f4f2e424d1d2	asuncion.ybarra.2000@proyectos.com	$2b$12$dZDIN/RM1KwoPnWjPjEo1OwytPr5z7Bc3j.avyrwu2pa5mOMSb3QS	patient	111769f3-1a1b-44a9-9670-f4f2e424d1d2	t	t	0	\N	2025-11-22 04:41:43.794901+00	2025-11-22 04:41:43.794901+00	2025-11-22 04:41:43.794901+00
2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	roberto.varela.1961@laboratorios.com	$2b$12$qM31u8eTff2K9dhJnEXID.QMvac/Vqv.A8v1.Zll.mIJH/bqPAvF2	patient	2c7e6f03-b9b3-47c8-ae46-57c7bcc919e1	t	t	0	\N	2025-11-22 04:41:43.798194+00	2025-11-22 04:41:43.798194+00	2025-11-22 04:41:43.798194+00
6a8b6d41-8d20-4bc5-8d48-538d348f6086	alejandra.acosta.1950@laboratorios.com	$2b$12$ljD0OkxxO0qQnH6xk4XuCepG027YJZs/ccU6Wiu/PPXESfH0BvJj2	patient	6a8b6d41-8d20-4bc5-8d48-538d348f6086	t	t	0	\N	2025-11-22 04:41:43.802054+00	2025-11-22 04:41:43.802054+00	2025-11-22 04:41:43.802054+00
89657c95-84c0-4bd0-80c6-70a2c4721276	minerva.ortiz.1985@club.biz	$2b$12$nidwJfTFlRDT7pH7LEpfeO5gZoTba.79oa.rTEQBh0m5vT/Ez9kXW	patient	89657c95-84c0-4bd0-80c6-70a2c4721276	t	t	0	\N	2025-11-22 04:41:43.806817+00	2025-11-22 04:41:43.806817+00	2025-11-22 04:41:43.806817+00
b6658dac-0ee1-415c-95ad-28c6acea85bd	amanda.menendez.1966@despacho.biz	$2b$12$4LAYIKorYqdLglkvTg4y1u8RGYD9Zf6WUMfJrMadilC.mmLva7E1u	patient	b6658dac-0ee1-415c-95ad-28c6acea85bd	t	t	0	\N	2025-11-22 04:41:43.811725+00	2025-11-22 04:41:43.811725+00	2025-11-22 04:41:43.811725+00
56564104-6009-466c-9134-c15d3175613b	hermelinda.medrano.1970@grupo.net	$2b$12$nQ0cHxbLTc7L1KWSy2EOFukHSC/0OySjp4IfAMmAlPqAHbaztbW7K	patient	56564104-6009-466c-9134-c15d3175613b	t	t	0	\N	2025-11-22 04:41:43.815628+00	2025-11-22 04:41:43.815628+00	2025-11-22 04:41:43.815628+00
edb1d693-b308-4ff6-8fd4-9e20561317e8	alonso.roldan.1960@gamez.com	$2b$12$Sf/XgqLOhx01z41RLSD1U.cMsPH.GUrEkslr03OxzE.ViIP8ArMFW	patient	edb1d693-b308-4ff6-8fd4-9e20561317e8	t	t	0	\N	2025-11-22 04:41:43.819745+00	2025-11-22 04:41:43.819745+00	2025-11-22 04:41:43.819745+00
9511f9b9-a450-489c-92b9-ac306733cee4	alma.sosa.2001@renteria.org	$2b$12$lK3OBSTndr8dOJ8k7U5/D.kad31vUKXvleCwlW6b/643F7xO9kX1e	patient	9511f9b9-a450-489c-92b9-ac306733cee4	t	t	0	\N	2025-11-22 04:41:43.823211+00	2025-11-22 04:41:43.823211+00	2025-11-22 04:41:43.823211+00
004ce58b-6a0d-4646-92c3-4508deb6b354	estela.lucero.1979@industrias.com	$2b$12$Bchq/HjH52p1fpZpj75MG.zxxVGKL33cz9PdFahf0knbCx7oeW7nW	patient	004ce58b-6a0d-4646-92c3-4508deb6b354	t	t	0	\N	2025-11-22 04:41:43.8271+00	2025-11-22 04:41:43.8271+00	2025-11-22 04:41:43.8271+00
0d1bcc20-a5be-40f0-a28b-23c2c77c51be	gonzalo.laureano.1979@llamas.info	$2b$12$/P8wOOTsUsygUgusXTozve9VNzy3uu1S42srIsgLL2lj/fM9OcCty	patient	0d1bcc20-a5be-40f0-a28b-23c2c77c51be	t	t	0	\N	2025-11-22 04:41:43.830021+00	2025-11-22 04:41:43.830021+00	2025-11-22 04:41:43.830021+00
38000dbb-417f-43ca-a60e-5812796420f7	helena.muro.1973@laboratorios.com	$2b$12$Hg6r9C3iehfIzQmdgAa4D.CKeZ2sOurRY.cQmqztnbxGMZia4LL6O	patient	38000dbb-417f-43ca-a60e-5812796420f7	t	t	0	\N	2025-11-22 04:41:43.833035+00	2025-11-22 04:41:43.833035+00	2025-11-22 04:41:43.833035+00
5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	adela.vergara.1991@lopez-gallardo.com	$2b$12$muk8f.dQJpP4TENPMbhPtuTZd/MXw4MW5D3CSpBT5yAHT6fqG4jhS	patient	5ae0a393-b399-4dc6-95d8-297d3b3ef0a8	t	t	0	\N	2025-11-22 04:41:43.8374+00	2025-11-22 04:41:43.8374+00	2025-11-22 04:41:43.8374+00
561c313d-2c15-41b1-b965-a38c8e0f6c42	salma.almaraz.1994@corporacin.com	$2b$12$AkLEd7GHn/GW3TyBV0Q88erW8a4CxSpfRKCAlSFXi4LW1yoHvLx3i	patient	561c313d-2c15-41b1-b965-a38c8e0f6c42	t	t	0	\N	2025-11-22 04:41:43.841459+00	2025-11-22 04:41:43.841459+00	2025-11-22 04:41:43.841459+00
ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	humberto.caraballo.1946@grupo.com	$2b$12$2kcZsd0hkJW8JMSOAVvE0uECm2h85TroCT7JGhDhkAlAzK6/ps.eO	patient	ba4b2a5b-887d-4f3d-8ec7-570cfe087b28	t	t	0	\N	2025-11-22 04:41:43.845726+00	2025-11-22 04:41:43.845726+00	2025-11-22 04:41:43.845726+00
cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	mauricio.zavala.1997@corporacin.com	$2b$12$OclOCTuBaezeU2dBiwd3c.WXXqVRiyiMp/PO6Qk13h7qK0JJ6n/vu	patient	cbdb51c5-0334-4e15-b4b9-13b1de1c4c20	t	t	0	\N	2025-11-22 04:41:43.849118+00	2025-11-22 04:41:43.849118+00	2025-11-22 04:41:43.849118+00
05bc2942-e676-42e9-ad01-ade9f7cc5aee	roberto.alejandro.1960@laboratorios.info	$2b$12$uCzXSpNBVcpDiFqgauG8t.hEUGGsoyokYY61Qla67XEu069e3GiUq	patient	05bc2942-e676-42e9-ad01-ade9f7cc5aee	t	t	0	\N	2025-11-22 04:41:43.853386+00	2025-11-22 04:41:43.853386+00	2025-11-22 04:41:43.853386+00
c78e7658-d517-4ca1-990b-e6971f8d108f	victor.gutierrez.1983@laboratorios.net	$2b$12$zztcWWsmlYV/CLoZA0KFK.JsREO5vrMp/.WtEOVFEsixl9/Mzfu5e	patient	c78e7658-d517-4ca1-990b-e6971f8d108f	t	t	0	\N	2025-11-22 04:41:43.857512+00	2025-11-22 04:41:43.857512+00	2025-11-22 04:41:43.857512+00
65474c27-8f72-4690-8f19-df9344e4be5e	adan.nava.2000@cedillo.info	$2b$12$jgyy9OZddlFHzmfoARuta.mwjjAqT1Z9DOqvVUS1qKqPsgc2a86CC	patient	65474c27-8f72-4690-8f19-df9344e4be5e	t	t	0	\N	2025-11-22 04:41:43.860476+00	2025-11-22 04:41:43.860476+00	2025-11-22 04:41:43.860476+00
c1b6fa98-203a-4321-96cd-e80e7a1c9461	amador.cano.1995@velasquez.com	$2b$12$/Jomy7IcPqHmcrIj6w/SdO0Esfc8nUEs.SbYXW4o/oZF8E9XUvuKa	patient	c1b6fa98-203a-4321-96cd-e80e7a1c9461	t	t	0	\N	2025-11-22 04:41:43.864921+00	2025-11-22 04:41:43.864921+00	2025-11-22 04:41:43.864921+00
9244b388-8c06-42c7-9c4e-cbaae5b1baa3	alfonso.prado.1955@saucedo.net	$2b$12$rJJY2NU3w.5kdpwNoDeAl.90zk9nmyNmgRurtvY.FWtJU6Dbwv282	patient	9244b388-8c06-42c7-9c4e-cbaae5b1baa3	t	t	0	\N	2025-11-22 04:41:43.868968+00	2025-11-22 04:41:43.868968+00	2025-11-22 04:41:43.868968+00
eb2e55f6-4738-4352-a59a-860909f1932c	uriel.suarez.1972@chapa.com	$2b$12$AyFi.FJeWD5qNsKNNBUq5.wpUKcHdak3zhzb5D6NtImEMIYxahMXe	patient	eb2e55f6-4738-4352-a59a-860909f1932c	t	t	0	\N	2025-11-22 04:41:43.87172+00	2025-11-22 04:41:43.87172+00	2025-11-22 04:41:43.87172+00
c572a4c7-e475-4d18-85da-417abcd00903	armando.porras.1954@maestas-mireles.biz	$2b$12$jz4a5gbtVYrTLTyzL56T2ud4yMnXhrZCW9I477r7oPr2qf.SSmnWW	patient	c572a4c7-e475-4d18-85da-417abcd00903	t	t	0	\N	2025-11-22 04:41:43.874493+00	2025-11-22 04:41:43.874493+00	2025-11-22 04:41:43.874493+00
5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	teresa.granado.1953@beltran.net	$2b$12$AlYrxiz8Bw5RnFcyTBuemO2BnNXuyh5jx5jXK82oVU79OtfK0G5bq	patient	5ff458b2-f6aa-4d5f-a983-a5aeaa37cbe3	t	t	0	\N	2025-11-22 04:41:43.878854+00	2025-11-22 04:41:43.878854+00	2025-11-22 04:41:43.878854+00
9b02d89c-2c5b-4c51-8183-15ccd1184990	marcela.fernandez.1981@corporacin.net	$2b$12$09p2ifC5JJ0KgNlG0fLw3eeQ1V8h04ikQCIhg9UFhJb2VA8dmItXK	patient	9b02d89c-2c5b-4c51-8183-15ccd1184990	t	t	0	\N	2025-11-22 04:41:43.883217+00	2025-11-22 04:41:43.883217+00	2025-11-22 04:41:43.883217+00
43ae2e81-ac13-40ac-949c-9e4f51d76098	sergio.loya.1970@jaime-santiago.com	$2b$12$KyAEIcaF2hmBnla4P3v.fuBd/iqJHULOEEXxN8wvbBShhuF.A2gGS	patient	43ae2e81-ac13-40ac-949c-9e4f51d76098	t	t	0	\N	2025-11-22 04:41:43.887343+00	2025-11-22 04:41:43.887343+00	2025-11-22 04:41:43.887343+00
49a18092-8f90-4f6b-873c-8715b64b8aff	jorgeluis.molina.1953@rosas.com	$2b$12$vy/iSirzrwXCgGTB/g81wOP7QlezBAiLWpRCZdieIzUP29mEcuJgq	patient	49a18092-8f90-4f6b-873c-8715b64b8aff	t	t	0	\N	2025-11-22 04:41:43.890644+00	2025-11-22 04:41:43.890644+00	2025-11-22 04:41:43.890644+00
c9a949e5-e650-4d95-9e2e-49ed06e5d087	elvira.echeverria.1970@melgar.org	$2b$12$h6ao1Wyi.1zjMgYn3tZCB.0cgkw0.J0CR7I7cyAXMOpuIXgXLNyF2	patient	c9a949e5-e650-4d95-9e2e-49ed06e5d087	t	t	0	\N	2025-11-22 04:41:43.893711+00	2025-11-22 04:41:43.893711+00	2025-11-22 04:41:43.893711+00
a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	federico.fajardo.1949@industrias.com	$2b$12$dlOqwHZ1dKzpDMrkaD67duFN3S7p35/RK1aXJczUcPtNMEIJ6my3W	patient	a4e5cbb3-36f7-43d8-a65a-e30fc1361e56	t	t	0	\N	2025-11-22 04:41:43.898051+00	2025-11-22 04:41:43.898051+00	2025-11-22 04:41:43.898051+00
447e48dc-861c-41e6-920e-a2dec785101f	elena.quintanilla.1979@arellano-delgadillo.com	$2b$12$FdO1YrGw89Wb7.VuwW.D4uayjqszk3EYFjR44KksB0BmuIEqUkpxS	patient	447e48dc-861c-41e6-920e-a2dec785101f	t	t	0	\N	2025-11-22 04:41:43.901586+00	2025-11-22 04:41:43.901586+00	2025-11-22 04:41:43.901586+00
3a535951-40fd-4959-a34e-07b29f675ecc	cynthia.jurado.1991@zelaya-vazquez.com	$2b$12$dPDRFbwj/iovW3Z81iHxhO99BzKRngrjfEVFOA8JMVJCvDbDL2ei2	patient	3a535951-40fd-4959-a34e-07b29f675ecc	t	t	0	\N	2025-11-22 04:41:43.905861+00	2025-11-22 04:41:43.905861+00	2025-11-22 04:41:43.905861+00
d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	juana.gurule.1993@zaragoza.com	$2b$12$UXrJmKtFFw.bwV9HpTTepeqULrGv3zQZ1WF6KsS5lL0XelFaQtVVe	patient	d4bfb3cb-c8d6-434a-a3d4-2712ecea4d70	t	t	0	\N	2025-11-22 04:41:43.909818+00	2025-11-22 04:41:43.909818+00	2025-11-22 04:41:43.909818+00
6052a417-6725-4fab-b7dd-7f498454cd47	lilia.mesa.1956@grijalva-trejo.com	$2b$12$nDT1kHf2fm65b20sF8Vl2.6sRF.eXN83wMH1DO.IaTeFAnT3qIXsK	patient	6052a417-6725-4fab-b7dd-7f498454cd47	t	t	0	\N	2025-11-22 04:41:43.913176+00	2025-11-22 04:41:43.913176+00	2025-11-22 04:41:43.913176+00
dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	octavio.gurule.2004@grupo.com	$2b$12$6auSOApvs/bwd/0981j5dePdIcvw5P84ocYhA./WzxUj6f129lxsK	patient	dad07e7d-fcb6-407a-9267-b7ab0a92d4a7	t	t	0	\N	2025-11-22 04:41:43.925704+00	2025-11-22 04:41:43.925704+00	2025-11-22 04:41:43.925704+00
f740b251-4264-4220-8400-706331f650af	estefania.vanegas.1946@despacho.com	$2b$12$vvIbYi12hwyOy9LBdwnHs.R318T2buZCYODkMxcdpVpD2gmQbhROm	patient	f740b251-4264-4220-8400-706331f650af	t	t	0	\N	2025-11-22 04:41:43.930548+00	2025-11-22 04:41:43.930548+00	2025-11-22 04:41:43.930548+00
fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	alfredo.holguin.1963@club.com	$2b$12$BNsAOZjKRpPrNRxjpTAgZOmZCj8wi09r0N1GiYdLBGBj0AuHuMQCO	patient	fac7afba-7f9c-40f9-9a06-a9782ad7d3a7	t	t	0	\N	2025-11-22 04:41:43.934591+00	2025-11-22 04:41:43.934591+00	2025-11-22 04:41:43.934591+00
a329242d-9e38-4178-aa8e-5b7497209897	daniel.caban.1964@laboratorios.biz	$2b$12$JdxWKWA7y0jd4zkERPl/HOpjSWCBV8wIefZTmomJRa9ATJhI.nlhu	patient	a329242d-9e38-4178-aa8e-5b7497209897	t	t	0	\N	2025-11-22 04:41:43.939121+00	2025-11-22 04:41:43.939121+00	2025-11-22 04:41:43.939121+00
fe2cc660-dd15-4d31-ac72-56114bdb6b92	graciela.bonilla.1997@valentin-galvez.com	$2b$12$7LpIGVkFc/1EeiS4cWDB.Ozj8lZW4MFsrPAoKMZaqF.E4Fd78Rhl.	patient	fe2cc660-dd15-4d31-ac72-56114bdb6b92	t	t	0	\N	2025-11-22 04:41:43.942861+00	2025-11-22 04:41:43.942861+00	2025-11-22 04:41:43.942861+00
fd01c50f-f3dd-4517-96c0-c0e65330a692	jaqueline.olivas.1950@arredondo-barajas.com	$2b$12$zP6dTiVeSM2rP3ltdoS8K.1HYUyhLZEZsjm/ccF2mKwArC3TRwvpq	patient	fd01c50f-f3dd-4517-96c0-c0e65330a692	t	t	0	\N	2025-11-22 04:41:43.947195+00	2025-11-22 04:41:43.947195+00	2025-11-22 04:41:43.947195+00
f56cc0bc-1765-4334-9594-73dcc9deac8e	leonardo.mateo.1966@grupo.org	$2b$12$HNrSc2Ft3LTmiCfdP7kA3u72tlQV2KAn9WxcXQqGUT/yH5Ty3XHlq	patient	f56cc0bc-1765-4334-9594-73dcc9deac8e	t	t	0	\N	2025-11-22 04:41:43.950052+00	2025-11-22 04:41:43.950052+00	2025-11-22 04:41:43.950052+00
1c861cbf-991d-4820-b3f0-98538fb0d454	antonio.sosa.1959@feliciano-ramirez.com	$2b$12$GbWK2QG..RrUMulPPc1dWuw2Z2RllUx4iEIGsOE2nNL8m0ulOWe8a	patient	1c861cbf-991d-4820-b3f0-98538fb0d454	t	t	0	\N	2025-11-22 04:41:43.9529+00	2025-11-22 04:41:43.9529+00	2025-11-22 04:41:43.9529+00
d1ec4069-41a0-4317-a6c6-84914d108257	jaqueline.negrete.1973@grupo.com	$2b$12$nYU6ePNimNXlpFtsrAR7ROm6IVj80r2J8BqORk/ZDBMyBVbNdkni.	patient	d1ec4069-41a0-4317-a6c6-84914d108257	t	t	0	\N	2025-11-22 04:41:43.956024+00	2025-11-22 04:41:43.956024+00	2025-11-22 04:41:43.956024+00
0deef39b-719e-4f3a-a84f-2072803b2548	zoe.gaona.1953@cornejo.com	$2b$12$Nm8RIAK4Br0Y5wbFTOxgqOIh9jMJwv81lSvKhEfE6RIGlUQN9s/S2	patient	0deef39b-719e-4f3a-a84f-2072803b2548	t	t	0	\N	2025-11-22 04:41:43.960838+00	2025-11-22 04:41:43.960838+00	2025-11-22 04:41:43.960838+00
d911f0a5-9268-4eb4-87e9-508d7c99b753	vanesa.nava.1996@jaramillo.net	$2b$12$siofu24h27aKq6oI2vh.ye845qOjfKLUbYzH42F.ByNh66Fe5sJim	patient	d911f0a5-9268-4eb4-87e9-508d7c99b753	t	t	0	\N	2025-11-22 04:41:43.965747+00	2025-11-22 04:41:43.965747+00	2025-11-22 04:41:43.965747+00
c3e065c2-c0a9-440f-98f3-1c5463949056	diana.ceja.1969@solano.com	$2b$12$nn3D8H9DkyTussgQotKX5.jRQ8geSB.OzlVqYbPhtqN6Ylly4s/Mu	patient	c3e065c2-c0a9-440f-98f3-1c5463949056	t	t	0	\N	2025-11-22 04:41:43.968667+00	2025-11-22 04:41:43.968667+00	2025-11-22 04:41:43.968667+00
b2eef54b-21a7-45ec-a693-bc60f1d6e293	emilio.delarosa.1946@laboratorios.com	$2b$12$6QJqUoD/wKPbFty4DX8bKeVHqkMIPdjXjK5y6lc43AobTExJHU3u.	patient	b2eef54b-21a7-45ec-a693-bc60f1d6e293	t	t	0	\N	2025-11-22 04:41:43.971419+00	2025-11-22 04:41:43.971419+00	2025-11-22 04:41:43.971419+00
3854a76e-ee29-4976-b630-1d7e18fb9887	monica.delarosa.1978@valdivia.biz	$2b$12$Ffn/IRgtxXta91yikWJmYOP21dYCSW6QOlhWGmzXrehiFAb1lBeN2	patient	3854a76e-ee29-4976-b630-1d7e18fb9887	t	t	0	\N	2025-11-22 04:41:43.975657+00	2025-11-22 04:41:43.975657+00	2025-11-22 04:41:43.975657+00
6b2e25e9-ebcb-4150-a594-c5742cd42121	reynaldo.garcia.1966@laboratorios.net	$2b$12$a6nNNTKRkvh0LU06UP6Q/exYOsviW9k4g2Gs35uKxv/MF6fScaUBq	patient	6b2e25e9-ebcb-4150-a594-c5742cd42121	t	t	0	\N	2025-11-22 04:41:43.979829+00	2025-11-22 04:41:43.979829+00	2025-11-22 04:41:43.979829+00
cc38cb13-51a5-4539-99c2-894cd2b207f1	geronimo.pedraza.1972@proyectos.info	$2b$12$oYSLNWsghyO4kX1PIzDdUu2H6ZV.hwquEjwD1WvClmw.krS/Zr4k.	patient	cc38cb13-51a5-4539-99c2-894cd2b207f1	t	t	0	\N	2025-11-22 04:41:43.983756+00	2025-11-22 04:41:43.983756+00	2025-11-22 04:41:43.983756+00
6af409b5-c8b8-4664-97cd-d419eedcc932	abelardo.barraza.1981@amador-nieves.com	$2b$12$JhAXTmaBPsQEIdNX1UUg0O4tZWPssdYivLBtr53SYoMNdPOy0w3MS	patient	6af409b5-c8b8-4664-97cd-d419eedcc932	t	t	0	\N	2025-11-22 04:41:43.987056+00	2025-11-22 04:41:43.987056+00	2025-11-22 04:41:43.987056+00
227a2c03-dfd1-4e03-9c04-daaf74fc68bd	noelia.toro.1948@rodrigez-casas.info	$2b$12$l3Nr5Ic52YtCJW4TeGGS1OetzCTecCpZwyXQUTBLQueJmEALCBd62	patient	227a2c03-dfd1-4e03-9c04-daaf74fc68bd	t	t	0	\N	2025-11-22 04:41:43.989983+00	2025-11-22 04:41:43.989983+00	2025-11-22 04:41:43.989983+00
bc6e7a77-d709-401c-bea7-82715eeb1a29	ines.tellez.2001@club.com	$2b$12$BdeM83HZ92n1GfXcHzsaKOxaYccW.S.JKXpOy54bAuVXUjbgDJvAi	patient	bc6e7a77-d709-401c-bea7-82715eeb1a29	t	t	0	\N	2025-11-22 04:41:43.994282+00	2025-11-22 04:41:43.994282+00	2025-11-22 04:41:43.994282+00
d54d7239-e49a-4185-8875-4f71af08b789	hector.maldonado.1974@despacho.com	$2b$12$.k3swDXTZe8jO/iUasjAduK7wIw0IgOnATG3HFdp8inqer8Sps6hi	patient	d54d7239-e49a-4185-8875-4f71af08b789	t	t	0	\N	2025-11-22 04:41:43.998791+00	2025-11-22 04:41:43.998791+00	2025-11-22 04:41:43.998791+00
8370857e-7e69-43a6-be63-78fc270c5fd5	jonas.segura.1969@proyectos.com	$2b$12$.GAtP7oC44HmbwyHf72TUebo4UlJ/WpuRxhcX28mskT1sz6J64QP.	patient	8370857e-7e69-43a6-be63-78fc270c5fd5	t	t	0	\N	2025-11-22 04:41:44.001787+00	2025-11-22 04:41:44.001787+00	2025-11-22 04:41:44.001787+00
e8813bf8-7bbb-4370-a181-880c0c959aa1	joseluis.gomez.2003@corporacin.info	$2b$12$tfQgAZxxq0MBM2DA8yxyWePwbQzdKSTRMpjJIpEKm/8bnVRqFSb32	patient	e8813bf8-7bbb-4370-a181-880c0c959aa1	t	t	0	\N	2025-11-22 04:41:44.004806+00	2025-11-22 04:41:44.004806+00	2025-11-22 04:41:44.004806+00
517958b1-f860-4a42-965b-15a796055981	angela.montanez.1974@proyectos.com	$2b$12$pHNxsjJQeXM/LXIbPNNRo.kAshDPu65wlhkZtHn74gVwYc1R6I3YC	patient	517958b1-f860-4a42-965b-15a796055981	t	t	0	\N	2025-11-22 04:41:44.008192+00	2025-11-22 04:41:44.008192+00	2025-11-22 04:41:44.008192+00
44e4c099-cf6e-4926-85f1-ab5cb34c59a1	leonor.olivera.1953@grupo.com	$2b$12$WBT6Ul/vbW2o/fWen/VfjOCqK.a6/.DldT.ETKDGBgEDlaNlDMYfi	patient	44e4c099-cf6e-4926-85f1-ab5cb34c59a1	t	t	0	\N	2025-11-22 04:41:44.011374+00	2025-11-22 04:41:44.011374+00	2025-11-22 04:41:44.011374+00
a0c3c815-c664-4931-927f-e4109a545603	gabino.aguirre.1951@cabrera.com	$2b$12$f06yYKY5F5VT0i6iVxzwLug5uILs8EtLcfDTPKlsenY0OYxnNGBM.	patient	a0c3c815-c664-4931-927f-e4109a545603	t	t	0	\N	2025-11-22 04:41:44.018759+00	2025-11-22 04:41:44.018759+00	2025-11-22 04:41:44.018759+00
5c1862f6-f802-41ae-a6fb-87dbc5555fb3	judith.aleman.1976@longoria-tellez.com	$2b$12$LbFs1z5cLlj5EMgfG1TZrOMJl5FCFaQRMFP2MiLRf2NHzwA0jvmh2	patient	5c1862f6-f802-41ae-a6fb-87dbc5555fb3	t	t	0	\N	2025-11-22 04:41:44.022994+00	2025-11-22 04:41:44.022994+00	2025-11-22 04:41:44.022994+00
11d31cb4-1dfb-479e-9329-8b8b35920b98	oswaldo.fuentes.1989@escobedo.info	$2b$12$mUoccHdmU56Y9Uism/cZNuw2C61NIB703OLUhFnzQ6ZafaoWa2.6u	patient	11d31cb4-1dfb-479e-9329-8b8b35920b98	t	t	0	\N	2025-11-22 04:41:44.027376+00	2025-11-22 04:41:44.027376+00	2025-11-22 04:41:44.027376+00
\.


--
-- Name: allergies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.allergies_id_seq', 1, false);


--
-- Name: blood_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.blood_types_id_seq', 8, true);


--
-- Name: cms_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.cms_permissions_id_seq', 6, true);


--
-- Name: cms_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.cms_roles_id_seq', 2, true);


--
-- Name: cms_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.cms_users_id_seq', 2, true);


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.countries_id_seq', 4, true);


--
-- Name: email_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.email_types_id_seq', 12, true);


--
-- Name: genders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.genders_id_seq', 8, true);


--
-- Name: institution_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.institution_types_id_seq', 11, true);


--
-- Name: medical_conditions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.medical_conditions_id_seq', 1, false);


--
-- Name: medications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.medications_id_seq', 1, false);


--
-- Name: phone_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.phone_types_id_seq', 12, true);


--
-- Name: regions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.regions_id_seq', 33, true);


--
-- Name: sexes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.sexes_id_seq', 3, true);


--
-- Name: specialty_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.specialty_categories_id_seq', 10, true);


--
-- Name: system_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: predictHealth_user
--

SELECT pg_catalog.setval('public.system_settings_id_seq', 7, true);


--
-- Name: addresses addresses_entity_type_entity_id_is_primary_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_entity_type_entity_id_is_primary_key UNIQUE (entity_type, entity_id, is_primary) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: allergies allergies_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.allergies
    ADD CONSTRAINT allergies_name_key UNIQUE (name);


--
-- Name: allergies allergies_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.allergies
    ADD CONSTRAINT allergies_pkey PRIMARY KEY (id);


--
-- Name: blood_types blood_types_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.blood_types
    ADD CONSTRAINT blood_types_name_key UNIQUE (name);


--
-- Name: blood_types blood_types_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.blood_types
    ADD CONSTRAINT blood_types_pkey PRIMARY KEY (id);


--
-- Name: cms_permissions cms_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_permissions
    ADD CONSTRAINT cms_permissions_pkey PRIMARY KEY (id);


--
-- Name: cms_permissions cms_permissions_resource_action_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_permissions
    ADD CONSTRAINT cms_permissions_resource_action_key UNIQUE (resource, action);


--
-- Name: cms_role_permissions cms_role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_role_permissions
    ADD CONSTRAINT cms_role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: cms_roles cms_roles_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_roles
    ADD CONSTRAINT cms_roles_name_key UNIQUE (name);


--
-- Name: cms_roles cms_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_roles
    ADD CONSTRAINT cms_roles_pkey PRIMARY KEY (id);


--
-- Name: cms_users cms_users_email_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_users
    ADD CONSTRAINT cms_users_email_key UNIQUE (email);


--
-- Name: cms_users cms_users_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_users
    ADD CONSTRAINT cms_users_pkey PRIMARY KEY (id);


--
-- Name: countries countries_iso_code_2_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_iso_code_2_key UNIQUE (iso_code_2);


--
-- Name: countries countries_iso_code_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_iso_code_key UNIQUE (iso_code);


--
-- Name: countries countries_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_name_key UNIQUE (name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: doctor_specialties doctor_specialties_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctor_specialties
    ADD CONSTRAINT doctor_specialties_name_key UNIQUE (name);


--
-- Name: doctor_specialties doctor_specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctor_specialties
    ADD CONSTRAINT doctor_specialties_pkey PRIMARY KEY (id);


--
-- Name: doctors doctors_medical_license_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_medical_license_key UNIQUE (medical_license);


--
-- Name: doctors doctors_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (id);


--
-- Name: email_types email_types_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.email_types
    ADD CONSTRAINT email_types_name_key UNIQUE (name);


--
-- Name: email_types email_types_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.email_types
    ADD CONSTRAINT email_types_pkey PRIMARY KEY (id);


--
-- Name: emails emails_entity_type_entity_id_is_primary_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_entity_type_entity_id_is_primary_key UNIQUE (entity_type, entity_id, is_primary) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: genders genders_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.genders
    ADD CONSTRAINT genders_name_key UNIQUE (name);


--
-- Name: genders genders_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.genders
    ADD CONSTRAINT genders_pkey PRIMARY KEY (id);


--
-- Name: health_profiles health_profiles_patient_id_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.health_profiles
    ADD CONSTRAINT health_profiles_patient_id_key UNIQUE (patient_id);


--
-- Name: health_profiles health_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.health_profiles
    ADD CONSTRAINT health_profiles_pkey PRIMARY KEY (id);


--
-- Name: institution_types institution_types_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.institution_types
    ADD CONSTRAINT institution_types_name_key UNIQUE (name);


--
-- Name: institution_types institution_types_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.institution_types
    ADD CONSTRAINT institution_types_pkey PRIMARY KEY (id);


--
-- Name: medical_conditions medical_conditions_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medical_conditions
    ADD CONSTRAINT medical_conditions_name_key UNIQUE (name);


--
-- Name: medical_conditions medical_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medical_conditions
    ADD CONSTRAINT medical_conditions_pkey PRIMARY KEY (id);


--
-- Name: medical_institutions medical_institutions_license_number_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medical_institutions
    ADD CONSTRAINT medical_institutions_license_number_key UNIQUE (license_number);


--
-- Name: medical_institutions medical_institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medical_institutions
    ADD CONSTRAINT medical_institutions_pkey PRIMARY KEY (id);


--
-- Name: medications medications_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT medications_name_key UNIQUE (name);


--
-- Name: medications medications_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medications
    ADD CONSTRAINT medications_pkey PRIMARY KEY (id);


--
-- Name: patient_allergies patient_allergies_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_allergies
    ADD CONSTRAINT patient_allergies_pkey PRIMARY KEY (patient_id, allergy_id);


--
-- Name: patient_conditions patient_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_conditions
    ADD CONSTRAINT patient_conditions_pkey PRIMARY KEY (patient_id, condition_id);


--
-- Name: patient_family_history patient_family_history_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_family_history
    ADD CONSTRAINT patient_family_history_pkey PRIMARY KEY (patient_id, condition_id);


--
-- Name: patient_medications patient_medications_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_medications
    ADD CONSTRAINT patient_medications_pkey PRIMARY KEY (patient_id, medication_id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: phone_types phone_types_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.phone_types
    ADD CONSTRAINT phone_types_name_key UNIQUE (name);


--
-- Name: phone_types phone_types_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.phone_types
    ADD CONSTRAINT phone_types_pkey PRIMARY KEY (id);


--
-- Name: phones phones_entity_type_entity_id_is_primary_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.phones
    ADD CONSTRAINT phones_entity_type_entity_id_is_primary_key UNIQUE (entity_type, entity_id, is_primary);


--
-- Name: phones phones_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.phones
    ADD CONSTRAINT phones_pkey PRIMARY KEY (id);


--
-- Name: regions regions_country_id_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_country_id_name_key UNIQUE (country_id, name);


--
-- Name: regions regions_country_id_region_code_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_country_id_region_code_key UNIQUE (country_id, region_code);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: sexes sexes_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.sexes
    ADD CONSTRAINT sexes_name_key UNIQUE (name);


--
-- Name: sexes sexes_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.sexes
    ADD CONSTRAINT sexes_pkey PRIMARY KEY (id);


--
-- Name: specialty_categories specialty_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.specialty_categories
    ADD CONSTRAINT specialty_categories_name_key UNIQUE (name);


--
-- Name: specialty_categories specialty_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.specialty_categories
    ADD CONSTRAINT specialty_categories_pkey PRIMARY KEY (id);


--
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (id);


--
-- Name: system_settings system_settings_setting_key_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_setting_key_key UNIQUE (setting_key);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_addresses_city; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_addresses_city ON public.addresses USING btree (city);


--
-- Name: idx_addresses_coordinates; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_addresses_coordinates ON public.addresses USING btree (latitude, longitude) WHERE ((latitude IS NOT NULL) AND (longitude IS NOT NULL));


--
-- Name: idx_addresses_country; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_addresses_country ON public.addresses USING btree (country_id);


--
-- Name: idx_addresses_entity; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_addresses_entity ON public.addresses USING btree (entity_type, entity_id);


--
-- Name: idx_addresses_postal; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_addresses_postal ON public.addresses USING btree (postal_code);


--
-- Name: idx_addresses_primary; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_addresses_primary ON public.addresses USING btree (entity_type, entity_id, is_primary) WHERE (is_primary = true);


--
-- Name: idx_addresses_region; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_addresses_region ON public.addresses USING btree (region_id);


--
-- Name: idx_cms_role_permissions_composite; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_cms_role_permissions_composite ON public.cms_role_permissions USING btree (role_id, permission_id);


--
-- Name: idx_cms_users_email; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_cms_users_email ON public.cms_users USING btree (email);


--
-- Name: idx_cms_users_role; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_cms_users_role ON public.cms_users USING btree (role_id) WHERE (is_active = true);


--
-- Name: idx_doctors_consultation_fee; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_doctors_consultation_fee ON public.doctors USING btree (consultation_fee) WHERE (is_active = true);


--
-- Name: idx_doctors_institution_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_doctors_institution_id ON public.doctors USING btree (institution_id) WHERE (is_active = true);


--
-- Name: idx_doctors_specialty_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_doctors_specialty_id ON public.doctors USING btree (specialty_id) WHERE (is_active = true);


--
-- Name: idx_emails_address; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_emails_address ON public.emails USING btree (email_address);


--
-- Name: idx_emails_entity; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_emails_entity ON public.emails USING btree (entity_type, entity_id);


--
-- Name: idx_emails_primary; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_emails_primary ON public.emails USING btree (entity_type, entity_id, is_primary) WHERE (is_primary = true);


--
-- Name: idx_emails_type; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_emails_type ON public.emails USING btree (email_type_id);


--
-- Name: idx_emails_verification; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_emails_verification ON public.emails USING btree (is_verified, verification_expires_at);


--
-- Name: idx_health_profiles_patient_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_health_profiles_patient_id ON public.health_profiles USING btree (patient_id);


--
-- Name: idx_medical_institutions_type; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_medical_institutions_type ON public.medical_institutions USING btree (institution_type_id) WHERE (is_active = true);


--
-- Name: idx_patient_allergies_allergy_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_allergies_allergy_id ON public.patient_allergies USING btree (allergy_id);


--
-- Name: idx_patient_allergies_patient_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_allergies_patient_id ON public.patient_allergies USING btree (patient_id);


--
-- Name: idx_patient_conditions_condition_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_conditions_condition_id ON public.patient_conditions USING btree (condition_id);


--
-- Name: idx_patient_conditions_patient_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_conditions_patient_id ON public.patient_conditions USING btree (patient_id);


--
-- Name: idx_patient_family_history_condition_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_family_history_condition_id ON public.patient_family_history USING btree (condition_id);


--
-- Name: idx_patient_family_history_patient_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_family_history_patient_id ON public.patient_family_history USING btree (patient_id);


--
-- Name: idx_patient_medications_medication_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_medications_medication_id ON public.patient_medications USING btree (medication_id);


--
-- Name: idx_patient_medications_patient_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patient_medications_patient_id ON public.patient_medications USING btree (patient_id);


--
-- Name: idx_patients_created_at; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patients_created_at ON public.patients USING btree (created_at) WHERE (is_active = true);


--
-- Name: idx_patients_doctor_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patients_doctor_id ON public.patients USING btree (doctor_id) WHERE (is_active = true);


--
-- Name: idx_patients_institution_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_patients_institution_id ON public.patients USING btree (institution_id) WHERE (is_active = true);


--
-- Name: idx_phones_entity; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_phones_entity ON public.phones USING btree (entity_type, entity_id);


--
-- Name: idx_phones_number; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_phones_number ON public.phones USING btree (phone_number);


--
-- Name: idx_phones_primary; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_phones_primary ON public.phones USING btree (entity_type, entity_id, is_primary) WHERE (is_primary = true);


--
-- Name: idx_phones_type; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_phones_type ON public.phones USING btree (phone_type_id);


--
-- Name: idx_regions_code; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_regions_code ON public.regions USING btree (region_code);


--
-- Name: idx_regions_country; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_regions_country ON public.regions USING btree (country_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_reference_id; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_users_reference_id ON public.users USING btree (reference_id, user_type);


--
-- Name: idx_users_user_type; Type: INDEX; Schema: public; Owner: predictHealth_user
--

CREATE INDEX idx_users_user_type ON public.users USING btree (user_type) WHERE (is_active = true);


--
-- Name: vw_patient_demographics _RETURN; Type: RULE; Schema: public; Owner: predictHealth_user
--

CREATE OR REPLACE VIEW public.vw_patient_demographics AS
 SELECT p.id,
    p.first_name,
    p.last_name,
    ( SELECT emails.email_address
           FROM public.emails
          WHERE (((emails.entity_type)::text = 'patient'::text) AND (emails.entity_id = p.id) AND (emails.is_primary = true))
         LIMIT 1) AS email,
    p.date_of_birth,
    EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (p.date_of_birth)::timestamp with time zone)) AS age,
    s.display_name AS biological_sex,
    g.display_name AS gender_identity,
    p.is_active,
    p.is_verified,
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    mi.name AS institution_name,
        CASE
            WHEN (d.institution_id = p.institution_id) THEN 'Valid'::text
            ELSE 'Invalid - Doctor not in institution'::text
        END AS relationship_status,
    bt.name AS blood_type,
    string_agg(DISTINCT (mc.name)::text, ', '::text) AS diagnosed_conditions,
    ( SELECT phones.phone_number
           FROM public.phones
          WHERE (((phones.entity_type)::text = 'patient'::text) AND (phones.entity_id = p.id) AND (phones.is_primary = true))
         LIMIT 1) AS primary_phone,
    ( SELECT phones.phone_number
           FROM public.phones
          WHERE (((phones.entity_type)::text = 'emergency_contact'::text) AND (phones.entity_id = p.id))
         LIMIT 1) AS emergency_phone,
    NULL::text AS patient_address,
    NULL::text AS patient_city,
    r.name AS institution_region,
    c.name AS institution_country,
    p.created_at
   FROM (((((((((((public.patients p
     LEFT JOIN public.sexes s ON ((p.sex_id = s.id)))
     LEFT JOIN public.genders g ON ((p.gender_id = g.id)))
     JOIN public.doctors d ON ((p.doctor_id = d.id)))
     JOIN public.medical_institutions mi ON ((p.institution_id = mi.id)))
     LEFT JOIN public.addresses addr ON ((((addr.entity_type)::text = 'institution'::text) AND (addr.entity_id = mi.id) AND (addr.is_primary = true))))
     LEFT JOIN public.regions r ON ((addr.region_id = r.id)))
     LEFT JOIN public.countries c ON ((addr.country_id = c.id)))
     LEFT JOIN public.health_profiles hp ON ((p.id = hp.patient_id)))
     LEFT JOIN public.blood_types bt ON ((hp.blood_type_id = bt.id)))
     LEFT JOIN public.patient_conditions pc ON ((p.id = pc.patient_id)))
     LEFT JOIN public.medical_conditions mc ON ((pc.condition_id = mc.id)))
  WHERE (p.is_active = true)
  GROUP BY p.id, p.first_name, p.last_name, p.date_of_birth, s.display_name, g.display_name, p.is_active, p.is_verified, d.first_name, d.last_name, d.institution_id, mi.name, bt.name, r.name, c.name, p.created_at;


--
-- Name: addresses set_timestamp_addresses; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_addresses BEFORE UPDATE ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: allergies set_timestamp_allergies; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_allergies BEFORE UPDATE ON public.allergies FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: cms_users set_timestamp_cms_users; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_cms_users BEFORE UPDATE ON public.cms_users FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: countries set_timestamp_countries; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_countries BEFORE UPDATE ON public.countries FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: doctors set_timestamp_doctors; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_doctors BEFORE UPDATE ON public.doctors FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: emails set_timestamp_emails; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_emails BEFORE UPDATE ON public.emails FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: health_profiles set_timestamp_health_profiles; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_health_profiles BEFORE UPDATE ON public.health_profiles FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: medical_conditions set_timestamp_medical_conditions; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_medical_conditions BEFORE UPDATE ON public.medical_conditions FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: medical_institutions set_timestamp_medical_institutions; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_medical_institutions BEFORE UPDATE ON public.medical_institutions FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: medications set_timestamp_medications; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_medications BEFORE UPDATE ON public.medications FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: patients set_timestamp_patients; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_patients BEFORE UPDATE ON public.patients FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: phones set_timestamp_phones; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_phones BEFORE UPDATE ON public.phones FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: regions set_timestamp_regions; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_regions BEFORE UPDATE ON public.regions FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: users set_timestamp_users; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: users trg_validate_user_reference; Type: TRIGGER; Schema: public; Owner: predictHealth_user
--

CREATE TRIGGER trg_validate_user_reference BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.validate_user_reference();


--
-- Name: addresses addresses_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE SET NULL;


--
-- Name: addresses addresses_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE SET NULL;


--
-- Name: cms_role_permissions cms_role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_role_permissions
    ADD CONSTRAINT cms_role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.cms_permissions(id) ON DELETE CASCADE;


--
-- Name: cms_role_permissions cms_role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_role_permissions
    ADD CONSTRAINT cms_role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.cms_roles(id) ON DELETE CASCADE;


--
-- Name: cms_users cms_users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.cms_users
    ADD CONSTRAINT cms_users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.cms_roles(id);


--
-- Name: doctor_specialties doctor_specialties_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctor_specialties
    ADD CONSTRAINT doctor_specialties_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.specialty_categories(id);


--
-- Name: doctors doctors_gender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_gender_id_fkey FOREIGN KEY (gender_id) REFERENCES public.genders(id);


--
-- Name: doctors doctors_institution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_institution_id_fkey FOREIGN KEY (institution_id) REFERENCES public.medical_institutions(id) ON DELETE RESTRICT;


--
-- Name: doctors doctors_sex_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_sex_id_fkey FOREIGN KEY (sex_id) REFERENCES public.sexes(id);


--
-- Name: doctors doctors_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT doctors_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.doctor_specialties(id) ON DELETE SET NULL;


--
-- Name: emails emails_email_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_email_type_id_fkey FOREIGN KEY (email_type_id) REFERENCES public.email_types(id) ON DELETE SET NULL;


--
-- Name: health_profiles health_profiles_blood_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.health_profiles
    ADD CONSTRAINT health_profiles_blood_type_id_fkey FOREIGN KEY (blood_type_id) REFERENCES public.blood_types(id);


--
-- Name: health_profiles health_profiles_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.health_profiles
    ADD CONSTRAINT health_profiles_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: medical_institutions medical_institutions_institution_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.medical_institutions
    ADD CONSTRAINT medical_institutions_institution_type_id_fkey FOREIGN KEY (institution_type_id) REFERENCES public.institution_types(id);


--
-- Name: patient_allergies patient_allergies_allergy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_allergies
    ADD CONSTRAINT patient_allergies_allergy_id_fkey FOREIGN KEY (allergy_id) REFERENCES public.allergies(id) ON DELETE RESTRICT;


--
-- Name: patient_allergies patient_allergies_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_allergies
    ADD CONSTRAINT patient_allergies_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: patient_conditions patient_conditions_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_conditions
    ADD CONSTRAINT patient_conditions_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.medical_conditions(id) ON DELETE RESTRICT;


--
-- Name: patient_conditions patient_conditions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_conditions
    ADD CONSTRAINT patient_conditions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: patient_family_history patient_family_history_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_family_history
    ADD CONSTRAINT patient_family_history_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.medical_conditions(id) ON DELETE RESTRICT;


--
-- Name: patient_family_history patient_family_history_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_family_history
    ADD CONSTRAINT patient_family_history_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: patient_medications patient_medications_medication_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_medications
    ADD CONSTRAINT patient_medications_medication_id_fkey FOREIGN KEY (medication_id) REFERENCES public.medications(id) ON DELETE RESTRICT;


--
-- Name: patient_medications patient_medications_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patient_medications
    ADD CONSTRAINT patient_medications_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id) ON DELETE CASCADE;


--
-- Name: patients patients_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id) ON DELETE RESTRICT;


--
-- Name: patients patients_gender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_gender_id_fkey FOREIGN KEY (gender_id) REFERENCES public.genders(id);


--
-- Name: patients patients_institution_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_institution_id_fkey FOREIGN KEY (institution_id) REFERENCES public.medical_institutions(id) ON DELETE RESTRICT;


--
-- Name: patients patients_sex_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_sex_id_fkey FOREIGN KEY (sex_id) REFERENCES public.sexes(id);


--
-- Name: phones phones_phone_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.phones
    ADD CONSTRAINT phones_phone_type_id_fkey FOREIGN KEY (phone_type_id) REFERENCES public.phone_types(id) ON DELETE SET NULL;


--
-- Name: regions regions_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE;


--
-- Name: specialty_categories specialty_categories_parent_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: predictHealth_user
--

ALTER TABLE ONLY public.specialty_categories
    ADD CONSTRAINT specialty_categories_parent_category_id_fkey FOREIGN KEY (parent_category_id) REFERENCES public.specialty_categories(id);


--
-- Name: system_settings cms_admin_only_policy; Type: POLICY; Schema: public; Owner: predictHealth_user
--

CREATE POLICY cms_admin_only_policy ON public.system_settings USING ((EXISTS ( SELECT 1
   FROM public.cms_users cu
  WHERE (((cu.email)::text = current_setting('app.current_user_email'::text, true)) AND ((cu.user_type)::text = 'admin'::text) AND (cu.is_active = true)))));


--
-- Name: system_settings; Type: ROW SECURITY; Schema: public; Owner: predictHealth_user
--

ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict D0b9dh8J5EbIaFqFl6CKL0UrXXqnwWTjJjecMRnxq2Fc6d0esh3bkIBoCxD86a9

