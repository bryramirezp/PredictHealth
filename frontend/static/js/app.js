// /frontend/static/js/app.js
// Versión 2.0 - Librería de cliente API para PredictHealth

/**
 * PredictHealthAPI v2.0
 * Módulo centralizado para interactuar con el backend de PredictHealth.
 * Utiliza autenticación basada en sesión (cookies).
 * 
 * Estructura:
 * - _request: Helper interno para todas las llamadas fetch.
 * - auth: Métodos para login, logout y obtener la sesión actual.
 * - patients: Métodos para el CRUD de pacientes y sus datos de salud.
 * - doctors: Métodos para la gestión de perfiles de doctores y sus pacientes.
 * - institutions: Métodos para la gestión de instituciones, incluyendo sus doctores y pacientes.
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
                // Manejar específicamente errores de autenticación
                if (response.status === 401) {
                    // Redirigir al login si hay 401
                    window.location.href = '/login';
                    return;
                }
                
                const errorData = await response.json().catch(() => ({ error: 'Error desconocido', message: response.statusText }));
                throw new Error(errorData.message || errorData.error);
            }

            // DELETE puede no devolver contenido
            if (response.status === 204) {
                return null;
            }
            
            const data = await response.json();
            
            // Verificar si la respuesta tiene el formato esperado
            if (data.status === 'error') {
                throw new Error(data.message || 'Error en la petición');
            }
            
            return data;
        } catch (error) {
            console.error(`API Error (${method} ${endpoint}):`, error);
            throw error; // Re-lanzar para que el llamador pueda manejarlo
        }
    },

    // --- MÓDULO DE AUTENTICACIÓN ---
    auth: {
        /**
         * Inicia sesión para un tipo de usuario específico.
         * @param {string} email
         * @param {string} password
         * @param {string} userType - 'patient', 'doctor', o 'institution'
         */
        login: function(email, password, userType) {
            // Usar endpoints del backend real /api/web/auth/{userType}/login
            const endpoint = `/api/web/auth/${userType}/login`;
            return PredictHealthAPI._request(endpoint, 'POST', { email, password });
        },

        /** Cierra la sesión del usuario actual. */
        logout: function() {
            return PredictHealthAPI._request('/api/web/auth/logout', 'POST');
        },

        /** Obtiene los datos del usuario de la sesión actual. */
        getCurrentUser: function() {
            // Usar endpoint del backend real
            return PredictHealthAPI._request('/api/web/auth/session/validate', 'GET');
        }
    },

    // --- MÓDULO DE PACIENTES ---
    patients: {
        /** Obtiene la vista 360° de un paciente específico. */
        getDetails: function(patientId) {
            // Usar endpoint del backend real
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}`);
        },
        /** Actualiza los datos de un paciente. */
        update: function(patientId, data) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}`, 'PUT', data);
        },
        /** Añade una condición médica a un paciente. */
        addCondition: function(patientId, conditionData) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}/conditions`, 'POST', conditionData);
        },
         /** Elimina una condición médica de un paciente. */
        removeCondition: function(patientId, conditionId) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}/conditions/${conditionId}`, 'DELETE');
        }
        // ... (Se pueden añadir funciones para 'medications' y 'allergies' siguiendo el mismo patrón)
    },

    // --- MÓDULO DE DOCTORES ---
    doctors: {
        /** Obtiene el perfil del doctor autenticado. */
        getProfile: function() {
            // Usar endpoint del backend real
            return PredictHealthAPI._request('/api/web/doctor/dashboard');
        },
        /** Actualiza el perfil del doctor autenticado. */
        updateProfile: function(data) {
            return PredictHealthAPI._request('/api/v1/doctors/profile', 'PUT', data);
        },
        /** Obtiene la institución del doctor autenticado. */
        getInstitution: function() {
            // Usar el dashboard
            return PredictHealthAPI._request('/api/web/doctor/dashboard');
        },
        /** Lista los pacientes asignados al doctor autenticado. */
        listMyPatients: function() {
            // Usar endpoint del backend real
            return PredictHealthAPI._request('/api/v1/doctors/patients');
        },
        /** Crea un nuevo paciente para el doctor autenticado. */
        createPatient: function(patientData) {
            return PredictHealthAPI._request('/api/v1/patients', 'POST', patientData);
        },
        /** Obtiene detalles de un paciente específico del doctor. */
        getPatientDetails: function(patientId) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}`);
        }
    },

    // --- MÓDULO DE INSTITUCIONES ---
    institutions: {
        /** Obtiene los detalles de una institución. */
        getDetails: function(institutionId) {
            // Usar endpoint del backend real
            return PredictHealthAPI._request('/api/web/institution/dashboard');
        },
        /** Obtiene las analíticas/KPIs de una institución. */
        getAnalytics: function(institutionId) {
            // Usar el dashboard
            return PredictHealthAPI._request('/api/web/institution/dashboard');
        },
        /** Lista los doctores de una institución. */
        listDoctors: function(institutionId) {
            // Usar endpoint del backend real
            return PredictHealthAPI._request('/api/web/institution/doctors');
        },
        /** Crea un doctor en una institución. */
        createDoctor: function(institutionId, doctorData) {
            return PredictHealthAPI._request('/api/web/institution/doctors', 'POST', doctorData);
        },
        /** Lista los pacientes de una institución. */
        listPatients: function(institutionId) {
            // Usar endpoint del backend real
            return PredictHealthAPI._request('/api/web/institution/patients');
        },
        /** Obtiene los detalles de un paciente de una institución. */
        getPatientDetails: function(institutionId, patientId) {
            return PredictHealthAPI._request(`/api/v1/patients/${patientId}`);
        }
    }
};


// --- LÓGICA DE LA APLICACIÓN AL CARGAR LA PÁGINA ---

document.addEventListener('DOMContentLoaded', () => {
    
    // Función principal para inicializar la página
    async function initializeApp() {
        try {
            // 1. Verificar quién es el usuario actual
            const userSession = await PredictHealthAPI.auth.getCurrentUser();
            console.log('Sesión activa para:', userSession);

            // 2. Cargar la UI y los datos según el rol del usuario
            switch (userSession.user_type) {
                case 'patient':
                    loadPatientDashboard(userSession.reference_id);
                    break;
                case 'doctor':
                    loadDoctorDashboard(userSession.reference_id);
                    break;
                case 'institution':
                    loadInstitutionDashboard(userSession.reference_id);
                    break;
                default:
                    console.error('Tipo de usuario desconocido:', userSession.user_type);
                    // Mostrar una vista de error o redirigir al login
            }

        } catch (error) {
            console.warn('No hay sesión activa o ha expirado. Redirigiendo al login...');
            // Si falla obtener la sesión, es probable que no esté logueado
            // window.location.href = '/login.html';
        }
    }

    // --- Funciones para cargar Dashboards específicos por rol ---

    async function loadPatientDashboard(patientId) {
        console.log(`Cargando dashboard para paciente ${patientId}`);
        // Ocultar secciones de otros roles
        document.getElementById('doctor-section')?.classList.add('d-none');
        document.getElementById('institution-section')?.classList.add('d-none');

        try {
            const patientData = await PredictHealthAPI.patients.getDetails(patientId);
            // Lógica para poblar el DOM con los datos del paciente
            // Ejemplo: document.getElementById('welcome-message').textContent = `Bienvenido, ${patientData.first_name}`;
            console.log('Datos del paciente:', patientData);
        } catch (error) {
            console.error('Error al cargar el dashboard del paciente:', error);
        }
    }

    async function loadDoctorDashboard(doctorId) {
        console.log(`Cargando dashboard para doctor ${doctorId}`);
        document.getElementById('patient-section')?.classList.add('d-none');
        document.getElementById('institution-section')?.classList.add('d-none');

        try {
            const [profile, myPatients, institution] = await Promise.all([
                PredictHealthAPI.doctors.getProfile(),
                PredictHealthAPI.doctors.listMyPatients(),
                PredictHealthAPI.doctors.getInstitution()
            ]);

            // Lógica para poblar el DOM con los datos del doctor
            // Ejemplo: document.getElementById('welcome-message').textContent = `Bienvenido, Dr. ${profile.last_name}`;
            // Ejemplo: poblar una tabla con la lista de `myPatients`
            console.log('Perfil del doctor:', profile);
            console.log('Pacientes del doctor:', myPatients);
            console.log('Institución del doctor:', institution);
        } catch (error) {
            console.error('Error al cargar el dashboard del doctor:', error);
        }
    }

    async function loadInstitutionDashboard(institutionId) {
        console.log(`Cargando dashboard para institución ${institutionId}`);
        document.getElementById('patient-section')?.classList.add('d-none');
        document.getElementById('doctor-section')?.classList.add('d-none');

        try {
            const [details, doctors, patients, analytics] = await Promise.all([
                PredictHealthAPI.institutions.getDetails(institutionId),
                PredictHealthAPI.institutions.listDoctors(institutionId),
                PredictHealthAPI.institutions.listPatients(institutionId),
                PredictHealthAPI.institutions.getAnalytics(institutionId)
            ]);

            // Lógica para poblar el DOM con los datos de la institución
            // Ejemplo: document.getElementById('welcome-message').textContent = `Panel de Administración: ${details.name}`;
            // Ejemplo: poblar KPIs con los datos de `analytics`
            console.log('Detalles de la institución:', details);
            console.log('Doctores:', doctors);
            console.log('Pacientes:', patients);
            console.log('Analíticas:', analytics);
        } catch (error) {
            console.error('Error al cargar el dashboard de la institución:', error);
        }
    }

    // --- Event Listeners ---

    // Botón de Logout
    const btnLogout = document.getElementById('btnLogout');
    if (btnLogout) {
        btnLogout.addEventListener('click', async () => {
            try {
                await PredictHealthAPI.auth.logout();
                console.log('Logout exitoso.');
                window.location.href = '/login.html';
            } catch (error) {
                console.error('Fallo el logout, pero se redirigirá de todos modos.');
                window.location.href = '/login.html';
            }
        });
    }

    // Iniciar la aplicación
    initializeApp();
});