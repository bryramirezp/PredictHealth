# /microservices\service-jwt\app\core\security.py
# /microservices/service-jwt/app/core/security.py
# JWT service security utilities

import logging
import bcrypt

logger = logging.getLogger(__name__)

class SecurityUtils:
    """JWT service security utilities"""

    @staticmethod
    def generate_token_id() -> str:
        """Generate a unique token ID"""
        import secrets
        return secrets.token_urlsafe(32)

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash"""
        try:
            # Handle bcrypt 72-byte limit
            password_bytes = plain_password.encode('utf-8')
            if len(password_bytes) > 72:
                password_bytes = password_bytes[:72]

            # Hash from database is already a string, convert to bytes
            hash_bytes = hashed_password.encode('utf-8')

            # Verify with bcrypt
            return bcrypt.checkpw(password_bytes, hash_bytes)
        except Exception as e:
            logger.error(f"Error verifying password: {str(e)}")
            return False
