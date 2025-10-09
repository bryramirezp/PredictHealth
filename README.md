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
  - [🌟 Características Principales](#-características-principales)
  - [🏗️ Arquitectura del Sistema](#️-arquitectura-del-sistema)
  - [📁 Estructura del Proyecto](#-estructura-del-proyecto)
  - [🚀 Inicio Rápido](#-inicio-rápido)
  - [📚 Documentación](#-documentación)
  - [🔧 Tecnologías](#-tecnologías)
  - [📊 Componentes](#-componentes)
  - [💻 Requisitos del Sistema](#-requisitos-del-sistema)
  - [🛠️ Instalación y Configuración](#️-instalación-y-configuración)
  - [🔐 Seguridad](#-seguridad)

## 🌟 Características Principales

### 🎯 **Salud Predictiva Inteligente**
- **Análisis de Riesgos**: Algoritmos avanzados para predicción de enfermedades cardiovasculares y diabetes
- **Recomendaciones Personalizadas**: Sugerencias basadas en IA adaptadas a cada paciente
- **Monitoreo Continuo**: Seguimiento en tiempo real de indicadores de salud

### 👥 **Multi-Usuario Completo**
- **Pacientes**: Dashboards personales con métricas de salud y recomendaciones
- **Doctores**: Gestión de pacientes, análisis clínicos y herramientas de diagnóstico
- **Instituciones**: Administración de personal médico y análisis institucionales
- **Administradores**: Control total del sistema con herramientas CMS avanzadas

### 🔬 **Datos Biométricos Avanzados**
- **Mediciones Médicas**: Presión arterial, glucosa, peso, altura, frecuencia cardíaca
- **Hábitos de Vida**: Actividad física, alimentación, consumo de sustancias
- **Historial Médico**: Antecedentes familiares y condiciones preexistentes
- **Validación Inteligente**: Rangos médicos y lógica de negocio integrada

### 📊 **Analytics y Reportes**
- **Dashboards en Tiempo Real**: KPIs y métricas actualizadas automáticamente
- **Reportes Exportables**: PDF, Excel y CSV con datos estructurados
- **Visualizaciones Interactivas**: Gráficos y tendencias con Chart.js
- **Análisis Geográfico**: Distribución regional de servicios de salud

## 🏗️ Arquitectura del Sistema

```mermaid
graph TB
    subgraph "Frontend Layer"
        WEB[🌐 Frontend Web<br/>HTML/CSS/JS]
        CMS[📊 CMS Backend<br/>Flask Admin]
    end

    subgraph "API Gateway Layer"
        GATEWAY[🚪 Backend Flask<br/>API Gateway]
    end

    subgraph "Microservices Layer"
        AUTH[🔐 auth-jwt-service<br/>Authentication]
        DOCTORS[👨‍⚕️ service-doctors<br/>Healthcare Providers]
        PATIENTS[🏥 service-patients<br/>Patient Management]
        INSTITUTIONS[🏢 service-institutions<br/>Medical Facilities]
    end

    subgraph "Data Layer"
        POSTGRES[(📊 PostgreSQL<br/>Primary Database)]
        REDIS[(⚡ Redis<br/>Cache & Sessions)]
    end

    WEB --> GATEWAY
    CMS --> POSTGRES
    GATEWAY --> AUTH
    GATEWAY --> DOCTORS
    GATEWAY --> PATIENTS
    GATEWAY --> INSTITUTIONS

    AUTH --> POSTGRES
    AUTH --> REDIS
    DOCTORS --> POSTGRES
    PATIENTS --> POSTGRES
    INSTITUTIONS --> POSTGRES
```

### 🏛️ **Principios Arquitectónicos**

- **🔄 Microservicios**: Arquitectura modular con servicios especializados
- **🚪 API Gateway**: Punto único de entrada con enrutamiento inteligente
- **📊 Base de Datos Compartida**: PostgreSQL normalizado 3NF con Redis para caché
- **🔐 Autenticación Centralizada**: JWT con gestión de sesiones en Redis
- **📱 Frontend Responsivo**: Interfaz web moderna con Bootstrap y WebGL
- **⚡ Alto Rendimiento**: Optimización con índices estratégicos y caché inteligente

## 📁 Estructura del Proyecto

```
predicthealth/
├── 📁 microservices/           # 🏗️ Servicios especializados
│   ├── auth-jwt-service/       # Autenticación JWT
│   ├── service-doctors/        # Gestión de doctores
│   ├── service-patients/       # Gestión de pacientes
│   └── service-institutions/   # Gestión de instituciones
├── 📁 backend-flask/           # 🚪 API Gateway Flask
├── 📁 cms-backend/             # 📊 Sistema de gestión administrativa
├── 📁 frontend/                # 🌐 Interfaz web del usuario
├── 📁 database/                # 🗄️ Configuración de base de datos
├── docker-compose.yml          # 🐳 Orquestación de contenedores
├── Dockerfile                  # 🐳 Configuración principal
└── README.md                   # 📖 Este archivo
```

## 🚀 Inicio Rápido

### 🐳 Despliegue con Docker (Recomendado)

```bash
# 1. Clonar el repositorio
git clone https://github.com/your-org/predicthealth.git
cd predicthealth

# 2. Iniciar todos los servicios
docker-compose up --build

# 3. Acceder a la aplicación
# Frontend: http://localhost:5000
# CMS Admin: http://localhost:5001
# Documentación API: http://localhost:8000/docs (auth-jwt)
```

### 🔧 Configuración Manual

```bash
# 1. Instalar dependencias del sistema
sudo apt-get update
sudo apt-get install postgresql redis-server python3.11

# 2. Configurar base de datos
sudo -u postgres createdb predicthealth_db
sudo -u postgres createuser predictHealth_user

# 3. Instalar dependencias Python
pip install -r backend-flask/requirements.txt
pip install -r cms-backend/requirements.txt

# 4. Configurar variables de entorno
cp .env.example .env
# Editar .env con configuración local

# 5. Ejecutar servicios
python backend-flask/app.py &
python cms-backend/app.py &
```

### 🎯 Primeros Pasos

1. **Acceder al Sistema**: Visitar `http://localhost:5000`
2. **Crear Cuenta**: Registrarse como paciente, doctor o institución
3. **Configurar Perfil**: Completar información médica y preferencias
4. **Explorar Dashboard**: Ver métricas de salud y recomendaciones
5. **Administrar Sistema**: Acceder al CMS en `http://localhost:5001`

## 📚 Documentación

### 📖 **Documentación Técnica Detallada**

| Componente | Documentación | Descripción |
|------------|---------------|-------------|
| 🗄️ **Base de Datos** | [📊 Ver README](database/README.md) | Esquema PostgreSQL y Redis |
| 🚪 **API Gateway** | [🔧 Ver README](backend-flask/README.md) | Backend Flask y enrutamiento |
| 🏥 **Microservicios** | [⚙️ Ver README](microservices/README.md) | Servicios especializados |
| 📊 **CMS Backend** | [🛠️ Ver README](cms-backend/README.md) | Sistema administrativo |
| 🌐 **Frontend** | [💻 Ver README](frontend/README.md) | Interfaz web de usuario |


## 🔧 Tecnologías

### 🏗️ **Backend & APIs**
- **Python 3.11+**: Lenguaje principal de desarrollo
- **FastAPI**: Framework para microservicios de alto rendimiento
- **Flask**: Framework web para API Gateway y CMS
- **SQLAlchemy**: ORM para gestión de base de datos
- **Pydantic**: Validación de datos y serialización

### 🗄️ **Base de Datos & Cache**
- **PostgreSQL 15**: Base de datos relacional principal
- **Redis**: Sistema de caché y gestión de sesiones

### 🌐 **Frontend**
- **HTML5/CSS3**: Estructura y estilos modernos
- **JavaScript ES6+**: Lógica del lado cliente
- **Bootstrap 5.3**: Framework CSS responsivo
- **WebGL**: Efectos visuales avanzados
- **Chart.js**: Visualizaciones de datos

### 🐳 **DevOps & Despliegue**
- **Docker**: Contenedorización de servicios
- **Docker Compose**: Orquestación de múltiples contenedores
- **Nginx**: Proxy reverso y balanceo de carga
- **PostgreSQL Client**: Cliente de base de datos
- **Redis Client**: Cliente de caché

## 📊 Componentes

### 🔐 **Servicio de Autenticación (auth-jwt-service)**
- Gestión centralizada de tokens JWT
- Validación y renovación de sesiones
- Huella digital de dispositivos
- Puerto: `8003`

### 👨‍⚕️ **Servicio de Doctores (service-doctors)**
- CRUD completo de perfiles médicos
- Gestión de especialidades y licencias
- Asociación con instituciones
- Puerto: `8000`

### 🏥 **Servicio de Pacientes (service-patients)**
- Gestión de datos de pacientes
- Flujo de trabajo de validación médica
- Integración con perfiles de salud
- Puerto: `8004`

### 🏢 **Servicio de Instituciones (service-institutions)**
- Administración de instalaciones médicas
- Organización geográfica y regional
- Gestión de acreditaciones
- Puerto: `8002`

### 🚪 **API Gateway (backend-flask)**
- Punto único de entrada para el frontend
- Enrutamiento inteligente a microservicios
- Servidor de páginas HTML
- Puerto: `5000`

### 📊 **CMS Backend (cms-backend)**
- Interfaz administrativa completa
- Control de acceso basado en roles
- Generación de reportes y análisis
- Puerto: `5001`

## 💻 Requisitos del Sistema

### 🔧 **Requisitos Mínimos**
- **CPU**: 2 núcleos (4+ recomendado)
- **RAM**: 4GB (8GB+ recomendado)
- **Almacenamiento**: 10GB de espacio disponible
- **Sistema Operativo**: Linux, macOS, Windows 10+

### 🐳 **Requisitos para Docker**
- **Docker**: Versión 20.10+
- **Docker Compose**: Versión 2.0+
- **Memoria**: 8GB+ RAM disponible para contenedores

### 💾 **Requisitos de Base de Datos**
- **PostgreSQL**: Versión 15+
- **Redis**: Versión 6.0+
- **Conexiones**: 20+ conexiones simultáneas soportadas

## 🛠️ Instalación y Configuración

### 📦 **Instalación Completa**

```bash
# 1. Clonar repositorio
git clone https://github.com/your-org/predicthealth.git
cd predicthealth

# 2. Configurar entorno
cp .env.example .env
# Editar .env con configuración específica

# 3. Construir y ejecutar
docker-compose up --build -d

# 4. Verificar estado
docker-compose ps
docker-compose logs
```

### ⚙️ **Configuración Avanzada**

#### Variables de Entorno Principales
```bash
# Base de datos
DATABASE_URL=postgresql://user:pass@postgres:5432/predicthealth_db
REDIS_URL=redis://redis:6379/0

# JWT
JWT_SECRET_KEY=your-super-secret-key-here
JWT_ALGORITHM=HS256

# Flask
SECRET_KEY=flask-secret-key-change-in-production
FLASK_ENV=production

# Microservicios
AUTH_SERVICE_URL=http://auth-jwt-service:8003
DOCTOR_SERVICE_URL=http://service-doctors:8000
PATIENT_SERVICE_URL=http://service-patients:8004
INSTITUTION_SERVICE_URL=http://service-institutions:8002
```

#### Configuración de Docker Compose
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: predicthealth_db
      POSTGRES_USER: predictHealth_user
      POSTGRES_PASSWORD: password

  redis:
    image: redis:alpine
    command: redis-server --maxmemory 1gb --maxmemory-policy allkeys-lru

  backend-flask:
    build: ./backend-flask
    ports:
      - "5000:5000"
    depends_on:
      - postgres
      - redis

  # ... otros servicios
```

## 🔐 Seguridad

### 🛡️ **Características de Seguridad**

- **🔒 Autenticación JWT**: Tokens seguros con expiración automática
- **🔐 Hash de Contraseñas**: bcrypt con sal para almacenamiento seguro
- **🚪 Control de Acceso**: Autorización basada en roles (RBAC)
- **🔍 Validación de Entrada**: Sanitización completa de datos de usuario
- **🛑 Prevención XSS**: Escape de plantillas y validación de contenido
- **🔒 Cookies Seguras**: HttpOnly, Secure, SameSite configuradas
- **📝 Auditoría**: Registro completo de acciones administrativas

### 🔐 **Mejores Prácticas de Seguridad**

- **Claves Fuertes**: Generar claves secretas aleatorias para producción
- **HTTPS**: Habilitar encriptación SSL/TLS en producción
- **Variables de Entorno**: Nunca commitear datos sensibles
- **Actualizaciones**: Mantener dependencias actualizadas regularmente
- **Monitoreo**: Implementar logging y alertas de seguridad


---

<div align="center">

**🚀 PredictHealth - Transformando la atención médica con tecnología inteligente**


</div>