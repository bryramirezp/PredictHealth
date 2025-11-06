// /frontend/static/js/doctor-patients.js
// Lógica para la lista de pacientes del doctor (patients.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/doctor/patients')) {
        if (!window.DoctorCore) {
            console.error("Error: doctor-core.js no está cargado.");
            return;
        }
        
        const userInfo = await DoctorCore.checkAuth();
        if (userInfo) {
            initMyPatientsPage(userInfo);
        }
    }
});

/**
 * Inicializa la página de "Mis Pacientes".
 * @param {object} userInfo - La información del usuario (doctor)
 */
async function initMyPatientsPage(userInfo) {
    console.log("Inicializando página de Mis Pacientes...");
    const tableBody = document.querySelector('#patient-list-table tbody');
    if (!tableBody) {
        console.error("No se encontró el <tbody> de la tabla.");
        return;
    }

    try {
        // Mostrar carga
        tableBody.innerHTML = '<tr><td colspan="4">Cargando pacientes...</td></tr>';
        
        // Obtener la lista de pacientes
        const patientListData = await DoctorCore.apiRequest(DoctorCore.ENDPOINTS.MY_PATIENTS());
        
        if (patientListData && patientListData.patients.length > 0) {
            renderPatientTable(tableBody, patientListData.patients);
        } else {
            tableBody.innerHTML = '<tr><td colspan="4" class="text-center">No tiene pacientes asignados actualmente.</td></tr>';
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
function renderPatientTable(tableBody, patients) {
    let html = '';
    
    patients.forEach(patient => {
        html += `
            <tr>
                <td>${patient.first_name} ${patient.last_name}</td>
                <td>${patient.contact_email || 'N/A'}</td>
                <td>${DoctorCore.formatDate(patient.date_of_birth)}</td>
                <td>
                    <a href="/doctor/patient-detail?id=${patient.id}" class="btn btn-sm btn-info">
                        <i class="fas fa-eye me-1"></i>Ver Expediente
                    </a>
                </td>
            </tr>
        `;
    });
    
    tableBody.innerHTML = html;
}