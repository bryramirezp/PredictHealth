# /backend-flask\app\api\v1\institutions.py
# /backend-flask/app/api/v1/institutions.py
# Endpoints de instituciones estandarizados para API v1

from flask import Blueprint, request, jsonify
from app.services.proxy_service import proxy_service
import logging

logger = logging.getLogger(__name__)

# Crear blueprint para instituciones
institutions_bp = Blueprint('institutions', __name__)

@institutions_bp.route('/', methods=['GET'])
def list_institutions():
    """Lista todas las instituciones con paginación"""
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
        
        # Llamar al servicio de instituciones
        response = proxy_service.call_institutions_service(
            'GET', '/api/v1/institutions', params=params
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch institutions',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error listando instituciones: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@institutions_bp.route('/<institution_id>', methods=['GET'])
def get_institution(institution_id):
    """Obtiene una institución específica"""
    try:
        # Llamar al servicio de instituciones
        response = proxy_service.call_institutions_service(
            'GET', f'/api/v1/institutions/{institution_id}'
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Institution not found',
                'message': 'The requested institution does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to fetch institution',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error obteniendo institución: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@institutions_bp.route('/<institution_id>', methods=['PUT'])
def update_institution(institution_id):
    """Actualiza una institución (requiere autenticación)"""
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
        
        # Llamar al servicio de instituciones
        response = proxy_service.call_institutions_service(
            'PUT', f'/api/v1/institutions/{institution_id}', 
            data=data, headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify({
                'message': 'Institution updated successfully',
                'data': response.get('data', {})
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Institution not found',
                'message': 'The requested institution does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to update institution',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error actualizando institución: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@institutions_bp.route('/<institution_id>', methods=['DELETE'])
def delete_institution(institution_id):
    """Elimina una institución (requiere autenticación)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401
        
        # Llamar al servicio de instituciones
        response = proxy_service.call_institutions_service(
            'DELETE', f'/api/v1/institutions/{institution_id}',
            headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify({
                'message': 'Institution deleted successfully'
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Institution not found',
                'message': 'The requested institution does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to delete institution',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error eliminando institución: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@institutions_bp.route('/<institution_id>/doctors', methods=['GET'])
def list_institution_doctors(institution_id):
    """Lista los doctores de una institución"""
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
        limit = request.args.get('limit', 10, type=int)
        
        params = {
            'page': page,
            'limit': limit,
            'institution_id': institution_id
        }
        
        # Llamar al servicio de doctores
        response = proxy_service.call_doctors_service(
            'GET', '/api/v1/doctors', 
            params=params, headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch doctors',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error listando doctores de institución: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@institutions_bp.route('/statistics', methods=['GET'])
def get_institution_statistics():
    """Obtiene estadísticas de instituciones"""
    try:
        # Llamar al servicio de instituciones
        response = proxy_service.call_institutions_service(
            'GET', '/api/v1/institutions/statistics'
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch statistics',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500
