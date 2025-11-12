# Backend Flask - API Gateway

Flask-based API Gateway and web server for PredictHealth microservices architecture. Acts as the single entry point for frontend requests, handling both HTML page rendering and intelligent routing of API calls to specialized microservices.

## Architecture

### Core Components

- **API Gateway**: Routes HTTP requests to specific microservices
- **Web Server**: Serves HTML pages, Jinja2 templates, and static files
- **Session Manager**: Handles JWT authentication with Redis storage
- **Proxy Service**: Intelligent communication with retries and error handling

### Technology Stack

- **Framework**: Flask 2.3.3
- **Authentication**: JWT with custom middleware
- **Proxy**: Intelligent proxy service with automatic retries
- **Sessions**: Redis for JWT token storage
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
│   │       ├── gateway.py   # Gateway routing
│   │       ├── auth.py      # Authentication endpoints
│   │       ├── health_controller.py  # Health checks
│   │       ├── main.py      # Main endpoints
│   │       └── web_controller.py  # Web API endpoints
│   ├── middleware/
│   │   └── jwt_middleware.py  # JWT middleware with Redis
│   ├── services/
│   │   ├── proxy_service.py  # Intelligent proxy service
│   │   ├── health_service.py # Health services
│   │   └── logging_service.py # Logging services
│   ├── controllers/
│   │   └── frontend_controller.py  # Frontend routes
│   └── utils/
│       └── client_detector.py # Client detection
└── frontend/                # Frontend files (copied in build)
    ├── templates/           # Jinja2 templates
    └── static/              # CSS, JS, images
```

## Features

### API Gateway

- Automatic service detection based on URL and user type
- Automatic JWT Bearer token injection in headers
- Exponential backoff retry logic for temporary failures
- Configurable timeouts per service

### Microservices

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

- Landing page
- User-specific dashboards
- Registration and login forms
- Documentation pages

### JWT Authentication

- Token validation against Redis
- Automatic token renewal on usage
- Secure cookies: HttpOnly, Secure, SameSite
- Secure logout with Redis token removal

## Endpoints

### API Endpoints (`/api/v1/`)

#### Authentication
- `POST /api/v1/auth/login` - Generic login
- `GET /api/v1/auth/validate` - Validate session

#### Web Controller (`/api/web/`)
- `POST /api/web/auth/patient/login` - Patient login
- `POST /api/web/auth/doctor/login` - Doctor login
- `POST /api/web/auth/institution/login` - Institution login
- `GET /api/web/patient/dashboard` - Patient dashboard
- `GET /api/web/doctor/dashboard` - Doctor dashboard
- `GET /api/web/institution/dashboard` - Institution dashboard

#### Gateway
- `GET/POST /api/v1/doctors/*` - Proxy to doctors service
- `GET/POST /api/v1/patients/*` - Proxy to patients service
- `GET/POST /api/v1/institutions/*` - Proxy to institutions service

### Web Pages

#### Public
- `GET /` - Landing page
- `GET /login` - Login page (redirects to landing with modal)
- `GET /docs` - Documentation
- `GET /docs/arquitectura` - Architecture documentation

#### Protected
- `GET /patient/dashboard` - Patient dashboard
- `GET /doctor/dashboard` - Doctor dashboard
- `GET /institution/dashboard` - Institution dashboard

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

# Set environment variables (create .env file)
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

- Automatic `/api/v1` prefix handling for domain services
- JWT Bearer token injection in all requests
- Exponential backoff retry (3 attempts, 1s base delay)
- Configurable timeouts (10s default)
- Comprehensive error handling

### Usage

```python
from app.services.proxy_service import proxy_service

# Proxy GET request
response = proxy_service.proxy_get('doctors', '/api/v1/doctors/')

# Proxy POST request
response = proxy_service.proxy_post('patients', '/api/v1/patients/', data={'name': 'John'})

# Service-specific methods
response = proxy_service.call_doctors_service('GET', '/api/v1/doctors/')
response = proxy_service.call_patients_service('POST', '/api/v1/patients/', data)
```

## JWT Middleware

### Decorators

```python
from app.middleware.jwt_middleware import require_session, require_auth, optional_session

# Require valid session
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

Tokens are stored in Redis with the format:
- `access_token:{jwt_token}` - Access token (15 min default)

## Security

### Authentication
- JWT stateless tokens
- Redis session validation
- Password hashing with bcrypt

### Authorization
- Role-based access control
- Route protection decorators
- Secure session management

### API Protection
- CORS with restrictive origin configuration
- Input validation
- Secure cookie settings (HttpOnly, SameSite)

## Monitoring

### Health Checks

```bash
# Service health
curl http://localhost:5000/health

# API health
curl http://localhost:5000/api/v1/health
```

### Logging

Logging levels are configurable via `LOG_LEVEL` environment variable:
- `DEBUG`: Detailed debug information
- `INFO`: General informational messages
- `WARNING`: Warning messages
- `ERROR`: Error messages

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
