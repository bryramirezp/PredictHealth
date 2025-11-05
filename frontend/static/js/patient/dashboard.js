// /frontend/static/js/patient.js
// Módulo de lógica de negocio para el rol de Paciente
// Maneja todas las vistas y funcionalidades específicas del paciente

document.addEventListener('DOMContentLoaded', async () => {
    const Auth = window.AuthManager;
    const API = window.PredictHealthAPI;

    // 1. Proteger todas las páginas del paciente
    const userInfo = await Auth.getUserInfo();
    if (!userInfo || userInfo.user_type !== 'patient') {
        console.warn('Acceso denegado: usuario no es paciente');
        return window.location.href = '/';
    }

    // 2. Enrutador simple del lado del cliente
    const path = window.location.pathname;
    console.log('Cargando página del paciente:', path);

    if (path.includes('/patient/dashboard')) {
        initDashboardPage(userInfo, API);
    } else if (path.includes('/patient/medical-record')) {
        initMedicalRecordPage(userInfo, API);
    } else if (path.includes('/patient/my-care-team')) {
        initCareTeamPage(userInfo, API);
    } else if (path.includes('/patient/profile')) {
        initProfilePage(userInfo, API);
    } else {
        console.warn('Página del paciente no reconocida:', path);
    }
});

// Función para la página del dashboard
async function initDashboardPage(userInfo, API) {
    console.log("Inicializando Dashboard del Paciente...");

    try {
        // Mostrar loading inicial
        showLoading('welcome-title', 'Cargando información del paciente...');
        showLoading('health-score', 'Calculando...');
        showLoading('active-medications', 'Cargando medicamentos...');

        // Obtener el token JWT y patient_id del usuario autenticado
        const token = await Auth.getToken();
        const patientId = userInfo.reference_id;

        if (!token || !patientId) {
            throw new Error('No se pudo obtener la información de autenticación del paciente');
        }

        // Obtener datos del paciente desde el microservicio correcto
        const response = await fetch(`/api/v1/patients/${patientId}`, {
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

        const patientData = result.data;

        // Renderizar widgets del dashboard con datos del paciente
        console.log('Patient data received:', patientData);
        console.log('Patient data structure:', JSON.stringify(patientData, null, 2));

        // Verificar que tenemos datos antes de renderizar
        if (patientData) {
            renderDashboardWidgets(patientData);
        } else {
            console.warn('No se recibieron datos del paciente');
            showErrorMessage('No se pudieron cargar los datos del paciente');
        }

        // Configurar event listeners
        setupDashboardEventListeners();

        console.log('Dashboard del paciente cargado exitosamente con datos de la base de datos');
    } catch (error) {
        console.error('Error cargando dashboard del paciente:', error);
        showErrorMessage('Error al cargar el dashboard. Por favor, intenta recargar la página.');
    }
}

// Función para la página de la ficha médica
async function initMedicalRecordPage(userInfo, API) {
    console.log("Inicializando Expediente Médico del Paciente...");

    try {
        // Mostrar loading en todas las pestañas
        showLoading('health-profile', 'Cargando perfil de salud...');
        showLoading('conditions', 'Cargando condiciones...');
        showLoading('medications', 'Cargando medicamentos...');
        showLoading('allergies', 'Cargando alergias...');
        showLoading('family-history', 'Cargando historial familiar...');

        // Obtener datos del expediente médico desde el nuevo endpoint
        const response = await fetch('/api/web/patient/medical-record', {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
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

        // Renderizar expediente médico completo
        renderMedicalRecordTabs(recordData);

        // Configurar event listeners
        setupMedicalRecordEventListeners();

        console.log('Expediente médico del paciente cargado exitosamente con datos de la base de datos');
    } catch (error) {
        console.error('Error cargando expediente médico:', error);
        showErrorMessage('Error al cargar el expediente médico. Por favor, intenta recargar la página.');
    }
}

// Función para la página del equipo médico
async function initCareTeamPage(userInfo, API) {
    console.log("Inicializando Equipo Médico del Paciente...");

    try {
        // Mostrar loading
        showLoading('primary-doctor', 'Cargando información del doctor...');
        showLoading('medical-institution', 'Cargando información de la institución...');

        // Obtener datos del equipo médico desde el nuevo endpoint
        const response = await fetch('/api/web/patient/care-team', {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error en la respuesta del servidor');
        }

        const careTeamData = result.data;

        // Renderizar equipo médico con datos reales
        renderCareTeam(careTeamData);

        console.log('Equipo médico del paciente cargado exitosamente con datos de la base de datos');
    } catch (error) {
        console.error('Error cargando equipo médico:', error);
        showErrorMessage('Error al cargar el equipo médico. Por favor, intenta recargar la página.');
    }
}

// Función para la página del perfil
async function initProfilePage(userInfo, API) {
    console.log("Inicializando Perfil del Paciente...");

    try {
        // Mostrar loading
        showLoading('personal-info-content', 'Cargando información personal...');
        showLoading('emails-content', 'Cargando emails...');
        showLoading('phones-content', 'Cargando teléfonos...');
        showLoading('addresses-content', 'Cargando direcciones...');

        // Obtener datos del perfil desde el nuevo endpoint
        const response = await fetch('/api/web/patient/profile', {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error en la respuesta del servidor');
        }

        const profileData = result.data;

        // Renderizar todas las secciones del perfil con datos reales
        renderProfileSections(profileData);

        // Configurar event listeners para formularios CRUD
        setupProfileCRUDListeners(API);

        console.log('Perfil del paciente cargado exitosamente con datos de la base de datos');
    } catch (error) {
        console.error('Error cargando perfil del paciente:', error);
        showErrorMessage('Error al cargar el perfil. Por favor, intenta recargar la página.');
    }
}

// Funciones de renderizado
function renderDashboardWidgets(data) {
    console.log('Renderizando dashboard con datos del paciente:', data);

    // Verificar estructura de datos
    if (!data) {
        console.error('No hay datos del paciente para renderizar');
        return;
    }

    // Renderizar título de bienvenida con nombre real
    const welcomeTitleEl = document.getElementById('welcome-title');
    if (welcomeTitleEl) {
        if (data.first_name && data.last_name) {
            welcomeTitleEl.textContent = `Bienvenido, ${data.first_name} ${data.last_name}`;
            console.log('Nombre actualizado:', data.first_name, data.last_name);
        } else {
            console.warn('Nombre del paciente no encontrado en los datos');
            welcomeTitleEl.textContent = 'Bienvenido, Paciente';
        }
    } else {
        console.warn('No se encontró elemento welcome-title');
    }

    // Renderizar estadísticas de salud (por ahora placeholder)
    const healthScoreEl = document.getElementById('health-score');
    if (healthScoreEl) {
        // TODO: Calcular health score basado en datos del paciente
        const healthScore = '85'; // Placeholder hasta implementar cálculo
        healthScoreEl.textContent = healthScore;
        console.log('Puntuación de salud actualizada:', healthScore);
    } else {
        console.warn('No se encontró elemento health-score');
    }

    // Renderizar medicamentos activos (por ahora vacío)
    const medicationsEl = document.getElementById('active-medications');
    if (medicationsEl) {
        // TODO: Obtener medicamentos desde el expediente médico
        const medications = []; // Placeholder hasta implementar
        renderMedicationsList(medicationsEl, medications);
        console.log('Medicamentos renderizados:', medications.length);
    } else {
        console.warn('No se encontró elemento active-medications');
    }

    console.log('Dashboard renderizado exitosamente con datos del paciente');
}

function renderMedicalRecordTabs(data) {
    // Renderizar perfil de salud
    populateHealthProfile(data.health_profile);

    // Renderizar condiciones médicas
    populateConditions(data.conditions);

    // Renderizar medicamentos
    populateMedicationsList(data.medications);

    // Renderizar alergias
    populateAllergies(data.allergies);

    // Renderizar historial familiar
    populateFamilyHistory(data.family_history);
}

function renderCareTeam(data) {
    // Renderizar doctor principal con datos reales
    const doctorEl = document.getElementById('primary-doctor');
    if (doctorEl && data.doctor) {
        doctorEl.innerHTML = `
            <div class="card-body">
                <h4 class="card-title">Dr. ${data.doctor.first_name} ${data.doctor.last_name}</h4>
                <p class="card-text"><strong>Especialidad:</strong> ${data.doctor.specialty || 'No especificada'}</p>
                <p class="card-text"><strong>Años de experiencia:</strong> ${data.doctor.years_experience || 'No disponible'}</p>
                <p class="card-text"><strong>Email:</strong> ${data.doctor.email || 'No disponible'}</p>
                <p class="card-text"><strong>Teléfono:</strong> ${data.doctor.phone || 'No disponible'}</p>
            </div>
        `;
    }

    // Renderizar institución con datos reales
    const institutionEl = document.getElementById('medical-institution');
    if (institutionEl && data.institution) {
        const address = data.institution.address;
        const addressText = address ?
            `${address.street || ''}, ${address.city || ''}, ${address.region || ''}, ${address.country || ''}`.replace(/^, |, $/, '') :
            'Dirección no disponible';

        institutionEl.innerHTML = `
            <div class="card-body">
                <h4 class="card-title">${data.institution.name || 'Institución no especificada'}</h4>
                <p class="card-text"><strong>Tipo:</strong> ${data.institution.type || 'No especificado'}</p>
                <p class="card-text"><strong>Dirección:</strong> ${addressText}</p>
                <p class="card-text"><strong>Teléfono:</strong> ${data.institution.phone || 'No disponible'}</p>
                <p class="card-text"><strong>Email:</strong> ${data.institution.email || 'No disponible'}</p>
                ${data.institution.website ? `<p class="card-text"><strong>Sitio web:</strong> <a href="${data.institution.website}" target="_blank">${data.institution.website}</a></p>` : ''}
            </div>
        `;
    }
}

function renderProfileSections(data) {
    // Renderizar información personal
    renderPersonalInfo(data.personal_info);

    // Renderizar listas CRUD
    renderEmailsList(data.emails);
    renderPhonesList(data.phones);
    renderAddressesList(data.addresses);
}

// Función para renderizar información personal
function renderPersonalInfo(personalInfo) {
    const container = document.getElementById('personal-info-content');
    if (!container) return;

    if (!personalInfo) {
        container.innerHTML = '<p class="text-muted">No hay información personal disponible</p>';
        return;
    }

    container.innerHTML = `
        <div class="row">
            <div class="col-md-6">
                <p><strong>Nombre:</strong> ${personalInfo.first_name || 'No especificado'}</p>
                <p><strong>Apellido:</strong> ${personalInfo.last_name || 'No especificado'}</p>
            </div>
            <div class="col-md-6">
                <p><strong>Fecha de Nacimiento:</strong> ${formatDate(personalInfo.date_of_birth) || 'No especificada'}</p>
                <p><strong>Email Principal:</strong> ${personalInfo.primary_email || 'No especificado'}</p>
            </div>
        </div>
    `;

    // Poblar el formulario del modal con datos existentes
    populatePersonalInfoForm(personalInfo);
}

// Función para renderizar lista de emails con CRUD
function renderEmailsList(emails) {
    const container = document.getElementById('emails-content');
    if (!container) return;

    if (!emails || emails.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay emails registrados</p>';
        return;
    }

    const html = emails.map(email => `
        <div class="email-item mb-3 p-3 border rounded">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <div class="d-flex align-items-center mb-2">
                        <strong class="me-2">${email.email_address}</strong>
                        ${email.is_primary ? '<span class="badge bg-primary">Principal</span>' : ''}
                        ${email.is_verified ? '<i class="fas fa-check-circle text-success ms-2" title="Verificado"></i>' : '<i class="fas fa-exclamation-triangle text-warning ms-2" title="No verificado"></i>'}
                    </div>
                    <div class="text-muted small">Tipo: ${getEmailTypeText(email.email_type)}</div>
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="editEmail('${email.id}')">
                            <i class="fas fa-edit me-2"></i>Editar
                        </a></li>
                        ${!email.is_primary ? `
                        <li><a class="dropdown-item" href="#" onclick="setPrimaryEmail('${email.id}')">
                            <i class="fas fa-star me-2"></i>Establecer como Principal
                        </a></li>
                        ` : ''}
                        <li><a class="dropdown-item text-danger" href="#" onclick="deleteEmail('${email.id}')">
                            <i class="fas fa-trash me-2"></i>Eliminar
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Función para renderizar lista de teléfonos con CRUD
function renderPhonesList(phones) {
    const container = document.getElementById('phones-content');
    if (!container) return;

    if (!phones || phones.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay teléfonos registrados</p>';
        return;
    }

    const html = phones.map(phone => `
        <div class="phone-item mb-3 p-3 border rounded">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <div class="d-flex align-items-center mb-2">
                        <strong class="me-2">${formatPhoneNumber(phone.phone_number)}</strong>
                        ${phone.is_primary ? '<span class="badge bg-primary">Principal</span>' : ''}
                        ${phone.is_verified ? '<i class="fas fa-check-circle text-success ms-2" title="Verificado"></i>' : '<i class="fas fa-exclamation-triangle text-warning ms-2" title="No verificado"></i>'}
                    </div>
                    <div class="text-muted small">Tipo: ${getPhoneTypeText(phone.phone_type)}</div>
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="editPhone('${phone.id}')">
                            <i class="fas fa-edit me-2"></i>Editar
                        </a></li>
                        ${!phone.is_primary ? `
                        <li><a class="dropdown-item" href="#" onclick="setPrimaryPhone('${phone.id}')">
                            <i class="fas fa-star me-2"></i>Establecer como Principal
                        </a></li>
                        ` : ''}
                        <li><a class="dropdown-item text-danger" href="#" onclick="deletePhone('${phone.id}')">
                            <i class="fas fa-trash me-2"></i>Eliminar
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Función para renderizar lista de direcciones con CRUD
function renderAddressesList(addresses) {
    const container = document.getElementById('addresses-content');
    if (!container) return;

    if (!addresses || addresses.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay direcciones registradas</p>';
        return;
    }

    const html = addresses.map(address => `
        <div class="address-item mb-3 p-3 border rounded">
            <div class="d-flex justify-content-between align-items-start">
                <div class="flex-grow-1">
                    <div class="d-flex align-items-center mb-2">
                        <strong class="me-2">${address.street_address}</strong>
                        ${address.is_primary ? '<span class="badge bg-primary">Principal</span>' : ''}
                        ${address.is_verified ? '<i class="fas fa-check-circle text-success ms-2" title="Verificada"></i>' : '<i class="fas fa-exclamation-triangle text-warning ms-2" title="No verificada"></i>'}
                    </div>
                    <div class="text-muted small">
                        ${address.city || ''}${address.city && address.region_id ? ', ' : ''}${address.region_id || ''}
                        ${address.postal_code ? `CP: ${address.postal_code}` : ''}
                    </div>
                    <div class="text-muted small">Tipo: ${getAddressTypeText(address.address_type)}</div>
                </div>
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="#" onclick="editAddress('${address.id}')">
                            <i class="fas fa-edit me-2"></i>Editar
                        </a></li>
                        ${!address.is_primary ? `
                        <li><a class="dropdown-item" href="#" onclick="setPrimaryAddress('${address.id}')">
                            <i class="fas fa-star me-2"></i>Establecer como Principal
                        </a></li>
                        ` : ''}
                        <li><a class="dropdown-item text-danger" href="#" onclick="deleteAddress('${address.id}')">
                            <i class="fas fa-trash me-2"></i>Eliminar
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Funciones auxiliares de renderizado
function renderMedicationsList(container, medications) {
    if (medications.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay medicamentos activos</p>';
        return;
    }

    const html = medications.map(med => `
        <div class="medication-item mb-2 p-2 border rounded">
            <div class="fw-bold">${med.name}</div>
            <div class="text-muted small">Dosis: ${med.dosage || 'No especificada'}</div>
            <div class="text-muted small">Frecuencia: ${med.frequency || 'No especificada'}</div>
        </div>
    `).join('');

    container.innerHTML = html;
}

function renderConditionsList(container, conditions) {
    if (conditions.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay condiciones médicas registradas</p>';
        return;
    }

    const html = conditions.map(cond => `
        <div class="condition-item mb-3 p-3 border rounded">
            <div class="fw-bold">${cond.name}</div>
            <div class="text-muted small">Diagnosticado: ${formatDate(cond.diagnosis_date)}</div>
            <div class="text-muted small">${cond.notes || 'Sin notas adicionales'}</div>
        </div>
    `).join('');

    container.innerHTML = html;
}

// Funciones para poblar las pestañas del expediente médico
function populateHealthProfile(healthProfile) {
    const container = document.getElementById('health-profile');
    if (!container) return;

    if (!healthProfile) {
        container.innerHTML = '<p class="text-muted">No hay información de perfil de salud disponible</p>';
        return;
    }

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
                <p><strong>Ejercicio semanal:</strong> ${healthProfile.physical_activity_minutes_weekly || 0} minutos</p>
            </div>
        </div>
        ${healthProfile.notes ? `<p><strong>Notas:</strong> ${healthProfile.notes}</p>` : ''}
    `;
}

function populateConditions(conditions) {
    const container = document.getElementById('conditions');
    if (!container) return;

    renderConditionsList(container, conditions || []);
}

function populateMedicationsList(medications) {
    const container = document.getElementById('medications');
    if (!container) return;

    renderMedicationsList(container, medications || []);
}

function populateAllergies(allergies) {
    const container = document.getElementById('allergies');
    if (!container) return;

    if (!allergies || allergies.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay alergias registradas</p>';
        return;
    }

    const html = allergies.map(allergy => `
        <div class="allergy-item mb-3 p-3 border rounded">
            <div class="fw-bold">${allergy.name}</div>
            <div class="text-muted small">Severidad: ${allergy.severity || 'No especificada'}</div>
            ${allergy.reaction_description ? `<div class="text-muted small">Reacción: ${allergy.reaction_description}</div>` : ''}
        </div>
    `).join('');

    container.innerHTML = html;
}

function populateFamilyHistory(familyHistory) {
    const container = document.getElementById('family-history');
    if (!container) return;

    if (!familyHistory || familyHistory.length === 0) {
        container.innerHTML = '<p class="text-muted">No hay historial familiar registrado</p>';
        return;
    }

    const html = familyHistory.map(history => `
        <div class="family-history-item mb-3 p-3 border rounded">
            <div class="fw-bold">${history.condition_name}</div>
            <div class="text-muted small">Familiar: ${history.relative_type || 'No especificado'}</div>
            ${history.notes ? `<div class="text-muted small">Notas: ${history.notes}</div>` : ''}
        </div>
    `).join('');

    container.innerHTML = html;
}

// Funciones de configuración de eventos
function setupDashboardEventListeners() {
    // Event listeners específicos del dashboard
    const refreshBtn = document.getElementById('refresh-dashboard');
    if (refreshBtn) {
        refreshBtn.addEventListener('click', () => {
            // Recargar datos del dashboard
            window.location.reload();
        });
    }
}

function setupMedicalRecordEventListeners() {
    // Event listeners para la ficha médica
    const downloadBtn = document.getElementById('download-record');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', () => {
            // Lógica para descargar ficha médica
            console.log('Descargando ficha médica...');
        });
    }
}

function setupProfileCRUDListeners(API) {
    // Formulario de información personal
    const personalInfoForm = document.getElementById('personal-info-form');
    if (personalInfoForm) {
        personalInfoForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handlePersonalInfoSubmit(API);
        });
    }

    // Formulario de email
    const emailForm = document.getElementById('email-form');
    if (emailForm) {
        emailForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleEmailSubmit(API);
        });
    }

    // Formulario de teléfono
    const phoneForm = document.getElementById('phone-form');
    if (phoneForm) {
        phoneForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handlePhoneSubmit(API);
        });
    }

    // Formulario de dirección
    const addressForm = document.getElementById('address-form');
    if (addressForm) {
        addressForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleAddressSubmit(API);
        });
    }

    // Formulario de cambio de contraseña
    const passwordForm = document.getElementById('password-change-form');
    if (passwordForm) {
        passwordForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handlePasswordChange(API);
        });

        // Validación en tiempo real para confirmar contraseña
        const newPassword = document.getElementById('newPassword');
        const confirmPassword = document.getElementById('confirmPassword');
        const feedback = document.getElementById('password-match-feedback');

        if (newPassword && confirmPassword && feedback) {
            confirmPassword.addEventListener('input', () => {
                if (confirmPassword.value === '') {
                    feedback.textContent = '';
                    confirmPassword.classList.remove('is-valid', 'is-invalid');
                } else if (confirmPassword.value === newPassword.value) {
                    feedback.textContent = 'Las contraseñas coinciden';
                    feedback.className = 'form-text text-success';
                    confirmPassword.classList.remove('is-invalid');
                    confirmPassword.classList.add('is-valid');
                } else {
                    feedback.textContent = 'Las contraseñas no coinciden';
                    feedback.className = 'form-text text-danger';
                    confirmPassword.classList.remove('is-valid');
                    confirmPassword.classList.add('is-invalid');
                }
            });
        }
    }
}

// Manejadores de formularios CRUD
async function handlePersonalInfoSubmit(API) {
    const form = document.getElementById('personal-info-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Guardando...';

        const formData = new FormData(form);
        const personalData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/personal-info', {
            method: 'PUT',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(personalData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al actualizar la información personal');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('personalInfoModal'));
        modal.hide();

        await loadProfileData(API);

        showSuccessMessage('Información personal actualizada exitosamente');

    } catch (error) {
        console.error('Error actualizando información personal:', error);
        showErrorMessage(error.message || 'Error al actualizar la información personal');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-save me-1"></i>Guardar Cambios';
    }
}

async function handleEmailSubmit(API) {
    const form = document.getElementById('email-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';

        const formData = new FormData(form);
        const emailData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/emails', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(emailData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar el email');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('emailModal'));
        modal.hide();

        form.reset();
        await loadProfileData(API);

        showSuccessMessage('Email agregado exitosamente');

    } catch (error) {
        console.error('Error agregando email:', error);
        showErrorMessage(error.message || 'Error al agregar el email');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Email';
    }
}

async function handlePhoneSubmit(API) {
    const form = document.getElementById('phone-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';

        const formData = new FormData(form);
        const phoneData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/phones', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(phoneData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar el teléfono');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('phoneModal'));
        modal.hide();

        form.reset();
        await loadProfileData(API);

        showSuccessMessage('Teléfono agregado exitosamente');

    } catch (error) {
        console.error('Error agregando teléfono:', error);
        showErrorMessage(error.message || 'Error al agregar el teléfono');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Teléfono';
    }
}

async function handleAddressSubmit(API) {
    const form = document.getElementById('address-form');
    const submitBtn = form.querySelector('button[type="submit"]');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Agregando...';

        const formData = new FormData(form);
        const addressData = Object.fromEntries(formData);

        const response = await fetch('/api/web/patient/addresses', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify(addressData)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al agregar la dirección');
        }

        // Cerrar modal y recargar datos
        const modal = bootstrap.Modal.getInstance(document.getElementById('addressModal'));
        modal.hide();

        form.reset();
        await loadProfileData(API);

        showSuccessMessage('Dirección agregada exitosamente');

    } catch (error) {
        console.error('Error agregando dirección:', error);
        showErrorMessage(error.message || 'Error al agregar la dirección');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus me-1"></i>Agregar Dirección';
    }
}

async function handlePasswordChange(API) {
    const form = document.getElementById('password-change-form');
    const submitBtn = document.getElementById('change-password-btn');

    try {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Cambiando...';

        const formData = new FormData(form);
        const passwordData = Object.fromEntries(formData);

        // Validar que las contraseñas coincidan
        if (passwordData.newPassword !== passwordData.confirmPassword) {
            throw new Error('Las contraseñas nuevas no coinciden');
        }

        const response = await fetch('/api/web/auth/change-password', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                current_password: passwordData.currentPassword,
                new_password: passwordData.newPassword
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error al cambiar la contraseña');
        }

        // Limpiar formulario
        form.reset();

        showSuccessMessage('Contraseña cambiada exitosamente');

    } catch (error) {
        console.error('Error cambiando contraseña:', error);
        showErrorMessage(error.message || 'Error al cambiar la contraseña');
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-key me-1"></i>Cambiar Contraseña';
    }
}

// Función auxiliar para cargar datos del perfil (para recargas)
async function loadProfileData(API) {
    try {
        const response = await fetch('/api/web/patient/profile', {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (result.status !== 'success') {
            throw new Error(result.message || 'Error en la respuesta del servidor');
        }

        const profileData = result.data;

        // Renderizar secciones actualizadas
        renderProfileSections(profileData);

    } catch (error) {
        console.error('Error recargando datos del perfil:', error);
        throw error;
    }
}

// Funciones auxiliares para formularios modales de edición
function populatePersonalInfoForm(personalInfo) {
    if (!personalInfo) return;

    const form = document.getElementById('personal-info-form');
    if (!form) return;

    form.firstName.value = personalInfo.first_name || '';
    form.lastName.value = personalInfo.last_name || '';
    form.dateOfBirth.value = personalInfo.date_of_birth ? personalInfo.date_of_birth.split('T')[0] : '';
}

// Funciones auxiliares para formateo y textos
function formatDate(dateString) {
    if (!dateString) return 'Fecha no disponible';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function formatPhoneNumber(phoneNumber) {
    if (!phoneNumber) return 'No disponible';
    // Formatear número mexicano: +52 XX XXXX XXXX
    const cleaned = phoneNumber.replace(/\D/g, '');
    if (cleaned.length === 10) {
        return `+52 ${cleaned.slice(0, 2)} ${cleaned.slice(2, 6)} ${cleaned.slice(6)}`;
    }
    return phoneNumber;
}

function getEmailTypeText(type) {
    const types = {
        'primary': 'Principal',
        'secondary': 'Secundario',
        'work': 'Trabajo',
        'personal': 'Personal'
    };
    return types[type] || type || 'No especificado';
}

function getPhoneTypeText(type) {
    const types = {
        'primary': 'Principal',
        'secondary': 'Secundario',
        'home': 'Casa',
        'work': 'Trabajo',
        'emergency': 'Emergencia'
    };
    return types[type] || type || 'No especificado';
}

function getAddressTypeText(type) {
    const types = {
        'primary': 'Principal',
        'secondary': 'Secundaria',
        'work': 'Trabajo',
        'home': 'Casa'
    };
    return types[type] || type || 'No especificado';
}

function showLoading(elementId, message = 'Cargando...') {
    const element = document.getElementById(elementId);
    if (element) {
        element.innerHTML = `<p class="text-muted"><i class="fas fa-spinner fa-spin me-2"></i>${message}</p>`;
    }
}

function showErrorMessage(message) {
    // Crear notificación de error mejorada
    console.error('Error:', message);

    // Crear elemento de notificación temporal
    const notification = document.createElement('div');
    notification.className = 'alert alert-danger alert-dismissible fade show position-fixed';
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    notification.innerHTML = `
        <i class="fas fa-exclamation-triangle me-2"></i>
        <strong>Error:</strong> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;

    document.body.appendChild(notification);

    // Auto-remover después de 5 segundos
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

function showSuccessMessage(message) {
    // Crear notificación de éxito
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

    // Auto-remover después de 3 segundos
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 3000);
}

// Funciones globales para los botones de editar/eliminar
window.editEmail = function(id) {
    console.log('Editar email:', id);
    // TODO: Implementar edición
};

window.deleteEmail = function(id) {
    if (confirm('¿Estás seguro de que quieres eliminar este email?')) {
        console.log('Eliminar email:', id);
        // TODO: Implementar eliminación
    }
};

window.setPrimaryEmail = function(id) {
    console.log('Establecer email principal:', id);
    // TODO: Implementar cambio de principal
};

window.editPhone = function(id) {
    console.log('Editar teléfono:', id);
    // TODO: Implementar edición
};

window.deletePhone = function(id) {
    if (confirm('¿Estás seguro de que quieres eliminar este teléfono?')) {
        console.log('Eliminar teléfono:', id);
        // TODO: Implementar eliminación
    }
};

window.setPrimaryPhone = function(id) {
    console.log('Establecer teléfono principal:', id);
    // TODO: Implementar cambio de principal
};

window.editAddress = function(id) {
    console.log('Editar dirección:', id);
    // TODO: Implementar edición
};

window.deleteAddress = function(id) {
    if (confirm('¿Estás seguro de que quieres eliminar esta dirección?')) {
        console.log('Eliminar dirección:', id);
        // TODO: Implementar eliminación
    }
};

window.setPrimaryAddress = function(id) {
    console.log('Establecer dirección principal:', id);
    // TODO: Implementar cambio de principal
};

// Exponer funciones globales si es necesario
window.PatientModule = {
    initDashboardPage,
    initMedicalRecordPage,
    initCareTeamPage,
    initProfilePage
};