# PredictHealth Microservices Architecture

## Overview

Arquitectura de microservicios escalable y modular para gestión de datos de salud. Cuatro microservicios especializados que manejan diferentes aspectos de la plataforma, comunicándose mediante APIs REST y compartiendo una base de datos PostgreSQL con Redis para caché.

## Arquitectura

### Stack Tecnológico

- **Framework**: FastAPI 0.104.1 (async web framework)
- **Base de Datos**: PostgreSQL con psycopg2-binary 2.9.9 (connection pooling)
- **Caché**: Redis 5.0.1 para sesiones y caché
- **Containerización**: Docker con health checks
- **Documentación API**: OpenAPI/Swagger automática
- **Validación**: Pydantic 2.5.0 para request/response
- **Autenticación**: JWT (PyJWT 2.8.0) con bcrypt 4.2.0 para hashing

### Arquitectura de Servicios

```
PredictHealth Microservices
├── auth-jwt-service (Puerto: 8003)
│   ├── Gestión de tokens JWT
│   ├── Endpoints de autenticación
│   ├── Creación de usuarios
│   └── Almacenamiento en Redis
├── service-doctors (Puerto: 8000)
│   ├── Gestión de perfiles de doctores
│   ├── Asociaciones con especialidades
│   ├── Validación de licencias médicas
│   └── Endpoints para frontend de doctores
├── service-institutions (Puerto: 8002)
│   ├── Gestión de instituciones médicas
│   ├── Organización geográfica
│   └── Verificación de licencias
└── service-patients (Puerto: 8004)
    ├── Gestión de datos de pacientes
    ├── Seguimiento de perfiles de salud
    └── Flujos de validación
```

## Servicios Individuales

### 1. Auth-JWT Service (`auth-jwt-service/`)

**Propósito**: Servicio centralizado de autenticación y gestión de tokens JWT

**Características**:
- Creación, verificación y validación de tokens JWT
- Almacenamiento de tokens en Redis
- Creación y gestión de cuentas de usuario
- Soporte para autenticación inter-servicios
- Hashing de contraseñas con bcrypt

**Endpoints Principales**:
- `POST /auth/login` - Autenticación de usuario
- `POST /auth/verify-token` - Verificar validez de token
- `POST /auth/session/validate` - Validar sesión JWT
- `POST /auth/logout` - Cerrar sesión
- `POST /users/create` - Crear nueva cuenta de usuario
- `GET /health` - Health check

**Lógica Técnica**:
- Gestión pura de tokens (sin dependencia de BD para tokens)
- Extracción y seguimiento de información de dispositivo
- Logging completo y monitoreo
- Health checks con conectividad a Redis
- Hashing de contraseñas con bcrypt

**Dependencias**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- bcrypt 4.2.0
- psycopg2-binary 2.9.9
- redis 5.0.1
- pydantic[email] 2.5.0

### 2. Doctors Service (`service-doctors/`)

**Propósito**: Gestión de datos de proveedores de salud y asociaciones de especialidades

**Características**:
- Gestión completa de perfiles de doctores (operaciones CRUD)
- Asociaciones con especialidades médicas e instituciones
- Validación de licencias y seguimiento de estado profesional
- Gestión de experiencia y tarifas de consulta
- Endpoints específicos para integración con frontend de doctores

**Endpoints Principales**:

**Endpoints para Doctores Autenticados** (frontend de doctores):
- `POST /auth/login` - Login delegado al auth-service
- `GET /api/v1/doctors/me/dashboard` - Obtener KPIs del dashboard
- `GET /api/v1/doctors/me/profile` - Obtener perfil del doctor
- `PUT /api/v1/doctors/me/profile` - Actualizar perfil del doctor
- `GET /api/v1/doctors/me/institution` - Obtener institución asociada
- `GET /api/v1/doctors/me/patients` - Listar pacientes asignados
- `GET /api/v1/doctors/me/patients/{patient_id}/medical-record` - Obtener expediente médico del paciente

**Endpoints CRUD de Admin**:
- `GET /api/v1/doctors` - Listar doctores con filtrado
- `POST /api/v1/doctors` - Crear nuevo doctor
- `GET /api/v1/doctors/{id}` - Obtener detalles del doctor
- `PUT /api/v1/doctors/{id}` - Actualizar doctor
- `DELETE /api/v1/doctors/{id}` - Eliminar doctor (soft delete)
- `GET /health` - Health check

**Lógica de Negocio**:
- Restricciones de email y licencia médica únicos
- Relaciones de clave foránea con especialidades e instituciones
- Validación de estado profesional (active, suspended, retired)
- Validación de años de experiencia y rango de tarifas
- Transacción atómica para creación de doctor (incluye cuenta de usuario)

**Dependencias**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- psycopg2-binary 2.9.9
- requests 2.31.0
- pydantic[email] 2.5.0

### 3. Institutions Service (`service-institutions/`)

**Propósito**: Gestión de instituciones médicas y organización geográfica

**Características**:
- Registro y gestión de instalaciones de salud
- Distribución geográfica y análisis regional
- Verificación de licencias y seguimiento de acreditación
- Clasificación de tipos de institución (clínica, hospital, aseguradora, etc.)

**Endpoints Principales**:
- `GET /api/v1/institutions` - Listar instituciones con filtrado
- `POST /api/v1/institutions` - Crear nueva institución
- `GET /api/v1/institutions/{id}` - Obtener detalles de institución
- `PUT /api/v1/institutions/{id}` - Actualizar institución
- `DELETE /api/v1/institutions/{id}` - Eliminar institución (soft delete)
- `GET /api/v1/institutions/doctors` - Obtener doctores de la institución autenticada
- `GET /api/v1/institutions/patients` - Obtener pacientes de la institución autenticada
- `GET /health` - Health check

**Lógica de Negocio**:
- Validación y restricciones de tipo de institución
- Requisitos de email de contacto y número de licencia únicos
- Seguimiento de región geográfica y estado
- Gestión de estado de verificación
- Transacción atómica para creación de institución (incluye cuenta de usuario)

**Dependencias**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- psycopg2-binary 2.9.9
- requests 2.31.0
- httpx 0.25.2
- pydantic[email] 2.5.0

### 4. Patients Service (`service-patients/`)

**Propósito**: Gestión de datos de pacientes y seguimiento de perfiles de salud

**Características**:
- Registro y gestión de perfiles de pacientes
- Creación y actualización de perfiles de salud
- Gestión de flujos de validación
- Seguimiento de asociaciones médicas (doctor/institución)
- Gestión completa de expedientes médicos

**Endpoints Principales**:
- `GET /api/v1/patients` - Listar pacientes con filtrado
- `POST /api/v1/patients` - Crear nuevo paciente
- `GET /api/v1/patients/{id}` - Obtener detalles del paciente
- `PUT /api/v1/patients/{id}` - Actualizar paciente
- `DELETE /api/v1/patients/{id}` - Eliminar paciente (soft delete)
- `GET /api/v1/patients/{id}/dashboard` - Obtener datos del dashboard del paciente
- `GET /api/v1/patients/{id}/medical-record` - Obtener expediente médico completo
- `GET /api/v1/patients/{id}/care-team` - Obtener información del equipo médico
- `GET /api/v1/patients/{id}/profile` - Obtener detalles del perfil del paciente
- `GET /health` - Health check

**Lógica de Negocio**:
- Progresión de estado de validación (pending → validated_by_doctor → validated_by_institution → full_access)
- Asociación médica requerida (debe tener doctor O institución)
- Validación de contacto de emergencia
- Integración de perfil de salud
- Transacción atómica para creación de paciente (incluye cuenta de usuario y perfil de salud)
- Cálculo de KPIs: health score, BMI, edad, clasificación BMI

**Dependencias**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- psycopg2-binary 2.9.9
- requests 2.31.0
- pydantic[email] 2.5.0

## Componentes Compartidos

### Auth Client (`shared/auth_client.py`)

Cliente HTTP para comunicación inter-servicios con el auth-jwt-service.

**Funciones**:
- `create_user(email, password, user_type, reference_id)` - Crea cuenta de usuario en el servicio de autenticación

**Configuración**:
- `AUTH_SERVICE_URL` - Variable de entorno para endpoint del servicio de autenticación (default: `http://servicio-auth-jwt:8003`)

## Estructura Común de Servicios

Todos los microservicios siguen una arquitectura consistente:

```
service-name/
├── app/
│   ├── main.py              # Punto de entrada de la aplicación FastAPI
│   ├── domain.py            # Modelos Pydantic y esquemas
│   ├── db.py                # Conexión a base de datos y utilidades
│   └── __init__.py
├── Dockerfile               # Configuración de contenedor
├── requirements.txt         # Dependencias Python
└── .env                     # Configuración de entorno
```

## Integración con Base de Datos

### Esquema de Base de Datos Compartida

Todos los servicios se conectan a la misma base de datos PostgreSQL con estas tablas clave:

- **`users`**: Tabla central de autenticación
- **`doctors`**: Perfiles de proveedores de salud
- **`patients`**: Información de pacientes y asociaciones
- **`medical_institutions`**: Instalaciones de salud
- **`health_profiles`**: Datos de salud de pacientes
- **`doctor_specialties`**: Definiciones de especialidades médicas
- **`emails`**: Direcciones de email de entidades (polimórfico)
- **`phones`**: Números de teléfono de entidades (polimórfico)
- **`addresses`**: Direcciones de entidades (polimórfico)

### Consistencia de Datos

- **Transacciones ACID**: Gestión de transacciones a nivel de base de datos
- **Restricciones de Clave Foránea**: Aplicación de integridad referencial
- **Restricciones Únicas**: Validación de reglas de negocio
- **Triggers**: Actualizaciones automáticas de timestamps

### Conexión a Base de Datos

Todos los servicios usan un patrón común de conexión:

- **Connection Pooling**: SimpleConnectionPool con 1-10 conexiones
- **Context Managers**: Gestión automática de conexiones
- **DictCursor**: Resultados retornados como diccionarios
- **Manejo de Errores**: Logging completo y gestión de errores

### Estrategia de Caché

- **Integración Redis**: Almacenamiento de sesiones y caché temporal
- **Gestión de Tokens**: Tokens JWT almacenados en Redis para acceso rápido
- **Manejo de Sesiones**: Gestión de datos de sesión de usuario

## Principios de Diseño API

### Endpoints RESTful

Todos los servicios siguen convenciones REST:
- `GET /resource` - Listar recursos con filtrado/paginación
- `POST /resource` - Crear nuevo recurso
- `GET /resource/{id}` - Obtener recurso específico
- `PUT /resource/{id}` - Actualizar recurso
- `DELETE /resource/{id}` - Eliminar recurso (soft delete)

### Formato Request/Response

- **JSON**: Toda la comunicación usa formato JSON
- **Modelos Pydantic**: Validación de request/response
- **Códigos de Estado HTTP Estándar**: Manejo apropiado de errores
- **Paginación**: Conjuntos de resultados grandes usan paginación basada en cursor

### Manejo de Errores

- **Respuestas de Error Estructuradas**: Formato de error consistente
- **Códigos de Estado HTTP**: Códigos apropiados para diferentes escenarios
- **Mensajes de Error Detallados**: Descripciones informativas de errores
- **Logging**: Logging completo de errores para depuración

## Características de Seguridad

### Autenticación y Autorización

- **Tokens JWT**: Autenticación stateless con refresh tokens
- **Seguridad de Contraseñas**: Hashing bcrypt con salt
- **Expiración de Tokens**: Tiempos de vida de tokens configurables
- **Seguimiento de Dispositivos**: Fingerprinting y monitoreo de sesiones
- **Acceso Basado en Roles**: Validación de tipo de usuario (patient, doctor, institution)

### Protección de Datos

- **Validación de Entrada**: Validación del lado del servidor en todas las entradas
- **Prevención de Inyección SQL**: Parametrización de consultas ORM
- **Configuración CORS**: Control de acceso cross-origin
- **Rate Limiting**: Protección contra abuso (configurable)

## Containerización y Despliegue

### Configuración Docker

Cada servicio incluye:
- **Multi-stage Builds**: Imágenes de producción optimizadas
- **Health Checks**: Monitoreo automatizado de salud del servicio
- **Seguridad**: Ejecución con usuario no root
- **Dependencias**: Dependencias mínimas de runtime

### Service Discovery

Los servicios se comunican mediante:
- **Llamadas HTTP Directas**: Comunicación API RESTful
- **Variables de Entorno**: Configuración de URLs de servicios
- **Docker Networks**: Comunicación contenedor a contenedor

### Integración Docker Compose

Todos los servicios están definidos en el `docker-compose.yml` raíz:
- **Red**: `predicthealth-network` (bridge, subnet: 172.20.0.0/16)
- **Dependencias**: Dependencias de servicios basadas en health checks
- **Volúmenes**: Almacenamiento de datos persistente
- **Puertos**: Puertos de servicios expuestos para acceso externo

**Puertos Expuestos**:
- `servicio-auth-jwt`: 8003
- `servicio-doctores`: 8000
- `servicio-instituciones`: 8002
- `servicio-pacientes`: 8004

## Monitoreo y Observabilidad

### Health Endpoints

Cada servicio proporciona:
- `GET /health` - Estado de salud del servicio

### Logging

- **Logging Estructurado**: Formato JSON con campos consistentes
- **Niveles de Log**: Verbosidad configurable (DEBUG, INFO, WARNING, ERROR)
- **Seguimiento de Requests**: Request ID y seguimiento de correlación
- **Métricas de Rendimiento**: Tiempos de respuesta y tasas de error

## Configuración de Desarrollo

### Prerrequisitos

- Python 3.11+
- Base de datos PostgreSQL
- Servidor Redis
- Docker y Docker Compose

### Desarrollo Local

1. **Clonar y Configurar**:
   ```bash
   cd microservices/service-name
   # Las variables de entorno están configuradas en .env (editar si es necesario)
   ```

2. **Instalar Dependencias**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configuración de Base de Datos**:
   - Asegurar que PostgreSQL y Redis estén ejecutándose
   - El esquema de base de datos debe estar inicializado

4. **Ejecutar Servicio**:
   ```bash
   python app/main.py
   # o
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Desarrollo Docker

```bash
# Construir y ejecutar servicio específico
docker-compose up --build servicio-name

# Ver logs
docker-compose logs servicio-name

# Acceder a documentación API
open http://localhost:SERVICE_PORT/docs
```

## Comunicación Inter-Servicios

### Llamadas Servicio a Servicio

Los servicios se comunican mediante APIs HTTP:
- **Auth Service**: Proporciona autenticación para otros servicios
- **Doctors Service**: Gestiona datos de doctores para pacientes e instituciones
- **Institutions Service**: Proporciona datos de instituciones para doctores y pacientes
- **Patients Service**: Se integra con servicios de doctores e instituciones

### Flujo de Autenticación

1. Usuario se autentica vía `auth-jwt-service`
2. Token JWT es retornado con información de usuario
3. Otros servicios verifican token vía `auth-jwt-service` o decodifican localmente
4. Servicios extraen `reference_id` del token para acceso a entidades

### Cliente Auth Compartido

El módulo `shared/auth_client.py` proporciona:
- Creación de usuarios estandarizada entre servicios
- Manejo de errores y lógica de reintento
- Configuración de URL de servicio mediante variables de entorno

## Patrón API Gateway

Aunque no está implementado en esta arquitectura, los servicios están diseñados para trabajar con un API gateway para:
- Enrutamiento de requests y load balancing
- Middleware de autenticación
- Rate limiting y seguridad
- Transformación de request/response

## Estrategia de Testing

### Unit Testing

- **Testing de Modelos**: Validación de modelos de base de datos
- **Testing de Servicios**: Verificación de lógica de negocio
- **Testing de API**: Testing de funcionalidad de endpoints

### Integration Testing

- **Integración de Base de Datos**: Persistencia y recuperación de datos
- **Comunicación Inter-Servicios**: Llamadas API entre servicios
- **Flujo de Autenticación**: Flujos de autenticación completos

### Load Testing

- **Benchmarks de Rendimiento**: Validación de tiempos de respuesta
- **Testing de Concurrencia**: Simulación de escenarios multi-usuario
- **Uso de Recursos**: Monitoreo de memoria y CPU

## Troubleshooting

### Problemas Comunes

1. **Errores de Conexión a Base de Datos**
   - Verificar configuración `DATABASE_URL`
   - Verificar estado del servicio PostgreSQL
   - Validar credenciales de conexión

2. **Problemas de Conexión Redis**
   - Verificar configuración `REDIS_URL`
   - Verificar disponibilidad del servicio Redis
   - Validar pool de conexiones Redis

3. **Comunicación Inter-Servicios**
   - Verificar URLs de servicios en configuración
   - Verificar conectividad de red Docker
   - Validar disponibilidad de endpoints API

4. **Problemas de Autenticación**
   - Verificar configuración `JWT_SECRET_KEY`
   - Verificar configuración de expiración de tokens
   - Validar almacenamiento de tokens en Redis

### Modo Debug

Habilitar logging detallado:
```bash
export LOG_LEVEL=DEBUG
python app/main.py
```

## Optimización de Rendimiento

### Optimización de Base de Datos

- **Connection Pooling**: Gestión eficiente de conexiones a base de datos
- **Optimización de Queries**: Indexación estratégica y planificación de queries
- **Caché**: Caché basado en Redis para datos frecuentemente accedidos

### Optimización de Servicios

- **Operaciones Async**: FastAPI async/await para procesamiento concurrente
- **Caché de Respuestas**: Caché Redis para operaciones costosas
- **Paginación**: Manejo eficiente de datasets grandes

## Mejoras Futuras

### Características Planificadas

- **API Gateway**: Enrutamiento de requests y autenticación centralizados
- **Service Mesh**: Comunicación inter-servicios avanzada y observabilidad
- **Arquitectura Orientada a Eventos**: Procesamiento asíncrono de eventos
- **Despliegue Multi-Región**: Distribución geográfica y failover

### Mejoras de Escalabilidad

- **Escalado Horizontal**: Load balancing entre múltiples instancias
- **Database Sharding**: Distribución de datos para despliegues a gran escala
- **Estrategias de Caché Avanzadas**: Patrones de caché Redis
- **Dashboard de Monitoreo**: Monitoreo centralizado de servicios

---

La arquitectura de microservicios de PredictHealth proporciona una base sólida y escalable para la gestión de datos de salud, con cada servicio especializándose en funcionalidad de dominio específica mientras mantiene diseño de API y prácticas operacionales consistentes.
