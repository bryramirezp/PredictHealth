// /frontend/static/js/institution/institution-dashboard.js
// Lógica para el dashboard de la institución (dashboard.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/institution/dashboard')) {
        if (!window.InstitutionCore) {
            console.error("Error: institution-core.js no está cargado.");
            return;
        }
        
        const userInfo = await InstitutionCore.checkAuth();
        if (userInfo) {
            initDashboardPage(userInfo);
        }
    }
});

/**
 * Inicializa la página del dashboard.
 * @param {object} userInfo - La información del usuario (institución)
 */
async function initDashboardPage(userInfo) {
    console.log("Inicializando Dashboard de la Institución...");

    try {
        // Obtener datos del dashboard de la institución
        const dashboardData = await InstitutionCore.apiRequest(InstitutionCore.ENDPOINTS.DASHBOARD());

        // Renderizar widgets del dashboard
        renderDashboardWidgets(dashboardData);

        // Configurar event listeners
        setupDashboardEventListeners();

        console.log('Dashboard de la institución cargado exitosamente');
    } catch (error) {
        console.error('Error cargando dashboard de la institución:', error);
        InstitutionCore.showErrorMessage('Error al cargar el dashboard');
    }
}

/**
 * Renderiza los widgets del dashboard.
 * @param {object} data - Datos del dashboard
 */
function renderDashboardWidgets(data) {
    // Renderizar estadísticas principales
    const totalDoctorsEl = document.getElementById('total-doctors');
    const totalPatientsEl = document.getElementById('total-patients');
    const newPatientsEl = document.getElementById('new-patients-month');
    
    if (totalDoctorsEl) {
        totalDoctorsEl.textContent = data.total_doctors || data.doctors?.length || 0;
    }
    if (totalPatientsEl) {
        totalPatientsEl.textContent = data.total_patients || data.patients?.length || 0;
    }
    if (newPatientsEl) {
        newPatientsEl.textContent = data.new_patients_this_month || 0;
    }

    // Renderizar doctores destacados si existe el contenedor
    const topDoctorsEl = document.getElementById('top-doctors-list');
    if (topDoctorsEl && data.top_doctors) {
        renderTopDoctorsList(topDoctorsEl, data.top_doctors);
    } else if (topDoctorsEl && data.doctors) {
        renderTopDoctorsList(topDoctorsEl, data.doctors.slice(0, 5));
    } else if (topDoctorsEl) {
        topDoctorsEl.innerHTML = '<p class="text-muted">No hay doctores destacados.</p>';
    }
}

/**
 * Renderiza la lista de doctores destacados.
 * @param {HTMLElement} container - Contenedor donde se renderizará
 * @param {Array} doctors - Lista de doctores
 */
function renderTopDoctorsList(container, doctors) {
    if (!doctors || doctors.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay doctores destacados.</p>';
        return;
    }

    let html = '';
    doctors.slice(0, 5).forEach(doctor => {
        html += `
            <div class="d-flex justify-content-between align-items-center mb-2">
                <div>
                    <strong>Dr. ${doctor.first_name || ''} ${doctor.last_name || ''}</strong>
                    <br><small class="text-muted">${doctor.specialty || 'Sin especialidad'}</small>
                </div>
                <span class="badge bg-primary">${doctor.active_patients || 0} pacientes</span>
            </div>
        `;
    });
    
    container.innerHTML = html;
}

/**
 * Configura los event listeners del dashboard.
 */
function setupDashboardEventListeners() {
    // Botón de refrescar
    const refreshBtn = document.getElementById('refresh-dashboard');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', async () => {
            const userInfo = await InstitutionCore.getCurrentUserInfo();
            if (userInfo) {
                await initDashboardPage(userInfo);
            }
        });
    }

    // Botón de agregar doctor
    const addDoctorBtn = document.getElementById('add-doctor');
    if (addDoctorBtn) {
        addDoctorBtn.addEventListener('click', () => {
            console.log('Agregar nuevo doctor');
            InstitutionCore.showErrorMessage('Funcionalidad de agregar doctor pendiente de implementar');
        });
    }
}

