# /backend-flask/app/api/v1/gateway.py
# Lógica del API Gateway para reenviar solicitudes a los microservicios.

import os
import requests
from flask import Blueprint, request, jsonify, Response
from functools import wraps

# Crear un blueprint para las rutas del gateway
gateway_bp = Blueprint('gateway', __name__)

# --- Configuración de los Microservicios ---

SERVICE_URLS = {
    "patients": os.getenv("PATIENTS_SERVICE_URL", "http://servicio-pacientes:8004"),
    "doctors": os.getenv("DOCTORS_SERVICE_URL", "http://servicio-doctores:8000"),
    "institutions": os.getenv("INSTITUTIONS_SERVICE_URL", "http://servicio-instituciones:8002"),
    "auth": os.getenv("AUTH_SERVICE_URL", "http://servicio-auth-jwt:8003"),
}

# --- Decorador de Autenticación ---

def require_auth(f):
    """Decorador para validar el token JWT antes de reenviar la solicitud."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.cookies.get('predicthealth_session')
        if not token:
            return jsonify({"error": "Token de autenticación no proporcionado"}), 401

        try:
            auth_service_url = SERVICE_URLS.get("auth")
            verify_url = f"{auth_service_url}/auth/verify-token"
            auth_resp = requests.post(verify_url, headers={"Authorization": f"Bearer {token}"}, timeout=5)

            if auth_resp.status_code != 200:
                return jsonify({"error": "Token inválido o expirado"}), 401

            # Pasa la información del usuario a la función envuelta
            g.user_info = auth_resp.json().get("payload", {})

        except requests.exceptions.RequestException:
            return jsonify({"error": "No se pudo conectar con el servicio de autenticación"}), 503

        return f(*args, **kwargs)
    return decorated_function

# --- Función de Proxy Genérica ---

def _proxy_request(service, path):
    """Función interna para reenviar una solicitud a un microservicio."""
    service_url = SERVICE_URLS.get(service)
    if not service_url:
        return jsonify({"error": "Servicio no encontrado"}), 404

    url = f"{service_url}{request.full_path}" # Usamos full_path para incluir los query params

    headers = {key: value for (key, value) in request.headers if key != 'Host'}
    data = request.get_data()

    # Inyectar la información del usuario si está disponible
    if 'user_info' in g:
        headers['X-User-ID'] = g.user_info.get('user_id', '')
        headers['X-User-Type'] = g.user_info.get('user_type', '')

    try:
        resp = requests.request(
            method=request.method,
            url=url,
            headers=headers,
            data=data,
            timeout=10
        )
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        response_headers = [(name, value) for (name, value) in resp.raw.headers.items() if name.lower() not in excluded_headers]
        return Response(resp.content, resp.status_code, response_headers)

    except requests.exceptions.RequestException as e:
        return jsonify({"error": "Error de comunicación con el servicio", "details": str(e)}), 502

# --- Rutas del Gateway ---

@gateway_bp.route('/auth/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def auth_proxy(path):
    """Proxy para el servicio de autenticación (rutas públicas)."""
    return _proxy_request('auth', f"/auth/{path}")

@gateway_bp.route('/patients/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def patients_proxy(path):
    """Proxy protegido para el servicio de pacientes."""
    return _proxy_request('patients', f"/api/v1/patients/{path}")

@gateway_bp.route('/doctors/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def doctors_proxy(path):
    """Proxy protegido para el servicio de doctores."""
    return _proxy_request('doctors', f"/api/v1/doctors/{path}")

@gateway_bp.route('/institutions/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def institutions_proxy(path):
    """Proxy protegido para el servicio de instituciones."""
    return _proxy_request('institutions', f"/api/v1/institutions/{path}")
