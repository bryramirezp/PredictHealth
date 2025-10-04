# /microservices\service-jwt\app\models\dto_models.py
# /microservices/service-jwt/app/models/dto_models.py
# JWT service data models

from pydantic import BaseModel
from typing import Dict, Any, List
from datetime import datetime

class TokenData(BaseModel):
    """JWT token data"""
    token_id: str
    user_id: str
    user_type: str
    email: str
    roles: List[str] = []
    metadata: Dict[str, Any] = {}
    expires_at: datetime
