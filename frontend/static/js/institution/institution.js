// /frontend/static/js/institution.js
// Módulo de lógica de negocio para el rol de Institución
// Maneja todas las vistas y funcionalidades específicas de la institución

document.addEventListener('DOMContentLoaded', async () => {
    const Auth = window.AuthManager;
    const API = window.PredictHealthAPI;

    // 1. Proteger todas las páginas de la institución
    const userInfo = await Auth.getUserInfo();
    if (!userInfo || userInfo.user_type !== 'institution') {
        console.warn('Acceso denegado: usuario no es institución');
        return window.location.href = '/';
    }

    // 2. Enrutador simple del lado del cliente
    const path = window.location.pathname;
    console.log('Cargando página de institución:', path);

    if (path.includes('/institution/dashboard')) {
        initDashboardPage(userInfo, API);
    } else if (path.includes('/institution/doctors')) {
        initDoctorsPage(userInfo, API);
    } else if (path.includes('/institution/patients')) {
        initPatientsPage(userInfo, API);
    } else if (path.includes('/institution/profile')) {
        initProfilePage(userInfo, API);
    } else {
        console.warn('Página de institución no reconocida:', path);
    }
});

// Función para la página del dashboard
async function initDashboardPage(userInfo, API) {
    console.log("Inicializando Dashboard de la Institución...");

    try {
        // Obtener datos del dashboard de la institución
        const dashboardData = await API.institutions.getDashboardData();

        // Renderizar widgets del dashboard
        renderDashboardWidgets(dashboardData);

        // Configurar event listeners
        setupDashboardEventListeners();

        console.log('Dashboard de la institución cargado exitosamente');
    } catch (error) {
        console.error('Error cargando dashboard de la institución:', error);
        showErrorMessage('Error al cargar el dashboard');
    }
}

// Función para la página de doctores
async function initDoctorsPage(userInfo, API) {
    console.log("Inicializando Gestión de Doctores de la Institución...");

    try {
        // Obtener lista de doctores de la institución
        const doctorsData = await API.institutions.getDoctors();

        // Renderizar lista de doctores
        renderDoctorsList(doctorsData);

        // Configurar filtros y acciones
        setupDoctorsFilters();
        setupDoctorActions();

        console.log('Gestión de doctores de la institución cargada exitosamente');
    } catch (error) {
        console.error('Error cargando doctores de la institución:', error);
        showErrorMessage('Error al cargar la lista de doctores');
    }
}

// Función para la página de pacientes
async function initPatientsPage(userInfo, API) {
    console.log("Inicializando Gestión de Pacientes de la Institución...");

    try {
        // Obtener lista de pacientes de la institución
        const patientsData = await API.institutions.getPatients();

        // Renderizar lista de pacientes
        renderPatientsList(patientsData);

        // Configurar filtros y estadísticas
        setupPatientsFilters();
        renderPatientStatistics(patientsData);

        console.log('Gestión de pacientes de la institución cargada exitosamente');
    } catch (error) {
        console.error('Error cargando pacientes de la institución:', error);
        showErrorMessage('Error al cargar la lista de pacientes');
    }
}

// Función para la página del perfil
async function initProfilePage(userInfo, API) {
    console.log("Inicializando Perfil de la Institución...");

    try {
        // Obtener datos del perfil de la institución
        const profileData = await API.institutions.getProfile();

        // Renderizar formulario del perfil
        renderProfileForm(profileData);

        // Configurar event listeners para edición
        setupProfileEventListeners();

        console.log('Perfil de la institución cargado exitosamente');
    } catch (error) {
        console.error('Error cargando perfil de la institución:', error);
        showErrorMessage('Error al cargar el perfil');
    }
}

// Funciones de renderizado
function renderDashboardWidgets(data) {
    // Renderizar estadísticas principales
    const statsEl = document.getElementById('institution-stats');
    if (statsEl) {
        statsEl.innerHTML = `
            <div class="stat-card">
                <h4>${data.total_doctors || 0}</h4>
                <p>Doctores Activos</p>
            </div>
            <div class="stat-card">
                <h4>${data.total_patients || 0}</h4>
                <p>Pacientes Registrados</p>
            </div>
            <div class="stat-card">
                <h4>${data.new_patients_this_month || 0}</h4>
                <p>Nuevos Pacientes (Mes)</p>
            </div>
            <div class="stat-card">
                <h4>${data.average_rating || 0}</h4>
                <p>Calificación Promedio</p>
            </div>
        `;
    }

    // Renderizar doctores destacados
    const topDoctorsEl = document.getElementById('top-doctors');
    if (topDoctorsEl && data.top_doctors) {
        renderTopDoctorsList(topDoctorsEl, data.top_doctors);
    }

    // Renderizar alertas recientes
    const alertsEl = document.getElementById('recent-alerts');
    if (alertsEl && data.recent_alerts) {
        renderAlertsList(alertsEl, data.recent_alerts);
    }

    // Renderizar gráfico de crecimiento
    const growthChartEl = document.getElementById('growth-chart');
    if (growthChartEl && data.growth_data) {
        renderGrowthChart(growthChartEl, data.growth_data);
    }
}

function renderDoctorsList(data) {
    const container = document.getElementById('doctors-list');
    if (!container) return;

    if (!data.doctors || data.doctors.length === 0) {
        container.innerHTML = '<p class="no-data">No hay doctores registrados en la institución</p>';
        return;
    }

    const html = data.doctors.map(doctor => `
        <div class="doctor-card" data-doctor-id="${doctor.id}">
            <div class="doctor-header">
                <h4>Dr. ${doctor.first_name} ${doctor.last_name}</h4>
                <span class="doctor-status ${doctor.is_active ? 'active' : 'inactive'}">
                    ${doctor.is_active ? 'Activo' : 'Inactivo'}
                </span>
            </div>
            <div class="doctor-info">
                <p><strong>Especialidad:</strong> ${doctor.specialty || 'No especificada'}</p>
                <p><strong>Años de experiencia:</strong> ${doctor.years_experience || 0}</p>
                <p><strong>Tarifa consulta:</strong> $${doctor.consultation_fee || 0}</p>
                <p><strong>Pacientes activos:</strong> ${doctor.active_patients || 0}</p>
            </div>
            <div class="doctor-actions">
                <button class="btn btn-primary view-doctor" data-doctor-id="${doctor.id}">
                    Ver Perfil
                </button>
                <button class="btn btn-secondary edit-doctor" data-doctor-id="${doctor.id}">
                    Editar
                </button>
                <button class="btn btn-danger ${doctor.is_active ? 'deactivate' : 'activate'}-doctor"
                        data-doctor-id="${doctor.id}">
                    ${doctor.is_active ? 'Desactivar' : 'Activar'}
                </button>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

function renderPatientsList(data) {
    const container = document.getElementById('patients-list');
    if (!container) return;

    if (!data.patients || data.patients.length === 0) {
        container.innerHTML = '<p class="no-data">No hay pacientes registrados en la institución</p>';
        return;
    }

    const html = data.patients.map(patient => `
        <div class="patient-card" data-patient-id="${patient.id}">
            <div class="patient-header">
                <h4>${patient.first_name} ${patient.last_name}</h4>
                <span class="patient-status ${patient.validation_status}">${patient.validation_status}</span>
            </div>
            <div class="patient-info">
                <p><strong>Doctor asignado:</strong> ${patient.doctor_name || 'Sin asignar'}</p>
                <p><strong>Fecha de registro:</strong> ${formatDate(patient.created_at)}</p>
                <p><strong>Riesgo:</strong> <span class="risk-level risk-${patient.risk_level}">${patient.risk_level}</span></p>
                <p><strong>Última actividad:</strong> ${formatDate(patient.last_activity)}</p>
            </div>
            <div class="patient-actions">
                <button class="btn btn-primary view-patient" data-patient-id="${patient.id}">
                    Ver Expediente
                </button>
                <button class="btn btn-secondary assign-doctor" data-patient-id="${patient.id}">
                    Asignar Doctor
                </button>
                <button class="btn btn-info send-notification" data-patient-id="${patient.id}">
                    Notificar
                </button>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

function renderProfileForm(data) {
    // Poblar formulario con datos actuales
    const form = document.getElementById('profile-form');
    if (form) {
        form.name.value = data.name || '';
        form.institution_type.value = data.institution_type || '';
        form.address.value = data.address || '';
        form.phone.value = data.phone || '';
        form.email.value = data.email || '';
        form.website.value = data.website || '';
        form.description.value = data.description || '';
    }
}

function renderPatientStatistics(data) {
    const statsEl = document.getElementById('patient-statistics');
    if (!statsEl) return;

    const totalPatients = data.patients?.length || 0;
    const activePatients = data.patients?.filter(p => p.validation_status === 'full_access').length || 0;
    const pendingValidation = data.patients?.filter(p => p.validation_status === 'pending').length || 0;
    const highRisk = data.patients?.filter(p => p.risk_level === 'high').length || 0;

    statsEl.innerHTML = `
        <div class="stats-grid">
            <div class="stat-item">
                <span class="stat-number">${totalPatients}</span>
                <span class="stat-label">Total Pacientes</span>
            </div>
            <div class="stat-item">
                <span class="stat-number">${activePatients}</span>
                <span class="stat-label">Pacientes Activos</span>
            </div>
            <div class="stat-item">
                <span class="stat-number">${pendingValidation}</span>
                <span class="stat-label">Pendientes Validación</span>
            </div>
            <div class="stat-item">
                <span class="stat-number">${highRisk}</span>
                <span class="stat-label">Alto Riesgo</span>
            </div>
        </div>
    `;
}

// Funciones auxiliares de renderizado
function renderTopDoctorsList(container, doctors) {
    if (!doctors || doctors.length === 0) {
        container.innerHTML = '<p>No hay datos de doctores destacados</p>';
        return;
    }

    const html = doctors.slice(0, 5).map(doctor => `
        <div class="top-doctor">
            <span class="doctor-name">Dr. ${doctor.first_name} ${doctor.last_name}</span>
            <span class="doctor-rating">★ ${doctor.rating || 0}</span>
            <span class="doctor-patients">${doctor.patient_count || 0} pacientes</span>
        </div>
    `).join('');

    container.innerHTML = html;
}

function renderAlertsList(container, alerts) {
    if (!alerts || alerts.length === 0) {
        container.innerHTML = '<p>No hay alertas recientes</p>';
        return;
    }

    const html = alerts.slice(0, 10).map(alert => `
        <div class="alert-item alert-${alert.type}">
            <span class="alert-time">${formatDate(alert.created_at)}</span>
            <span class="alert-message">${alert.message}</span>
            <span class="alert-type">${alert.type}</span>
        </div>
    `).join('');

    container.innerHTML = html;
}

function renderGrowthChart(container, growthData) {
    // Placeholder para gráfico de crecimiento
    // En producción, usar Chart.js o similar
    container.innerHTML = `
        <div class="chart-placeholder">
            <p>Gráfico de crecimiento mensual</p>
            <div class="chart-bars">
                ${growthData.map(month => `
                    <div class="chart-bar" style="height: ${month.growth_percentage * 2}px;">
                        <span class="bar-value">${month.patients}</span>
                        <span class="bar-label">${month.month}</span>
                    </div>
                `).join('')}
            </div>
        </div>
    `;
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

    const exportBtn = document.getElementById('export-data');
    if (exportBtn) {
        exportBtn.addEventListener('click', () => {
            exportInstitutionData();
        });
    }
}

function setupDoctorsFilters() {
    // Configurar filtros de búsqueda para doctores
    const searchInput = document.getElementById('doctor-search');
    const specialtyFilter = document.getElementById('specialty-filter');
    const statusFilter = document.getElementById('status-filter');

    if (searchInput) {
        searchInput.addEventListener('input', debounce(filterDoctors, 300));
    }

    if (specialtyFilter) {
        specialtyFilter.addEventListener('change', filterDoctors);
    }

    if (statusFilter) {
        statusFilter.addEventListener('change', filterDoctors);
    }
}

function setupDoctorActions() {
    // Configurar acciones para doctores
    const addDoctorBtn = document.getElementById('add-doctor');
    if (addDoctorBtn) {
        addDoctorBtn.addEventListener('click', () => {
            showAddDoctorModal();
        });
    }

    // Delegación de eventos para acciones dinámicas
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('view-doctor')) {
            const doctorId = e.target.dataset.doctorId;
            viewDoctorDetails(doctorId);
        } else if (e.target.classList.contains('edit-doctor')) {
            const doctorId = e.target.dataset.doctorId;
            showEditDoctorModal(doctorId);
        } else if (e.target.classList.contains('deactivate-doctor')) {
            const doctorId = e.target.dataset.doctorId;
            deactivateDoctor(doctorId);
        } else if (e.target.classList.contains('activate-doctor')) {
            const doctorId = e.target.dataset.doctorId;
            activateDoctor(doctorId);
        }
    });
}

function setupPatientsFilters() {
    // Configurar filtros de búsqueda para pacientes
    const searchInput = document.getElementById('patient-search');
    const doctorFilter = document.getElementById('doctor-filter');
    const riskFilter = document.getElementById('risk-filter');

    if (searchInput) {
        searchInput.addEventListener('input', debounce(filterPatients, 300));
    }

    if (doctorFilter) {
        doctorFilter.addEventListener('change', filterPatients);
    }

    if (riskFilter) {
        riskFilter.addEventListener('change', filterPatients);
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
                await window.PredictHealthAPI.institutions.updateProfile(profileData);
                showSuccessMessage('Perfil actualizado exitosamente');
            } catch (error) {
                console.error('Error actualizando perfil:', error);
                showErrorMessage('Error al actualizar el perfil');
            }
        });
    }
}

// Funciones de filtrado
function filterDoctors() {
    const searchTerm = document.getElementById('doctor-search')?.value.toLowerCase() || '';
    const specialtyFilter = document.getElementById('specialty-filter')?.value || '';
    const statusFilter = document.getElementById('status-filter')?.value || '';

    const doctorCards = document.querySelectorAll('.doctor-card');

    doctorCards.forEach(card => {
        const name = card.querySelector('h4').textContent.toLowerCase();
        const specialty = card.querySelector('.doctor-info p:first-child').textContent.toLowerCase();
        const status = card.querySelector('.doctor-status').classList[1];

        const matchesSearch = name.includes(searchTerm) || specialty.includes(searchTerm);
        const matchesSpecialty = !specialtyFilter || specialty.includes(specialtyFilter.toLowerCase());
        const matchesStatus = !statusFilter || status === statusFilter;

        card.style.display = matchesSearch && matchesSpecialty && matchesStatus ? 'block' : 'none';
    });
}

function filterPatients() {
    const searchTerm = document.getElementById('patient-search')?.value.toLowerCase() || '';
    const doctorFilter = document.getElementById('doctor-filter')?.value || '';
    const riskFilter = document.getElementById('risk-filter')?.value || '';

    const patientCards = document.querySelectorAll('.patient-card');

    patientCards.forEach(card => {
        const name = card.querySelector('h4').textContent.toLowerCase();
        const doctor = card.querySelector('.patient-info p:first-child').textContent.toLowerCase();
        const riskLevel = card.querySelector('.risk-level').classList[1];

        const matchesSearch = name.includes(searchTerm);
        const matchesDoctor = !doctorFilter || doctor.includes(doctorFilter.toLowerCase());
        const matchesRisk = !riskFilter || riskLevel === riskFilter;

        card.style.display = matchesSearch && matchesDoctor && matchesRisk ? 'block' : 'none';
    });
}

// Funciones de acciones
function showAddDoctorModal() {
    console.log('Mostrar modal para agregar doctor');
    // Implementar modal para agregar doctor
}

function viewDoctorDetails(doctorId) {
    console.log('Ver detalles del doctor:', doctorId);
    // Redirigir a página de detalle del doctor
    window.location.href = `/institution/doctor/${doctorId}`;
}

function showEditDoctorModal(doctorId) {
    console.log('Mostrar modal para editar doctor:', doctorId);
    // Implementar modal para editar doctor
}

async function deactivateDoctor(doctorId) {
    if (confirm('¿Está seguro de que desea desactivar este doctor?')) {
        try {
            await window.PredictHealthAPI.institutions.deactivateDoctor(doctorId);
            showSuccessMessage('Doctor desactivado exitosamente');
            // Recargar la lista
            window.location.reload();
        } catch (error) {
            console.error('Error desactivando doctor:', error);
            showErrorMessage('Error al desactivar el doctor');
        }
    }
}

async function activateDoctor(doctorId) {
    try {
        await window.PredictHealthAPI.institutions.activateDoctor(doctorId);
        showSuccessMessage('Doctor activado exitosamente');
        // Recargar la lista
        window.location.reload();
    } catch (error) {
        console.error('Error activando doctor:', error);
        showErrorMessage('Error al activar el doctor');
    }
}

function exportInstitutionData() {
    console.log('Exportar datos de la institución');
    // Implementar funcionalidad de exportación
}

// Funciones de utilidad
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
window.InstitutionModule = {
    initDashboardPage,
    initDoctorsPage,
    initPatientsPage,
    initProfilePage
};