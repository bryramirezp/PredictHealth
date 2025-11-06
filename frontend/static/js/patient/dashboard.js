// /frontend/static/js/patient/dashboard.js (REFACTORIZADO)

/**
 * Módulo de lógica de negocio para el Dashboard del Paciente.
 * Este script asume que `patient-core.js` ya ha sido cargado.
 */

document.addEventListener('DOMContentLoaded', async () => {
    // Verificar si estamos en la página del dashboard antes de ejecutar
    if (window.location.pathname.includes('/patient/dashboard')) {
        if (!window.PatientCore) {
            console.error("Error: patient-core.js no está cargado. El dashboard no puede funcionar.");
            return;
        }
        
        const userInfo = await PatientCore.checkAuth();
        if (userInfo) {
            initDashboardPage(userInfo);
        }
    }
});

/**
 * Inicializa la página del dashboard del paciente.
 * Obtiene los datos del endpoint específico del dashboard y los renderiza.
 * @param {object} userInfo - La información del usuario obtenida de la sesión.
 */
async function initDashboardPage(userInfo) {
    console.log("Inicializando Dashboard del Paciente...");

    try {
        // Establecer estados de carga iniciales para los nuevos widgets
        document.getElementById('welcome-title').textContent = 'Cargando...';
        document.getElementById('health-score-value').textContent = '--';
        document.getElementById('imc-value').textContent = '--';
        document.getElementById('imc-classification').textContent = 'Calculando...';
        document.getElementById('quick-summary-box').innerHTML = `
            <div class="d-flex align-items-center text-muted justify-content-center">
                <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                <span>Calculando resumen...</span>
            </div>`;


        // Construir la URL del endpoint usando las constantes de PatientCore
        const patientId = PatientCore.getUserId(userInfo);
        const dashboardUrl = PatientCore.ENDPOINTS.DASHBOARD(patientId);

        // Usar el helper de PatientCore para la llamada API
        const dashboardData = await PatientCore.apiRequest(dashboardUrl);
        
        console.log('Datos del dashboard recibidos:', dashboardData);

        // Renderizar todos los componentes del dashboard
        renderDashboardWidgets(dashboardData);

        console.log('Dashboard del paciente cargado exitosamente.');
    } catch (error) {
        console.error('Error fatal al cargar el dashboard del paciente:', error);
        PatientCore.showErrorMessage(error.message || 'No se pudo cargar la información del dashboard.');
        // Ocultar spinners en caso de error
        document.getElementById('welcome-title').textContent = 'Error al cargar';
        document.getElementById('quick-summary-box').innerHTML = '<p class="text-danger">No se pudo cargar el resumen.</p>';
    }
}

/**
 * Renderiza todos los widgets del dashboard con los datos de la API.
 * @param {object} data - El objeto de datos recibido del endpoint /dashboard.
 */
function renderDashboardWidgets(data) {
    if (!data || !data.patient) {
        PatientCore.showErrorMessage('La respuesta del servidor no contiene datos válidos del paciente.');
        return;
    }

    // 1. Renderizar título de bienvenida
    const welcomeTitleEl = document.getElementById('welcome-title');
    if (welcomeTitleEl) {
        welcomeTitleEl.innerHTML = `Bienvenido, <strong>${data.patient.first_name}</strong>`;
    }

    // 2. Renderizar Resumen Rápido
    renderSummaryBox(data);

    // 3. Renderizar Puntuación de Salud
    const healthScoreEl = document.getElementById('health-score-value');
    if (healthScoreEl) {
        healthScoreEl.textContent = data.health_score ?? '--';
    }

    // 4. Renderizar Tarjeta de IMC
    renderIMCCard(data.bmi, data.bmi_classification);
}

/**
 * Renderiza el cuadro de resumen del paciente.
 * @param {object} data - Los datos completos del dashboard.
 */
function renderSummaryBox(data) {
    const container = document.getElementById('quick-summary-box');
    if (!container) return;

    const { patient, health_score, bmi, age } = data;
    
    // Preparar los strings para el box
    const name = `👤 ${patient.first_name || ''} ${patient.last_name || ''}`.padEnd(20);
    const health = `Salud: ${health_score || '--'}/100 ⭐`;
    const bmiText = `IMC: ${bmi || '--'} (${data.bmi_classification || 'N/A'})`.padEnd(20);
    const ageText = `Edad: ${age || '--'} años`;

    // Usar <pre> para mantener el formato ASCII
    container.innerHTML = `
<pre class="text-start p-3 bg-light rounded" style="font-size: 1.1rem; line-height: 1.6; border: 1px solid #eee;">
┌─────────────────────────────────────┐
│  ${name}${health}  │
│  ${bmiText}${ageText}  │
└─────────────────────────────────────┘
</pre>
    `;
}

/**
 * Renderiza la tarjeta de IMC con su clasificación.
 * @param {number|null} bmi - El valor numérico del IMC.
 * @param {string|null} classification - El texto de clasificación (ej. "Normal ✅").
 */
function renderIMCCard(bmi, classification) {
    const bmiEl = document.getElementById('imc-value');
    const classEl = document.getElementById('imc-classification');

    if (!bmiEl || !classEl) return;

    if (bmi && classification) {
        bmiEl.textContent = bmi;
        classEl.textContent = classification;

        // Asignar color de badge según clasificación
        if (classification.includes('Normal')) {
            classEl.className = 'badge fs-6 bg-success';
        } else if (classification.includes('Bajo peso') || classification.includes('Sobrepeso')) {
            classEl.className = 'badge fs-6 bg-warning text-dark';
        } else if (classification.includes('Obesidad')) {
            classEl.className = 'badge fs-6 bg-danger';
        } else {
            classEl.className = 'badge fs-6 bg-secondary';
        }
    } else {
        bmiEl.textContent = 'N/A';
        classEl.textContent = 'Datos insuficientes';
        classEl.className = 'badge fs-6 bg-light text-dark';
    }
}