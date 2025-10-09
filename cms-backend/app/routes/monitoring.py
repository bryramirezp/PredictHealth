from flask import Blueprint, render_template
from flask_login import login_required
import socket
import time
from datetime import datetime
import psycopg2
import redis

monitoring_bp = Blueprint('monitoring', __name__)

def check_service_health(service_name, host, port):
    """Health check básico sin APIs - usando socket connections"""
    try:
        start_time = time.time()
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)  # 2 second timeout
        result = sock.connect_ex((host, port))
        response_time = (time.time() - start_time) * 1000  # Convert to milliseconds
        sock.close()

        return {
            'healthy': result == 0,
            'host': host,
            'port': port,
            'message': 'Healthy' if result == 0 else 'Connection failed',
            'response_time': round(response_time, 1) if result == 0 else None
        }
    except Exception as e:
        return {
            'healthy': False,
            'host': host,
            'port': port,
            'message': f'Error: {str(e)}',
            'response_time': None
        }

def check_postgresql_health():
    """Health check específico para PostgreSQL"""
    try:
        start_time = time.time()
        # Usar configuración de la aplicación Flask
        from flask import current_app
        db_uri = current_app.config.get('SQLALCHEMY_DATABASE_URI', '')

        if not db_uri:
            return {
                'healthy': False,
                'host': 'unknown',
                'port': 5432,
                'message': 'Database URI not configured',
                'response_time': None
            }

        # Parsear la URI para extraer host y puerto
        # Formato típico: postgresql://user:pass@host:port/dbname
        import re
        match = re.search(r'postgresql://[^@]+@([^:]+):(\d+)/', db_uri)
        if match:
            host = match.group(1)
            port = int(match.group(2))
        else:
            host = 'localhost'
            port = 5432

        # Intentar conectar a PostgreSQL
        conn = psycopg2.connect(db_uri, connect_timeout=5)
        conn.close()

        response_time = (time.time() - start_time) * 1000
        return {
            'healthy': True,
            'host': host,
            'port': port,
            'message': 'Connected successfully',
            'response_time': round(response_time, 1)
        }
    except Exception as e:
        return {
            'healthy': False,
            'host': 'unknown',
            'port': 5432,
            'message': f'Connection failed: {str(e)}',
            'response_time': None
        }

def check_redis_health():
    """Health check específico para Redis"""
    try:
        start_time = time.time()
        # Configuración típica de Redis
        host = 'redis'  # nombre del contenedor Docker
        port = 6379

        # Intentar conectar a Redis
        r = redis.Redis(host=host, port=port, socket_connect_timeout=5, socket_timeout=5)
        r.ping()  # Comando PING para verificar conectividad

        response_time = (time.time() - start_time) * 1000
        return {
            'healthy': True,
            'host': host,
            'port': port,
            'message': 'PING successful',
            'response_time': round(response_time, 1)
        }
    except Exception as e:
        return {
            'healthy': False,
            'host': 'redis',
            'port': 6379,
            'message': f'Connection failed: {str(e)}',
            'response_time': None
        }

def check_all_services_health():
    """Verificar estado de todos los servicios usando socket connections"""
    services = {
        'auth-jwt': ('servicio-auth-jwt', 8003),
        'doctors': ('servicio-doctores', 8000),
        'patients': ('servicio-pacientes', 8004),
        'institutions': ('servicio-instituciones', 8002),
        'backend-flask': ('backend-flask', 5000),
        'cms-backend': ('cms-backend', 5001)  # Este siempre está healthy
    }

    status = {}
    for name, (host, port) in services.items():
        if name == 'cms-backend':
            # CMS backend siempre está healthy (es este mismo servicio)
            status[name] = {
                'healthy': True,
                'host': host,
                'port': port,
                'message': 'This service',
                'response_time': 0
            }
        else:
            status[name] = check_service_health(name, host, port)

    # Agregar health checks para módulos de infraestructura
    status['postgresql'] = check_postgresql_health()
    status['redis'] = check_redis_health()

    return status

@monitoring_bp.route('/microservices', methods=['GET', 'POST'])
@login_required
def microservices():
    """Página de monitoreo de microservicios con health checks server-side"""
    # Realizar health checks al cargar la página o al hacer refresh
    services_status = check_all_services_health()

    # Formatear datos para el template
    health_data = {}
    for service_name, status in services_status.items():
        # Determinar el estado basado en si está healthy
        status_class = 'healthy' if status['healthy'] else 'error'

        # Determinar el tipo de servicio/módulo
        if service_name in ['postgresql', 'redis']:
            service_type = 'database' if service_name == 'postgresql' else 'cache'
        else:
            service_type = service_name.split('-')[0] if '-' in service_name else service_name

        health_data[service_name] = {
            'config': {
                'name': service_name.replace('-', ' ').title(),
                'host': status['host'],
                'port': status['port'],
                'type': service_type
            },
            'status': status_class,
            'message': status['message'],
            'response_time': status['response_time']
        }

    # Última actualización
    last_updated = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    return render_template('monitoring/microservices.html',
                         health_data=health_data,
                         last_updated=last_updated)