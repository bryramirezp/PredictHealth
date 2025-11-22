# 🏥 PredictHealth - Plataforma de Salud Predictiva

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)

> **Transformando la atención médica con inteligencia predictiva avanzada.** Anticipa riesgos y ofrece cuidados personalizados a través de una plataforma integral de salud digital.

## 📋 Tabla de Contenidos

- [🏥 PredictHealth - Plataforma de Salud Predictiva](#-predicthealth---plataforma-de-salud-predictiva)
  - [📋 Tabla de Contenidos](#-tabla-de-contenidos)
  - [🎯 Contexto y Problema](#-contexto-y-problema)
  - [💡 Descripción de la Solución](#-descripción-de-la-solución)
  - [🏗️ Arquitectura del Sistema](#️-arquitectura-del-sistema)
  - [🚀 Inicio Rápido](#-inicio-rápido)
  - [📚 Documentación Técnica](#-documentación-técnica)
  - [🔧 Stack Tecnológico](#-stack-tecnológico)
  - [📅 Plan de Trabajo](#-plan-de-trabajo)

## 🎯 Contexto y Problema

El **activo más valioso** es la salud. Sin embargo, la atención médica tradicional se enfoca principalmente en el **tratamiento reactivo**: esperamos a que aparezcan síntomas o enfermedades antes de actuar.

### El Problema

Existe una necesidad urgente de una **gestión proactiva de la salud** que vaya más allá del modelo reactivo actual. Específicamente, buscamos abordar el riesgo de **enfermedades crónicas comunes**, como:

- **Diabetes**: Afecta a millones de personas y puede prevenirse con intervención temprana
- **Hipertensión**: Una de las principales causas de enfermedades cardiovasculares
- **Enfermedades Cardiovasculares**: Principal causa de mortalidad a nivel mundial

Estas condiciones pueden **prevenirse o gestionarse mejor** cuando se cuenta con información oportuna, análisis predictivo y recomendaciones personalizadas basadas en los datos individuales de cada persona.

### La Oportunidad

La tecnología actual permite recopilar, procesar y analizar grandes volúmenes de datos de salud para generar insights predictivos. Sin embargo, falta una plataforma integrada que:

- Combine datos históricos del paciente con información de estilo de vida
- Genere predicciones de riesgo personalizadas
- Proporcione recomendaciones preventivas activas y adaptativas
- Evolucione con el comportamiento diario del usuario

## 💡 Descripción de la Solución

PredictHealth es una **plataforma de inteligencia artificial** que funciona en dos niveles para ofrecer una experiencia de salud predictiva completa:

### 🔍 Nivel 1: Análisis Básico (MVP)

> **Nota sobre MVP**: Los modelos de Machine Learning para predicción de enfermedades crónicas **no están implementados en el MVP actual**. El sistema actual se enfoca en la gestión de datos de salud, autenticación y dashboards. Los modelos predictivos están planeados para implementación futura.

Utiliza **datos históricos del paciente** para generar una predicción inicial de riesgo de enfermedades crónicas (planeado para futuras versiones):

- **Expedientes Médicos**: Historial clínico, diagnósticos previos, medicaciones
- **Estilo de Vida**: Actividad física, alimentación, consumo de sustancias, hábitos diarios
- **Genética**: Antecedentes familiares y factores genéticos predisponentes
- **Mediciones Biométricas**: Presión arterial, glucosa, peso, altura, frecuencia cardíaca

Con estos datos, la plataforma generará un **perfil de riesgo inicial** que identifica la probabilidad de desarrollar condiciones crónicas específicas (funcionalidad futura).

### ⚡ Nivel 2: Análisis en Tiempo Real (Futuro)

**Integración con dispositivos wearables** para que la predicción de riesgo evolucione dinámicamente:

- **Datos en Tiempo Real**: Ritmo cardíaco, actividad física, patrones de sueño
- **Evolución Dinámica**: La predicción no es estática, se actualiza según los hábitos diarios
- **Recomendaciones Adaptativas**: Las sugerencias se ajustan automáticamente al comportamiento reciente del usuario
- **Monitoreo Continuo**: Seguimiento 24/7 de indicadores de salud

### 🎯 Valor Diferencial

El valor diferencial de PredictHealth no se limita a mostrar un **porcentaje de riesgo estático**. En su lugar, la plataforma:

- ✅ **Entrega recomendaciones preventivas activas** personalizadas para cada usuario
- ✅ **Se adapta al comportamiento reciente** del usuario, no solo a datos históricos
- ✅ **Evoluciona con el tiempo** para reflejar cambios en hábitos y estilo de vida
- ✅ **Facilita la adherencia** mediante recordatorios, alertas y seguimiento personalizado

## 🏗️ Arquitectura del Sistema

PredictHealth implementa una **arquitectura de microservicios** escalable y modular, diseñada para alta disponibilidad y rendimiento.

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Web (Port 5000)                  │
│  HTML5/CSS3/JavaScript - Bootstrap 5.3 - Jinja2 Templates   │
└──────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              Backend Flask - API Gateway                     │
│  Flask 2.3.3 - JWT Auth - Proxy Service - Web Server         │
│  Port: 5000                                                  │
└──────────┬───────────────────────────────┬──────────────────┘
           │                               │
           ▼                               ▼
┌──────────────────────┐      ┌──────────────────────────────┐
│   Microservicios      │      │    CMS Backend (Port 5001)     │
│   FastAPI 0.104.1     │      │    Flask - Admin Interface    │
│                       │      │    Role-Based Access Control   │
│ • auth-jwt (8003)     │      └──────────────┬────────────────┘
│ • doctors (8000)      │                     │
│ • patients (8004)     │                     │
│ • institutions (8002)  │                     │
└──────────┬────────────┘                     │
           │                                  │
           └──────────┬───────────────────────┘
                      ▼
        ┌────────────────────────────┐
        │   PostgreSQL 15 Database   │
        │   Port: 5432               │
        │   • Normalized 3NF Schema  │
        │   • Stored Procedures       │
        │   • Materialized Views     │
        └────────────┬───────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │   Redis Cache & Sessions   │
        │   Port: 6379               │
        │   • JWT Token Storage      │
        │   • Session Management     │
        │   • Cache Layer            │
        └────────────────────────────┘
```

### Servicios y Puertos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **Frontend/API Gateway** | 5000 | Interfaz web y punto de entrada único |
| **CMS Backend** | 5001 | Panel administrativo |
| **Auth JWT Service** | 8003 | Autenticación y gestión de tokens |
| **Doctors Service** | 8000 | Gestión de doctores |
| **Patients Service** | 8004 | Gestión de pacientes |
| **Institutions Service** | 8002 | Gestión de instituciones |
| **PostgreSQL** | 5432 | Base de datos principal |
| **Redis** | 6379 | Caché y sesiones |

### Flujo de Autenticación

1. Usuario inicia sesión vía API Gateway (`/api/web/auth/login`)
2. API Gateway delega autenticación a `auth-jwt-service`
3. Token JWT se almacena en Redis (`access_token:{token}`)
4. Cookie HTTP-only (`predicthealth_jwt`) se establece en el cliente
5. Requests subsecuentes incluyen cookie automáticamente
6. Middleware JWT valida token contra Redis en cada request

### Patrón API Gateway

El **Backend Flask** actúa como API Gateway único, proporcionando:

- **Enrutamiento Inteligente**: Proxy automático a microservicios según URL pattern
- **Inyección de JWT**: Tokens Bearer inyectados automáticamente en headers
- **Retry Logic**: Reintentos con backoff exponencial (3 intentos, 1s base delay)
- **Timeouts Configurables**: 10s default para requests a microservicios
- **Web Server**: Renderizado de templates Jinja2 y archivos estáticos
- **Middleware JWT**: Validación de sesiones con Redis

## 🚀 Inicio Rápido

### Prerrequisitos

- Docker y Docker Compose instalados
- Git para clonar el repositorio
- PowerShell (Windows) o Bash (Linux/Mac)

### Instalación y Configuración

```powershell
# 1. Clonar el repositorio
git clone https://github.com/your-org/predicthealth.git
cd predicthealth

# 2. Construir y levantar todos los servicios
docker-compose up --build

# 3. Poblar base de datos con datos de prueba desde Powershell
Get-Content populate.sql | docker exec -i predicthealth-postgres psql -U predictHealth_user -d predicthealth_db

#### 4. Probar archivo TKinter

cd PredictHealthPCApp
venv\Scripts\activate
python main.py
```


> **Nota**: El script `init.sql` se ejecuta automáticamente al iniciar PostgreSQL, creando el esquema completo. El script `populate.sql` agrega datos de prueba adicionales.

### Acceso a la Aplicación

Una vez que todos los servicios estén ejecutándose:

- **Frontend Web**: http://localhost:5000
- **CMS Admin**: http://localhost:5001
- **API Docs (Swagger)**: 
  - Auth Service: http://localhost:8003/docs
  - Doctors Service: http://localhost:8000/docs
  - Patients Service: http://localhost:8004/docs
  - Institutions Service: http://localhost:8002/docs

### Primeros Pasos

1. **Acceder al Sistema**: Visitar `http://localhost:5000`
2. **Crear Cuenta**: Registrarse como paciente, doctor o institución desde la landing page
3. **Iniciar Sesión**: Usar credenciales creadas o datos de prueba del populate
4. **Explorar Dashboard**: Cada tipo de usuario tiene un dashboard personalizado
5. **Administrar Sistema**: Acceder al CMS en `http://localhost:5001` con credenciales de admin

### Verificación de Servicios

```powershell
# Verificar estado de contenedores
docker-compose ps

# Ver logs de un servicio específico
docker-compose logs backend-flask
docker-compose logs servicio-doctores

# Verificar health checks
curl http://localhost:5000/health
curl http://localhost:5001/health
curl http://localhost:8000/health
```

## 📚 Documentación Técnica

Para información técnica detallada sobre cada componente del sistema, consulta la documentación específica:

### Componentes del Sistema

| Componente | Documentación | Descripción |
|------------|---------------|-------------|
| 🗄️ **Base de Datos** | [📊 Ver README](database/README.md) | Esquema PostgreSQL 15 normalizado (3NF), Redis, vistas materializadas, procedimientos almacenados, triggers |
| 🚪 **API Gateway** | [🔧 Ver README](backend-flask/README.md) | Flask 2.3.3, enrutamiento de microservicios, autenticación JWT, proxy service con retry logic, middleware |
| 🏥 **Microservicios** | [⚙️ Ver README](microservices/README.md) | Arquitectura FastAPI 0.104.1, servicios especializados (auth, doctors, patients, institutions), comunicación inter-servicios |
| 📊 **CMS Backend** | [🛠️ Ver README](cms-backend/README.md) | Sistema administrativo Flask, gestión CRUD de entidades, reportes y análisis, control de acceso basado en roles (Admin/Editor) |
| 🌐 **Frontend** | [💻 Ver README](frontend/README.md) | Interfaz web JavaScript vanilla, Bootstrap 5.3, autenticación por cookies, módulos por rol (patient/doctor/institution) |

### Características Técnicas Clave

#### Base de Datos
- **Esquema Normalizado**: Tercera Forma Normal (3NF) con integridad referencial
- **Vistas Materializadas**: Optimizadas para dashboards y reportes
- **Procedimientos Almacenados**: Operaciones complejas a nivel de BD
- **Triggers Automatizados**: Actualización automática de timestamps
- **Índices Estratégicos**: Optimización de queries frecuentes

#### API Gateway
- **Proxy Inteligente**: Enrutamiento automático con prefijo `/api/v1`
- **JWT Middleware**: Validación de tokens contra Redis
- **Retry Logic**: 3 intentos con backoff exponencial
- **Web Server**: Renderizado server-side con Jinja2
- **CORS Configurado**: Integración con frontend

#### Microservicios
- **FastAPI Async**: Alto rendimiento con async/await
- **Pydantic Validation**: Validación automática de request/response
- **Connection Pooling**: Gestión eficiente de conexiones PostgreSQL
- **Health Checks**: Monitoreo automatizado de salud
- **OpenAPI Docs**: Documentación automática en `/docs`

#### CMS Backend
- **Control de Acceso**: Roles Admin/Editor con permisos granulares
- **CRUD Completo**: Gestión de doctores, pacientes, instituciones
- **Reportes**: Exportación PDF/Excel/CSV
- **Monitoreo**: Estado de microservicios y base de datos
- **Dashboard Analytics**: Métricas en tiempo real

#### Frontend
- **Multi-Usuario**: Interfaces separadas por rol
- **Autenticación por Sesión**: Cookies HTTP-only seguras
- **Modular**: JavaScript organizado por componentes
- **Responsive**: Bootstrap 5.3 mobile-first
- **Templates Jinja2**: Renderizado server-side

## 🔧 Stack Tecnológico

### Backend & APIs

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **Python** | 3.11+ | Lenguaje principal |
| **FastAPI** | 0.104.1 | Microservicios de alto rendimiento |
| **Flask** | 2.3.3 | API Gateway y CMS |
| **Pydantic** | 2.5.0 | Validación de datos |
| **PyJWT** | 2.8.0 | Autenticación JWT |
| **bcrypt** | 4.2.0 | Hashing de contraseñas |
| **SQLAlchemy** | - | ORM para CMS |
| **psycopg2-binary** | 2.9.9 | Adaptador PostgreSQL |
| **requests** | 2.31.0 | Cliente HTTP |
| **redis** | 5.0.1 | Cliente Redis |

### Base de Datos & Cache

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **PostgreSQL** | 15 | Base de datos relacional principal |
| **Redis** | Latest (Alpine) | Caché y gestión de sesiones |

> **Nota**: Firebase está mencionado en la documentación pero **no está implementado en el MVP**. Está planeado para futuras versiones como base de datos adicional para datos en tiempo real.

### Frontend

| Tecnología | Versión | Uso |
|------------|---------|-----|
| **HTML5/CSS3** | - | Estructura y estilos |
| **JavaScript** | ES6+ | Lógica del lado cliente |
| **Bootstrap** | 5.3 | Framework CSS responsivo |
| **Jinja2** | - | Motor de templates |
| **WebGL** | - | Efectos visuales (landing) |
| **Chart.js** | - | Visualizaciones de datos |
| **Font Awesome** | 6.0 | Iconos |

### DevOps & Despliegue

| Tecnología | Uso |
|------------|-----|
| **Docker** | Contenedorización de servicios |
| **Docker Compose** | Orquestación de múltiples contenedores |
| **Git** | Control de versiones |
| **GitHub** | Repositorio y colaboración |

## 📅 Plan de Trabajo

### 🚀 Fase 1: MVP (12 Semanas)

#### Estado Actual

El proyecto ha completado la **arquitectura base** con:

- ✅ **Backend Completo**: API Gateway, microservicios, CMS
- ✅ **Base de Datos**: Esquema normalizado con datos de prueba
- ✅ **Frontend Web**: Interfaces para pacientes, doctores, instituciones
- ✅ **Autenticación**: Sistema JWT con Redis
- ✅ **Documentación**: READMEs técnicos completos

#### Funcionalidades Fuera del MVP

Las siguientes funcionalidades **no están incluidas en el MVP actual** y están planeadas para futuras versiones:

1. **Modelos de Machine Learning**
   - Modelos predictivos de enfermedades crónicas (diabetes, hipertensión, cardiovasculares)
   - Entrenamiento y validación de modelos
   - Despliegue e integración con servicios
   - Generación de recomendaciones basadas en IA

2. **Firebase**
   - Base de datos en tiempo real
   - Notificaciones push
   - Almacenamiento de archivos e imágenes médicas

3. **Leap Motion**
   - Integración para visualización con simulación
   - Navegación por gestos en dashboards médicos
   - Interacción gestual con visualizaciones 3D

4. **App Android**
   - Aplicación móvil nativa (mencionada pero no detallada)
   - Captura de datos de salud desde móvil
   - Visualización de predicciones en app

### 🔮 Fase 2: Funcionalidades Futuras

#### Tecnologías No Incluidas en MVP

Las siguientes tecnologías están **planeadas para implementación futura** y **no forman parte del MVP actual**:

- **Machine Learning / IA**: Modelos predictivos de enfermedades crónicas, entrenamiento y despliegue de modelos ML
- **Firebase**: Base de datos adicional para datos en tiempo real, notificaciones push y almacenamiento de archivos
- **Leap Motion**: Integración para visualización con simulación y navegación por gestos

#### Funcionalidades Adicionales

- Integración con dispositivos wearables
- Actualización dinámica de predicciones
- Visualizaciones avanzadas de datos
- Modelos de IA más sofisticados
- Escalabilidad horizontal mejorada

---

<div align="center">

**🚀 PredictHealth - Transformando la atención médica con tecnología inteligente**

</div>
