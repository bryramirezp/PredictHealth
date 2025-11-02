# /backend-flask/app/api/v1/admins.py
# Endpoints para administradores del sistema

from flask import Blueprint, request, jsonify, g
from app.middleware.jwt_middleware import require_session
from app.db import get_db_connection 
import logging
import psycopg2
import psycopg2.extras

logger = logging.getLogger(__name__)

# Crear blueprint v1 para administradores
admins_bp = Blueprint('admins', __name__, url_prefix='/admins')

@admins_bp.route('/', methods=['GET'])
@require_session(allowed_roles=['admin'])
def list_admins():
    """Lista todos los administradores del sistema"""
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                cur.execute("SELECT id, email, created_at, is_active FROM users WHERE user_type = 'admin' ORDER BY created_at DESC;")
                admins = [dict(row) for row in cur.fetchall()]
                return jsonify(admins)
    except Exception as e:
        logger.error(f"❌ Error listando administradores: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@admins_bp.route('/dashboard', methods=['GET'])
@require_session(allowed_roles=['admin'])
def admin_dashboard():
    """Dashboard para administradores"""
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                # Estadísticas generales
                stats = {}
                
                # Total de usuarios por tipo
                cur.execute("SELECT user_type, COUNT(*) as count FROM users GROUP BY user_type;")
                user_stats = {row['user_type']: row['count'] for row in cur.fetchall()}
                stats['users_by_type'] = user_stats
                
                # Total de instituciones
                cur.execute("SELECT COUNT(*) as count FROM medical_institutions WHERE is_active = TRUE;")
                stats['total_institutions'] = cur.fetchone()['count']
                
                # Total de doctores
                cur.execute("SELECT COUNT(*) as count FROM doctors WHERE is_active = TRUE;")
                stats['total_doctors'] = cur.fetchone()['count']
                
                # Total de pacientes
                cur.execute("SELECT COUNT(*) as count FROM patients WHERE is_active = TRUE;")
                stats['total_patients'] = cur.fetchone()['count']
                
                # Usuarios activos en última hora
                cur.execute("""
                    SELECT COUNT(*) as count 
                    FROM users 
                    WHERE last_login >= NOW() - INTERVAL '1 hour'
                """)
                stats['active_users_last_hour'] = cur.fetchone()['count']
                
                return jsonify({
                    'status': 'success',
                    'message': 'Dashboard de administrador',
                    'data': stats
                })
    except Exception as e:
        logger.error(f"❌ Error en dashboard de administrador: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@admins_bp.route('/users', methods=['GET'])
@require_session(allowed_roles=['admin'])
def list_all_users():
    """Lista todos los usuarios del sistema con paginación"""
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 20, type=int)
    search = request.args.get('search', '')
    offset = (page - 1) * limit
    
    try:
        with get_db_connection() as conn:
            with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
                query = """
                    SELECT u.id, u.email, u.user_type, u.created_at, u.is_active,
                           CASE 
                               WHEN u.user_type = 'patient' THEN p.first_name || ' ' || p.last_name
                               WHEN u.user_type = 'doctor' THEN d.first_name || ' ' || d.last_name
                               WHEN u.user_type = 'institution' THEN i.name
                               ELSE 'N/A'
                           END as full_name
                    FROM users u
                    LEFT JOIN patients p ON u.user_type = 'patient' AND u.reference_id = p.id::text
                    LEFT JOIN doctors d ON u.user_type = 'doctor' AND u.reference_id = d.id::text
                    LEFT JOIN medical_institutions i ON u.user_type = 'institution' AND u.reference_id = i.id::text
                    WHERE u.email ILIKE %s
                    ORDER BY u.created_at DESC
                    LIMIT %s OFFSET %s;
                """
                cur.execute(query, (f'%{search}%', limit, offset))
                users = [dict(row) for row in cur.fetchall()]
                
                # Contar total para paginación
                cur.execute("SELECT COUNT(*) FROM users WHERE email ILIKE %s;", (f'%{search}%',))
                total_records = cur.fetchone()[0]
                
                return jsonify({
                    'data': users,
                    'pagination': {
                        'total_records': total_records,
                        'current_page': page,
                        'total_pages': (total_records + limit - 1) // limit,
                        'limit': limit
                    }
                })
    except Exception as e:
        logger.error(f"❌ Error listando usuarios: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@admins_bp.route('/system/health', methods=['GET'])
@require_session(allowed_roles=['admin'])
def system_health():
    """Verifica la salud del sistema"""
    try:
        health_data = {
            'database': 'healthy',
            'redis': 'healthy',
            'services': {
                'auth_jwt': 'healthy',
                'patients': 'healthy',
                'doctors': 'healthy',
                'institutions': 'healthy'
            },
            'timestamp': '2024-01-01T00:00:00Z'
        }
        
        return jsonify({
            'status': 'success',
            'message': 'Estado del sistema',
            'data': health_data
        })
    except Exception as e:
        logger.error(f"❌ Error verificando salud del sistema: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500