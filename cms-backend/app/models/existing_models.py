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
    sex_id = db.Column(db.Integer, db.ForeignKey('sexes.id'))
    medical_license = db.Column(db.String(50), unique=True)
    specialty_id = db.Column(db.String(36))
    years_experience = db.Column(db.Integer, default=0)
    consultation_fee = db.Column(db.Numeric(10, 2))
    professional_status = db.Column(db.String(50), default='active')
    is_active = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Property to get primary email
    @property
    def email(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT email_address FROM emails WHERE entity_type = 'doctor' AND entity_id = :entity_id AND is_primary = TRUE LIMIT 1"),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

    # Property to get primary phone
    @property
    def phone(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT phone_number FROM phones WHERE entity_type = 'doctor' AND entity_id = :entity_id AND is_primary = TRUE LIMIT 1"),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

class Patient(db.Model):
    __tablename__ = 'patients'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    doctor_id = db.Column(db.String(36))
    institution_id = db.Column(db.String(36))
    first_name = db.Column(db.String(100))
    last_name = db.Column(db.String(100))
    date_of_birth = db.Column(db.Date)
    sex_id = db.Column(db.Integer, db.ForeignKey('sexes.id'))
    gender_id = db.Column(db.Integer, db.ForeignKey('genders.id'))
    emergency_contact_name = db.Column(db.String(200))
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Properties to get normalized contact information
    @property
    def email(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT email_address FROM emails WHERE entity_type = 'patient' AND entity_id = :entity_id AND is_primary = TRUE LIMIT 1"),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

    @property
    def phone(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT phone_number FROM phones WHERE entity_type = 'patient' AND entity_id = :entity_id AND is_primary = TRUE LIMIT 1"),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

    @property
    def emergency_contact_phone(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT phone_number FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = :entity_id LIMIT 1"),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

    @property
    def gender(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT name FROM genders WHERE id = :gender_id LIMIT 1"),
            {'gender_id': self.gender_id}
        ).fetchone()
        return result[0] if result else None

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

class InstitutionType(db.Model):
    __tablename__ = 'institution_types'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True)
    description = db.Column(db.Text)
    category = db.Column(db.String(50))
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class MedicalInstitution(db.Model):
    __tablename__ = 'medical_institutions'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(200))
    institution_type_id = db.Column(db.Integer, db.ForeignKey('institution_types.id'))
    website = db.Column(db.String(255))
    license_number = db.Column(db.String(100), unique=True)
    is_active = db.Column(db.Boolean, default=True)
    is_verified = db.Column(db.Boolean, default=False)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship to InstitutionType
    institution_type_rel = db.relationship('InstitutionType', backref='medical_institutions')

    # Property to get institution type name
    @property
    def institution_type(self):
        if self.institution_type_rel:
            return self.institution_type_rel.name
        return None

    # Relationship to InstitutionType
    institution_type_rel = db.relationship('InstitutionType', backref='medical_institutions')

    # Properties to get normalized contact information
    @property
    def contact_email(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT email_address FROM emails WHERE entity_type = 'institution' AND entity_id = :entity_id AND is_primary = TRUE LIMIT 1"),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

    @property
    def phone(self):
        from app.models import db
        result = db.session.execute(
            db.text("SELECT phone_number FROM phones WHERE entity_type = 'institution' AND entity_id = :entity_id AND is_primary = TRUE LIMIT 1"),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

    @property
    def address(self):
        from app.models import db
        result = db.session.execute(
            db.text("""
                SELECT CONCAT_WS(', ', addr.street_address, addr.city, r.name, c.name)
                FROM addresses addr
                LEFT JOIN regions r ON addr.region_id = r.id
                LEFT JOIN countries c ON addr.country_id = c.id
                WHERE addr.entity_type = 'institution' AND addr.entity_id = :entity_id AND addr.is_primary = TRUE
                LIMIT 1
            """),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

    @property
    def region_state(self):
        from app.models import db
        result = db.session.execute(
            db.text("""
                SELECT r.name
                FROM addresses addr
                LEFT JOIN regions r ON addr.region_id = r.id
                WHERE addr.entity_type = 'institution' AND addr.entity_id = :entity_id AND addr.is_primary = TRUE
                LIMIT 1
            """),
            {'entity_id': self.id}
        ).fetchone()
        return result[0] if result else None

class SpecialtyCategory(db.Model):
    __tablename__ = 'specialty_categories'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True)
    description = db.Column(db.Text)
    parent_category_id = db.Column(db.Integer, db.ForeignKey('specialty_categories.id'))
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class DoctorSpecialty(db.Model):
    __tablename__ = 'doctor_specialties'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(100), unique=True)
    description = db.Column(db.Text)
    category_id = db.Column(db.Integer, db.ForeignKey('specialty_categories.id'))
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationship to SpecialtyCategory
    category_rel = db.relationship('SpecialtyCategory', backref='doctor_specialties')

class HealthProfile(db.Model):
    __tablename__ = 'health_profiles'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = db.Column(db.String(36), db.ForeignKey('patients.id'), unique=True)
    height_cm = db.Column(db.Numeric(5, 2))
    weight_kg = db.Column(db.Numeric(5, 2))
    blood_type_id = db.Column(db.Integer, db.ForeignKey('blood_types.id'))
    is_smoker = db.Column(db.Boolean, default=False)
    smoking_years = db.Column(db.Integer, default=0)
    consumes_alcohol = db.Column(db.Boolean, default=False)
    alcohol_frequency = db.Column(db.String(20))
    notes = db.Column(db.Text)
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