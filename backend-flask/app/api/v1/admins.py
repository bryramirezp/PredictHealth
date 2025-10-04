# /backend-flask\app\api\v1\admins.py
# /backend-flask/app/api/v1/admins.py
# Endpoints de administradores estandarizados para API v1

from flask import Blueprint, request, jsonify, g
from app.services.proxy_service import proxy_service
from app.middleware.jwt_middleware import require_session
import logging

logger = logging.getLogger(__name__)

# Crear blueprint para administradores
admins_bp = Blueprint('admins', __name__)

@admins_bp.route('/', methods=['GET'])
@require_session
def list_admins():
    """Lista todos los administradores con paginación"""
    try:
        # Obtener parámetros de query
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 10, type=int)
        search = request.args.get('search', '')

        # Construir parámetros
        params = {
            'page': page,
            'limit': limit
        }
        if search:
            params['search'] = search

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'GET', '/api/v1/admins',
            params=params
        )

        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch admins',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error listando administradores: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/<admin_id>', methods=['GET'])
def get_admin(admin_id):
    """Obtiene un administrador específico"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'GET', f'/api/v1/admins/{admin_id}',
            headers={'Authorization': auth_header}
        )

        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Admin not found',
                'message': 'The requested admin does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to fetch admin',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error obteniendo administrador: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/', methods=['POST'])
def create_admin():
    """Crea un nuevo administrador (requiere autenticación)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401

        # Obtener datos del request
        data = request.get_json() or {}

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'POST', '/api/v1/admins',
            data=data, headers={'Authorization': auth_header}
        )

        if response.get('status_code') == 201:
            return jsonify({
                'message': 'Admin created successfully',
                'data': response.get('data', {})
            }), 201
        else:
            return jsonify({
                'error': 'Failed to create admin',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error creando administrador: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/<admin_id>', methods=['PUT'])
def update_admin(admin_id):
    """Actualiza un administrador (requiere autenticación)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401

        # Obtener datos del request
        data = request.get_json() or {}

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'PUT', f'/api/v1/admins/{admin_id}',
            data=data, headers={'Authorization': auth_header}
        )

        if response.get('status_code') == 200:
            return jsonify({
                'message': 'Admin updated successfully',
                'data': response.get('data', {})
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Admin not found',
                'message': 'The requested admin does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to update admin',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error actualizando administrador: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/<admin_id>', methods=['DELETE'])
def delete_admin(admin_id):
    """Elimina un administrador (requiere autenticación)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'DELETE', f'/api/v1/admins/{admin_id}',
            headers={'Authorization': auth_header}
        )

        if response.get('status_code') == 204:
            return jsonify({
                'message': 'Admin deleted successfully'
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Admin not found',
                'message': 'The requested admin does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to delete admin',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error eliminando administrador: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/institutions', methods=['POST'])
def create_institution():
    """Crea una nueva institución (requiere autenticación de admin)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401

        # Obtener datos del request
        data = request.get_json() or {}

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'POST', '/api/v1/admins/institutions',
            data=data, headers={'Authorization': auth_header}
        )

        if response.get('status_code') == 201:
            return jsonify({
                'message': 'Institution created successfully',
                'data': response.get('data', {})
            }), 201
        else:
            return jsonify({
                'error': 'Failed to create institution',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error creando institución: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/audit/logs', methods=['GET'])
def get_audit_logs():
    """Obtiene logs de auditoría (requiere autenticación)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401

        # Obtener parámetros de query
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 50, type=int)
        admin_id = request.args.get('admin_id', '')

        # Construir parámetros
        params = {
            'page': page,
            'limit': limit
        }
        if admin_id:
            params['admin_id'] = admin_id

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'GET', '/api/v1/admins/audit/logs',
            params=params, headers={'Authorization': auth_header}
        )

        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch audit logs',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error obteniendo logs de auditoría: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/health', methods=['GET'])
def health_check():
    """Health check del servicio de administradores"""
    try:
        # Llamar al servicio de administradores (health check público)
        response = proxy_service.call_admins_service(
            'GET', '/health'
        )

        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Health check failed',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error en health check de administradores: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@admins_bp.route('/statistics', methods=['GET'])
@require_session
def get_admin_statistics():
    """Obtiene estadísticas de administradores"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401

        # Llamar al servicio de administradores
        response = proxy_service.call_admins_service(
            'GET', '/api/v1/admins/statistics',
            headers={'Authorization': auth_header}
        )

        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch statistics',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas de administradores: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500