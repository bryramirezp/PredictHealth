# PredictHealth Frontend

Frontend web application for the PredictHealth platform, providing user interfaces for patients, doctors, institutions, and administrators.

## Table of Contents

1. [Overview](#overview)
2. [Technologies](#technologies)
3. [Project Structure](#project-structure)
4. [User Types & Features](#user-types--features)
5. [Core Components](#core-components)
6. [Authentication System](#authentication-system)
7. [API Integration](#api-integration)
8. [Styling & Theming](#styling--theming)
9. [Development](#development)
10. [Architecture](#architecture)

## Overview

The PredictHealth frontend is a multi-user web application built with vanilla JavaScript, HTML5, and CSS3. It provides role-based interfaces for different user types, each with specialized features and dashboards.

### Key Features

- **Multi-User Support**: Separate interfaces for patients, doctors, institutions, and administrators
- **JWT Authentication**: Secure token-based authentication with cookie storage
- **Responsive Design**: Mobile-first design using Bootstrap 5.3
- **Modular Architecture**: Component-based JavaScript modules for maintainability
- **Real-time Updates**: Dynamic data loading and UI updates
- **Error Handling**: Comprehensive error handling with user-friendly notifications

## Technologies

### Core Stack

- **HTML5**: Semantic markup and structure
- **CSS3**: Custom stylesheets with role-based theming
- **JavaScript ES6+**: Modern JavaScript with async/await patterns
- **Bootstrap 5.3**: Responsive UI framework
- **Font Awesome 6.0**: Icon library
- **WebGL**: Advanced visual effects for landing page

### External Libraries

- **Chart.js**: Data visualization (where applicable)
- **Bootstrap Icons**: Additional icon support

## Project Structure

```
frontend/
├── static/
│   ├── css/
│   │   ├── landing.css          # Landing page styles
│   │   ├── patient.css          # Patient-specific styles
│   │   ├── doctor.css           # Doctor-specific styles
│   │   ├── institution.css      # Institution-specific styles
│   │   └── docs.css             # Documentation styles
│   ├── images/
│   │   └── logo.jpg             # Application logo
│   └── js/
│       ├── api-client.js        # Centralized API client
│       ├── auth-manager.js      # JWT authentication manager
│       ├── auth-forms.js        # Authentication form handlers
│       ├── landing.js           # Landing page functionality
│       ├── patient/             # Patient modules
│       │   ├── patient-core.js  # Patient core utilities
│       │   ├── dashboard.js     # Patient dashboard
│       │   ├── medical-record.js # Medical record management
│       │   ├── care-team.js     # Care team management
│       │   └── profile.js       # Profile management
│       ├── doctor/              # Doctor modules
│       │   ├── doctor-core.js   # Doctor core utilities
│       │   ├── doctor-dashboard.js
│       │   ├── doctor-patients.js
│       │   ├── doctor-patient-detail.js
│       │   ├── doctor-institution.js
│       │   └── doctor-profile.js
│       └── institution/         # Institution modules
│           └── institution.js   # Institution core
├── templates/
│   ├── base.html                # Base template
│   ├── index.html               # Landing page
│   ├── 404.html                 # Error pages
│   ├── 500.html
│   ├── includes/
│   │   └── app-header.html      # Shared header component
│   ├── patient/                 # Patient templates
│   │   ├── dashboard.html
│   │   ├── medical-record.html
│   │   ├── my-care-team.html
│   │   └── profile.html
│   ├── doctor/                  # Doctor templates
│   │   ├── dashboard.html
│   │   ├── patients.html
│   │   ├── patient-detail.html
│   │   ├── my-institution.html
│   │   └── profile.html
│   ├── institution/             # Institution templates
│   │   ├── dashboard.html
│   │   ├── doctors.html
│   │   ├── patients.html
│   │   └── profile.html
│   └── docs/                    # Documentation pages
│       ├── docs.html
│       ├── arquitectura.html
│       ├── frontend/
│       ├── backend/
│       ├── database/
│       ├── deploy/
│       ├── devices/
│       └── ml/
└── README.md                    # This file
```

## User Types & Features

### Patient Interface

**Templates**: `templates/patient/`
**JavaScript**: `static/js/patient/`

#### Features

- **Dashboard**: Health metrics, medications, conditions overview
- **Medical Record**: Complete health profile, conditions, medications, allergies, family history
- **Care Team**: Primary doctor and institution information
- **Profile**: Personal information, contact details (emails, phones, addresses), password management

#### Key Modules

- `patient-core.js`: Core utilities and API endpoints
- `dashboard.js`: Dashboard initialization and rendering
- `medical-record.js`: Medical record data management
- `care-team.js`: Care team information display
- `profile.js`: Profile management with form handlers

### Doctor Interface

**Templates**: `templates/doctor/`
**JavaScript**: `static/js/doctor/`

#### Features

- **Dashboard**: Patient overview and statistics
- **Patients**: List of assigned patients
- **Patient Detail**: Detailed patient information and medical records
- **My Institution**: Institution association and details
- **Profile**: Professional profile management

#### Key Modules

- `doctor-core.js`: Doctor-specific utilities
- `doctor-dashboard.js`: Doctor dashboard
- `doctor-patients.js`: Patient list management
- `doctor-patient-detail.js`: Individual patient details
- `doctor-institution.js`: Institution management
- `doctor-profile.js`: Profile management

### Institution Interface

**Templates**: `templates/institution/`
**JavaScript**: `static/js/institution/`

#### Features

- **Dashboard**: Institutional overview and metrics
- **Doctors**: Doctor management and assignments
- **Patients**: Patient registry and management
- **Profile**: Institution profile and settings

### Landing Page

**Template**: `templates/index.html`
**JavaScript**: `static/js/landing.js`

Features:
- WebGL animated background
- Login modal integration
- Responsive hero section
- Call-to-action buttons

## Core Components

### API Client (`api-client.js`)

Centralized API communication module providing:

- Unified request handling
- Automatic authentication header injection
- Error handling and response parsing
- Session-based authentication support

```javascript
// Example usage
const data = await PredictHealthAPI.get('/api/v1/patients/123/dashboard');
```

### Auth Manager (`auth-manager.js`)

JWT token management and user authentication:

- Token storage in secure cookies
- Token validation and expiration checking
- User information retrieval
- Login/logout functionality

```javascript
// Check authentication
const isLoggedIn = await AuthManager.isLoggedIn();

// Get user info
const userInfo = await AuthManager.getUserInfo();
```

### Patient Core (`patient-core.js`)

Shared utilities for patient modules:

- Endpoint definitions
- Authentication checks
- API request wrapper
- Error notification system
- Mock data fallback for development

```javascript
// Check auth and get user
const userInfo = await PatientCore.checkAuth();

// Make API request
const data = await PatientCore.apiRequest(
    PatientCore.ENDPOINTS.DASHBOARD(patientId)
);
```

### Doctor Core (`doctor-core.js`)

Similar structure to Patient Core, providing doctor-specific utilities and endpoints.

## Authentication System

### JWT Token Flow

1. User logs in through landing page modal
2. Backend validates credentials and returns JWT token
3. Token stored in secure cookie (`predicthealth_jwt`)
4. All subsequent requests include token in Authorization header
5. Token validated on each request by backend

### Token Storage

- **Method**: Secure HTTP-only cookies
- **Cookie Name**: `predicthealth_jwt`
- **Security**: SameSite=Lax, HttpOnly (handled by backend)

### Authentication Check Pattern

All protected pages follow this pattern:

```javascript
document.addEventListener('DOMContentLoaded', async () => {
    const userInfo = await PatientCore.checkAuth();
    if (!userInfo) {
        window.location.href = '/';
        return;
    }
    // Initialize page
});
```

## API Integration

### Endpoint Structure

All API calls go through the Flask API Gateway:

```
/api/v1/gateway/{resource}/{id}/{action}
```

### Patient Endpoints

- `GET /api/v1/gateway/patients/{id}/dashboard`
- `GET /api/v1/gateway/patients/{id}/medical-record`
- `GET /api/v1/gateway/patients/{id}/care-team`
- `GET /api/v1/gateway/patients/{id}/profile`
- `POST /api/web/patient/emails`
- `POST /api/web/patient/phones`
- `POST /api/web/patient/addresses`
- `POST /api/web/auth/change-password`

### Request Pattern

```javascript
const response = await fetch('/api/v1/gateway/endpoint', {
    method: 'GET',
    credentials: 'include',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    }
});
```

### Error Handling

- Network errors: Fallback to mock data (development mode)
- 401 Unauthorized: Redirect to login
- 400/500 errors: Display user-friendly error messages
- All errors logged to console for debugging

## Styling & Theming

### Role-Based CSS

The application loads different stylesheets based on user type:

```html
{% if user and user.user_type == 'patient' %}
<link href="{{ url_for('static', filename='css/patient.css') }}" rel="stylesheet">
{% elif user and user.user_type == 'doctor' %}
<link href="{{ url_for('static', filename='css/doctor.css') }}" rel="stylesheet">
{% elif user and user.user_type == 'institution' %}
<link href="{{ url_for('static', filename='css/institution.css') }}" rel="stylesheet">
{% endif %}
```

### CSS Files

- `landing.css`: Landing page styles with WebGL integration
- `patient.css`: Patient interface theme
- `doctor.css`: Doctor interface theme
- `institution.css`: Institution interface theme
- `docs.css`: Documentation pages styling

### Design System

- **Font**: Inter (Google Fonts)
- **Icons**: Font Awesome 6.0
- **Framework**: Bootstrap 5.3
- **Color Scheme**: Role-specific themes
- **Responsive**: Mobile-first approach

## Development

### Local Development

1. Ensure backend services are running (Flask API Gateway, microservices)
2. Serve frontend through Flask backend (port 5000)
3. Access at `http://localhost:5000`

### Template Engine

Uses Jinja2 templating (Flask):

- Base template inheritance
- Block-based content injection
- User data injection via template variables
- Static file URL generation

### JavaScript Module Loading

Modules are loaded in specific order:

1. `api-client.js` - Base API client
2. `auth-manager.js` - Authentication
3. `auth-forms.js` - Form handlers
4. Role-specific core (e.g., `patient-core.js`)
5. Page-specific modules (e.g., `dashboard.js`)

### Development Patterns

#### Module Initialization

```javascript
document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/patient/dashboard')) {
        if (!window.PatientCore) {
            console.error("Error: patient-core.js not loaded");
            return;
        }
        
        const userInfo = await PatientCore.checkAuth();
        if (userInfo) {
            initDashboardPage(userInfo);
        }
    }
});
```

#### Form Submission Pattern

```javascript
async function handleFormSubmit() {
    const form = document.getElementById('form-id');
    const submitBtn = form.querySelector('button[type="submit"]');
    
    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>Processing...';
        
        const formData = new FormData(form);
        const data = Object.fromEntries(formData);
        
        const response = await fetch('/api/endpoint', {
            method: 'POST',
            credentials: 'same-origin',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            // Success handling
            PatientCore.showSuccessMessage('Operation successful');
        } else {
            throw new Error('Request failed');
        }
    } catch (error) {
        PatientCore.showErrorMessage(error.message);
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Submit';
    }
}
```

### Debugging

- Console logging for all API requests
- Error messages displayed to users via notification system
- Network tab for API request inspection
- Template variables exposed to `window.PatientUserData`

## Architecture

### Data Flow

```
User Interaction
    ↓
JavaScript Module
    ↓
PatientCore/DoctorCore (API wrapper)
    ↓
API Client (auth headers)
    ↓
Flask API Gateway
    ↓
Microservices
    ↓
PostgreSQL Database
```

### Module Communication

- **Shared Utilities**: Core modules provide shared functionality
- **Event-Driven**: DOM events trigger module functions
- **Async/Await**: All API calls are asynchronous
- **Error Boundaries**: Try-catch blocks at module level

### State Management

- **No Global State**: Each module manages its own state
- **Template Variables**: User data injected from backend
- **Cookie Storage**: Authentication tokens in cookies
- **DOM as State**: UI reflects current data state

### Security Considerations

- **XSS Prevention**: Template escaping via Jinja2
- **CSRF Protection**: SameSite cookies
- **Token Validation**: JWT validation on every request
- **Input Sanitization**: Form data validation before submission

## File Organization Principles

1. **Separation by Role**: Each user type has dedicated directories
2. **Shared Components**: Common utilities in root `js/` directory
3. **Template Inheritance**: Base template for common structure
4. **CSS Modularity**: Role-specific stylesheets
5. **Module Dependencies**: Clear loading order and dependencies

## Browser Support

- **Modern Browsers**: Chrome, Firefox, Safari, Edge (latest versions)
- **ES6+ Features**: Async/await, arrow functions, template literals
- **CSS3**: Flexbox, Grid, custom properties
- **APIs**: Fetch API, LocalStorage, Cookies

## Performance Considerations

- **Lazy Loading**: Scripts loaded per page
- **Minimal Dependencies**: Vanilla JavaScript where possible
- **Efficient Rendering**: DOM manipulation only when needed
- **API Caching**: Consider implementing client-side caching for static data

## Future Enhancements

- Progressive Web App (PWA) support
- Service Worker for offline functionality
- Client-side routing for SPA-like experience
- Component library standardization
- TypeScript migration for type safety
