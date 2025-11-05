# /microservices/auth-jwt-service/app/main.py
# Microservicio de Autenticación y JWT - Alineado con 3NF

from fastapi import FastAPI, Depends, HTTPException, status, Header
import jwt
import os
import logging
from datetime import datetime, timedelta, timezone
import bcrypt

from .db import execute_query
from .domain import (
    LoginRequest,
    VerifyTokenResponse,
    TokenPayload,
    UserCreateRequest,
    UserResponse
)

# --- Configuración ---
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "secret")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))

app = FastAPI(title="Servicio de Autenticación y JWT", version="3.0.0")

# Configure logging
logger = logging.getLogger(__name__)

# --- Lógica de Contraseñas y Tokens ---
def verify_password(plain_password, hashed_password):
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

def get_password_hash(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def create_access_token(data: dict, expires_delta: timedelta):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode.update({"exp": expire.timestamp()})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# --- Endpoints ---
@app.post("/auth/login")
def login(request: LoginRequest):
    try:
        # Validate input
        if not request.email or not request.password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email y contraseña son requeridos"
            )
        
        # Find user
        query = "SELECT id, email, password_hash, user_type, reference_id, is_active FROM users WHERE email = %s"
        user_data = execute_query(query, (request.email,), fetch_one=True)
        if not user_data:
            logger.warning(f"Login attempt with non-existent email: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email o contraseña incorrectos"
            )

        # Verify password
        if not verify_password(request.password, user_data['password_hash']):
            logger.warning(f"Failed password verification for email: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email o contraseña incorrectos"
            )

        # Check if user is active
        if not user_data['is_active']:
            logger.warning(f"Login attempt for inactive user: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Usuario desactivado. Contacte al administrador."
            )

        token_data = {
            "user_id": str(user_data['id']),
            "user_type": user_data['user_type'],
            "email": user_data['email'],
            "roles": [user_data['user_type']],
            "metadata": {"reference_id": str(user_data['reference_id'])}
        }

        access_token = create_access_token(data=token_data, expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        
        logger.info(f"Successful login for user: {request.email}, user_type: {user_data['user_type']}")
        
        # Return complete response with user information that backend expects
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": str(user_data['id']),
            "user_type": user_data['user_type'],
            "email": user_data['email'],
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,  # in seconds
            "refresh_token": None  # Not implemented yet, but included for compatibility
        }
    
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    except Exception as e:
        logger.error(f"Unexpected error during login for {request.email}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor durante el login"
        )

@app.post("/auth/verify-token", response_model=VerifyTokenResponse)
def verify_token(authorization: str = Header(..., alias="Authorization")):
    if not authorization.startswith("Bearer "):
        return VerifyTokenResponse(valid=False, payload=None)

    token = authorization.split(" ")[1]
    try:
        payload_dict = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM], options={"verify_exp": True})
        payload = TokenPayload(**payload_dict)
        return VerifyTokenResponse(valid=True, payload=payload)
    except jwt.PyJWTError:
        return VerifyTokenResponse(valid=False, payload=None)

@app.post("/users/create", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(request: UserCreateRequest):
    # Check if email already exists
    existing_user = execute_query("SELECT id FROM users WHERE email = %s", (request.email,), fetch_one=True)
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")

    hashed_password = get_password_hash(request.password)

    # Insert new user
    insert_query = """
        INSERT INTO users (email, password_hash, user_type, reference_id, is_active, is_verified)
        VALUES (%s, %s, %s, %s, TRUE, TRUE)
        RETURNING id, email, user_type, reference_id, is_active, is_verified
    """
    result = execute_query(insert_query, (request.email, hashed_password, request.user_type, request.reference_id), fetch_one=True)

    return UserResponse(
        id=result['id'],
        email=result['email'],
        user_type=result['user_type'],
        reference_id=result['reference_id'],
        is_active=result['is_active'],
        is_verified=result['is_verified']
    )

@app.get("/auth/session/validate")
def validate_session_endpoint(authorization: str = Header(..., alias="Authorization")):
    """Validate JWT session token"""
    if not authorization.startswith("Bearer "):
        return {"valid": False, "message": "Invalid authorization header"}

    token = authorization.split(" ")[1]
    try:
        payload_dict = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM], options={"verify_exp": True})
        payload = TokenPayload(**payload_dict)
        return {
            "valid": True,
            "user": {
                "user_id": payload.user_id,
                "user_type": payload.user_type,
                "email": payload.email
            }
        }
    except jwt.ExpiredSignatureError:
        return {"valid": False, "message": "Token expired"}
    except jwt.PyJWTError:
        return {"valid": False, "message": "Invalid token"}

@app.post("/auth/logout")
def logout_endpoint(authorization: str = Header(..., alias="Authorization")):
    """Logout endpoint - revoke JWT token"""
    if not authorization.startswith("Bearer "):
        return {"success": False, "message": "Invalid authorization header"}

    token = authorization.split(" ")[1]
    try:
        # Decode token to get basic info for logging
        payload_dict = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM], options={"verify_exp": False})
        logger.info(f"Logout for user: {payload_dict.get('email', 'unknown')}")

        # In a real implementation, you might want to add the token to a blacklist
        # or revoke it in Redis if you're using Redis for token storage

        return {"success": True, "message": "Logged out successfully"}
    except jwt.PyJWTError:
        return {"success": False, "message": "Invalid token"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
