# /backend/servicio-doctores/schemas.py

from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime
import uuid

# =============================================
# ESQUEMAS PARA DOCTORES
# =============================================

class DoctorCreate(BaseModel):
    nombre: str
    apellido: str
    email: EmailStr
    licencia_medica: str
    password: str

class DoctorUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    email: Optional[EmailStr] = None

class Doctor(BaseModel):
    id_doctor: uuid.UUID
    nombre: str
    apellido: str
    email: EmailStr
    licencia_medica: str
    fecha_creacion: datetime
    fecha_actualizacion: datetime

    class Config:
        from_attributes = True

class DoctorLogin(BaseModel):
    email: EmailStr
    password: str

class DoctorResponse(BaseModel):
    id_doctor: uuid.UUID
    nombre: str
    apellido: str
    email: EmailStr
    licencia_medica: str

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
    doctor: DoctorResponse

class DoctorList(BaseModel):
    doctores: List[DoctorResponse]
    total: int
    pagina: int
    por_pagina: int

# =============================================
# ESQUEMAS PARA USUARIOS (PACIENTES)
# =============================================

class UsuarioCreate(BaseModel):
    id_doctor: uuid.UUID
    nombre: str
    apellido: str
    email: EmailStr
    fecha_nacimiento: str
    genero: str
    password: str

class UsuarioUpdate(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    email: Optional[EmailStr] = None
    fecha_nacimiento: Optional[str] = None
    genero: Optional[str] = None
    activo: Optional[bool] = None

class Usuario(BaseModel):
    id_usuario: uuid.UUID
    id_doctor: uuid.UUID
    nombre: str
    apellido: str
    email: EmailStr
    fecha_nacimiento: str
    genero: str
    activo: bool
    fecha_creacion: datetime
    fecha_actualizacion: datetime

    class Config:
        from_attributes = True

class UsuarioLogin(BaseModel):
    email: EmailStr
    password: str

class UsuarioResponse(BaseModel):
    id_usuario: uuid.UUID
    id_doctor: uuid.UUID
    nombre: str
    apellido: str
    email: EmailStr
    fecha_nacimiento: str
    genero: str
    activo: bool

    class Config:
        from_attributes = True

class UsuarioToken(BaseModel):
    access_token: str
    token_type: str
    usuario: UsuarioResponse

class UsuarioList(BaseModel):
    usuarios: List[UsuarioResponse]
    total: int
    pagina: int
    por_pagina: int

# =============================================
# ESQUEMAS PARA PERFIL DE SALUD GENERAL
# =============================================

class PerfilSaludGeneralCreate(BaseModel):
    id_usuario: uuid.UUID
    altura_cm: Optional[str] = None
    peso_kg: Optional[str] = None
    fumador: Optional[bool] = False
    consumo_alcohol: Optional[bool] = False
    diagnostico_hipertension: Optional[bool] = False
    diagnostico_colesterol_alto: Optional[bool] = False
    antecedente_acv: Optional[bool] = False
    antecedente_enf_cardiaca: Optional[bool] = False
    condiciones_preexistentes_notas: Optional[str] = None
    minutos_actividad_fisica_semanal: Optional[str] = "0"

class PerfilSaludGeneralUpdate(BaseModel):
    altura_cm: Optional[str] = None
    peso_kg: Optional[str] = None
    fumador: Optional[bool] = None
    consumo_alcohol: Optional[bool] = None
    diagnostico_hipertension: Optional[bool] = None
    diagnostico_colesterol_alto: Optional[bool] = None
    antecedente_acv: Optional[bool] = None
    antecedente_enf_cardiaca: Optional[bool] = None
    condiciones_preexistentes_notas: Optional[str] = None
    minutos_actividad_fisica_semanal: Optional[str] = None

class PerfilSaludGeneral(BaseModel):
    id_perfil: uuid.UUID
    id_usuario: uuid.UUID
    altura_cm: Optional[str] = None
    peso_kg: Optional[str] = None
    fumador: bool
    consumo_alcohol: bool
    diagnostico_hipertension: bool
    diagnostico_colesterol_alto: bool
    antecedente_acv: bool
    antecedente_enf_cardiaca: bool
    condiciones_preexistentes_notas: Optional[str] = None
    minutos_actividad_fisica_semanal: str
    fecha_creacion: datetime
    fecha_actualizacion: datetime

    class Config:
        from_attributes = True

# =============================================
# ESQUEMAS PARA DATOS BIOMÉTRICOS
# =============================================

class DatoBiometricoCreate(BaseModel):
    id_usuario: uuid.UUID
    fecha_hora_medida: datetime
    tipo_medida: str
    valor: str
    unidad: str
    fuente_dato: str
    id_doctor_registro: Optional[uuid.UUID] = None
    notas: Optional[str] = None

class DatoBiometricoUpdate(BaseModel):
    fecha_hora_medida: Optional[datetime] = None
    tipo_medida: Optional[str] = None
    valor: Optional[str] = None
    unidad: Optional[str] = None
    fuente_dato: Optional[str] = None
    notas: Optional[str] = None

class DatoBiometrico(BaseModel):
    id_dato_biometrico: uuid.UUID
    id_usuario: uuid.UUID
    fecha_hora_medida: datetime
    tipo_medida: str
    valor: str
    unidad: str
    fuente_dato: str
    id_doctor_registro: Optional[uuid.UUID] = None
    notas: Optional[str] = None
    fecha_creacion: datetime

    class Config:
        from_attributes = True

class DatoBiometricoList(BaseModel):
    datos_biometricos: List[DatoBiometrico]
    total: int
    pagina: int
    por_pagina: int

# =============================================
# ESQUEMAS PARA PREDICCIONES DE RIESGO
# =============================================

class PrediccionRiesgoCreate(BaseModel):
    id_usuario: uuid.UUID
    fecha_prediccion: datetime
    tipo_riesgo: str
    puntuacion_riesgo: str
    nivel_riesgo: str
    detalles_prediccion: Optional[str] = None

class PrediccionRiesgo(BaseModel):
    id_prediccion: uuid.UUID
    id_usuario: uuid.UUID
    fecha_prediccion: datetime
    tipo_riesgo: str
    puntuacion_riesgo: str
    nivel_riesgo: str
    detalles_prediccion: Optional[str] = None
    fecha_creacion: datetime

    class Config:
        from_attributes = True

class PrediccionRiesgoList(BaseModel):
    predicciones: List[PrediccionRiesgo]
    total: int
    pagina: int
    por_pagina: int

# =============================================
# ESQUEMAS PARA RECOMENDACIONES MÉDICAS
# =============================================

class RecomendacionMedicaCreate(BaseModel):
    id_usuario: uuid.UUID
    id_doctor: uuid.UUID
    id_prediccion: Optional[uuid.UUID] = None
    fecha_generacion: datetime
    contenido_es: str
    estado_recomendacion: str = "pendiente"
    feedback_doctor: Optional[str] = None

class RecomendacionMedicaUpdate(BaseModel):
    contenido_es: Optional[str] = None
    estado_recomendacion: Optional[str] = None
    feedback_doctor: Optional[str] = None

class RecomendacionMedica(BaseModel):
    id_recomendacion: uuid.UUID
    id_usuario: uuid.UUID
    id_doctor: uuid.UUID
    id_prediccion: Optional[uuid.UUID] = None
    fecha_generacion: datetime
    contenido_es: str
    estado_recomendacion: str
    feedback_doctor: Optional[str] = None
    fecha_creacion: datetime
    fecha_actualizacion: datetime

    class Config:
        from_attributes = True

class RecomendacionMedicaList(BaseModel):
    recomendaciones: List[RecomendacionMedica]
    total: int
    pagina: int
    por_pagina: int
