# PredictHealth Microservices Architecture

## Overview

The PredictHealth microservices architecture provides a scalable, modular approach to healthcare data management. This directory contains four specialized microservices that handle different aspects of the health platform, communicating through well-defined APIs and sharing a common PostgreSQL database with Redis caching.

## Architecture Summary

### Technology Stack

- **Framework**: FastAPI (high-performance async web framework)
- **Database**: PostgreSQL with psycopg2 (connection pooling)
- **Cache**: Redis for session management and caching
- **Containerization**: Docker with health checks
- **API Documentation**: Automatic OpenAPI/Swagger documentation
- **Validation**: Pydantic for request/response validation
- **Authentication**: JWT tokens with bcrypt password hashing

### Service Architecture

```
PredictHealth Microservices
├── auth-jwt-service (Port: 8003)
│   ├── JWT token management
│   ├── Authentication endpoints
│   └── Redis-based token storage
├── service-doctors (Port: 8000)
│   ├── Doctor profile management
│   ├── Specialty associations
│   └── Medical license validation
├── service-institutions (Port: 8002)
│   ├── Medical institution management
│   ├── Geographic organization
│   └── License verification
└── service-patients (Port: 8004)
    ├── Patient data management
    ├── Health profile tracking
    └── Validation workflows
```

## Individual Services

### 1. Auth-JWT Service (`auth-jwt-service/`)

**Purpose**: Centralized authentication and JWT token management service

**Key Features**:
- JWT token creation, verification, and refresh
- Redis-based token storage and revocation
- Device fingerprinting and session tracking
- Inter-service authentication support
- User account creation and management

**Main Endpoints**:
- `POST /auth/login` - User authentication
- `POST /auth/verify-token` - Verify token validity
- `POST /auth/session/validate` - Validate JWT session
- `POST /auth/logout` - User logout
- `POST /users/create` - Create new user account

**Technical Highlights**:
- Pure token management (no database dependency for tokens)
- Device information extraction and tracking
- Complete logging and monitoring
- Health checks with Redis connectivity
- Password hashing with bcrypt

**Dependencies**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- bcrypt 4.2.0
- psycopg2-binary 2.9.9
- redis 5.0.1

### 2. Doctors Service (`service-doctors/`)

**Purpose**: Management of healthcare provider data and specialty associations

**Key Features**:
- Complete doctor profile management (CRUD operations)
- Medical specialty and institution associations
- License validation and professional status tracking
- Experience and consultation fee management
- Doctor-specific endpoints for frontend integration

**Main Endpoints**:

**Doctor-Authenticated Endpoints** (for doctor frontend):
- `GET /api/v1/doctors/me/dashboard` - Get dashboard KPIs
- `GET /api/v1/doctors/me/profile` - Get doctor profile
- `PUT /api/v1/doctors/me/profile` - Update doctor profile
- `GET /api/v1/doctors/me/institution` - Get associated institution
- `GET /api/v1/doctors/me/patients` - List assigned patients
- `GET /api/v1/doctors/me/patients/{patient_id}/medical-record` - Get patient medical record

**Admin CRUD Endpoints**:
- `GET /api/v1/doctors` - List doctors with filtering
- `POST /api/v1/doctors` - Create new doctor
- `GET /api/v1/doctors/{id}` - Get doctor details
- `PUT /api/v1/doctors/{id}` - Update doctor
- `DELETE /api/v1/doctors/{id}` - Delete doctor (soft delete)

**Business Logic**:
- Unique email and medical license constraints
- Foreign key relationships with specialties and institutions
- Professional status validation (active, suspended, retired)
- Experience years and fee range validation
- Atomic transaction for doctor creation (includes user account)

**Dependencies**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- psycopg2-binary 2.9.9
- requests 2.31.0

### 3. Institutions Service (`service-institutions/`)

**Purpose**: Management of medical institutions and geographic organization

**Key Features**:
- Registration and management of healthcare facilities
- Geographic distribution and regional analysis
- License verification and accreditation tracking
- Institution type classification (clinic, hospital, insurer, etc.)

**Main Endpoints**:
- `GET /api/v1/institutions` - List institutions with filtering
- `POST /api/v1/institutions` - Create new institution
- `GET /api/v1/institutions/{id}` - Get institution details
- `PUT /api/v1/institutions/{id}` - Update institution
- `DELETE /api/v1/institutions/{id}` - Delete institution (soft delete)

**Business Logic**:
- Institution type validation and constraints
- Unique contact email and license number requirements
- Geographic region and status tracking
- Verification status management
- Atomic transaction for institution creation (includes user account)

**Dependencies**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- psycopg2-binary 2.9.9
- requests 2.31.0
- httpx 0.25.2

### 4. Patients Service (`service-patients/`)

**Purpose**: Management of patient data and health profile tracking

**Key Features**:
- Patient profile registration and management
- Health profile creation and updates
- Validation workflow management
- Medical association tracking (doctor/institution)
- Comprehensive medical record management

**Main Endpoints**:
- `GET /api/v1/patients` - List patients with filtering
- `POST /api/v1/patients` - Create new patient
- `GET /api/v1/patients/{id}` - Get patient details
- `PUT /api/v1/patients/{id}` - Update patient
- `DELETE /api/v1/patients/{id}` - Delete patient (soft delete)
- `GET /api/v1/patients/{id}/dashboard` - Get patient dashboard data
- `GET /api/v1/patients/{id}/medical-record` - Get complete medical record
- `GET /api/v1/patients/{id}/care-team` - Get care team information
- `GET /api/v1/patients/{id}/profile` - Get patient profile details

**Business Logic**:
- Validation status progression (pending → validated_by_doctor → validated_by_institution → full_access)
- Required medical association (must have doctor OR institution)
- Emergency contact validation
- Health profile integration
- Atomic transaction for patient creation (includes user account and health profile)

**Dependencies**:
- FastAPI 0.104.1
- PyJWT 2.8.0
- psycopg2-binary 2.9.9
- requests 2.31.0

## Shared Components

### Auth Client (`shared/auth_client.py`)

HTTP client for inter-service communication with the auth-jwt-service.

**Functions**:
- `create_user(email, password, user_type, reference_id)` - Creates user account in auth service

**Configuration**:
- `AUTH_SERVICE_URL` - Environment variable for auth service endpoint (default: `http://servicio-auth-jwt:8003`)

## Common Service Structure

All microservices follow a consistent architecture:

```
service-name/
├── app/
│   ├── main.py              # FastAPI application entry point
│   ├── domain.py            # Pydantic models and schemas
│   ├── db.py                # Database connection and utilities
│   └── __init__.py
├── Dockerfile               # Container configuration
├── requirements.txt         # Python dependencies
└── .env                     # Environment configuration
```

## Database Integration

### Shared Database Schema

All services connect to the same PostgreSQL database with these key tables:

- **`users`**: Central authentication table
- **`doctors`**: Healthcare provider profiles
- **`patients`**: Patient information and associations
- **`medical_institutions`**: Healthcare facilities
- **`health_profiles`**: Patient health data
- **`doctor_specialties`**: Medical specialty definitions
- **`emails`**: Entity email addresses (polymorphic)
- **`phones`**: Entity phone numbers (polymorphic)
- **`addresses`**: Entity addresses (polymorphic)

### Data Consistency

- **ACID Transactions**: Database-level transaction management
- **Foreign Key Constraints**: Referential integrity enforcement
- **Unique Constraints**: Business rule validation
- **Triggers**: Automatic timestamp updates

### Database Connection

All services use a common database connection pattern:

- **Connection Pooling**: SimpleConnectionPool with 1-10 connections
- **Context Managers**: Automatic connection management
- **DictCursor**: Results returned as dictionaries
- **Error Handling**: Comprehensive logging and error management

### Cache Strategy

- **Redis Integration**: Session storage and temporary caching
- **Token Management**: JWT tokens stored in Redis for fast access
- **Session Handling**: User session data management

## API Design Principles

### RESTful Endpoints

All services follow REST conventions:
- `GET /resource` - List resources with filtering/pagination
- `POST /resource` - Create new resource
- `GET /resource/{id}` - Get specific resource
- `PUT /resource/{id}` - Update resource
- `DELETE /resource/{id}` - Delete resource (soft delete)

### Request/Response Format

- **JSON**: All communication uses JSON format
- **Pydantic Models**: Request/response validation
- **Standard HTTP Status Codes**: Appropriate error handling
- **Pagination**: Large result sets use cursor-based pagination

### Error Handling

- **Structured Error Responses**: Consistent error format
- **HTTP Status Codes**: Appropriate codes for different scenarios
- **Detailed Error Messages**: Informative error descriptions
- **Logging**: Complete error logging for debugging

## Security Features

### Authentication and Authorization

- **JWT Tokens**: Stateless authentication with refresh tokens
- **Password Security**: bcrypt hashing with salt
- **Token Expiration**: Configurable token lifetimes
- **Device Tracking**: Session fingerprinting and monitoring
- **Role-Based Access**: User type validation (patient, doctor, institution)

### Data Protection

- **Input Validation**: Server-side validation on all inputs
- **SQL Injection Prevention**: ORM query parameterization
- **CORS Configuration**: Cross-origin access control
- **Rate Limiting**: Protection against abuse (configurable)

## Containerization and Deployment

### Docker Configuration

Each service includes:
- **Multi-stage Builds**: Optimized production images
- **Health Checks**: Automated service health monitoring
- **Security**: Non-root user execution
- **Dependencies**: Minimal runtime dependencies

### Service Discovery

Services communicate through:
- **Direct HTTP Calls**: RESTful API communication
- **Environment Variables**: Service URL configuration
- **Docker Networks**: Container-to-container communication

### Docker Compose Integration

All services are defined in the root `docker-compose.yml`:
- **Network**: `predicthealth-network` (bridge, subnet: 172.20.0.0/16)
- **Dependencies**: Health check-based service dependencies
- **Volumes**: Persistent data storage
- **Ports**: Exposed service ports for external access

## Monitoring and Observability

### Health Endpoints

Each service provides:
- `GET /health` - Service health status

### Logging

- **Structured Logging**: JSON format with consistent fields
- **Log Levels**: Configurable verbosity (DEBUG, INFO, WARNING, ERROR)
- **Request Tracking**: Request ID and correlation tracking
- **Performance Metrics**: Response times and error rates

## Development Configuration

### Prerequisites

- Python 3.11+
- PostgreSQL database
- Redis server
- Docker and Docker Compose

### Local Development

1. **Clone and Configure**:
   ```bash
   cd microservices/service-name
   # Environment variables are configured in .env (edit if necessary)
   ```

2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Database Configuration**:
   - Ensure PostgreSQL and Redis are running
   - Database schema must be initialized

4. **Run Service**:
   ```bash
   python app/main.py
   # or
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Docker Development

```bash
# Build and run specific service
docker-compose up --build servicio-name

# View logs
docker-compose logs servicio-name

# Access API documentation
open http://localhost:SERVICE_PORT/docs
```

## Inter-Service Communication

### Service-to-Service Calls

Services communicate through HTTP APIs:
- **Auth Service**: Provides authentication for other services
- **Doctors Service**: Manages doctor data for patients and institutions
- **Institutions Service**: Provides institution data for doctors and patients
- **Patients Service**: Integrates with doctors and institutions services

### Authentication Flow

1. User authenticates via `auth-jwt-service`
2. JWT token is returned with user information
3. Other services verify token via `auth-jwt-service` or decode locally
4. Services extract `reference_id` from token for entity access

### Shared Auth Client

The `shared/auth_client.py` module provides:
- Standardized user creation across services
- Error handling and retry logic
- Service URL configuration via environment variables

## API Gateway Pattern

Although not implemented in this architecture, services are designed to work with an API gateway for:
- Request routing and load balancing
- Authentication middleware
- Rate limiting and security
- Request/response transformation

## Testing Strategy

### Unit Testing

- **Model Testing**: Database model validation
- **Service Testing**: Business logic verification
- **API Testing**: Endpoint functionality testing

### Integration Testing

- **Database Integration**: Data persistence and retrieval
- **Inter-Service Communication**: API calls between services
- **Authentication Flow**: Complete authentication workflows

### Load Testing

- **Performance Benchmarks**: Response time validation
- **Concurrency Testing**: Multi-user scenario simulation
- **Resource Usage**: Memory and CPU monitoring

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify `DATABASE_URL` configuration
   - Check PostgreSQL service status
   - Validate connection credentials

2. **Redis Connection Problems**
   - Verify `REDIS_URL` configuration
   - Check Redis service availability
   - Validate Redis connection pool

3. **Inter-Service Communication**
   - Verify service URLs in configuration
   - Check Docker network connectivity
   - Validate API endpoint availability

4. **Authentication Issues**
   - Verify `JWT_SECRET_KEY` configuration
   - Check token expiration settings
   - Validate token storage in Redis

### Debug Mode

Enable detailed logging:
```bash
export LOG_LEVEL=DEBUG
python app/main.py
```

## Performance Optimization

### Database Optimization

- **Connection Pooling**: Efficient database connection management
- **Query Optimization**: Strategic indexing and query planning
- **Caching**: Redis-based caching for frequently accessed data

### Service Optimization

- **Async Operations**: FastAPI async/await for concurrent processing
- **Response Caching**: Redis caching for expensive operations
- **Pagination**: Efficient handling of large datasets

## Future Improvements

### Planned Features

- **API Gateway**: Centralized request routing and authentication
- **Service Mesh**: Advanced inter-service communication and observability
- **Event-Driven Architecture**: Asynchronous event processing
- **Multi-Region Deployment**: Geographic distribution and failover

### Scalability Improvements

- **Horizontal Scaling**: Load balancing across multiple instances
- **Database Sharding**: Data distribution for large-scale deployments
- **Advanced Caching Strategies**: Redis cache patterns
- **Monitoring Dashboard**: Centralized service monitoring

---

The PredictHealth microservices architecture provides a solid, scalable foundation for healthcare data management, with each service specializing in specific domain functionality while maintaining consistent API design and operational practices.
