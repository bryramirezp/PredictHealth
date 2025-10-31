from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# Import all models
from .user import User
from .role import Role, UserRole
from .cms_roles import AdminCMS, EditorCMS

# Existing system models (read-only mapping)
from .existing_models import (
    Admin, Doctor, Patient, MedicalInstitution,
    DoctorSpecialty, HealthProfile, InstitutionType, SpecialtyCategory
)

__all__ = [
    'db', 'User', 'Role', 'UserRole', 'AdminCMS', 'EditorCMS',
    'Admin', 'Doctor', 'Patient', 'MedicalInstitution',
    'DoctorSpecialty', 'HealthProfile', 'InstitutionType', 'SpecialtyCategory'
]