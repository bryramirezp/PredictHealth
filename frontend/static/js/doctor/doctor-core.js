// /frontend/static/js/doctor-core.js

/**
 * PredictHealth Doctor Core Utilities
 * Funciones, constantes y helpers compartidos para todos los módulos de doctores.
 * Análogo a patient-core.js pero para la lógica del doctor.
 */

const DoctorCore = {
    // === CONSTANTES DE ENDPOINTS (para service-doctors) ===
    ENDPOINTS: {
        DASHBOARD: () => `/api/v1/doctors/me/dashboard`,
        MY_PROFILE: () => `/api/v1/doctors/me/profile`,
        MY_INSTITUTION: () => `/api/v1/doctors/me/institution`,
        MY_PATIENTS: () => `/api/v1/doctors/me/patients`,
        PATIENT_MEDICAL_RECORD: (patientId) => `/api/v1/doctors/me/patients/${patientId}/medical-record`,
        // Endpoints de Admin (si fueran necesarios)
        // LIST_ALL_DOCTORS: () => `/api/v1/doctors`,
        // GET_DOCTOR_BY_ID: (doctorId) => `/api/v1/doctors/${doctorId}`,
    },

    // === UTILIDADES DE AUTENTICACIÓN ===
    /**
     * Verifica si el usuario está autenticado como doctor.
     * Si no, redirige al login. Si sí, devuelve la información del usuario.
     * @returns {Promise<object|null>} La información del usuario o null si no está autenticado.
     */
    async checkAuth() {
        try {
            // Reutiliza AuthManager, que ya está cargado globalmente
            const userInfo = await window.AuthManager.getUserInfo();
            if (!userInfo || userInfo.user_type !== 'doctor') {
                console.warn('Acceso denegado: usuario no es doctor. Redirigiendo...');
                window.location.href = '/'; // Redirigir al login principal
                return null;
            }
            return userInfo;
        } catch (error) {
            console.error('Error crítico verificando autenticación:', error);
            window.location.href = '/';
            return null;
        }
    },

    /**
     * Obtiene la información actual del usuario autenticado (doctor).
     * @returns {Promise<object|null>} La información del usuario o null.
     */
    async getCurrentUserInfo() {
        try {
            return await window.AuthManager.getUserInfo();
        } catch (error) {
            console.error('Error obteniendo información del usuario:', error);
            return null;
        }
    },

    /**
     * Obtiene el ID del doctor del payload del token.
     * @param {object} userInfo - La información del usuario (del token).
     * @returns {string|null} El ID del doctor (reference_id) o null.
     */
    getDoctorId(userInfo) {
        if (!userInfo) return null;
        
        // En nuestra arquitectura, el ID de la entidad está en reference_id
        if (userInfo.reference_id) {
            console.log('Using reference_id (Doctor ID):', userInfo.reference_id);
            return userInfo.reference_id;
        }
        
        // Fallback por si acaso
        if (userInfo.user_id) {
            console.log('Using user_id (Doctor ID):', userInfo.user_id);
            return userInfo.user_id;
        }

        console.warn('No Doctor ID (reference_id) found in userInfo:', userInfo);
        return null;
    },

    // === UTILIDADES DE API ===
    /**
     * Helper centralizado para todas las llamadas API de la sección de doctores.
     * Usa 'credentials: 'include'' para la autenticación por cookies.
     */
    async apiRequest(url, options = {}) {
        const finalOptions = {
            method: options.method || 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                ...(options.headers || {})
            },
            credentials: 'include' 
        };

        if (options.body && typeof options.body !== 'string') {
            finalOptions.body = JSON.stringify(options.body);
        }

        try {
            const response = await fetch(url, finalOptions);

            if (response.status === 401) {
                console.error('No autorizado (401). Redirigiendo al login.');
                window.location.href = '/';
                throw new Error('No autorizado (401)');
            }

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                const errorMessage = errorData.detail || errorData.message || `Error de API: ${response.status} ${response.statusText}`;
                throw new Error(errorMessage); 
            }

            if (response.status === 204) {
                return null;
            }

            return response.json();

        } catch (error) {
            console.error(`Fallo en apiRequest para: ${url}`, error);
            this.showErrorMessage(error.message || 'Error de conexión con el servidor'); 
            throw error; 
        }
    },

    // === UTILIDADES DE UI ===
    /**
     * Muestra un indicador de carga en un elemento del DOM.
     */
    showLoading(elementId, message = 'Cargando...') {
        const element = document.getElementById(elementId);
        if (element) {
            element.innerHTML = `
                <div class="d-flex align-items-center text-muted">
                    <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                    <span>${message}</span>
                </div>
            `;
        }
    },

    /**
     * Muestra una notificación de error global.
     */
    showErrorMessage(message) {
        console.error('UI Error:', message);
        this._showNotification(message, 'danger', 'fa-exclamation-triangle');
    },

    /**
     * Muestra una notificación de éxito global.
     */
    showSuccessMessage(message) {
        console.log('UI Success:', message);
        this._showNotification(message, 'success', 'fa-check-circle');
    },
    
    /**
     * Helper interno para crear notificaciones.
     * @private
     */
    _showNotification(message, type, icon) {
        const notification = document.createElement('div');
        notification.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
        notification.style.cssText = 'top: 20px; right: 20px; z-index: 1050;';
        notification.setAttribute('role', 'alert');
        notification.innerHTML = `
            <i class="fas ${icon} me-2"></i>
            <strong>${type === 'danger' ? 'Error' : 'Éxito'}:</strong> ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        `;
        document.body.appendChild(notification);

        setTimeout(() => {
            const bsAlert = bootstrap.Alert.getOrCreateInstance(notification);
            if (bsAlert) bsAlert.close();
            else notification.remove();
        }, 5000);
    },

    // === UTILIDADES DE FORMATEO ===
    /**
     * Formatea una cadena de fecha (ej. "2025-11-05") a un formato legible.
     */
    formatDate(dateString) {
        if (!dateString) return 'Fecha no disponible';
        try {
            const date = new Date(dateString + 'T00:00:00');
            return date.toLocaleDateString('es-ES', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        } catch (e) {
            return 'Fecha inválida';
        }
    }
};

// Exponer el objeto DoctorCore globalmente
window.DoctorCore = DoctorCore;