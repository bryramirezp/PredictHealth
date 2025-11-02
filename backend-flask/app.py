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

@app.route('/login')
def login_page():
    """Página de login - redirige a la página principal con el modal de login."""
    return render_template('index.html')

@app.route('/institution_signup.html')
def institution_signup_page():
    """Página de registro para instituciones médicas."""
    return render_template('institution/institution_signup.html')

@app.route('/institution_dashboard.html')
def institution_dashboard_page():
    """Panel principal de la institución médica."""
    return render_template('institution/institution_dashboard.html')

@app.route('/patient_dashboard.html')
def patient_dashboard_page():
    """Panel principal del paciente."""
    return render_template('patient/patient_dashboard.html')

@app.route('/patient_medical_record.html')
def patient_medical_record_page():
    """Expediente médico del paciente."""
    return render_template('patient/patient_medical_record.html')

@app.route('/patient_appointments.html')
def patient_appointments_page():
    """Citas médicas del paciente."""
    return render_template('patient/patient_appointments.html')

@app.route('/patient_lifestyle.html')
def patient_lifestyle_page():
    """Hábitos de vida del paciente."""
    return render_template('patient/patient_lifestyle.html')

@app.route('/patient_measurements.html')
def patient_measurements_page():
    """Medidas y métricas del paciente."""
    return render_template('patient/patient_measurements.html')

@app.route('/patient_notifications.html')
def patient_notifications_page():
    """Notificaciones del paciente."""
    return render_template('patient/patient_notifications.html')

@app.route('/patient_recommendations.html')
def patient_recommendations_page():
    """Recomendaciones personalizadas del paciente."""
    return render_template('patient/patient_recommendations.html')

@app.route('/patient_profile.html')
def patient_profile_page():
    """Perfil del paciente."""
    return render_template('patient/patient_user_profile.html')

@app.route('/doctor_dashboard.html')
def doctor_dashboard_page():
    """Panel principal del doctor."""
    return render_template('doctor/index.html')

@app.route('/doctor/mi-jornada')
def doctor_mi_jornada_page():
    """Página de Mi Jornada del doctor."""
    return render_template('doctor/jornada.html')

@app.route('/doctor/mis-pacientes')
def doctor_mis_pacientes_page():
    """Página de Mis Pacientes del doctor."""
    return render_template('doctor/mis_pacientes.html')

@app.route('/doctor/estadisticas')
def doctor_estadisticas_page():
    """Página de Estadísticas del doctor."""
    return render_template('doctor/estadisticas.html')

@app.route('/doctor/configuracion')
def doctor_configuracion_page():
    """Página de Configuración del doctor."""
    return render_template('doctor/configuracion.html')

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

@app.route('/institution/analytics')
def institution_analytics_page():
    """Página de analíticas para instituciones."""
    return render_template('institution/institution_analytics.html')

@app.route('/institution/settings')
def institution_settings_page():
    """Página de configuración para instituciones."""
    return render_template('institution/institution_settings.html')

@app.route('/admin_dashboard.html')
def admin_dashboard_page():
    """Panel principal del administrador."""
    return render_template('admin/admin_dashboard.html')

@app.route('/docs')
def docs_page():
    """Página de documentación técnica."""
    return render_template('docs/docs.html')

@app.route('/docs/arquitectura')
def docs_arquitectura():
    """Página de arquitectura del sistema."""
    return render_template('docs/arquitectura.html')

@app.route('/docs/backend/<path:subpath>')
def docs_backend(subpath):
    """Páginas de documentación del backend."""
    return render_template(f'docs/backend/{subpath}.html')

@app.route('/docs/frontend/<path:subpath>')
def docs_frontend(subpath):
    """Páginas de documentación del frontend."""
    return render_template(f'docs/frontend/{subpath}.html')

@app.route('/docs/database/<path:subpath>')
def docs_database(subpath):
    """Páginas de documentación de base de datos."""
    return render_template(f'docs/database/{subpath}.html')

@app.route('/docs/ml/<path:subpath>')
def docs_ml(subpath):
    """Páginas de documentación de machine learning."""
    return render_template(f'docs/ml/{subpath}.html')

@app.route('/docs/devices/<path:subpath>')
def docs_devices(subpath):
    """Páginas de documentación de dispositivos."""
    return render_template(f'docs/devices/{subpath}.html')

@app.route('/docs/deploy/<path:subpath>')
def docs_deploy(subpath):
    """Páginas de documentación de deployment."""
    return render_template(f'docs/deploy/{subpath}.html')

@app.route('/logout', methods=['POST'])
def logout():
    """Endpoint de logout que elimina el token de Redis"""
    jwt_token = request.cookies.get('predicthealth_session')

    if jwt_token:
        try:
            # Eliminar el token de Redis usando el formato de clave
            import redis
            redis_url = os.getenv('REDIS_URL', 'redis://redis:6379/0')
            redis_client = redis.from_url(redis_url, decode_responses=True)

            # Intentar eliminar tanto access_token como refresh_token
            access_key = f"access_token:{jwt_token}"
            refresh_key = f"refresh_token:{jwt_token}"

            deleted_access = redis_client.delete(access_key)
            deleted_refresh = redis_client.delete(refresh_key)

            if deleted_access or deleted_refresh:
                logger.info(f"✅ Token revoked from Redis: {access_key[:50]}...")
            else:
                logger.warning(f"⚠️ Token not found in Redis for revocation")
        except Exception as e:
            logger.error(f"❌ Error deleting token from Redis: {str(e)}")

    # Eliminar cookie de todos modos
    resp = jsonify({"success": True, "message": "Sesión cerrada exitosamente"})
    resp.set_cookie('predicthealth_session', '', expires=0, httponly=True, secure=False, samesite='Strict')
    return resp

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