// /frontend/static/js/profile.js
// Módulo específico para la gestión del perfil del paciente
// Maneja CRUD completo de información personal, emails, teléfonos y direcciones

document.addEventListener('DOMContentLoaded', async () => {
    const Auth = window.AuthManager;
    const API = window.PredictHealthAPI;

    // Verificar autenticación
    const userInfo = await Auth.getUserInfo();
    if (!userInfo || userInfo.user_type !== 'patient') {
        console.warn('Acceso denegado: usuario no es paciente');
        return window.location.href = '/';
    }

    // Solo inicializar si estamos en la página de perfil
    if (window.location.pathname.includes('/patient/profile')) {
        initProfilePage(userInfo, API);
    }
});

// Función principal de inicialización
async function initProfilePage(userInfo, API) {
    console.log("Inicializando perfil del paciente con CRUD completo...");

    try {
        // Cargar datos del perfil
        await loadProfileData(API);

        // Configurar event listeners para formularios
        setupProfileFormListeners(API);

        console.log('Perfil del paciente inicializado correctamente');
    } catch (error) {
        console.error('Error inicializando perfil:', error);
        showErrorMessage('Error al cargar la información del perfil. Por favor, intenta recargar la página.');
    }
}

// Cargar datos del perfil
async function loadProfileData(API) {
    try {
        // Obtener el token JWT y patient_id del usuario autenticado
        const token = await Auth.getToken();
        const patientId = userInfo.reference_id;

        if (!token || !patientId) {
            throw new Error('No se pudo obtener la información de autenticación del paciente');
        }

        const response = await fetch(`/api/web/patients/${patientId}/profile`, {
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

        const profileData = result.data;

        // Renderizar cada sección
        renderPersonalInfo(profileData.personal_info);
        renderEmails(profileData.emails);
        renderPhones(profileData.phones);
        renderAddresses(profileData.addresses);

    } catch (error) {
        console.error('Error cargando datos del perfil:', error);
        throw error;
    }
}

// Renderizar información personal
function renderPersonalInfo(personalInfo) {
    const container = document.getElementById('personal-info-content');
    if (!container) return;

    if (!personalInfo) {
        container.innerHTML = '<p class="text-muted">No hay información personal disponible</p>';
        return;
    }

    // Poblar el formulario del modal con datos existentes
    populatePersonalInfoForm(personalInfo);

    // Mostrar datos en la vista
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
}

// Renderizar lista de emails
function renderEmails(emails) {
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

// Renderizar lista de teléfonos
function renderPhones(phones) {
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

// Renderizar lista de direcciones
function renderAddresses(addresses) {
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

// Poblar formularios con datos existentes
function populatePersonalInfoForm(personalInfo) {
    if (!personalInfo) return;

    const form = document.getElementById('personal-info-form');
    if (!form) return;

    form.firstName.value = personalInfo.first_name || '';
    form.lastName.value = personalInfo.last_name || '';
    form.dateOfBirth.value = personalInfo.date_of_birth ? personalInfo.date_of_birth.split('T')[0] : '';
}

// Configurar event listeners para formularios
function setupProfileFormListeners(API) {
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

// Manejadores de envío de formularios
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

// Funciones auxiliares
function formatDate(dateString) {
    if (!dateString) return null;
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