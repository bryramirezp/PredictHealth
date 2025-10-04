# PredictHealth Microservices Architecture

## Overview

PredictHealth is a healthcare management system built using a microservices architecture. This directory contains five independent microservices that handle different aspects of the healthcare platform, along with centralized authentication and JWT token management.

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐
│   Frontend      │    │  Backend Flask   │
│   (React/JS)    │◄──►│   (API Gateway)  │
└─────────────────┘    └──────────────────┘
                              │
                    ┌─────────┼─────────┐
                    │         │         │
            ┌───────▼───┐ ┌──▼───┐ ┌───▼────┐
            │ Auth-JWT  │ │Redis │ │Postgre│
            │ Service   │ │      │ │SQL    │
            └───────▲───┘ └──────┘ └───────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
┌───────▼───┐ ┌─────▼───┐ ┌────▼────┐
│Service-   │ │Service- │ │Service-  │
│Admins     │ │Doctors  │ │Patients  │
└───────────┘ └─────────┘ └──────────┘
                    │
            ┌───────▼────┐
            │Service-     │
            │Institutions │
            └─────────────┘
```

## Services Description

### 1. Auth-JWT Service (`auth-jwt-service`)
**Port: 8003**

Centralized authentication and JWT token management service.

**Key Features:**
- User authentication (login/logout)
- JWT token creation, verification, and refresh
- Token revocation and session management
- Device tracking and security monitoring
- Redis-based token storage for high performance
- Health checks and statistics

**Technology:** FastAPI, Redis, PostgreSQL, PyJWT

---

### 2. Service-Admins (`service-admins`)
**Port: 8006**

Administrative user management and institution creation service.

**Key Features:**
- Admin user CRUD operations
- Institution creation (calls institutions service)
- Audit logging for admin actions
- System statistics and monitoring
- Integration with auth service for user creation

**Technology:** FastAPI, PostgreSQL, httpx

---

### 3. Service-Doctors (`service-doctors`)
**Port: 8000**

Medical doctor profile and management service.

**Key Features:**
- Doctor profile CRUD operations
- Patient creation and association
- Doctor search and filtering by specialty/institution
- Statistics on doctors by specialty and institution
- Medical license validation
- Integration with auth service for user creation

**Technology:** FastAPI, PostgreSQL

---

### 4. Service-Institutions (`service-institutions`)
**Port: 8002**

Medical institution management service.

**Key Features:**
- Institution CRUD operations
- Institution search and filtering by type/region
- Statistics on institutions by type and region
- Support for different institution types (hospitals, clinics, etc.)
- Integration with auth service for user creation

**Technology:** FastAPI, PostgreSQL

---

### 5. Service-Patients (`service-patients`)
**Port: 8004**

Patient profile and management service.

**Key Features:**
- Patient profile CRUD operations
- Patient validation states (pending, doctor_validated, etc.)
- Patient search and filtering
- Statistics on patients by gender/validation state/doctor
- Emergency contact management
- Age calculation utilities

**Technology:** FastAPI, PostgreSQL

## Technology Stack

- **Framework:** FastAPI (Python 3.11)
- **Database:** PostgreSQL
- **Cache/Session Store:** Redis
- **ORM:** SQLAlchemy 2.0
- **Authentication:** JWT tokens with bcrypt hashing
- **Containerization:** Docker & Docker Compose
- **API Documentation:** OpenAPI/Swagger
- **Health Checks:** Built-in health endpoints

## Prerequisites

- Docker and Docker Compose
- Python 3.11+ (for local development)
- PostgreSQL client (optional, for database inspection)

## Quick Start

1. **Clone the repository and navigate to the project root**

2. **Start all services:**
   ```bash
   docker-compose up -d
   ```

3. **Verify services are running:**
   ```bash
   docker-compose ps
   ```

4. **Check service health:**
   - Auth-JWT: http://localhost:8003/health
   - Doctors: http://localhost:8000/health
   - Patients: http://localhost:8004/health
   - Institutions: http://localhost:8002/health
   - Admins: http://localhost:8006/health

## Service Dependencies

All microservices follow this startup dependency order:

1. **PostgreSQL** - Database
2. **Redis** - Cache and session storage
3. **Auth-JWT Service** - Authentication foundation
4. **Domain Services** (Doctors, Patients, Institutions, Admins) - Business logic
5. **Backend Flask** - API Gateway

## API Endpoints Summary

### Auth-JWT Service (Port 8003)
- `POST /auth/login` - User authentication
- `POST /auth/logout` - User logout
- `POST /tokens/create` - Create JWT tokens
- `POST /tokens/verify` - Verify token validity
- `POST /tokens/refresh` - Refresh access tokens
- `DELETE /tokens/revoke` - Revoke tokens
- `GET /health` - Health check
- `GET /statistics` - Service statistics

### Service-Admins (Port 8006)
- `POST /api/v1/admins/` - Create admin
- `GET /api/v1/admins/` - List admins
- `GET /api/v1/admins/{id}` - Get admin by ID
- `PUT /api/v1/admins/{id}` - Update admin
- `DELETE /api/v1/admins/{id}` - Delete admin
- `POST /api/v1/admins/institutions` - Create institution
- `GET /api/v1/admins/audit/logs` - Get audit logs

### Service-Doctors (Port 8000)
- `POST /api/v1/doctors/` - Create doctor
- `GET /api/v1/doctors/` - List doctors
- `GET /api/v1/doctors/{id}` - Get doctor by ID
- `GET /api/v1/doctors/statistics` - Doctor statistics

### Service-Institutions (Port 8002)
- `POST /api/v1/institutions/` - Create institution
- `GET /api/v1/institutions/` - List institutions
- `GET /api/v1/institutions/{id}` - Get institution by ID
- `PUT /api/v1/institutions/{id}` - Update institution
- `DELETE /api/v1/institutions/{id}` - Delete institution
- `GET /api/v1/institutions/statistics` - Institution statistics

### Service-Patients (Port 8004)
- `POST /api/v1/patients/` - Create patient
- `GET /api/v1/patients/` - List patients
- `GET /api/v1/patients/{id}` - Get patient by ID
- `GET /api/v1/patients/statistics` - Patient statistics

## Development

### Local Development Setup

1. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # or
   venv\Scripts\activate     # Windows
   ```

2. **Install dependencies for a specific service:**
   ```bash
   cd microservices/service-doctors
   pip install -r requirements.txt
   ```

3. **Set up environment variables:**
   Copy `.env.example` to `.env` and configure database connections, JWT secrets, etc.

4. **Run service locally:**
   ```bash
   cd microservices/service-doctors
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Database Schema

The system uses PostgreSQL with the following main tables:
- `users` - Centralized user authentication
- `user_tokens` - JWT token storage and tracking
- `revoked_tokens` - Revoked token records
- `admins` - Administrator profiles
- `doctors` - Doctor profiles
- `doctor_specialties` - Medical specialties
- `patients` - Patient profiles
- `medical_institutions` - Healthcare institutions

### Environment Variables

Each service requires specific environment variables. Key variables include:

- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `JWT_SECRET_KEY` - JWT signing secret
- `SERVICE_HOST/SERVICE_PORT` - Service binding configuration
- `*_SERVICE_URL` - URLs for inter-service communication

## Monitoring and Health Checks

All services include:
- Health check endpoints (`/health`)
- Service statistics endpoints
- Docker health checks
- Structured logging with configurable levels

## Security Features

- JWT-based authentication with refresh tokens
- Password hashing using bcrypt
- Device fingerprinting and tracking
- Token revocation capabilities
- CORS configuration
- Input validation and sanitization
- SQL injection prevention via SQLAlchemy

## Contributing

1. Follow the existing code structure and patterns
2. Add comprehensive tests for new features
3. Update API documentation
4. Ensure all services maintain their independence
5. Test inter-service communication thoroughly

## Troubleshooting

### Common Issues

1. **Service startup failures:** Check database and Redis connectivity
2. **Authentication errors:** Verify JWT secrets and token validity
3. **Inter-service communication:** Ensure all services are running and network accessible
4. **Database connection issues:** Check PostgreSQL credentials and network

### Logs

View service logs:
```bash
docker-compose logs [service-name]
```

Example:
```bash
docker-compose logs servicio-auth-jwt
```

## License

This project is part of the PredictHealth healthcare management system.

---

For more detailed API documentation, visit the individual service endpoints with `/docs` (e.g., http://localhost:8003/docs).