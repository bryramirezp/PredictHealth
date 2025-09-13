# 🏥 PredictHealth - Sistema de Predicción de Riesgos Cardiovasculares

Sistema integral de salud que permite a doctores gestionar pacientes y realizar predicciones de riesgo cardiovascular basadas en datos biométricos y hábitos de vida.

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![Hadoop](https://img.shields.io/badge/Hadoop-66CCFF?style=for-the-badge&logo=apachehadoop&logoColor=black)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Ejecución del Sistema](#-ejecución-del-sistema)
- [Acceso a la Aplicación](#-acceso-a-la-aplicación)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [API Endpoints](#-api-endpoints)
- [Solución de Problemas](#-solución-de-problemas)
- [Desarrollo](#-desarrollo)

## 🚀 Características

- **Gestión de Doctores**: Registro y autenticación de profesionales médicos
- **Gestión de Pacientes**: Registro y seguimiento de pacientes por doctores
- **Predicciones de Riesgo**: Algoritmos para evaluar riesgo cardiovascular
- **Dashboard Interactivo**: Visualización de datos y métricas de salud
- **Recomendaciones Médicas**: Sistema de recomendaciones personalizadas
- **Arquitectura de Microservicios**: Backend escalable con FastAPI
- **Frontend Moderno**: Interfaz web responsiva con Flask

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Microservicio │    │   Microservicio │
│   Flask         │◄──►│   Doctores      │◄──►│   Pacientes     │
│   (Puerto 5001) │    │   (Puerto 8000) │    │   (Puerto 8001) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   PostgreSQL    │
                    │   (Puerto 5432) │
                    └─────────────────┘
```

## 📋 Requisitos Previos

### Software Necesario

1. **Docker** (versión 20.10 o superior)
2. **Docker Compose** (versión 2.0 o superior)
3. **Git** (para clonar el repositorio)

### Verificar Instalación

```bash
# Verificar Docker
docker --version
docker-compose --version

# Verificar Git
git --version
```

## 🔧 Instalación y Configuración

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/PredictHealth.git
cd PredictHealth
```

### Paso 2: Configurar Variables de Entorno

El archivo `config.env` ya está configurado con valores por defecto. Si necesitas modificar alguna configuración:

```bash
# Editar configuración (opcional)
nano config.env
```

**Configuración por defecto:**
- Base de datos: `postgresql://admin:admin123@localhost:5432/predicthealth_db`
- Servicio doctores: `http://localhost:8000`
- Servicio pacientes: `http://localhost:8001`
- Frontend: `http://localhost:5001`

### Paso 3: Verificar Archivos de Configuración

Asegúrate de que existan los siguientes archivos:
- ✅ `docker-compose.yml`
- ✅ `config.env`
- ✅ `init.sql`
- ✅ `requirements.txt`
- ✅ `Dockerfile`

## 🚀 Ejecución del Sistema

### Método 1: Ejecución Completa con Docker Compose (Recomendado)

```bash
# Construir y ejecutar todos los servicios
docker-compose up --build

# Para ejecutar en segundo plano
docker-compose up --build -d
```

### Método 2: Ejecución Paso a Paso

```bash
# 1. Levantar solo la base de datos
docker-compose up db -d

# 2. Esperar 30 segundos para que la DB esté lista
sleep 30

# 3. Levantar el servicio de doctores
docker-compose up servicio-doctores -d

# 4. Levantar el servicio de pacientes
docker-compose up servicio-pacientes -d

# 5. Levantar el frontend
docker-compose up frontend -d
```

### Verificar Estado de los Servicios

```bash
# Ver estado de todos los contenedores
docker-compose ps

# Ver logs de un servicio específico
docker-compose logs servicio-doctores
docker-compose logs servicio-pacientes
docker-compose logs frontend
docker-compose logs db
```

## 🌐 Acceso a la Aplicación

Una vez que todos los servicios estén ejecutándose, puedes acceder a:

### URLs Principales

- **Frontend Principal**: http://localhost:5001
- **API Doctores**: http://localhost:8000
- **API Pacientes**: http://localhost:8001
- **Documentación API Doctores**: http://localhost:8000/docs
- **Documentación API Pacientes**: http://localhost:8001/docs

### Flujo de Uso

1. **Registro de Doctor**:
   - Ir a http://localhost:5001/doctor_signup.html
   - Completar formulario de registro médico

2. **Login de Doctor**:
   - Ir a http://localhost:5001/doctor_login.html
   - Iniciar sesión con credenciales

3. **Registro de Paciente**:
   - Desde el dashboard del doctor, registrar nuevos pacientes

4. **Login de Paciente**:
   - Ir a http://localhost:5001/log_in.html
   - Iniciar sesión con credenciales del paciente

## 📁 Estructura del Proyecto

```
PredictHealth/
├── 📁 backend/
│   ├── 📁 servicio-doctores/     # Microservicio de gestión de doctores
│   └── 📁 servicio-pacientes/    # Microservicio de gestión de pacientes
├── 📁 frontend/                  # Controladores y servicios del frontend
├── 📁 static/                    # Archivos estáticos (CSS, JS, imágenes)
├── 📁 templates/                 # Plantillas HTML
├── 📁 shared_models/             # Modelos compartidos entre servicios
├── 📁 database/                  # Scripts de migración y optimización
├── 📄 docker-compose.yml         # Configuración de contenedores
├── 📄 Dockerfile                 # Imagen del frontend
├── 📄 app.py                     # Servidor Flask principal
├── 📄 init.sql                   # Script de inicialización de BD
└── 📄 config.env                 # Variables de entorno
```

## 🔌 API Endpoints

### Servicio de Doctores (Puerto 8000)

```bash
# Autenticación
POST /auth/doctor/register
POST /auth/doctor/login

# Gestión de doctores
GET /doctors/
GET /doctors/{doctor_id}
PUT /doctors/{doctor_id}
```

### Servicio de Pacientes (Puerto 8001)

```bash
# Autenticación
POST /auth/patient/register
POST /auth/patient/login

# Gestión de pacientes
GET /patients/
GET /patients/{patient_id}
POST /patients/
PUT /patients/{patient_id}

# Datos de salud
POST /patients/{patient_id}/measurements
GET /patients/{patient_id}/health-profile
POST /patients/{patient_id}/predictions
```

### Frontend (Puerto 5001)

```bash
# Páginas principales
GET /                    # Landing page
GET /log_in.html         # Login pacientes
GET /sign_up.html        # Registro pacientes
GET /doctor_login.html   # Login doctores
GET /doctor_signup.html  # Registro doctores

# Dashboards
GET /user_dashboard.html     # Dashboard paciente
GET /doctor_dashboard.html   # Dashboard doctor
GET /mis_pacientes.html     # Lista de pacientes
```

## 🔧 Solución de Problemas

### Problema: Los servicios no se levantan

```bash
# Verificar logs de errores
docker-compose logs

# Reiniciar servicios
docker-compose down
docker-compose up --build
```

### Problema: Error de conexión a la base de datos

```bash
# Verificar que PostgreSQL esté ejecutándose
docker-compose ps db

# Ver logs de la base de datos
docker-compose logs db

# Reiniciar solo la base de datos
docker-compose restart db
```

### Problema: Puerto ya en uso

```bash
# Verificar qué proceso usa el puerto
netstat -tulpn | grep :5001
netstat -tulpn | grep :8000
netstat -tulpn | grep :8001
netstat -tulpn | grep :5432

# Detener servicios que usen los puertos
sudo kill -9 <PID>
```

### Problema: Error de permisos en Docker

```bash
# En Linux/Mac, agregar usuario al grupo docker
sudo usermod -aG docker $USER
# Reiniciar sesión después de ejecutar este comando
```

### Comandos de Diagnóstico

```bash
# Ver estado de contenedores
docker ps -a

# Ver uso de recursos
docker stats

# Limpiar contenedores e imágenes no utilizadas
docker system prune -a

# Ver logs en tiempo real
docker-compose logs -f
```

## 🛠️ Desarrollo

### Modo Desarrollo

```bash
# Ejecutar en modo desarrollo con recarga automática
docker-compose up --build

# Para desarrollo del frontend
docker-compose up frontend --build
```

### Agregar Nuevas Dependencias

1. **Frontend**: Editar `requirements.txt` en la raíz
2. **Servicio Doctores**: Editar `backend/servicio-doctores/requirements.txt`
3. **Servicio Pacientes**: Editar `backend/servicio-pacientes/requirements.txt`

### Base de Datos

```bash
# Acceder a la base de datos directamente
docker-compose exec db psql -U admin -d predicthealth_db

# Ejecutar migraciones (si las hay)
docker-compose exec servicio-doctores alembic upgrade head
docker-compose exec servicio-pacientes alembic upgrade head
```

### Testing

```bash
# Ejecutar tests (si están implementados)
docker-compose exec servicio-doctores python -m pytest
docker-compose exec servicio-pacientes python -m pytest
```

## 📊 Monitoreo

### Health Checks

```bash
# Verificar estado de servicios
curl http://localhost:8000/health
curl http://localhost:8001/health
curl http://localhost:5001/
```

### Métricas

- **Base de datos**: Puerto 5432
- **Servicio doctores**: Puerto 8000
- **Servicio pacientes**: Puerto 8001
- **Frontend**: Puerto 5001

## 🚨 Comandos de Emergencia

```bash
# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ PERDERÁS DATOS)
docker-compose down -v

# Reconstruir todo desde cero
docker-compose down -v
docker-compose up --build --force-recreate
```

## 📞 Soporte

Si encuentras problemas:

1. **Revisar logs**: `docker-compose logs`
2. **Verificar puertos**: Asegúrate de que los puertos estén libres
3. **Reiniciar servicios**: `docker-compose restart`
4. **Reconstruir**: `docker-compose up --build`

---

## 🎯 Resumen de Comandos Rápidos

```bash
# Instalación completa
git clone <repo-url>
cd PredictHealth
docker-compose up --build

# Verificar estado
docker-compose ps

# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down
```

**¡El sistema estará disponible en http://localhost:5001!** 🚀
