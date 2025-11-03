# /backend-flask/app/api/v1/__init__.py
# API v1 Blueprint - Actuará como API Gateway

from flask import Blueprint

# Crear blueprint principal para API v1, que funcionará como el Gateway
api_v1 = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Importar las rutas del Gateway que se encargarán del proxying
from .gateway import gateway_bp

# Registrar el blueprint del gateway
api_v1.register_blueprint(gateway_bp)

# Health check para API v1
@api_v1.route('/health', methods=['GET'])
def health():
    """Health check para el API Gateway v1"""
    return {
        'status': 'healthy',
        'service': 'PredictHealth API Gateway',
        'version': '1.0.0'
    }
