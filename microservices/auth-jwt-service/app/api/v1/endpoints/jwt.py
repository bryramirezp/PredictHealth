# /microservices\service-jwt\app\api\v1\endpoints\jwt.py
# /microservices/service-jwt/app/api/v1/endpoints/jwt.py
# JWT service endpoints for pure token management

from fastapi import APIRouter, HTTPException, status, Request
from typing import Dict, Any, Optional
import logging
from app.services.jwt_service import jwt_service
from app.schemas.jwt import (
    CreateTokenRequest,
    VerifyTokenRequest,
    RefreshTokenRequest,
    RevokeTokenRequest,
    TokenResponse,
    VerifyTokenResponse,
    RevokeTokenResponse
)

# Configure logging
logger = logging.getLogger(__name__)

# Router for JWT endpoints
router = APIRouter(prefix="/tokens", tags=["jwt"])

def extract_device_info(request: Request) -> Dict[str, Any]:
    """
    Extract device and client information from the request.

    Args:
        request: FastAPI Request object

    Returns:
        Dict containing device information
    """
    device_info = {}

    # Get client IP
    client_ip = None
    if request.client:
        client_ip = request.client.host
    else:
        # Fallback to headers
        client_ip = request.headers.get("X-Forwarded-For") or request.headers.get("X-Real-IP")

    device_info["ip_address"] = client_ip
    device_info["user_agent"] = request.headers.get("User-Agent")

    # Basic device detection (can be enhanced with a proper library)
    user_agent = device_info["user_agent"] or ""

    if "Mobile" in user_agent or "Android" in user_agent or "iPhone" in user_agent:
        device_info["device_type"] = "mobile"
    elif "Tablet" in user_agent or "iPad" in user_agent:
        device_info["device_type"] = "tablet"
    else:
        device_info["device_type"] = "desktop"

    # Browser detection (simplified)
    if "Chrome" in user_agent:
        device_info["browser_name"] = "Chrome"
        # Extract version (simplified)
        try:
            version_start = user_agent.find("Chrome/") + 7
            version_end = user_agent.find(" ", version_start)
            device_info["browser_version"] = user_agent[version_start:version_end] if version_end > version_start else "Unknown"
        except:
            device_info["browser_version"] = "Unknown"
    elif "Firefox" in user_agent:
        device_info["browser_name"] = "Firefox"
        device_info["browser_version"] = "Unknown"
    elif "Safari" in user_agent and "Chrome" not in user_agent:
        device_info["browser_name"] = "Safari"
        device_info["browser_version"] = "Unknown"
    else:
        device_info["browser_name"] = "Unknown"
        device_info["browser_version"] = "Unknown"

    # OS detection (simplified)
    if "Windows" in user_agent:
        device_info["os_name"] = "Windows"
        device_info["os_version"] = "Unknown"
    elif "Mac OS" in user_agent or "MacOS" in user_agent:
        device_info["os_name"] = "macOS"
        device_info["os_version"] = "Unknown"
    elif "Linux" in user_agent:
        device_info["os_name"] = "Linux"
        device_info["os_version"] = "Unknown"
    elif "Android" in user_agent:
        device_info["os_name"] = "Android"
        device_info["os_version"] = "Unknown"
    elif "iOS" in user_agent or "iPhone" in user_agent or "iPad" in user_agent:
        device_info["os_name"] = "iOS"
        device_info["os_version"] = "Unknown"
    else:
        device_info["os_name"] = "Unknown"
        device_info["os_version"] = "Unknown"

    return device_info

@router.post("/create", response_model=TokenResponse)
async def create_tokens(
    request: CreateTokenRequest,
    http_request: Request
):
    """
    Create access and refresh tokens for authenticated user with device tracking

    Args:
        request: Token creation request with user information
        http_request: HTTP request object for device information

    Returns:
        TokenResponse: Access and refresh tokens with metadata
    """
    try:
        logger.info(f"🔄 Creating tokens for user: {request.email} (type: {request.user_type})")

        # Extract device information from request
        device_info = extract_device_info(http_request)
        logger.info(f"📱 Device info captured: {device_info.get('device_type', 'unknown')} - {device_info.get('browser_name', 'unknown')}")

        # Create access token with device information
        access_token, access_token_id = jwt_service.create_access_token(
            user_id=request.user_id,
            user_type=request.user_type,
            email=request.email,
            roles=request.roles or [],
            metadata=request.metadata or {},
            device_info=device_info
        )

        # Create refresh token with device information
        refresh_token, refresh_token_id = jwt_service.create_refresh_token(
            user_id=request.user_id,
            user_type=request.user_type,
            email=request.email,
            device_info=device_info
        )

        logger.info(f"✅ Tokens created successfully for user: {request.email}")

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=900,  # 15 minutes
            user_id=request.user_id,
            user_type=request.user_type,
            email=request.email,
            roles=request.roles or [],
            metadata=request.metadata or {}
        )

    except Exception as e:
        logger.error(f"❌ Error creating tokens: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error creating tokens"
        )

@router.post("/verify", response_model=VerifyTokenResponse)
async def verify_token(
    request: VerifyTokenRequest
):
    """
    Verify JWT token validity

    Args:
        request: Token verification request

    Returns:
        VerifyTokenResponse: Token validation result with user information
    """
    try:
        logger.info("🔄 Verifying JWT token")

        # Verify token using JWT service
        payload = jwt_service.verify_token(request.token)

        if payload:
            logger.info(f"✅ Token verified for user: {payload.get('email')}")

            return VerifyTokenResponse(
                valid=True,
                user_id=payload.get('user_id'),
                user_type=payload.get('user_type'),
                email=payload.get('email'),
                roles=payload.get('roles', []),
                metadata=payload.get('metadata', {}),
                expires_at=payload.get('exp'),
                token_type=payload.get('type')
            )
        else:
            logger.warning("⚠️ Token verification failed")
            return VerifyTokenResponse(
                valid=False,
                user_id=None,
                user_type=None,
                email=None,
                roles=[],
                metadata={},
                expires_at=None,
                token_type=None
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error verifying token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error verifying token"
        )

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    request: RefreshTokenRequest
):
    """
    Refresh access token using refresh token with Redis verification

    Args:
        request: Refresh token request

    Returns:
        TokenResponse: New access token with metadata
    """
    try:
        logger.info("🔄 Refreshing access token with Redis verification")

        # Refresh access token using JWT service with Redis verification
        new_access_token, new_token_id = jwt_service.refresh_access_token(request.refresh_token)

        # Get user info from refresh token (already verified in the service method)
        refresh_payload = jwt_service.verify_refresh_token_from_redis(request.refresh_token)

        if not refresh_payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )

        logger.info(f"✅ Access token refreshed for user: {refresh_payload.get('email')}")

        return TokenResponse(
            access_token=new_access_token,
            refresh_token=request.refresh_token,  # Keep same refresh token
            token_type="bearer",
            expires_in=900,  # 15 minutes
            user_id=refresh_payload.get('user_id'),
            user_type=refresh_payload.get('user_type'),
            email=refresh_payload.get('email'),
            roles=refresh_payload.get('roles', []),
            metadata=refresh_payload.get('metadata', {})
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error refreshing token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error refreshing token"
        )

@router.post("/revoke", response_model=RevokeTokenResponse)
async def revoke_token(
    request: RevokeTokenRequest
):
    """
    Revoke/invalidate token from Redis

    Args:
        request: Token revocation request

    Returns:
        RevokeTokenResponse: Revocation result
    """
    try:
        logger.info("🔄 Revoking JWT token from Redis")

        # Revoke token using JWT service (removes from Redis)
        revoked = jwt_service.revoke_token(request.token)

        if revoked:
            return RevokeTokenResponse(
                revoked=True,
                message="Token successfully revoked"
            )
        else:
            return RevokeTokenResponse(
                revoked=False,
                message="Failed to revoke token"
            )

    except Exception as e:
        logger.error(f"❌ Error revoking token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error revoking token"
        )
