# /backend/servicio-pacientes/schemas.py

from pydantic import BaseModel, EmailStr, validator
from typing import Optional, List
from datetime import datetime, date
from decimal import Decimal
import uuid

# =============================================
# ESQUEMAS PARA USUARIOS (ANTES PACIENTES)
# =============================================

class UsuarioCreate(BaseModel):
    id_doctor: uuid.UUID
    nombre: str
    apellido: str
    email: EmailStr
    fecha_nacimiento: str
    genero: str
    password: str
    zona_horaria: Optional[str] = "America/Mexico_City"
    
    # Campos del perfil de salud
    altura_cm: Optional[float] = None
    peso_kg: Optional[float] = None
    fumador: Optional[bool] = False
    consumo_alcohol: Optional[bool] = False
    diagnostico_hipertension: Optional[bool] = False
    diagnostico_colesterol_alto: Optional[bool] = False
    antecedente_acv: Optional[bool] = False
    antecedente_enf_cardiaca: Optional[bool] = False
    condiciones_preexistentes_notas: Optional[str] = None
    minutos_actividad_fisica_semanal: Optional[int] = 0
    
    @validator('fecha_nacimiento', pre=True)
    def parse_fecha_nacimiento(cls, v):
        if isinstance(v, str):
            try:
                # Intentar parsear como YYYY-MM-DD
                return datetime.strptime(v, '%Y-%m-%d').date()
            except ValueError:
                try:
                    # Intentar parsear como DD/MM/YYYY
                    return datetime.strptime(v, '%d/%m/%Y').date()
                except ValueError:
                    raise ValueError('Formato de fecha inválido. Use YYYY-MM-DD o DD/MM/YYYY')
        return v

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
    activo: bool = True
    fecha_creacion: datetime
    fecha_actualizacion: datetime

    class Config:
        from_attributes = True
        
    @classmethod
    def from_orm(cls, obj):
        """Método personalizado para convertir desde ORM"""
        data = {
            "id_usuario": obj.id_usuario,
            "id_doctor": obj.id_doctor,
            "nombre": obj.nombre,
            "apellido": obj.apellido,
            "email": obj.email,
            "fecha_nacimiento": obj.fecha_nacimiento.isoformat() if isinstance(obj.fecha_nacimiento, date) else str(obj.fecha_nacimiento),
            "genero": obj.genero,
            "activo": obj.activo,
            "fecha_creacion": obj.fecha_creacion.isoformat() if hasattr(obj.fecha_creacion, 'isoformat') else str(obj.fecha_creacion),
            "fecha_actualizacion": obj.fecha_actualizacion.isoformat() if hasattr(obj.fecha_actualizacion, 'isoformat') else str(obj.fecha_actualizacion)
        }
        return cls(**data)

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
        
    @classmethod
    def from_orm(cls, obj):
        """Método personalizado para convertir desde ORM"""
        data = {
            "id_usuario": obj.id_usuario,
            "id_doctor": obj.id_doctor,
            "nombre": obj.nombre,
            "apellido": obj.apellido,
            "email": obj.email,
            "fecha_nacimiento": obj.fecha_nacimiento.isoformat() if isinstance(obj.fecha_nacimiento, date) else str(obj.fecha_nacimiento),
            "genero": obj.genero,
            "activo": obj.activo
        }
        return cls(**data)

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
    altura_cm: Optional[Decimal] = None
    peso_kg: Optional[Decimal] = None
    fumador: bool
    consumo_alcohol: bool
    diagnostico_hipertension: bool
    diagnostico_colesterol_alto: bool
    antecedente_acv: bool
    antecedente_enf_cardiaca: bool
    condiciones_preexistentes_notas: Optional[str] = None
    minutos_actividad_fisica_semanal: int
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

# =============================================
# ESQUEMAS COMPATIBLES CON FRONTEND (LEGACY)
# =============================================

# Mantener compatibilidad con el frontend existente
class PacienteCreate(UsuarioCreate):
    pass

class PacienteUpdate(UsuarioUpdate):
    pass

class Paciente(Usuario):
    id_paciente: uuid.UUID = None
    
    def __init__(self, **data):
        if 'id_usuario' in data:
            data['id_paciente'] = data['id_usuario']
        super().__init__(**data)
    
    @classmethod
    def from_orm(cls, obj):
        """Método personalizado para convertir desde ORM"""
        data = {
            "id_usuario": obj.id_usuario,
            "id_doctor": obj.id_doctor,
            "nombre": obj.nombre,
            "apellido": obj.apellido,
            "email": obj.email,
            "fecha_nacimiento": obj.fecha_nacimiento.isoformat() if isinstance(obj.fecha_nacimiento, date) else str(obj.fecha_nacimiento),
            "genero": obj.genero,
            "activo": obj.activo,
            "fecha_creacion": obj.fecha_creacion,
            "fecha_actualizacion": obj.fecha_actualizacion,
            "id_paciente": obj.id_usuario  # Alias para compatibilidad
        }
        return cls(**data)

class PacienteLogin(UsuarioLogin):
    pass

class PacienteResponse(UsuarioResponse):
    id_paciente: uuid.UUID = None
    fecha_creacion: str = None
    fecha_actualizacion: str = None
    
    def __init__(self, **data):
        if 'id_usuario' in data:
            data['id_paciente'] = data['id_usuario']
        super().__init__(**data)
    
    @classmethod
    def from_orm(cls, obj):
        """Método personalizado para convertir desde ORM"""
        data = {
            "id_usuario": obj.id_usuario,
            "id_doctor": obj.id_doctor,
            "nombre": obj.nombre,
            "apellido": obj.apellido,
            "email": obj.email,
            "fecha_nacimiento": obj.fecha_nacimiento.isoformat() if isinstance(obj.fecha_nacimiento, date) else str(obj.fecha_nacimiento),
            "genero": obj.genero,
            "activo": obj.activo,
            "fecha_creacion": obj.fecha_creacion.isoformat() if hasattr(obj.fecha_creacion, 'isoformat') else str(obj.fecha_creacion),
            "fecha_actualizacion": obj.fecha_actualizacion.isoformat() if hasattr(obj.fecha_actualizacion, 'isoformat') else str(obj.fecha_actualizacion),
            "id_paciente": obj.id_usuario  # Alias para compatibilidad
        }
        return cls(**data)

class PacienteToken(BaseModel):
    access_token: str
    token_type: str
    paciente: PacienteResponse

class PacienteList(BaseModel):
    pacientes: List[PacienteResponse]
    total: int
    pagina: int
    por_pagina: int

# Esquemas para perfil de salud (compatibilidad)
class PerfilSaludCreate(BaseModel):
    peso: Optional[str] = None
    altura: Optional[str] = None
    presion_arterial_sistolica: Optional[str] = None
    presion_arterial_diastolica: Optional[str] = None
    glucosa: Optional[str] = None
    colesterol: Optional[str] = None
    historial_medico: Optional[str] = None
    alergias: Optional[str] = None
    medicamentos_actuales: Optional[str] = None

class PerfilSalud(BaseModel):
    id_perfil: uuid.UUID
    id_paciente: uuid.UUID
    peso: Optional[str] = None
    altura: Optional[str] = None
    presion_arterial_sistolica: Optional[str] = None
    presion_arterial_diastolica: Optional[str] = None
    glucosa: Optional[str] = None
    colesterol: Optional[str] = None
    historial_medico: Optional[str] = None
    alergias: Optional[str] = None
    medicamentos_actuales: Optional[str] = None
    fecha_creacion: datetime
    fecha_actualizacion: datetime

    class Config:
        from_attributes = True

# Esquemas para medidas de salud (compatibilidad)
class MedidaSaludCreate(BaseModel):
    tipo_medida: str
    valor: str
    unidad: str
    fecha_medicion: datetime
    notas: Optional[str] = None

class MedidaSalud(BaseModel):
    id_medida: uuid.UUID
    id_paciente: uuid.UUID
    tipo_medida: str
    valor: str
    unidad: str
    fecha_medicion: datetime
    notas: Optional[str] = None
    fecha_creacion: datetime

    class Config:
        from_attributes = True
