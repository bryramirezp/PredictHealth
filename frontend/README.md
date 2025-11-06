# Frontend Data Flow Architecture

## Table of Contents
1. [Overview](#overview)
2. [Architecture Components](#architecture-components)
3. [Authentication System](#authentication-system)
4. [JavaScript Module Structure](#javascript-module-structure)
5. [PatientCore Framework](#patientcore-framework)
6. [API Gateway Communication](#api-gateway-communication)
7. [Form Handling Patterns](#form-handling-patterns)
8. [Error Handling & Notifications](#error-handling--notifications)
9. [Patient Modules](#patient-modules)
10. [Database Connectivity](#database-connectivity)

---

## Overview

The PredictHealth frontend is built on a layered architecture that separates concerns across multiple JavaScript modules. The system follows a modular approach where each patient functionality is encapsulated in dedicated modules that share common utilities through the `PatientCore` framework.

### Key Architectural Principles
- **Modular Design**: Each patient feature is a separate, self-contained module
- **Centralized Utilities**: Common functionality is abstracted in `PatientCore`
- **Consistent Patterns**: All modules follow the same initialization and communication patterns
- **Graceful Degradation**: Fallback mechanisms for API failures
- **Type Safety**: Consistent data structures and error handling

---

## Architecture Components

### 1. Core Authentication Layer
```
AuthManager (auth-manager.js)
    ↓
JWT Token Management
    ↓
User Session State
    ↓
PatientCore Authentication
```

### 2. Patient Module Layer
```
Patient Modules
├── dashboard.js
├── medical-record.js
├── care-team.js
└── profile.js
    ↓
PatientCore Framework
    ↓
AuthManager & API Client
```

### 3. Backend Communication Layer
```
Frontend JavaScript
    ↓
API Gateway (Flask Backend)
    ↓
Microservices
    ↓
PostgreSQL Database + Redis Cache
```

---

## Authentication System

### AuthManager Role
The `AuthManager` serves as the primary authentication interface, managing JWT tokens stored in secure cookies.

```javascript
// Token-based authentication
const AuthManager = {
    // Get JWT token from cookies
    getToken() {
        return _getCookie('predicthealth_jwt');
    },
    
    // Get user information from multiple sources
    getUserInfo() {
        // 1. Cookies (primary)
        // 2. Template JINJA2 variables
        // 3. API fallback
        return userData;
    },
    
    // Check login status with token validation
    isLoggedIn() {
        const token = this.getToken();
        const payload = _decodeToken(token);
        return payload.exp > currentTime;
    }
};
```

### PatientCore Authentication Flow
`PatientCore` provides a standardized authentication interface for all patient modules:

```javascript
// Standardized authentication pattern
const userInfo = await PatientCore.checkAuth();
if (!userInfo) {
    window.location.href = '/'; // Redirect to login
    return;
}

// Get user ID with fallback support
const userId = PatientCore.getUserId(userInfo);
```

---

## JavaScript Module Structure

### Module Initialization Pattern
All patient modules follow a consistent initialization pattern:

```javascript
document.addEventListener('DOMContentLoaded', async () => {
    // 1. Page-specific check
    if (window.location.pathname.includes('/patient/module-name')) {
        
        // 2. Dependency verification
        if (!window.PatientCore) {
            console.error("Error: patient-core.js not loaded");
            return;
        }
        
        // 3. Authentication check
        const userInfo = await PatientCore.checkAuth();
        if (userInfo) {
            // 4. Module initialization
            initModuleName(userInfo);
        }
    }
});
```

### Module Communication Flow
```
Page Load → Authentication → Data Fetch → UI Render → User Interaction → Form Submit → API Call → Update UI
```

---

## PatientCore Framework

### Purpose
`PatientCore` serves as the central utility framework that provides:
- Authentication utilities
- API request handling
- Error management
- UI feedback systems
- Data formatting helpers

### Key Components

#### 1. Endpoint Management
```javascript
const PatientCore = {
    ENDPOINTS: {
        DASHBOARD: (patientId) => `/api/v1/gateway/patients/${patientId}/dashboard`,
        MEDICAL_RECORD: (patientId) => `/api/v1/gateway/patients/${patientId}/medical-record`,
        CARE_TEAM: (patientId) => `/api/v1/gateway/patients/${patientId}/care-team`,
        PROFILE: (patientId) => `/api/v1/gateway/patients/${patientId}/profile`,
    }
};
```

#### 2. API Request Handler
```javascript
// Centralized API communication
async apiRequest(url, options = {}) {
    const token = await window.AuthManager.getToken();
    
    const response = await fetch(url, {
        ...options,
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            ...options.headers
        }
    });
    
    if (!response.ok) {
        // Fallback to mock data for demo mode
        return this.getMockDataForUrl(url);
    }
    
    return response.json();
}
```

#### 3. Mock Data System
Provides fallback data when APIs are unavailable:
```javascript
mockDashboardData() {
    return {
        patient: { /* mock patient data */ },
        health_score: 85,
        medications: [ /* mock medications */ ],
        conditions: [ /* mock conditions */ ]
    };
}
```

---

## API Gateway Communication

### Gateway Routing Pattern
The API Gateway (Flask backend) acts as a central router for all requests:

```
Frontend Request → API Gateway → Microservice → Database
     ↓                 ↓              ↓            ↓
/api/v1/gateway/ → auth-jwt-service → patients-service → PostgreSQL
/patients/{id}/    (token validation)   (business logic)    (data persistence)
```

### Endpoint Structure
```
/api/v1/gateway/patients/{patientId}/dashboard
/api/v1/gateway/patients/{patientId}/medical-record
/api/v1/gateway/patients/{patientId}/care-team
/api/v1/gateway/patients/{patientId}/profile
```

### Request Flow Example
```javascript
// 1. Frontend makes request
const data = await PatientCore.apiRequest(
    PatientCore.ENDPOINTS.DASHBOARD(patientId)
);

// 2. Gateway validates JWT and routes
// 3. Microservice processes business logic
// 4. Database returns data
// 5. Gateway formats response
// 6. Frontend receives formatted JSON
```

---

## Form Handling Patterns

### Standard Form Handler Structure
All form submission handlers follow a consistent pattern with three phases:

```javascript
async function handleFormSubmit() {
    // Phase 1: Get form elements
    const form = document.getElementById('form-id');
    const submitBtn = form.querySelector('button[type="submit"]');
    
    try {
        // Phase 2: Setup loading state
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>Processing...';
        
        // Phase 3: Process form data
        const formData = new FormData(form);
        const submitData = Object.fromEntries(formData);
        
        // Phase 4: API call
        const response = await fetch('/api/endpoint', {
            method: 'POST',
            credentials: 'same-origin',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(submitData)
        });
        
        // Phase 5: Handle response
        if (response.ok) {
            // Success: Close modal, reset form, reload data
            const modal = bootstrap.Modal.getInstance(modalElement);
            modal.hide();
            form.reset();
            
            // Reload relevant data
            const userInfo = await PatientCore.getCurrentUserInfo();
            const newData = await PatientCore.apiRequest(endpoint);
            renderUpdatedSection(newData);
            
            // Show success message
            PatientCore.showSuccessMessage('Operation completed successfully');
        } else {
            throw new Error('API request failed');
        }
        
    } catch (error) {
        // Error handling
        PatientCore.showErrorMessage(error.message);
    } finally {
        // Cleanup: Reset button state
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Original Button Text';
    }
}
```

### Email Submission Handler
```javascript
async function handleEmailSubmit() {
    const form = document.getElementById('email-form');
    const submitBtn = form.querySelector('button[type="submit"]');
    
    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';
        
        const formData = new FormData(form);
        const emailData = Object.fromEntries(formData);
        
        const response = await fetch('/api/web/patient/emails', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(emailData)
        });
        
        const result = await response.json();
        
        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar el email');
        }
        
        // Success actions
        const modal = bootstrap.Modal.getInstance(document.getElementById('emailModal'));
        modal.hide();
        form.reset();
        
        // Reload email section
        const userInfo = await PatientCore.getCurrentUserInfo();
        const profileData = await PatientCore.apiRequest(
            PatientCore.ENDPOINTS.PROFILE(PatientCore.getUserId(userInfo))
        );
        renderEmails(profileData.emails);
        
        PatientCore.showSuccessMessage('Email agregado exitosamente');
        
    } catch (error) {
        PatientCore.showErrorMessage(error.message || 'Error al agregar el email');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Email';
    }
}
```

### Phone Submission Handler
```javascript
async function handlePhoneSubmit() {
    const form = document.getElementById('phone-form');
    const submitBtn = form.querySelector('button[type="submit"]');
    
    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';
        
        const formData = new FormData(form);
        const phoneData = Object.fromEntries(formData);
        
        const response = await fetch('/api/web/patient/phones', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(phoneData)
        });
        
        const result = await response.json();
        
        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar el teléfono');
        }
        
        // Success actions
        const modal = bootstrap.Modal.getInstance(document.getElementById('phoneModal'));
        modal.hide();
        form.reset();
        
        // Reload phone section
        const userInfo = await PatientCore.getCurrentUserInfo();
        const profileData = await PatientCore.apiRequest(
            PatientCore.ENDPOINTS.PROFILE(PatientCore.getUserId(userInfo))
        );
        renderPhones(profileData.phones);
        
        PatientCore.showSuccessMessage('Teléfono agregado exitosamente');
        
    } catch (error) {
        PatientCore.showErrorMessage(error.message || 'Error al agregar el teléfono');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Teléfono';
    }
}
```

### Address Submission Handler
```javascript
async function handleAddressSubmit() {
    const form = document.getElementById('address-form');
    const submitBtn = form.querySelector('button[type="submit"]');
    
    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';
        
        const formData = new FormData(form);
        const addressData = Object.fromEntries(formData);
        
        const response = await fetch('/api/web/patient/addresses', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(addressData)
        });
        
        const result = await response.json();
        
        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar la dirección');
        }
        
        // Success actions
        const modal = bootstrap.Modal.getInstance(document.getElementById('addressModal'));
        modal.hide();
        form.reset();
        
        // Reload address section
        const userInfo = await PatientCore.getCurrentUserInfo();
        const profileData = await PatientCore.apiRequest(
            PatientCore.ENDPOINTS.PROFILE(PatientCore.getUserId(userInfo))
        );
        renderAddresses(profileData.addresses);
        
        PatientCore.showSuccessMessage('Dirección agregada exitosamente');
        
    } catch (error) {
        PatientCore.showErrorMessage(error.message || 'Error al agregar la dirección');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Dirección';
    }
}
```

### Password Change Handler
```javascript
async function handlePasswordChange() {
    const form = document.getElementById('password-change-form');
    const submitBtn = document.getElementById('change-password-btn');
    
    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Cambiando...';
        
        const formData = new FormData(form);
        const passwordData = Object.fromEntries(formData);
        
        // Client-side validation
        if (passwordData.newPassword !== passwordData.confirmPassword) {
            throw new Error('Las contraseñas nuevas no coinciden');
        }
        
        const response = await fetch('/api/web/auth/change-password', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                current_password: passwordData.currentPassword,
                new_password: passwordData.newPassword
            })
        });
        
        const result = await response.json();
        
        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al cambiar la contraseña');
        }
        
        // Success actions
        form.reset();
        PatientCore.showSuccessMessage('Contraseña cambiada exitosamente');
        
    } catch (error) {
        PatientCore.showErrorMessage(error.message || 'Error al cambiar la contraseña');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-key me-1"></i>Cambiar Contraseña';
    }
}
```

---

## Error Handling & Notifications

### Unified Notification System
All modules use `PatientCore` for consistent notification management:

```javascript
// Error notification
PatientCore.showErrorMessage('Error description');

// Success notification  
PatientCore.showSuccessMessage('Success description');

// In module-specific handlers
function showErrorMessage(message) {
    console.error('Error:', message);
    PatientCore.showErrorMessage(message);
}
```

### Notification Implementation
```javascript
// PatientCore notification system
showErrorMessage(message) {
    console.error('UI Error:', message);
    
    // Special handling for API errors
    if (message.includes('API') || message.includes('network')) {
        this._showNotification(
            'Modo Demo: Mostrando datos de ejemplo. Las APIs están en desarrollo.', 
            'info', 
            'fa-info-circle'
        );
    } else {
        this._showNotification(message, 'danger', 'fa-exclamation-triangle');
    }
},

showSuccessMessage(message) {
    console.log('UI Success:', message);
    this._showNotification(message, 'success', 'fa-check-circle');
},

_showNotification(message, type, icon) {
    const notification = document.createElement('div');
    notification.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 1050;';
    notification.innerHTML = `
        <i class="fas ${icon} me-2"></i>
        <strong>${type === 'danger' ? 'Error' : 'Éxito'}:</strong> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        const bsAlert = bootstrap.Alert.getOrCreateInstance(notification);
        if (bsAlert) bsAlert.close();
        else notification.remove();
    }, 5000);
}
```

### Cross-Module Consistency
Each module implements the notification interface:

#### dashboard.js
```javascript
// Error handling
PatientCore.showErrorMessage(error.message || 'No se pudo cargar la información del dashboard.');

// Success states
PatientCore.showErrorMessage('La respuesta del servidor no contiene datos válidos del paciente.');
```

#### medical-record.js  
```javascript
// Form submission handlers
async function handleHealthProfileSubmit() {
    PatientCore.showErrorMessage('Funcionalidad no implementada temporalmente. Use los datos existentes.');
}

// Page initialization
catch (error) {
    PatientCore.showErrorMessage('Error al cargar el expediente médico. Por favor, intenta recargar la página.');
}
```

#### profile.js
```javascript
// Form handlers
async function handlePersonalInfoSubmit() {
    PatientCore.showErrorMessage(error.message || 'Error al actualizar la información personal');
    PatientCore.showSuccessMessage('Información personal actualizada exitosamente');
}
```

---

## Patient Modules

### Module Overview

#### 1. Dashboard Module (dashboard.js)
**Purpose**: Main patient dashboard with health metrics and summaries

**Key Functions**:
```javascript
// Main initialization
async function initDashboardPage(userInfo) {
    // Load dashboard data
    const dashboardData = await PatientCore.apiRequest(
        PatientCore.ENDPOINTS.DASHBOARD(PatientCore.getUserId(userInfo))
    );
    
    // Render widgets
    renderDashboardWidgets(dashboardData);
}

// Widget rendering
function renderDashboardWidgets(data) {
    renderWelcomeTitle(data.patient);
    renderHealthScore(data.health_score);
    renderMedications(data.medications);
    renderConditions(data.conditions);
}
```

#### 2. Medical Record Module (medical-record.js)
**Purpose**: Complete medical history management

**Key Functions**:
```javascript
// Initialize medical record page
async function initMedicalRecordPage(userInfo) {
    const recordData = await PatientCore.apiRequest(
        PatientCore.ENDPOINTS.MEDICAL_RECORD(PatientCore.getUserId(userInfo))
    );
    
    renderHealthProfile(recordData.health_profile);
    renderConditions(recordData.conditions);
    renderMedications(recordData.medications);
    renderAllergies(recordData.allergies);
    renderFamilyHistory(recordData.family_history);
}

// Data rendering
function renderHealthProfile(healthProfile) {
    // Render health profile data in UI
    const container = document.getElementById('health-profile-content');
    container.innerHTML = generateHealthProfileHTML(healthProfile);
}
```

#### 3. Care Team Module (care-team.js)
**Purpose**: Doctor and institution relationship management

**Key Functions**:
```javascript
// Initialize care team page
async function initCareTeamPage(userInfo) {
    const careTeamData = await PatientCore.apiRequest(
        PatientCore.ENDPOINTS.CARE_TEAM(PatientCore.getUserId(userInfo))
    );
    
    renderDoctorInfo(careTeamData.doctor);
    renderInstitutionInfo(careTeamData.institution);
}

// Render doctor information
function renderDoctorInfo(doctor) {
    const container = document.getElementById('primary-doctor');
    container.innerHTML = generateDoctorProfileHTML(doctor);
}
```

#### 4. Profile Module (profile.js)
**Purpose**: Personal information and contact management

**Key Functions**:
```javascript
// Initialize profile page
async function initProfilePage(userInfo) {
    const profileData = await PatientCore.apiRequest(
        PatientCore.ENDPOINTS.PROFILE(PatientCore.getUserId(userInfo))
    );
    
    renderPersonalInfo(profileData.personal_info);
    renderEmails(profileData.emails);
    renderPhones(profileData.phones);
    renderAddresses(profileData.addresses);
}

// Form handlers
async function handleEmailSubmit() { /* email handling */ }
async function handlePhoneSubmit() { /* phone handling */ }
async function handleAddressSubmit() { /* address handling */ }
async function handlePasswordChange() { /* password handling */ }
```

---

## Database Connectivity

### Database Layer Architecture
```
Frontend JavaScript
    ↓ HTTP/API
API Gateway (Flask)
    ↓ RPC/HTTP
Microservices (FastAPI)
    ↓ SQLAlchemy ORM
PostgreSQL Database
    ↓
Redis Cache
```

### Database Schema Overview
The shared PostgreSQL database contains these key tables:

#### Users Table
```sql
users (
    id UUID PRIMARY KEY,
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    user_type VARCHAR NOT NULL, -- 'patient', 'doctor', 'institution'
    created_at TIMESTAMP,
    is_active BOOLEAN
)
```

#### Patients Table
```sql
patients (
    id UUID PRIMARY KEY REFERENCES users(id),
    first_name VARCHAR,
    last_name VARCHAR,
    date_of_birth DATE,
    doctor_id UUID REFERENCES doctors(id),
    institution_id UUID REFERENCES medical_institutions(id),
    created_at TIMESTAMP
)
```

#### Health Profiles Table
```sql
health_profiles (
    id UUID PRIMARY KEY,
    patient_id UUID REFERENCES patients(id),
    height_cm INTEGER,
    weight_kg DECIMAL,
    blood_type VARCHAR,
    is_smoker BOOLEAN,
    physical_activity_minutes_weekly INTEGER,
    notes TEXT
)
```

### Connection Pattern
```python
# Microservice database connection (FastAPI)
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Database URL from environment
DATABASE_URL = "postgresql://predictHealth_user:password@postgres:5432/predicthealth_db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Usage in endpoint
@app.get("/patients/{patient_id}/profile")
async def get_patient_profile(patient_id: str, db: Session = Depends(get_db)):
    profile = db.query(HealthProfile).filter(
        HealthProfile.patient_id == patient_id
    ).first()
    return profile
```

### Redis Cache Integration
```python
# Token and session management
import redis
import json

redis_client = redis.Redis(
    host='redis',
    port=6379,
    decode_responses=True
)

# Store JWT token
def store_token(user_id: str, token: str, expires_in: int = 900):
    redis_client.setex(f"access_token:{token}", expires_in, user_id)

# Retrieve token
def get_token_user(token: str):
    return redis_client.get(f"access_token:{token}")
```

---

## Summary

The PredictHealth frontend architecture demonstrates a well-structured, modular design that:

1. **Separates Concerns**: Each module handles a specific patient functionality
2. **Centralizes Utilities**: `PatientCore` provides consistent APIs and utilities
3. **Ensures Security**: JWT-based authentication with secure cookie storage
4. **Handles Errors Gracefully**: Unified notification system and fallback mechanisms
5. **Follows Patterns**: Consistent initialization, API communication, and error handling
6. **Enables Scalability**: Modular design allows easy addition of new features

The system successfully integrates with the backend through the API Gateway, providing a seamless user experience while maintaining clean separation between frontend logic and backend services.