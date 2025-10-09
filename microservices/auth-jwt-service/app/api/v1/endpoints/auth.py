# /microservices\service-jwt\app\api\v1\endpoints\auth.py
# /microservices/service-jwt/app/api/v1/endpoints/auth.py
# JWT service endpoints for user authentication

from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import Dict, Any
import logging

from app.core.database import get_db
from app.services.jwt_service import jwt_service
from app.models.user import User
from app.core.security import SecurityUtils
from app.schemas.jwt import LoginRequest, LoginResponse, LogoutRequest, LogoutResponse
from .jwt import extract_device_info

# Configure logging
logger = logging.getLogger(__name__)

# Router for auth endpoints
router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/login", response_model=LoginResponse)
def login(
    request: LoginRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """
    Authenticate user and generate JWT tokens
    """
    try:
        logger.info(f"🔄 Authenticating user: {request.email}")

        # Find user by email
        user = db.query(User).filter(User.email == request.email).first()

        if not user:
            logger.warning(f"⚠️ User not found: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Check if user is active
        if not user.is_active:
            logger.warning(f"⚠️ Inactive user attempted login: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Account is inactive",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Verify password
        if not SecurityUtils.verify_password(request.password, user.password_hash):
            logger.warning(f"⚠️ Invalid password for user: {request.email}")

            # Increment failed login attempts
            user.failed_login_attempts += 1
            db.commit()

            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Reset failed login attempts on successful login
        user.failed_login_attempts = 0
        db.commit()

        logger.info(f"✅ User authenticated: {request.email} (type: {user.user_type})")

        # Extract device information from the request
        device_info = extract_device_info(http_request)
        logger.info(f"📱 Device info captured: {device_info.get('device_type', 'unknown')} - {device_info.get('browser_name', 'unknown')}")

        # Create access token with device information
        access_token, access_token_id = jwt_service.create_access_token(
            user_id=str(user.id),
            user_type=user.user_type,
            email=user.email,
            roles=[user.user_type],  # 💡 CORRECCIÓN (403): Pasa el rol para el Gateway
            metadata={"reference_id": str(user.reference_id)},
            device_info=device_info
        )
        
        # 🚀 CORRECCIÓN CRÍTICA (401/INESTABILIDAD): 
        # Si el access_token_id no existe, significa que el token no se pudo guardar en Redis 
        # (debido al Error 104) y, según el Flujo Definitivo, la sesión NO ES VÁLIDA.
        if not access_token_id:
            logger.error("❌ Fallo crítico al almacenar el Access Token en Redis. Se rechaza el login.")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE, # 503 indica que es un problema del servidor (Redis)
                detail="El servicio de sesión no está disponible. Intente nuevamente."
            )

        # Create refresh token with device information
        refresh_token, refresh_token_id = jwt_service.create_refresh_token(
            user_id=str(user.id),
            user_type=user.user_type,
            email=user.email,
            device_info=device_info
        )

        logger.info(f"✅ Tokens generated for user: {request.email}")

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=900,  # 15 minutes
            user_id=str(user.id),
            user_type=user.user_type,
            email=user.email,
            reference_id=str(user.reference_id),
            access_token_id=access_token_id
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error during login: {str(e)}")
        # Si el error no es 503, se convierte a 500
        if not isinstance(e, HTTPException) or e.status_code != status.HTTP_503_SERVICE_UNAVAILABLE:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error during authentication"
            )
        else:
            raise

@router.post("/logout", response_model=LogoutResponse)
async def logout(
    request: LogoutRequest
):
    """
    Logout user by revoking tokens

    Args:
        request: Logout request with access and refresh token_ids

    Returns:
        LogoutResponse: Logout result
    """
    try:
        logger.info("🔄 Logging out user")

        success_count = 0

        # Revoke tokens - now request contains full JWT tokens
        if request.access_token:
            # request.access_token is the full JWT token
            access_revoked = jwt_service.revoke_token(request.access_token)
            if access_revoked:
                success_count += 1

        if request.refresh_token:
            # request.refresh_token is the full JWT token
            refresh_revoked = jwt_service.revoke_token(request.refresh_token)
            if refresh_revoked:
                success_count += 1

        if success_count > 0:
            logger.info(f"✅ User logged out successfully ({success_count} tokens revoked)")
            return LogoutResponse(
                logged_out=True,
                message=f"Successfully logged out ({success_count} tokens revoked)"
            )
        else:
            logger.warning("⚠️ No tokens were revoked")
            return LogoutResponse(
                logged_out=False,
                message="No tokens found to revoke"
            )

    except Exception as e:
        logger.error(f"❌ Error during logout: {str(e)}")
        # Even if there's an error, we consider it a successful logout
        # to avoid leaking information about token validity
        return LogoutResponse(
            logged_out=True,
            message="Logged out (with warnings)"
        )
