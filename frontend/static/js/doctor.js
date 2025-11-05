// /frontend/static/js/doctor.js
// Módulo de lógica de negocio para el rol de Doctor
// Maneja todas las vistas y funcionalidades específicas del doctor

document.addEventListener('DOMContentLoaded', async () => {
    const Auth = window.AuthManager;
    const API = window.PredictHealthAPI;

    // 1. Proteger todas las páginas del doctor
    const userInfo = await Auth.getUserInfo();
    if (!userInfo || userInfo.user_type !== 'doctor') {
        console.warn('Acceso denegado: usuario no es doctor');
        return window.location.href = '/';
    }

    // 2. Enrutador simple del lado del cliente
    const path = window.location.pathname;
    console.log('Cargando página del doctor:', path);

    if (path.includes('/doctor/dashboard')) {
        initDashboardPage(userInfo, API);
    } else if (path.includes('/doctor/patients')) {
        initPatientsPage(userInfo, API);
    } else if (path.includes('/doctor/patient-detail/')) {
        const patientId = path.split('/').pop();
        initPatientDetailPage(userInfo, API, patientId);
    } else if (path.includes('/doctor/my-institution')) {
        initInstitutionPage(userInfo, API);
    } else if (path.includes('/doctor/profile')) {
        initProfilePage(userInfo, API);
    } else {
        console.warn('Página del doctor no reconocida:', path);
    }
});

// Función para la página del dashboard
async function initDashboardPage(userInfo, API) {
    console.log("Inicializando Dashboard del Doctor...");

    try {
        // Obtener datos del dashboard del doctor
        const dashboardData = await API.doctors.getDashboardData();

        // Renderizar widgets del dashboard
        renderDashboardWidgets(dashboardData);

        // Configurar event listeners
        setupDashboardEventListeners();

        console.log('Dashboard del doctor cargado exitosamente');
    } catch (error) {
        console.error('Error cargando dashboard del doctor:', error);
        showErrorMessage('Error al cargar el dashboard');
    }
}

// Función para la página de pacientes
async function initPatientsPage(userInfo, API) {
    console.log("Inicializando Lista de Pacientes del Doctor...");

    try {
        // Obtener lista de pacientes del doctor
        const patientsData = await API.doctors.getMyPatients();

        // Renderizar lista de pacientes
        renderPatientsList(patientsData);

        // Configurar filtros y búsqueda
        setupPatientsFilters();

        console.log('Lista de pacientes del doctor cargada exitosamente');
    } catch (error) {
        console.error('Error cargando pacientes del doctor:', error);
        showErrorMessage('Error al cargar la lista de pacientes');
    }
}

// Función para la página de detalle de paciente
async function initPatientDetailPage(userInfo, API, patientId) {
    console.log(`Inicializando Detalle del Paciente ${patientId}...`);

    try {
        // Obtener datos detallados del paciente
        const patientData = await API.doctors.getPatientDetails(patientId);

        // Renderizar información completa del paciente
        renderPatientDetail(patientData);

        // Configurar acciones médicas
        setupPatientActions(patientId);

        console.log(`Detalle del paciente ${patientId} cargado exitosamente`);
    } catch (error) {
        console.error('Error cargando detalle del paciente:', error);
        showErrorMessage('Error al cargar los detalles del paciente');
    }
}

// Función para la página de institución
async function initInstitutionPage(userInfo, API) {
    console.log("Inicializando Página de Institución del Doctor...");

    try {
        // Obtener datos de la institución del doctor
        const institutionData = await API.doctors.getInstitution();

        // Renderizar información de la institución
        renderInstitutionInfo(institutionData);

        console.log('Información de institución del doctor cargada exitosamente');
    } catch (error) {
        console.error('Error cargando institución del doctor:', error);
        showErrorMessage('Error al cargar la información de la institución');
    }
}

// Función para la página del perfil
async function initProfilePage(userInfo, API) {
    console.log("Inicializando Perfil del Doctor...");

    try {
        // Obtener datos del perfil del doctor
        const profileData = await API.doctors.getProfile();

        // Renderizar formulario del perfil
        renderProfileForm(profileData);

        // Configurar event listeners para edición
        setupProfileEventListeners();

        console.log('Perfil del doctor cargado exitosamente');
    } catch (error) {
        console.error('Error cargando perfil del doctor:', error);
        showErrorMessage('Error al cargar el perfil');
    }
}

// Funciones de renderizado
function renderDashboardWidgets(data) {
    // Renderizar estadísticas del doctor
    const statsEl = document.getElementById('doctor-stats');
    if (statsEl) {
        statsEl.innerHTML = `
            <div class="stat-card">
                <h4>${data.total_patients || 0}</h4>
                <p>Pacientes Activos</p>
            </div>
            <div class="stat-card">
                <h4>${data.today_appointments || 0}</h4>
                <p>Citas Hoy</p>
            </div>
            <div class="stat-card">
                <h4>${data.pending_reviews || 0}</h4>
                <p>Revisiones Pendientes</p>
            </div>
        `;
    }

    // Renderizar próximas citas
    const appointmentsEl = document.getElementById('upcoming-appointments');
    if (appointmentsEl && data.appointments) {
        renderAppointmentsList(appointmentsEl, data.appointments);
    }

    // Renderizar pacientes recientes
    const recentPatientsEl = document.getElementById('recent-patients');
    if (recentPatientsEl && data.recent_patients) {
        renderRecentPatientsList(recentPatientsEl, data.recent_patients);
    }
}

function renderPatientsList(data) {
    const container = document.getElementById('patients-list');
    if (!container) return;

    if (!data.patients || data.patients.length === 0) {
        container.innerHTML = '<p class="no-data">No hay pacientes asignados</p>';
        return;
    }

    const html = data.patients.map(patient => `
        <div class="patient-card" data-patient-id="${patient.id}">
            <div class="patient-header">
                <h4>${patient.first_name} ${patient.last_name}</h4>
                <span class="patient-status ${patient.status}">${patient.status}</span>
            </div>
            <div class="patient-info">
                <p><strong>Edad:</strong> ${calculateAge(patient.date_of_birth)} años</p>
                <p><strong>Última visita:</strong> ${formatDate(patient.last_visit)}</p>
                <p><strong>Condición principal:</strong> ${patient.main_condition || 'No especificada'}</p>
            </div>
            <div class="patient-actions">
                <button class="btn btn-primary view-detail" data-patient-id="${patient.id}">
                    Ver Detalle
                </button>
                <button class="btn btn-secondary schedule-appointment" data-patient-id="${patient.id}">
                    Agendar Cita
                </button>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

function renderPatientDetail(data) {
    // Renderizar información básica
    const basicInfoEl = document.getElementById('patient-basic-info');
    if (basicInfoEl) {
        basicInfoEl.innerHTML = `
            <h3>${data.first_name} ${data.last_name}</h3>
            <p><strong>Fecha de nacimiento:</strong> ${formatDate(data.date_of_birth)}</p>
            <p><strong>Edad:</strong> ${calculateAge(data.date_of_birth)} años</p>
            <p><strong>Email:</strong> ${data.email}</p>
            <p><strong>Teléfono:</strong> ${data.phone || 'No especificado'}</p>
        `;
    }

    // Renderizar historial médico
    const medicalHistoryEl = document.getElementById('medical-history');
    if (medicalHistoryEl && data.medical_history) {
        renderMedicalHistory(medicalHistoryEl, data.medical_history);
    }

    // Renderizar condiciones actuales
    const conditionsEl = document.getElementById('current-conditions');
    if (conditionsEl && data.conditions) {
        renderConditionsList(conditionsEl, data.conditions);
    }

    // Renderizar medicamentos
    const medicationsEl = document.getElementById('current-medications');
    if (medicationsEl && data.medications) {
        renderMedicationsList(medicationsEl, data.medications);
    }

    // Renderizar próximas citas
    const appointmentsEl = document.getElementById('patient-appointments');
    if (appointmentsEl && data.appointments) {
        renderAppointmentsList(appointmentsEl, data.appointments);
    }
}

function renderInstitutionInfo(data) {
    const container = document.getElementById('institution-info');
    if (!container) return;

    container.innerHTML = `
        <div class="institution-card">
            <h3>${data.name}</h3>
            <p><strong>Tipo:</strong> ${data.institution_type}</p>
            <p><strong>Dirección:</strong> ${data.address}</p>
            <p><strong>Teléfono:</strong> ${data.phone}</p>
            <p><strong>Email:</strong> ${data.email}</p>
            <div class="institution-stats">
                <span>Total Doctores: ${data.total_doctors || 0}</span>
                <span>Total Pacientes: ${data.total_patients || 0}</span>
            </div>
        </div>
    `;
}

function renderProfileForm(data) {
    // Poblar formulario con datos actuales
    const form = document.getElementById('profile-form');
    if (form) {
        form.first_name.value = data.first_name || '';
        form.last_name.value = data.last_name || '';
        form.email.value = data.email || '';
        form.phone.value = data.phone || '';
        form.specialty.value = data.specialty || '';
        form.license_number.value = data.license_number || '';
        form.years_experience.value = data.years_experience || '';
        form.consultation_fee.value = data.consultation_fee || '';
    }
}

// Funciones auxiliares de renderizado
function renderMedicalHistory(container, history) {
    if (!history || history.length === 0) {
        container.innerHTML = '<p>No hay historial médico registrado</p>';
        return;
    }

    const html = history.map(entry => `
        <div class="history-entry">
            <div class="entry-date">${formatDate(entry.date)}</div>
            <div class="entry-type">${entry.type}</div>
            <div class="entry-description">${entry.description}</div>
            <div class="entry-doctor">Dr. ${entry.doctor_name}</div>
        </div>
    `).join('');

    container.innerHTML = html;
}

function renderRecentPatientsList(container, patients) {
    if (!patients || patients.length === 0) {
        container.innerHTML = '<p>No hay pacientes recientes</p>';
        return;
    }

    const html = patients.slice(0, 5).map(patient => `
        <div class="recent-patient">
            <span class="patient-name">${patient.first_name} ${patient.last_name}</span>
            <span class="last-visit">${formatDate(patient.last_visit)}</span>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Funciones de configuración de eventos
function setupDashboardEventListeners() {
    // Event listeners específicos del dashboard
    const refreshBtn = document.getElementById('refresh-dashboard');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', () => {
            window.location.reload();
        });
    }
}

function setupPatientsFilters() {
    // Configurar filtros de búsqueda
    const searchInput = document.getElementById('patient-search');
    const statusFilter = document.getElementById('status-filter');

    if (searchInput) {
        searchInput.addEventListener('input', debounce(filterPatients, 300));
    }

    if (statusFilter) {
        statusFilter.addEventListener('change', filterPatients);
    }
}

function setupPatientActions(patientId) {
    // Configurar acciones para el paciente específico
    const addConditionBtn = document.getElementById('add-condition');
    const scheduleAppointmentBtn = document.getElementById('schedule-appointment');
    const updateRecordBtn = document.getElementById('update-record');

    if (addConditionBtn) {
        addConditionBtn.addEventListener('click', () => {
            showAddConditionModal(patientId);
        });
    }

    if (scheduleAppointmentBtn) {
        scheduleAppointmentBtn.addEventListener('click', () => {
            showScheduleAppointmentModal(patientId);
        });
    }

    if (updateRecordBtn) {
        updateRecordBtn.addEventListener('click', () => {
            showUpdateRecordModal(patientId);
        });
    }
}

function setupProfileEventListeners() {
    // Event listeners para el formulario de perfil
    const form = document.getElementById('profile-form');
    if (form) {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();

            const formData = new FormData(form);
            const profileData = Object.fromEntries(formData);

            try {
                await window.PredictHealthAPI.doctors.updateProfile(profileData);
                showSuccessMessage('Perfil actualizado exitosamente');
            } catch (error) {
                console.error('Error actualizando perfil:', error);
                showErrorMessage('Error al actualizar el perfil');
            }
        });
    }
}

// Funciones de filtrado
function filterPatients() {
    const searchTerm = document.getElementById('patient-search')?.value.toLowerCase() || '';
    const statusFilter = document.getElementById('status-filter')?.value || '';

    const patientCards = document.querySelectorAll('.patient-card');

    patientCards.forEach(card => {
        const name = card.querySelector('h4').textContent.toLowerCase();
        const status = card.querySelector('.patient-status').classList[1];

        const matchesSearch = name.includes(searchTerm);
        const matchesStatus = !statusFilter || status === statusFilter;

        card.style.display = matchesSearch && matchesStatus ? 'block' : 'none';
    });
}

// Funciones modales (placeholders)
function showAddConditionModal(patientId) {
    console.log('Mostrar modal para agregar condición al paciente:', patientId);
    // Implementar modal para agregar condición médica
}

function showScheduleAppointmentModal(patientId) {
    console.log('Mostrar modal para agendar cita con paciente:', patientId);
    // Implementar modal para agendar cita
}

function showUpdateRecordModal(patientId) {
    console.log('Mostrar modal para actualizar expediente del paciente:', patientId);
    // Implementar modal para actualizar expediente
}

// Funciones de utilidad
function calculateAge(birthDate) {
    if (!birthDate) return 'N/A';
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();

    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
        age--;
    }

    return age;
}

function formatDate(dateString) {
    if (!dateString) return 'Fecha no disponible';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function showErrorMessage(message) {
    console.error(message);
    alert(message); // Temporal
}

function showSuccessMessage(message) {
    console.log(message);
    alert(message); // Temporal
}

// Exponer funciones globales si es necesario
window.DoctorModule = {
    initDashboardPage,
    initPatientsPage,
    initPatientDetailPage,
    initInstitutionPage,
    initProfilePage
};