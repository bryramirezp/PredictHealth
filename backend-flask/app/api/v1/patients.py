# /backend-flask\app\api\v1\patients.py
# /backend-flask/app/api/v1/patients.py
# Endpoints de pacientes estandarizados para API v1

from flask import Blueprint, request, jsonify
from app.services.proxy_service import proxy_service
from app.middleware.jwt_middleware import require_session
import logging

logger = logging.getLogger(__name__)

# Crear blueprint para pacientes
patients_bp = Blueprint('patients', __name__)

@patients_bp.route('/', methods=['GET'])
def list_patients():
    """Lista todos los pacientes con paginación"""
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
        doctor_id = request.args.get('doctor_id', '')
        
        # Construir parámetros
        params = {
            'page': page,
            'limit': limit
        }
        if search:
            params['search'] = search
        if doctor_id:
            params['doctor_id'] = doctor_id
        
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
        logger.error(f"❌ Error listando pacientes: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@patients_bp.route('/<patient_id>', methods=['GET'])
def get_patient(patient_id):
    """Obtiene un paciente específico"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401
        
        # Llamar al servicio de pacientes
        response = proxy_service.call_patients_service(
            'GET', f'/api/v1/patients/{patient_id}',
            headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Patient not found',
                'message': 'The requested patient does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to fetch patient',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error obteniendo paciente: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@patients_bp.route('/<patient_id>', methods=['PUT'])
def update_patient(patient_id):
    """Actualiza un paciente (requiere autenticación)"""
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
        
        # Llamar al servicio de pacientes
        response = proxy_service.call_patients_service(
            'PUT', f'/api/v1/patients/{patient_id}', 
            data=data, headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify({
                'message': 'Patient updated successfully',
                'data': response.get('data', {})
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Patient not found',
                'message': 'The requested patient does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to update patient',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error actualizando paciente: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@patients_bp.route('/<patient_id>', methods=['DELETE'])
def delete_patient(patient_id):
    """Elimina un paciente (requiere autenticación)"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401
        
        # Llamar al servicio de pacientes
        response = proxy_service.call_patients_service(
            'DELETE', f'/api/v1/patients/{patient_id}',
            headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify({
                'message': 'Patient deleted successfully'
            }), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Patient not found',
                'message': 'The requested patient does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to delete patient',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error eliminando paciente: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@patients_bp.route('/<patient_id>/health-data', methods=['GET'])
def get_patient_health_data(patient_id):
    """Obtiene los datos de salud de un paciente"""
    try:
        # Verificar autenticación
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'error': 'Authentication required',
                'message': 'Bearer token required'
            }), 401
        
        # Llamar al servicio de pacientes
        response = proxy_service.call_patients_service(
            'GET', f'/api/v1/patients/{patient_id}/health-data',
            headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Patient not found',
                'message': 'The requested patient does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to fetch health data',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error obteniendo datos de salud: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@patients_bp.route('/<patient_id>/health-data', methods=['POST'])
def add_patient_health_data(patient_id):
    """Agrega datos de salud a un paciente"""
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
        
        # Llamar al servicio de pacientes
        response = proxy_service.call_patients_service(
            'POST', f'/api/v1/patients/{patient_id}/health-data', 
            data=data, headers={'Authorization': auth_header}
        )
        
        if response.get('status_code') == 201:
            return jsonify({
                'message': 'Health data added successfully',
                'data': response.get('data', {})
            }), 201
        elif response.get('status_code') == 404:
            return jsonify({
                'error': 'Patient not found',
                'message': 'The requested patient does not exist'
            }), 404
        else:
            return jsonify({
                'error': 'Failed to add health data',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)
            
    except Exception as e:
        logger.error(f"❌ Error agregando datos de salud: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500

@patients_bp.route('/statistics', methods=['GET'])
@require_session
def get_patient_statistics():
    """Obtiene estadísticas de pacientes"""
    try:
        # Llamar al servicio de pacientes
        response = proxy_service.call_patients_service(
            'GET', '/api/v1/patients/statistics'
        )

        if response.get('status_code') == 200:
            return jsonify(response.get('data', {})), 200
        else:
            return jsonify({
                'error': 'Failed to fetch statistics',
                'message': response.get('message', 'Unknown error')
            }), response.get('status_code', 500)

    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas de pacientes: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'message': 'An unexpected error occurred'
        }), 500
