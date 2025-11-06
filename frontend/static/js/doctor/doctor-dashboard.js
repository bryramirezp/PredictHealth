// /frontend/static/js/doctor-dashboard.js
// Lógica para el dashboard del doctor (dashboard.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/doctor/dashboard')) {
        if (!window.DoctorCore) {
            console.error("Error: doctor-core.js no está cargado.");
            return;
        }
        
        const userInfo = await DoctorCore.checkAuth();
        if (userInfo) {
            initDoctorDashboard(userInfo);
        }
    }
});

/**
 * Inicializa la página del dashboard del doctor.
 * @param {object} userInfo - La información del usuario (doctor)
 */
async function initDoctorDashboard(userInfo) {
    console.log("Inicializando Dashboard del Doctor...");

    try {
        // Cargar el nombre del doctor en el saludo
        document.getElementById('welcome-title').innerHTML = `Bienvenido, <strong>Dr. ${userInfo.first_name || userInfo.email}</strong>`;

        // Cargar los KPIs
        const kpiData = await DoctorCore.apiRequest(DoctorCore.ENDPOINTS.DASHBOARD());
        
        if (kpiData) {
            document.getElementById('total-patients').textContent = kpiData.total_patients;
            document.getElementById('today-appointments').textContent = kpiData.today_appointments;
            document.getElementById('pending-reviews').textContent = kpiData.pending_reviews;
            document.getElementById('available-hours').textContent = 'N/A'; // Placeholder
        }

        // Cargar listas (placeholders)
        document.getElementById('upcoming-appointments').innerHTML = '<p class="text-muted">No hay citas próximas.</p>'; // TODO
        document.getElementById('recent-patients').innerHTML = '<p class="text-muted">No hay pacientes recientes.</p>'; // TODO

        // Event listener para el botón de actualizar
        document.getElementById('refresh-dashboard').addEventListener('click', () => initDoctorDashboard(userInfo));

    } catch (error) {
        console.error('Error fatal al cargar el dashboard del doctor:', error);
        DoctorCore.showErrorMessage(error.message || 'No se pudo cargar el dashboard.');
    }
}