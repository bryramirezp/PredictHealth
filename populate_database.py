import csv
import uuid
import random
import unicodedata
from faker import Faker
import bcrypt
from datetime import datetime, timedelta
import os

# Import bcrypt for password hashing
def generar_hash(password: str) -> str:
    """Generate bcrypt hash for password"""
    password_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode('utf-8')

# Initialize Faker with Mexican Spanish locale
fake = Faker('es_MX')

# Lists for random selection
INSTITUTION_TYPES = ['hospital', 'preventive_clinic', 'health_center']
SPECIALTIES = ['Cardiology', 'Internal Medicine', 'Endocrinology', 'Family Medicine', 'Emergency Medicine', 
               'General Medicine', 'Diabetes Management', 'Preventive Medicine']
GENDERS = ['male', 'female']
BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
STATES = ['Ciudad de México', 'Nuevo León', 'Jalisco', 'Guanajuato', 'México', 'Michoacán', 
         'Morelos', 'Nayarit', 'Sinaloa', 'Sonora', 'Veracruz', 'Puebla', 'Querétaro', 
         'Quintana Roo', 'San Luis Potosí', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 
         'Yucatán', 'Zacatecas']

MEDICAL_CONDITIONS = [
    'Hypertension', 'Diabetes Mellitus Type 2', 'High Cholesterol', 'Stroke History', 
    'Heart Disease History', 'Asthma', 'Chronic Obstructive Pulmonary Disease', 
    'Depression', 'Anxiety Disorder', 'Osteoarthritis', 'Rheumatoid Arthritis', 
    'Hypothyroidism', 'Hyperthyroidism', 'Chronic Kidney Disease', 
    'Gastroesophageal Reflux Disease', 'Irritable Bowel Syndrome', 'Migraine', 
    'Obesity', 'Sleep Apnea', 'Atrial Fibrillation'
]

MEDICATIONS = [
    'Lisinopril', 'Atorvastatin', 'Multivitamin', 'Metformin', 'Omeprazole', 
    'Aspirin', 'Losartan', 'Simvastatin', 'Levothyroxine', 'Prednisone', 
    'Warfarin', 'Insulin Glargine', 'Albuterol', 'Sertraline', 'Ibuprofen', 
    'Furosemide', 'Amlodipine', 'Gabapentin', 'Pantoprazole', 'Diazepam'
]

ALLERGIES = [
    'Penicillin', 'None reported', 'Sulfa Drugs', 'NSAIDs', 'Aspirin', 
    'Latex', 'Shellfish', 'Peanuts', 'Eggs', 'Milk', 'Wheat', 'Soy', 
    'Tree Nuts', 'Fish', 'Iodine', 'Local Anesthetics', 'Codeine', 
    'Tetracycline', 'Quinolones', 'ACE Inhibitors'
]

# Global function for normalizing text (emails and names)
def normalize_text(text):
    # Remove accents
    text = unicodedata.normalize('NFD', text)
    text = ''.join(c for c in text if unicodedata.category(c) != 'Mn')
    # Replace special characters with hyphens
    text = text.replace(' ', '-').replace(',', '-').replace('.', '-').replace('ñ', 'n').replace('Ñ', 'N')
    # Remove multiple consecutive hyphens
    while '--' in text:
        text = text.replace('--', '-')
    # Remove trailing hyphens
    text = text.strip('-')
    return text.lower()

def normalize_email(text):
    # Remove accents and special characters for email
    text = unicodedata.normalize('NFD', text)
    text = ''.join(c for c in text if unicodedata.category(c) != 'Mn' and c.isalnum() or c in ['.', '-', '_', '@'])
    # Replace problematic characters
    text = text.replace(' ', '.').replace('ñ', 'n').replace('Ñ', 'N')
    return text.lower()

def normalize_name(text):
    # Remove accents but keep original characters for display
    text = unicodedata.normalize('NFD', text)
    text = ''.join(c for c in text if unicodedata.category(c) != 'Mn')
    return text

def generate_institutions(num_institutions=100):
    """Generate medical institutions with related data"""
    institutions = []
    
    for i in range(num_institutions):
        institution_id = str(uuid.uuid4())
        institution_type = random.choice(INSTITUTION_TYPES)
        
        # Generate institution data
        name = fake.company()
        # Clean up name for URL and email: remove spaces, commas, accents, and special characters
        
        clean_name = normalize_text(name)
        website = f"https://{clean_name}.predicthealth.com"
        license_number = f"LIC-MX-{institution_type.upper()[:4]}-{i+101:03d}"
        
        institutions.append({
            'id': institution_id,
            'name': name,
            'institution_type': institution_type,
            'website': website,
            'license_number': license_number,
            'is_active': True,
            'is_verified': True
        })
    
    return institutions

def generate_institution_contacts(institutions):
    """Generate emails, phones, and addresses for institutions"""
    contacts = {
        'emails': [],
        'phones': [],
        'addresses': []
    }
    
    for institution in institutions:
        # Generate email
        domain = institution['website'].replace('https://', '').replace('http://', '')
        email = f"contacto@{domain}"
        
        contacts['emails'].append({
            'entity_type': 'institution',
            'entity_id': institution['id'],
            'email_address': email,
            'is_primary': True,
            'is_verified': True
        })
        
        # Generate phone (format: exactly 10 digits for local numbers)
        area_code = random.choice(['55', '81', '33', '477', '322'])
        # Ensure we have exactly 8 more digits to make 10 total (2-digit area code + 8 digits = 10)
        phone_suffix = f"{random.randint(10000000, 99999999)}"
        phone_number = f"{area_code}{phone_suffix}"
        
        contacts['phones'].append({
            'entity_type': 'institution',
            'entity_id': institution['id'],
            'phone_number': phone_number,
            'country_code': '+52',
            'area_code': area_code,
            'is_primary': True,
            'is_verified': True
        })
        
        # Generate address
        state = random.choice(STATES)
        
        contacts['addresses'].append({
            'entity_type': 'institution',
            'entity_id': institution['id'],
            'address_type': 'primary',
            'street_address': fake.street_address(),
            'city': fake.city(),
            'state': state,
            'is_primary': True,
            'is_verified': True
        })
    
    return contacts

def generate_doctors(institutions, num_doctors=100):
    """Generate doctors with related data"""
    doctors = []
    
    for i in range(num_doctors):
        doctor_id = str(uuid.uuid4())
        institution = random.choice(institutions)
        specialty = random.choice(SPECIALTIES)
        gender = random.choice(GENDERS)
        
        # Generate doctor data
        first_name = fake.first_name_male() if gender == 'male' else fake.first_name_female()
        last_name = fake.last_name()
        medical_license = f"MED-MX-2024-{i+101:03d}"
        years_experience = random.randint(1, 30)
        consultation_fee = random.uniform(500.0, 2000.0)
        
        doctors.append({
            'id': doctor_id,
            'institution_id': institution['id'],
            'first_name': first_name,
            'last_name': last_name,
            'gender': gender,
            'medical_license': medical_license,
            'specialty': specialty,
            'years_experience': years_experience,
            'consultation_fee': consultation_fee,
            'is_active': True,
            'professional_status': 'active'
        })
    
    return doctors

def generate_doctor_contacts(doctors):
    """Generate emails and phones for doctors"""
    contacts = {
        'emails': [],
        'phones': []
    }
    
    for doctor in doctors:
        # Generate email
        first_name = normalize_email(doctor['first_name']).lower()
        last_name = normalize_email(doctor['last_name']).lower()
        domain = fake.domain_name()
        email = f"dr.{first_name}.{last_name}@{domain}"
        
        contacts['emails'].append({
            'entity_type': 'doctor',
            'entity_id': doctor['id'],
            'email_address': email,
            'is_primary': True,
            'is_verified': True
        })
        
        # Generate phone (format: +52-XX-XXXX-XXXX for international format)
        area_code = random.choice(['55', '81', '33', '477', '322'])
        phone_number = f"+52-{area_code}-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}"
        
        contacts['phones'].append({
            'entity_type': 'doctor',
            'entity_id': doctor['id'],
            'phone_number': phone_number,
            'country_code': '+52',
            'area_code': area_code,
            'is_primary': True,
            'is_verified': True
        })
    
    return contacts

def generate_patients(doctors, institutions, num_patients=100):
    """Generate patients with related data"""
    patients = []
    
    for i in range(num_patients):
        patient_id = str(uuid.uuid4())
        doctor = random.choice(doctors)
        institution = random.choice(institutions)
        gender = random.choice(GENDERS)
        
        # Generate patient data
        first_name = fake.first_name_male() if gender == 'male' else fake.first_name_female()
        last_name = fake.last_name()
        birth_date = fake.date_between(start_date='-80y', end_date='-18y')
        emergency_contact_name = normalize_name(fake.name())
        
        patients.append({
            'id': patient_id,
            'doctor_id': doctor['id'],
            'institution_id': institution['id'],
            'first_name': first_name,
            'last_name': last_name,
            'date_of_birth': birth_date,
            'gender': gender,
            'emergency_contact_name': emergency_contact_name,
            'is_active': True,
            'is_verified': True
        })
    
    return patients

def generate_patient_contacts(patients):
    """Generate emails and phones for patients"""
    contacts = {
        'emails': [],
        'phones': [],
        'emergency_phones': []
    }
    
    for patient in patients:
        # Generate email
        first_name = normalize_email(patient['first_name']).lower()
        last_name = normalize_email(patient['last_name']).lower()
        birth_year = patient['date_of_birth'].year
        domain = fake.domain_name()
        email = f"{first_name}.{last_name}.{birth_year}@{domain}"
        
        contacts['emails'].append({
            'entity_type': 'patient',
            'entity_id': patient['id'],
            'email_address': email,
            'is_primary': True,
            'is_verified': True
        })
        
        # Generate primary phone (format: exactly 10 digits for local numbers)
        area_code = random.choice(['55', '81', '33', '477', '322'])
        # Ensure we have exactly 8 more digits to make 10 total (2-digit area code + 8 digits = 10)
        phone_suffix = f"{random.randint(10000000, 99999999)}"
        phone_number = f"{area_code}{phone_suffix}"
        
        contacts['phones'].append({
            'entity_type': 'patient',
            'entity_id': patient['id'],
            'phone_number': phone_number,
            'country_code': '+52',
            'area_code': area_code,
            'is_primary': True,
            'is_verified': True
        })
        
        # Generate emergency contact phone (format: exactly 10 digits for local numbers)
        # Ensure we have exactly 8 more digits to make 10 total (2-digit area code + 8 digits = 10)
        emergency_phone_suffix = f"{random.randint(10000000, 99999999)}"
        emergency_phone = f"{area_code}{emergency_phone_suffix}"
        
        contacts['emergency_phones'].append({
            'entity_type': 'emergency_contact',
            'entity_id': patient['id'],
            'phone_number': emergency_phone,
            'country_code': '+52',
            'area_code': area_code,
            'is_primary': False,
            'is_verified': False
        })
    
    return contacts

def generate_health_profiles(patients):
    """Generate health profiles for patients"""
    profiles = []
    
    for patient in patients:
        blood_type = random.choice(BLOOD_TYPES)
        
        is_smoker = random.choice([True, False])
        smoking_years = random.randint(1, 30) if is_smoker else 0
        
        consumes_alcohol = random.choice([True, False])
        alcohol_frequency = random.choice(['never', 'rarely', 'occasionally', 'regularly', 'daily']) if consumes_alcohol else 'never'
        
        profiles.append({
            'patient_id': patient['id'],
            'height_cm': round(random.uniform(150.0, 200.0), 1),
            'weight_kg': round(random.uniform(50.0, 120.0), 1),
            'blood_type': blood_type,
            'is_smoker': is_smoker,
            'smoking_years': smoking_years,
            'consumes_alcohol': consumes_alcohol,
            'alcohol_frequency': alcohol_frequency,
            'physical_activity_minutes_weekly': random.randint(0, 600),
            'notes': fake.sentence()
        })
    
    return profiles

def generate_patient_medical_data(patients):
    """Generate medical conditions, medications, and allergies for patients"""
    medical_data = {
        'conditions': [],
        'family_history': [],
        'medications': [],
        'allergies': []
    }
    
    for patient in patients:
        # Randomly assign 1-3 medical conditions (using IDs 1-20 from init.sql)
        num_conditions = random.randint(1, 3)
        selected_condition_ids = random.sample(range(1, 21), min(num_conditions, 20))
        
        for condition_id in selected_condition_ids:
            diagnosis_date = fake.date_between(start_date='-10y', end_date='today')
            
            medical_data['conditions'].append({
                'patient_id': patient['id'],
                'condition_id': condition_id,
                'diagnosis_date': diagnosis_date,
                'notes': fake.sentence()
            })
            
            # 30% chance to add to family history
            if random.random() < 0.3:
                relative_type = random.choice(['Mother', 'Father', 'Sibling', 'Grandparent', 'Unspecified'])
                
                medical_data['family_history'].append({
                    'patient_id': patient['id'],
                    'condition_id': condition_id,
                    'relative_type': relative_type,
                    'notes': fake.sentence()
                })
        
        # Randomly assign 1-3 medications (using IDs 1-20 from init.sql)
        num_medications = random.randint(1, 3)
        selected_medication_ids = random.sample(range(1, 21), min(num_medications, 20))
        
        for medication_id in selected_medication_ids:
            dosage = f"{random.randint(5, 500)}{random.choice(['mg', 'mcg', 'ml'])}"
            frequency = random.choice(['daily', 'twice daily', 'three times daily', 'weekly', 'as needed'])
            
            medical_data['medications'].append({
                'patient_id': patient['id'],
                'medication_id': medication_id,
                'dosage': dosage,
                'frequency': frequency,
                'start_date': fake.date_between(start_date='-5y', end_date='today')
            })
        
        # Randomly assign 0-2 allergies (using IDs 1-20 from init.sql)
        num_allergies = random.randint(0, 2)
        if num_allergies > 0:
            selected_allergy_ids = random.sample(range(1, 21), min(num_allergies, 20))
            
            for allergy_id in selected_allergy_ids:
                # Skip ID 2 which is 'None reported' in the allergies table
                if allergy_id != 2:
                    severity = random.choice(['mild', 'moderate', 'severe'])
                    
                    medical_data['allergies'].append({
                        'patient_id': patient['id'],
                        'allergy_id': allergy_id,
                        'severity': severity,
                        'reaction_description': fake.sentence()
                    })
    
    return medical_data

def generate_users(institutions, doctors, patients):
    """Generate user accounts for all entities with passwords"""
    users = []
    
    # Generate users for institutions
    for institution in institutions:
        domain = institution['website'].replace('https://', '').replace('http://', '').replace('/', '')
        email = f"contacto@{domain}"
        password = fake.password(length=12, special_chars=True, digits=True, upper_case=True, lower_case=True)
        
        users.append({
            'id': institution['id'],
            'email': email,
            'password': password,  # Plain text for reference
            'password_hash': generar_hash(password),  # Hashed password
            'user_type': 'institution',
            'reference_id': institution['id'],
            'is_active': True,
            'is_verified': True
        })
    
    # Generate users for doctors
    for doctor in doctors:
        first_name = normalize_email(doctor['first_name']).lower()
        last_name = normalize_email(doctor['last_name']).lower()
        domain = fake.domain_name()
        email = f"dr.{first_name}.{last_name}@{domain}"
        password = fake.password(length=12, special_chars=True, digits=True, upper_case=True, lower_case=True)
        
        users.append({
            'id': doctor['id'],
            'email': email,
            'password': password,  # Plain text for reference
            'password_hash': generar_hash(password),  # Hashed password
            'user_type': 'doctor',
            'reference_id': doctor['id'],
            'is_active': True,
            'is_verified': True
        })
    
    # Generate users for patients
    for patient in patients:
        first_name = normalize_email(patient['first_name']).lower()
        last_name = normalize_email(patient['last_name']).lower()
        birth_year = patient['date_of_birth'].year
        domain = fake.domain_name()
        email = f"{first_name}.{last_name}.{birth_year}@{domain}"
        password = fake.password(length=12, special_chars=True, digits=True, upper_case=True, lower_case=True)
        
        users.append({
            'id': patient['id'],
            'email': email,
            'password': password,  # Plain text for reference
            'password_hash': generar_hash(password),  # Hashed password
            'user_type': 'patient',
            'reference_id': patient['id'],
            'is_active': True,
            'is_verified': True
        })
    
    return users

def write_sql_file(institutions, institution_contacts, doctors, doctor_contacts, patients, patient_contacts, health_profiles, medical_data, users):
    """Write all data to a SQL file"""
    with open('populate.sql', 'w', encoding='utf-8') as f:
        f.write("-- =============================================\n")
        f.write("-- POPULATE DATABASE - 100 INSTITUTIONS, DOCTORS, PATIENTS\n")
        f.write("-- Generated on: " + datetime.now().strftime('%Y-%m-%d %H:%M:%S') + "\n")
        f.write("-- =============================================\n\n")
        
        # Write reference tables first
        f.write("-- =============================================\n")
        f.write("-- REFERENCE TABLES (must be populated first)\n")
        f.write("-- =============================================\n\n")
        
        # Insert institution types
        f.write("-- Institution types\n")
        f.write("INSERT INTO institution_types (name, description, category) VALUES\n")
        f.write("    ('hospital', 'General or specialized hospital providing inpatient and outpatient care', 'healthcare'),\n")
        f.write("    ('preventive_clinic', 'Clinic focused on preventive medicine and health promotion', 'healthcare'),\n")
        f.write("    ('health_center', 'Primary healthcare center for basic medical services', 'healthcare')\n")
        f.write("ON CONFLICT (name) DO NOTHING;\n\n")
        
        # Insert email types
        f.write("-- Email types\n")
        f.write("INSERT INTO email_types (name, description) VALUES\n")
        f.write("    ('primary', 'Primary contact email address'),\n")
        f.write("    ('secondary', 'Secondary contact email address'),\n")
        f.write("    ('work', 'Work-related email address'),\n")
        f.write("    ('personal', 'Personal email address'),\n")
        f.write("    ('notification', 'Email for system notifications'),\n")
        f.write("    ('billing', 'Email for billing and financial communications')\n")
        f.write("ON CONFLICT (name) DO NOTHING;\n\n")
        
        # Insert phone types
        f.write("-- Phone types\n")
        f.write("INSERT INTO phone_types (name, description) VALUES\n")
        f.write("    ('primary', 'Primary contact number'),\n")
        f.write("    ('secondary', 'Secondary contact number'),\n")
        f.write("    ('mobile', 'Mobile phone number'),\n")
        f.write("    ('work', 'Work phone number'),\n")
        f.write("    ('home', 'Home phone number'),\n")
        f.write("    ('emergency', 'Emergency contact phone')\n")
        f.write("ON CONFLICT (name) DO NOTHING;\n\n")
        
        # Insert countries
        f.write("-- Countries\n")
        f.write("INSERT INTO countries (name, iso_code, iso_code_2, phone_code, currency_code) VALUES\n")
        f.write("    ('Mexico', 'MEX', 'MX', '+52', 'MXN'),\n")
        f.write("    ('United States', 'USA', 'US', '+1', 'USD'),\n")
        f.write("    ('Canada', 'CAN', 'CA', '+1', 'CAD')\n")
        f.write("ON CONFLICT (iso_code) DO NOTHING;\n\n")
        
        # Insert regions (Mexican states)
        f.write("-- Regions (Mexican states)\n")
        f.write("INSERT INTO regions (country_id, name, region_code, region_type) VALUES\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Ciudad de México', 'CDMX', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Nuevo León', 'NL', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Jalisco', 'JAL', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Guanajuato', 'GTO', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'México', 'MEX', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Michoacán', 'MICH', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Morelos', 'MOR', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Nayarit', 'NAY', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Sinaloa', 'SIN', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Sonora', 'SON', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Veracruz', 'VER', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Puebla', 'PUE', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Querétaro', 'QRO', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Quintana Roo', 'QROO', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'San Luis Potosí', 'SLP', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tabasco', 'TAB', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tamaulipas', 'TAMPS', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Tlaxcala', 'TLAX', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Yucatán', 'YUC', 'state'),\n")
        f.write("    ((SELECT id FROM countries WHERE iso_code = 'MEX'), 'Zacatecas', 'ZAC', 'state')\n")
        f.write("ON CONFLICT (country_id, name) DO NOTHING;\n\n")
        
        # Write institutions
        f.write("-- =============================================\n")
        f.write("-- MEDICAL INSTITUTIONS (100)\n")
        f.write("-- =============================================\n\n")
        
        for institution in institutions:
            f.write(f"INSERT INTO medical_institutions (id, name, institution_type_id, website, license_number, is_active, is_verified)\n")
            f.write(f"VALUES ('{institution['id']}', '{institution['name']}', (SELECT id FROM institution_types WHERE name = '{institution['institution_type']}'), '{institution['website']}', '{institution['license_number']}', TRUE, TRUE)\n")
            f.write("ON CONFLICT (license_number) DO NOTHING;\n\n")
        
        # Write doctors
        f.write("-- =============================================\n")
        f.write("-- DOCTORS (100)\n")
        f.write("-- =============================================\n\n")
        
        for doctor in doctors:
            f.write(f"INSERT INTO doctors (id, institution_id, first_name, last_name, sex_id, medical_license, specialty_id, years_experience, consultation_fee, is_active, professional_status)\n")
            f.write(f"VALUES ('{doctor['id']}', '{doctor['institution_id']}', '{doctor['first_name']}', '{doctor['last_name']}', (SELECT id FROM sexes WHERE name = '{doctor['gender']}'), '{doctor['medical_license']}', (SELECT id FROM doctor_specialties WHERE name = '{doctor['specialty']}'), {doctor['years_experience']}, {doctor['consultation_fee']}, TRUE, 'active')\n")
            f.write("ON CONFLICT (medical_license) DO NOTHING;\n\n")
        
        # Write patients
        f.write("-- =============================================\n")
        f.write("-- PATIENTS (100)\n")
        f.write("-- =============================================\n\n")
        
        for patient in patients:
            f.write(f"INSERT INTO patients (id, doctor_id, institution_id, first_name, last_name, date_of_birth, sex_id, gender_id, emergency_contact_name, is_active, is_verified)\n")
            f.write(f"VALUES ('{patient['id']}', '{patient['doctor_id']}', '{patient['institution_id']}', '{patient['first_name']}', '{patient['last_name']}', '{patient['date_of_birth']}', (SELECT id FROM sexes WHERE name = '{patient['gender']}'), (SELECT id FROM genders WHERE name = '{patient['gender']}'), '{patient['emergency_contact_name']}', TRUE, TRUE)\n")
            f.write("ON CONFLICT DO NOTHING;\n\n")
        
        # Write health profiles (AFTER patients to ensure foreign key constraint)
        f.write("-- =============================================\n")
        f.write("-- HEALTH PROFILES\n")
        f.write("-- =============================================\n\n")
        
        f.write("INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type_id, is_smoker, smoking_years, consumes_alcohol, alcohol_frequency, physical_activity_minutes_weekly, notes)\n")
        f.write("VALUES\n")
        
        for i, profile in enumerate(health_profiles):
            comma = "," if i < len(health_profiles) - 1 else ""
            f.write(f"    ('{profile['patient_id']}', {profile['height_cm']}, {profile['weight_kg']}, (SELECT id FROM blood_types WHERE name = '{profile['blood_type']}'), {profile['is_smoker']}, {profile['smoking_years']}, {profile['consumes_alcohol']}, '{profile['alcohol_frequency']}', {profile['physical_activity_minutes_weekly']}, '{profile['notes']}'){comma}\n")
        
        f.write("ON CONFLICT (patient_id) DO NOTHING;\n\n")
        
        # Write medical conditions (AFTER patients to ensure foreign key constraint)
        f.write("-- =============================================\n")
        f.write("-- PATIENT CONDITIONS\n")
        f.write("-- =============================================\n\n")
        
        for condition in medical_data['conditions']:
            f.write(f"INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes)\n")
            f.write(f"VALUES ('{condition['patient_id']}', {condition['condition_id']}, '{condition['diagnosis_date']}', '{condition['notes']}')\n")
            f.write(f"ON CONFLICT (patient_id, condition_id) DO NOTHING;\n\n")
        
        # Write family history (AFTER patients to ensure foreign key constraint)
        f.write("-- =============================================\n")
        f.write("-- PATIENT FAMILY HISTORY\n")
        f.write("-- =============================================\n\n")
        
        for history in medical_data['family_history']:
            f.write(f"INSERT INTO patient_family_history (patient_id, condition_id, relative_type, notes)\n")
            f.write(f"VALUES ('{history['patient_id']}', {history['condition_id']}, '{history['relative_type']}', '{history['notes']}')\n")
            f.write(f"ON CONFLICT (patient_id, condition_id) DO NOTHING;\n\n")
        
        # Write medications (AFTER patients to ensure foreign key constraint)
        f.write("-- =============================================\n")
        f.write("-- PATIENT MEDICATIONS\n")
        f.write("-- =============================================\n\n")
        
        for medication in medical_data['medications']:
            f.write(f"INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date)\n")
            f.write(f"VALUES ('{medication['patient_id']}', {medication['medication_id']}, '{medication['dosage']}', '{medication['frequency']}', '{medication['start_date']}')\n")
            f.write(f"ON CONFLICT (patient_id, medication_id) DO NOTHING;\n\n")
        
        # Write allergies (AFTER patients to ensure foreign key constraint)
        f.write("-- =============================================\n")
        f.write("-- PATIENT ALLERGIES\n")
        f.write("-- =============================================\n\n")
        
        for allergy in medical_data['allergies']:
            f.write(f"INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description)\n")
            f.write(f"VALUES ('{allergy['patient_id']}', {allergy['allergy_id']}, '{allergy['severity']}', '{allergy['reaction_description']}')\n")
            f.write(f"ON CONFLICT (patient_id, allergy_id) DO NOTHING;\n\n")
        
        # Write institution emails
        f.write("-- =============================================\n")
        f.write("-- INSTITUTION EMAILS\n")
        f.write("-- =============================================\n\n")
        
        for email in institution_contacts['emails']:
            f.write(f"INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)\n")
            f.write(f"SELECT 'institution', '{email['entity_id']}'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), '{email['email_address']}', TRUE, TRUE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'institution' AND entity_id = '{email['entity_id']}'::uuid AND email_address = '{email['email_address']}');\n\n")
        
        # Write doctor emails
        f.write("-- =============================================\n")
        f.write("-- DOCTOR EMAILS\n")
        f.write("-- =============================================\n\n")
        
        for email in doctor_contacts['emails']:
            f.write(f"INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)\n")
            f.write(f"SELECT 'doctor', '{email['entity_id']}'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), '{email['email_address']}', TRUE, TRUE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'doctor' AND entity_id = '{email['entity_id']}'::uuid AND email_address = '{email['email_address']}');\n\n")
        
        # Write patient emails
        f.write("-- =============================================\n")
        f.write("-- PATIENT EMAILS\n")
        f.write("-- =============================================\n\n")
        
        for email in patient_contacts['emails']:
            f.write(f"INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)\n")
            f.write(f"SELECT 'patient', '{email['entity_id']}'::uuid, (SELECT id FROM email_types WHERE name = 'primary'), '{email['email_address']}', TRUE, TRUE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM emails WHERE entity_type = 'patient' AND entity_id = '{email['entity_id']}'::uuid AND email_address = '{email['email_address']}');\n\n")
        
        # Write institution phones
        f.write("-- =============================================\n")
        f.write("-- INSTITUTION PHONES\n")
        f.write("-- =============================================\n\n")
        
        for phone in institution_contacts['phones']:
            f.write(f"INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)\n")
            f.write(f"SELECT 'institution', '{phone['entity_id']}'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '{phone['phone_number']}', TRUE, TRUE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'institution' AND entity_id = '{phone['entity_id']}'::uuid AND phone_number = '{phone['phone_number']}');\n\n")
        
        # Write doctor phones
        f.write("-- =============================================\n")
        f.write("-- DOCTOR PHONES\n")
        f.write("-- =============================================\n\n")
        
        for phone in doctor_contacts['phones']:
            f.write(f"INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)\n")
            f.write(f"SELECT 'doctor', '{phone['entity_id']}'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '{phone['phone_number']}', TRUE, TRUE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'doctor' AND entity_id = '{phone['entity_id']}'::uuid AND phone_number = '{phone['phone_number']}');\n\n")
        
        # Write patient phones
        f.write("-- =============================================\n")
        f.write("-- PATIENT PHONES\n")
        f.write("-- =============================================\n\n")
        
        for phone in patient_contacts['phones']:
            f.write(f"INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)\n")
            f.write(f"SELECT 'patient', '{phone['entity_id']}'::uuid, (SELECT id FROM phone_types WHERE name = 'primary'), '{phone['phone_number']}', TRUE, TRUE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'patient' AND entity_id = '{phone['entity_id']}'::uuid AND phone_number = '{phone['phone_number']}');\n\n")
        
        # Write emergency contact phones
        f.write("-- =============================================\n")
        f.write("-- EMERGENCY CONTACT PHONES\n")
        f.write("-- =============================================\n\n")
        
        for phone in patient_contacts['emergency_phones']:
            f.write(f"INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)\n")
            f.write(f"SELECT 'emergency_contact', '{phone['entity_id']}'::uuid, (SELECT id FROM phone_types WHERE name = 'emergency'), '{phone['phone_number']}', FALSE, FALSE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = '{phone['entity_id']}'::uuid AND phone_number = '{phone['phone_number']}');\n\n")
        
        # Write institution addresses
        f.write("-- =============================================\n")
        f.write("-- INSTITUTION ADDRESSES\n")
        f.write("-- =============================================\n\n")
        
        for address in institution_contacts['addresses']:
            f.write(f"INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)\n")
            f.write(f"SELECT 'institution', '{address['entity_id']}', 'primary', '{address['street_address']}', '{address['city']}', (SELECT id FROM regions WHERE name = '{address['state']}'), (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, TRUE\n")
            f.write(f"WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE entity_type = 'institution' AND entity_id = '{address['entity_id']}' AND street_address = '{address['street_address']}');\n\n")
        
        # Write users with passwords (AFTER all entities to ensure foreign key constraint)
        f.write("-- =============================================\n")
        f.write("-- USERS WITH PASSWORDS\n")
        f.write("-- =============================================\n\n")
        
        for user in users:
            f.write(f"-- User: {user['email']}\n")
            f.write(f"-- Password (plain text): {user['password']}\n")
            f.write(f"INSERT INTO users (id, email, password_hash, user_type, reference_id, is_active, is_verified)\n")
            f.write(f"VALUES ('{user['id']}', '{user['email']}', '{user['password_hash']}', '{user['user_type']}', '{user['reference_id']}', TRUE, TRUE)\n")
            f.write("ON CONFLICT (email) DO NOTHING;\n\n")

def write_debug_file(institutions, institution_contacts, doctors, doctor_contacts, patients, patient_contacts, health_profiles, medical_data, users):
    """Write debug information to a text file"""
    with open('populate_debug.txt', 'w', encoding='utf-8') as f:
        f.write("=============================================\n")
        f.write("POPULATE DATABASE DEBUG INFORMATION\n")
        f.write(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("=============================================\n\n")
        
        f.write("INSTITUTIONS:\n")
        f.write("=============================================\n")
        for i, institution in enumerate(institutions[:5]):  # Show first 5 as example
            f.write(f"{i+1}. ID: {institution['id']}\n")
            f.write(f"   Name: {institution['name']}\n")
            f.write(f"   Type: {institution['institution_type']}\n")
            f.write(f"   Website: {institution['website']}\n")
            f.write(f"   License: {institution['license_number']}\n\n")
        
        f.write("DOCTORS:\n")
        f.write("=============================================\n")
        for i, doctor in enumerate(doctors[:5]):  # Show first 5 as example
            f.write(f"{i+1}. ID: {doctor['id']}\n")
            f.write(f"   Name: {doctor['first_name']} {doctor['last_name']}\n")
            f.write(f"   Gender: {doctor['gender']}\n")
            f.write(f"   License: {doctor['medical_license']}\n")
            f.write(f"   Specialty: {doctor['specialty']}\n")
            f.write(f"   Institution ID: {doctor['institution_id']}\n\n")
        
        f.write("PATIENTS:\n")
        f.write("=============================================\n")
        for i, patient in enumerate(patients[:5]):  # Show first 5 as example
            f.write(f"{i+1}. ID: {patient['id']}\n")
            f.write(f"   Name: {patient['first_name']} {patient['last_name']}\n")
            f.write(f"   Gender: {patient['gender']}\n")
            f.write(f"   Birth Date: {patient['date_of_birth']}\n")
            f.write(f"   Doctor ID: {patient['doctor_id']}\n")
            f.write(f"   Institution ID: {patient['institution_id']}\n\n")
        
        f.write("SAMPLE EMAILS:\n")
        f.write("=============================================\n")
        if patient_contacts['emails']:
            email = patient_contacts['emails'][0]
            f.write(f"Patient Email: {email['email_address']}\n")
            f.write(f"Entity ID: {email['entity_id']}\n\n")
        
        f.write("SAMPLE PHONES:\n")
        f.write("=============================================\n")
        if patient_contacts['phones']:
            phone = patient_contacts['phones'][0]
            f.write(f"Patient Phone: {phone['phone_number']}\n")
            f.write(f"Entity ID: {phone['entity_id']}\n\n")
        
        f.write("SAMPLE USERS:\n")
        f.write("=============================================\n")
        for i, user in enumerate(users[:5]):  # Show first 5 as example
            f.write(f"{i+1}. Email: {user['email']}\n")
            f.write(f"   Type: {user['user_type']}\n")
            f.write(f"   Reference ID: {user['reference_id']}\n")
            f.write(f"   Password: {user['password']}\n\n")

def main():
    """Main function to generate and write all data to SQL file"""
    print("Generating database population script...")
    print("Progress: 0%")
    
    # Generate institutions
    print("Generating 100 institutions...")
    institutions = generate_institutions(100)
    print("Progress: 10%")
    
    # Generate institution contacts
    print("Generating institution contacts...")
    institution_contacts = generate_institution_contacts(institutions)
    print("Progress: 20%")
    
    # Generate doctors
    print("Generating 100 doctors...")
    doctors = generate_doctors(institutions, 100)
    print("Progress: 30%")
    
    # Generate doctor contacts
    print("Generating doctor contacts...")
    doctor_contacts = generate_doctor_contacts(doctors)
    print("Progress: 40%")
    
    # Generate patients
    print("Generating 100 patients...")
    patients = generate_patients(doctors, institutions, 100)
    print("Progress: 50%")
    
    # Generate patient contacts
    print("Generating patient contacts...")
    patient_contacts = generate_patient_contacts(patients)
    print("Progress: 60%")
    
    # Generate health profiles
    print("Generating health profiles...")
    health_profiles = generate_health_profiles(patients)
    print("Progress: 70%")
    
    # Generate patient medical data
    print("Generating patient medical data...")
    medical_data = generate_patient_medical_data(patients)
    print("Progress: 80%")
    
    # Generate users
    print("Generating user accounts...")
    users = generate_users(institutions, doctors, patients)
    print("Progress: 90%")
    
    # Write debug file first
    print("Writing debug information file...")
    write_debug_file(institutions, institution_contacts, doctors, doctor_contacts, patients, patient_contacts, health_profiles, medical_data, users)
    
    # Write everything to SQL file
    print("Writing populate.sql file...")
    write_sql_file(institutions, institution_contacts, doctors, doctor_contacts, patients, patient_contacts, health_profiles, medical_data, users)
    
    print("Progress: 100%")
    print("Database population script completed successfully!")
    print(f"Generated {len(institutions)} institutions, {len(doctors)} doctors, {len(patients)} patients")
    print(f"File 'populate.sql' created with all data and passwords in comments")
    print(f"File 'populate_debug.txt' created with debug information")

if __name__ == "__main__":
    main()