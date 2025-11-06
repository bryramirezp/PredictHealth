# /microservices/service-doctors/app/domain.py
# Modelos y esquemas para el dominio de Doctores (REFACTORIZADO COMPLETO)

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from uuid import UUID as UUID_type
from datetime import date as date_type, datetime

# ============================================================================
# MODELOS PARA SOLICITUDES (REQUESTS)
# ============================================================================

class EmailSchema(BaseModel):
    email_address: EmailStr
    is_primary: bool = True

class DoctorCreateRequest(BaseModel):
    """Esquema para crear un doctor con su email principal y contraseña."""
    institution_id: UUID_type
    first_name: str = Field(..., min_length=1)
    last_name: str = Field(..., min_length=1)
    medical_license: str = Field(..., min_length=1)
    specialty_id: Optional[UUID_type] = None
    years_experience: Optional[int] = 0
    consultation_fee: Optional[float] = None
    contact_email: EmailSchema
    password: str = Field(..., min_length=8)

class DoctorUpdateRequest(BaseModel):
    """Esquema para actualizar el perfil de un doctor (profile.html)."""
    specialty_id: Optional[UUID_type] = None
    years_experience: Optional[int] = None
    consultation_fee: Optional[float] = None
    # 'first_name', 'last_name' podrían ir aquí si el doctor puede editarlos
    
class PatientMedicalRecordUpdateRequest(BaseModel):
    """Modelo para que un doctor actualice el expediente de un paciente (patient-detail.html)."""
    # Esta es una versión simplificada. Podríamos tener modelos detallados
    # para 'health_profile', 'conditions', etc., similar a service-patients.
    notes: Optional[str] = None
    # ... otros campos que el doctor puede editar

# ============================================================================
# MODELOS PARA RESPUESTAS (RESPONSES)
# ============================================================================

# --- Modelos para el Dashboard (dashboard.html) ---

class DoctorDashboardKPIs(BaseModel):
    """Para los KPIs en la parte superior de dashboard.html."""
    total_patients: int
    today_appointments: int
    pending_reviews: int
    
    class Config:
        from_attributes = True

# --- Modelos para Mi Perfil (profile.html) ---

class DoctorProfileResponse(BaseModel):
    """Respuesta para el endpoint GET /doctors/me."""
    id: UUID_type
    first_name: str
    last_name: str
    email: Optional[EmailStr]
    specialty_name: Optional[str]
    specialty_id: Optional[UUID_type]
    institution_name: str
    years_experience: Optional[int]
    consultation_fee: Optional[float]
    
    class Config:
        from_attributes = True

# --- Modelos para Mi Institución (my-institution.html) ---

class InstitutionAddressResponse(BaseModel):
    street_address: Optional[str]
    city: Optional[str]
    region_name: Optional[str]
    country_name: Optional[str]
    postal_code: Optional[str]

class DoctorInstitutionResponse(BaseModel):
    """Respuesta para el endpoint GET /doctors/me/institution."""
    id: UUID_type
    name: str
    type: Optional[str]
    license_number: str
    email: Optional[EmailStr]
    phone: Optional[str]
    website: Optional[str]
    address: Optional[InstitutionAddressResponse]
    
    class Config:
        from_attributes = True

# --- Modelos para Mis Pacientes (patients.html) ---

class DoctorPatientInfo(BaseModel):
    """Información resumida de un paciente para la tabla en patients.html."""
    id: UUID_type
    first_name: str
    last_name: str
    date_of_birth: date_type
    contact_email: Optional[EmailStr] = None
    contact_phone: Optional[str] = None
    last_login: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class DoctorPatientListResponse(BaseModel):
    """Respuesta para el endpoint GET /doctors/me/patients."""
    patient_count: int
    patients: List[DoctorPatientInfo]

# --- Modelos para Detalle Paciente (patient-detail.html) ---
# Estos modelos son desde la perspectiva del DOCTOR

class PatientHealthProfile(BaseModel):
    height_cm: Optional[float]
    weight_kg: Optional[float]
    blood_type: Optional[str]
    is_smoker: Optional[bool]
    consumes_alcohol: Optional[bool]
    physical_activity_minutes_weekly: Optional[int]
    notes: Optional[str]

class PatientCondition(BaseModel):
    id: int # ID de la condición, no de la unión
    name: str
    diagnosis_date: Optional[date_type]
    notes: Optional[str]

class PatientMedication(BaseModel):
    id: int # ID del medicamento, no de la unión
    name: str
    dosage: Optional[str]
    frequency: Optional[str]
    start_date: Optional[date_type]

class PatientAllergy(BaseModel):
    id: int # ID de la alergia, no de la unión
    name: str
    severity: Optional[str]
    reaction_description: Optional[str]

class PatientFamilyHistory(BaseModel):
    id: int # ID de la condición, no de la unión
    condition_name: str
    relative_type: Optional[str]
    notes: Optional[str]

class DoctorPatientMedicalRecord(BaseModel):
    """Respuesta para GET /doctors/me/patients/{patient_id}/medical-record."""
    patient_info: DoctorPatientInfo # Info básica del paciente
    health_profile: Optional[PatientHealthProfile]
    conditions: List[PatientCondition]
    medications: List[PatientMedication]
    allergies: List[PatientAllergy]
    family_history: List[PatientFamilyHistory]

# --- Modelo para el CRUD de Admin (ya existente) ---

class DoctorResponse(BaseModel):
    """Esquema para la respuesta de un doctor (usado para CRUD de Admin)."""
    id: UUID_type
    institution_id: UUID_type
    first_name: str
    last_name: str
    medical_license: str
    specialty_id: Optional[UUID_type] = None
    years_experience: Optional[int] = 0
    consultation_fee: Optional[float] = None
    is_active: bool
    professional_status: Optional[str] = None
    contact_email: Optional[EmailStr] = None

    class Config:
        from_attributes = True