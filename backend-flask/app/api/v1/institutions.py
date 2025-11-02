# /backend-flask/app/api/v2/institutions.py
# Endpoints de instituciones v2 (versión final y completa).
# Este blueprint actúa como un centro de mando para gestionar la institución,
# así como los doctores y pacientes asociados a ella.

from flask import Blueprint, request, jsonify, g
from app.middleware.jwt_middleware import require_session
from app.db import get_db_connection 
import logging
import psycopg2
import psycopg2.extras

logger = logging.getLogger(__name__)

# Crear blueprint v2 para instituciones
institutions_bp= Blueprint('institutions', __name__, url_prefix='/api/v1institutions')

# --- CRUD Principal de la Institución ---

@institutions_bp.route('/', methods=['POST'])
@require_session
def create_institution():
    """Crea una nueva institución, su usuario asociado y contactos principales (Transaccional)."""
    data = request.get_json()
    required_fields = ['name', 'institution_type_id', 'license_number', 'email', 'password', 'address']
    if not data or not all(k in data for k in required_fields):
        return jsonify({'error': 'Missing required fields'}), 400
    if not isinstance(data['address'], dict) or not all(k in data['address'] for k in ['street_address', 'city', 'region_name', 'country_iso']):
         return jsonify({'error': 'Invalid address format'}), 400

    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("INSERT INTO medical_institutions (name, institution_type_id, license_number, website) VALUES (%s, %s, %s, %s) RETURNING id;", (data['name'], data['institution_type_id'], data['license_number'], data.get('website')))
            institution_id = cur.fetchone()[0]

            cur.execute("INSERT INTO users (email, password_hash, user_type, reference_id) VALUES (%s, %s, 'institution', %s);", (data['email'], data['password'], institution_id))
            
            addr = data['address']
            cur.execute("SELECT add_entity_address('institution', %s, %s, %s, %s, %s, %s, 'primary', TRUE);", (institution_id, addr['street_address'], addr['city'], addr['region_name'], addr['country_iso'], addr.get('postal_code')))
            cur.execute("SELECT add_entity_email('institution', %s, %s, 'primary', TRUE);", (institution_id, data['email']))
            if 'phone' in data:
                cur.execute("SELECT add_entity_phone('institution', %s, %s, 'primary', TRUE);", (institution_id, data['phone']))

            conn.commit()
            return jsonify({'message': 'Institution created successfully', 'institution_id': str(institution_id)}), 201
    except psycopg2.errors.UniqueViolation:
        if conn: conn.rollback()
        return jsonify({'error': 'Institution with this license number or email already exists'}), 409
    except Exception as e:
        if conn: conn.rollback()
        logger.error(f"❌ Error creando institución: {str(e)}")
        return jsonify({'error': 'Internal server error', 'message': str(e)}), 500
    finally:
        if conn: conn.close()

@institutions_bp.route('/', methods=['GET'])
def list_institutions():
    """Lista instituciones con paginación y búsqueda."""
    page, limit, search = request.args.get('page', 1, type=int), request.args.get('limit', 10, type=int), request.args.get('search', '')
    offset = (page - 1) * limit
    try:
        with get_db_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            query = """
                SELECT mi.id, mi.name, mi.website, it.name AS institution_type, addr.city, r.name AS region
                FROM medical_institutions mi
                JOIN institution_types it ON mi.institution_type_id = it.id
                LEFT JOIN addresses addr ON mi.id = addr.entity_id AND addr.entity_type = 'institution' AND addr.is_primary = TRUE
                LEFT JOIN regions r ON addr.region_id = r.id
                WHERE mi.is_active = TRUE AND mi.name ILIKE %s ORDER BY mi.name LIMIT %s OFFSET %s;
            """
            cur.execute(query, (f'%{search}%', limit, offset))
            institutions = [dict(row) for row in cur.fetchall()]
            cur.execute("SELECT COUNT(*) FROM medical_institutions WHERE is_active = TRUE AND name ILIKE %s;", (f'%{search}%',))
            total_records = cur.fetchone()[0]
            return jsonify({'data': institutions, 'pagination': {'total_records': total_records, 'current_page': page, 'total_pages': (total_records + limit - 1) // limit, 'limit': limit}})
    except Exception as e:
        logger.error(f"❌ Error listando instituciones v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@institutions_bp.route('/<uuid:institution_id>', methods=['GET'])
def get_institution_details(institution_id):
    """Obtiene una vista completa de 360° de una institución."""
    try:
        with get_db_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT mi.*, it.name as institution_type_name FROM medical_institutions mi JOIN institution_types it ON mi.institution_type_id = it.id WHERE mi.id = %s AND mi.is_active = TRUE;", (str(institution_id),))
            institution_data = cur.fetchone()
            if not institution_data: return jsonify({'error': 'Institution not found'}), 404
            
            details = dict(institution_data)
            cur.execute("SELECT * FROM get_primary_address('institution', %s);", (str(institution_id),))
            address = cur.fetchone()
            details['primary_address'] = dict(address) if address else None
            cur.execute("SELECT get_primary_email('institution', %s);", (str(institution_id),))
            details['primary_email'] = cur.fetchone()[0]
            cur.execute("SELECT get_primary_phone('institution', %s);", (str(institution_id),))
            details['primary_phone'] = cur.fetchone()[0]
            return jsonify(details)
    except Exception as e:
        logger.error(f"❌ Error obteniendo detalles de institución v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@institutions_bp.route('/<uuid:institution_id>', methods=['PUT'])
@require_session
def update_institution(institution_id):
    """Actualiza los datos centrales de una institución."""
    data = request.get_json()
    allowed_fields = ['name', 'website', 'institution_type_id']
    update_fields = {key: data[key] for key in allowed_fields if key in data}
    if not update_fields: return jsonify({'error': 'No valid fields to update provided'}), 400
    
    set_clause = ", ".join([f"{key} = %s" for key in update_fields.keys()])
    values = list(update_fields.values())
    values.append(str(institution_id))
    
    try:
        with get_db_connection() as conn, conn.cursor() as cur:
            cur.execute(f"UPDATE medical_institutions SET {set_clause} WHERE id = %s;", values)
            if cur.rowcount == 0: return jsonify({'error': 'Institution not found or no changes made'}), 404
            conn.commit()
            return jsonify({'message': 'Institution updated successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error actualizando institución v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@institutions_bp.route('/<uuid:institution_id>', methods=['DELETE'])
@require_session
def delete_institution(institution_id):
    """Realiza una eliminación lógica de la institución y su usuario asociado."""
    try:
        with get_db_connection() as conn, conn.cursor() as cur:
            cur.execute("UPDATE medical_institutions SET is_active = FALSE WHERE id = %s;", (str(institution_id),))
            if cur.rowcount == 0: return jsonify({'error': 'Institution not found'}), 404
            cur.execute("UPDATE users SET is_active = FALSE WHERE reference_id = %s AND user_type = 'institution';", (str(institution_id),))
            conn.commit()
            return jsonify({'message': 'Institution deactivated successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error eliminando lógicamente institución v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Gestión Anidada de Doctores ---

@institutions_bp.route('/<uuid:institution_id>/doctors', methods=['POST'])
@require_session
def create_doctor_in_institution(institution_id):
    """Crea un nuevo doctor para esta institución (Transaccional)."""
    data = request.get_json()
    required_fields = ['first_name', 'last_name', 'medical_license', 'email', 'password']
    if not data or not all(k in data for k in required_fields):
        return jsonify({'error': 'Missing required fields for doctor'}), 400

    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            # Insertar doctor, asociándolo a la institución de la URL
            cur.execute("""
                INSERT INTO doctors (first_name, last_name, medical_license, institution_id, specialty_id, years_experience, consultation_fee, sex_id, gender_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING id;
            """, (data['first_name'], data['last_name'], data['medical_license'], str(institution_id), data.get('specialty_id'), data.get('years_experience'), data.get('consultation_fee'), data.get('sex_id'), data.get('gender_id')))
            doctor_id = cur.fetchone()[0]

            # Crear usuario para el doctor
            cur.execute("INSERT INTO users (email, password_hash, user_type, reference_id) VALUES (%s, %s, 'doctor', %s);", (data['email'], data['password'], doctor_id))
            cur.execute("SELECT add_entity_email('doctor', %s, %s, 'primary', TRUE);", (doctor_id, data['email']))

            conn.commit()
            return jsonify({'message': 'Doctor created and associated successfully', 'doctor_id': str(doctor_id)}), 201
    except psycopg2.errors.ForeignKeyViolation:
        if conn: conn.rollback()
        return jsonify({'error': 'Institution not found'}), 404
    except psycopg2.errors.UniqueViolation:
        if conn: conn.rollback()
        return jsonify({'error': 'Doctor with this medical license or email already exists'}), 409
    except Exception as e:
        if conn: conn.rollback()
        logger.error(f"❌ Error creando doctor en institución: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500
    finally:
        if conn: conn.close()

@institutions_bp.route('/<uuid:institution_id>/doctors', methods=['GET'])
@require_session
def list_institution_doctors(institution_id):
    """Lista los doctores activos de una institución."""
    try:
        with get_db_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT id, first_name, last_name, specialty, years_experience, consultation_fee FROM vw_doctor_performance WHERE institution_id = %s;", (str(institution_id),))
            return jsonify([dict(row) for row in cur.fetchall()])
    except Exception as e:
        logger.error(f"❌ Error listando doctores de institución v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@institutions_bp.route('/<uuid:institution_id>/doctors/<uuid:doctor_id>', methods=['GET'])
@require_session
def get_institution_doctor_details(institution_id, doctor_id):
    """Obtiene detalles de un doctor, validando que pertenece a la institución."""
    try:
        with get_db_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT * FROM vw_doctor_performance WHERE id = %s AND institution_id = %s;", (str(doctor_id), str(institution_id)))
            doctor = cur.fetchone()
            if not doctor:
                return jsonify({'error': 'Doctor not found or does not belong to this institution'}), 404
            return jsonify(dict(doctor))
    except Exception as e:
        logger.error(f"❌ Error obteniendo detalles de doctor de institución: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Gestión Anidada de Pacientes ---

@institutions_bp.route('/<uuid:institution_id>/patients', methods=['GET'])
@require_session
def list_institution_patients(institution_id):
    """Lista los pacientes activos de una institución."""
    try:
        with get_db_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT id, first_name, last_name, email, age, doctor_first_name, doctor_last_name FROM vw_patient_demographics WHERE institution_id = %s;", (str(institution_id),))
            return jsonify([dict(row) for row in cur.fetchall()])
    except Exception as e:
        logger.error(f"❌ Error listando pacientes de institución v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@institutions_bp.route('/<uuid:institution_id>/patients/<uuid:patient_id>', methods=['GET'])
@require_session
def get_institution_patient_details(institution_id, patient_id):
    """
    Obtiene la vista 360° de un paciente, validando que pertenece a la institución.
    NOTA: La lógica es una réplica del endpoint de pacientes, con una validación adicional.
    En una arquitectura de microservicios, esto podría ser una llamada a ese servicio.
    """
    try:
        with get_db_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            # Validación clave: el paciente debe pertenecer a la institución
            cur.execute("SELECT * FROM vw_patient_demographics WHERE id = %s AND institution_id = %s;", (str(patient_id), str(institution_id)))
            patient_data = cur.fetchone()
            if not patient_data:
                return jsonify({'error': 'Patient not found or does not belong to this institution'}), 404
            
            # Reutilizar la lógica de 'get_patient_details' para obtener la vista 360°
            patient_details = dict(patient_data)
            cur.execute("SELECT * FROM health_profiles WHERE patient_id = %s;", (str(patient_id),))
            health_profile_data = cur.fetchone()
            if health_profile_data:
                patient_details['health_profile'] = {k: v for k, v in dict(health_profile_data).items() if k != 'patient_id'}
            
            cur.execute("SELECT mc.name as condition, pfh.relative_type, pfh.notes FROM patient_family_history pfh JOIN medical_conditions mc ON pfh.condition_id = mc.id WHERE pfh.patient_id = %s;", (str(patient_id),))
            patient_details['family_history'] = [dict(row) for row in cur.fetchall()]
            
            cur.execute("SELECT mc.name, pc.diagnosis_date, pc.notes FROM patient_conditions pc JOIN medical_conditions mc ON pc.condition_id = mc.id WHERE pc.patient_id = %s;", (str(patient_id),))
            patient_details['conditions'] = [dict(row) for row in cur.fetchall()]
            
            return jsonify(patient_details)
    except Exception as e:
        logger.error(f"❌ Error obteniendo detalles de paciente de institución: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Endpoints de Analíticas ---

@institutions_bp.route('/<uuid:institution_id>/analytics', methods=['GET'])
@require_session
def get_institution_analytics(institution_id):
    """Obtiene KPIs y analíticas para una institución específica."""
    try:
        with get_db_connection() as conn, conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            cur.execute("SELECT 1 FROM medical_institutions WHERE id = %s AND is_active = TRUE;", (str(institution_id),))
            if not cur.fetchone(): return jsonify({'error': 'Institution not found'}), 404

            queries = {
                "patient_count": "SELECT COUNT(*) FROM patients WHERE institution_id = %s AND is_active = TRUE;",
                "doctor_count": "SELECT COUNT(*) FROM doctors WHERE institution_id = %s AND is_active = TRUE;",
                "avg_consultation_fee": "SELECT AVG(consultation_fee) FROM doctors WHERE institution_id = %s AND is_active = TRUE;",
                "most_common_specialty": """
                    SELECT ds.name FROM doctors d JOIN doctor_specialties ds ON d.specialty_id = ds.id
                    WHERE d.institution_id = %s AND d.is_active = TRUE
                    GROUP BY ds.name ORDER BY COUNT(*) DESC LIMIT 1;
                """
            }
            analytics = {}
            for key, query in queries.items():
                cur.execute(query, (str(institution_id),))
                result = cur.fetchone()[0]
                analytics[key] = float(result) if hasattr(result, 'is_normal') else result

            return jsonify(analytics)
    except Exception as e:
        logger.error(f"❌ Error obteniendo analíticas de institución v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500