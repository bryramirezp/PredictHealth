# PredictHealth Database

Infraestructura y configuración de base de datos para la plataforma PredictHealth. Gestiona PostgreSQL para almacenamiento persistente y Redis para caché y sesiones.

## Arquitectura

### PostgreSQL 15
- **Base de datos**: `predicthealth_db`
- **Usuario**: `predictHealth_user`
- **Puerto**: 5432
- **Versión**: PostgreSQL 15
- **Esquema**: Normalizado en Tercera Forma Normal (3NF)
- **Inicialización**: Script `init.sql` ejecutado automáticamente al iniciar el contenedor
- **Extensiones**: `uuid-ossp` (generación UUID), `pgcrypto` (funciones criptográficas)
- **Container**: `predicthealth-postgres`

### Redis
- **Versión**: Alpine-based Redis
- **Puerto**: 6379
- **Memoria máxima**: 1GB
- **Política de evicción**: `allkeys-lru`
- **Persistencia**: AOF habilitado con fsync `everysec`
- **Container**: `predicthealth-redis`

## Esquema de Base de Datos

### Entidades Principales

#### Autenticación
- **`users`**: Autenticación centralizada para todos los tipos de usuario (pacientes, doctores, instituciones)
  - Referencia polimórfica mediante `user_type` y `reference_id`
  - Validación mediante trigger `trg_validate_user_reference`
  - Seguimiento de intentos fallidos de login

#### Entidades Médicas
- **`medical_institutions`**: Instituciones de salud (clínicas, hospitales, aseguradoras)
- **`doctor_specialties`**: Especialidades médicas con categorías
- **`doctors`**: Perfiles de profesionales de la salud con especialidades e instituciones
- **`patients`**: Información de pacientes con flujo de validación
- **`health_profiles`**: Información de salud completa (relación 1:1 con pacientes)

#### Contacto Normalizado
- **`emails`**: Direcciones de correo normalizadas con verificación
  - Entidades soportadas: `patient`, `doctor`, `institution`
  - Validación de formato mediante constraint
  - Un único email primario por entidad
- **`phones`**: Números telefónicos normalizados con códigos de país/área
  - Entidades soportadas: `doctor`, `patient`, `institution`, `emergency_contact`
  - Validación de formatos local e internacional
- **`addresses`**: Direcciones normalizadas con soporte geográfico
  - Coordenadas de geolocalización (latitude, longitude)
  - Un único domicilio primario por entidad

#### Catálogos Geográficos
- **`countries`**: Catálogo de países con códigos ISO
- **`regions`**: Catálogo jerárquico de regiones/estados

#### Catálogos Médicos
- **`institution_types`**: Tipos de instituciones
- **`specialty_categories`**: Categorías jerárquicas de especialidades
- **`sexes`**: Catálogo de sexo biológico (para registros médicos)
- **`genders`**: Catálogo de identidad de género (inclusivo)
- **`blood_types`**: Catálogo de tipos sanguíneos con matrices de compatibilidad
- **`email_types`**: Clasificaciones de tipos de email
- **`phone_types`**: Clasificaciones de tipos de teléfono

#### Datos Médicos
- **`medical_conditions`**: Catálogo de condiciones médicas
- **`medications`**: Catálogo de medicamentos
- **`allergies`**: Catálogo de alergias
- **`patient_conditions`**: Condiciones diagnosticadas del paciente (many-to-many)
- **`patient_family_history`**: Historial médico familiar (many-to-many)
- **`patient_medications`**: Medicamentos del paciente (many-to-many)
- **`patient_allergies`**: Alergias del paciente (many-to-many)

#### Sistema CMS
- **`cms_users`**: Cuentas de usuario CMS (roles admin/editor)
- **`cms_roles`**: Definiciones de roles (Admin, Editor)
- **`cms_permissions`**: Permisos granulares (pares recurso-acción)
- **`cms_role_permissions`**: Tabla de unión para asignación de permisos a roles
- **`system_settings`**: Configuración dinámica del sistema

### Relaciones Clave

```
users (1) ──── (1) entidades de dominio (patients/doctors/institutions)
    │
    └── user_type determina referencia reference_id

patients (N) ──── (1) doctors
patients (N) ──── (1) medical_institutions
patients (1) ──── (1) health_profiles
doctors (N) ──── (1) medical_institutions
doctors (N) ──── (1) doctor_specialties
```

- Los pacientes deben estar asociados tanto a un doctor como a una institución (constraint obligatorio)
- Los doctores deben estar vinculados a una institución (constraint obligatorio)
- Los perfiles de salud son 1:1 con pacientes (constraint único)
- Los usuarios CMS tienen permisos basados en roles mediante tablas de unión normalizadas

## Funcionalidades de Base de Datos

### Procedimientos Almacenados

- **`sp_create_patient_with_profile`**: Registro atómico de paciente con creación de perfil de salud
- **`sp_get_patient_stats_by_month`**: Reportes KPI de métricas de pacientes y análisis
- **`sp_get_doctor_performance_stats`**: Métricas de rendimiento de doctores y estadísticas de atención
- **`sp_get_institution_analytics`**: Análisis y estadísticas a nivel de institución

### Funciones Helper

- **`get_primary_email`**: Obtiene email primario para cualquier entidad
- **`add_entity_email`**: Agrega email a entidad
- **`get_primary_phone`**: Obtiene teléfono primario para cualquier entidad
- **`add_entity_phone`**: Agrega número telefónico a entidad
- **`get_primary_address`**: Obtiene dirección primaria para cualquier entidad
- **`add_entity_address`**: Agrega dirección a entidad

### Vistas

Vistas pre-optimizadas para dashboards y reportes:

- **`vw_patient_demographics`**: Datos demográficos de pacientes con asociaciones doctor/institución
- **`vw_doctor_performance`**: Métricas de rendimiento de doctores y conteos de pacientes
- **`vw_monthly_registrations`**: Análisis de registros mensuales
- **`vw_health_condition_stats`**: Estadísticas de salud poblacional y prevalencia
- **`vw_dashboard_overview`**: Métricas de resumen general del sistema
- **`vw_doctor_specialty_distribution`**: Análisis de distribución de especialidades
- **`vw_geographic_distribution`**: Distribución geográfica de entidades de salud
- **`vw_health_condition_prevalence`**: Estadísticas de prevalencia de condiciones de salud
- **`vw_patient_validation_status`**: Estado del flujo de validación de pacientes
- **`vw_relationship_integrity`**: Monitoreo de integridad de relaciones

### Optimización de Rendimiento

#### Índices Estratégicos
- Índices parciales en registros activos para tablas consultadas frecuentemente
- Índices compuestos para operaciones de join complejas
- Índices de claves foráneas para rendimiento de integridad referencial
- Índices especializados para filtrado de condiciones de salud

#### Gestión de Memoria
- Política LRU de Redis con límite de 1GB de memoria
- Persistencia automática mediante snapshots
- Planes de consulta optimizados mediante índices estratégicos

### Constraints de Integridad de Datos

#### Constraints de Lógica de Negocio
- Validación de asociación de paciente (debe tener doctor E institución)
- Validación de consistencia de contacto de emergencia
- Validación de lógica de consumo de tabaco/alcohol
- Constraints de validación de edad y formato

#### Integridad Referencial
- Claves foráneas suaves para asociaciones flexibles
- Operaciones en cascada para datos dependientes
- Constraints únicos en campos críticos de negocio

### Triggers Automatizados

- **`trigger_set_timestamp()`**: Función de trigger que actualiza automáticamente `updated_at` en todas las tablas relevantes
- Aplicado a: `patients`, `doctors`, `medical_institutions`, `health_profiles`, `users`, `cms_users`, `emails`, `phones`, `addresses`, `countries`, `regions`, `medical_conditions`, `medications`, `allergies`

## Configuración

### Docker Compose

Servicios definidos en `docker-compose.yml` raíz:

```yaml
postgres:
  build:
    context: .
    dockerfile: database/postgresql/Dockerfile
  container_name: predicthealth-postgres
  environment:
    POSTGRES_DB: predicthealth_db
    POSTGRES_USER: predictHealth_user
    POSTGRES_PASSWORD: password
  ports: ["5432:5432"]
  volumes:
    - postgres_data:/var/lib/postgresql/data
    - ./populate.sql:/docker-entrypoint-initdb.d/populate.sql
  networks: [predicthealth-network]
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U predictHealth_user -d predicthealth_db"]

redis:
  build:
    context: ./database/redis
    dockerfile: Dockerfile
  container_name: predicthealth-redis
  ports: ["6379:6379"]
  volumes: [redis_data:/data]
  networks: [predicthealth-network]
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
```

### Variables de Entorno

- `DATABASE_URL`: Cadena de conexión PostgreSQL
- `REDIS_URL`: Cadena de conexión Redis
- `POSTGRES_DB`: Nombre de base de datos (default: `predicthealth_db`)
- `POSTGRES_USER`: Usuario de base de datos (default: `predictHealth_user`)
- `POSTGRES_PASSWORD`: Contraseña de base de datos

### Configuración Redis

Archivo `database/redis/redis.conf`:

- Puerto: 6379
- Memoria máxima: 1GB
- Política de evicción: `allkeys-lru`
- Persistencia: AOF habilitado con fsync `everysec`
- Puntos de guardado: 900s (1 cambio), 300s (10 cambios), 60s (10000 cambios)
- TCP keepalive: 300
- Timeout: 300

### Dependencias

`requirements.txt`:
- `psycopg2-binary>=2.9.0`: Adaptador PostgreSQL para Python
- `python-dotenv>=0.19.0`: Gestión de variables de entorno

### Linting

`.pylintrc`: Configuración específica para scripts de migración de base de datos

## Operaciones

### Proceso de Inicialización

1. **Inicio de contenedor**: Contenedor PostgreSQL 15 se inicializa con configuración personalizada
2. **Creación de esquema**: `init.sql` se ejecuta automáticamente, creando:
   - Extensiones de base de datos (uuid-ossp, pgcrypto)
   - Esquema normalizado 3NF completo con todas las tablas y relaciones
   - Constraints y validación de lógica de negocio completa
   - Índices estratégicos para optimización de rendimiento de consultas
   - Triggers automatizados para gestión de timestamps
   - Procedimientos almacenados para operaciones complejas
   - Vistas de base de datos para reportes y análisis
   - Datos de semilla (especialidades médicas, roles/permisos CMS, usuarios de prueba, instituciones, doctores, pacientes)
   - Configuraciones del sistema (system_settings)
3. **Configuración Redis**: Contenedor Redis basado en Alpine con configuración personalizada para persistencia y gestión de memoria

### Arquitectura de Flujo de Datos

1. **Capa de autenticación**: Tabla `users` centralizada maneja autenticación para todos los tipos de usuario
2. **Servicios de dominio**: Microservicios especializados gestionan sus respectivos datos de dominio mediante tablas normalizadas
3. **Capa de caché**: Redis proporciona caché de alto rendimiento para sesiones, datos temporales e información frecuentemente accedida
4. **Administración CMS**: Control de acceso basado en roles mediante tablas `cms_users`, `cms_roles` y `cms_permissions`
5. **Análisis y reportes**: Vistas pre-computadas y procedimientos almacenados proporcionan insights en tiempo real y KPIs

### Integración con Microservicios

La base de datos sirve a los siguientes microservicios con patrones de acceso de datos optimizados:

- **auth-jwt-service**: Gestión de tokens JWT y autenticación centralizada mediante tabla `users`
- **service-patients**: Gestión del ciclo de vida de pacientes con perfiles de salud y flujos de validación
- **service-doctors**: Perfiles de doctores, especialidades y análisis de rendimiento
- **service-institutions**: Gestión de instituciones médicas y análisis geográfico
- **cms-backend**: Funciones administrativas con permisos basados en roles y configuración del sistema
- **backend-flask**: API Gateway que orquesta acceso a todos los servicios

Cada microservicio mantiene conexiones optimizadas tanto a PostgreSQL (datos persistentes) como a Redis (caché/sesiones).

## Mantenimiento

### Acceso a la Base de Datos

**PostgreSQL**:
```bash
# Desde el host (si psql está instalado)
psql -h localhost -p 5432 -U predictHealth_user -d predicthealth_db

# Desde el contenedor
docker exec -it predicthealth-postgres psql -U predictHealth_user -d predicthealth_db

# Usando docker-compose
docker-compose exec postgres psql -U predictHealth_user -d predicthealth_db
```

**Redis**:
```bash
# Desde el host (si redis-cli está instalado)
redis-cli -h localhost -p 6379

# Desde el contenedor
docker exec -it predicthealth-redis redis-cli
```

### Monitoreo y Análisis

- **Dashboards en tiempo real**: Vistas pre-computadas proporcionan acceso instantáneo a KPIs
- **Seguimiento de actividad de usuario**: Intentos fallidos de login y eventos de autenticación registrados en tabla `users`
- **Análisis de salud**: Estadísticas completas de salud de pacientes mediante vistas optimizadas
- **Métricas de rendimiento**: Procedimientos almacenados entregan datos de rendimiento de doctores e instituciones
- **Insights geográficos**: Análisis de distribución regional para planificación de salud

### Optimización de Rendimiento

- **Índices estratégicos**: Índices parciales y compuestos optimizan rendimiento de consultas
- **Gestión de memoria**: Política LRU de Redis con límite de 1GB previene agotamiento de memoria
- **Optimización de consultas**: Vistas y procedimientos almacenados reducen procesamiento del lado de la aplicación
- **Connection pooling**: Gestión eficiente de conexiones de base de datos a través de microservicios

## Seguridad

### Autenticación y Autorización
- **Seguridad de contraseñas**: Hashing bcrypt para todas las contraseñas de usuario
- **Control de acceso basado en roles**: Permisos granulares mediante sistema de roles y permisos CMS
- **Protección de cuentas**: Seguimiento de intentos fallidos de login con políticas de bloqueo configurables
- **Gestión de sesiones**: Manejo de sesiones basado en Redis con expiración automática

### Protección de Datos
- **Validación de entrada**: Constraints completos previenen entrada de datos inválidos
- **Seguridad de lógica de negocio**: Validación a nivel de base de datos asegura integridad de datos
- **Validación de contacto de emergencia**: Validación consistente de información de contacto de emergencia
- **Constraints de edad y formato**: Constraints de base de datos aplican rangos de datos realistas

### Seguridad de Infraestructura
- **Redes de contenedores**: Redis configurado para comunicación segura entre contenedores
- **Control de acceso**: Patrones de acceso a base de datos específicos por microservicio
- **Consistencia de datos**: Operaciones transaccionales previenen actualizaciones parciales de datos
- **Auditoría**: Seguimiento de actividad de usuario mediante registros de autenticación

### Características de Cumplimiento
- **Estándares de datos de salud**: Almacenamiento estructurado para información médica
- **Privacidad del paciente**: Flujos de validación aseguran acceso autorizado a datos
- **Cumplimiento regulatorio**: Arquitectura preparada para auditorías para regulaciones de salud

## Desarrollo

### Setup

1. Asegurar que Docker y Docker Compose estén instalados
2. Los contenedores de base de datos se orquestan mediante `docker-compose.yml` en la raíz del proyecto
3. Las variables de entorno en `.env` se cargan automáticamente
4. Scripts Python en este directorio pueden usarse para migraciones y mantenimiento

### Datos de Semilla

El script `init.sql` incluye datos de semilla:
- 5 instituciones médicas
- 5 doctores
- 5 pacientes con perfiles de salud
- 20 condiciones médicas
- 20 medicamentos
- 20 alergias
- Especialidades médicas
- Roles y permisos CMS
- Usuarios de prueba
- Estados de México (32 regiones)
- Configuraciones del sistema
