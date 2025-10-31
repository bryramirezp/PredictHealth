from flask import Blueprint, render_template, request, jsonify
from flask_login import login_required
import socket
import time
from datetime import datetime
import psycopg2
import redis
import docker
from docker.errors import DockerException

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

def get_docker_client():
    """Inicializar cliente Docker con soporte para múltiples plataformas y configuraciones

    Basado en docker-compose.yml que configura DOCKER_HOST=tcp://host.docker.internal:2375
    """
    import os
    import platform

    # Lista de configuraciones a probar en orden de preferencia
    # Prioriza la configuración que usa docker-compose.yml
    docker_configs = []

    # 1. TCP connection usando host.docker.internal con puerto 2375 (como habilitaste en Docker Desktop)
    docker_configs.append({
        'base_url': 'tcp://host.docker.internal:2375',
        'tls': False,
        'description': 'Docker Desktop TCP (host.docker.internal:2375 - habilitado en Docker Desktop)'
    })

    # 2. TCP connection usando localhost con puerto 2375 (fallback directo)
    docker_configs.append({
        'base_url': 'tcp://localhost:2375',
        'tls': False,
        'description': 'Docker Desktop TCP (localhost:2375 - fallback directo)'
    })

    # 3. Socket Unix (Linux/Mac por defecto - menos probable en containers)
    if platform.system() != 'Windows':
        docker_configs.append({
            'base_url': 'unix://var/run/docker.sock',
            'description': 'Unix socket (Linux/Mac)'
        })

    # 4. Embeded Docker (para desarrollo/testing)
    docker_configs.append({
        'method': 'from_env',
        'description': 'Docker from environment (docker.from_env() fallback)'
    })

    print("\n🔍 Probando configuraciones Docker:")

    for i, config in enumerate(docker_configs, 1):
        try:
            print(f"  {i}. Intentando: {config['description']}")

            if config.get('method') == 'from_env':
                # Método alternativo usando from_env()
                client = docker.from_env()
            else:
                # Usar base_url específica
                client = docker.DockerClient(base_url=config['base_url'])

            # Verificar que realmente funciona
            client.ping()
            version = client.version()
            print(f"    ✅ Éxito! Docker API version: {version.get('ApiVersion', 'unknown')}")

            # Log información adicional
            info = client.info()
            containers = client.containers.list(all=True)
            print(f"    📊 Contenedores encontrados: {len(containers)}")
            print(f"    🔧 Docker versión: {version.get('Version', 'unknown')}")

            return client

        except DockerException as e:
            print(f"    ❌ Falló: {str(e)}")
            continue
        except Exception as e:
            print(f"    ❌ Error inesperado: {str(e)}")
            continue

    # Si ninguna configuración funcionó
    print("❌ No se pudo conectar a Docker con ninguna configuración.")
    print("💡 Posibles soluciones:")
    print("   1. Asegurarse de que Docker Desktop esté ejecutándose")
    print("   2. Verificar que el socket Docker esté correctamente montado")
    print("   3. En Windows, asegurarse de que 'Expose daemon on tcp://localhost:2375 without TLS' esté habilitado")
    print(f"   4. Variables de entorno actuales: DOCKER_HOST={os.getenv('DOCKER_HOST', 'no definido')}")

    return None

def get_container_detailed_stats(container_name):
    """Obtener métricas detalladas de un contenedor Docker"""
    try:
        client = get_docker_client()
        if not client:
            return None

        container = client.containers.get(container_name)

        # Obtener estadísticas en tiempo real
        stats = container.stats(stream=False)

        if not stats:
            return None

        # Extraer métricas de CPU
        cpu_stats = stats.get('cpu_stats', {})
        cpu_usage = cpu_stats.get('cpu_usage', {}).get('total_usage', 0)
        system_cpu_usage = cpu_stats.get('system_cpu_usage', 0)
        online_cpus = cpu_stats.get('online_cpus', 1)

        # Calcular porcentaje de CPU
        cpu_percent = 0
        if system_cpu_usage > 0:
            cpu_delta = cpu_usage - stats.get('precpu_stats', {}).get('cpu_usage', {}).get('total_usage', 0)
            system_delta = system_cpu_usage - stats.get('precpu_stats', {}).get('system_cpu_usage', 0)

            if system_delta > 0 and cpu_delta > 0:
                cpu_percent = (cpu_delta / system_delta) * online_cpus * 100

        print(f"\n🔍 DEBUG: Procesando resto de métricas para: {container_name}")

        # Extraer métricas de memoria
        print(f"🔍 DEBUG: Procesando métricas de memoria...")
        memory_stats = stats.get('memory_stats', {})
        memory_usage = memory_stats.get('usage', 0) if isinstance(memory_stats, dict) else 0
        memory_limit = memory_stats.get('limit', 1) if isinstance(memory_stats, dict) else 1
        memory_percent = (memory_usage / memory_limit) * 100 if memory_limit > 0 else 0
        print(f"✅ DEBUG: Memoria calculada: {memory_usage} / {memory_limit}")

        # Extraer métricas de red
        print(f"🔍 DEBUG: Procesando métricas de red...")
        networks = stats.get('networks', {})
        total_rx = 0
        total_tx = 0

        if isinstance(networks, dict):
            for net_name, net_stats in networks.items():
                if isinstance(net_stats, dict):
                    total_rx += net_stats.get('rx_bytes', 0)
                    total_tx += net_stats.get('tx_bytes', 0)

        print(f"✅ DEBUG: Red calculada: RX={total_rx}, TX={total_tx}")

        # Extraer métricas de disco
        print(f"🔍 DEBUG: Procesando métricas de disco...")
        blkio_stats = stats.get('blkio_stats', {})
        disk_read = 0
        disk_write = 0

        if isinstance(blkio_stats, dict):
            io_service_bytes = blkio_stats.get('io_service_bytes_recursive', [])
            if isinstance(io_service_bytes, list):
                for stat in io_service_bytes:
                    if isinstance(stat, dict):
                        if stat.get('op') == 'Read':
                            disk_read += stat.get('value', 0)
                        elif stat.get('op') == 'Write':
                            disk_write += stat.get('value', 0)

        print(f"✅ DEBUG: Disco calculado: Read={disk_read}, Write={disk_write}")

        # Obtener logs recientes
        print(f"🔍 DEBUG: Obteniendo logs...")
        try:
            logs = container.logs(tail=20, timestamps=True).decode('utf-8')
            print(f"✅ DEBUG: Logs obtenidos exitosamente")
        except Exception as log_error:
            logs = f"No se pudieron obtener los logs: {log_error}"
            print(f"⚠️  DEBUG: Error obteniendo logs: {log_error}")

        # Obtener variables de entorno
        print(f"🔍 DEBUG: Obteniendo variables de entorno...")
        container_info = container.attrs
        env_vars = container_info.get('Config', {}).get('Env', [])
        sensitive_keys = ['PASSWORD', 'SECRET', 'KEY', 'TOKEN']
        env_vars_filtered = [
            env for env in env_vars
            if not any(sensitive in env.upper() for sensitive in sensitive_keys)
        ]

        print(f"✅ DEBUG: Proceso completado exitosamente para: {container_name}")

        result = {
            'container_name': container_name,
            'status': container.status,
            'created': container_info.get('Created', ''),
            'image': container_info.get('Config', {}).get('Image', ''),
            'cpu_percent': round(cpu_percent, 2),
            'memory_usage': memory_usage,
            'memory_limit': memory_limit,
            'memory_percent': round(memory_percent, 2),
            'network_rx': total_rx,
            'network_tx': total_tx,
            'disk_read': disk_read,
            'disk_write': disk_write,
            'logs': logs,
            'environment': env_vars_filtered[:10]
        }

        print(f"🎉 DEBUG: Retornando resultado exitoso para: {container_name}")
        return result

    except Exception as e:
        print(f"❌ DEBUG: Error GENERAL obteniendo stats para {container_name}: {e}")
        print(f"❌ DEBUG: Tipo de error: {type(e).__name__}")
        import traceback
        traceback.print_exc()
        return None

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

@monitoring_bp.route('/api/service-details/<service_name>')
@login_required
def get_service_details(service_name):
    """API endpoint para obtener detalles técnicos de un servicio/microservicio"""

    # Mapear nombres de servicios a nombres de contenedores
    # Basado en docker-compose.yml: container_name field
    container_mapping = {
        'auth-jwt': 'predicthealth-auth-jwt',
        'doctors': 'predicthealth-doctores',
        'patients': 'predicthealth-pacientes',
        'institutions': 'predicthealth-instituciones',
        'backend-flask': 'predicthealth-backend',
        'cms-backend': 'predicthealth-cms',
        'postgresql': 'predicthealth-postgres',
        'redis': 'predicthealth-redis'
    }

    container_name = container_mapping.get(service_name, service_name)

    if not container_name:
        return jsonify({'error': 'Service not found'}), 404

    # Mapear nombres de servicios a información básica
    basic_service_info = {
        'auth-jwt': {
            'name': 'Auth JWT Service',
            'description': 'Authentication and JWT token management microservice',
            'technology': 'FastAPI/Python',
            'port': 8003,
            'health_endpoint': '/health'
        },
        'doctors': {
            'name': 'Doctors Service',
            'description': 'Doctor management and medical staff operations',
            'technology': 'FastAPI/Python',
            'port': 8000,
            'health_endpoint': '/health'
        },
        'patients': {
            'name': 'Patients Service',
            'description': 'Patient data management and medical records',
            'technology': 'FastAPI/Python',
            'port': 8004,
            'health_endpoint': '/health'
        },
        'institutions': {
            'name': 'Institutions Service',
            'description': 'Healthcare institution management',
            'technology': 'FastAPI/Python',
            'port': 8002,
            'health_endpoint': '/health'
        },
        'backend-flask': {
            'name': 'Flask Backend (API Gateway)',
            'description': 'Main API gateway and business logic',
            'technology': 'Flask/Python',
            'port': 5000,
            'health_endpoint': '/health'
        },
        'cms-backend': {
            'name': 'CMS Backend',
            'description': 'Content Management System for administration',
            'technology': 'Flask/Python',
            'port': 5001,
            'health_endpoint': '/health'
        },
        'postgresql': {
            'name': 'PostgreSQL Database',
            'description': 'Primary relational database for all services',
            'technology': 'PostgreSQL',
            'port': 5432,
            'health_endpoint': None
        },
        'redis': {
            'name': 'Redis Cache',
            'description': 'In-memory cache and session storage',
            'technology': 'Redis',
            'port': 6379,
            'health_endpoint': None
        }
    }

    # Obtener información básica del servicio
    basic_info = basic_service_info.get(service_name)

    # Verificar si Docker cliente está disponible
    docker_client = get_docker_client()
    if not docker_client:
        return jsonify({
            'error': 'Docker daemon is not accessible',
            'diagnosis': 'Unable to establish connection with Docker daemon using any available configuration',
            'troubleshooting': [
                'Ensure Docker Desktop is running',
                'Verify Docker socket is properly mounted (/var/run/docker.sock)',
                'For Windows: Enable "Expose daemon on tcp://localhost:2375 without TLS" in Docker Desktop settings',
                'Check if DOCKER_HOST environment variable is correctly set',
                'Try restarting the cms-backend container after fixing Docker configuration'
            ],
            'container_name': container_name,
            'service_name': service_name,
            'basic_info': basic_info
        }), 503

    # Obtener estadísticas detalladas del contenedor
    detailed_stats = get_container_detailed_stats(container_name)

    if detailed_stats:
        # Combinar información básica con estadísticas detalladas
        response_data = basic_info.copy() if basic_info else {}
        response_data.update({
            'success': True,
            'container_name': container_name,
            **detailed_stats
        })
        return jsonify(response_data)
    else:
        return jsonify({
            'error': f'Unable to fetch container statistics for {container_name}',
            'container_name': container_name,
            'service_name': service_name,
            'diagnosis': 'Container may not exist or Docker connection failed',
            'status': 'unavailable',
            'basic_info': basic_info,
            'troubleshooting': [
                'Verify the container name is correct',
                'Ensure Docker daemon is accessible',
                'Check if the service is actually running',
                f'Container name being queried: {container_name}',
                'Check Docker Desktop settings and socket mounting'
            ]
        }), 500
