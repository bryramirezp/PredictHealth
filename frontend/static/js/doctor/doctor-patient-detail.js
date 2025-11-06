// /frontend/static/js/doctor-patient-detail.js
// Lógica para el expediente de un paciente (vista de doctor) (patient-detail.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/doctor/patient-detail')) {
        if (!window.DoctorCore) {
            console.error("Error: doctor-core.js no está cargado.");
            return;
        }
        
        const userInfo = await DoctorCore.checkAuth();
        if (userInfo) {
            initPatientDetailPage();
        }
    }
});

/**
 * Inicializa la página de "Detalle del Paciente".
 */
async function initPatientDetailPage() {
    console.log("Inicializando página de Detalle de Paciente...");
    
    // 1. Obtener el ID del paciente de la URL
    const params = new URLSearchParams(window.location.search);
    const patientId = params.get('id');
    
    if (!patientId) {
        document.getElementById('patient-detail-container').innerHTML = 
            '<h1 class="text-danger">Error: No se proporcionó un ID de paciente.</h1>';
        return;
    }

    try {
        // 2. Cargar datos del expediente
        const recordData = await DoctorCore.apiRequest(
            DoctorCore.ENDPOINTS.PATIENT_MEDICAL_RECORD(patientId)
        );
        
        // 3. Renderizar todos los componentes
        renderPatientHeader(recordData.patient_info);
        renderHealthProfile(recordData.health_profile);
        renderConditions(recordData.conditions);
        renderMedications(recordData.medications);
        renderAllergies(recordData.allergies);
        renderFamilyHistory(recordData.family_history);

    } catch (error) {
        console.error('Error al cargar el expediente del paciente:', error);
        document.getElementById('patient-detail-container').innerHTML = 
            `<h1 class="text-danger">Error al cargar expediente: ${error.message}</h1>`;
    }
}

// --- Funciones de Renderizado ---

function renderPatientHeader(patient) {
    document.getElementById('patient-name-header').textContent = 
        `Expediente de: ${patient.first_name} ${patient.last_name}`;
}

function renderHealthProfile(profile) {
    const container = document.getElementById('health-profile');
    if (!container) return;
    
    if (!profile) {
        container.innerHTML = '<p class="text-muted">No hay perfil de salud registrado.</p>';
        return;
    }
    
    container.innerHTML = `
        <div class="card mt-3">
            <div class="card-body">
                <h5 class="card-title">Perfil de Salud del Paciente</h5>
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Altura:</strong> ${profile.height_cm || 'N/A'} cm</p>
                        <p><strong>Peso:</strong> ${profile.weight_kg || 'N/A'} kg</p>
                        <p><strong>Tipo de sangre:</strong> ${profile.blood_type || 'N/A'}</p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Fumador:</strong> ${profile.is_smoker ? 'Sí' : 'No'}</p>
                        <p><strong>Consume alcohol:</strong> ${profile.consumes_alcohol ? 'Sí' : 'No'}</p>
                        <p><strong>Actividad física:</strong> ${profile.physical_activity_minutes_weekly || 0} min/sem</p>
                    </div>
                </div>
                ${profile.notes ? `<p><strong>Notas del Perfil:</strong> ${profile.notes}</p>` : ''}
                <button class="btn btn-primary mt-2">Editar Perfil</button>
            </div>
        </div>
    `;
}

function renderConditions(conditions) {
    const container = document.getElementById('conditions');
    if (!container) return;

    let html = '<div class="card mt-3"><div class="card-body"><h5 class="card-title">Gestionar Condiciones Médicas</h5>';
    if (!conditions || conditions.length === 0) {
        html += '<p class="text-muted">No hay condiciones médicas registradas.</p>';
    } else {
        html += conditions.map(c => `
            <div class="p-2 border-bottom">
                <strong>${c.name}</strong>
                <div class="text-muted small">Diagnosticado: ${DoctorCore.formatDate(c.diagnosis_date)}</div>
                ${c.notes ? `<div class="text-muted small">Notas: ${c.notes}</div>` : ''}
            </div>
        `).join('');
    }
    html += '<button class="btn btn-success mt-3">Añadir Condición</button></div></div>';
    container.innerHTML = html;
}

function renderMedications(medications) {
    const container = document.getElementById('medications');
    // ... (lógica similar a renderConditions) ...
    container.innerHTML = '<div class="card mt-3"><div class="card-body"><h5 class="card-title">Gestionar Medicamentos</h5><p class="text-muted">Renderizado de medicamentos (Próximamente)...</p></div></div>';
}

function renderAllergies(allergies) {
    const container = document.getElementById('allergies');
    // ... (lógica similar a renderConditions) ...
    container.innerHTML = '<div class="card mt-3"><div class="card-body"><h5 class="card-title">Gestionar Alergias</h5><p class="text-muted">Renderizado de alergias (Próximamente)...</p></div></div>';
}

function renderFamilyHistory(history) {
    const container = document.getElementById('family-history');
    // ... (lógica similar a renderConditions) ...
    container.innerHTML = '<div class="card mt-3"><div class="card-body"><h5 class="card-title">Gestionar Historial Familiar</h5><p class="text-muted">Renderizado de historial (Próximamente)...</p></div></div>';
}