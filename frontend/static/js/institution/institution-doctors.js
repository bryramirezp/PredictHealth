// /frontend/static/js/institution/institution-doctors.js
// Lógica para la lista de doctores de la institución (doctors.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/institution/doctors')) {
        if (!window.InstitutionCore) {
            console.error("Error: institution-core.js no está cargado.");
            return;
        }
        
        const userInfo = await InstitutionCore.checkAuth();
        if (userInfo) {
            initDoctorsPage(userInfo);
        }
    }
});

/**
 * Inicializa la página de "Gestionar Doctores".
 * @param {object} userInfo - La información del usuario (institución)
 */
async function initDoctorsPage(userInfo) {
    console.log("Inicializando página de Gestión de Doctores...");
    const tableBody = document.querySelector('#doctors-list-table tbody');
    if (!tableBody) {
        console.error("No se encontró el <tbody> de la tabla.");
        return;
    }

    try {
        // Mostrar carga
        InstitutionCore.showLoading('doctors-list-table-body', 'Cargando doctores...');
        
        // Obtener la lista de doctores
        const doctorsData = await InstitutionCore.apiRequest(InstitutionCore.ENDPOINTS.DOCTORS());
        
        // El backend puede devolver directamente {doctors: [...]} o el array directamente
        const doctors = doctorsData?.doctors || doctorsData || [];
        
        if (Array.isArray(doctors) && doctors.length > 0) {
            renderDoctorsTable(tableBody, doctors);
        } else {
            tableBody.innerHTML = '<tr><td colspan="5" class="text-center">No hay doctores registrados en la institución.</td></tr>';
        }

    } catch (error) {
        console.error('Error al cargar la lista de doctores:', error);
        tableBody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">Error al cargar doctores: ${error.message}</td></tr>`;
    }
}

/**
 * Renderiza las filas de la tabla de doctores.
 * @param {HTMLElement} tableBody - El elemento <tbody>
 * @param {Array} doctors - La lista de objetos de doctor
 */
function renderDoctorsTable(tableBody, doctors) {
    let html = '';
    
    doctors.forEach(doctor => {
        const fullName = `Dr. ${doctor.first_name || ''} ${doctor.last_name || ''}`.trim();
        const specialty = doctor.specialty || doctor.specialty_name || 'No especificada';
        const email = doctor.contact_email || 'N/A';
        const statusBadge = doctor.is_active 
            ? '<span class="badge bg-success">Activo</span>'
            : '<span class="badge bg-secondary">Inactivo</span>';
        
        html += `
            <tr>
                <td>${fullName}</td>
                <td>${specialty}</td>
                <td>${email}</td>
                <td>${statusBadge}</td>
                <td class="actions-cell">
                    <button type="button" class="btn btn-sm btn-warning" onclick="editDoctor('${doctor.id}')" title="Editar">
                        <i class="fas fa-edit"></i>
                    </button>
                    ${doctor.is_active 
                        ? `<button type="button" class="btn btn-sm btn-danger deactivate-doctor" data-doctor-id="${doctor.id}" title="Desactivar">
                            <i class="fas fa-trash-alt"></i>
                           </button>`
                        : `<button type="button" class="btn btn-sm btn-success activate-doctor" data-doctor-id="${doctor.id}" title="Activar">
                            <i class="fas fa-check"></i>
                           </button>`
                    }
                </td>
            </tr>
        `;
    });
    
    tableBody.innerHTML = html;
    
    // Configurar event listeners para botones de activar/desactivar
    setupDoctorActionListeners();
}

/**
 * Configura los event listeners para los botones de acción de doctores.
 */
function setupDoctorActionListeners() {
    // Botones de desactivar
    document.querySelectorAll('.deactivate-doctor').forEach(button => {
        button.addEventListener('click', async (e) => {
            const doctorId = e.currentTarget.getAttribute('data-doctor-id');
            if (confirm('¿Está seguro de que desea desactivar este doctor?')) {
                await deleteDoctor(doctorId);
            }
        });
    });
    
    // Botones de activar
    document.querySelectorAll('.activate-doctor').forEach(button => {
        button.addEventListener('click', async (e) => {
            const doctorId = e.currentTarget.getAttribute('data-doctor-id');
            if (confirm('¿Está seguro de que desea activar este doctor?')) {
                await activateDoctor(doctorId);
            }
        });
    });
}

/**
 * Elimina (desactiva) un doctor.
 * @param {string} doctorId - ID del doctor
 */
async function deleteDoctor(doctorId) {
    try {
        await InstitutionCore.apiRequest(InstitutionCore.ENDPOINTS.DELETE_DOCTOR(doctorId), {
            method: 'DELETE'
        });
        
        InstitutionCore.showSuccessMessage('Doctor desactivado exitosamente');
        
        // Recargar la lista
        const userInfo = await InstitutionCore.getCurrentUserInfo();
        if (userInfo) {
            await initDoctorsPage(userInfo);
        }
    } catch (error) {
        console.error('Error al desactivar doctor:', error);
        InstitutionCore.showErrorMessage('Error al desactivar doctor: ' + error.message);
    }
}

/**
 * Activa un doctor.
 * @param {string} doctorId - ID del doctor
 */
async function activateDoctor(doctorId) {
    try {
        // TODO: Implementar endpoint de activación si existe
        // Por ahora, mostrar mensaje
        InstitutionCore.showErrorMessage('Funcionalidad de activación pendiente de implementar');
    } catch (error) {
        console.error('Error al activar doctor:', error);
        InstitutionCore.showErrorMessage('Error al activar doctor: ' + error.message);
    }
}

/**
 * Función para editar un doctor (placeholder).
 * @param {string} doctorId - ID del doctor
 */
function editDoctor(doctorId) {
    console.log('Editar doctor:', doctorId);
    InstitutionCore.showErrorMessage('Funcionalidad de edición pendiente de implementar');
}

