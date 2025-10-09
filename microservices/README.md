# Microservicios PredictHealth

## Resumen

La arquitectura de microservicios PredictHealth proporciona un enfoque escalable y modular para la gestión de datos de salud. Este directorio contiene cuatro microservicios especializados que manejan diferentes aspectos de la plataforma de salud, comunicándose a través de APIs bien definidas y compartiendo una base de datos PostgreSQL común con caché Redis.

## Resumen de Arquitectura

### Pila Tecnológica

- **Framework**: FastAPI (framework web asíncrono de alto rendimiento)
- **Base de datos**: PostgreSQL con ORM SQLAlchemy
- **Caché**: Redis para gestión de sesiones y caché
- **Contenedorización**: Docker con verificaciones de salud
- **Documentación API**: Documentación automática OpenAPI/Swagger
- **Validación**: Pydantic para validación de solicitudes/respuestas
- **Autenticación**: Tokens JWT con hash bcrypt

### Arquitectura de Servicios

```
Microservicios PredictHealth
├── auth-jwt-service (Puerto: 8003)
│   ├── Gestión de tokens JWT
│   ├── Endpoints de autenticación
│   └── Almacenamiento de tokens basado en Redis
├── service-doctors (Puerto: 8000)
│   ├── Gestión de perfiles de doctores
│   ├── Asociaciones de especialidades
│   └── Validación de licencias médicas
├── service-institutions (Puerto: 8002)
│   ├── Gestión de instituciones médicas
│   ├── Organización geográfica
│   └── Verificación de licencias
└── service-patients (Puerto: 8004)
    ├── Gestión de datos de pacientes
    ├── Seguimiento de perfiles de salud
    └── Flujos de trabajo de validación
```

## Servicios Individuales

### 1. Servicio Auth-JWT (`auth-jwt-service/`)

**Propósito**: Servicio centralizado de autenticación y gestión de tokens JWT

**Características Principales**:
- Creación, verificación y actualización de tokens JWT
- Almacenamiento y revocación de tokens basado en Redis
- Huella digital de dispositivos y seguimiento de sesiones
- Soporte de autenticación entre servicios

**Endpoints Principales**:
- `POST /tokens/create` - Crear tokens de acceso/actualización
- `POST /tokens/verify` - Verificar validez del token
- `POST /tokens/refresh` - Actualizar tokens de acceso
- `POST /tokens/revoke` - Revocar/invalidar tokens
- `POST /auth/login` - Autenticación de usuario
- `POST /auth/logout` - Cierre de sesión de usuario

**Aspectos Técnicos Destacados**:
- Gestión pura de tokens (sin dependencia de base de datos para tokens)
- Extracción y seguimiento de información de dispositivos
- Registro y monitoreo completos
- Verificaciones de salud con conectividad Redis

### 2. Servicio de Doctores (`service-doctors/`)

**Propósito**: Gestión de datos de proveedores de salud y asociaciones de especialidades

**Características Principales**:
- Gestión completa de perfiles de doctores (operaciones CRUD)
- Asociaciones de especialidades médicas e instituciones
- Validación de licencias y seguimiento de estado profesional
- Gestión de experiencia y tarifas de consulta

**Endpoints Principales**:
- `GET /api/v1/doctors` - Listar doctores con filtrado
- `POST /api/v1/doctors` - Crear nuevo doctor
- `GET /api/v1/doctors/{id}` - Obtener detalles del doctor
- `PUT /api/v1/doctors/{id}` - Actualizar doctor
- `DELETE /api/v1/doctors/{id}` - Eliminar doctor

**Lógica de Negocio**:
- Restricciones únicas de email y licencia médica
- Relaciones de clave foránea con especialidades e instituciones
- Validación de estado profesional (activo, suspendido, retirado)
- Validación de años de experiencia y rango de tarifas

### 3. Servicio de Instituciones (`service-institutions/`)

**Propósito**: Gestión de instituciones médicas y organización geográfica

**Características Principales**:
- Registro y gestión de instalaciones de salud
- Distribución geográfica y análisis regional
- Seguimiento de verificación de licencias y acreditación
- Clasificación de tipos de institución (clínica, hospital, aseguradora, etc.)

**Endpoints Principales**:
- `GET /api/v1/institutions` - Listar instituciones con filtrado
- `POST /api/v1/institutions` - Crear nueva institución
- `GET /api/v1/institutions/{id}` - Obtener detalles de institución
- `PUT /api/v1/institutions/{id}` - Actualizar institución
- `DELETE /api/v1/institutions/{id}` - Eliminar institución

**Lógica de Negocio**:
- Validación y restricciones de tipo de institución
- Requisitos únicos de email de contacto y número de licencia
- Seguimiento de región geográfica y estado
- Gestión de estado de verificación

### 4. Servicio de Pacientes (`service-patients/`)

**Propósito**: Gestión de datos de pacientes y seguimiento de perfiles de salud

**Características Principales**:
- Registro y gestión de perfiles de pacientes
- Creación y actualizaciones de perfiles de salud
- Gestión de flujos de trabajo de validación
- Seguimiento de asociaciones médicas (doctor/institución)

**Endpoints Principales**:
- `GET /api/v1/patients` - Listar pacientes con filtrado
- `POST /api/v1/patients` - Crear nuevo paciente
- `GET /api/v1/patients/{id}` - Obtener detalles del paciente
- `PUT /api/v1/patients/{id}` - Actualizar paciente
- `DELETE /api/v1/patients/{id}` - Eliminar paciente

**Lógica de Negocio**:
- Progresión de estado de validación (pendiente → validado_por_doctor → validado_por_institución → acceso_completo)
- Asociación médica requerida (debe tener doctor O institución)
- Validación de contacto de emergencia
- Integración de perfil de salud

## Estructura Común de Servicios

Todos los microservicios siguen una arquitectura consistente:

```
service-name/
├── app/
│   ├── main.py              # Punto de entrada de aplicación FastAPI
│   ├── api/v1/endpoints/    # Manejadores de rutas API
│   ├── core/                # Configuración y funcionalidad central
│   ├── models/              # Modelos de base de datos y esquemas
│   ├── services/            # Servicios de lógica de negocio
│   └── utils/               # Funciones de utilidad
├── Dockerfile               # Configuración de contenedor
├── requirements.txt         # Dependencias Python
├── .env                     # Configuración de entorno
└── .env.example            # Plantilla de entorno
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

### Consistencia de Datos

- **Transacciones ACID**: Gestión de transacciones a nivel de base de datos
- **Restricciones de Clave Foránea**: Aplicación de integridad referencial
- **Restricciones Únicas**: Validación de reglas de negocio
- **Triggers**: Actualizaciones automáticas de marcas de tiempo

### Estrategia de Caché

- **Integración Redis**: Almacenamiento de sesiones y caché temporal
- **Gestión de Tokens**: Tokens JWT almacenados en Redis para acceso rápido
- **Manejo de Sesiones**: Gestión de datos de sesión de usuario

## Principios de Diseño de API

### Endpoints RESTful

Todos los servicios siguen convenciones REST:
- `GET /resource` - Listar recursos con filtrado/paginación
- `POST /resource` - Crear nuevo recurso
- `GET /resource/{id}` - Obtener recurso específico
- `PUT /resource/{id}` - Actualizar recurso
- `DELETE /resource/{id}` - Eliminar recurso

### Formato de Solicitud/Respuesta

- **JSON**: Toda comunicación utiliza formato JSON
- **Modelos Pydantic**: Validación de solicitudes/respuestas
- **Códigos de Estado HTTP Estándar**: Manejo adecuado de errores
- **Paginación**: Conjuntos de resultados grandes usan paginación basada en cursor

### Manejo de Errores

- **Respuestas de Error Estructuradas**: Formato consistente de error
- **Códigos de Estado HTTP**: Códigos apropiados para diferentes escenarios
- **Mensajes de Error Detallados**: Descripciones informativas de errores
- **Registro**: Registro completo de errores para depuración

## Características de Seguridad

### Autenticación y Autorización

- **Tokens JWT**: Autenticación sin estado con tokens de actualización
- **Seguridad de Contraseñas**: Hash bcrypt con sal
- **Expiración de Tokens**: Duraciones de vida configurables de tokens
- **Seguimiento de Dispositivos**: Huella digital de sesiones y monitoreo

### Protección de Datos

- **Validación de Entrada**: Validación del lado del servidor en todas las entradas
- **Prevención de Inyección SQL**: Parametrización de consultas ORM
- **Configuración CORS**: Acceso controlado entre orígenes
- **Limitación de Tasa**: Protección contra abuso (configurable)

## Contenedorización y Despliegue

### Configuración Docker

Cada servicio incluye:
- **Construcciones Multi-etapa**: Imágenes optimizadas para producción
- **Verificaciones de Salud**: Monitoreo automatizado de salud del servicio
- **Seguridad**: Ejecución de usuario no root
- **Dependencias**: Dependencias mínimas de tiempo de ejecución

### Descubrimiento de Servicios

Los servicios se comunican a través de:
- **Llamadas HTTP Directas**: Comunicación API RESTful
- **Variables de Entorno**: Configuración de URL de servicios
- **Redes Docker**: Comunicación contenedor a contenedor

## Monitoreo y Observabilidad

### Endpoints de Salud

Cada servicio proporciona:
- `GET /health` - Estado de salud del servicio
- `GET /info` - Información del servicio y configuración
- `GET /statistics` - Estadísticas y métricas de uso

### Registro

- **Registro Estructurado**: Formato JSON con campos consistentes
- **Niveles de Registro**: Verbosidad configurable (DEBUG, INFO, WARNING, ERROR)
- **Seguimiento de Solicitudes**: ID de solicitud y seguimiento de correlación
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
   cp .env.example .env
   # Configurar variables de entorno
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

### Desarrollo con Docker

```bash
# Construir y ejecutar servicio específico
docker-compose up --build service-name

# Ver registros
docker-compose logs service-name

# Acceder a documentación API
open http://localhost:SERVICE_PORT/docs
```

## Service Communication

### Inter-Service Calls

Services communicate through HTTP APIs:
- **Auth Service**: Provides authentication for other services
- **Doctors Service**: Manages doctor data for patients and institutions
- **Institutions Service**: Provides institution data for doctors and patients
- **Patients Service**: Integrates with doctors and institutions services

### API Gateway Pattern

While not implemented in this architecture, services are designed to work with an API gateway for:
- Request routing and load balancing
- Authentication middleware
- Rate limiting and security
- Request/response transformation

## Testing Strategy

### Unit Tests

- **Model Testing**: Database model validation
- **Service Testing**: Business logic verification
- **API Testing**: Endpoint functionality testing

### Integration Tests

- **Database Integration**: Data persistence and retrieval
- **Service Communication**: Inter-service API calls
- **Authentication Flow**: Complete authentication workflows

### Load Testing

- **Performance Benchmarks**: Response time validation
- **Concurrency Testing**: Multi-user scenario simulation
- **Resource Usage**: Memory and CPU monitoring

## Solución de Problemas

### Problemas Comunes

1. **Errores de Conexión a Base de Datos**
   - Verificar configuración de DATABASE_URL
   - Comprobar estado del servicio PostgreSQL
   - Validar credenciales de conexión

2. **Problemas de Conexión Redis**
   - Verificar configuración de REDIS_URL
   - Comprobar disponibilidad del servicio Redis
   - Validar pool de conexiones Redis

3. **Comunicación entre Servicios**
   - Verificar URLs de servicios en configuración
   - Verificar conectividad de red Docker
   - Validar disponibilidad de endpoints API

4. **Problemas de Autenticación**
   - Verificar configuración de JWT_SECRET_KEY
   - Verificar configuraciones de expiración de tokens
   - Validar almacenamiento de tokens en Redis

### Modo Depuración

Habilitar registro detallado:
```bash
export LOG_LEVEL=DEBUG
python app/main.py
```

## Optimización de Rendimiento

### Optimización de Base de Datos

- **Pooling de Conexiones**: Gestión eficiente de conexiones de base de datos
- **Optimización de Consultas**: Indexación estratégica y planificación de consultas
- **Caché**: Caché de datos basado en Redis para datos frecuentemente accedidos

### Optimización de Servicios

- **Operaciones Asíncronas**: FastAPI async/await para procesamiento concurrente
- **Caché de Respuestas**: Caché Redis para operaciones costosas
- **Paginación**: Manejo eficiente de grandes conjuntos de datos

## Mejoras Futuras

### Características Planificadas

- **API Gateway**: Enrutamiento centralizado de solicitudes y autenticación
- **Service Mesh**: Comunicación avanzada entre servicios y observabilidad
- **Arquitectura Orientada a Eventos**: Procesamiento asíncrono de eventos
- **Despliegue Multi-Región**: Distribución geográfica y failover

### Mejoras de Escalabilidad

- **Escalado Horizontal**: Balanceo de carga entre múltiples instancias
- **Sharding de Base de Datos**: Distribución de datos para despliegues a gran escala
- **Estrategias de Caché**: Patrones avanzados de caché Redis
- **Dashboard de Monitoreo**: Monitoreo centralizado de servicios

---

La arquitectura de microservicios PredictHealth proporciona una base sólida y escalable para la gestión de datos de salud, con cada servicio especializándose en funcionalidad específica de dominio mientras mantiene un diseño de API consistente y prácticas operativas.