# /backend-flask/app/controllers/frontend_controller.py
from flask import Blueprint, render_template, g, make_response
from functools import wraps
from flask import request, redirect, url_for

# Importar el middleware JWT que ya está configurado para validar tokens del auth-jwt-service
from app.middleware.jwt_middleware import jwt_middleware

# Crear un blueprint para las rutas del frontend
frontend_bp = Blueprint('frontend', __name__)

def login_required(role=None):
    """
    Decorador para proteger rutas. Verifica el JWT de la cookie usando el middleware JWT,
    almacena los datos del usuario en `g.user` y opcionalmente verifica el rol.
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token = request.cookies.get('predicthealth_jwt')
            if not token:
                return redirect(url_for('index'))

            # Usar el middleware JWT que valida tokens del auth-jwt-service
            session_data = jwt_middleware.validate_session(token)
            if not session_data:
                # Si el token es inválido o expirado, limpiar la cookie y redirigir
                resp = make_response(redirect(url_for('index')))
                resp.set_cookie('predicthealth_jwt', '', expires=0)
                return resp

            user_role = session_data.get('user_type')

            # Almacenar la info del usuario en g para acceso en la vista y plantillas
            g.user = session_data

            if role and user_role != role:
                # Si el rol no coincide, redirigir al dashboard correcto
                return redirect(url_for(f'frontend.{user_role}_dashboard'))

            return f(*args, **kwargs)
        return decorated_function
    return decorator

# --- Rutas de Pacientes ---
@frontend_bp.route('/patient/dashboard')
@login_required(role='patient')
def patient_dashboard():
    """Renderiza el dashboard del paciente."""
    return render_template('patient/dashboard.html', user=g.user)

@frontend_bp.route('/patient/medical-record')
@login_required(role='patient')
def patient_medical_record():
    """Renderiza el expediente médico del paciente."""
    return render_template('patient/medical-record.html', user=g.user)

@frontend_bp.route('/patient/my-care-team')
@login_required(role='patient')
def patient_my_care_team():
    """Renderiza la página del equipo médico del paciente."""
    return render_template('patient/my-care-team.html', user=g.user)

@frontend_bp.route('/patient/profile')
@login_required(role='patient')
def patient_profile():
    """Renderiza la página de perfil del paciente."""
    return render_template('patient/profile.html', user=g.user)


# --- Rutas de Doctores ---
@frontend_bp.route('/doctor/dashboard')
@login_required(role='doctor')
def doctor_dashboard():
    """Renderiza el dashboard del doctor."""
    return render_template('doctor/dashboard.html', user=g.user)

@frontend_bp.route('/doctor/patients')
@login_required(role='doctor')
def doctor_patients():
    """Renderiza la lista de pacientes del doctor."""
    return render_template('doctor/patients.html', user=g.user)

@frontend_bp.route('/doctor/patient-detail/<patient_id>')
@login_required(role='doctor')
def doctor_patient_detail(patient_id):
    """Renderiza el detalle del expediente de un paciente."""
    # Aquí se pasaría el patient_id para obtener los datos específicos
    return render_template('doctor/patient-detail.html', user=g.user, patient_id=patient_id)

@frontend_bp.route('/doctor/my-institution')
@login_required(role='doctor')
def doctor_my_institution():
    """Renderiza la página de la institución del doctor."""
    return render_template('doctor/my-institution.html', user=g.user)

@frontend_bp.route('/doctor/profile')
@login_required(role='doctor')
def doctor_profile():
    """Renderiza la página de perfil del doctor."""
    return render_template('doctor/profile.html', user=g.user)


# --- Rutas de Instituciones ---
@frontend_bp.route('/institution/dashboard')
@login_required(role='institution')
def institution_dashboard():
    """Renderiza el dashboard de la institución."""
    return render_template('institution/dashboard.html', user=g.user)

@frontend_bp.route('/institution/doctors')
@login_required(role='institution')
def institution_doctors():
    """Renderiza la página de gestión de doctores."""
    return render_template('institution/doctors.html', user=g.user)

@frontend_bp.route('/institution/patients')
@login_required(role='institution')
def institution_patients():
    """Renderiza la página de gestión de pacientes."""
    return render_template('institution/patients.html', user=g.user)

@frontend_bp.route('/institution/profile')
@login_required(role='institution')
def institution_profile():
    """Renderiza la página de perfil de la institución."""
    return render_template('institution/profile.html', user=g.user)
