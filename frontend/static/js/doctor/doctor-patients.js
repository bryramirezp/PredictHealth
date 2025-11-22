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
                    <button type="button" class="btn btn-sm btn-info" onclick="showPatientMedicalRecord('${patient.id}')">
                        <i class="fas fa-eye me-1"></i>Ver Expediente
                    </button>
                </td>
            </tr>
        `;
    });
    
    tableBody.innerHTML = html;
}

/**
 * Muestra el expediente médico del paciente en un modal.
 * @param {string} patientId - ID del paciente
 */
async function showPatientMedicalRecord(patientId) {
    const modal = new bootstrap.Modal(document.getElementById('patientMedicalRecordModal'));
    const contentDiv = document.getElementById('medicalRecordContent');
    
    // Mostrar modal con loading
    contentDiv.innerHTML = `
        <div class="text-center">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-2">Cargando expediente médico...</p>
        </div>
    `;
    modal.show();
    
    try {
        const response = await fetch(`/api/web/doctor/patients/${patientId}/medical-record`, {
            method: 'GET',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const result = await response.json();
        
        if (result.status === 'success' && result.data) {
            const data = result.data;
            renderMedicalRecord(contentDiv, data);
        } else {
            contentDiv.innerHTML = `
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    ${result.message || 'Error al cargar el expediente médico'}
                </div>
            `;
        }
    } catch (error) {
        console.error('Error al cargar expediente médico:', error);
        contentDiv.innerHTML = `
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Error al cargar el expediente médico. Por favor, intente nuevamente.
            </div>
        `;
    }
}

/**
 * Renderiza el contenido del expediente médico en el modal.
 * @param {HTMLElement} container - Contenedor donde se renderizará el contenido
 * @param {object} data - Datos del expediente médico
 */
function renderMedicalRecord(container, data) {
    const patientInfo = data.patient_info || {};
    const healthProfile = data.health_profile || {};
    const conditions = data.conditions || [];
    const medications = data.medications || [];
    const allergies = data.allergies || [];
    const familyHistory = data.family_history || [];
    
    let html = `
        <div class="mb-4">
            <h6 class="text-primary mb-3">
                <i class="fas fa-user me-2"></i>Información del Paciente
            </h6>
            <div class="row">
                <div class="col-md-6">
                    <p><strong>Nombre:</strong> ${patientInfo.first_name || ''} ${patientInfo.last_name || ''}</p>
                    <p><strong>Fecha de Nacimiento:</strong> ${DoctorCore.formatDate(patientInfo.date_of_birth) || 'N/A'}</p>
                </div>
                <div class="col-md-6">
                    <p><strong>Email:</strong> ${patientInfo.contact_email || 'N/A'}</p>
                    <p><strong>Teléfono:</strong> ${patientInfo.contact_phone || 'N/A'}</p>
                </div>
            </div>
        </div>
        
        <div class="mb-4">
            <h6 class="text-primary mb-3">
                <i class="fas fa-heartbeat me-2"></i>Perfil de Salud
            </h6>
            ${healthProfile.height_cm || healthProfile.weight_kg || healthProfile.blood_type ? `
                <div class="row">
                    ${healthProfile.height_cm ? `<div class="col-md-4"><p><strong>Estatura:</strong> ${healthProfile.height_cm} cm</p></div>` : ''}
                    ${healthProfile.weight_kg ? `<div class="col-md-4"><p><strong>Peso:</strong> ${healthProfile.weight_kg} kg</p></div>` : ''}
                    ${healthProfile.blood_type ? `<div class="col-md-4"><p><strong>Tipo de Sangre:</strong> ${healthProfile.blood_type}</p></div>` : ''}
                </div>
                <div class="row">
                    ${healthProfile.is_smoker !== null && healthProfile.is_smoker !== undefined ? `<div class="col-md-4"><p><strong>Fumador:</strong> ${healthProfile.is_smoker ? 'Sí' : 'No'}</p></div>` : ''}
                    ${healthProfile.consumes_alcohol !== null && healthProfile.consumes_alcohol !== undefined ? `<div class="col-md-4"><p><strong>Consume Alcohol:</strong> ${healthProfile.consumes_alcohol ? 'Sí' : 'No'}</p></div>` : ''}
                    ${healthProfile.physical_activity_minutes_weekly ? `<div class="col-md-4"><p><strong>Actividad Física:</strong> ${healthProfile.physical_activity_minutes_weekly} min/semana</p></div>` : ''}
                </div>
                ${healthProfile.notes ? `<div class="mt-2"><p><strong>Notas:</strong> ${healthProfile.notes}</p></div>` : ''}
            ` : '<p class="text-muted">No hay información de perfil de salud disponible.</p>'}
        </div>
        
        <div class="mb-4">
            <h6 class="text-primary mb-3">
                <i class="fas fa-stethoscope me-2"></i>Condiciones Médicas
            </h6>
            ${conditions.length > 0 ? `
                <div class="table-responsive">
                    <table class="table table-sm table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>Condición</th>
                                <th>Fecha de Diagnóstico</th>
                                <th>Notas</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${conditions.map(cond => `
                                <tr>
                                    <td>${cond.name || 'N/A'}</td>
                                    <td>${cond.diagnosis_date ? DoctorCore.formatDate(cond.diagnosis_date) : 'N/A'}</td>
                                    <td>${cond.notes || '-'}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : '<p class="text-muted">No hay condiciones médicas registradas.</p>'}
        </div>
        
        <div class="mb-4">
            <h6 class="text-primary mb-3">
                <i class="fas fa-pills me-2"></i>Medicamentos
            </h6>
            ${medications.length > 0 ? `
                <div class="table-responsive">
                    <table class="table table-sm table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>Medicamento</th>
                                <th>Dosis</th>
                                <th>Frecuencia</th>
                                <th>Fecha de Inicio</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${medications.map(med => `
                                <tr>
                                    <td>${med.name || 'N/A'}</td>
                                    <td>${med.dosage || '-'}</td>
                                    <td>${med.frequency || '-'}</td>
                                    <td>${med.start_date ? DoctorCore.formatDate(med.start_date) : 'N/A'}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : '<p class="text-muted">No hay medicamentos registrados.</p>'}
        </div>
        
        <div class="mb-4">
            <h6 class="text-primary mb-3">
                <i class="fas fa-exclamation-triangle me-2"></i>Alergias
            </h6>
            ${allergies.length > 0 ? `
                <div class="table-responsive">
                    <table class="table table-sm table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>Alergia</th>
                                <th>Severidad</th>
                                <th>Descripción de Reacción</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${allergies.map(allergy => `
                                <tr>
                                    <td>${allergy.name || 'N/A'}</td>
                                    <td>${allergy.severity || '-'}</td>
                                    <td>${allergy.reaction_description || '-'}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : '<p class="text-muted">No hay alergias registradas.</p>'}
        </div>
        
        <div class="mb-4">
            <h6 class="text-primary mb-3">
                <i class="fas fa-users me-2"></i>Historial Familiar
            </h6>
            ${familyHistory.length > 0 ? `
                <div class="table-responsive">
                    <table class="table table-sm table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>Condición</th>
                                <th>Parentesco</th>
                                <th>Notas</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${familyHistory.map(history => `
                                <tr>
                                    <td>${history.condition_name || 'N/A'}</td>
                                    <td>${history.relative_type || '-'}</td>
                                    <td>${history.notes || '-'}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : '<p class="text-muted">No hay historial familiar registrado.</p>'}
        </div>
    `;
    
    container.innerHTML = html;
}