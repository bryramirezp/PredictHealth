// /frontend\static\js\auth-manager.js
// /frontend/static/js/auth-manager.js
// Reemplazar TODA la clase AuthManager

class SessionAuthManager {
    constructor() {
        this.baseURL = window.location.origin;
        this.apiURL = `${this.baseURL}/api/web/auth`;
        this.isAuthenticated = false;
        this.currentUser = null;

        this.init();
    }

    async init() {
        await this.validateSession();
    }

    async login(email, password, userType = 'patient') {
        try {
            const response = await fetch(`${this.apiURL}/login`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                credentials: 'include', // IMPORTANTE
                body: JSON.stringify({email, password, user_type: userType})
            });

            if (response.ok) {
                const data = await response.json();
                this.isAuthenticated = true;
                this.currentUser = data.user;
                console.log('✅ Login exitoso con sesión server-side');
                return {success: true, user: data.user};
            } else {
                const error = await response.json();
                return {success: false, error: error.message || 'Error de login'};
            }
        } catch (error) {
            console.error('❌ Error en login:', error);
            return {success: false, error: 'Error de conexión'};
        }
    }

    async validateSession() {
        try {
            const response = await fetch(`${this.apiURL}/session/validate`, {
                credentials: 'include'
            });

            if (response.ok) {
                const data = await response.json();
                this.isAuthenticated = true;
                this.currentUser = data.user;
                console.log('✅ Sesión válida');
                return true;
            }
        } catch (error) {
            console.error('❌ Error validando sesión:', error);
        }

        this.isAuthenticated = false;
        this.currentUser = null;
        return false;
    }

    async logout() {
        try {
            await fetch(`${this.apiURL}/logout`, {
                method: 'POST',
                credentials: 'include'
            });
        } catch (error) {
            console.warn('⚠️ Error en logout del servidor:', error);
        }

        this.isAuthenticated = false;
        this.currentUser = null;
        window.location.href = '/';
    }

    setupHTTPInterceptors() {
        const originalFetch = window.fetch;

        window.fetch = async (url, options = {}) => {
            options.credentials = 'include'; // Incluir cookies automáticamente

            try {
                const response = await originalFetch(url, options);

                if (response.status === 401 && this.isAuthenticated) {
                    console.warn('⚠️ Sesión expirada, redirigiendo...');
                    this.handleSessionExpired();
                }

                return response;
            } catch (error) {
                console.error('❌ Error en request HTTP:', error);
                throw error;
            }
        };
    }

    handleSessionExpired() {
        this.isAuthenticated = false;
        this.currentUser = null;
        window.location.href = '/';
    }

    // Métodos públicos
    async getUserInfo() {
        await this.validateSession();
        return this.currentUser;
    }
    async isLoggedIn() {
        // Siempre validar con el servidor, no depender del estado local
        return await this.validateSession();
    }
    getUserType() { return this.currentUser?.user_type; }
}

// Reemplazar instancia global
window.AuthManager = new SessionAuthManager();
window.authManager = window.AuthManager; // Compatibilidad
