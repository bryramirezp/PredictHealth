# /microservices/auth-jwt-service/app/main.py
# Microservicio de Autenticación y JWT - Alineado con 3NF

from fastapi import FastAPI, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
import jwt
import os
from datetime import datetime, timedelta, timezone
import bcrypt

from shared.database import get_db, Base, engine
from .domain import (
    User,
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

Base.metadata.create_all(bind=engine)
app = FastAPI(title="Servicio de Autenticación y JWT", version="3.0.0")

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
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user or not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Email o contraseña incorrectos")

    token_data = {
        "user_id": str(user.id),
        "user_type": user.user_type,
        "email": user.email,
        "roles": [user.user_type],
        "metadata": {"reference_id": str(user.reference_id)}
    }

    access_token = create_access_token(data=token_data, expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    return {"access_token": access_token, "token_type": "bearer"}

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
def create_user(request: UserCreateRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == request.email).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El email ya está en uso.")

    hashed_password = get_password_hash(request.password)
    db_user = User(
        email=request.email,
        password_hash=hashed_password,
        user_type=request.user_type,
        reference_id=request.reference_id
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.get("/health")
def health_check():
    return {"status": "healthy"}
