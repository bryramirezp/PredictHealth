from app.models import db
from datetime import datetime
import bcrypt
import uuid

# Read-only models for existing system tables
# These map to the existing database tables for viewing/managing system data

class Admin(db.Model):
    __tablename__ = 'admins'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.String(36))  # Removed foreign key constraint
    email = db.Column(db.String(255))
    first_name = db.Column(db.String(100))
    last_name = db.Column(db.String(100))
    department = db.Column(db.String(100))
    employee_id = db.Column(db.String(50), unique=True)
    phone = db.Column(db.String(20))
    is_active = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Doctor(db.Model):
    __tablename__ = 'doctors'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    institution_id = db.Column(db.String(36))
    first_name = db.Column(db.String(100))
    last_name = db.Column(db.String(100))
    email = db.Column(db.String(255), unique=True)
    medical_license = db.Column(db.String(50), unique=True)
    specialty_id = db.Column(db.String(36))
    phone = db.Column(db.String(20))
    years_experience = db.Column(db.Integer, default=0)
    consultation_fee = db.Column(db.Numeric(10, 2))
    professional_status = db.Column(db.String(50), default='active')
    is_active = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Patient(db.Model):
    __tablename__ = 'patients'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    doctor_id = db.Column(db.String(36))
    institution_id = db.Column(db.String(36))
    first_name = db.Column(db.String(100))
    last_name = db.Column(db.String(100))
    email = db.Column(db.String(255), unique=True)
    date_of_birth = db.Column(db.Date)
    gender = db.Column(db.String(20))
    phone = db.Column(db.String(20))
    emergency_contact_name = db.Column(db.String(200))
    emergency_contact_phone = db.Column(db.String(20))
    validation_status = db.Column(db.String(50), default='pending')
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class MainUser(db.Model):
    """Model for the main application users table"""
    __tablename__ = 'users'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    user_type = db.Column(db.String(50), nullable=False)  # 'patient', 'doctor', 'admin', 'institution'
    reference_id = db.Column(db.String(36), nullable=False)  # FK to respective domain table (UUID as string)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    is_verified = db.Column(db.Boolean, default=False, nullable=False)
    failed_login_attempts = db.Column(db.Integer, default=0)
    last_failed_login = db.Column(db.DateTime)
    password_changed_at = db.Column(db.DateTime, default=datetime.utcnow)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def set_password(self, password):
        password_bytes = password.encode('utf-8')
        salt = bcrypt.gensalt()
        self.password_hash = bcrypt.hashpw(password_bytes, salt).decode('utf-8')

    def check_password(self, password):
        password_bytes = password.encode('utf-8')
        hash_bytes = self.password_hash.encode('utf-8')
        return bcrypt.checkpw(password_bytes, hash_bytes)

    def __repr__(self):
        return f'<MainUser {self.email} ({self.user_type})>'

class MedicalInstitution(db.Model):
    __tablename__ = 'medical_institutions'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(200))
    institution_type = db.Column(db.String(50))
    contact_email = db.Column(db.String(255), unique=True)
    address = db.Column(db.String(255))
    region_state = db.Column(db.String(100))
    phone = db.Column(db.String(20))
    website = db.Column(db.String(255))
    license_number = db.Column(db.String(100))
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class DoctorSpecialty(db.Model):
    __tablename__ = 'doctor_specialties'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(100), unique=True)
    description = db.Column(db.Text)
    category = db.Column(db.String(50))
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class HealthProfile(db.Model):
    __tablename__ = 'health_profiles'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = db.Column(db.String(36), db.ForeignKey('patients.id'), unique=True)
    height_cm = db.Column(db.Numeric(5, 2))
    weight_kg = db.Column(db.Numeric(5, 2))
    blood_type = db.Column(db.String(5))
    is_smoker = db.Column(db.Boolean, default=False)
    smoking_years = db.Column(db.Integer, default=0)
    consumes_alcohol = db.Column(db.Boolean, default=False)
    alcohol_frequency = db.Column(db.String(20))
    hypertension_diagnosis = db.Column(db.Boolean, default=False)
    diabetes_diagnosis = db.Column(db.Boolean, default=False)
    high_cholesterol_diagnosis = db.Column(db.Boolean, default=False)
    has_stroke_history = db.Column(db.Boolean, default=False)
    has_heart_disease_history = db.Column(db.Boolean, default=False)
    family_history_diabetes = db.Column(db.Boolean, default=False)
    family_history_hypertension = db.Column(db.Boolean, default=False)
    family_history_heart_disease = db.Column(db.Boolean, default=False)
    preexisting_conditions_notes = db.Column(db.Text)
    current_medications = db.Column(db.Text)
    allergies = db.Column(db.Text)
    physical_activity_minutes_weekly = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class SystemSetting(db.Model):
    __tablename__ = 'system_settings'

    id = db.Column(db.Integer, primary_key=True)
    setting_key = db.Column(db.String(100), unique=True, nullable=False)
    setting_value = db.Column(db.Text)
    setting_type = db.Column(db.String(50), default='string')
    category = db.Column(db.String(50), default='general')
    description = db.Column(db.Text)
    is_system = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)