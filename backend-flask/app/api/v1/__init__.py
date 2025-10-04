# /backend-flask\app\api\v1\__init__.py
# /backend-flask/app/api/v1/__init__.py
# API v1 Blueprint centralizado para PredictHealth

from flask import Blueprint

# Crear blueprint principal para API v1
api_v1 = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Importar y registrar sub-blueprints
from .auth import auth_bp
from .institutions import institutions_bp
from .doctors import doctors_bp
from .patients import patients_bp
from .admins import admins_bp

# Registrar blueprints con prefijos consistentes
api_v1.register_blueprint(auth_bp, url_prefix='/auth')
api_v1.register_blueprint(institutions_bp, url_prefix='/institutions')
api_v1.register_blueprint(doctors_bp, url_prefix='/doctors')
api_v1.register_blueprint(patients_bp, url_prefix='/patients')
api_v1.register_blueprint(admins_bp, url_prefix='/admins')

# Health check para API v1
@api_v1.route('/health', methods=['GET'])
def health():
    """Health check para API v1"""
    return {
        'status': 'healthy',
        'version': '1.0.0',
        'service': 'PredictHealth API Gateway',
        'endpoints': {
            'auth': '/api/v1/auth',
            'institutions': '/api/v1/institutions',
            'doctors': '/api/v1/doctors',
            'patients': '/api/v1/patients',
            'admins': '/api/v1/admins'
        }
    }
