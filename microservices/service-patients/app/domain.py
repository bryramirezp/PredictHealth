# /microservices/service-patients/app/domain.py (REFACTORIZADO)

from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import date as date_type, datetime
from uuid import UUID as UUID_type

# ============================================================================
# MODELOS PARA SOLICITUDES (REQUESTS) - DATOS DE ENTRADA
# ============================================================================

class EmailCreate(BaseModel):
    email_address: EmailStr
    is_primary: bool = True

class HealthProfileCreate(BaseModel):
    height_cm: Optional[float] = Field(None, gt=0)
    weight_kg: Optional[float] = Field(None, gt=0)
    blood_type_id: Optional[int] = None
    is_smoker: Optional[bool] = False
    smoking_years: Optional[int] = Field(None, ge=0)
    consumes_alcohol: Optional[bool] = False
    alcohol_frequency: Optional[str] = None
    physical_activity_minutes_weekly: Optional[int] = Field(None, ge=0)
    notes: Optional[str] = None

class PatientCreateRequest(BaseModel):
    doctor_id: UUID_type
    institution_id: UUID_type
    first_name: str = Field(..., min_length=1)
    last_name: str = Field(..., min_length=1)
    date_of_birth: date_type
    sex_id: Optional[int] = None
    gender_id: Optional[int] = None
    emergency_contact_name: Optional[str] = None
    contact_email: EmailCreate
    health_profile: HealthProfileCreate
    password: str = Field(..., min_length=8)

class PatientUpdateRequest(BaseModel):
    first_name: Optional[str] = Field(None, min_length=1)
    last_name: Optional[str] = Field(None, min_length=1)
    date_of_birth: Optional[date_type] = None
    sex_id: Optional[int] = None
    gender_id: Optional[int] = None
    emergency_contact_name: Optional[str] = None


# ============================================================================
# MODELOS PARA RESPUESTAS (RESPONSES) - DATOS DE SALIDA
# ============================================================================

class HealthProfileResponse(BaseModel):
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    blood_type: Optional[str] = None
    is_smoker: Optional[bool] = None
    consumes_alcohol: Optional[bool] = None
    notes: Optional[str] = None
    physical_activity_minutes_weekly: Optional[int] = None

    class Config:
        from_attributes = True

class PatientResponse(BaseModel):
    id: UUID_type
    doctor_id: UUID_type
    institution_id: UUID_type
    first_name: str
    last_name: str
    date_of_birth: date_type
    is_active: bool
    is_verified: bool
    emergency_contact_name: Optional[str] = None
    contact_email: Optional[EmailStr] = None
    sex_id: Optional[int] = None
    gender_id: Optional[int] = None
    health_profile: Optional[HealthProfileResponse] = None

    class Config:
        from_attributes = True

# --- Modelos de respuesta para el endpoint del Dashboard (REFACTORIZADOS) ---

class DashboardPatientInfo(BaseModel):
    """Datos crudos del paciente para cálculos del dashboard."""
    first_name: str
    last_name: str
    date_of_birth: Optional[date_type] = None
    is_smoker: Optional[bool] = None
    consumes_alcohol: Optional[bool] = None
    physical_activity_minutes_weekly: Optional[int] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None

class DashboardMedication(BaseModel):
    name: str
    dosage: Optional[str]
    frequency: Optional[str]

class DashboardCondition(BaseModel):
    name: str

class DashboardResponse(BaseModel):
    """Modelo final de respuesta para el Dashboard del Paciente."""
    patient: DashboardPatientInfo
    health_score: int
    medications: List[DashboardMedication]
    conditions: List[DashboardCondition]
    
    # --- KPIs NUEVOS ---
    age: Optional[int] = None
    bmi: Optional[float] = None
    bmi_classification: Optional[str] = None
    # --- FIN KPIs NUEVOS ---
    
    # Campos mantenidos para futuras implementaciones
    appointments: List = []
    recent_activity: List = []

# --- Modelos de respuesta para el endpoint de Expediente Médico ---

class MedicalRecordHealthProfile(HealthProfileResponse):
    physical_activity_minutes_weekly: Optional[int] = None
    smoking_years: Optional[int] = None
    alcohol_frequency: Optional[str] = None

class MedicalRecordCondition(BaseModel):
    name: str
    diagnosis_date: Optional[date_type]
    notes: Optional[str]

class MedicalRecordMedication(BaseModel):
    name: str
    dosage: Optional[str]
    frequency: Optional[str]
    start_date: Optional[date_type]

class MedicalRecordAllergy(BaseModel):
    name: str
    severity: Optional[str]
    reaction_description: Optional[str]

class MedicalRecordFamilyHistory(BaseModel):
    condition_name: str
    relative_type: Optional[str]
    notes: Optional[str]

class MedicalRecordResponse(BaseModel):
    health_profile: Optional[MedicalRecordHealthProfile]
    conditions: List[MedicalRecordCondition]
    medications: List[MedicalRecordMedication]
    allergies: List[MedicalRecordAllergy]
    family_history: List[MedicalRecordFamilyHistory]

# --- Modelos de respuesta para el endpoint de Equipo Médico ---

class CareTeamDoctor(BaseModel):
    first_name: str
    last_name: str
    years_experience: Optional[int]
    specialty: Optional[str]
    email: Optional[EmailStr]
    phone: Optional[str]

class CareTeamInstitutionAddress(BaseModel):
    street: Optional[str]
    city: Optional[str]
    region: Optional[str]
    country: Optional[str]
    postal_code: Optional[str]

class CareTeamInstitution(BaseModel):
    name: str
    type: Optional[str]
    website: Optional[str]
    email: Optional[EmailStr]
    phone: Optional[str]
    address: Optional[CareTeamInstitutionAddress]

class CareTeamResponse(BaseModel):
    doctor: CareTeamDoctor
    institution: CareTeamInstitution

# --- Modelos de respuesta para el endpoint de Perfil de Usuario ---

class ProfilePersonalInfo(BaseModel):
    first_name: str
    last_name: str
    date_of_birth: date_type
    primary_email: Optional[EmailStr] = None

class ProfileEmail(BaseModel):
    id: UUID_type
    email_address: EmailStr
    is_primary: bool
    is_verified: bool
    email_type: Optional[str]

class ProfilePhone(BaseModel):
    id: UUID_type
    phone_number: str
    is_primary: bool
    is_verified: bool
    phone_type: Optional[str]

class ProfileAddress(BaseModel):
    id: UUID_type
    street_address: str
    city: str
    postal_code: Optional[str]
    neighborhood: Optional[str] = None
    address_type: Optional[str] = None
    is_verified: Optional[bool] = None
    region_id: Optional[int] = None
    country_id: Optional[int] = None

class PatientProfileResponse(BaseModel):
    personal_info: ProfilePersonalInfo
    emails: List[ProfileEmail]
    phones: List[ProfilePhone]
    addresses: List[ProfileAddress]