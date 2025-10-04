# /microservices\service-patients\app\clients\auth_client.py
# Cliente unificado para autenticación JWT
"""
Extended auth client:
- keeps the existing async verify_token helper used as a FastAPI dependency
- adds a synchronous helper (SyncAuthClient) so sync service code can call auth endpoints
  during create flows (create_user, delete_user, set_user_reference).
The sync client uses requests to avoid mixing async/sync in service business logic.
"""

import os
import httpx
import requests
import logging
from typing import Dict, Any, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

logger = logging.getLogger(__name__)
security = HTTPBearer()

# -------------------------
# Async client (existing)
# -------------------------
class AuthClient:
    """Async client to communicate with the auth service (used by async endpoints)."""

    def __init__(self):
        self.auth_service_url = os.getenv("AUTH_SERVICE_URL", "http://servicio-auth:8003")
        self.client = httpx.AsyncClient(base_url=self.auth_service_url)

    async def verify_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Verify token with auth service"""
        try:
            response = await self.client.post(
                "/auth/verify-token",
                headers={"Authorization": f"Bearer {token}"},
                timeout=5
            )
            response.raise_for_status()
            return response.json().get("payload")
        except httpx.HTTPStatusError as e:
            logger.warning(f"❌ Error HTTP al verificar token: {e.response.status_code} - {e.response.text}")
            return None
        except httpx.RequestError as e:
            logger.error(f"❌ Error de red al verificar token: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error inesperado al verificar token: {e}")
            return None

# Async instance for dependency
auth_client = AuthClient()

async def verify_token_from_auth_service(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> Dict[str, Any]:
    """FastAPI dependency verifying token with auth service"""
    token_data = await auth_client.verify_token(credentials.credentials)
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data

def require_role(required_role: str):
    """Dependency wrapper to require a role"""
    def role_checker(current_user: Dict[str, Any] = Depends(verify_token_from_auth_service)):
        user_roles = current_user.get("roles", [])
        if required_role not in user_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Se requiere el rol: {required_role}",
            )
        return current_user
    return role_checker

# -------------------------
# Sync helper client
# -------------------------
class SyncAuthClient:
    """Synchronous helper used in sync service code paths to call auth endpoints."""

    def __init__(self):
        self.auth_service_url = os.getenv("AUTH_SERVICE_URL", "http://servicio-auth:8003")
        self.session = requests.Session()
        # reasonable default headers
        self.session.headers.update({"Content-Type": "application/json", "Accept": "application/json"})

    def _url(self, path: str) -> str:
        if not path.startswith("/"):
            path = "/" + path
        return f"{self.auth_service_url}{path}"

    def create_user(self, email: str, password: str, user_type: str, timeout: int = 5) -> Optional[Dict[str, Any]]:
        """
        Create a user in the centralized auth service.
        Expected contract (best-effort):
        POST /users/create
        body: { email, password, user_type }
        response: { user_id, email, user_type }
        """
        try:
            payload = {"email": email, "password": password, "user_type": user_type}
            r = self.session.post(self._url("/users/create"), json=payload, timeout=timeout)
            r.raise_for_status()
            return r.json()
        except requests.HTTPError as e:
            logger.error(f"❌ HTTP error creating auth user: {e} - {getattr(e.response, 'text', '')}")
            return None
        except requests.RequestException as e:
            logger.error(f"❌ Network error creating auth user: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Unexpected error creating auth user: {e}")
            return None

    def delete_user(self, user_id: str, timeout: int = 5) -> bool:
        """Delete/cleanup user in auth service (used for compensation on failures)."""
        try:
            r = self.session.delete(self._url(f"/users/{user_id}"), timeout=timeout)
            if r.status_code in (200,204):
                return True
            logger.warning(f"⚠️ Delete user returned status {r.status_code}")
            return False
        except requests.RequestException as e:
            logger.error(f"❌ Network error deleting auth user: {e}")
            return False

    def set_user_reference(self, user_id: str, reference_id: str, timeout: int = 5) -> bool:
        """Attach domain reference_id to user (PATCH /users/{user_id}/reference)."""
        try:
            payload = {"reference_id": reference_id}
            r = self.session.patch(self._url(f"/users/{user_id}/reference"), json=payload, timeout=timeout)
            r.raise_for_status()
            return True
        except requests.HTTPError as e:
            logger.error(f"❌ HTTP error setting user reference: {e} - {getattr(e.response, 'text', '')}")
            return False
        except requests.RequestException as e:
            logger.error(f"❌ Network error setting user reference: {e}")
            return False

# Global sync client instance
sync_auth_client = SyncAuthClient()

# Backwards-compatible alias
verify_token = auth_client.verify_token
