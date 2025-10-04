# /backend-flask\app.py
# /backend-flask/app.py
# app.py
# Servidor Flask principal con nueva arquitectura de microservicios

import os
import logging
from flask import Flask, render_template, request, redirect, url_for, jsonify, session, flash
from flask_cors import CORS

# Cargar variables de entorno ANTES de importar otros módulos
from dotenv import load_dotenv
load_dotenv()

# Importar configuración
from app.core.config import Config

# Importar blueprints
from app.api.v1 import api_v1
from app.api.v1.web_controller import web_bp

# Importar middleware JWT
from app.middleware import jwt_middleware

# Configurar logging
logging.basicConfig(
    level=getattr(logging, os.getenv('LOG_LEVEL', 'INFO')),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# --- Configuración de la Aplicación ---
app = Flask(__name__,
            static_folder='frontend/static',
            template_folder='frontend/templates')

# Configuración usando la clase Config
app.config.from_object(Config)

# Configurar CORS para permitir cookies
CORS(app, origins=Config.CORS_ORIGINS, supports_credentials=True)

# Registrar blueprints
app.register_blueprint(api_v1)
app.register_blueprint(web_bp)

logger.info("🚀 Flask app inicializada con nueva arquitectura de microservicios")

# --- Rutas para Servir las Páginas HTML ---

@app.route('/')
@app.route('/index.html')
def index():
    """Página de aterrizaje (landing page)."""
    return render_template('index.html')

@app.route('/institution_login.html')
def institution_login_page():
    """Página de inicio de sesión para instituciones médicas."""
    return render_template('institution/institution_login.html')

@app.route('/institution_signup.html')
def institution_signup_page():
    """Página de registro para instituciones médicas."""
    return render_template('institution/institution_signup.html')

@app.route('/institution_dashboard.html')
def institution_dashboard_page():
    """Panel principal de la institución médica."""
    return render_template('institution/institution_dashboard.html')

@app.route('/patient_login.html')
def patient_login_page():
    """Página de inicio de sesión para pacientes."""
    return render_template('patient/patient_login.html')

@app.route('/doctor_login.html')
def doctor_login_page():
    """Página de inicio de sesión para doctores."""
    return render_template('doctor/doctor_login.html')

@app.route('/patient_dashboard.html')
def patient_dashboard_page():
    """Panel principal del paciente."""
    return render_template('patient/patient_dashboard.html')

@app.route('/doctor_dashboard.html')
def doctor_dashboard_page():
    """Panel principal del doctor."""
    return render_template('doctor/doctor_dashboard.html')

@app.route('/register_patient.html')
def register_patient_page():
    """Página de registro para pacientes."""
    return render_template('patient/register_patient.html')

@app.route('/register_user.html')
def register_user_page():
    """Página de registro para usuarios."""
    return render_template('patient/register_user.html')

@app.route('/institution/doctors')
def institution_doctors_page():
    """Página de gestión de doctores para instituciones."""
    return render_template('institution/institution_doctors.html')

@app.route('/institution/patients')
def institution_patients_page():
    """Página de visualización de pacientes para instituciones."""
    return render_template('institution/institution_patients.html')

@app.route('/admin_login.html')
def admin_login_page():
    """Página de inicio de sesión para administradores."""
    return render_template('admin/admin_login.html')

@app.route('/admin_dashboard.html')
def admin_dashboard_page():
    """Panel principal del administrador."""
    return render_template('admin/admin_dashboard.html')

@app.route('/docs')
def docs_page():
    """Página de documentación técnica."""
    return render_template('docs/docs.html')

# --- Health endpoint for docker-compose healthcheck ---
@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "service": "backend-flask",
        "version": "1.0.0"
    })

# --- Ejecutar la aplicación ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)