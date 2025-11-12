# PredictHealth CMS Backend

Content Management System backend for PredictHealth platform. Flask-based administrative interface for managing healthcare data including doctors, patients, medical institutions, and system analytics.

## Overview

The CMS Backend provides a secure, role-based administrative interface for managing the PredictHealth healthcare platform. It integrates with the main PostgreSQL database and provides comprehensive CRUD operations, reporting capabilities, and system monitoring.

## Architecture

### Technology Stack

- **Framework**: Flask 2.3.3 with SQLAlchemy ORM
- **Authentication**: Flask-Login with bcrypt password hashing
- **Security**: CSRF protection (Flask-WTF) and role-based access control
- **Database**: PostgreSQL integration with existing schema
- **Frontend**: Jinja2 templates with Bootstrap styling
- **Visualization**: Chart.js for data visualization
- **Reporting**: ReportLab for PDF generation, pandas/openpyxl for Excel export

### Project Structure

```
cms-backend/
├── app.py                 # Main application entry point
├── Dockerfile            # Container configuration
├── requirements.txt      # Python dependencies
└── app/
    ├── __init__.py       # Flask application factory
    ├── config.py         # Configuration management
    ├── models/           # Database models
    │   ├── __init__.py
    │   ├── user.py       # CMS user model
    │   ├── role.py       # Role and permission models
    │   ├── cms_roles.py  # Admin/Editor role definitions
    │   └── existing_models.py  # Read-only models for system data
    ├── routes/           # Route handlers
    │   ├── auth.py       # Authentication routes
    │   ├── dashboard.py  # Main dashboard
    │   ├── entities.py   # CRUD operations for entities
    │   ├── reports.py    # Reporting functionality
    │   ├── settings.py   # System configurations
    │   └── monitoring.py # System monitoring
    ├── templates/        # Jinja2 templates
    ├── static/           # CSS, JS, images
    └── utils/            # Utility functions
        └── role_utils.py # Role-based access control utilities
```

## Features

### 1. Authentication and Authorization

#### User Management
- **CMS Users**: Dedicated administrative accounts (stored in `cms_users` table)
- **Role-Based Access**: Admin and Editor roles with granular permissions
- **Session Management**: Secure session handling with configurable timeouts
- **Password Security**: bcrypt hashing with salt

#### Role System
- **Admin Role**: Full CRUD permissions on all entities
- **Editor Role**: Read and update permissions, no create/delete
- **Permission Matrix**: Resource-action based permissions (doctors, patients, institutions)

### 2. Entity Management

#### Doctor Management
- **CRUD Operations**: Create, read, update, delete doctors
- **Advanced Filtering**: By specialty, institution, experience, status
- **Validation**: Unique email and medical license enforcement
- **Associations**: Linking with specialties and institutions

#### Patient Management
- **Complete Profiles**: Management of demographic and health data
- **Validation Flow**: Pending → Doctor Validated → Institution Validated → Full Access
- **Medical Associations**: Linking with doctors and/or institutions
- **Health Profiles**: Automatic creation with patient registration

#### Institution Management
- **Healthcare Facilities**: Hospitals, clinics, insurers, health centers
- **Geographic Organization**: Region/state-based filtering
- **Verification Status**: Active/inactive and verified status tracking
- **Contact Management**: Complete contact information

### 3. Dashboard and Analytics

#### Real-Time Metrics
- **System Summary**: Total users, doctors, patients, institutions
- **Validation Statistics**: Patient validation status distribution
- **Financial Metrics**: Average consultation fees
- **Growth Tracking**: Monthly registration trends

#### Data Visualization
- **Interactive Charts**: Chart.js-powered visualizations
- **Geographic Distribution**: Mapping of institutions and providers
- **Specialty Distribution**: Doctor specialty analysis
- **Health Conditions**: Population health statistics

### 4. Reporting System

#### Analysis Views
- **Monthly Registrations**: Patient onboarding trends
- **Geographic Analysis**: Regional health distribution
- **Specialty Analysis**: Doctor specialty distribution
- **Health Prevalence**: Condition prevalence statistics

#### Export Capabilities
- **PDF Reports**: ReportLab-generated PDF documents
- **Excel Exports**: pandas/openpyxl for data export
- **CSV Downloads**: Structured data downloads

### 5. System Administration

#### Configuration Management
- **Dynamic Configuration**: Runtime system configurations
- **Environment Variables**: Configurable application behavior
- **File Upload Limits**: Configurable upload restrictions

#### Monitoring
- **Health Checks**: Application health endpoints
- **System Metrics**: Performance monitoring
- **User Activity**: Login tracking and audit logs

## Database Integration

### Schema Architecture

The CMS integrates with the main PredictHealth PostgreSQL database using read-only models for existing system data:

- **`cms_users`**: CMS administrative accounts
- **`cms_roles` & `cms_permissions`**: Role-based access control
- **`doctors`, `patients`, `medical_institutions`**: Health entities
- **`health_profiles`, `doctor_specialties`**: Supporting data
- **`system_settings`**: Dynamic configuration

### Data Flow

1. **Authentication**: CMS users authenticate against `cms_users` table
2. **Authorization**: Role lookup via `cms_roles` and `cms_role_permissions`
3. **Entity Management**: CRUD operations on health entities
4. **Analytics**: Read-only queries against database views and procedures
5. **Configurations**: Runtime configuration via `system_settings` table

## Security Features

### Access Control
- **CSRF Protection**: Flask-WTF CSRF tokens on all forms
- **Session Security**: Secure session configuration with timeouts
- **Role Enforcement**: Permission verification via decorators
- **Input Validation**: Server-side validation on all user inputs

### Data Protection
- **SQL Injection Prevention**: SQLAlchemy ORM protection
- **XSS Prevention**: Template escaping and input sanitization
- **File Upload Security**: Werkzeug secure filename handling
- **Password Policies**: Strong password requirements

## API Endpoints

### Authentication
- `GET/POST /auth/login` - User login
- `POST /auth/logout` - User logout

### Dashboard
- `GET /dashboard/` - Main dashboard with analytics

### Entity Management
- `GET /entities/doctors` - List doctors with filtering
- `GET/POST /entities/doctors/create` - Create new doctor
- `GET/POST /entities/doctors/edit/<id>` - Edit doctor
- `POST /entities/doctors/delete/<id>` - Delete doctor
- `GET /entities/doctors/view/<id>` - View doctor details
- Similar CRUD endpoints for patients and institutions

### Reports
- `GET /reports/` - Reports dashboard
- `GET /reports/monthly` - Monthly registration reports
- `GET /reports/geographic` - Geographic analysis
- `GET /reports/specialties` - Specialty distribution
- `GET /reports/health` - Health condition reports

### Settings
- `GET /settings/` - System settings management
- `GET /settings/system` - System configuration
- `GET /settings/backup` - Backup and restore

### Monitoring
- `GET /monitoring/` - System monitoring dashboard
- `GET /monitoring/microservices` - Microservice status

### Health Check
- `GET /health` - Application health status

## Configuration

### Environment Variables

```bash
# Flask Configuration
SECRET_KEY=your-secret-key-change-in-production
FLASK_ENV=development
DEBUG=True

# Database
DATABASE_URL=postgresql://predictHealth_user:password@postgres:5432/predicthealth_db

# CMS Settings
CMS_TITLE=PredictHealth CMS
CMS_VERSION=1.0.0

# Session
SESSION_TYPE=filesystem
PERMANENT_SESSION_LIFETIME=3600
```

### Configuration Classes

The application supports multiple configuration environments:
- **Development**: Debug mode enabled, detailed error messages
- **Production**: Debug disabled, optimized for performance

## Installation

### Prerequisites

- Python 3.11+
- PostgreSQL database
- Docker and Docker Compose (optional)

### Local Development Setup

1. **Clone and Navigate**:
   ```powershell
   cd cms-backend
   ```

2. **Create Virtual Environment**:
   ```powershell
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   ```

3. **Install Dependencies**:
   ```powershell
   pip install -r requirements.txt
   ```

4. **Configure Environment**:
   Create a `.env` file with required environment variables (see Configuration section)

5. **Database Setup**:
   Ensure PostgreSQL is running and the database schema is initialized

6. **Run Application**:
   ```powershell
   python app.py
   ```

The application will be available at `http://localhost:5001`

### Docker Deployment

```powershell
# Build and run with Docker Compose
docker-compose up --build cms-backend
```

The Dockerfile includes:
- Python 3.11 slim base image
- Health check monitoring
- Non-root user execution
- PostgreSQL client for database connectivity

## Usage

### Admin Workflow

1. **Login**: Access via `/auth/login` with admin credentials
2. **Dashboard Review**: Check system metrics and recent activity
3. **Entity Management**: Create/edit doctors, patients, institutions
4. **Report Generation**: Export system analysis and reports
5. **System Configuration**: Adjust system parameters

### Editor Workflow

1. **Login**: Access with editor credentials
2. **View Entities**: Browse doctors, patients, institutions
3. **Edit Records**: Update information for existing entities
4. **Generate Reports**: Access read-only analysis

## Monitoring and Maintenance

### Health Monitoring
- **Endpoint**: `/health` returns JSON health status
- **Metrics**: Application uptime, database connectivity
- **Alerts**: Automated health checks via Docker

### Performance Optimization
- **Database Queries**: Optimized with SQLAlchemy lazy loading
- **Caching**: Session-based data caching
- **Pagination**: Efficient handling of large datasets
- **Indexing**: Leverages database indexes for fast queries

### Backup and Recovery
- **Data Export**: CSV/Excel export capabilities
- **Audit Logs**: User action logging
- **Configuration Backup**: Environment variable documentation

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify `DATABASE_URL` configuration
   - Check PostgreSQL service status
   - Validate network connectivity

2. **Permission Denied**
   - Confirm user roles and permissions
   - Verify session validity
   - Validate CSRF token

3. **Import Errors**
   - Ensure all dependencies are installed
   - Check Python version compatibility
   - Verify virtual environment activation

### Debug Mode

Enable debug mode for detailed error information:
```powershell
$env:FLASK_ENV="development"
$env:DEBUG="True"
python app.py
```

## Security Best Practices

### Production Deployment
- **Secret Key**: Use strong, randomly generated secret keys
- **HTTPS**: Enable SSL/TLS encryption
- **Environment Variables**: Never commit sensitive data
- **Regular Updates**: Keep dependencies updated
- **Access Logging**: Monitor and audit access patterns

### Data Protection
- **Input Sanitization**: All user inputs validated and sanitized
- **SQL Injection**: ORM prevents injection attacks
- **Session Security**: Secure session configuration

## Development

### Code Standards
- Follow Flask and SQLAlchemy best practices
- Implement proper error handling
- Add comprehensive docstrings
- Write unit tests for new features

### Development Guidelines
- Use virtual environments
- Follow PEP 8 style guidelines
- Implement role-based access control
- Test all database operations
- Document API changes

## License

Part of the PredictHealth platform.
