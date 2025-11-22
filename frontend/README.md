# PredictHealth Frontend

Frontend web application para la plataforma PredictHealth, proporcionando interfaces de usuario para pacientes, doctores, instituciones y administradores.

## Tabla de Contenidos

1. [Overview](#overview)
2. [Tecnologías](#tecnologías)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Tipos de Usuario y Funcionalidades](#tipos-de-usuario-y-funcionalidades)
5. [Componentes Principales](#componentes-principales)
6. [Sistema de Autenticación](#sistema-de-autenticación)
7. [Integración con API](#integración-con-api)
8. [Estilos y Temas](#estilos-y-temas)
9. [Desarrollo](#desarrollo)
10. [Arquitectura](#arquitectura)

## Overview

El frontend de PredictHealth es una aplicación web multi-usuario construida con JavaScript vanilla, HTML5 y CSS3. Proporciona interfaces basadas en roles para diferentes tipos de usuarios, cada una con funcionalidades y dashboards especializados.

### Características Principales

- **Soporte Multi-Usuario**: Interfaces separadas para pacientes, doctores, instituciones y administradores
- **Autenticación por Sesión**: Autenticación basada en cookies HTTP-only con JWT
- **Diseño Responsivo**: Diseño mobile-first usando Bootstrap 5.3
- **Arquitectura Modular**: Módulos JavaScript basados en componentes para mantenibilidad
- **Actualizaciones en Tiempo Real**: Carga dinámica de datos y actualizaciones de UI
- **Manejo de Errores**: Manejo de errores con notificaciones amigables al usuario

## Tecnologías

### Stack Principal

- **HTML5**: Marcado semántico y estructura
- **CSS3**: Hojas de estilo personalizadas con temas basados en roles
- **JavaScript ES6+**: JavaScript moderno con patrones async/await
- **Bootstrap 5.3**: Framework de UI responsivo
- **Font Awesome 6.0**: Librería de iconos
- **WebGL**: Efectos visuales avanzados para la landing page

### Librerías Externas

- **Chart.js**: Visualización de datos (donde aplique)
- **Bootstrap Icons**: Soporte adicional de iconos

## Estructura del Proyecto

```
frontend/
├── static/
│   ├── css/
│   │   ├── landing.css          # Estilos de la landing page
│   │   ├── patient.css          # Estilos específicos de paciente
│   │   ├── doctor.css           # Estilos específicos de doctor
│   │   ├── institution.css      # Estilos específicos de institución
│   │   └── docs.css             # Estilos de documentación
│   ├── images/
│   │   └── logo.jpg             # Logo de la aplicación
│   └── js/
│       ├── api-client.js        # Cliente API centralizado
│       ├── auth-manager.js      # Gestor de autenticación JWT
│       ├── auth-forms.js        # Manejadores de formularios de autenticación
│       ├── landing.js           # Funcionalidad de la landing page
│       ├── patient/             # Módulos de paciente
│       │   ├── patient-core.js  # Utilidades core de paciente
│       │   ├── dashboard.js     # Dashboard de paciente
│       │   ├── medical-record.js # Gestión de expediente médico
│       │   ├── care-team.js     # Gestión de equipo de cuidado
│       │   └── profile.js       # Gestión de perfil
│       ├── doctor/              # Módulos de doctor
│       │   ├── doctor-core.js   # Utilidades core de doctor
│       │   ├── doctor-dashboard.js
│       │   ├── doctor-patients.js
│       │   ├── doctor-patient-detail.js
│       │   ├── doctor-institution.js
│       │   └── doctor-profile.js
│       └── institution/         # Módulos de institución
│           ├── institution-core.js # Utilidades core de institución
│           ├── institution-dashboard.js
│           ├── institution-doctors.js
│           ├── institution-patients.js
│           └── institution.js
├── templates/
│   ├── base.html                # Template base
│   ├── index.html               # Landing page
│   ├── 404.html                 # Páginas de error
│   ├── 500.html
│   ├── includes/
│   │   └── app-header.html      # Componente de header compartido
│   ├── patient/                 # Templates de paciente
│   │   ├── dashboard.html
│   │   ├── medical-record.html
│   │   ├── my-care-team.html
│   │   └── profile.html
│   ├── doctor/                  # Templates de doctor
│   │   ├── dashboard.html
│   │   ├── patients.html
│   │   ├── patient-detail.html
│   │   ├── my-institution.html
│   │   └── profile.html
│   ├── institution/             # Templates de institución
│   │   ├── dashboard.html
│   │   ├── doctors.html
│   │   ├── patients.html
│   │   └── profile.html
│   └── docs/                    # Páginas de documentación
│       ├── docs.html
│       ├── arquitectura.html
│       ├── frontend/
│       ├── backend/
│       ├── database/
│       ├── deploy/
│       ├── devices/
│       └── ml/
└── README.md                    # Este archivo
```

## Tipos de Usuario y Funcionalidades

### Interfaz de Paciente

**Templates**: `templates/patient/`
**JavaScript**: `static/js/patient/`

#### Funcionalidades

- **Dashboard**: Métricas de salud, medicamentos, resumen de condiciones
- **Expediente Médico**: Perfil de salud completo, condiciones, medicamentos, alergias, historial familiar
- **Equipo de Cuidado**: Información del doctor primario e institución
- **Perfil**: Información personal, detalles de contacto (emails, teléfonos, direcciones), gestión de contraseña

#### Módulos Clave

- `patient-core.js`: Utilidades core y endpoints de API
- `dashboard.js`: Inicialización y renderizado del dashboard
- `medical-record.js`: Gestión de datos del expediente médico
- `care-team.js`: Visualización de información del equipo de cuidado
- `profile.js`: Gestión de perfil con manejadores de formularios

### Interfaz de Doctor

**Templates**: `templates/doctor/`
**JavaScript**: `static/js/doctor/`

#### Funcionalidades

- **Dashboard**: Resumen de pacientes y estadísticas
- **Pacientes**: Lista de pacientes asignados
- **Detalle de Paciente**: Información detallada del paciente y expedientes médicos
- **Mi Institución**: Asociación y detalles de la institución
- **Perfil**: Gestión de perfil profesional

#### Módulos Clave

- `doctor-core.js`: Utilidades específicas de doctor
- `doctor-dashboard.js`: Dashboard del doctor
- `doctor-patients.js`: Gestión de lista de pacientes
- `doctor-patient-detail.js`: Detalles individuales de pacientes
- `doctor-institution.js`: Gestión de institución
- `doctor-profile.js`: Gestión de perfil

### Interfaz de Institución

**Templates**: `templates/institution/`
**JavaScript**: `static/js/institution/`

#### Funcionalidades

- **Dashboard**: Resumen institucional y métricas
- **Doctores**: Gestión de doctores y asignaciones
- **Pacientes**: Registro y gestión de pacientes
- **Perfil**: Perfil y configuraciones de la institución

#### Módulos Clave

- `institution-core.js`: Utilidades core de institución
- `institution-dashboard.js`: Dashboard de institución
- `institution-doctors.js`: Gestión de doctores
- `institution-patients.js`: Gestión de pacientes

### Landing Page

**Template**: `templates/index.html`
**JavaScript**: `static/js/landing.js`

Características:
- Fondo animado con WebGL
- Integración de modal de login
- Sección hero responsiva
- Botones de llamada a la acción

## Componentes Principales

### Cliente API (`api-client.js`)

Módulo centralizado de comunicación con la API que proporciona:

- Manejo unificado de peticiones
- Inyección automática de autenticación por cookies
- Manejo de errores y parsing de respuestas
- Soporte de autenticación basada en sesión

```javascript
// Ejemplo de uso
const data = await PredictHealthAPI.auth.getCurrentUser();
const patientData = await PredictHealthAPI.patients.getDetails(patientId);
```

### Gestor de Autenticación (`auth-manager.js`)

Gestión de tokens JWT y autenticación de usuarios:

- Almacenamiento de tokens en cookies de sesión
- Validación de tokens y verificación de expiración
- Obtención de información del usuario
- Funcionalidad de login/logout

```javascript
// Verificar autenticación
const isLoggedIn = AuthManager.isLoggedIn();

// Obtener información del usuario
const userInfo = AuthManager.getUserInfo();
```

### Manejador de Formularios de Autenticación (`auth-forms.js`)

Integración de `AuthManager` con formularios de login:

- Configuración automática de formularios de login
- Manejo de eventos de autenticación
- Actualización de UI según estado de autenticación
- Redirección automática según tipo de usuario

### Patient Core (`patient-core.js`)

Utilidades compartidas para módulos de paciente:

- Definiciones de endpoints
- Verificaciones de autenticación
- Wrapper de peticiones API
- Sistema de notificaciones de errores

```javascript
// Verificar auth y obtener usuario
const userInfo = await PatientCore.checkAuth();

// Realizar petición API
const data = await PatientCore.apiRequest(
    PatientCore.ENDPOINTS.DASHBOARD(patientId)
);
```

### Doctor Core (`doctor-core.js`)

Estructura similar a Patient Core, proporcionando utilidades y endpoints específicos de doctor.

### Institution Core (`institution-core.js`)

Estructura similar a Patient Core y Doctor Core, proporcionando utilidades y endpoints específicos de institución.

## Sistema de Autenticación

### Flujo de Tokens JWT

1. El usuario inicia sesión a través del modal de la landing page
2. El backend valida credenciales y retorna token JWT
3. El token se almacena en cookie segura (`predicthealth_jwt`)
4. Todas las peticiones subsecuentes incluyen la cookie automáticamente
5. El token se valida en cada petición por el backend

### Almacenamiento de Tokens

- **Método**: Cookies HTTP-only seguras
- **Nombre de Cookie**: `predicthealth_jwt`
- **Seguridad**: SameSite=Lax, HttpOnly (manejado por backend)

### Patrón de Verificación de Autenticación

Todas las páginas protegidas siguen este patrón:

```javascript
document.addEventListener('DOMContentLoaded', async () => {
    const userInfo = await PatientCore.checkAuth();
    if (!userInfo) {
        window.location.href = '/';
        return;
    }
    // Inicializar página
});
```

## Integración con API

### Estructura de Endpoints

Las llamadas API van a través del Flask API Gateway:

```
/api/v1/patients/{id}/{action}          # Endpoints de pacientes
/api/v1/doctors/me/{action}             # Endpoints de doctores (autenticado)
/api/web/institution/{action}           # Endpoints de instituciones
/api/web/auth/{userType}/login          # Autenticación
```

### Endpoints de Paciente

- `GET /api/v1/patients/{id}/dashboard`
- `GET /api/v1/patients/{id}/medical-record`
- `GET /api/v1/patients/{id}/care-team`
- `GET /api/v1/patients/{id}/profile`
- `POST /api/web/patient/emails`
- `POST /api/web/patient/phones`
- `POST /api/web/patient/addresses`
- `POST /api/web/auth/change-password`

### Endpoints de Doctor

- `GET /api/v1/doctors/me/dashboard`
- `GET /api/v1/doctors/me/profile`
- `GET /api/v1/doctors/me/institution`
- `GET /api/v1/doctors/me/patients`
- `GET /api/v1/doctors/me/patients/{id}/medical-record`

### Endpoints de Institución

- `GET /api/web/institution/dashboard`
- `GET /api/web/institution/doctors`
- `POST /api/web/institution/doctors`
- `DELETE /api/web/institution/doctors/{id}`
- `GET /api/web/institution/patients`

### Patrón de Petición

```javascript
const response = await fetch('/api/v1/endpoint', {
    method: 'GET',
    credentials: 'include', // Envía cookies automáticamente
    headers: {
        'Content-Type': 'application/json'
    }
});
```

### Manejo de Errores

- Errores de red: Lanzan excepciones con mensajes descriptivos
- 401 No autorizado: Redirige a login
- Errores 400/500: Muestra mensajes de error amigables al usuario
- Todos los errores se registran en consola para debugging

## Estilos y Temas

### CSS Basado en Roles

La aplicación carga diferentes hojas de estilo según el tipo de usuario:

```html
{% if user and user.user_type == 'patient' %}
<link href="{{ url_for('static', filename='css/patient.css') }}" rel="stylesheet">
{% elif user and user.user_type == 'doctor' %}
<link href="{{ url_for('static', filename='css/doctor.css') }}" rel="stylesheet">
{% elif user and user.user_type == 'institution' %}
<link href="{{ url_for('static', filename='css/institution.css') }}" rel="stylesheet">
{% endif %}
```

### Archivos CSS

- `landing.css`: Estilos de la landing page con integración WebGL
- `patient.css`: Tema de la interfaz de paciente
- `doctor.css`: Tema de la interfaz de doctor
- `institution.css`: Tema de la interfaz de institución
- `docs.css`: Estilos de páginas de documentación

### Sistema de Diseño

- **Fuente**: Inter (Google Fonts)
- **Iconos**: Font Awesome 6.0
- **Framework**: Bootstrap 5.3
- **Esquema de Colores**: Temas específicos por rol
- **Responsivo**: Enfoque mobile-first

## Desarrollo

### Desarrollo Local

1. Asegurar que los servicios backend estén ejecutándose (Flask API Gateway, microservicios)
2. Servir el frontend a través del backend Flask (puerto 5000)
3. Acceder en `http://localhost:5000`

### Motor de Templates

Usa Jinja2 templating (Flask):

- Herencia de templates base
- Inyección de contenido basada en bloques
- Inyección de datos de usuario vía variables de template
- Generación de URLs de archivos estáticos

### Carga de Módulos JavaScript

Los módulos se cargan en un orden específico:

1. `api-client.js` - Cliente API base
2. `auth-manager.js` - Autenticación
3. `auth-forms.js` - Manejadores de formularios
4. Core específico de rol (ej., `patient-core.js`)
5. Módulos específicos de página (ej., `dashboard.js`)

### Patrones de Desarrollo

#### Inicialización de Módulos

```javascript
document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/patient/dashboard')) {
        if (!window.PatientCore) {
            console.error("Error: patient-core.js no cargado");
            return;
        }
        
        const userInfo = await PatientCore.checkAuth();
        if (userInfo) {
            initDashboardPage(userInfo);
        }
    }
});
```

#### Patrón de Envío de Formularios

```javascript
async function handleFormSubmit() {
    const form = document.getElementById('form-id');
    const submitBtn = form.querySelector('button[type="submit"]');
    
    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>Procesando...';
        
        const formData = new FormData(form);
        const data = Object.fromEntries(formData);
        
        const response = await fetch('/api/endpoint', {
            method: 'POST',
            credentials: 'include',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            PatientCore.showSuccessMessage('Operación exitosa');
        } else {
            throw new Error('Petición fallida');
        }
    } catch (error) {
        PatientCore.showErrorMessage(error.message);
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Enviar';
    }
}
```

### Debugging

- Logging en consola para todas las peticiones API
- Mensajes de error mostrados a usuarios vía sistema de notificaciones
- Pestaña Network para inspección de peticiones API
- Variables de template expuestas a `window.PatientUserData`

## Arquitectura

### Flujo de Datos

```
Interacción del Usuario
    ↓
Módulo JavaScript
    ↓
PatientCore/DoctorCore/InstitutionCore (wrapper API)
    ↓
Cliente API (auth por cookies)
    ↓
Flask API Gateway
    ↓
Microservicios
    ↓
Base de Datos PostgreSQL
```

### Comunicación entre Módulos

- **Utilidades Compartidas**: Los módulos core proporcionan funcionalidad compartida
- **Basado en Eventos**: Eventos DOM disparan funciones de módulos
- **Async/Await**: Todas las llamadas API son asíncronas
- **Límites de Error**: Bloques try-catch a nivel de módulo

### Gestión de Estado

- **Sin Estado Global**: Cada módulo gestiona su propio estado
- **Variables de Template**: Datos de usuario inyectados desde backend
- **Almacenamiento en Cookies**: Tokens de autenticación en cookies
- **DOM como Estado**: La UI refleja el estado actual de los datos

### Consideraciones de Seguridad

- **Prevención XSS**: Escapado de templates vía Jinja2
- **Protección CSRF**: Cookies SameSite
- **Validación de Tokens**: Validación JWT en cada petición
- **Sanitización de Entrada**: Validación de datos de formularios antes del envío

## Principios de Organización de Archivos

1. **Separación por Rol**: Cada tipo de usuario tiene directorios dedicados
2. **Componentes Compartidos**: Utilidades comunes en directorio raíz `js/`
3. **Herencia de Templates**: Template base para estructura común
4. **Modularidad CSS**: Hojas de estilo específicas por rol
5. **Dependencias de Módulos**: Orden de carga claro y dependencias

## Soporte de Navegadores

- **Navegadores Modernos**: Chrome, Firefox, Safari, Edge (últimas versiones)
- **Características ES6+**: Async/await, arrow functions, template literals
- **CSS3**: Flexbox, Grid, custom properties
- **APIs**: Fetch API, LocalStorage, Cookies

## Consideraciones de Rendimiento

- **Carga Perezosa**: Scripts cargados por página
- **Dependencias Mínimas**: JavaScript vanilla donde sea posible
- **Renderizado Eficiente**: Manipulación DOM solo cuando es necesario
- **Caché de API**: Considerar implementar caché del lado del cliente para datos estáticos

## Mejoras Futuras

- Soporte de Progressive Web App (PWA)
- Service Worker para funcionalidad offline
- Enrutamiento del lado del cliente para experiencia tipo SPA
- Estandarización de librería de componentes
- Migración a TypeScript para seguridad de tipos
