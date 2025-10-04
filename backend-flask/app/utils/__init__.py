# /backend-flask\app\utils\__init__.py
# /backend-flask/app/utils/__init__.py
# Módulo de utilidades JSON

from .client_detector import (
    ClientDetector,
    detect_client_type,
    is_mobile_client,
    is_web_client,
    get_client_info
)

__all__ = [
    # Client Detector
    'ClientDetector',
    'detect_client_type',
    'is_mobile_client',
    'is_web_client',
    'get_client_info'
]
