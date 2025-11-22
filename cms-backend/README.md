# PredictHealth CMS Backend

Sistema de gestión de contenido (CMS) para la plataforma PredictHealth. Interfaz administrativa basada en Flask para gestionar datos de salud incluyendo doctores, pacientes, instituciones médicas y análisis del sistema.

## Descripción General

El CMS Backend proporciona una interfaz administrativa segura con control de acceso basado en roles para gestionar la plataforma PredictHealth. Se integra con la base de datos PostgreSQL principal y proporciona operaciones CRUD completas, capacidades de reportes y monitoreo del sistema.

## Arquitectura

### Stack Tecnológico

- **Framework**: Flask 2.3.3 con SQLAlchemy ORM
- **Autenticación**: Flask-Login con hash de contraseñas bcrypt
- **Seguridad**: Protección CSRF (Flask-WTF) y control de acceso basado en roles
- **Base de Datos**: PostgreSQL con integración al esquema existente
- **Frontend**: Plantillas Jinja2 con estilos Bootstrap
- **Visualización**: Chart.js para visualización de datos
- **Reportes**: ReportLab para generación de PDF, pandas/openpyxl para exportación Excel
- **Monitoreo**: Docker SDK para monitoreo de microservicios, Redis para caché

### Estructura del Proyecto

```
cms-backend/
├── app.py                 # Punto de entrada principal
├── Dockerfile             # Configuración de contenedor
├── requirements.txt       # Dependencias Python
└── app/
    ├── __init__.py        # Factory de aplicación Flask
    ├── config.py          # Gestión de configuración
    ├── models/            # Modelos de base de datos
    │   ├── __init__.py
    │   ├── user.py         # Modelo de usuario CMS
    │   ├── role.py         # Modelos de roles y permisos
    │   ├── cms_roles.py    # Definiciones de roles Admin/Editor
    │   └── existing_models.py  # Modelos de solo lectura para datos del sistema
    ├── routes/             # Manejadores de rutas
    │   ├── auth.py         # Rutas de autenticación
    │   ├── dashboard.py    # Dashboard principal
    │   ├── entities.py      # Operaciones CRUD para entidades
    │   ├── reports.py      # Funcionalidad de reportes
    │   ├── settings.py    # Configuraciones del sistema
    │   └── monitoring.py   # Monitoreo del sistema
    ├── templates/          # Plantillas Jinja2
    ├── static/             # CSS, JS, imágenes
    └── utils/              # Funciones utilitarias
        └── role_utils.py   # Utilidades de control de acceso basado en roles
```

## Características

### 1. Autenticación y Autorización

#### Gestión de Usuarios
- **Usuarios CMS**: Cuentas administrativas dedicadas (almacenadas en tabla `cms_users`)
- **Control de Acceso Basado en Roles**: Roles Admin y Editor con permisos granulares
- **Gestión de Sesiones**: Manejo seguro de sesiones con timeouts configurables
- **Seguridad de Contraseñas**: Hash bcrypt con salt

#### Sistema de Roles
- **Rol Admin**: Permisos CRUD completos en todas las entidades
- **Rol Editor**: Permisos de lectura y actualización, sin crear/eliminar
- **Matriz de Permisos**: Permisos basados en recurso-acción (doctores, pacientes, instituciones)
- **Perfiles Extendidos**: Tablas `admin_cms` y `editor_cms` con información adicional

### 2. Gestión de Entidades

#### Gestión de Doctores
- **Operaciones CRUD**: Crear, leer, actualizar, eliminar doctores
- **Filtrado Avanzado**: Por especialidad, institución, experiencia, estado
- **Validación**: Enfoque de email único y licencia médica
- **Asociaciones**: Vinculación con especialidades e instituciones
- **Ordenamiento**: Por nombre, experiencia, tarifa de consulta

#### Gestión de Pacientes
- **Perfiles Completos**: Gestión de datos demográficos y de salud
- **Flujo de Validación**: Pendiente → Validado por Doctor → Validado por Institución → Acceso Completo
- **Asociaciones Médicas**: Vinculación con doctores y/o instituciones
- **Perfiles de Salud**: Creación automática con registro de paciente
- **Vista Demográfica**: Uso de `vw_patient_demographics` para reportes

#### Gestión de Instituciones
- **Instalaciones de Salud**: Hospitales, clínicas, aseguradoras, centros de salud
- **Organización Geográfica**: Filtrado basado en región/estado
- **Estado de Verificación**: Seguimiento de estado activo/inactivo y verificado
- **Gestión de Contacto**: Información de contacto completa

### 3. Dashboard y Análisis

#### Métricas en Tiempo Real
- **Resumen del Sistema**: Total de usuarios, doctores, pacientes, instituciones
- **Estadísticas de Validación**: Distribución de estado de validación de pacientes
- **Métricas Financieras**: Promedio de tarifas de consulta
- **Seguimiento de Crecimiento**: Tendencias de registro mensual
- **Integridad de Relaciones**: Métricas de integridad de relaciones paciente-doctor-institución

#### Visualización de Datos
- **Gráficos Interactivos**: Visualizaciones con Chart.js
- **Distribución Geográfica**: Mapeo de instituciones y proveedores
- **Distribución de Especialidades**: Análisis de especialidades de doctores
- **Condiciones de Salud**: Estadísticas de salud poblacional

#### Vistas de Base de Datos Utilizadas
- `vw_dashboard_overview`: Resumen general del sistema
- `vw_monthly_registrations`: Registros mensuales
- `vw_doctor_specialty_distribution`: Distribución de especialidades
- `vw_geographic_distribution`: Distribución geográfica
- `vw_health_condition_prevalence`: Prevalencia de condiciones de salud
- `vw_patient_validation_status`: Estado de validación de pacientes
- `vw_patient_demographics`: Demografía de pacientes

### 4. Sistema de Reportes

#### Vistas de Análisis
- **Registros Mensuales**: Tendencias de incorporación de pacientes
- **Análisis Geográfico**: Distribución de salud regional
- **Análisis de Especialidades**: Distribución de especialidades de doctores
- **Prevalencia de Salud**: Estadísticas de prevalencia de condiciones

#### Capacidades de Exportación
- **Reportes PDF**: Documentos PDF generados con ReportLab
- **Exportaciones Excel**: pandas/openpyxl para exportación de datos
- **Descargas CSV**: Descargas de datos estructurados
- **Filtrado Avanzado**: Por fecha, estado, región, especialidad, validación

### 5. Administración del Sistema

#### Gestión de Configuración
- **Configuración Dinámica**: Configuraciones del sistema en tiempo de ejecución
- **Variables de Entorno**: Comportamiento de aplicación configurable
- **Límites de Carga de Archivos**: Restricciones de carga configurables
- **Configuración de Sesión**: Timeouts y configuraciones de sesión

#### Monitoreo
- **Health Checks**: Endpoints de salud de aplicación
- **Métricas del Sistema**: Monitoreo de rendimiento
- **Monitoreo de Microservicios**: Verificación de estado de servicios mediante Docker SDK
- **Monitoreo de Base de Datos**: Verificación de conectividad PostgreSQL
- **Monitoreo de Redis**: Verificación de conectividad Redis
- **Tiempos de Respuesta**: Medición de tiempos de respuesta de servicios

## Integración con Base de Datos

### Arquitectura de Esquema

El CMS se integra con la base de datos PostgreSQL principal de PredictHealth usando modelos de solo lectura para datos existentes del sistema:

- **`cms_users`**: Cuentas administrativas del CMS
- **`cms_roles` & `cms_user_roles`**: Control de acceso basado en roles
- **`admin_cms` & `editor_cms`**: Perfiles extendidos de usuarios CMS
- **`doctors`, `patients`, `medical_institutions`**: Entidades de salud
- **`health_profiles`, `doctor_specialties`**: Datos de soporte
- **`system_settings`**: Configuración dinámica
- **`emails`, `phones`**: Información de contacto normalizada

### Flujo de Datos

1. **Autenticación**: Usuarios CMS autentican contra tabla `cms_users`
2. **Autorización**: Búsqueda de roles mediante `cms_roles` y `cms_user_roles`
3. **Gestión de Entidades**: Operaciones CRUD en entidades de salud
4. **Análisis**: Consultas de solo lectura contra vistas de base de datos y procedimientos
5. **Configuraciones**: Configuración en tiempo de ejecución mediante tabla `system_settings`

## Características de Seguridad

### Control de Acceso
- **Protección CSRF**: Tokens CSRF de Flask-WTF en todos los formularios
- **Seguridad de Sesión**: Configuración de sesión segura con timeouts
- **Aplicación de Roles**: Verificación de permisos mediante decoradores
- **Validación de Entrada**: Validación del lado del servidor en todas las entradas de usuario

### Protección de Datos
- **Prevención de Inyección SQL**: Protección ORM de SQLAlchemy
- **Prevención XSS**: Escape de plantillas y sanitización de entrada
- **Seguridad de Carga de Archivos**: Manejo seguro de nombres de archivo con Werkzeug
- **Políticas de Contraseñas**: Requisitos de contraseña fuerte

## Endpoints API

### Autenticación
- `GET/POST /auth/login` - Inicio de sesión de usuario
- `POST /auth/logout` - Cierre de sesión de usuario

### Dashboard
- `GET /dashboard/` - Dashboard principal con análisis

### Gestión de Entidades

#### Doctores
- `GET /entities/doctors` - Listar doctores con filtrado
- `GET /entities/doctors/create` - Formulario de creación
- `POST /entities/doctors` - Crear nuevo doctor
- `GET /entities/doctors/view/<doctor_id>` - Ver detalles de doctor
- `GET /entities/doctors/edit/<doctor_id>` - Formulario de edición
- `POST /entities/doctors/edit/<doctor_id>` - Actualizar doctor
- `POST /entities/doctors/delete/<doctor_id>` - Eliminar doctor

#### Pacientes
- `GET /entities/patients` - Listar pacientes con filtrado
- `GET /entities/patients/create` - Formulario de creación
- `POST /entities/patients` - Crear nuevo paciente
- `GET /entities/patients/view/<patient_id>` - Ver detalles de paciente
- `GET /entities/patients/edit/<patient_id>` - Formulario de edición
- `POST /entities/patients/edit/<patient_id>` - Actualizar paciente
- `POST /entities/patients/delete/<patient_id>` - Eliminar paciente

#### Instituciones
- `GET /entities/institutions` - Listar instituciones con filtrado
- `GET /entities/institutions/create` - Formulario de creación
- `POST /entities/institutions` - Crear nueva institución
- `GET /entities/institutions/view/<institution_id>` - Ver detalles de institución
- `GET /entities/institutions/edit/<institution_id>` - Formulario de edición
- `POST /entities/institutions/edit/<institution_id>` - Actualizar institución
- `POST /entities/institutions/delete/<institution_id>` - Eliminar institución

### Reportes
- `GET /reports/` - Dashboard de reportes
- `GET /reports/export/<report_type>/<format>` - Exportar reporte (CSV/PDF)

### Configuración
- `GET /settings/` - Gestión de configuraciones del sistema
- `POST /settings/` - Guardar configuraciones

### Monitoreo
- `GET /monitoring/` - Dashboard de monitoreo del sistema
- `GET /monitoring/microservices` - Estado de microservicios
- `POST /monitoring/microservices` - Actualizar configuración de monitoreo
- `GET /monitoring/api/service-details/<service_name>` - Detalles de servicio

### Health Check
- `GET /health` - Estado de salud de la aplicación (JSON)
- `GET /` - Redirección a login o dashboard según autenticación

## Configuración

### Variables de Entorno

```bash
# Flask Configuration
SECRET_KEY=your-secret-key-change-in-production
FLASK_ENV=development
DEBUG=True
PORT=5001

# Database
DATABASE_URL=postgresql://predictHealth_user:password@postgres:5432/predicthealth_db?client_encoding=utf8

# CMS Settings
CMS_TITLE=PredictHealth CMS
CMS_VERSION=1.0.0

# Session
SESSION_TYPE=filesystem
PERMANENT_SESSION_LIFETIME=3600

# Docker (para monitoreo de microservicios)
DOCKER_HOST=tcp://host.docker.internal:2375
DOCKER_TLS_VERIFY=0
```

### Clases de Configuración

La aplicación soporta múltiples entornos de configuración:
- **Development**: Modo debug habilitado, mensajes de error detallados
- **Production**: Debug deshabilitado, optimizado para rendimiento

## Instalación

### Prerrequisitos

- Python 3.11+
- PostgreSQL database
- Docker y Docker Compose (opcional, para monitoreo de microservicios)
- Redis (opcional, para caché)

### Configuración de Desarrollo Local

1. **Clonar y Navegar**:
   ```powershell
   cd cms-backend
   ```

2. **Crear Entorno Virtual**:
   ```powershell
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   ```

3. **Instalar Dependencias**:
   ```powershell
   pip install -r requirements.txt
   ```

4. **Configurar Entorno**:
   Crear archivo `.env` con variables de entorno requeridas (ver sección Configuración)

5. **Configuración de Base de Datos**:
   Asegurar que PostgreSQL esté ejecutándose y el esquema de base de datos esté inicializado

6. **Ejecutar Aplicación**:
   ```powershell
   python app.py
   ```

La aplicación estará disponible en `http://localhost:5001`

### Despliegue Docker

```powershell
# Construir y ejecutar con Docker Compose
docker-compose up --build cms-backend
```

El Dockerfile incluye:
- Imagen base Python 3.11 slim
- Monitoreo de health check
- Ejecución de usuario no root
- Cliente PostgreSQL para conectividad de base de datos
- Integración con Docker SDK para monitoreo

## Uso

### Flujo de Trabajo de Admin

1. **Inicio de Sesión**: Acceder mediante `/auth/login` con credenciales de admin
2. **Revisión de Dashboard**: Verificar métricas del sistema y actividad reciente
3. **Gestión de Entidades**: Crear/editar doctores, pacientes, instituciones
4. **Generación de Reportes**: Exportar análisis del sistema y reportes
5. **Configuración del Sistema**: Ajustar parámetros del sistema
6. **Monitoreo**: Verificar estado de microservicios y salud del sistema

### Flujo de Trabajo de Editor

1. **Inicio de Sesión**: Acceder con credenciales de editor
2. **Ver Entidades**: Navegar doctores, pacientes, instituciones
3. **Editar Registros**: Actualizar información de entidades existentes
4. **Generar Reportes**: Acceder a análisis de solo lectura

## Monitoreo y Mantenimiento

### Monitoreo de Salud
- **Endpoint**: `/health` retorna estado de salud JSON
- **Métricas**: Tiempo de actividad de aplicación, conectividad de base de datos
- **Alertas**: Health checks automatizados mediante Docker
- **Microservicios**: Monitoreo de estado y tiempos de respuesta de servicios

### Optimización de Rendimiento
- **Consultas de Base de Datos**: Optimizadas con carga diferida de SQLAlchemy
- **Caché**: Caché de datos basado en sesión
- **Paginación**: Manejo eficiente de grandes conjuntos de datos
- **Indexación**: Aprovecha índices de base de datos para consultas rápidas
- **Vistas Materializadas**: Uso de vistas de base de datos para análisis

### Respaldo y Recuperación
- **Exportación de Datos**: Capacidades de exportación CSV/Excel
- **Logs de Auditoría**: Registro de acciones de usuario
- **Respaldo de Configuración**: Documentación de variables de entorno

## Solución de Problemas

### Problemas Comunes

1. **Errores de Conexión a Base de Datos**
   - Verificar configuración `DATABASE_URL`
   - Verificar estado del servicio PostgreSQL
   - Validar conectividad de red

2. **Permiso Denegado**
   - Confirmar roles y permisos de usuario
   - Verificar validez de sesión
   - Validar token CSRF

3. **Errores de Importación**
   - Asegurar que todas las dependencias estén instaladas
   - Verificar compatibilidad de versión de Python
   - Verificar activación de entorno virtual

4. **Problemas de Monitoreo de Microservicios**
   - Verificar configuración `DOCKER_HOST`
   - Verificar acceso a Docker daemon
   - Verificar conectividad de red con servicios

### Modo Debug

Habilitar modo debug para información detallada de errores:
```powershell
$env:FLASK_ENV="development"
$env:DEBUG="True"
python app.py
```

## Mejores Prácticas de Seguridad

### Despliegue en Producción
- **Clave Secreta**: Usar claves secretas fuertes generadas aleatoriamente
- **HTTPS**: Habilitar cifrado SSL/TLS
- **Variables de Entorno**: Nunca comprometer datos sensibles
- **Actualizaciones Regulares**: Mantener dependencias actualizadas
- **Registro de Acceso**: Monitorear y auditar patrones de acceso

### Protección de Datos
- **Sanitización de Entrada**: Todas las entradas de usuario validadas y sanitizadas
- **Inyección SQL**: ORM previene ataques de inyección
- **Seguridad de Sesión**: Configuración de sesión segura

## Desarrollo

### Estándares de Código
- Seguir mejores prácticas de Flask y SQLAlchemy
- Implementar manejo adecuado de errores
- Agregar docstrings comprensivos
- Escribir pruebas unitarias para nuevas características

### Guías de Desarrollo
- Usar entornos virtuales
- Seguir guías de estilo PEP 8
- Implementar control de acceso basado en roles
- Probar todas las operaciones de base de datos
- Documentar cambios de API

## Licencia

Parte de la plataforma PredictHealth.
