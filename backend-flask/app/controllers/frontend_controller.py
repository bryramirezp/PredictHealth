# /backend-flask/app/controllers/frontend_controller.py
from flask import Blueprint, render_template, g, make_response
from functools import wraps
import jwt
from flask import request, redirect, url_for, current_app

# Crear un blueprint para las rutas del frontend
frontend_bp = Blueprint('frontend', __name__)

def login_required(role=None):
    """
    Decorador para proteger rutas. Verifica el JWT de la cookie,
    almacena los datos del usuario en `g.user` y opcionalmente
    verifica el rol.
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token = request.cookies.get('predicthealth_session')
            if not token:
                return redirect(url_for('index'))

            try:
                payload = jwt.decode(
                    token,
                    current_app.config['SECRET_KEY'],
                    algorithms=["HS256"]
                )
                user_role = payload.get('user_type')

                # Almacenar la info del usuario en g para acceso en la vista y plantillas
                g.user = payload

                if role and user_role != role:
                    # Si el rol no coincide, redirigir al dashboard correcto
                    return redirect(url_for(f'frontend.{user_role}_dashboard'))

            except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
                # Si el token es inválido o expirado, limpiar la cookie y redirigir
                resp = make_response(redirect(url_for('index')))
                resp.set_cookie('predicthealth_session', '', expires=0)
                return resp

            return f(*args, **kwargs)
        return decorated_function
    return decorator

# --- Rutas de Pacientes ---
@frontend_bp.route('/patient/dashboard')
@login_required(role='patient')
def patient_dashboard():
    """Renderiza el dashboard del paciente."""
    return render_template('patient/dashboard.html', user=g.user)

# --- Rutas de Doctores ---
@frontend_bp.route('/doctor/dashboard')
@login_required(role='doctor')
def doctor_dashboard():
    """Renderiza el dashboard del doctor."""
    return render_template('doctor/dashboard.html', user=g.user)

# --- Rutas de Instituciones ---
@frontend_bp.route('/institution/dashboard')
@login_required(role='institution')
def institution_dashboard():
    """Renderiza el dashboard de la institución."""
    return render_template('institution/dashboard.html', user=g.user)
