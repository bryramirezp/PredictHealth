# /backend-flask\app\api\v1\doctors.py
# /backend-flask/app/api/v1/doctors.py
# Endpoints de doctores estandarizados para API v1

from flask import Blueprint, request, jsonify
from app.services.proxy_service import proxy_service
from app.middleware.jwt_middleware import require_session
import logging

logger = logging.getLogger(__name__)

# Crear blueprint para doctores
doctors_bp = Blueprint('doctors', __name__)

@doctors_bp.route('/', methods=['GET'])
def list_doctors():
    """Lista todos los doctores con paginación"""
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
        search = request.args.get('search', '')
        institution_id = request.args.get('institution_id', '')
        
        # Construir parámetros
        params = {
            'page': page,
            'limit': limit
        }
        if search:
            params['search'] = search
        if institution_id:
            params['institution_id'] = institution_id
        
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
        logger.error(f"❌ Error listando doctores: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@doctors_bp.route('/<doctor_id>', methods=['GET'])
def get_doctor(doctor_id):
    """Obtiene un doctor específico"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401
        
        # Llamar al servicio de doctores
        response = proxy_service.call_doctors_service(
            'GET', f'/api/v1/doctors/{doctor_id}',
            headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Doctor not found',
                'message': 'The requested doctor does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to fetch doctor',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error obteniendo doctor: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@doctors_bp.route('/<doctor_id>', methods=['PUT'])
def update_doctor(doctor_id):
    """Actualiza un doctor (requiere autenticación)"""
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
        
        # Llamar al servicio de doctores
        response = proxy_service.call_doctors_service(
            'PUT', f'/api/v1/doctors/{doctor_id}', 
            data=data, headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify({
                'message': 'Doctor updated successfully',
                'data': response.get('data', {})
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Doctor not found',
                'message': 'The requested doctor does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to update doctor',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error actualizando doctor: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@doctors_bp.route('/<doctor_id>', methods=['DELETE'])
def delete_doctor(doctor_id):
    """Elimina un doctor (requiere autenticación)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401
        
        # Llamar al servicio de doctores
        response = proxy_service.call_doctors_service(
            'DELETE', f'/api/v1/doctors/{doctor_id}',
            headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify({
                'message': 'Doctor deleted successfully'
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Doctor not found',
                'message': 'The requested doctor does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to delete doctor',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error eliminando doctor: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@doctors_bp.route('/<doctor_id>/patients', methods=['GET'])
def list_doctor_patients(doctor_id):
    """Lista los pacientes de un doctor"""
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
            'doctor_id': doctor_id
        }
        
        # Llamar al servicio de pacientes
        response = proxy_service.call_patients_service(
            'GET', '/api/v1/patients', 
            params=params, headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch patients',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error listando pacientes del doctor: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@doctors_bp.route('/statistics', methods=['GET'])
@require_session
def get_doctor_statistics():
    """Obtiene estadísticas de doctores"""
    try:
        # Llamar al servicio de doctores
        response = proxy_service.call_doctors_service(
            'GET', '/api/v1/doctors/statistics'
        )

        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch statistics',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas de doctores: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500
