# app.py
# Servidor Flask principal con arquitectura MVC refactorizada

import os
from flask import Flask, render_template, request, redirect, url_for, jsonify, session, flash

# Importar controladores
from frontend.controllers.auth_controller import AuthController
from frontend.controllers.health_controller import HealthController

# Cargar variables de entorno
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# --- Configuración de la Aplicación ---
app = Flask(__name__,
            static_folder='static',
            template_folder='templates')

# Configuración de seguridad
app.secret_key = os.getenv('SECRET_KEY', os.urandom(24))

# URLs de los microservicios
DOCTOR_SERVICE_URL = os.getenv('DOCTOR_SERVICE_URL', 'http://localhost:8000')
PATIENT_SERVICE_URL = os.getenv('PATIENT_SERVICE_URL', 'http://localhost:8001')

# Inicializar controladores
auth_controller = AuthController()
health_controller = HealthController()

# --- Rutas para Servir las Páginas HTML ---

@app.route('/')
@app.route('/index.html')
def index():
    """Página de aterrizaje (landing page)."""
    return render_template('index.html')

@app.route('/log_in.html')
def log_in_page():
    """Página de inicio de sesión."""
    return render_template('log_in.html')

@app.route('/sign_up.html')
def sign_up_page():
    """Página de registro de credenciales."""
    return render_template('sign_up.html')

# --- Rutas Protegidas (Requieren inicio de sesión) ---

@app.route('/user_dashboard.html')
def user_dashboard():
    """Panel principal del paciente."""
    if session.get('user_type') != 'patient':
        return redirect(url_for('log_in_page'))
    return render_template('user_dashboard.html')

@app.route('/user_profile.html')
def user_profile():
    """Página de perfil del usuario."""
    if session.get('user_type') != 'patient':
        return redirect(url_for('log_in_page'))
    return render_template('user_profile.html')

@app.route('/doctor_dashboard.html')
def doctor_dashboard():
    """Panel principal del doctor."""
    if session.get('user_type') != 'doctor':
        return redirect(url_for('doctor_login_page'))
    return render_template('doctor_dashboard.html')

@app.route('/register_user.html')
def register_user_page():
    """Página para registrar datos de salud del usuario."""
    if session.get('user_type') != 'patient':
        return redirect(url_for('log_in_page'))
    return render_template('register_user.html')

@app.route('/register_patient.html')
def register_patient_page():
    """Página para que el doctor registre un nuevo paciente."""
    if session.get('user_type') != 'doctor':
        return redirect(url_for('doctor_login_page'))
    return render_template('register_patient.html')

@app.route('/doctor_login.html')
def doctor_login_page():
    """Página de inicio de sesión para doctores."""
    return render_template('doctor_login.html')

@app.route('/doctor_signup.html')
def doctor_signup_page():
    """Página de registro para doctores."""
    return render_template('doctor_signup.html')

@app.route('/measurements.html')
def measurements_page():
    """Página para registrar medidas de salud."""
    if session.get('user_type') != 'patient':
        return redirect(url_for('log_in_page'))
    return render_template('measurements.html')
    
@app.route('/lifestyle.html')
def lifestyle_page():
    """Página para registrar hábitos de vida."""
    if session.get('user_type') != 'patient':
        return redirect(url_for('log_in_page'))
    return render_template('lifestyle.html')

@app.route('/recommendations.html')
def recommendations_page():
    """Página de recomendaciones."""
    if session.get('user_type') != 'patient':
        return redirect(url_for('log_in_page'))
    return render_template('recommendations.html')

@app.route('/notifications.html')
def notifications_page():
    """Página de notificaciones."""
    if session.get('user_type') != 'patient':
        return redirect(url_for('log_in_page'))
    return render_template('notifications.html')

@app.route('/mis_pacientes.html')
def mis_pacientes_page():
    """Página para mostrar la lista de pacientes del doctor."""
    if session.get('user_type') != 'doctor':
        return redirect(url_for('doctor_login_page'))
    return render_template('mis_pacientes.html')

# --- Endpoints de Autenticación (Refactorizados con Controladores) ---

@app.route('/auth/doctor/register', methods=['POST'])
def handle_doctor_register():
    """Registrar un nuevo doctor"""
    doctor_data = {
        'nombre': request.form.get('nombre'),
        'apellido': request.form.get('apellido'),
        'email': request.form.get('email'),
        'especialidad': request.form.get('especialidad'),
        'licencia_medica': request.form.get('licencia_medica'),
        'zona_horaria': request.form.get('zona_horaria', 'America/Mexico_City'),
        'password': request.form.get('password')
    }
    
    return auth_controller.register_doctor(doctor_data)

@app.route('/auth/doctor/login', methods=['POST'])
def handle_doctor_login():
    """Autenticar un doctor"""
    email = request.form.get('email')
    password = request.form.get('password')
    
    return auth_controller.login_doctor(email, password)

@app.route('/auth/patient/register', methods=['POST'])
def handle_patient_register():
    """Registrar un nuevo paciente (solo doctores pueden hacer esto)"""
    patient_data = {
        'id_doctor': session.get('doctor_id'),
        'nombre': request.form.get('nombre'),
        'apellido': request.form.get('apellido'),
        'email': request.form.get('email'),
        'fecha_nacimiento': request.form.get('fecha_nacimiento'),
        'genero': request.form.get('genero'),
        'zona_horaria': request.form.get('zona_horaria', 'America/Mexico_City'),
        'password': request.form.get('password'),
        # Campos del perfil de salud
        'altura_cm': float(request.form.get('altura_cm')) if request.form.get('altura_cm') else None,
        'peso_kg': float(request.form.get('peso_kg')) if request.form.get('peso_kg') else None,
        'fumador': request.form.get('fumador') == 'true',
        'consumo_alcohol': request.form.get('consumo_alcohol') == 'true',
        'diagnostico_hipertension': request.form.get('diagnostico_hipertension') == 'true',
        'diagnostico_colesterol_alto': request.form.get('diagnostico_colesterol_alto') == 'true',
        'antecedente_acv': request.form.get('antecedente_acv') == 'true',
        'antecedente_enf_cardiaca': request.form.get('antecedente_enf_cardiaca') == 'true',
        'condiciones_preexistentes_notas': request.form.get('condiciones_preexistentes_notas'),
        'minutos_actividad_fisica_semanal': int(request.form.get('minutos_actividad_fisica_semanal', 0))
    }
    
    return auth_controller.register_patient(patient_data)

@app.route('/auth/patient/login', methods=['POST'])
def handle_patient_login():
    """Autenticar un paciente"""
    email = request.form.get('email')
    password = request.form.get('password')
    
    return auth_controller.login_patient(email, password)

@app.route('/auth/logout', methods=['POST'])
def handle_logout():
    """Cerrar sesión"""
    return auth_controller.logout()

# --- API Endpoints de Salud (Refactorizados con Controladores) ---

@app.route('/api/measurements', methods=['POST'])
def handle_measurements():
    """Guarda medidas de salud reales en el sistema."""
    measurements_data = {
        'bp_systolic': request.form.get('bp_systolic'),
        'bp_diastolic': request.form.get('bp_diastolic'),
        'glucose': request.form.get('glucose')
    }
    
    return health_controller.save_measurements(measurements_data)

@app.route('/api/lifestyle', methods=['POST'])
def handle_lifestyle():
    """Guarda hábitos de vida reales en el sistema."""
    lifestyle_data = {
        'fumador': request.form.get('fumador') == 'true',
        'consumo_alcohol': request.form.get('consumo_alcohol') == 'true',
        'minutos_actividad_fisica_semanal': int(request.form.get('actividad_fisica', 0)),
        'diagnostico_hipertension': request.form.get('hipertension') == 'true',
        'diagnostico_colesterol_alto': request.form.get('colesterol') == 'true',
        'antecedente_acv': request.form.get('acv') == 'true',
        'antecedente_enf_cardiaca': request.form.get('enfermedad_cardiaca') == 'true',
        'condiciones_preexistentes_notas': request.form.get('notas_adicionales', '')
    }
    
    return health_controller.save_lifestyle_data(lifestyle_data)

@app.route('/api/doctor/patients')
def get_doctor_patients():
    """Obtener lista de pacientes del doctor actual"""
    return health_controller.get_patient_list()

@app.route('/patient_details.html')
def patient_details_page():
    """Página de detalles del paciente."""
    if session.get('user_type') != 'doctor':
        return redirect(url_for('doctor_login_page'))
    
    patient_id = request.args.get('id')
    if not patient_id:
        flash('ID de paciente no proporcionado', 'error')
        return redirect(url_for('mis_pacientes_page'))
    
    return render_template('patient_details.html', patient_id=patient_id)

@app.route('/api/doctor/patient/<patient_id>')
def get_patient_details_api(patient_id):
    """Obtener detalles de un paciente específico"""
    return health_controller.get_patient_details(patient_id)

@app.route('/api/doctor/patient/<patient_id>/health')
def get_patient_health_api(patient_id):
    """Obtener perfil de salud de un paciente específico"""
    return health_controller.get_patient_health_profile(patient_id)

@app.route('/api/doctor/patient/<patient_id>/measurements')
def get_patient_measurements_api(patient_id):
    """Obtener mediciones de un paciente específico"""
    return health_controller.get_patient_measurements(patient_id)

@app.route('/api/patient/profile')
def get_patient_profile():
    """Obtener perfil completo del paciente autenticado"""
    return health_controller.get_patient_profile()

@app.route('/api/patient/health-profile')
def get_patient_health_profile():
    """Obtener perfil de salud del paciente autenticado"""
    return health_controller.get_patient_health_profile()

@app.route('/api/dashboard', methods=['GET'])
def get_dashboard_data():
    """Endpoint que proporciona datos reales del dashboard basados en predicciones de salud."""
    return health_controller.get_dashboard_data()

# --- Arranque del Servidor ---

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)