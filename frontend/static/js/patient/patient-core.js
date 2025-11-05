// /frontend/static/js/patient/patient-core.js
// Utilidades compartidas entre todos los módulos de pacientes
// Funciones comunes, constantes y helpers reutilizables

/**
 * PredictHealth Patient Core Utilities
 * Funciones compartidas para todos los módulos de pacientes
 */

const PatientCore = {
    // === CONSTANTES ===
    ENDPOINTS: {
        DASHBOARD: (patientId) => `/api/web/patients/${patientId}/dashboard`,
        MEDICAL_RECORD: (patientId) => `/api/web/patients/${patientId}/medical-record`,
        CARE_TEAM: (patientId) => `/api/web/patients/${patientId}/care-team`,
        PROFILE: (patientId) => `/api/web/patients/${patientId}/profile`,
        HEALTH_PROFILE: (patientId) => `/api/web/patients/${patientId}/health-profile`,
        CONDITIONS: (patientId) => `/api/web/patients/${patientId}/conditions`,
        MEDICATIONS: (patientId) => `/api/web/patients/${patientId}/medications`,
        ALLERGIES: (patientId) => `/api/web/patients/${patientId}/allergies`,
        FAMILY_HISTORY: (patientId) => `/api/web/patients/${patientId}/family-history`,
        PERSONAL_INFO: (patientId) => `/api/web/patients/${patientId}/personal-info`,
        EMAILS: (patientId) => `/api/web/patients/${patientId}/emails`,
        PHONES: (patientId) => `/api/web/patients/${patientId}/phones`,
        ADDRESSES: (patientId) => `/api/web/patients/${patientId}/addresses`
    },

    // === UTILIDADES DE AUTENTICACIÓN ===
    /**
     * Verifica autenticación del paciente
     */
    async checkAuth() {
        try {
            const userInfo = await window.AuthManager.getUserInfo();
            if (!userInfo || userInfo.user_type !== 'patient') {
                console.warn('Acceso denegado: usuario no es paciente');
                window.location.href = '/';
                return null;
            }
            return userInfo;
        } catch (error) {
            console.error('Error verificando autenticación:', error);
            window.location.href = '/';
            return null;
        }
    },

    // === UTILIDADES DE API ===
    /**
     * Helper para llamadas API con manejo de errores y autenticación JWT
     */
    async apiRequest(endpoint, options = {}) {
        try {
            // Obtener token JWT si no está en las opciones
            const token = options.token || await window.AuthManager.getToken();

            const defaultOptions = {
                method: 'GET',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            };

            // Si endpoint es una función, llamarla con patientId
            let finalEndpoint = endpoint;
            if (typeof endpoint === 'function') {
                const userInfo = await window.AuthManager.getUserInfo();
                if (!userInfo || !userInfo.reference_id) {
                    throw new Error('No se pudo obtener la información del paciente');
                }
                finalEndpoint = endpoint(userInfo.reference_id);
            }

            const response = await fetch(finalEndpoint, { ...defaultOptions, ...options });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const result = await response.json();

            if (result.status !== 'success') {
                throw new Error(result.message || 'Error en la respuesta del servidor');
            }

            return result.data;
        } catch (error) {
            console.error(`API Error (${options.method || 'GET'} ${typeof endpoint === 'function' ? 'dynamic endpoint' : endpoint}):`, error);
            throw error;
        }
    },

    // === UTILIDADES DE FORMATEO ===
    /**
     * Formatea fechas para display
     */
    formatDate(dateString) {
        if (!dateString) return 'Fecha no disponible';
        const date = new Date(dateString);
        return date.toLocaleDateString('es-ES', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    },

    /**
     * Formatea números de teléfono
     */
    formatPhoneNumber(phoneNumber) {
        if (!phoneNumber) return 'No disponible';
        // Formatear número mexicano: +52 XX XXXX XXXX
        const cleaned = phoneNumber.replace(/\D/g, '');
        if (cleaned.length === 10) {
            return `+52 ${cleaned.slice(0, 2)} ${cleaned.slice(2, 6)} ${cleaned.slice(6)}`;
        }
        return phoneNumber;
    },

    /**
     * Capitaliza texto
     */
    capitalize(text) {
        if (!text) return '';
        return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();
    },

    // === UTILIDADES DE UI ===
    /**
     * Muestra mensaje de error
     */
    showErrorMessage(message) {
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
    },

    /**
     * Muestra mensaje de éxito
     */
    showSuccessMessage(message) {
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
    },

    /**
     * Muestra mensaje informativo
     */
    showInfoMessage(message) {
        console.log('Info:', message);

        const notification = document.createElement('div');
        notification.className = 'alert alert-info alert-dismissible fade show position-fixed';
        notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
        notification.innerHTML = `
            <i class="fas fa-info-circle me-2"></i>
            <strong>Información:</strong> ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;

        document.body.appendChild(notification);

        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 3000);
    },

    /**
     * Muestra estado de carga en un elemento
     */
    showLoading(elementId, message = 'Cargando...') {
        const element = document.getElementById(elementId);
        if (element) {
            element.innerHTML = `<p class="text-muted"><i class="fas fa-spinner fa-spin me-2"></i>${message}</p>`;
        }
    },

    /**
     * Oculta estado de carga
     */
    hideLoading(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            element.innerHTML = '';
        }
    },

    // === UTILIDADES DE VALIDACIÓN ===
    /**
     * Valida email
     */
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    },

    /**
     * Valida teléfono
     */
    isValidPhone(phone) {
        const phoneRegex = /^\+?[\d\s\-\(\)]{10,}$/;
        return phoneRegex.test(phone.replace(/\s/g, ''));
    },

    // === UTILIDADES DE FORMULARIOS ===
    /**
     * Serializa datos de formulario
     */
    serializeForm(form) {
        const formData = new FormData(form);
        return Object.fromEntries(formData);
    },

    /**
     * Pobla formulario con datos
     */
    populateForm(form, data) {
        Object.keys(data).forEach(key => {
            const input = form.querySelector(`[name="${key}"]`);
            if (input) {
                if (input.type === 'checkbox') {
                    input.checked = data[key];
                } else if (input.type === 'date' && data[key]) {
                    input.value = data[key].split('T')[0];
                } else {
                    input.value = data[key] || '';
                }
            }
        });
    },

    /**
     * Resetea formulario
     */
    resetForm(form) {
        form.reset();
        // Limpiar validaciones de Bootstrap
        const invalidFields = form.querySelectorAll('.is-invalid');
        invalidFields.forEach(field => field.classList.remove('is-invalid'));
        const validFields = form.querySelectorAll('.is-valid');
        validFields.forEach(field => field.classList.remove('is-valid'));
    },

    // === UTILIDADES ESPECÍFICAS DE PACIENTES ===
    /**
     * Obtiene texto de tipo de email
     */
    getEmailTypeText(type) {
        const types = {
            'primary': 'Principal',
            'secondary': 'Secundario',
            'work': 'Trabajo',
            'personal': 'Personal'
        };
        return types[type] || type || 'No especificado';
    },

    /**
     * Obtiene texto de tipo de teléfono
     */
    getPhoneTypeText(type) {
        const types = {
            'primary': 'Principal',
            'secondary': 'Secundario',
            'home': 'Casa',
            'work': 'Trabajo',
            'emergency': 'Emergencia'
        };
        return types[type] || type || 'No especificado';
    },

    /**
     * Obtiene texto de tipo de dirección
     */
    getAddressTypeText(type) {
        const types = {
            'primary': 'Principal',
            'secondary': 'Secundaria',
            'work': 'Trabajo',
            'home': 'Casa'
        };
        return types[type] || type || 'No especificado';
    },

    /**
     * Obtiene texto de severidad de alergia
     */
    getSeverityText(severity) {
        const severityMap = {
            'mild': 'Leve',
            'moderate': 'Moderada',
            'severe': 'Severa'
        };
        return severityMap[severity] || severity || 'No especificada';
    },

    /**
     * Construye dirección completa desde objeto address
     */
    buildFullAddress(address) {
        if (!address) return null;

        const parts = [];
        if (address.street_address) parts.push(address.street_address);
        if (address.neighborhood) parts.push(address.neighborhood);
        if (address.city) parts.push(address.city);
        if (address.region_id) parts.push(address.region_id);
        if (address.country_id) parts.push(address.country_id);
        if (address.postal_code) parts.push(`CP: ${address.postal_code}`);

        return parts.length > 0 ? parts.join(', ') : null;
    },

    /**
     * Construye información de contacto
     */
    buildContactInfo(entity) {
        const contacts = [];

        if (entity.email) {
            contacts.push(`
                <div class="contact-item mb-2">
                    <i class="fas fa-envelope text-primary me-2"></i>
                    <strong>Email:</strong>
                    <a href="mailto:${entity.email}" class="text-decoration-none ms-1">${entity.email}</a>
                </div>
            `);
        }

        if (entity.phone) {
            contacts.push(`
                <div class="contact-item mb-2">
                    <i class="fas fa-phone text-primary me-2"></i>
                    <strong>Teléfono:</strong>
                    <a href="tel:${entity.phone}" class="text-decoration-none ms-1">${entity.phone}</a>
                </div>
            `);
        }

        if (contacts.length === 0) {
            return '<p class="text-muted small">Información de contacto no disponible</p>';
        }

        return contacts.join('');
    }
};

// Exponer globalmente
window.PatientCore = PatientCore;