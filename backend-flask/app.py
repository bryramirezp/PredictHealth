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