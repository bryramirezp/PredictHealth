# /backend/servicio-pacientes/auth.py

from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
import models, schemas, database
import hashlib
import secrets

# Configuración de seguridad
SECRET_KEY = "tu-clave-secreta-super-segura-cambiar-en-produccion"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Usar una implementación más estable de hash
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
security = HTTPBearer()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica si la contraseña coincide con el hash"""
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception:
        # Fallback a una implementación simple si hay problemas con passlib
        return verify_password_simple(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Genera el hash de la contraseña"""
    try:
        return pwd_context.hash(password)
    except Exception:
        # Fallback a una implementación simple si hay problemas con passlib
        return hash_password_simple(password)

def hash_password_simple(password: str) -> str:
    """Implementación simple de hash como fallback"""
    salt = secrets.token_hex(16)
    pwd_hash = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt.encode('utf-8'), 100000)
    return f"{salt}:{pwd_hash.hex()}"

def verify_password_simple(password: str, hashed_password: str) -> bool:
    """Implementación simple de verificación como fallback"""
    try:
        salt, hash_part = hashed_password.split(':')
        pwd_hash = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt.encode('utf-8'), 100000)
        return pwd_hash.hex() == hash_part
    except Exception:
        return False

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Crea un token JWT"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> Optional[dict]:
    """Verifica y decodifica un token JWT"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None

def get_current_paciente(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(database.get_db)
) -> models.Usuario:
    """Obtiene el paciente actual basado en el token JWT"""
    print(f"Received credentials: {credentials}")
    print(f"Token: {credentials.credentials if credentials else 'None'}")
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudieron validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    if not credentials:
        print("No credentials provided")
        raise credentials_exception
    
    payload = verify_token(credentials.credentials)
    print(f"Token payload: {payload}")
    
    if payload is None:
        print("Invalid token payload")
        raise credentials_exception
    
    paciente_id: str = payload.get("sub")
    print(f"Patient ID from token: {paciente_id}")
    
    if paciente_id is None:
        print("No patient ID in token")
        raise credentials_exception
    
    paciente = db.query(models.Usuario).filter(
        models.Usuario.id_usuario == paciente_id,
        models.Usuario.activo == True
    ).first()
    
    print(f"Found patient: {paciente is not None}")
    
    if paciente is None:
        print("Patient not found or inactive")
        raise credentials_exception
    
    return paciente

def authenticate_paciente(db: Session, email: str, password: str) -> Optional[models.Usuario]:
    """Autentica un paciente con email y contraseña"""
    paciente = db.query(models.Usuario).filter(
        models.Usuario.email == email,
        models.Usuario.activo == True
    ).first()
    
    if not paciente:
        return None
    if not verify_password(password, paciente.contrasena_hash):
        return None
    return paciente
