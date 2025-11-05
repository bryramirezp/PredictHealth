// /frontend/static/js/care-team.js
// Módulo específico para la gestión del equipo médico del paciente
// Maneja la visualización completa de información del doctor e institución

document.addEventListener('DOMContentLoaded', async () => {
    const Auth = window.AuthManager;
    const API = window.PredictHealthAPI;

    // Verificar autenticación
    const userInfo = await Auth.getUserInfo();
    if (!userInfo || userInfo.user_type !== 'patient') {
        console.warn('Acceso denegado: usuario no es paciente');
        return window.location.href = '/';
    }

    // Solo inicializar si estamos en la página del equipo médico
    if (window.location.pathname.includes('/patient/my-care-team')) {
        initCareTeamPage(userInfo, API);
    }
});

// Función principal de inicialización
async function initCareTeamPage(userInfo, API) {
    console.log("Inicializando equipo médico con datos completos...");

    try {
        // Cargar datos del equipo médico
        await loadCareTeamData(API);

        console.log('Equipo médico inicializado correctamente');
    } catch (error) {
        console.error('Error inicializando equipo médico:', error);
        showErrorMessage('Error al cargar la información del equipo médico. Por favor, intenta recargar la página.');
    }
}

// Cargar datos del equipo médico
async function loadCareTeamData(API) {
    try {
        // Obtener el token JWT y patient_id del usuario autenticado
        const token = await Auth.getToken();
        const patientId = userInfo.reference_id;

        if (!token || !patientId) {
            throw new Error('No se pudo obtener la información de autenticación del paciente');
        }

        const response = await fetch(`/api/web/patients/${patientId}/care-team`, {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error en la respuesta del servidor');
        }

        const careTeamData = result.data;

        // Renderizar información del doctor e institución
        renderDoctorInfo(careTeamData.doctor);
        renderInstitutionInfo(careTeamData.institution);

    } catch (error) {
        console.error('Error cargando datos del equipo médico:', error);
        throw error;
    }
}

// Renderizar información completa del doctor
function renderDoctorInfo(doctor) {
    const container = document.getElementById('primary-doctor');

    if (!container) return;

    if (!doctor) {
        container.innerHTML = `
            <div class="text-center text-muted">
                <i class="fas fa-user-md fa-3x mb-3 text-secondary"></i>
                <h5>No hay doctor asignado</h5>
                <p>Actualmente no tienes un doctor asignado a tu cuidado.</p>
            </div>
        `;
        return;
    }

    // Construir información de contacto
    const contactInfo = buildContactInfo(doctor);

    container.innerHTML = `
        <div class="doctor-profile">
            <!-- Avatar y nombre -->
            <div class="text-center mb-4">
                <div class="doctor-avatar mx-auto mb-3">
                    <i class="fas fa-user-md fa-4x text-primary"></i>
                </div>
                <h4 class="card-title mb-1">${doctor.first_name} ${doctor.last_name}</h4>
                <p class="text-muted mb-0">Dr. ${doctor.first_name} ${doctor.last_name}</p>
            </div>

            <!-- Información profesional -->
            <div class="professional-info mb-4">
                <div class="row">
                    <div class="col-sm-6 mb-3">
                        <div class="info-item">
                            <i class="fas fa-stethoscope text-primary me-2"></i>
                            <strong>Especialidad:</strong><br>
                            <span class="text-muted">${doctor.specialty || 'No especificada'}</span>
                        </div>
                    </div>
                    <div class="col-sm-6 mb-3">
                        <div class="info-item">
                            <i class="fas fa-calendar-alt text-primary me-2"></i>
                            <strong>Años de Experiencia:</strong><br>
                            <span class="text-muted">${doctor.years_experience || 'No disponible'} años</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Información de contacto -->
            <div class="contact-info">
                <h6 class="text-primary mb-3">
                    <i class="fas fa-address-book me-2"></i>Información de Contacto
                </h6>
                ${contactInfo}
            </div>

            <!-- Acciones -->
            <div class="actions mt-4 pt-3 border-top">
                <div class="row">
                    <div class="col-6">
                        <button class="btn btn-outline-primary btn-sm w-100" onclick="scheduleAppointment()">
                            <i class="fas fa-calendar-plus me-1"></i>
                            Agendar Cita
                        </button>
                    </div>
                    <div class="col-6">
                        <button class="btn btn-outline-success btn-sm w-100" onclick="contactDoctor()">
                            <i class="fas fa-envelope me-1"></i>
                            Contactar
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// Renderizar información completa de la institución
function renderInstitutionInfo(institution) {
    const container = document.getElementById('medical-institution');

    if (!container) return;

    if (!institution) {
        container.innerHTML = `
            <div class="text-center text-muted">
                <i class="fas fa-hospital fa-3x mb-3 text-secondary"></i>
                <h5>No hay institución asignada</h5>
                <p>Actualmente no tienes una institución médica asignada.</p>
            </div>
        `;
        return;
    }

    // Construir dirección completa
    const fullAddress = buildFullAddress(institution.address);

    // Construir información de contacto
    const contactInfo = buildInstitutionContactInfo(institution);

    container.innerHTML = `
        <div class="institution-profile">
            <!-- Logo y nombre -->
            <div class="text-center mb-4">
                <div class="institution-logo mx-auto mb-3">
                    <i class="fas fa-hospital fa-4x text-success"></i>
                </div>
                <h4 class="card-title mb-1">${institution.name}</h4>
                <p class="text-muted mb-0">${institution.type || 'Institución Médica'}</p>
            </div>

            <!-- Información institucional -->
            <div class="institution-info mb-4">
                <div class="info-item mb-3">
                    <i class="fas fa-building text-success me-2"></i>
                    <strong>Tipo de Institución:</strong><br>
                    <span class="text-muted">${institution.type || 'No especificado'}</span>
                </div>

                ${fullAddress ? `
                <div class="info-item mb-3">
                    <i class="fas fa-map-marker-alt text-success me-2"></i>
                    <strong>Dirección:</strong><br>
                    <span class="text-muted">${fullAddress}</span>
                </div>
                ` : ''}
            </div>

            <!-- Información de contacto -->
            <div class="contact-info">
                <h6 class="text-success mb-3">
                    <i class="fas fa-address-book me-2"></i>Información de Contacto
                </h6>
                ${contactInfo}
            </div>

            <!-- Servicios y acciones -->
            <div class="services mt-4 pt-3 border-top">
                <h6 class="text-success mb-3">
                    <i class="fas fa-concierge-bell me-2"></i>Servicios Disponibles
                </h6>
                <div class="row">
                    <div class="col-6 mb-2">
                        <button class="btn btn-outline-success btn-sm w-100" onclick="viewServices()">
                            <i class="fas fa-list me-1"></i>
                            Ver Servicios
                        </button>
                    </div>
                    <div class="col-6 mb-2">
                        <button class="btn btn-outline-info btn-sm w-100" onclick="getDirections()">
                            <i class="fas fa-directions me-1"></i>
                            Cómo Llegar
                        </button>
                    </div>
                </div>

                <div class="emergency-notice mt-3 p-3 bg-light rounded">
                    <div class="d-flex align-items-start">
                        <i class="fas fa-exclamation-triangle text-warning me-2 mt-1"></i>
                        <div>
                            <strong class="text-warning">Emergencias:</strong>
                            <p class="mb-0 small text-muted">Para emergencias médicas, contacta directamente a la institución.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// Función auxiliar para construir información de contacto del doctor
function buildContactInfo(doctor) {
    const contacts = [];

    if (doctor.email) {
        contacts.push(`
            <div class="contact-item mb-2">
                <i class="fas fa-envelope text-primary me-2"></i>
                <strong>Email:</strong>
                <a href="mailto:${doctor.email}" class="text-decoration-none ms-1">${doctor.email}</a>
            </div>
        `);
    }

    if (doctor.phone) {
        contacts.push(`
            <div class="contact-item mb-2">
                <i class="fas fa-phone text-primary me-2"></i>
                <strong>Teléfono:</strong>
                <a href="tel:${doctor.phone}" class="text-decoration-none ms-1">${doctor.phone}</a>
            </div>
        `);
    }

    if (contacts.length === 0) {
        return '<p class="text-muted small">Información de contacto no disponible</p>';
    }

    return contacts.join('');
}

// Función auxiliar para construir dirección completa
function buildFullAddress(address) {
    if (!address) return null;

    const parts = [];
    if (address.street_address) parts.push(address.street_address);
    if (address.neighborhood) parts.push(address.neighborhood);
    if (address.city) parts.push(address.city);
    if (address.region_id) parts.push(address.region_id); // Podrías mapear a nombre real
    if (address.country_id) parts.push(address.country_id); // Podrías mapear a nombre real
    if (address.postal_code) parts.push(`CP: ${address.postal_code}`);

    return parts.length > 0 ? parts.join(', ') : null;
}

// Función auxiliar para construir información de contacto de la institución
function buildInstitutionContactInfo(institution) {
    const contacts = [];

    if (institution.email) {
        contacts.push(`
            <div class="contact-item mb-2">
                <i class="fas fa-envelope text-success me-2"></i>
                <strong>Email:</strong>
                <a href="mailto:${institution.email}" class="text-decoration-none ms-1">${institution.email}</a>
            </div>
        `);
    }

    if (institution.phone) {
        contacts.push(`
            <div class="contact-item mb-2">
                <i class="fas fa-phone text-success me-2"></i>
                <strong>Teléfono:</strong>
                <a href="tel:${institution.phone}" class="text-decoration-none ms-1">${institution.phone}</a>
            </div>
        `);
    }

    if (institution.website) {
        contacts.push(`
            <div class="contact-item mb-2">
                <i class="fas fa-globe text-success me-2"></i>
                <strong>Sitio Web:</strong>
                <a href="${institution.website}" target="_blank" class="text-decoration-none ms-1">
                    ${institution.website} <i class="fas fa-external-link-alt small"></i>
                </a>
            </div>
        `);
    }

    if (contacts.length === 0) {
        return '<p class="text-muted small">Información de contacto no disponible</p>';
    }

    return contacts.join('');
}

// Funciones de acciones (placeholders para futuras funcionalidades)
function scheduleAppointment() {
    showInfoMessage('Funcionalidad de agendamiento próximamente disponible.');
}

function contactDoctor() {
    const doctorEmail = document.querySelector('#primary-doctor a[href^="mailto:"]');
    if (doctorEmail) {
        window.location.href = doctorEmail.href;
    } else {
        showInfoMessage('Información de contacto del doctor no disponible.');
    }
}

function viewServices() {
    showInfoMessage('Lista de servicios próximamente disponible.');
}

function getDirections() {
    const institutionAddress = document.querySelector('#medical-institution .info-item i.fa-map-marker-alt');
    if (institutionAddress) {
        const addressText = institutionAddress.parentElement.querySelector('.text-muted').textContent;
        const encodedAddress = encodeURIComponent(addressText);
        window.open(`https://www.google.com/maps/search/?api=1&query=${encodedAddress}`, '_blank');
    } else {
        showInfoMessage('Dirección de la institución no disponible.');
    }
}

// Funciones de utilidad para mensajes
function showErrorMessage(message) {
    console.error('Error:', message);

    const notification = document.createElement('div');
    notification.className = 'alert alert-danger alert-dismissible fade show position-fixed';
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    notification.innerHTML = `
        <i class="fas fa-exclamation-triangle me-2"></i>
        <strong>Error:</strong> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

function showInfoMessage(message) {
    console.log('Info:', message);

    const notification = document.createElement('div');
    notification.className = 'alert alert-info alert-dismissible fade show position-fixed';
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    notification.innerHTML = `
        <i class="fas fa-info-circle me-2"></i>
        <strong>Información:</strong> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 3000);
}