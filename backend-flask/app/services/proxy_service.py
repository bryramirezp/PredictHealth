# /backend-flask\app\services\proxy_service.py
# /backend-flask/app/services/proxy_service.py
# Servicio de proxy inteligente para microservicios con JWT automático

import requests
import logging
import time
import jwt
import os
from typing import Dict, Any, Optional
from flask import request, current_app, g

logger = logging.getLogger(__name__)

class ProxyService:
    """Servicio de proxy inteligente para microservicios"""
    
    def __init__(self):
        self.timeout = 10
        self.max_retries = 3
        self.retry_delay = 1  # segundos
        self.jwt_secret_key = os.getenv('JWT_SECRET_KEY', 'UDEM')
        self.jwt_algorithm = os.getenv('JWT_ALGORITHM', 'HS256')
        self.microservices = {
            'doctors': 'http://servicio-doctores:8000',
            'patients': 'http://servicio-pacientes:8004',
            'institutions': 'http://servicio-instituciones:8002',
            'admins': 'http://servicio-admins:8006',
            'jwt': 'http://servicio-auth-jwt:8003'
        }

    def _ensure_api_v1(self, endpoint: str) -> str:
        """
        Ensure an endpoint has the /api/v1 prefix for domain microservices.

        Notes:
        - JWT endpoints use /tokens/... and should NOT get /api/v1 prefixed here.
        - The helper will add a leading slash if missing and prepend /api/v1 when appropriate.
        """
        if not endpoint:
            endpoint = '/'
        # Keep jwt token routes untouched
        if endpoint.startswith('/tokens'):
            return endpoint
        # If the endpoint already starts with /api/v1 leave it
        if not endpoint.startswith('/api/v1'):
            if not endpoint.startswith('/'):
                endpoint = '/' + endpoint
            endpoint = '/api/v1' + endpoint
        return endpoint

    def _decode_jwt_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Decode JWT token and return payload"""
        try:
            payload = jwt.decode(token, self.jwt_secret_key, algorithms=[self.jwt_algorithm])
            return payload
        except jwt.ExpiredSignatureError:
            logger.warning("JWT token has expired")
            return None
        except jwt.InvalidTokenError as e:
            logger.warning(f"Invalid JWT token: {e}")
            return None
        except Exception as e:
            logger.error(f"Error decoding JWT token: {e}")
            return None

    def _get_auth_headers(self) -> Dict[str, str]:
        """Obtener headers de autenticación de la sesión actual"""
        headers = {}

        # Agregar información del usuario de la sesión (validada por middleware)
        if hasattr(g, 'current_user') and g.current_user:
            user_info = g.current_user
            headers['X-User-ID'] = str(user_info.get('user_id', ''))
            headers['X-User-Type'] = user_info.get('user_type', '')
            headers['X-User-Email'] = user_info.get('email', '')
            logger.info(f"👤 Headers de usuario agregados para: {user_info.get('email')} ({user_info.get('user_type')})")
        else:
            logger.warning("⚠️ No hay información de usuario en la sesión para proxy")

        # Headers estándar
        headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'PredictHealth-API-Gateway/1.0'
        })

        return headers
    
    def proxy_get(self, service: str, endpoint: str, params: Optional[Dict] = None, headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Proxy GET request a microservicio

        Args:
            service: Nombre del microservicio
            endpoint: Endpoint específico
            params: Parámetros de query
            headers: Headers custom (opcional)

        Returns:
            Respuesta del microservicio
        """
        return self._proxy_request(service, endpoint, 'GET', params=params, headers=headers)

    def proxy_post(self, service: str, endpoint: str, data: Optional[Dict] = None, headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Proxy POST request a microservicio

        Args:
            service: Nombre del microservicio
            endpoint: Endpoint específico
            data: Datos a enviar
            headers: Headers custom (opcional)

        Returns:
            Respuesta del microservicio
        """
        return self._proxy_request(service, endpoint, 'POST', data=data, headers=headers)

    def proxy_put(self, service: str, endpoint: str, data: Optional[Dict] = None, headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Proxy PUT request a microservicio

        Args:
            service: Nombre del microservicio
            endpoint: Endpoint específico
            data: Datos a enviar
            headers: Headers custom (opcional)

        Returns:
            Respuesta del microservicio
        """
        return self._proxy_request(service, endpoint, 'PUT', data=data, headers=headers)

    def proxy_delete(self, service: str, endpoint: str, headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Proxy DELETE request a microservicio

        Args:
            service: Nombre del microservicio
            endpoint: Endpoint específico
            headers: Headers custom (opcional)

        Returns:
            Respuesta del microservicio
        """
        return self._proxy_request(service, endpoint, 'DELETE', headers=headers)
    
    def _proxy_request(self, service: str, endpoint: str, method: str,
                       data: Optional[Dict] = None, params: Optional[Dict] = None,
                       headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """
        Método interno para hacer proxy de requests
        
        Args:
            service: Nombre del microservicio
            endpoint: Endpoint específico
            method: Método HTTP
            data: Datos a enviar
            params: Parámetros de query
            
        Returns:
            Respuesta del microservicio
        """
        try:
            # Obtener URL del microservicio
            if service not in self.microservices:
                logger.error(f"❌ Microservicio desconocido: {service}")
                return {
                    'status_code': 400,
                    'data': {'error': f'Microservicio desconocido: {service}'},
                    'headers': {}
                }
            
            base_url = self.microservices[service]
            url = f"{base_url}{endpoint}"
            
            # Preparar headers
            auth_headers = self._get_auth_headers()
            
            # Combinar headers de autenticación con headers custom
            if headers:
                # Si se pasaron headers custom, combinarlos con auth headers
                combined_headers = auth_headers.copy()
                combined_headers.update(headers)
                headers = combined_headers
            else:
                # Usar solo auth headers si no hay custom
                headers = auth_headers.copy()

            # Asegurar headers básicos
            headers.setdefault('Content-Type', 'application/json')
            headers.setdefault('Accept', 'application/json')
            headers.setdefault('User-Agent', 'PredictHealth-API-Gateway/1.0')
            
            logger.info(f"🔄 Proxy {method} request a {service}: {url}")
            
            # Hacer request con reintentos
            last_exception = None
            for attempt in range(self.max_retries):
                try:
                    # Hacer request
                    if method.upper() == 'GET':
                        response = requests.get(url, headers=headers, params=params, timeout=self.timeout)
                    elif method.upper() == 'POST':
                        response = requests.post(url, json=data, headers=headers, timeout=self.timeout)
                    elif method.upper() == 'PUT':
                        response = requests.put(url, json=data, headers=headers, timeout=self.timeout)
                    elif method.upper() == 'DELETE':
                        response = requests.delete(url, headers=headers, timeout=self.timeout)
                    else:
                        logger.error(f"❌ Método HTTP no soportado: {method}")
                        return {
                            'status_code': 400,
                            'data': {'error': f'Método HTTP no soportado: {method}'},
                            'headers': {}
                        }
                    
                    logger.info(f"✅ Respuesta del microservicio {service}: {response.status_code}")
                    
                    # Procesar respuesta
                    try:
                        response_data = response.json()
                    except ValueError:
                        response_data = response.text
                    
                    return {
                        'status_code': response.status_code,
                        'data': response_data,
                        'headers': dict(response.headers)
                    }
                    
                except requests.exceptions.Timeout:
                    last_exception = f"Timeout en intento {attempt + 1}/{self.max_retries}"
                    logger.warning(f"⏰ {last_exception}")
                    if attempt < self.max_retries - 1:
                        time.sleep(self.retry_delay * (attempt + 1))  # Backoff exponencial
                        
                except requests.exceptions.ConnectionError:
                    last_exception = f"Error de conexión en intento {attempt + 1}/{self.max_retries}"
                    logger.warning(f"🔌 {last_exception}")
                    if attempt < self.max_retries - 1:
                        time.sleep(self.retry_delay * (attempt + 1))
                        
                except requests.exceptions.RequestException as e:
                    last_exception = f"Error de request en intento {attempt + 1}/{self.max_retries}: {str(e)}"
                    logger.warning(f"❌ {last_exception}")
                    if attempt < self.max_retries - 1:
                        time.sleep(self.retry_delay * (attempt + 1))
            
            # Si llegamos aquí, todos los reintentos fallaron
            logger.error(f"❌ Todos los reintentos fallaron para {service}: {last_exception}")
            return {
                'status_code': 503,
                'data': {'error': f'Service unavailable after {self.max_retries} attempts', 'details': last_exception},
                'headers': {}
            }
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Error de conexión con microservicio {service}: {e}")
            return {
                'status_code': 503,
                'data': {'error': 'Servicio no disponible', 'detail': str(e)},
                'headers': {}
            }
        except Exception as e:
            logger.error(f"❌ Error inesperado en proxy a {service}: {e}")
            return {
                'status_code': 500,
                'data': {'error': 'Error interno del servidor', 'detail': str(e)},
                'headers': {}
            }
    
    def proxy_to_doctors_service(self, endpoint: str, method: str = 'GET',
                                data: Optional[Dict] = None, params: Optional[Dict] = None,
                                headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """Proxy específico para servicio de doctores"""
        return self._proxy_request('doctors', endpoint, method, data, params, headers)

    def proxy_to_patients_service(self, endpoint: str, method: str = 'GET',
                                 data: Optional[Dict] = None, params: Optional[Dict] = None,
                                 headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """Proxy específico para servicio de pacientes"""
        return self._proxy_request('patients', endpoint, method, data, params, headers)

    def proxy_to_institutions_service(self, endpoint: str, method: str = 'GET',
                                     data: Optional[Dict] = None, params: Optional[Dict] = None,
                                     headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """Proxy específico para servicio de instituciones"""
        return self._proxy_request('institutions', endpoint, method, data, params, headers)

    def proxy_to_auth_service(self, endpoint: str, method: str = 'GET',
                              data: Optional[Dict] = None, params: Optional[Dict] = None,
                              headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """Proxy específico para servicio de autenticación"""
        return self._proxy_request('auth', endpoint, method, data, params, headers)

    def proxy_to_admins_service(self, endpoint: str, method: str = 'GET',
                               data: Optional[Dict] = None, params: Optional[Dict] = None,
                               headers: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
        """Proxy específico para servicio de administradores"""
        return self._proxy_request('admins', endpoint, method, data, params, headers)
    
    # Métodos específicos para el web controller
    def call_jwt_service(self, method: str, endpoint: str, data: Optional[Dict] = None,
                         headers: Optional[Dict] = None) -> Dict[str, Any]:
        """Llamada específica al servicio JWT"""
        # El router del JWT service ya tiene el prefijo /tokens, así que agregamos el prefijo al endpoint
        if not endpoint.startswith('/tokens/'):
            endpoint = f"/tokens{endpoint}"
        return self._proxy_request('jwt', endpoint, method, data, headers=headers)

    def call_patients_service(self, method: str, endpoint: str, data: Optional[Dict] = None,
                              headers: Optional[Dict] = None) -> Dict[str, Any]:
        """Llamada específica al servicio de pacientes"""
        # Asegurar que endpoints que usan query params tengan trailing slash
        if '?' in endpoint and not endpoint.startswith('/pacientes/'):
            endpoint = endpoint.replace('/pacientes?', '/pacientes/?')
        return self._proxy_request('patients', endpoint, method, data, headers=headers)

    def call_doctors_service(self, method: str, endpoint: str, data: Optional[Dict] = None,
                             headers: Optional[Dict] = None) -> Dict[str, Any]:
        """Llamada específica al servicio de doctores"""
        return self._proxy_request('doctors', endpoint, method, data, headers=headers)

    def call_institutions_service(self, method: str, endpoint: str, data: Optional[Dict] = None,
                                 headers: Optional[Dict] = None, params: Optional[Dict] = None) -> Dict[str, Any]:
        """Llamada específica al servicio de instituciones"""
        return self._proxy_request('institutions', endpoint, method, data, params=params, headers=headers)

    def call_admins_service(self, method: str, endpoint: str, **kwargs):
        """Proxy genérico para llamadas al servicio de administradores con sesiones"""
        try:
            # Usar headers de sesión en lugar de JWT
            headers = self._get_auth_headers()

            # Combinar con headers custom si existen
            if kwargs.get('headers'):
                headers.update(kwargs['headers'])

            # Build URL - Fix the duplicated path issue
            base_url = "http://servicio-admins:8006"
            # Remove the /api/v1/admins prefix from the incoming endpoint
            clean_endpoint = endpoint
            if clean_endpoint.startswith('/api/v1/admins/'):
                clean_endpoint = clean_endpoint.replace('/api/v1/admins/', '/', 1)
            elif clean_endpoint.startswith('/api/v1/admins'):
                clean_endpoint = clean_endpoint.replace('/api/v1/admins', '', 1)
            elif clean_endpoint.startswith('/admins/'):
                clean_endpoint = clean_endpoint.replace('/admins/', '/', 1)
            elif clean_endpoint.startswith('/admins'):
                clean_endpoint = clean_endpoint.replace('/admins', '', 1)

            # Ensure we have a leading slash
            if not clean_endpoint.startswith('/'):
                clean_endpoint = '/' + clean_endpoint

            url = f"{base_url}/api/v1{clean_endpoint}"

            logger.info(f"🔄 Proxy {method} request a admins: {url}")

            # Make request with all kwargs
            response = requests.request(
                method=method,
                url=url,
                headers=headers,
                json=kwargs.get('json'),
                params=kwargs.get('params'),
                data=kwargs.get('data'),
                timeout=30
            )

            logger.info(f"✅ Respuesta del microservicio admins: {response.status_code}")

            # Return standardized response format like other proxy methods
            try:
                response_data = response.json()
            except ValueError:
                response_data = response.text

            return {
                'status_code': response.status_code,
                'data': response_data,
                'headers': dict(response.headers)
            }

        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Error conectando con servicio de administradores: {str(e)}")
            return {
                'status_code': 503,
                'data': {'error': 'Service unavailable', 'details': str(e)},
                'headers': {}
            }
        except Exception as e:
            logger.error(f"❌ Error inesperado en call_admins_service: {str(e)}")
            return {
                'status_code': 500,
                'data': {'error': 'Internal server error', 'details': str(e)},
                'headers': {}
            }

    def call_domain_service(self, user_type: str, method: str, endpoint: str, data: Optional[Dict] = None,
                            headers: Optional[Dict] = None) -> Dict[str, Any]:
        """Call appropriate domain service based on user type"""
        service_map = {
            'institution': 'institutions',
            'doctor': 'doctors',
            'patient': 'patients',
            'admin': 'admins'
        }
        service = service_map.get(user_type)
        if service:
            return self._proxy_request(service, endpoint, method, data, headers=headers)
        else:
            return {'status_code': 400, 'data': {'error': 'Invalid user type'}}

# Instancia global del servicio de proxy
proxy_service = ProxyService()
