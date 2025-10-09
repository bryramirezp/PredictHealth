# Frontend PredictHealth

## Resumen

El **Frontend de PredictHealth** es una aplicación web moderna y responsiva que proporciona interfaces especializadas para pacientes, doctores, instituciones médicas y administradores. Construida con tecnologías web estándar, ofrece una experiencia de usuario intuitiva con autenticación basada en sesiones JWT y comunicación JSON con el backend.

## Arquitectura General

### Diseño Arquitectónico

```
Usuario → Frontend Web → Backend Flask (API Gateway) → Microservicios
                    ↓
            Navegador Web (HTML/CSS/JS)
                    ↓
            Interfaz de Usuario Responsiva
```

### Principios de Diseño

- **📱 Diseño Responsivo**: Optimizado para desktop, tablet y móvil
- **🎨 Interfaz Moderna**: Bootstrap 5.3 con efectos visuales avanzados
- **🔐 Autenticación Segura**: Sesiones JWT con cookies HttpOnly
- **📡 Comunicación JSON**: API RESTful con el backend
- **♿ Accesibilidad**: Navegación por teclado y soporte ARIA
- **⚡ Rendimiento**: Carga optimizada y efectos WebGL

## Estructura del Proyecto

```
frontend/
├── src/
│   └── config/
│       └── nomenclature_config.js    # Configuración de nomenclatura estándar
├── static/
│   ├── css/
│   │   ├── landing.css              # Estilos página de inicio
│   │   ├── lifestyle.css            # Estilos hábitos de vida
│   │   ├── measurements.css         # Estilos mediciones
│   │   ├── notifications.css        # Estilos notificaciones
│   │   ├── recommendations.css      # Estilos recomendaciones
│   │   ├── register_user.css        # Estilos registro usuario
│   │   ├── styles.css               # Estilos globales
│   │   └── user_dashboard.css       # Estilos dashboard usuario
│   ├── js/
│   │   ├── app.js                   # Funciones principales y API
│   │   ├── auth-forms.js            # Formularios de autenticación
│   │   ├── auth-manager.js          # Gestor de autenticación JWT
│   │   ├── browser-compatibility.js # Compatibilidad navegador
│   │   ├── charts.js                # Gráficos y visualizaciones
│   │   ├── landing.js               # Funcionalidad página inicio
│   │   ├── nomenclature_config.js   # Configuración campos
│   │   ├── notifications.js         # Sistema de notificaciones
│   │   └── validations.js           # Validaciones de formularios
│   └── images/
│       ├── background.jpg           # Imagen fondo
│       └── logo.jpg                 # Logo aplicación
└── templates/
    ├── base.html                    # Plantilla base
    ├── index.html                   # Página de inicio
    ├── docs/
    │   ├── arquitectura.html        # Documentación arquitectura
    │   ├── docs.html               # Página principal docs
    │   ├── backend/                # Docs backend
    │   ├── database/               # Docs base de datos
    │   ├── deploy/                 # Docs despliegue
    │   ├── devices/                # Docs dispositivos
    │   ├── frontend/               # Docs frontend
    │   └── ml/                     # Docs machine learning
    ├── doctor/
    │   ├── doctor_dashboard.html    # Dashboard doctor
    │   └── mis_pacientes.html       # Gestión pacientes
    ├── institution/
    │   ├── create_doctor.html       # Crear doctor
    │   ├── institution_analytics.html # Analytics institución
    │   ├── institution_dashboard.html # Dashboard institución
    │   ├── institution_doctors.html # Gestión doctores
    │   └── institution_patients.html # Gestión pacientes
    └── patient/
        ├── lifestyle.html           # Hábitos de vida
        ├── measurements.html        # Mediciones
        ├── notifications.html       # Notificaciones
        ├── patient_dashboard.html   # Dashboard paciente
        ├── patient_details.html     # Detalles paciente
        ├── recommendations.html     # Recomendaciones
        ├── register_patient.html    # Registro paciente
        ├── register_user.html       # Registro usuario
        └── user_profile.html        # Perfil usuario
```

## Tecnologías Principales

### Framework y Librerías

- **HTML5/CSS3**: Estructura y estilos modernos
- **JavaScript ES6+**: Lógica del lado cliente
- **Bootstrap 5.3.0**: Framework CSS responsivo
- **Font Awesome 6.0.0**: Iconografía vectorial
- **WebGL**: Efectos visuales avanzados

### APIs y Comunicación

- **Fetch API**: Solicitudes HTTP modernas
- **JSON**: Formato de datos estándar
- **Cookies**: Gestión de sesiones seguras
- **Local Storage**: Almacenamiento local limitado

### Compatibilidad

- **Navegadores Modernos**: Chrome, Firefox, Safari, Edge
- **Dispositivos Móviles**: iOS Safari, Android Chrome
- **Responsive Design**: Breakpoints Bootstrap
- **Progressive Enhancement**: Funcionalidad básica sin JavaScript

## Funcionalidades Principales

### 1. Sistema de Autenticación

#### Autenticación Multi-Tipo
```javascript
// Login automático por tipo de usuario
const result = await AuthManager.login(email, password, userType);
// userType: 'patient', 'doctor', 'institution'
```

#### Gestión de Sesiones
- **Cookies HttpOnly**: Almacenamiento seguro de tokens JWT
- **Validación Automática**: Verificación de sesión activa
- **Renovación Transparente**: Extensión automática de expiración
- **Logout Seguro**: Eliminación completa de sesión

#### Interfaz de Login
- **Modal Interactivo**: Formulario integrado en página principal
- **Validación en Tiempo Real**: Feedback inmediato de errores
- **Recordar Credenciales**: Persistencia opcional
- **Recuperación de Contraseña**: Enlaces de recuperación

### 2. Dashboards Especializados

#### Dashboard Paciente
- **Métricas de Salud**: KPIs de riesgo cardiovascular y diabetes
- **Historial de Mediciones**: Gráficos de evolución temporal
- **Recomendaciones Personalizadas**: Sugerencias basadas en IA
- **Notificaciones**: Alertas de salud importantes

#### Dashboard Doctor
- **Gestión de Pacientes**: Lista completa de pacientes asignados
- **Estadísticas Clínicas**: Métricas de salud poblacional
- **Recomendaciones Médicas**: Sugerencias para pacientes
- **Calendario de Citas**: Programación de consultas

#### Dashboard Institución
- **Gestión de Doctores**: CRUD completo de personal médico
- **Analytics Institucional**: Estadísticas de rendimiento
- **Gestión de Pacientes**: Visibilidad de pacientes asociados
- **Reportes Administrativos**: Métricas operativas

### 3. Sistema de Mediciones

#### Captura de Datos Biométricos
```javascript
// Validación automática de rangos médicos
const errors = validateMeasurementData(formData);
if (errors.length === 0) {
    await saveMeasurements(formattedData);
}
```

#### Tipos de Medición Soportados
- **Presión Arterial**: Sistólica/diastólica con validación
- **Glucosa**: Niveles de azúcar en sangre
- **Peso y Altura**: Cálculo automático de IMC
- **Frecuencia Cardíaca**: Ritmo cardíaco en reposo
- **Saturación de Oxígeno**: Niveles SpO2

#### Validación Inteligente
- **Rangos Médicos**: Límites fisiológicos por tipo de medición
- **Unidades Consistentes**: Conversión automática de unidades
- **Validación Cruzada**: Relaciones entre mediciones (ej: presión sistólica > diastólica)

### 4. Gestión de Estilo de Vida

#### Hábitos Saludables
- **Actividad Física**: Minutos semanales con recomendaciones
- **Hábitos Alimenticios**: Registro de patrones nutricionales
- **Consumo de Sustancias**: Tabaquismo y alcohol con cuantificación
- **Sueño**: Calidad y duración del descanso

#### Seguimiento Longitudinal
- **Tendencias**: Evolución de hábitos en el tiempo
- **Objetivos**: Metas personalizadas de mejora
- **Feedback**: Retroalimentación basada en progreso

### 5. Sistema de Recomendaciones

#### Recomendaciones Inteligentes
```javascript
// Sistema de recomendaciones por prioridad
const recommendations = [
    { tipo: 'urgente', titulo: 'Control Glucosa', prioridad: 'high' },
    { tipo: 'preventivo', titulo: 'Ejercicio Regular', prioridad: 'medium' },
    { tipo: 'seguimiento', titulo: 'Consulta Médica', prioridad: 'low' }
];
```

#### Categorías de Recomendaciones
- **Urgentes**: Riesgos críticos que requieren atención inmediata
- **Preventivas**: Medidas para prevenir enfermedades
- **Seguimiento**: Monitoreo continuo de condiciones crónicas
- **Educativas**: Información general sobre salud

### 6. Sistema de Notificaciones

#### Tipos de Notificaciones
- **Alertas Médicas**: Recordatorios de mediciones
- **Recordatorios**: Citas médicas y medicamentos
- **Actualizaciones**: Cambios en recomendaciones
- **Anuncios**: Información institucional

#### Gestión de Notificaciones
- **Estados**: Pendiente, Leída, Aplicada, Rechazada
- **Priorización**: Ordenamiento por urgencia
- **Historial**: Registro completo de interacciones

## Configuración y Nomenclatura

### Sistema de Nomenclatura Estándar

#### Mapeo Campo-Frontend ↔ Backend
```javascript
const fieldMapping = {
    // Mediciones
    'bp_systolic': 'presion_sistolica',
    'bp_diastolic': 'presion_diastolica',
    'glucose': 'glucosa',
    'weight': 'peso_kg',
    'height': 'altura_cm',

    // Estilo de vida
    'smoker': 'fumador',
    'alcohol_consumption': 'consumo_alcohol',
    'physical_activity': 'minutos_actividad_fisica_semanal'
};
```

#### Rangos Médicos Validados
```javascript
const medicalRanges = {
    'presion_sistolica': { min: 50, max: 250, unit: 'mmHg' },
    'presion_diastolica': { min: 30, max: 150, unit: 'mmHg' },
    'glucosa': { min: 30, max: 600, unit: 'mg/dL' },
    'peso_kg': { min: 10, max: 300, unit: 'kg' },
    'altura_cm': { min: 50, max: 250, unit: 'cm' }
};
```

### Utilidades de Nomenclatura

#### Conversión Automática
```javascript
// Frontend → Backend
const backendData = NomenclatureUtils.mapFormToBackend(formData);

// Backend → Frontend
const formData = NomenclatureUtils.mapBackendToForm(backendData);
```

#### Validación Inteligente
```javascript
// Validar valores médicos
const isValid = NomenclatureUtils.validateMedicalValue('glucosa', 120);

// Validar presión arterial completa
const isValidBP = NomenclatureUtils.validateBloodPressure(120, 80);
```

## APIs y Comunicación

### Cliente API Principal

#### PredictHealthAPI
```javascript
const PredictHealthAPI = {
    // Dashboard
    async fetchDashboard() { /* ... */ },

    // Mediciones
    async saveMeasurements(data) { /* ... */ },

    // Estilo de vida
    async saveLifestyle(data) { /* ... */ },

    // Autenticación
    async logout() { /* ... */ }
};
```

#### Configuración de Solicitudes
```javascript
const response = await fetch('/api/web/dashboard', {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include'  // Incluye cookies automáticamente
});
```

### Gestor de Autenticación

#### SessionAuthManager
```javascript
class SessionAuthManager {
    async login(email, password, userType) { /* ... */ }
    async validateSession() { /* ... */ }
    async logout() { /* ... */ }
    setupHTTPInterceptors() { /* ... */ }
}
```

## Interfaz de Usuario

### Diseño Responsivo

#### Breakpoints Bootstrap
- **Extra Small**: <576px (celulares)
- **Small**: ≥576px (celulares grandes)
- **Medium**: ≥768px (tablets)
- **Large**: ≥992px (desktops)
- **Extra Large**: ≥1200px (desktops grandes)

#### Componentes UI
- **Cards**: Contenedores de información
- **Modales**: Formularios y confirmaciones
- **Navegación**: Headers y footers responsivos
- **Formularios**: Validación en tiempo real

### Efectos Visuales

#### WebGL Background
- **Shader Interactivo**: Efectos de irisación animados
- **Mouse Tracking**: Respuesta a movimiento del cursor
- **Performance**: Optimizado para 60fps

#### Animaciones CSS
```css
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}
```

## Seguridad del Frontend

### Protección XSS
- **Sanitización**: Validación de inputs de usuario
- **CSP Headers**: Content Security Policy
- **Escape HTML**: Prevención de inyección de código

### Seguridad de Sesiones
- **Cookies Seguras**: HttpOnly, Secure, SameSite
- **Token Expiration**: Renovación automática
- **Session Validation**: Verificación continua

### Validación de Datos
- **Client-Side**: Validación inmediata en formularios
- **Server-Side**: Validación redundante en backend
- **Cross-Field**: Validaciones entre campos relacionados

## Rendimiento y Optimización

### Optimizaciones Implementadas

#### Carga de Recursos
- **Lazy Loading**: Carga diferida de imágenes
- **Code Splitting**: JavaScript modular
- **Minificación**: CSS y JS comprimidos

#### Cache y Almacenamiento
- **Browser Cache**: Headers de cache apropiados
- **Service Worker**: Cache offline (futuro)
- **Local Storage**: Datos no sensibles

### Métricas de Performance

#### Core Web Vitals
- **LCP**: <2.5s Largest Contentful Paint
- **FID**: <100ms First Input Delay
- **CLS**: <0.1 Cumulative Layout Shift

#### Optimizaciones Específicas
- **Bundle Size**: <500KB JavaScript inicial
- **Time to Interactive**: <3s en conexiones 3G
- **Memory Usage**: <50MB en navegación típica

## Desarrollo y Despliegue

### Configuración de Desarrollo

```bash
# Instalar dependencias (si las hay)
# El frontend es estático, servido por Flask

# Ejecutar servidor de desarrollo
python backend-flask/app.py

# Acceder a la aplicación
# http://localhost:5000
```

### Estructura de Archivos

#### Organización por Funcionalidad
- **CSS**: Un archivo por componente/página
- **JavaScript**: Funciones modulares reutilizables
- **Templates**: Herencia con base.html
- **Imágenes**: Optimizadas y responsivas

### Herramientas de Desarrollo

#### Debugging
```javascript
// Logging estructurado
console.log('✅ Login exitoso:', userData);
console.warn('⚠️ Sesión expirada');
console.error('❌ Error de conexión:', error);
```

#### Validación
```javascript
// Validación de formularios
const errors = validateMeasurementData(formData);
if (errors.length > 0) {
    showValidationErrors(errors);
}
```

## Testing y QA

### Estrategia de Testing

#### Unit Tests
- **Funciones Utilitarias**: Nomenclatura y validaciones
- **API Client**: Funciones de comunicación
- **Auth Manager**: Lógica de autenticación

#### Integration Tests
- **Form Submissions**: Envío completo de formularios
- **API Responses**: Manejo de respuestas del backend
- **Session Management**: Ciclo completo de autenticación

#### E2E Tests
- **User Journeys**: Flujos completos de usuario
- **Cross-Browser**: Compatibilidad entre navegadores
- **Mobile Testing**: Funcionalidad en dispositivos móviles

### Compatibilidad de Navegadores

#### Navegadores Soportados
- **Chrome**: 90+ (recomendado)
- **Firefox**: 88+
- **Safari**: 14+
- **Edge**: 90+

#### Funcionalidades Progresivas
- **JavaScript**: Funcionalidad básica sin JS
- **WebGL**: Fallback a CSS para navegadores antiguos
- **Fetch API**: Polyfill para navegadores legacy

## Documentación Técnica

### Sistema de Documentación

#### Categorías de Docs
- **🏗️ Arquitectura**: Diseño del sistema y componentes
- **💻 Frontend**: Guías de desarrollo y mejores prácticas
- **🗄️ Base de Datos**: Esquemas y relaciones
- **🔧 Backend**: APIs y servicios
- **🤖 ML**: Modelos de predicción y algoritmos
- **📱 Dispositivos**: Integración IoT y wearables
- **🚀 Despliegue**: Configuración y DevOps

#### Navegación por Docs
```html
<!-- Estructura jerárquica -->
/docs                    # Página principal
/docs/arquitectura      # Arquitectura del sistema
/docs/frontend/...      # Documentación específica
```

## Conclusión

El **Frontend de PredictHealth** representa una interfaz web moderna y completa que conecta usuarios finales con el potente backend de microservicios. Su diseño modular, seguridad robusta y experiencia de usuario intuitiva hacen posible la transformación digital de la atención médica predictiva.

### Beneficios Arquitectónicos

- **✅ Experiencia Unificada**: Interfaz consistente para todos los tipos de usuario
- **✅ Escalabilidad**: Arquitectura modular fácilmente extensible
- **✅ Seguridad Integral**: Autenticación robusta y validación de datos
- **✅ Performance Optimizada**: Carga rápida y efectos visuales avanzados
- **✅ Accesibilidad**: Diseño inclusivo y navegación intuitiva
- **✅ Mantenibilidad**: Código organizado y bien documentado

Esta interfaz web sirve como puente entre la complejidad del sistema de salud predictiva y la experiencia del usuario final, haciendo que la tecnología avanzada sea accesible y útil para pacientes, profesionales médicos e instituciones de salud.