# Backend Flask - API Gateway

Flask-based API Gateway and web server for PredictHealth microservices architecture. Single entry point for frontend requests handling HTML page rendering and API routing to specialized microservices.

## Architecture

### Core Components

- **API Gateway**: Routes HTTP requests to specific microservices with JWT token injection
- **Web Server**: Serves HTML pages, Jinja2 templates, and static files
- **JWT Middleware**: Handles JWT authentication with Redis session validation
- **Proxy Service**: Intelligent proxy with exponential backoff retry logic
- **Frontend Controller**: Server-side rendered pages with role-based access

### Technology Stack

- **Framework**: Flask 2.3.3
- **Authentication**: JWT with Redis-backed session storage
- **Proxy**: HTTP proxy with retry logic (3 attempts, exponential backoff)
- **Sessions**: Redis for JWT token storage and validation
- **CORS**: Flask-CORS for frontend integration
- **Templates**: Jinja2 for HTML rendering

## Project Structure

```
backend-flask/
├── app.py                    # Main entry point
├── Dockerfile               # Container configuration
├── requirements.txt         # Python dependencies
├── app/
│   ├── core/
│   │   └── config.py        # Centralized configuration
│   ├── api/
│   │   └── v1/
│   │       ├── __init__.py  # API v1 blueprint
│   │       ├── gateway.py   # Gateway routing (proxy to microservices)
│   │       ├── auth.py      # Authentication endpoints
│   │       ├── health_controller.py  # Health data endpoints
│   │       ├── main.py      # Main API endpoints
│   │       └── web_controller.py  # Web API endpoints (/api/web)
│   ├── middleware/
│   │   ├── __init__.py      # Middleware exports
│   │   └── jwt_middleware.py  # JWT middleware with Redis
│   ├── services/
│   │   ├── proxy_service.py  # Intelligent proxy service
│   │   ├── health_service.py # Health data services
│   │   └── logging_service.py # Logging services
│   ├── controllers/
│   │   └── frontend_controller.py  # Frontend routes (dashboards)
│   └── utils/
│       └── client_detector.py # Client detection (web/mobile)
└── frontend/                # Frontend files (copied in build)
    ├── templates/           # Jinja2 templates
    └── static/              # CSS, JS, images
```

## Features

### API Gateway

- Automatic routing to microservices based on URL pattern
- JWT Bearer token injection in Authorization headers
- Exponential backoff retry logic (3 attempts, 1s base delay)
- Configurable timeouts (10s default)
- Automatic `/api/v1` prefix handling for domain services

### Microservices Configuration

```python
MICROSERVICES = {
    'jwt': 'http://servicio-auth-jwt:8003',
    'doctors': 'http://servicio-doctores:8000',
    'patients': 'http://servicio-pacientes:8004',
    'institutions': 'http://servicio-instituciones:8002',
    'admins': 'http://servicio-admins:8006'
}
```

### Web Server

- Landing page with login modal
- Role-based dashboards (patient, doctor, institution)
- Protected routes with JWT middleware
- Documentation pages

### JWT Authentication

- Token validation against Redis (`access_token:{jwt_token}`)
- Cookie-based session management (`predicthealth_jwt`)
- Secure cookies: HttpOnly, SameSite=Lax
- Automatic token renewal on usage
- Secure logout with Redis token removal

## Endpoints

### API Gateway (`/api/v1/`)

#### Gateway Proxy
- `GET/POST/PUT/DELETE /api/v1/auth/<path>` - Proxy to auth service
- `GET/POST/PUT/DELETE /api/v1/patients/<path>` - Proxy to patients service (protected)
- `GET/POST/PUT/DELETE /api/v1/doctors/<path>` - Proxy to doctors service (protected)
- `GET/POST/PUT/DELETE /api/v1/institutions/<path>` - Proxy to institutions service (protected)

#### Authentication (`/api/v1/auth/`)
- `POST /api/v1/auth/login` - Generic login with session creation
- `POST /api/v1/auth/logout` - Logout and token revocation
- `GET /api/v1/auth/session/validate` - Validate active session
- `GET /api/v1/auth/jwt/health` - JWT service health check

#### Health (`/api/v1/health`)
- `GET /api/v1/health` - API Gateway health check

### Web API (`/api/web/`)

#### Authentication
- `POST /api/web/auth/login` - Generic login (auto-detects user type)
- `POST /api/web/auth/patient/login` - Patient login
- `POST /api/web/auth/doctor/login` - Doctor login
- `POST /api/web/auth/institution/login` - Institution login
- `POST /api/web/auth/logout` - Logout
- `GET /api/web/auth/session/validate` - Validate session
- `GET /api/web/auth/token` - Get current token (protected)

#### Patient Endpoints (Protected)
- `GET /api/web/patient/dashboard` - Patient dashboard data
- `GET /api/web/patient/medical-record` - Medical record
- `GET /api/web/patient/care-team` - Care team (doctor & institution)
- `GET /api/web/patient/profile` - Patient profile

#### Doctor Endpoints (Protected)
- `GET /api/web/doctor/dashboard` - Doctor dashboard data
- `GET /api/web/doctor/patients` - Doctor's patient list
- `GET /api/web/doctor/patients/<patient_id>/medical-record` - Patient medical record

#### Institution Endpoints (Protected)
- `GET /api/web/institution/dashboard` - Institution dashboard
- `GET /api/web/institution/doctors` - Institution doctors list
- `POST /api/web/institution/doctors` - Create new doctor
- `DELETE /api/web/institution/doctors/<doctor_id>` - Delete doctor
- `GET /api/web/institution/patients` - Institution patients list
- `GET /api/web/institution/patients/stats` - Patient statistics

#### Contact
- `POST /api/web/contact` - Contact form submission

### Web Pages

#### Public
- `GET /` - Landing page
- `GET /login` - Login page (redirects to landing with modal)
- `GET /docs` - Documentation
- `GET /docs/arquitectura` - Architecture documentation

#### Protected (Role-based)
- `GET /patient/dashboard` - Patient dashboard
- `GET /patient/medical-record` - Patient medical record
- `GET /patient/my-care-team` - Patient care team
- `GET /patient/profile` - Patient profile
- `GET /doctor/dashboard` - Doctor dashboard
- `GET /doctor/patients` - Doctor patient list
- `GET /doctor/patient-detail/<patient_id>` - Patient detail
- `GET /doctor/my-institution` - Doctor institution
- `GET /doctor/profile` - Doctor profile
- `GET /institution/dashboard` - Institution dashboard
- `GET /institution/doctors` - Institution doctors
- `GET /institution/patients` - Institution patients
- `GET /institution/profile` - Institution profile

### Health
- `GET /health` - Service health check
- `GET /api/v1/health` - API health check

## Configuration

### Environment Variables

```bash
# JWT Configuration
JWT_SECRET_KEY=your-secret-key
JWT_ALGORITHM=HS256

# Microservice URLs
JWT_SERVICE_URL=http://servicio-auth-jwt:8003
DOCTOR_SERVICE_URL=http://servicio-doctores:8000
PATIENT_SERVICE_URL=http://servicio-pacientes:8004
INSTITUTION_SERVICE_URL=http://servicio-instituciones:8002
ADMIN_SERVICE_URL=http://servicio-admins:8006

# Database and Cache
DATABASE_URL=postgresql://user:pass@postgres:5432/predicthealth
REDIS_URL=redis://redis:6379/0

# Flask Configuration
SECRET_KEY=flask-secret-key
FLASK_ENV=development
FLASK_DEBUG=1
LOG_LEVEL=INFO

# CORS Configuration
CORS_ORIGINS=http://localhost:5000,http://localhost:3000
```

## Development

### Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
cp .env.example .env

# Run application
python app.py
```

### Docker

```bash
# Build image
docker build -t predicthealth/backend-flask .

# Run container
docker run -p 5000:5000 --env-file .env predicthealth/backend-flask
```

### Docker Compose

```yaml
services:
  backend-flask:
    build: ./backend-flask
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
    depends_on:
      - postgres
      - redis
      - servicio-auth-jwt
      - servicio-doctores
      - servicio-pacientes
      - servicio-instituciones
```

## Proxy Service

### Features

- Automatic `/api/v1` prefix handling for domain microservices
- JWT Bearer token injection in all requests (from `g.token_id` set by middleware)
- Exponential backoff retry (3 attempts, 1s base delay)
- Configurable timeouts (10s default)
- Comprehensive error handling

### Usage

```python
from app.services.proxy_service import proxy_service

# Generic proxy methods
response = proxy_service.proxy_get('doctors', '/api/v1/doctors/')
response = proxy_service.proxy_post('patients', '/api/v1/patients/', data={'name': 'John'})

# Service-specific methods
response = proxy_service.call_doctors_service('GET', '/api/v1/doctors/')
response = proxy_service.call_patients_service('POST', '/api/v1/patients/', data)
response = proxy_service.call_institutions_service('GET', '/api/v1/institutions/dashboard')
response = proxy_service.call_jwt_service('POST', '/auth/login', data)

# Domain service routing
response = proxy_service.call_domain_service('doctor', 'GET', '/api/v1/doctors/me')
```

## JWT Middleware

### Decorators

```python
from app.middleware.jwt_middleware import require_session, require_auth, optional_session

# Require valid session (from cookie)
@require_session
def protected_route():
    user = g.current_user
    return jsonify(user)

# Require specific user type
@require_auth(required_user_type='doctor')
def doctor_only_route():
    return jsonify({'message': 'Doctor access'})

# Optional session
@optional_session
def public_route():
    if is_authenticated():
        return jsonify(g.current_user)
    return jsonify({'message': 'Public'})
```

### Session Storage

Tokens are stored in Redis with format:
- Key: `access_token:{jwt_token}`
- Value: JWT token (string)
- TTL: 15 minutes (900 seconds) default

### Cookie Configuration

- Name: `predicthealth_jwt`
- HttpOnly: Yes
- Secure: False (True in production with HTTPS)
- SameSite: Lax
- Path: `/`
- Max-Age: 900 seconds (15 minutes)

## Frontend Controller

### Role-based Routes

Protected routes use `login_required(role=None)` decorator:

```python
@frontend_bp.route('/patient/dashboard')
@login_required(role='patient')
def patient_dashboard():
    return render_template('patient/dashboard.html', user=g.user)
```

Routes automatically redirect to landing page if unauthenticated or wrong role.

## Client Detection

Utility for detecting client type (web/mobile):

```python
from app.utils.client_detector import detect_client_type, is_mobile_client

client_type = detect_client_type()  # 'web', 'mobile', or 'unknown'
if is_mobile_client():
    # Mobile-specific logic
    pass
```

## Security

### Authentication
- JWT stateless tokens
- Redis session validation
- Password hashing with bcrypt (handled by auth service)

### Authorization
- Role-based access control (patient, doctor, institution)
- Route protection decorators
- Secure session management

### API Protection
- CORS with restrictive origin configuration
- Input validation
- Secure cookie settings (HttpOnly, SameSite)
- JWT token validation on every protected request

## Monitoring

### Health Checks

```bash
# Service health
curl http://localhost:5000/health

# API health
curl http://localhost:5000/api/v1/health
```

### Logging

Logging levels configurable via `LOG_LEVEL`:
- `DEBUG`: Detailed debug information
- `INFO`: General informational messages
- `WARNING`: Warning messages
- `ERROR`: Error messages

Logging includes:
- User actions
- Security events
- System errors
- Medical data access

## Troubleshooting

### Microservice Connection Issues

```bash
# Verify connectivity
curl http://servicio-doctores:8000/health

# Check configuration
echo $DOCTOR_SERVICE_URL
```

### JWT Issues

```bash
# Check tokens in Redis
redis-cli KEYS "access_token:*"

# Validate token manually
python -c "import jwt; jwt.decode(token, 'secret', algorithms=['HS256'])"
```

### CORS Errors

```bash
# Verify CORS configuration
echo $CORS_ORIGINS

# Check response headers
curl -I http://localhost:5000/api/v1/health
```

## Dependencies

### Production
- Flask==2.3.3
- Flask-CORS==4.0.0
- requests==2.31.0
- python-dotenv==1.0.0
- pydantic[email]==2.5.0
- PyJWT==2.8.0
- bcrypt==4.2.0
- redis==5.0.1

### Development
- pytest==7.4.3
- pytest-flask==1.3.0

## License

Part of the PredictHealth project.
