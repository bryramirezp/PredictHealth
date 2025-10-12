# Backend CMS PredictHealth

## Resumen

El Backend CMS (Sistema de Gestión de Contenido) PredictHealth es una aplicación web basada en Flask que proporciona funcionalidad administrativa para gestionar datos de salud en la plataforma PredictHealth. Sirve como interfaz administrativa para gestionar doctores, pacientes, instituciones médicas y análisis del sistema.

## Arquitectura

### Pila Tecnológica

- **Framework**: Flask 2.3.3 con ORM SQLAlchemy
- **Autenticación**: Flask-Login con hash bcrypt
- **Seguridad**: Protección CSRF y control de acceso basado en roles
- **Base de datos**: Integración PostgreSQL con esquema de sistema existente
- **Frontend**: Plantillas Jinja2 con estilos Bootstrap
- **Gráficos**: Chart.js para visualización de datos
- **Reportes**: ReportLab para generación PDF, pandas/openpyxl para exportación de datos

### Application Structure

```
cms-backend/
├── app.py                 # Punto de entrada principal de la aplicación
├── Dockerfile            # Configuración de contenedor
├── requirements.txt      # Dependencias Python
├── .env                  # Configuración de entorno
├── .env.example          # Plantilla de entorno
└── app/
    ├── __init__.py       # Fábrica de aplicación Flask
    ├── config.py         # Gestión de configuración
    ├── models/           # Modelos de base de datos
    │   ├── __init__.py
    │   ├── user.py       # Modelo de usuario CMS
    │   ├── role.py       # Modelos de roles y permisos
    │   ├── cms_roles.py  # Definiciones de roles Admin/Editor
    │   └── existing_models.py  # Modelos de solo lectura para datos del sistema
    ├── routes/           # Manejadores de rutas
    │   ├── auth.py       # Rutas de autenticación
    │   ├── dashboard.py  # Dashboard principal
    │   ├── entities.py   # Operaciones CRUD para entidades
    │   ├── reports.py    # Funcionalidad de reportes
    │   ├── settings.py   # Configuraciones del sistema
    │   └── monitoring.py # Monitoreo del sistema
    ├── templates/        # Plantillas Jinja2
    ├── static/           # CSS, JS, imágenes
    └── utils/            # Funciones de utilidad
        └── role_utils.py # Utilidades de control de acceso basado en roles
```

## Características Principales

### 1. Autenticación y Autorización

#### Gestión de Usuarios
- **Usuarios CMS**: Cuentas administrativas dedicadas (tabla `cms_users`)
- **Acceso Basado en Roles**: Roles Admin y Editor con permisos granulares
- **Gestión de Sesiones**: Manejo seguro de sesiones con timeouts configurables
- **Seguridad de Contraseñas**: Hash bcrypt con sal

#### Sistema de Roles
- **Rol Admin**: Permisos CRUD completos en todas las entidades
- **Rol Editor**: Permisos de lectura y actualización, sin crear/eliminar
- **Matriz de Permisos**: Permisos basados en recurso-acción (doctores, pacientes, instituciones)

### 2. Gestión de Entidades

#### Gestión de Doctores
- **Operaciones CRUD**: Crear, leer, actualizar, eliminar doctores
- **Filtrado Avanzado**: Por especialidad, institución, experiencia, estado
- **Validación**: Aplicación única de email y licencia médica
- **Asociaciones**: Vinculación con especialidades e instituciones

#### Gestión de Pacientes
- **Perfiles Completos**: Gestión de datos demográficos y de salud
- **Flujo de Validación**: Pendiente → Validado por Doctor → Validado por Institución → Acceso Completo
- **Asociaciones Médicas**: Vinculación con doctores y/o instituciones
- **Perfiles de Salud**: Creación automática con registro de paciente

#### Gestión de Instituciones
- **Instalaciones de Salud**: Hospitales, clínicas, aseguradoras, centros de salud
- **Organización Geográfica**: Filtrado basado en región/estado
- **Estado de Verificación**: Seguimiento de estado activo/inactivo y verificado
- **Gestión de Contactos**: Información de contacto completa

### 3. Dashboard y Análisis

#### Métricas en Tiempo Real
- **Resumen del Sistema**: Total de usuarios, doctores, pacientes, instituciones
- **Estadísticas de Validación**: Distribución de estado de validación de pacientes
- **Métricas Financieras**: Tarifas promedio de consulta
- **Seguimiento de Crecimiento**: Tendencias de registro mensual

#### Visualización de Datos
- **Gráficos Interactivos**: Visualizaciones impulsadas por Chart.js
- **Distribución Geográfica**: Mapeo de instituciones y proveedores
- **Distribución de Especialidades**: Análisis de especialidades de doctores
- **Condiciones de Salud**: Estadísticas de salud poblacional

### 4. Sistema de Reportes

#### Vistas de Análisis
- **Registros Mensuales**: Tendencias de incorporación de pacientes
- **Análisis Geográfico**: Distribución regional de salud
- **Análisis de Especialidades**: Distribución de especialidades de doctores
- **Prevalencia de Salud**: Estadísticas de prevalencia de condiciones

#### Capacidades de Exportación
- **Reportes PDF**: Documentos PDF generados con ReportLab
- **Exportaciones Excel**: pandas/openpyxl para exportación de datos
- **Descargas CSV**: Descargas de datos estructurados

### 5. Administración del Sistema

#### Gestión de Configuraciones
- **Configuración Dinámica**: Configuraciones del sistema en tiempo de ejecución
- **Variables de Entorno**: Comportamiento configurable de aplicación
- **Límites de Carga de Archivos**: Restricciones configurables de carga

#### Monitoreo
- **Verificaciones de Salud**: Endpoints de salud de aplicación
- **Métricas del Sistema**: Monitoreo de rendimiento
- **Actividad de Usuario**: Seguimiento de logins y registros de auditoría

## Integración con Base de Datos

### Arquitectura de Esquema

El CMS se integra con la base de datos PostgreSQL principal de PredictHealth usando modelos de solo lectura para datos de sistema existentes:

- **`cms_users`**: Cuentas administrativas CMS
- **`cms_roles` & `cms_permissions`**: Control de acceso basado en roles
- **`doctors`, `patients`, `medical_institutions`**: Entidades de salud
- **`health_profiles`, `doctor_specialties`**: Datos de soporte
- **`system_settings`**: Configuración dinámica

### Flujo de Datos

1. **Autenticación**: Los usuarios CMS se autentican contra tabla `cms_users`
2. **Autorización**: Búsqueda de roles vía `cms_roles` y `cms_role_permissions`
3. **Gestión de Entidades**: Operaciones CRUD en entidades de salud
4. **Análisis**: Consultas de solo lectura contra vistas y procedimientos de base de datos
5. **Configuraciones**: Configuración en tiempo de ejecución vía tabla `system_settings`

## Características de Seguridad

### Control de Acceso
- **Protección CSRF**: Tokens CSRF Flask-WTF en todos los formularios
- **Seguridad de Sesión**: Configuración segura de sesión con timeouts
- **Aplicación de Roles**: Verificación de permisos basada en decoradores
- **Validación de Entrada**: Validación del lado del servidor en todas las entradas de usuario

### Protección de Datos
- **Prevención de Inyección SQL**: Protección ORM SQLAlchemy
- **Prevención XSS**: Escape de plantillas y sanitización de entrada
- **Seguridad de Carga de Archivos**: Manejo seguro de nombres de archivo Werkzeug
- **Políticas de Contraseña**: Requisitos de contraseña fuerte

## Endpoints API

### Autenticación
- `GET/POST /auth/login` - Login de usuario
- `POST /auth/logout` - Logout de usuario

### Dashboard
- `GET /dashboard/` - Dashboard principal con análisis

### Gestión de Entidades
- `GET /entities/doctors` - Listar doctores con filtrado
- `GET/POST /entities/doctors/create` - Crear nuevo doctor
- `GET/POST /entities/doctors/edit/<id>` - Editar doctor
- `POST /entities/doctors/delete/<id>` - Eliminar doctor
- Endpoints CRUD similares para pacientes e instituciones

### Reportes
- `GET /reports/` - Dashboard de reportes

### Configuraciones
- `GET /settings/` - Gestión de configuraciones del sistema

### Monitoreo
- `GET /monitoring/` - Dashboard de monitoreo del sistema

### Verificación de Salud
- `GET /health` - Estado de salud de la aplicación

## Configuración

### Variables de Entorno

```bash
# Configuración Flask
SECRET_KEY=your-secret-key-change-in-production
FLASK_ENV=development
DEBUG=True

# Base de datos
DATABASE_URL=postgresql://predictHealth_user:password@postgres:5432/predicthealth_db

# Configuraciones CMS
CMS_TITLE=PredictHealth CMS
CMS_VERSION=1.0.0

# Sesión
SESSION_TYPE=filesystem
PERMANENT_SESSION_LIFETIME=3600
```

### Configuración Docker

La aplicación está contenerizada con:
- **Imagen Base**: Python 3.11 slim
- **Verificaciones de Salud**: Monitoreo automatizado de salud
- **Seguridad**: Ejecución de usuario no root
- **Dependencias**: Cliente PostgreSQL para conectividad de base de datos

## Configuración de Desarrollo

### Prerrequisitos
- Python 3.11+
- Base de datos PostgreSQL
- Docker y Docker Compose

### Instalación

1. **Clonar y Configurar**:
   ```bash
   cd cms-backend
   # Las variables de entorno ya están configuradas en .env (editar si es necesario)
   ```

2. **Instalar Dependencias**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configuración de Base de Datos**:
   - Asegurar que PostgreSQL esté ejecutándose
   - El esquema de base de datos debe estar inicializado vía proyecto principal

4. **Ejecutar Aplicación**:
   ```bash
   python app.py
   ```

### Despliegue Docker

```bash
# Construir y ejecutar con Docker Compose
docker-compose up --build cms-backend
```

## Guía de Uso

### Flujo de Trabajo de Admin

1. **Login**: Acceder vía `/auth/login` con credenciales de admin
2. **Revisión de Dashboard**: Verificar métricas del sistema y actividad reciente
3. **Gestión de Entidades**: Crear/editar doctores, pacientes, instituciones
4. **Generación de Reportes**: Exportar análisis y reportes del sistema
5. **Configuración de Parámetros**: Ajustar parámetros del sistema

### Flujo de Trabajo de Editor

1. **Login**: Acceder con credenciales de editor
2. **Ver Entidades**: Navegar doctores, pacientes, instituciones
3. **Editar Registros**: Actualizar información de entidades existentes
4. **Generar Reportes**: Acceder a análisis de solo lectura

## Monitoreo y Mantenimiento

### Monitoreo de Salud
- **Endpoint**: `/health` retorna estado de salud JSON
- **Métricas**: Tiempo de actividad de aplicación, conectividad de base de datos
- **Alertas**: Verificaciones automatizadas de salud vía Docker

### Optimización de Rendimiento
- **Consultas de Base de Datos**: Optimizadas con carga lazy de SQLAlchemy
- **Caché**: Caché de datos basado en sesión
- **Paginación**: Manejo eficiente de grandes conjuntos de datos
- **Indexación**: Aprovecha índices de base de datos para consultas rápidas

### Respaldo y Recuperación
- **Exportación de Datos**: Capacidades de exportación CSV/Excel
- **Registros de Auditoría**: Registro de acciones de usuario
- **Respaldo de Configuración**: Documentación de variables de entorno

## Solución de Problemas

### Problemas Comunes

1. **Errores de Conexión a Base de Datos**
   - Verificar configuración de DATABASE_URL
   - Comprobar estado del servicio PostgreSQL
   - Validar conectividad de red

2. **Permiso Denegado**
   - Confirmar roles y permisos de usuario
   - Verificar validez de sesión
   - Validar validez del token CSRF

3. **Problemas de Conexión a Base de Datos**
   - Verificar configuración de DATABASE_URL
   - Comprobar estado del servicio PostgreSQL
   - Validar conectividad de red

### Modo Depuración
Habilitar modo depuración para información detallada de errores:
```bash
export FLASK_ENV=development
export DEBUG=True
python app.py
```

## Mejores Prácticas de Seguridad

### Despliegue en Producción
- **Clave Secreta**: Usar claves secretas fuertes y generadas aleatoriamente
- **HTTPS**: Habilitar encriptación SSL/TLS
- **Variables de Entorno**: Nunca commitear datos sensibles
- **Actualizaciones Regulares**: Mantener dependencias actualizadas
- **Registro de Acceso**: Monitorear y auditar patrones de acceso

### Protección de Datos
- **Sanitización de Entrada**: Todas las entradas de usuario validadas y sanitizadas
- **Inyección SQL**: ORM previene ataques de inyección
- **Seguridad de Sesión**: Configuración segura de sesión

## Contribuyendo

### Estándares de Código
- Seguir mejores prácticas de Flask y SQLAlchemy
- Implementar manejo adecuado de errores
- Agregar docstrings completos
- Escribir pruebas unitarias para nuevas características

### Guías de Desarrollo
- Usar entornos virtuales
- Seguir guías de estilo PEP 8
- Implementar control de acceso basado en roles
- Probar todas las operaciones de base de datos
- Documentar cambios en API

---

El Backend CMS PredictHealth proporciona una interfaz administrativa completa para gestión de datos de salud, combinando seguridad robusta, experiencia de usuario intuitiva y poderosas capacidades de análisis.