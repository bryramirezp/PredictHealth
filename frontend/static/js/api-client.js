// /frontend/static/js/api-client.js
// Versión 2.1 - Librería de cliente API (Endpoints de Doctor/Institución actualizados)

/**
 * PredictHealthAPI v2.1
 * Módulo centralizado para interactuar con el backend de PredictHealth.
 * Utiliza autenticación basada en sesión (cookies).
 */
const PredictHealthAPI = {
    // --- HELPER INTERNO ---
    _request: async function(endpoint, method = 'GET', body = null) {
        const options = {
            method,
            headers: {},
            credentials: 'include' // ¡Esencial para la autenticación por sesión!
        };

        if (body) {
            options.headers['Content-Type'] = 'application/json';
            options.body = JSON.stringify(body);
        }

        try {
            const response = await fetch(endpoint, options);

            if (!response.ok) {
                if (response.status === 401) {
                    window.location.href = '/login';
                    return;
                }
                
                const errorData = await response.json().catch(() => ({ error: 'Error desconocido', message: response.statusText }));
                // Capturar el error interno específico del log
                if (errorData.detail && typeof errorData.detail === 'string' && errorData.detail.includes("list index out of range")) {
                     throw new Error('Error interno: list index out of range');
                }
                throw new Error(errorData.detail || errorData.message || errorData.error);
            }

            if (response.status === 204) {
                return null;
            }
            
            const data = await response.json();
            
            if (data.status === 'error') {
                throw new Error(data.message || 'Error en la petición');
            }
            
            return data;
        } catch (error) {
            console.error(`API Error (${method} ${endpoint}):`, error);
            throw error;
        }
    },

    // --- MÓDULO DE AUTENTICACIÓN ---
    auth: {
        login: function(email, password, userType) {
            const endpoint = `/api/web/auth/${userType}/login`;
            return PredictHealthAPI._request(endpoint, 'POST', { email, password });
        },
        logout: function() {
            return PredictHealthAPI._request('/api/web/auth/logout', 'POST');
        },
        getCurrentUser: function() {
            return PredictHealthAPI._request('/api/web/auth/session/validate', 'GET');
        }
    },

    // --- MÓDULO DE PACIENTES (Sin cambios) ---
    patients: {
        getDetails: function(patientId) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}`);
        },
        update: function(patientId, data) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}`, 'PUT', data);
        },
        addCondition: function(patientId, conditionData) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}/conditions`, 'POST', conditionData);
        },
        removeCondition: function(patientId, conditionId) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}/conditions/${conditionId}`, 'DELETE');
        }
    },

    // --- MÓDULO DE DOCTORES (REFACTORIZADO) ---
    doctors: {
        /** Obtiene el perfil del doctor autenticado. */
        getProfile: function() {
            // CORREGIDO: Apunta al endpoint /me de service-doctors
            return PredictHealthAPI._request('/api/v1/doctors/me/profile');
        },
        /** Actualiza el perfil del doctor autenticado. */
        updateProfile: function(data) {
            // CORREGIDO: Apunta al endpoint /me de service-doctors
            return PredictHealthAPI._request('/api/v1/doctors/me/profile', 'PUT', data);
        },
        /** Obtiene la institución del doctor autenticado. */
        getInstitution: function() {
            // CORREGIDO: Apunta al endpoint /me de service-doctors
            return PredictHealthAPI._request('/api/v1/doctors/me/institution');
        },
        /** Lista los pacientes asignados al doctor autenticado. */
        listMyPatients: function() {
            // CORREGIDO: Apunta al endpoint /me de service-doctors
            return PredictHealthAPI._request('/api/v1/doctors/me/patients');
        },
        /** Obtiene el expediente de un paciente específico (vista de doctor). */
        getPatientDetails: function(patientId) {
            // CORREGIDO: Apunta al endpoint /me de service-doctors
            return PredictHealthAPI._request(`/api/v1/doctors/me/patients/${patientId}/medical-record`);
        },
        /** Obtiene los KPIs del dashboard del doctor. */
        getDashboardKPIs: function() {
            // CORREGIDO: Apunta al endpoint /me de service-doctors
            return PredictHealthAPI._request('/api/v1/doctors/me/dashboard');
        }
        // NOTA: createPatient se eliminó de aquí. 
        // La creación de pacientes debe ser una ruta de admin o institución,
        // no una ruta de /doctors.
    },

    // --- MÓDULO DE INSTITUCIONES (REFACTORIZADO) ---
    // (Estos endpoints son ahora para un rol de 'institución')
    institutions: {
        /** Obtiene los detalles de la institución autenticada. */
        getDetails: function() {
            // CORREGIDO: Apunta a una ruta /me de institución (asumiendo que existirá)
            return PredictHealthAPI._request('/api/v1/institutions/me');
        },
        /** Obtiene las analíticas/KPIs de la institución. */
        getAnalytics: function() {
            // CORREGIDO: Apunta a una ruta /me de institución
            return PredictHealthAPI._request('/api/v1/institutions/me/analytics');
        },
        /** Lista los doctores de la institución. */
        listDoctors: function() {
            // CORREGIDO: Apunta a una ruta /me de institución
            return PredictHealthAPI._request('/api/v1/institutions/me/doctors');
        },
        /** Crea un doctor en la institución (ruta de admin de institución). */
        createDoctor: function(doctorData) {
            // CORREGIDO: Apunta a la ruta de admin /api/v1/doctors (que ya creamos)
            return PredictHealthAPI._request('/api/v1/doctors', 'POST', doctorData);
        },
        /** Lista los pacientes de la institución. */
        listPatients: function() {
            // CORREGIDO: Apunta a una ruta /me de institución
            return PredictHealthAPI._request('/api/v1/institutions/me/patients');
        }
    }
};


// --- LÓGICA DE LA APLICACIÓN AL CARGAR LA PÁGINA ---

document.addEventListener('DOMContentLoaded', () => {
    
    // Función principal para inicializar la página
    async function initializeApp() {
        try {
            const userSession = await PredictHealthAPI.auth.getCurrentUser();
            console.log('Sesión activa para:', userSession);

            const userData = userSession.data.user;
            console.log('Datos del usuario:', userData);
            
            // --- INICIO DE LA CORRECCIÓN DE LÓGICA ---
            // Solo ejecutar la lógica de 'initializeApp' si un script 
            // específico de la página (como patient-core.js o doctor-core.js)
            // NO se ha cargado.
            
            if (userData.user_type === 'patient' && !window.PatientCore) {
                // Si eres paciente y patient-core.js no se ha cargado,
                // ejecuta la lógica básica de dashboard de paciente.
                loadPatientDashboard(userData.user_id);
                
            } else if (userData.user_type === 'doctor' && !window.DoctorCore) {
                // Si eres doctor y doctor-core.js no se ha cargado,
                // ejecuta la lógica básica de dashboard de doctor.
                loadDoctorDashboard(userData.user_id);

            } else if (userData.user_type === 'institution' && !window.InstitutionCore) {
                // (Futuro)
                loadInstitutionDashboard(userData.user_id);
            
            } else {
                console.log(`Core JS ('${userData.user_type}-core.js') ya cargado. Dejando que tome el control.`);
            }
            // --- FIN DE LA CORRECCIÓN DE LÓGICA ---

        } catch (error) {
            console.warn('No hay sesión activa o ha expirado.');
            // No redirigir, dejar que auth-forms.js maneje el login
        }
    }

    // --- Funciones para cargar Dashboards (Lógica de Fallback) ---

    async function loadPatientDashboard(patientId) {
        console.log(`Cargando dashboard (fallback) para paciente ${patientId}`);
        try {
            const patientData = await PredictHealthAPI.patients.getDetails(patientId);
            console.log('Datos del paciente (fallback):', patientData);
        } catch (error) {
            console.error('Error al cargar el dashboard del paciente (fallback):', error);
        }
    }

    async function loadDoctorDashboard(doctorId) {
        console.log(`Cargando dashboard (fallback) para doctor ${doctorId}`);
        try {
            // Usar el nuevo endpoint de KPIs del dashboard
            const kpiData = await PredictHealthAPI.doctors.getDashboardKPIs();
            console.log('KPIs del doctor (fallback):', kpiData);
        } catch (error) {
            console.error('Error al cargar el dashboard del doctor (fallback):', error);
        }
    }

    async function loadInstitutionDashboard(institutionId) {
        console.log(`Cargando dashboard (fallback) para institución ${institutionId}`);
        // ... (lógica futura)
    }

    // --- Event Listeners ---
    const btnLogout = document.getElementById('btnLogout');
    if (btnLogout) {
        btnLogout.addEventListener('click', async () => {
            try {
                await PredictHealthAPI.auth.logout();
                console.log('Logout exitoso.');
                window.location.href = '/login'; // Redirigir a la raíz/login
            } catch (error) {
                console.error('Fallo el logout, pero se redirigirá de todos modos.');
                window.location.href = '/login';
            }
        });
    }

    // Iniciar la aplicación
    initializeApp();
});