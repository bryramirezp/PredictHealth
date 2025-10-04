# Backend-Flask (API Gateway)

## Overview

Backend-Flask is the **API Gateway** and **frontend server** for the PredictHealth healthcare prediction system. It serves as the central entry point for all client requests, implementing a microservices architecture using Flask.

## Architecture

Backend-Flask acts as an API Gateway that:

- **Routes requests** to specialized microservices
- **Manages authentication** and session handling
- **Serves frontend templates** for the web interface
- **Provides unified API endpoints** for different user types
- **Handles CORS, logging, and health checks**

### Microservices Architecture

```
┌─────────────────┐    ┌──────────────────────┐
│   Frontend      │────│   Backend-Flask      │
│   (HTML/JS)     │    │   (API Gateway)      │
└─────────────────┘    └──────────────────────┘
                              │
                    ┌─────────┼─────────┐
                    │         │         │
            ┌───────▼───┐ ┌──▼───┐ ┌───▼────┐
            │ Auth-JWT  │ │Doctors│ │Patients│
            │ Service   │ │Service│ │Service │
            └───────────┘ └───────┘ └────────┘
                    │         │         │
            ┌───────▼───┐ ┌──▼───┐ ┌───▼────┐
            │Institutions│ │ Admins│ │PostgreSQL│
            │ Service    │ │Service│ │  + Redis │
            └────────────┘ └───────┘ └─────────┘
```

## Features

### 🔐 Authentication & Authorization
- JWT-based authentication with Redis session storage
- Support for multiple user types: patients, doctors, institutions, admins
- HTTP-only secure cookies for session management
- Automatic token refresh and validation

### 🌐 API Gateway
- Intelligent request routing to microservices
- Unified API endpoints (`/api/web/*`)
- Request/response transformation
- Error handling and retry logic

### 🎨 Frontend Serving
- HTML template rendering for dashboards
- Static file serving (CSS, JS, images)
- CORS configuration for frontend communication

### 📊 Dashboard Aggregation
- Patient, doctor, institution, and admin dashboards
- Data aggregation from multiple microservices
- Real-time statistics and health metrics

### 🏥 Healthcare-Specific Features
- Institution management (doctors, patients)
- Doctor-patient relationships
- Health data tracking and analytics
- Audit logging for compliance

## Tech Stack

- **Framework**: Flask 2.3.3
- **Authentication**: PyJWT 2.8.0, Redis 5.0.1
- **HTTP Client**: Requests 2.31.0
- **CORS**: Flask-CORS 4.0.0
- **Validation**: Pydantic 2.5.0
- **Database**: PostgreSQL (via microservices)
- **Cache**: Redis
- **Container**: Docker
- **Testing**: Pytest 7.4.3

## Installation

### Prerequisites
- Python 3.11+
- Docker and Docker Compose
- Git

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PredictHealth
   ```

2. **Environment Configuration**
   ```bash
   cp backend-flask/.env.example backend-flask/.env
   # Edit .env with your configuration
   ```

3. **Install Dependencies**
   ```bash
   cd backend-flask
   pip install -r requirements.txt
   ```

4. **Run with Docker Compose**
   ```bash
   # From project root
   docker-compose up -d
   ```

5. **Access the Application**
   - API Gateway: http://localhost:5000
   - Health Check: http://localhost:5000/health

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JWT_SECRET_KEY` | Secret key for JWT signing | `UDEM` |
| `JWT_ALGORITHM` | JWT algorithm | `HS256` |
| `JWT_SERVICE_URL` | Auth-JWT service URL | `http://servicio-auth-jwt:8003` |
| `DOCTOR_SERVICE_URL` | Doctors service URL | `http://servicio-doctores:8000` |
| `PATIENT_SERVICE_URL` | Patients service URL | `http://servicio-pacientes:8004` |
| `INSTITUTION_SERVICE_URL` | Institutions service URL | `http://servicio-instituciones:8002` |
| `ADMIN_SERVICE_URL` | Admins service URL | `http://servicio-admins:8006` |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://...` |
| `REDIS_URL` | Redis connection URL | `redis://redis:6379/0` |
| `SECRET_KEY` | Flask secret key | Random string |
| `FLASK_ENV` | Flask environment | `development` |
| `FLASK_DEBUG` | Debug mode | `1` |
| `LOG_LEVEL` | Logging level | `INFO` |
| `CORS_ORIGINS` | Allowed CORS origins | `http://localhost:5000,http://localhost:3000` |

## API Endpoints

### Authentication
- `POST /api/web/auth/login` - Generic login (auto-detects user type)
- `POST /api/web/auth/patient/login` - Patient login
- `POST /api/web/auth/doctor/login` - Doctor login
- `POST /api/web/auth/institution/login` - Institution login
- `POST /api/web/auth/admin/login` - Admin login
- `GET /api/web/auth/session/validate` - Validate session
- `POST /api/web/auth/logout` - Logout

### Dashboards
- `GET /api/web/patient/dashboard` - Patient dashboard data
- `GET /api/web/doctor/dashboard` - Doctor dashboard data
- `GET /api/web/institution/dashboard` - Institution dashboard data
- `GET /api/web/admin/dashboard` - Admin dashboard data

### Institution Management
- `GET /api/web/institution/doctors` - List institution doctors
- `POST /api/web/institution/doctors` - Create doctor
- `GET /api/web/institution/patients` - List institution patients

### Admin Operations
- `GET /api/web/admin/institutions` - List all institutions
- `POST /api/web/admin/institutions` - Create institution
- `GET /api/web/admin/admins` - List all admins
- `POST /api/web/admin/admins` - Create admin
- `GET /api/web/admin/statistics` - System statistics

### Health & Monitoring
- `GET /health` - Service health check
- `GET /api/web/health` - Web API health check
- `GET /api/web/admin/health` - Admin service health check

## Development

### Project Structure
```
backend-flask/
├── app/
│   ├── api/v1/           # API blueprints
│   │   ├── auth.py       # Authentication endpoints
│   │   ├── doctors.py    # Doctor management
│   │   ├── web_controller.py  # Main web API
│   │   └── ...
│   ├── core/
│   │   └── config.py     # Configuration
│   ├── middleware/
│   │   └── jwt_middleware.py  # JWT handling
│   ├── services/
│   │   ├── proxy_service.py   # Microservice proxy
│   │   └── auth_service.py    # Auth service client
│   └── utils/           # Utilities
├── .env                 # Environment variables
├── app.py              # Main application
├── requirements.txt    # Python dependencies
├── Dockerfile         # Docker configuration
└── README.md          # This file
```

### Running Tests
```bash
cd backend-flask
pytest
```

### Code Style
- Follow PEP 8 guidelines
- Use type hints where possible
- Maintain comprehensive logging
- Write docstrings for all functions

## Deployment

### Docker Deployment
```bash
# Build and run
docker-compose up --build -d

# View logs
docker-compose logs -f backend-flask

# Scale services
docker-compose up -d --scale backend-flask=3
```

### Production Considerations
- Set `FLASK_ENV=production`
- Use HTTPS with proper SSL certificates
- Configure proper CORS origins
- Set strong `SECRET_KEY` and `JWT_SECRET_KEY`
- Enable Redis persistence
- Configure log aggregation
- Set up monitoring and alerting

## Health Checks

The service includes multiple health check endpoints:

- **Gateway Health**: `GET /health`
- **Web API Health**: `GET /api/web/health`
- **JWT Service Health**: `GET /api/v1/auth/jwt/health`
- **Admin Service Health**: `GET /api/web/admin/health`

## Security

- JWT tokens with expiration
- HTTP-only secure cookies
- CORS configuration
- Input validation with Pydantic
- Password strength requirements
- Audit logging for admin actions
- Principle of least privilege

## Monitoring

- Comprehensive logging with configurable levels
- Health checks for all services
- Request/response logging
- Error tracking and reporting
- Performance monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass
6. Submit a pull request

## License

[Specify your license here]

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation at `/docs`

---

**PredictHealth Backend-Flask** - API Gateway for Healthcare Prediction Platform