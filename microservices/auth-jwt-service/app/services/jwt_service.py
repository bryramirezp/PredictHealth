# /microservices\service-jwt\app\services\jwt_service.py
# /servicio-jwt/app/services/jwt_service.py
# Core service for managing JWT tokens and session data in Redis only.

import jwt
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any, Tuple, List
import uuid
import os
import redis
import json
import time
import logging
import hashlib

from fastapi import HTTPException, status

logger = logging.getLogger(__name__)

# --- Configuration Constants for 503 Fix ---
MAX_RETRIES = 5
RETRY_DELAY_BASE = 1 # seconds

class JWTService:
    """
    Core service for managing JWT tokens and session data in Redis only.
    Includes robust connection handling and connection pooling for Redis.
    """

    def __init__(self):
        # Configuration from environment variables
        self.SECRET_KEY = os.getenv("JWT_SECRET_KEY")
        self.ALGORITHM = os.getenv("JWT_ALGORITHM")
        self.ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 15))
        self.REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 7))
        self.redis_url = os.getenv('REDIS_URL')

        # Redis connection pooling for production performance
        self.redis_pool = redis.ConnectionPool.from_url(
            self.redis_url,
            decode_responses=True,
            max_connections=20,  # Connection pool size
            socket_connect_timeout=5,
            socket_timeout=5,
            retry_on_timeout=True
        )

        # Initialize Redis client with connection pooling
        self.redis_client = self._connect_with_retry()

        # Health monitoring
        self.redis_available = self.redis_client is not None

    def _connect_with_retry(self) -> Optional[redis.Redis]:
        """
        FIX for the intermittent 503 issue: Implements exponential backoff
        to ensure Redis is available before the service starts accepting traffic.
        Now uses connection pooling for better performance.
        """
        for i in range(MAX_RETRIES):
            try:
                logger.info(f"Attempting to connect to Redis (Attempt {i + 1}/{MAX_RETRIES})...")
                client = redis.Redis(connection_pool=self.redis_pool)
                client.ping()
                logger.info("✅ Successfully connected to Redis with connection pooling.")
                return client
            except Exception as e:
                if i < MAX_RETRIES - 1:
                    delay = RETRY_DELAY_BASE * (2 ** i)
                    logger.warning(f"❌ Redis connection failed: {e}. Retrying in {delay}s...")
                    time.sleep(delay)
                else:
                    logger.error(f"❌ Final Redis connection attempt failed after {MAX_RETRIES} retries. Token operations will use fallback mode.")
                    return None

    def _get_redis_client(self) -> Optional[redis.Redis]:
        """
        Get a Redis client from the connection pool.
        Returns None if Redis is unavailable.
        """
        if not self.redis_client:
            logger.warning("⚠️ Redis client not available - using fallback mode")
            return None
        return self.redis_client

    def _hash_token(self, token: str) -> str:
        """Generate a secure hash for token storage."""
        return hashlib.sha256(token.encode()).hexdigest()

    def _create_token(self, data: Dict[str, Any], expires_delta: timedelta) -> Tuple[str, str]:
        """Helper to encode and sign the JWT."""
        to_encode = data.copy()
        expire = datetime.now(timezone.utc) + expires_delta
        to_encode.update({"exp": expire.timestamp()})
        
        token_id = str(uuid.uuid4())
        to_encode.update({
            "iat": datetime.now(timezone.utc).timestamp(),
            "token_id": token_id
        })
        
        encoded_jwt = jwt.encode(to_encode, self.SECRET_KEY, algorithm=self.ALGORITHM)
        return encoded_jwt, token_id

    def _register_token(self, token_type: str, jwt_token: str, expiry_seconds: int, token_id: str = None) -> bool:
        """Stores the JWT token in Redis with JWT as part of the key name."""
        redis_client = self._get_redis_client()
        if not redis_client:
            logger.error("❌ Cannot register token: Redis unavailable.")
            return False

        try:
            key = f"{token_type}:{jwt_token}"  # "access_token:jwt..." or "refresh_token:jwt..."
            redis_client.setex(key, expiry_seconds, "valid")  # Just store "valid" as value
            logger.info(f"✅ {token_type} stored in Redis with JWT in key")
            return True
        except Exception as e:
            logger.error(f"❌ Error storing {token_type} in Redis: {e}")
            return False

    def create_access_token(
        self,
        user_id: str,
        user_type: str,
        email: str,
        roles: List[str] = None,
        metadata: Dict[str, Any] = None,
        device_info: Dict[str, Any] = None
    ) -> Tuple[str, Optional[str]]:
        """Creates a signed access token and stores it in Redis."""

        data = {
            "user_id": user_id,
            "user_type": user_type,
            "email": email,
            "roles": roles or [],
            "metadata": metadata or {},
            "type": "access"
        }

        expires_delta = timedelta(minutes=self.ACCESS_TOKEN_EXPIRE_MINUTES)
        token, token_id = self._create_token(data, expires_delta)

        # Store complete JWT token in Redis - PROPAGATES 503 if Redis is definitively down
        expiry_seconds = int(expires_delta.total_seconds())
        if not self._register_token("access_token", token, expiry_seconds, token_id):
            # Propagate a critical error if token storage fails
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Authentication backend unavailable (Redis token storage failure)"
            )

        return token, token_id

    def create_refresh_token(
        self,
        user_id: str,
        user_type: str,
        email: str,
        device_info: Dict[str, Any] = None
    ) -> Tuple[str, str]:
        """Creates a signed refresh token and stores the complete JWT in Redis."""
        data = {
            "user_id": user_id,
            "user_type": user_type,
            "email": email,
            "type": "refresh"
        }
        expires_delta = timedelta(days=self.REFRESH_TOKEN_EXPIRE_DAYS)
        token, token_id = self._create_token(data, expires_delta)

        # Store complete JWT token in Redis (same as access tokens)
        expiry_seconds = int(expires_delta.total_seconds())
        if not self._register_token("refresh_token", token, expiry_seconds, token_id):
            logger.warning("⚠️ Redis unavailable - refresh token created but not persisted")
            # Don't fail token creation if Redis storage fails - token still valid

        return token, token_id

    def verify_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Verifies the JWT signature, expiration, and checks Redis for the stored token."""
        try:
            payload = jwt.decode(
                token,
                self.SECRET_KEY,
                algorithms=[self.ALGORITHM]
            )

            token_type = payload.get("type")
            token_id = payload.get("token_id")

            if token_type == "access":
                redis_client = self._get_redis_client()
                if redis_client:
                    stored_token = redis_client.get("access_token")
                    if not stored_token:
                        logger.warning("⚠️ Access token not found in Redis (revoked or expired).")
                        return None
                    if stored_token != token:
                        logger.warning("⚠️ Access token mismatch in Redis.")
                        return None
                    logger.info("✅ Access token verified against Redis")
                else:
                    logger.warning("⚠️ Redis unavailable for access token verification - allowing token")
                    # In fallback mode, allow tokens but log the issue

            return payload

        except jwt.ExpiredSignatureError:
            logger.warning("⚠️ Token expired.")
            return None
        except jwt.InvalidTokenError as e:
            logger.error(f"❌ Invalid token: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Unexpected error during token verification: {e}")
            return None

    def health_check(self) -> Dict[str, Any]:
        """Health check for JWT service and Redis connectivity."""
        health_status = {
            "service": "jwt-service",
            "redis_available": False,
            "redis_pool_size": 0,
            "status": "unhealthy"
        }

        try:
            redis_client = self._get_redis_client()
            if redis_client:
                redis_client.ping()
                health_status["redis_available"] = True
                # Get pool stats if available
                if hasattr(self.redis_pool, 'connection_kwargs'):
                    health_status["redis_pool_size"] = self.redis_pool.connection_kwargs.get('max_connections', 0)
                health_status["status"] = "healthy"
            else:
                health_status["status"] = "degraded"
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            health_status["error"] = str(e)

        return health_status

    def get_statistics(self) -> Dict[str, Any]:
        """Get authentication statistics and metrics."""
        stats = {
            "service": "auth-jwt-service",
            "version": "1.0.0",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "redis_available": False,
            "redis_pool_size": 0,
            "active_tokens": 0,
            "refresh_tokens": 0,
            "configuration": {
                "access_token_expire_minutes": self.ACCESS_TOKEN_EXPIRE_MINUTES,
                "refresh_token_expire_days": self.REFRESH_TOKEN_EXPIRE_DAYS,
                "algorithm": self.ALGORITHM
            }
        }

        try:
            redis_client = self._get_redis_client()
            if redis_client:
                stats["redis_available"] = True

                # Get connection pool size
                if hasattr(self.redis_pool, 'connection_kwargs'):
                    stats["redis_pool_size"] = self.redis_pool.connection_kwargs.get('max_connections', 0)

                # Count tokens by pattern matching
                try:
                    access_keys = redis_client.keys("access_token:*")
                    refresh_keys = redis_client.keys("refresh_token:*")

                    stats["active_tokens"] = len(access_keys) if access_keys else 0
                    stats["refresh_tokens"] = len(refresh_keys) if refresh_keys else 0
                except Exception as e:
                    logger.warning(f"Could not count tokens: {e}")
                    stats["active_tokens"] = -1
                    stats["refresh_tokens"] = -1

        except Exception as e:
            logger.error(f"Error gathering JWT statistics: {e}")
            stats["error"] = str(e)

        return stats

    def verify_refresh_token_from_redis(self, refresh_token: str) -> Optional[Dict[str, Any]]:
        """
        Verify refresh token against Redis storage.

        Args:
            refresh_token: The refresh token to verify

        Returns:
            Optional[Dict]: Token payload if valid, None otherwise
        """
        try:
            # First verify the JWT signature and expiration
            payload = jwt.decode(
                refresh_token,
                self.SECRET_KEY,
                algorithms=[self.ALGORITHM]
            )

            if payload.get("type") != "refresh":
                logger.warning("⚠️ Token is not a refresh token")
                return None

            redis_client = self._get_redis_client()
            if not redis_client:
                logger.warning("⚠️ Redis unavailable for refresh token verification")
                return None

            # Look up the stored refresh token using JWT in key name
            key = f"refresh_token:{refresh_token}"
            exists = redis_client.exists(key)

            if not exists:
                logger.warning(f"⚠️ Refresh token not found in Redis: {key[:50]}...")
                return None

            # Token exists, so it's valid

            logger.info(f"✅ Refresh token verified from Redis for user: {payload.get('email')}")
            return payload

        except jwt.ExpiredSignatureError:
            logger.warning("⚠️ Refresh token expired")
            return None
        except jwt.InvalidTokenError as e:
            logger.error(f"❌ Invalid refresh token: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Error verifying refresh token from Redis: {e}")
            return None

    def refresh_access_token(self, refresh_token: str) -> Tuple[str, Optional[str]]:
        """Verifies refresh token from Redis and issues a new access token."""
        refresh_payload = self.verify_refresh_token_from_redis(refresh_token)

        if not refresh_payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )

        # Extract essential data for new access token
        user_id = refresh_payload.get("user_id")
        user_type = refresh_payload.get("user_type")
        email = refresh_payload.get("email")
        roles = refresh_payload.get("roles", ["user"])
        metadata = refresh_payload.get("metadata", {})

        # Create and register the new access token
        try:
            new_access_token, new_token_id = self.create_access_token(
                user_id=user_id,
                user_type=user_type,
                email=email,
                roles=roles,
                metadata=metadata,
                device_info=None  # Device info not available during refresh, will be empty
            )
            return new_access_token, new_token_id
        except HTTPException as e:
            # Propagate the 503 error from create_access_token if Redis fails
            raise e
        except Exception as e:
            logger.error(f"❌ Error during refresh token process: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal server error during token refresh"
            )

    def revoke_token(self, token: str) -> bool:
        """Revokes a token by deleting its key from Redis (JWT is part of key name)."""
        # First verify the token is valid
        payload = self.verify_token(token)

        if not payload:
            return False

        token_type = payload.get("type")
        success = False

        redis_client = self._get_redis_client()
        if not redis_client:
            logger.warning("⚠️ Redis unavailable for token revocation")
            return False

        try:
            # Revoke token from Redis using JWT in key name
            key = f"{token_type}_token:{token}"
            deleted_count = redis_client.delete(key)
            if deleted_count > 0:
                success = True
                logger.info(f"✅ {token_type.capitalize()} token revoked from Redis: {key[:50]}...")

        except Exception as e:
            logger.error(f"❌ Error revoking token from Redis: {e}")
            return False

        return success

    def revoke_token_by_id(self, token_id: str, token_type: str) -> bool:
        """Revokes a token by token_id and type (used for logout with token_ids)."""
        redis_client = self._get_redis_client()
        if not redis_client:
            logger.warning("⚠️ Redis unavailable for token revocation")
            return False

        try:
            # Construct the key and delete the token
            key = f"{token_type}_token:{token_id}"
            deleted_count = redis_client.delete(key)
            if deleted_count > 0:
                logger.info(f"✅ {token_type.capitalize()} token revoked from Redis by ID: {key}")
                return True
            else:
                logger.warning(f"⚠️ {token_type.capitalize()} token not found for revocation: {key}")
                return False

        except Exception as e:
            logger.error(f"❌ Error revoking token by ID from Redis: {e}")
            return False


    def revoke_user_tokens(self, user_id: str, device_fingerprint: str = None) -> int:
        """
        Revoke all tokens for a specific user, optionally filtered by device.
        Note: This is a simplified implementation for Redis-only storage.
        In production, you might want to maintain user token indexes.

        Args:
            user_id: The user ID to revoke tokens for
            device_fingerprint: Optional device fingerprint to target specific device

        Returns:
            int: Number of tokens revoked (approximate)
        """
        redis_client = self._get_redis_client()
        if not redis_client:
            logger.warning("⚠️ Redis unavailable for user token revocation")
            return 0

        try:
            # Find and delete token keys that belong to the user
            revoked_count = 0

            # Get all token keys (access_token:* and refresh_token:*)
            token_keys = redis_client.keys("access_token:*") + redis_client.keys("refresh_token:*")

            for key in token_keys:
                try:
                    # Extract JWT from key name (format: "access_token:jwt_token")
                    jwt_token = key.split(":", 1)[1]  # Get everything after the first ":"

                    # Decode to check if it belongs to the user
                    payload = jwt.decode(jwt_token, options={"verify_signature": False})
                    if payload.get("user_id") == user_id:
                        if device_fingerprint:
                            # For now, device fingerprint check is not implemented
                            # since we don't store device info in the simple token format
                            pass
                        redis_client.delete(key)
                        revoked_count += 1
                        logger.info(f"✅ Token revoked: {key[:50]}...")
                except:
                    # Skip invalid tokens
                    pass

            logger.info(f"✅ Revoked {revoked_count} tokens for user {user_id}")
            return revoked_count

        except Exception as e:
            logger.error(f"❌ Error revoking user tokens: {e}")
            return 0


jwt_service = JWTService()
