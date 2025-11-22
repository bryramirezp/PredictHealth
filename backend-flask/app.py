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
from app.controllers.frontend_controller import frontend_bp

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
app.register_blueprint(frontend_bp)

logger.info("🚀 Flask app inicializada con nueva arquitectura de microservicios")

# --- Rutas para Servir las Páginas HTML ---

@app.route('/')
@app.route('/index.html')
def index():
    """Página de aterrizaje (landing page)."""
    show_login = request.args.get('show_login', 'false').lower() == 'true'
    return render_template('index.html', show_login=show_login)

@app.route('/login')
def login_page():
    """Página de login - redirige a la página principal con el modal de login."""
    # Redirigir a la página principal con parámetro para mostrar modal
    return redirect(url_for('index', show_login='true'))

# Las rutas de la aplicación (dashboards, perfiles, etc.) ahora son manejadas
# por el blueprint 'frontend' en app/controllers/frontend_controller.py

@app.route('/docs')
def docs_page():
    """Página de documentación técnica."""
    return render_template('docs/docs.html')

@app.route('/docs/arquitectura')
def docs_arquitectura():
    """Página de arquitectura del sistema."""
    return render_template('docs/arquitectura.html')

# Backend
@app.route('/docs/backend/flask')
def docs_backend_flask():
    return render_template('docs/backend/flask.html')

@app.route('/docs/backend/microservicios')
def docs_backend_microservicios():
    return render_template('docs/backend/microservicios.html')

@app.route('/docs/backend/autenticacion')
def docs_backend_autenticacion():
    return render_template('docs/backend/autenticacion.html')

# Frontend
@app.route('/docs/frontend/estructura')
def docs_frontend_estructura():
    return render_template('docs/frontend/estructura.html')

@app.route('/docs/frontend/componentes')
def docs_frontend_componentes():
    return render_template('docs/frontend/componentes.html')

@app.route('/docs/frontend/estilos')
def docs_frontend_estilos():
    return render_template('docs/frontend/estilos.html')

# Base de Datos
@app.route('/docs/database/postgresql')
def docs_database_postgresql():
    return render_template('docs/database/postgresql.html')

@app.route('/docs/database/redis')
def docs_database_redis():
    return render_template('docs/database/redis.html')

@app.route('/docs/database/firebase')
def docs_database_firebase():
    return render_template('docs/database/firebase.html')

# Machine Learning
@app.route('/docs/ml/modelos')
def docs_ml_modelos():
    return render_template('docs/ml/modelos.html')

@app.route('/docs/ml/entrenamiento')
def docs_ml_entrenamiento():
    return render_template('docs/ml/entrenamiento.html')

@app.route('/docs/ml/deployment')
def docs_ml_deployment():
    return render_template('docs/ml/deployment.html')

# Dispositivos
@app.route('/docs/devices/mobile')
def docs_devices_mobile():
    return render_template('docs/devices/mobile.html')

@app.route('/docs/devices/leap-motion')
def docs_devices_leap_motion():
    return render_template('docs/devices/leap-motion.html')

# Deployment
@app.route('/docs/deploy/docker')
def docs_deploy_docker():
    return render_template('docs/deploy/docker.html')

@app.route('/docs/deploy/produccion')
def docs_deploy_produccion():
    return render_template('docs/deploy/produccion.html')

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