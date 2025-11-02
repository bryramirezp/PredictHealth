# /backend-flask/app/api/v2/patients.py
# Endpoints de pacientes v2 (versión final), alineados con la base de datos 3NF.
# Incluye lógica de negocio, acceso directo a la BD, seguridad y completitud de datos.

from flask import Blueprint, request, jsonify, g
from app.middleware.jwt_middleware import require_session
from app.db import get_db_connection 
import logging
import psycopg2
import psycopg2.extras

logger = logging.getLogger(__name__)

# Crear blueprint v2 para pacientes
patients_bp = Blueprint('patients', __name__, url_prefix='/api/v1/patients')

# --- CRUD Principal del Paciente ---

@patients_bp.route('/', methods=['POST'])
@require_session
def create_patient():
    """
    Crea un nuevo paciente, su perfil de salud básico, su usuario y su contacto principal.
    Este endpoint es transaccional.
    """
    data = request.get_json()
    if not data or not all(k in data for k in ['first_name', 'last_name', 'date_of_birth', 'doctor_id', 'institution_id', 'email', 'password']):
        return jsonify({'error': 'Missing required fields'}), 400

    conn = None
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            # 1. Validar que el doctor pertenece a la institución (regla de negocio)
            cur.execute(
                "SELECT institution_id FROM doctors WHERE id = %s", (data['doctor_id'],)
            )
            doctor_record = cur.fetchone()
            if not doctor_record or str(doctor_record[0]) != data['institution_id']:
                return jsonify({'error': 'Doctor does not belong to the specified institution'}), 400

            # Iniciar transacción
            # 2. Insertar en la tabla 'patients'
            cur.execute(
                """
                INSERT INTO patients (first_name, last_name, date_of_birth, doctor_id, institution_id, sex_id, gender_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id;
                """,
                (
                    data['first_name'], data['last_name'], data['date_of_birth'],
                    data['doctor_id'], data['institution_id'],
                    data.get('sex_id'), data.get('gender_id')
                )
            )
            patient_id = cur.fetchone()[0]

            # 3. Crear el usuario asociado en la tabla 'users'
            # NOTA: En una app real, la contraseña se hashearía antes de llegar aquí.
            cur.execute(
                """
                INSERT INTO users (email, password_hash, user_type, reference_id)
                VALUES (%s, %s, 'patient', %s);
                """,
                (data['email'], data['password'], patient_id)
            )

            # 4. Insertar el email principal
            cur.execute(
                """
                INSERT INTO emails (entity_type, entity_id, email_address, is_primary, email_type_id)
                VALUES ('patient', %s, %s, TRUE, (SELECT id FROM email_types WHERE name = 'primary'));
                """,
                (patient_id, data['email'])
            )

            # 5. Crear perfil de salud (con datos si se proporcionan)
            cur.execute(
                """
                INSERT INTO health_profiles (patient_id, height_cm, weight_kg, blood_type_id)
                VALUES (%s, %s, %s, %s);
                """,
                (
                    patient_id, data.get('height_cm'), data.get('weight_kg'), data.get('blood_type_id')
                )
            )

            conn.commit()
            
            return jsonify({
                'message': 'Patient created successfully',
                'patient_id': str(patient_id)
            }), 201

    except psycopg2.errors.UniqueViolation:
        if conn:
            conn.rollback()
        return jsonify({'error': 'A user with this email already exists'}), 409
    except Exception as e:
        if conn:
            conn.rollback()
        logger.error(f"❌ Error creando paciente: {str(e)}")
        return jsonify({'error': 'Internal server error', 'message': str(e)}), 500
    finally:
        if conn:
            conn.close()

@patients_bp.route('/', methods=['GET'])
@require_session
def list_patients():
    """
    Lista pacientes usando la vista optimizada 'vw_patient_demographics'.
    Permite paginación y búsqueda.
    """
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)
    search = request.args.get('search', '')
    offset = (page - 1) * limit
    
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                query = "SELECT * FROM vw_patient_demographics WHERE (first_name ILIKE %s OR last_name ILIKE %s OR email ILIKE %s) ORDER BY last_name, first_name LIMIT %s OFFSET %s;"
                cur.execute(query, (f'%{search}%', f'%{search}%', f'%{search}%', limit, offset))
                patients = [dict(row) for row in cur.fetchall()]
                
                cur.execute("SELECT COUNT(*) FROM patients WHERE is_active = TRUE AND (first_name ILIKE %s OR last_name ILIKE %s);", (f'%{search}%', f'%{search}%'))
                total_records = cur.fetchone()[0]
                
                return jsonify({
                    'data': patients,
                    'pagination': {
                        'total_records': total_records,
                        'current_page': page,
                        'total_pages': (total_records + limit - 1) // limit,
                        'limit': limit
                    }
                })
    except Exception as e:
        logger.error(f"❌ Error listando pacientes v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@patients_bp.route('/<uuid:patient_id>', methods=['GET'])
@require_session
def get_patient_details(patient_id):
    """
    Obtiene una vista completa y SEGURA de 360° de un paciente.
    Este endpoint ahora incluye autorización para asegurar que un paciente
    solo pueda ver su propia información.
    """
    if 'user' not in g:
        return jsonify({'error': 'Authentication context not found'}), 500

    # Lógica de autorización: Un paciente solo puede ver sus propios datos.
    if g.user['user_type'] == 'patient' and g.user['reference_id'] != str(patient_id):
        return jsonify({'error': 'Forbidden. You can only access your own patient data.'}), 403

    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # a. Obtener datos demográficos desde la vista
                cur.execute("SELECT * FROM vw_patient_demographics WHERE id = %s;", (str(patient_id),))
                patient_data = cur.fetchone()
                if not patient_data:
                    return jsonify({'error': 'Patient not found'}), 404
                
                patient_details = dict(patient_data)

                # b. Obtener el perfil de salud completo
                cur.execute("SELECT * FROM health_profiles WHERE patient_id = %s;", (str(patient_id),))
                health_profile_data = cur.fetchone()
                if health_profile_data:
                    patient_details['health_profile'] = {k: v for k, v in dict(health_profile_data).items() if k != 'patient_id'}

                # c. Obtener TODA la información de contacto
                cur.execute("SELECT email_address, is_primary, et.name as type FROM emails e JOIN email_types et ON e.email_type_id = et.id WHERE entity_type = 'patient' AND entity_id = %s;", (str(patient_id),))
                patient_details['contact_emails'] = [dict(row) for row in cur.fetchall()]
                
                cur.execute("SELECT phone_number, is_primary, pt.name as type FROM phones p JOIN phone_types pt ON p.phone_type_id = pt.id WHERE entity_type = 'patient' AND entity_id = %s;", (str(patient_id),))
                patient_details['contact_phones'] = [dict(row) for row in cur.fetchall()]

                # d. Obtener las direcciones del PACIENTE
                cur.execute("SELECT street_address, city, postal_code, address_type, is_primary FROM addresses WHERE entity_type = 'patient' AND entity_id = %s;", (str(patient_id),))
                patient_details['addresses'] = [dict(row) for row in cur.fetchall()]

                # e. Obtener historial médico familiar
                cur.execute("""
                    SELECT mc.name as condition, pfh.relative_type, pfh.notes
                    FROM patient_family_history pfh
                    JOIN medical_conditions mc ON pfh.condition_id = mc.id
                    WHERE pfh.patient_id = %s;
                """, (str(patient_id),))
                patient_details['family_history'] = [dict(row) for row in cur.fetchall()]

                # f. Obtener condiciones, medicamentos y alergias
                cur.execute("""
                    SELECT mc.name, pc.diagnosis_date, pc.notes
                    FROM patient_conditions pc JOIN medical_conditions mc ON pc.condition_id = mc.id
                    WHERE pc.patient_id = %s;
                """, (str(patient_id),))
                patient_details['conditions'] = [dict(row) for row in cur.fetchall()]

                cur.execute("""
                    SELECT m.name, pm.dosage, pm.frequency, pm.start_date
                    FROM patient_medications pm JOIN medications m ON pm.medication_id = m.id
                    WHERE pm.patient_id = %s;
                """, (str(patient_id),))
                patient_details['medications'] = [dict(row) for row in cur.fetchall()]

                cur.execute("""
                    SELECT a.name, pa.severity, pa.reaction_description
                    FROM patient_allergies pa JOIN allergies a ON pa.allergy_id = a.id
                    WHERE pa.patient_id = %s;
                """, (str(patient_id),))
                patient_details['allergies'] = [dict(row) for row in cur.fetchall()]
                
                return jsonify(patient_details)
                
    except Exception as e:
        logger.error(f"❌ Error obteniendo detalles completos de paciente v2.1: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@patients_bp.route('/<uuid:patient_id>', methods=['PUT'])
@require_session
def update_patient_core_data(patient_id):
    """
    Actualiza los datos centrales de un paciente (tabla 'patients').
    """
    data = request.get_json()
    allowed_fields = ['first_name', 'last_name', 'date_of_birth', 'sex_id', 'gender_id', 'emergency_contact_name']
    
    update_fields = {key: data[key] for key in allowed_fields if key in data}
    if not update_fields:
        return jsonify({'error': 'No valid fields to update provided'}), 400
        
    set_clause = ", ".join([f"{key} = %s" for key in update_fields.keys()])
    values = list(update_fields.values())
    values.append(str(patient_id))
    
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(f"UPDATE patients SET {set_clause} WHERE id = %s;", values)
                if cur.rowcount == 0:
                    return jsonify({'error': 'Patient not found or no changes made'}), 404
                conn.commit()
                return jsonify({'message': 'Patient updated successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error actualizando paciente v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@patients_bp.route('/<uuid:patient_id>', methods=['DELETE'])
@require_session
def delete_patient(patient_id):
    """
    Realiza una eliminación lógica (soft delete) del paciente y su usuario asociado.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Desactivar al paciente
                cur.execute("UPDATE patients SET is_active = FALSE WHERE id = %s;", (str(patient_id),))
                if cur.rowcount == 0:
                    return jsonify({'error': 'Patient not found'}), 404
                
                # Desactivar al usuario asociado
                cur.execute("UPDATE users SET is_active = FALSE WHERE reference_id = %s AND user_type = 'patient';", (str(patient_id),))
                
                conn.commit()
                return jsonify({'message': 'Patient deactivated successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error eliminando lógicamente paciente v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Endpoints Anidados para Datos de Salud ---

# --- Condiciones ---
@patients_bp.route('/<uuid:patient_id>/conditions', methods=['POST'])
@require_session
def add_patient_condition(patient_id):
    data = request.get_json()
    if not data or 'condition_id' not in data:
        return jsonify({'error': 'Missing condition_id'}), 400
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO patient_conditions (patient_id, condition_id, diagnosis_date, notes) VALUES (%s, %s, %s, %s);", (str(patient_id), data['condition_id'], data.get('diagnosis_date'), data.get('notes')))
                conn.commit()
                return jsonify({'message': 'Condition added successfully'}), 201
    except psycopg2.errors.ForeignKeyViolation:
         return jsonify({'error': 'Patient or condition not found'}), 404
    except psycopg2.errors.UniqueViolation:
        return jsonify({'error': 'Patient already has this condition'}), 409
    except Exception as e:
        logger.error(f"❌ Error agregando condición: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@patients_bp.route('/<uuid:patient_id>/conditions/<int:condition_id>', methods=['DELETE'])
@require_session
def remove_patient_condition(patient_id, condition_id):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM patient_conditions WHERE patient_id = %s AND condition_id = %s;", (str(patient_id), condition_id))
                if cur.rowcount == 0:
                    return jsonify({'error': 'Association not found'}), 404
                conn.commit()
                return jsonify({'message': 'Condition removed successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error eliminando condición: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Medicamentos ---
@patients_bp.route('/<uuid:patient_id>/medications', methods=['POST'])
@require_session
def add_patient_medication(patient_id):
    data = request.get_json()
    if not data or 'medication_id' not in data:
        return jsonify({'error': 'Missing medication_id'}), 400
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO patient_medications (patient_id, medication_id, dosage, frequency, start_date) VALUES (%s, %s, %s, %s, %s);", (str(patient_id), data['medication_id'], data.get('dosage'), data.get('frequency'), data.get('start_date')))
                conn.commit()
                return jsonify({'message': 'Medication added successfully'}), 201
    except psycopg2.errors.ForeignKeyViolation:
         return jsonify({'error': 'Patient or medication not found'}), 404
    except psycopg2.errors.UniqueViolation:
        return jsonify({'error': 'Patient already has this medication'}), 409
    except Exception as e:
        logger.error(f"❌ Error agregando medicamento: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@patients_bp.route('/<uuid:patient_id>/medications/<int:medication_id>', methods=['DELETE'])
@require_session
def remove_patient_medication(patient_id, medication_id):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM patient_medications WHERE patient_id = %s AND medication_id = %s;", (str(patient_id), medication_id))
                if cur.rowcount == 0:
                    return jsonify({'error': 'Association not found'}), 404
                conn.commit()
                return jsonify({'message': 'Medication removed successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error eliminando medicamento: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Alergias ---
@patients_bp.route('/<uuid:patient_id>/allergies', methods=['POST'])
@require_session
def add_patient_allergy(patient_id):
    data = request.get_json()
    if not data or 'allergy_id' not in data:
        return jsonify({'error': 'Missing allergy_id'}), 400
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("INSERT INTO patient_allergies (patient_id, allergy_id, severity, reaction_description) VALUES (%s, %s, %s, %s);", (str(patient_id), data['allergy_id'], data.get('severity'), data.get('reaction_description')))
                conn.commit()
                return jsonify({'message': 'Allergy added successfully'}), 201
    except psycopg2.errors.ForeignKeyViolation:
         return jsonify({'error': 'Patient or allergy not found'}), 404
    except psycopg2.errors.UniqueViolation:
        return jsonify({'error': 'Patient already has this allergy'}), 409
    except Exception as e:
        logger.error(f"❌ Error agregando alergia: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@patients_bp.route('/<uuid:patient_id>/allergies/<int:allergy_id>', methods=['DELETE'])
@require_session
def remove_patient_allergy(patient_id, allergy_id):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM patient_allergies WHERE patient_id = %s AND allergy_id = %s;", (str(patient_id), allergy_id))
                if cur.rowcount == 0:
                    return jsonify({'error': 'Association not found'}), 404
                conn.commit()
                return jsonify({'message': 'Allergy removed successfully'}), 200
    except Exception as e:
        logger.error(f"❌ Error eliminando alergia: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

# --- Endpoints de Estadísticas ---

@patients_bp.route('/statistics/prevalence', methods=['GET'])
@require_session
def get_condition_prevalence():
    """
    Obtiene estadísticas de prevalencia de condiciones usando la vista 'vw_health_condition_prevalence'.
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                cur.execute("SELECT * FROM vw_health_condition_prevalence ORDER BY patient_count DESC;")
                stats = [dict(row) for row in cur.fetchall()]
                return jsonify(stats)
    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas de prevalencia v2: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500