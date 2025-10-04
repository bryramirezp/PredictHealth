# /microservices\service-institutions\app\models\__init__.py
# This file makes the 'models' directory a Python package.
from .base import Base
from .institution import MedicalInstitution
from .doctor import Doctor
from .user import User