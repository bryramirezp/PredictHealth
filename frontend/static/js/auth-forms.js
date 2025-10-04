// /frontend\static\js\auth-forms.js
// /frontend/static/js/auth-forms.js
// Helper para integrar AuthManager con formularios de login

class AuthFormsHandler {
    constructor() {
        this.authManager = window.AuthManager;
        this.init();
    }
    
    init() {
        /** Inicializar el manejador de formularios */
        try {
            this.setupLoginForms();
            this.setupLogoutButtons();
            this.setupAuthEvents();
            
            console.log('📝 AuthFormsHandler inicializado');
            
        } catch (error) {
            console.error('❌ Error inicializando AuthFormsHandler:', error);
        }
    }
    
    setupLoginForms() {
        /** Configurar formularios de login */
        try {
            // Formulario de login de pacientes
            const patientLoginForm = document.getElementById('loginForm');
            if (patientLoginForm) {
                patientLoginForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    this.handleLogin(e.target, 'patient');
                });
            }
            
            // Formulario de login de doctores
            const doctorLoginForm = document.getElementById('doctorLoginForm');
            if (doctorLoginForm) {
                doctorLoginForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    this.handleLogin(e.target, 'doctor');
                });
            }
            
            // Formulario de login de instituciones
            const institutionLoginForm = document.getElementById('institutionLoginForm');
            if (institutionLoginForm) {
                institutionLoginForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    this.handleLogin(e.target, 'institution');
                });
            }
            
            console.log('✅ Formularios de login configurados');
            
        } catch (error) {
            console.error('❌ Error configurando formularios:', error);
        }
    }
    
    setupLogoutButtons() {
        /** Configurar botones de logout */
        try {
            const logoutButtons = document.querySelectorAll('[data-action="logout"]');
            
            logoutButtons.forEach(button => {
                button.addEventListener('click', (e) => {
                    e.preventDefault();
                    this.handleLogout();
                });
            });
            
            console.log(`✅ ${logoutButtons.length} botones de logout configurados`);
            
        } catch (error) {
            console.error('❌ Error configurando botones de logout:', error);
        }
    }
    
    setupAuthEvents() {
        /** Configurar eventos de autenticación */
        try {
            // Escuchar eventos de autenticación
            window.addEventListener('auth', (event) => {
                this.handleAuthEvent(event.detail);
            });
            
            // Verificar estado de autenticación al cargar la página
            this.checkAuthStatus();
            
            console.log('✅ Eventos de autenticación configurados');
            
        } catch (error) {
            console.error('❌ Error configurando eventos:', error);
        }
    }
    
    async handleLogin(form, userType) {
        /** Manejar login desde formulario */
        try {
            const formData = new FormData(form);
            const email = formData.get('email');
            const password = formData.get('password');
            
            if (!email || !password) {
                this.showError('Por favor, completa todos los campos');
                return;
            }
            
            // Mostrar estado de carga
            this.showLoading(form);
            
            // Intentar login
            const result = await this.authManager.login(email, password, userType);
            
            if (result.success) {
                this.showSuccess('Login exitoso');
                
                // Redirigir después de un breve delay
                setTimeout(() => {
                    window.location.href = result.redirect;
                }, 1000);
                
            } else {
                this.showError(result.error || 'Error en el login');
            }
            
        } catch (error) {
            console.error('❌ Error en login:', error);
            this.showError('Error inesperado durante el login');
            
        } finally {
            this.hideLoading(form);
        }
    }
    
    async handleLogout() {
        /** Manejar logout */
        try {
            // Mostrar confirmación
            if (!confirm('¿Estás seguro de que quieres cerrar sesión?')) {
                return;
            }
            
            // Mostrar estado de carga
            this.showLogoutLoading();
            
            // Intentar logout
            const result = await this.authManager.logout();
            
            if (result.success) {
                this.showSuccess('Sesión cerrada exitosamente');
                
                // Redirigir a login
                setTimeout(() => {
                    window.location.href = '/patient_login.html';
                }, 1000);
                
            } else {
                this.showError('Error al cerrar sesión');
            }
            
        } catch (error) {
            console.error('❌ Error en logout:', error);
            this.showError('Error inesperado durante el logout');
            
        } finally {
            this.hideLogoutLoading();
        }
    }
    
    handleAuthEvent(eventDetail) {
        /** Manejar eventos de autenticación */
        try {
            const { type, data, user, isAuthenticated } = eventDetail;
            
            switch (type) {
                case 'login':
                    this.updateUIAfterLogin(user, isAuthenticated);
                    break;
                    
                case 'logout':
                    this.updateUIAfterLogout();
                    break;
                    
                case 'token_expired':
                    this.handleTokenExpired();
                    break;
                    
                default:
                    console.log('Evento de autenticación:', type, data);
            }
            
        } catch (error) {
            console.error('❌ Error manejando evento de autenticación:', error);
        }
    }
    
    checkAuthStatus() {
        /** Verificar estado de autenticación al cargar la página */
        try {
            if (this.authManager.isLoggedIn()) {
                this.updateUIAfterLogin(this.authManager.getCurrentUser(), true);
            } else {
                this.updateUIAfterLogout();
            }
            
        } catch (error) {
            console.error('❌ Error verificando estado de autenticación:', error);
        }
    }
    
    updateUIAfterLogin(user, isAuthenticated) {
        /** Actualizar UI después del login */
        try {
            // Mostrar información del usuario
            const userInfoElements = document.querySelectorAll('[data-user-info]');
            userInfoElements.forEach(element => {
                const infoType = element.getAttribute('data-user-info');
                switch (infoType) {
                    case 'name':
                        element.textContent = user?.full_name || user?.email || 'Usuario';
                        break;
                    case 'email':
                        element.textContent = user?.email || '';
                        break;
                    case 'type':
                        element.textContent = this.getUserTypeLabel(user?.roles?.[0]);
                        break;
                }
            });
            
            // Mostrar/ocultar elementos según autenticación
            const authElements = document.querySelectorAll('[data-auth="required"]');
            authElements.forEach(element => {
                element.style.display = isAuthenticated ? 'block' : 'none';
            });
            
            const guestElements = document.querySelectorAll('[data-auth="guest"]');
            guestElements.forEach(element => {
                element.style.display = isAuthenticated ? 'none' : 'block';
            });
            
            // Actualizar navegación
            this.updateNavigation(user?.roles?.[0]);
            
        } catch (error) {
            console.error('❌ Error actualizando UI después del login:', error);
        }
    }
    
    updateUIAfterLogout() {
        /** Actualizar UI después del logout */
        try {
            // Limpiar información del usuario
            const userInfoElements = document.querySelectorAll('[data-user-info]');
            userInfoElements.forEach(element => {
                element.textContent = '';
            });
            
            // Mostrar/ocultar elementos según autenticación
            const authElements = document.querySelectorAll('[data-auth="required"]');
            authElements.forEach(element => {
                element.style.display = 'none';
            });
            
            const guestElements = document.querySelectorAll('[data-auth="guest"]');
            guestElements.forEach(element => {
                element.style.display = 'block';
            });
            
            // Actualizar navegación
            this.updateNavigation(null);
            
        } catch (error) {
            console.error('❌ Error actualizando UI después del logout:', error);
        }
    }
    
    updateNavigation(userType) {
        /** Actualizar navegación según tipo de usuario */
        try {
            // Ocultar todos los elementos de navegación específicos
            const navElements = document.querySelectorAll('[data-nav]');
            navElements.forEach(element => {
                element.style.display = 'none';
            });
            
            // Mostrar elementos según tipo de usuario
            if (userType) {
                const userNavElements = document.querySelectorAll(`[data-nav="${userType}"]`);
                userNavElements.forEach(element => {
                    element.style.display = 'block';
                });
            }
            
        } catch (error) {
            console.error('❌ Error actualizando navegación:', error);
        }
    }
    
    handleTokenExpired() {
        /* Manejar token expirado */
        try {
            this.showError('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.');
            
            // Redirigir a login después de un delay
            setTimeout(() => {
                window.location.href = '/patient_login.html';
            }, 3000);
            
        } catch (error) {
            console.error('❌ Error manejando token expirado:', error);
        }
    }
    
    // === UTILIDADES DE UI ===
    
    showLoading(form) {
        /* Mostrar estado de carga en formulario */
        try {
            const submitButton = form.querySelector('button[type="submit"]');
            if (submitButton) {
                submitButton.disabled = true;
                submitButton.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Cargando...';
            }
            
        } catch (error) {
            console.error('❌ Error mostrando loading:', error);
        }
    }
    
    hideLoading(form) {
        /* Ocultar estado de carga en formulario */
        try {
            const submitButton = form.querySelector('button[type="submit"]');
            if (submitButton) {
                submitButton.disabled = false;
                submitButton.innerHTML = submitButton.getAttribute('data-original-text') || 'Iniciar Sesión';
            }
            
        } catch (error) {
            console.error('❌ Error ocultando loading:', error);
        }
    }
    
    showLogoutLoading() {
        /* Mostrar estado de carga en logout */
        try {
            const logoutButtons = document.querySelectorAll('[data-action="logout"]');
            logoutButtons.forEach(button => {
                button.disabled = true;
                button.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Cerrando...';
            });
            
        } catch (error) {
            console.error('❌ Error mostrando loading de logout:', error);
        }
    }
    
    hideLogoutLoading() {
        /* Ocultar estado de carga en logout */
        try {
            const logoutButtons = document.querySelectorAll('[data-action="logout"]');
            logoutButtons.forEach(button => {
                button.disabled = false;
                button.innerHTML = button.getAttribute('data-original-text') || 'Cerrar Sesión';
            });
            
        } catch (error) {
            console.error('❌ Error ocultando loading de logout:', error);
        }
    }
    
    showError(message) {
        /* Mostrar mensaje de error */
        try {
            this.showAlert(message, 'danger');
            
        } catch (error) {
            console.error('❌ Error mostrando error:', error);
        }
    }
    
    showSuccess(message) {
        /* Mostrar mensaje de éxito */
        try {
            this.showAlert(message, 'success');
            
        } catch (error) {
            console.error('❌ Error mostrando éxito:', error);
        }
    }
    
    showAlert(message, type) {
        /* Mostrar alerta */
        try {
            // Crear elemento de alerta
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
            alertDiv.innerHTML = `
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            
            // Insertar al inicio del contenido principal
            const mainContent = document.querySelector('main') || document.body;
            mainContent.insertBefore(alertDiv, mainContent.firstChild);
            
            // Auto-ocultar después de 5 segundos
            setTimeout(() => {
                if (alertDiv.parentNode) {
                    alertDiv.remove();
                }
            }, 5000);
            
        } catch (error) {
            console.error('❌ Error mostrando alerta:', error);
        }
    }
    
    getUserTypeLabel(userType) {
        /* Obtener etiqueta del tipo de usuario */
        const labels = {
            'patient': 'Paciente',
            'doctor': 'Doctor',
            'institution': 'Institución',
            'admin': 'Administrador'
        };
        
        return labels[userType] || 'Usuario';
    }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.AuthFormsHandler = new AuthFormsHandler();
});

// Exportar para uso en módulos
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AuthFormsHandler;
}
