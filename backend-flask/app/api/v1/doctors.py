# /backend-flask/app/api/v2/doctors.py
# Endpoints de doctores v2 (versión final y completa).
# Este blueprint se enfoca en el doctor como un usuario autenticado,
# permitiéndole gestionar su perfil y los pacientes a su cargo.

from flask import Blueprint, request, jsonify, g
from app.middleware.jwt_middleware import require_session
from app.db import get_db_connection 
import logging
import psycopg2
import psycopg2.extras

logger = logging.getLogger(__name__)

# Crear blueprint v2 para doctores
doctors_bp = Blueprint('doctors', __name__, url_prefix='/api/v1/doctors')

# --- Endpoints Públicos o Semi-Públicos ---

@doctors_bp.route('/', methods=['GET'])
def list_doctors():
    """
    Lista todos los doctores activos con paginación y búsqueda.
    Útil para que los pacientes o administradores busquen doctores.
    """
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)
    search = request.args.get('search', '')
    offset = (page - 1) * limit
    
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                query = """
                    SELECT id, first_name, last_name, specialty, specialty_category, 
                           institution_name, institution_city, years_experience
                    FROM vw_doctor_performance 
                    WHERE (first_name ILIKE %s OR last_name ILIKE %s OR specialty ILIKE %s)
                    ORDER BY last_name, first_name LIMIT %s OFFSET %s;
                """
                cur.execute(query, (f'%{search}%', f'%{search}%', f'%{search}%', limit, offset))
                doctors = [dict(row) for row in cur.fetchall()]
                
                cur.execute("SELECT COUNT(*) FROM doctors WHERE is_active = TRUE AND (first_name ILIKE %s OR last_name ILIKE %s);", (f'%{search}%', f'%{search}%'))
                total_records = cur.fetchone()[0]
                
                return jsonify({
                    'data': doctors,
                    'pagination': {
                        'total_records': total_records,
                        'current_page': page,
                        'total_pages': (total_records + limit - 1) // limit,
                        'limit': limit
                    }
                })
    except Exception as e:
        logger.error(f"❌ Error listando doctores: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Endpoints para el Doctor Autenticado ---

@doctors_bp.route('/profile', methods=['GET'])
@require_session(allowed_roles=['doctor'])
def get_doctor_profile():
    """Obtiene el perfil completo del doctor actualmente autenticado."""
    try:
        doctor_id = g.user['reference_id']
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                cur.execute("SELECT * FROM vw_doctor_performance WHERE id = %s;", (doctor_id,))
                doctor_profile = cur.fetchone()
                if not doctor_profile:
                    return jsonify({'error': 'Doctor profile not found'}), 404
                return jsonify(dict(doctor_profile))
    except Exception as e:
        logger.error(f"❌ Error obteniendo perfil de doctor: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@doctors_bp.route('/profile', methods=['PUT'])
@require_session(allowed_roles=['doctor'])
def update_doctor_profile():
    """Actualiza el perfil del doctor actualmente autenticado."""
    doctor_id = g.user['reference_id']
    data = request.get_json()
    
    allowed_fields = ['first_name', 'last_name', 'specialty_id', 'years_experience', 'consultation_fee', 'sex_id', 'gender_id']
    update_fields = {key: data[key] for key in allowed_fields if key in data}
    if not update_fields:
        return jsonify({'error': 'No valid fields to update provided'}), 400
        
    set_clause = ", ".join([f"{key} = %s" for key in update_fields.keys()])
    values = list(update_fields.values())
    values.append(doctor_id)
    
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(f"UPDATE doctors SET {set_clause} WHERE id = %s;", values)
                if cur.rowcount == 0:
                    return jsonify({'error': 'Profile not found or no changes made'}), 404
                conn.commit()
                return jsonify({'message': 'Profile updated successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error actualizando perfil de doctor: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@doctors_bp.route('/institution', methods=['GET'])
@require_session(allowed_roles=['doctor'])
def get_doctor_institution():
    """Obtiene los detalles de la institución a la que pertenece el doctor."""
    doctor_id = g.user['reference_id']
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # Primero, obtener el ID de la institución del doctor
                cur.execute("SELECT institution_id FROM doctors WHERE id = %s;", (doctor_id,))
                result = cur.fetchone()
                if not result:
                    return jsonify({'error': 'Doctor not found'}), 404
                institution_id = result['institution_id']

                # Luego, usar el endpoint de instituciones para obtener los detalles
                # (En una app real, esto podría ser una llamada interna o reutilizar la lógica)
                cur.execute("SELECT * FROM medical_institutions WHERE id = %s;", (institution_id,))
                institution = cur.fetchone()
                if not institution:
                    return jsonify({'error': 'Institution not found'}), 404
                
                return jsonify(dict(institution))
    except Exception as e:
        logger.error(f"❌ Error obteniendo institución del doctor: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Gestión de Pacientes por el Doctor ---

@doctors_bp.route('/patients', methods=['GET'])
@require_session(allowed_roles=['doctor'])
def list_doctor_patients():
    """Lista los pacientes asignados al doctor autenticado."""
    doctor_id = g.user['reference_id']
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                cur.execute("SELECT id, first_name, last_name, email, age, diagnosed_conditions FROM vw_patient_demographics WHERE doctor_id = %s;", (doctor_id,))
                patients = [dict(row) for row in cur.fetchall()]
                return jsonify(patients)
    except Exception as e:
        logger.error(f"❌ Error listando pacientes del doctor: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@doctors_bp.route('/patients', methods=['POST'])
@require_session(allowed_roles=['doctor'])
def create_patient_for_doctor():
    """Crea un nuevo paciente y lo asigna al doctor autenticado y su institución."""
    doctor_id = g.user['reference_id']
    data = request.get_json()
    if not data or not all(k in data for k in ['first_name', 'last_name', 'date_of_birth', 'email', 'password']):
        return jsonify({'error': 'Missing required fields for patient'}), 400

    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            # Obtener la institución del doctor para asegurar la consistencia
            cur.execute("SELECT institution_id FROM doctors WHERE id = %s;", (doctor_id,))
            result = cur.fetchone()
            if not result:
                return jsonify({'error': 'Doctor performing action not found'}), 404
            institution_id = result[0]

            # Iniciar transacción
            cur.execute(
                "INSERT INTO patients (first_name, last_name, date_of_birth, doctor_id, institution_id, sex_id, gender_id) VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id;",
                (data['first_name'], data['last_name'], data['date_of_birth'], doctor_id, institution_id, data.get('sex_id'), data.get('gender_id'))
            )
            patient_id = cur.fetchone()[0]

            cur.execute("INSERT INTO users (email, password_hash, user_type, reference_id) VALUES (%s, %s, 'patient', %s);", (data['email'], data['password'], patient_id))
            cur.execute("INSERT INTO emails (entity_type, entity_id, email_address, is_primary, email_type_id) VALUES ('patient', %s, %s, TRUE, (SELECT id FROM email_types WHERE name = 'primary'));", (patient_id, data['email']))
            cur.execute("INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type_id) VALUES (%s, %s, %s, %s);", (patient_id, data.get('height_cm'), data.get('weight_kg'), data.get('blood_type_id')))

            conn.commit()
            return jsonify({'message': 'Patient created and assigned successfully', 'patient_id': str(patient_id)}), 201
    except psycopg2.errors.UniqueViolation:
        if conn: conn.rollback()
        return jsonify({'error': 'A user with this email already exists'}), 409
    except Exception as e:
        if conn: conn.rollback()
        logger.error(f"❌ Error creando paciente para doctor: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500
    finally:
        if conn: conn.close()

@doctors_bp.route('/patients/<uuid:patient_id>', methods=['GET'])
@require_session(allowed_roles=['doctor'])
def get_doctor_patient_details(patient_id):
    """Obtiene los detalles de un paciente específico, validando que esté asignado al doctor."""
    doctor_id = g.user['reference_id']
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # Validación de seguridad: El paciente debe estar asignado al doctor
                cur.execute("SELECT id FROM patients WHERE id = %s AND doctor_id = %s;", (str(patient_id), doctor_id))
                if not cur.fetchone():
                    return jsonify({'error': 'Patient not found or not assigned to you'}), 404
                
                # Si la validación pasa, se reutiliza la lógica del endpoint de pacientes
                # (En una arquitectura real, esto sería una llamada a una función de servicio compartida)
                cur.execute("SELECT * FROM vw_patient_demographics WHERE id = %s;", (str(patient_id),))
                patient_details = dict(cur.fetchone())
                
                # ... (se podrían agregar las demás consultas para la vista 360° completa) ...
                
                return jsonify(patient_details)
    except Exception as e:
        logger.error(f"❌ Error obteniendo detalles de paciente para doctor: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500