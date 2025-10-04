# /microservices\service-doctors\app\models\__init__.py
# This file makes the 'models' directory a Python package.
from .base import Base
from .doctor import Doctor
from .doctor_specialty import DoctorSpecialty
from .patient import Patient
from .user import User