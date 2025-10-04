# /microservices\service-jwt\app\utils\token_utils.py
# /microservices/service-jwt/app/utils/token_utils.py
# Utility functions for token hashing and security

import hashlib
import hmac
import os
import logging
from typing import Optional

logger = logging.getLogger(__name__)

class TokenHasher:
    """
    Utility class for secure token hashing operations.
    Provides consistent hashing for token storage and verification.
    """

    def __init__(self):
        # Use a dedicated secret for token hashing (different from JWT secret)
        self.hash_secret = os.getenv("TOKEN_HASH_SECRET", "default-token-hash-secret-change-in-production")
        if self.hash_secret == "default-token-hash-secret-change-in-production":
            logger.warning("⚠️ Using default TOKEN_HASH_SECRET. Please set a secure value in production.")

    def hash_token(self, token: str) -> str:
        """
        Create a secure hash of the token for database storage.

        Args:
            token: The JWT token to hash

        Returns:
            str: SHA-256 hash of the token using HMAC with secret key
        """
        try:
            # Use HMAC-SHA256 for consistent, secure hashing
            hash_input = token.encode('utf-8')
            hash_secret_bytes = self.hash_secret.encode('utf-8')

            hashed = hmac.new(
                hash_secret_bytes,
                hash_input,
                hashlib.sha256
            ).hexdigest()

            return hashed
        except Exception as e:
            logger.error(f"❌ Error hashing token: {e}")
            raise ValueError(f"Failed to hash token: {str(e)}")

    def verify_token_hash(self, token: str, stored_hash: str) -> bool:
        """
        Verify a token matches its stored hash.

        Args:
            token: The original token
            stored_hash: The stored hash to compare against

        Returns:
            bool: True if token matches the hash
        """
        try:
            current_hash = self.hash_token(token)
            return hmac.compare_digest(current_hash, stored_hash)
        except Exception as e:
            logger.error(f"❌ Error verifying token hash: {e}")
            return False

    def generate_token_fingerprint(self, user_agent: str = None, ip_address: str = None) -> str:
        """
        Generate a device fingerprint for token tracking.

        Args:
            user_agent: Client user agent string
            ip_address: Client IP address

        Returns:
            str: Fingerprint hash for device identification
        """
        try:
            fingerprint_data = f"{user_agent or ''}:{ip_address or ''}"
            return hashlib.sha256(fingerprint_data.encode('utf-8')).hexdigest()
        except Exception as e:
            logger.error(f"❌ Error generating token fingerprint: {e}")
            return hashlib.sha256(b"unknown").hexdigest()

# Global instance
token_hasher = TokenHasher()