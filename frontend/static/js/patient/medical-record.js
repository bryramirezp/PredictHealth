// /frontend/static/js/medical-record.js
// Módulo específico para la gestión del expediente médico del paciente
// Maneja formularios modales, validaciones y llamadas API para el expediente médico

document.addEventListener('DOMContentLoaded', async () => {
    // Verificar si estamos en la página de expediente médico antes de ejecutar
    if (window.location.pathname.includes('/patient/medical-record')) {
        // PatientCore se encargará de la autenticación y proporcionará las utilidades
        if (!window.PatientCore) {
            console.error("Error: patient-core.js no está cargado. El expediente médico no puede funcionar.");
            return;
        }
        
        const userInfo = await PatientCore.checkAuth();
        if (userInfo) {
            initMedicalRecordPage(userInfo);
        }
    }
});

// Función principal de inicialización
async function initMedicalRecordPage(userInfo) {
    console.log("Inicializando expediente médico con formularios dinámicos...");

    try {
        const patientId = PatientCore.getUserId(userInfo);
        if (!patientId) {
            throw new Error("No se pudo obtener el ID del paciente.");
        }

        // --- INICIO DE LA CORRECCIÓN ---
        // El endpoint /api/v1/patients/{id} tiene el 'health_profile' correcto.
        // El endpoint /medical-record tiene las listas (condiciones, alergias, etc.).
        // Llamaremos a ambos en paralelo y combinaremos los datos.

        // 1. Definir los endpoints a llamar
        // (Asumimos que la ruta base /api/v1/patients/{id} está en tu proxy, 
        // basado en los logs de api-client.js)
        const generalPatientEndpoint = `/api/v1/patients/${patientId}`; 
        const medicalRecordEndpoint = PatientCore.ENDPOINTS.MEDICAL_RECORD(patientId);

        // 2. Realizar ambas llamadas en paralelo
        const [patientData, recordData] = await Promise.all([
            PatientCore.apiRequest(generalPatientEndpoint),
            PatientCore.apiRequest(medicalRecordEndpoint)
        ]);

        // 3. Renderizar cada sección con los datos de la fuente correcta
        renderHealthProfile(patientData.health_profile); // <-- Usamos patientData para el perfil
        renderConditions(recordData.conditions);       // <-- Usamos recordData para el resto
        renderMedications(recordData.medications);   
        renderAllergies(recordData.allergies);       
        renderFamilyHistory(recordData.family_history);
        // --- FIN DE LA CORRECCIÓN ---

        // Configurar event listeners para formularios
        setupMedicalRecordFormListeners();

        console.log('Expediente médico con formularios dinámicos inicializado correctamente');
    } catch (error) {
        console.error('Error inicializando expediente médico:', error);
        PatientCore.showErrorMessage('Error al cargar el expediente médico. Por favor, intenta recargar la página.');
    }
}

// Renderizar perfil de salud
function renderHealthProfile(healthProfile) {
    const container = document.getElementById('health-profile-content');
    if (!container) return;

    if (!healthProfile) {
        container.innerHTML = '<p class="text-muted">No hay información de perfil de salud disponible</p>';
        return;
    }

    // Poblar el formulario del modal con datos existentes
    populateHealthProfileForm(healthProfile);

    // Mostrar datos en la vista
    container.innerHTML = `
        <div class="row">
            <div class="col-md-6">
                <p><strong>Altura:</strong> ${healthProfile.height_cm || 'No especificada'} cm</p>
                <p><strong>Peso:</strong> ${healthProfile.weight_kg || 'No especificado'} kg</p>
                <p><strong>Tipo de sangre:</strong> ${healthProfile.blood_type || 'No especificado'}</p>
            </div>
            <div class="col-md-6">
                <p><strong>Fumador:</strong> ${healthProfile.is_smoker ? 'Sí' : 'No'}</p>
                <p><strong>Consume alcohol:</strong> ${healthProfile.consumes_alcohol ? 'Sí' : 'No'}</p>
                <p><strong>Actividad física semanal:</strong> ${healthProfile.physical_activity_minutes_weekly || 0} minutos</p>
            </div>
        </div>
        ${healthProfile.notes ? `<p><strong>Notas:</strong> ${healthProfile.notes}</p>` : ''}
    `;
}

// Renderizar condiciones médicas
function renderConditions(conditions) {
    const container = document.getElementById('conditions-content');
    if (!container) return;

    if (!conditions || conditions.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay condiciones médicas registradas</p>';
        return;
    }

    const html = conditions.map(condition => `
        <div class="condition-item mb-3 p-3 border rounded">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <div class="fw-bold">${condition.name}</div>
                    <div class="text-muted small">Diagnosticado: ${PatientCore.formatDate(condition.diagnosis_date)}</div>
                    ${condition.notes ? `<div class="text-muted small mt-1">${condition.notes}</div>` : ''}
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="editCondition(${condition.id})">
                            <i class="fas fa-edit me-2"></i>Editar
                        </a></li>
                        <li><a class="dropdown-item text-danger" href="#" onclick="deleteCondition(${condition.id})">
                            <i class="fas fa-trash me-2"></i>Eliminar
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Renderizar medicamentos
function renderMedications(medications) {
    const container = document.getElementById('medications-content');
    if (!container) return;

    if (!medications || medications.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay medicamentos registrados</p>';
        return;
    }

    const html = medications.map(medication => `
        <div class="medication-item mb-3 p-3 border rounded">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <div class="fw-bold">${medication.name}</div>
                    <div class="text-muted small">
                        Dosis: ${medication.dosage || 'No especificada'} |
                        Frecuencia: ${medication.frequency || 'No especificada'}
                    </div>
                    ${medication.start_date ? `<div class="text-muted small">Inicio: ${PatientCore.formatDate(medication.start_date)}</div>` : ''}
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="editMedication(${medication.id})">
                            <i class="fas fa-edit me-2"></i>Editar
                        </a></li>
                        <li><a class="dropdown-item text-danger" href="#" onclick="deleteMedication(${medication.id})">
                            <i class="fas fa-trash me-2"></i>Eliminar
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Renderizar alergias
function renderAllergies(allergies) {
    const container = document.getElementById('allergies-content');
    if (!container) return;

    if (!allergies || allergies.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay alergias registradas</p>';
        return;
    }

    const html = allergies.map(allergy => `
        <div class="allergy-item mb-3 p-3 border rounded">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <div class="fw-bold">${allergy.name}</div>
                    <div class="text-muted small">Severidad: ${getSeverityText(allergy.severity)}</div>
                    ${allergy.reaction_description ? `<div class="text-muted small mt-1">${allergy.reaction_description}</div>` : ''}
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="editAllergy(${allergy.id})">
                            <i class="fas fa-edit me-2"></i>Editar
                        </a></li>
                        <li><a class="dropdown-item text-danger" href="#" onclick="deleteAllergy(${allergy.id})">
                            <i class="fas fa-trash me-2"></i>Eliminar
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Renderizar historial familiar
function renderFamilyHistory(familyHistory) {
    const container = document.getElementById('family-history-content');
    if (!container) return;

    if (!familyHistory || familyHistory.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay historial familiar registrado</p>';
        return;
    }

    const html = familyHistory.map(history => `
        <div class="family-history-item mb-3 p-3 border rounded">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <div class="fw-bold">${history.condition_name}</div>
                    <div class="text-muted small">Familiar: ${history.relative_type || 'No especificado'}</div>
                    ${history.notes ? `<div class="text-muted small mt-1">${history.notes}</div>` : ''}
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="editFamilyHistory(${history.id})">
                            <i class="fas fa-edit me-2"></i>Editar
                        </a></li>
                        <li><a class="dropdown-item text-danger" href="#" onclick="deleteFamilyHistory(${history.id})">
                            <i class="fas fa-trash me-2"></i>Eliminar
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Poblar formulario del perfil de salud
function populateHealthProfileForm(healthProfile) {
    if (!healthProfile) return;

    const form = document.getElementById('health-profile-form');
    if (!form) return;

    // Poblar campos del formulario
    form.height_cm.value = healthProfile.height_cm || '';
    form.weight_kg.value = healthProfile.weight_kg || '';
    form.blood_type.value = healthProfile.blood_type || '';
    form.physical_activity.value = healthProfile.physical_activity_minutes_weekly || '';
    form.is_smoker.checked = healthProfile.is_smoker || false;
    form.smoking_years.value = healthProfile.smoking_years || '';
    form.consumes_alcohol.checked = healthProfile.consumes_alcohol || false;
    form.alcohol_frequency.value = healthProfile.alcohol_frequency || 'never';
    form.notes.value = healthProfile.notes || '';
}

// Configurar event listeners para formularios
function setupMedicalRecordFormListeners() {
    // Formulario de perfil de salud
    const healthProfileForm = document.getElementById('health-profile-form');
    if (healthProfileForm) {
        healthProfileForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleHealthProfileSubmit();
        });
    }

    // Formulario de condición médica
    const conditionForm = document.getElementById('condition-form');
    if (conditionForm) {
        conditionForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleConditionSubmit();
        });
    }

    // Formulario de medicamento
    const medicationForm = document.getElementById('medication-form');
    if (medicationForm) {
        medicationForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleMedicationSubmit();
        });
    }

    // Formulario de alergia
    const allergyForm = document.getElementById('allergy-form');
    if (allergyForm) {
        allergyForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleAllergySubmit();
        });
    }

    // Formulario de historial familiar
    const familyHistoryForm = document.getElementById('family-history-form');
    if (familyHistoryForm) {
        familyHistoryForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleFamilyHistorySubmit();
        });
    }
}

// Manejadores de envío de formularios
async function handleHealthProfileSubmit() {
    PatientCore.showErrorMessage('Funcionalidad no implementada temporalmente.');
}

async function handleConditionSubmit() {
    PatientCore.showErrorMessage('Funcionalidad no implementada temporalmente.');
}

async function handleMedicationSubmit() {
    PatientCore.showErrorMessage('Funcionalidad no implementada temporalmente.');
}

async function handleAllergySubmit() {
    PatientCore.showErrorMessage('Funcionalidad no implementada temporalmente.');
}

async function handleFamilyHistorySubmit() {
    PatientCore.showErrorMessage('Funcionalidad no implementada temporalmente.');
}

// Funciones auxiliares
function getSeverityText(severity) {
    const severityMap = {
        'mild': 'Leve',
        'moderate': 'Moderada',
        'severe': 'Severa'
    };
    return severityMap[severity] || severity || 'No especificada';
}

// Funciones globales para los botones de editar/eliminar
// (Se asume que PatientCore.formatDate está disponible si se elimina la local)
// Si no, se debe descomentar la función formatDate local
// function formatDate(dateString) {
//     if (!dateString) return 'Fecha no disponible';
//     const date = new Date(dateString);
//     return date.toLocaleDateString('es-ES', {
//         year: 'numeric',
//         month: 'long',
//         day: 'numeric'
//     });
// }


window.editCondition = function(id) {
    console.log('Editar condición:', id);
    // TODO: Implementar edición
};

window.deleteCondition = function(id) {
    if (confirm('¿Estás seguro de que quieres eliminar esta condición médica?')) {
        console.log('Eliminar condición:', id);
        // TODO: Implementar eliminación
    }
};

window.editMedication = function(id) {
    console.log('Editar medicamento:', id);
    // TODO: Implementar edición
};

window.deleteMedication = function(id) {
    if (confirm('¿Estás seguro de que quieres eliminar este medicamento?')) {
        console.log('Eliminar medicamento:', id);
        // TODO: Implementar eliminación
    }
};

window.editAllergy = function(id) {
    console.log('Editar alergia:', id);
    // TODO: Implementar edición
};

window.deleteAllergy = function(id) {
    if (confirm('¿Estás seguro de que quieres eliminar esta alergia?')) {
        console.log('Eliminar alergia:', id);
        // TODO: Implementar eliminación
    }
};

window.editFamilyHistory = function(id) {
    console.log('Editar historial familiar:', id);
    // TODO: Implementar edición
};

window.deleteFamilyHistory = function(id) {
    if (confirm('¿Estás seguro de que quieres eliminar este historial familiar?')) {
        console.log('Eliminar historial familiar:', id);
        // TODO: Implementar eliminación
    }
};