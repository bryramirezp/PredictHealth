// /frontend/static/js/medical-record.js
// Módulo específico para la gestión del expediente médico del paciente
// Maneja formularios modales, validaciones y llamadas API para el expediente médico

document.addEventListener('DOMContentLoaded', async () => {
    const Auth = window.AuthManager;
    const API = window.PredictHealthAPI;

    // Verificar autenticación
    const userInfo = await Auth.getUserInfo();
    if (!userInfo || userInfo.user_type !== 'patient') {
        console.warn('Acceso denegado: usuario no es paciente');
        return window.location.href = '/';
    }

    // Solo inicializar si estamos en la página de expediente médico
    if (window.location.pathname.includes('/patient/medical-record')) {
        initMedicalRecordPage(userInfo, API);
    }
});

// Función principal de inicialización
async function initMedicalRecordPage(userInfo, API) {
    console.log("Inicializando expediente médico con formularios dinámicos...");

    try {
        // Cargar datos del expediente médico
        await loadMedicalRecordData(API);

        // Configurar event listeners para formularios
        setupMedicalRecordFormListeners(API);

        console.log('Expediente médico con formularios dinámicos inicializado correctamente');
    } catch (error) {
        console.error('Error inicializando expediente médico:', error);
        showErrorMessage('Error al cargar el expediente médico. Por favor, intenta recargar la página.');
    }
}

// Cargar datos del expediente médico
async function loadMedicalRecordData(API) {
    try {
        // Obtener el token JWT y patient_id del usuario autenticado
        const token = await Auth.getToken();
        const patientId = userInfo.reference_id;

        if (!token || !patientId) {
            throw new Error('No se pudo obtener la información de autenticación del paciente');
        }

        const response = await fetch(`/api/web/patients/${patientId}/medical-record`, {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': `Bearer ${token}`
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error en la respuesta del servidor');
        }

        const recordData = result.data;

        // Renderizar cada sección
        renderHealthProfile(recordData.health_profile);
        renderConditions(recordData.conditions);
        renderMedications(recordData.medications);
        renderAllergies(recordData.allergies);
        renderFamilyHistory(recordData.family_history);

    } catch (error) {
        console.error('Error cargando datos del expediente médico:', error);
        throw error;
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
                    <div class="text-muted small">Diagnosticado: ${formatDate(condition.diagnosis_date)}</div>
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
                    ${medication.start_date ? `<div class="text-muted small">Inicio: ${formatDate(medication.start_date)}</div>` : ''}
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
function setupMedicalRecordFormListeners(API) {
    // Formulario de perfil de salud
    const healthProfileForm = document.getElementById('health-profile-form');
    if (healthProfileForm) {
        healthProfileForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleHealthProfileSubmit(API);
        });
    }

    // Formulario de condición médica
    const conditionForm = document.getElementById('condition-form');
    if (conditionForm) {
        conditionForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleConditionSubmit(API);
        });
    }

    // Formulario de medicamento
    const medicationForm = document.getElementById('medication-form');
    if (medicationForm) {
        medicationForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleMedicationSubmit(API);
        });
    }

    // Formulario de alergia
    const allergyForm = document.getElementById('allergy-form');
    if (allergyForm) {
        allergyForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleAllergySubmit(API);
        });
    }

    // Formulario de historial familiar
    const familyHistoryForm = document.getElementById('family-history-form');
    if (familyHistoryForm) {
        familyHistoryForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleFamilyHistorySubmit(API);
        });
    }
}

// Manejadores de envío de formularios
async function handleHealthProfileSubmit(API) {
    const form = document.getElementById('health-profile-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Guardando...';

        const formData = new FormData(form);
        const profileData = Object.fromEntries(formData);

        // Convertir valores numéricos
        if (profileData.height_cm) profileData.height_cm = parseFloat(profileData.height_cm);
        if (profileData.weight_kg) profileData.weight_kg = parseFloat(profileData.weight_kg);
        if (profileData.physical_activity) profileData.physical_activity = parseInt(profileData.physical_activity);
        if (profileData.smoking_years) profileData.smoking_years = parseInt(profileData.smoking_years);

        // Convertir checkboxes
        profileData.is_smoker = form.is_smoker.checked;
        profileData.consumes_alcohol = form.consumes_alcohol.checked;

        const response = await fetch('/api/web/patient/health-profile', {
            method: 'PUT',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(profileData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al actualizar el perfil de salud');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('healthProfileModal'));
        modal.hide();

        // Recargar la página para mostrar los cambios
        window.location.reload();

        showSuccessMessage('Perfil de salud actualizado exitosamente');

    } catch (error) {
        console.error('Error actualizando perfil de salud:', error);
        showErrorMessage(error.message || 'Error al actualizar el perfil de salud');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-save me-1"></i>Guardar Cambios';
    }
}

async function handleConditionSubmit(API) {
    const form = document.getElementById('condition-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';

        const formData = new FormData(form);
        const conditionData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/conditions', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(conditionData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar la condición médica');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('conditionModal'));
        modal.hide();

        form.reset();
        await loadMedicalRecordData(API);

        showSuccessMessage('Condición médica agregada exitosamente');

    } catch (error) {
        console.error('Error agregando condición médica:', error);
        showErrorMessage(error.message || 'Error al agregar la condición médica');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Condición';
    }
}

async function handleMedicationSubmit(API) {
    const form = document.getElementById('medication-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';

        const formData = new FormData(form);
        const medicationData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/medications', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(medicationData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar el medicamento');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('medicationModal'));
        modal.hide();

        form.reset();
        await loadMedicalRecordData(API);

        showSuccessMessage('Medicamento agregado exitosamente');

    } catch (error) {
        console.error('Error agregando medicamento:', error);
        showErrorMessage(error.message || 'Error al agregar el medicamento');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Medicamento';
    }
}

async function handleAllergySubmit(API) {
    const form = document.getElementById('allergy-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';

        const formData = new FormData(form);
        const allergyData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/allergies', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(allergyData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar la alergia');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('allergyModal'));
        modal.hide();

        form.reset();
        await loadMedicalRecordData(API);

        showSuccessMessage('Alergia agregada exitosamente');

    } catch (error) {
        console.error('Error agregando alergia:', error);
        showErrorMessage(error.message || 'Error al agregar la alergia');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Alergia';
    }
}

async function handleFamilyHistorySubmit(API) {
    const form = document.getElementById('family-history-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';

        const formData = new FormData(form);
        const familyHistoryData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/family-history', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(familyHistoryData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar el historial familiar');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('familyHistoryModal'));
        modal.hide();

        form.reset();
        await loadMedicalRecordData(API);

        showSuccessMessage('Historial familiar agregado exitosamente');

    } catch (error) {
        console.error('Error agregando historial familiar:', error);
        showErrorMessage(error.message || 'Error al agregar el historial familiar');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Historial';
    }
}

// Funciones auxiliares
function formatDate(dateString) {
    if (!dateString) return 'Fecha no disponible';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function getSeverityText(severity) {
    const severityMap = {
        'mild': 'Leve',
        'moderate': 'Moderada',
        'severe': 'Severa'
    };
    return severityMap[severity] || severity || 'No especificada';
}

function showErrorMessage(message) {
    console.error('Error:', message);

    const notification = document.createElement('div');
    notification.className = 'alert alert-danger alert-dismissible fade show position-fixed';
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    notification.innerHTML = `
        <i class="fas fa-exclamation-triangle me-2"></i>
        <strong>Error:</strong> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

function showSuccessMessage(message) {
    console.log('Success:', message);

    const notification = document.createElement('div');
    notification.className = 'alert alert-success alert-dismissible fade show position-fixed';
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    notification.innerHTML = `
        <i class="fas fa-check-circle me-2"></i>
        <strong>Éxito:</strong> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 3000);
}

// Funciones globales para los botones de editar/eliminar
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