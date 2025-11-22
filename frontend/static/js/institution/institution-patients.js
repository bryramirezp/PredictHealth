// /frontend/static/js/institution/institution-patients.js
// Lógica para la lista de pacientes de la institución (patients.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/institution/patients')) {
        if (!window.InstitutionCore) {
            console.error("Error: institution-core.js no está cargado.");
            return;
        }

        const userInfo = await InstitutionCore.checkAuth();
        if (userInfo) {
            initPatientsPage(userInfo);
        }
    }
});

/**
 * Inicializa la página de "Gestionar Pacientes".
 * @param {object} userInfo - La información del usuario (institución)
 */
async function initPatientsPage(userInfo) {
    console.log("Inicializando página de Gestión de Pacientes...");
    const tableBody = document.querySelector('#patients-list-table tbody');
    if (!tableBody) {
        console.error("No se encontró el <tbody> de la tabla.");
        return;
    }

    try {
        // Mostrar carga
        InstitutionCore.showLoading('patients-list-table-body', 'Cargando pacientes...');

        // Obtener la lista de pacientes
        const patientsData = await InstitutionCore.apiRequest(InstitutionCore.ENDPOINTS.PATIENTS());

        // El backend devuelve {status: "success", data: {patients: [...]}}
        const patients = patientsData?.data?.patients || patientsData?.patients || [];

        if (Array.isArray(patients) && patients.length > 0) {
            renderPatientsTable(tableBody, patients);
        } else {
            tableBody.innerHTML = '<tr><td colspan="4" class="text-center">No hay pacientes registrados en la institución.</td></tr>';
        }

    } catch (error) {
        console.error('Error al cargar la lista de pacientes:', error);
        tableBody.innerHTML = `<tr><td colspan="4" class="text-center text-danger">Error al cargar pacientes: ${error.message}</td></tr>`;
    }
}

/**
 * Renderiza las filas de la tabla de pacientes.
 * @param {HTMLElement} tableBody - El elemento <tbody>
 * @param {Array} patients - La lista de objetos de paciente
 */
function renderPatientsTable(tableBody, patients) {
    let html = '';

    patients.forEach(patient => {
        const fullName = `${patient.first_name || ''} ${patient.last_name || ''}`.trim();
        const email = patient.contact_email || 'N/A';
        const doctorName = patient.doctor_name
            ? `Dr. ${patient.doctor_name}`
            : (patient.doctor_first_name && patient.doctor_last_name
                ? `Dr. ${patient.doctor_first_name} ${patient.doctor_last_name}`
                : 'Sin asignar');

        html += `
            <tr>
                <td>${fullName}</td>
                <td>${email}</td>
                <td>${doctorName}</td>
                <td class="actions-cell">
                    <button type="button" class="btn btn-sm btn-warning" onclick="reassignDoctor('${patient.id}')" title="Reasignar Doctor">
                        <i class="fas fa-exchange-alt me-1"></i>Reasignar Doctor
                    </button>
                </td>
            </tr>
        `;
    });

    tableBody.innerHTML = html;
}

/**
 * Función para reasignar doctor a un paciente (placeholder).
 * @param {string} patientId - ID del paciente
 */
function reassignDoctor(patientId) {
    console.log('Reasignar doctor para paciente:', patientId);
    InstitutionCore.showErrorMessage('Funcionalidad de reasignación pendiente de implementar');
}

