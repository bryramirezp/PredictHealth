// /frontend/static/js/auth-manager.js (REFACTORIZADO PARA JWT EN COOKIES)

(function(window) {
    'use strict';

    // Claves para las cookies.
    const TOKEN_COOKIE_KEY = 'predicthealth_jwt';
    const USER_INFO_COOKIE_KEY = 'predicthealth_user';

    /**
     * Lee el valor de una cookie específica.
     * @param {string} name - El nombre de la cookie.
     * @returns {string|null} El valor de la cookie o null si no se encuentra.
     */
    function _getCookie(name) {
        const cookieValue = document.cookie.match('(^|;)\\s*' + name + '\\s*=\\s*([^;]+)');
        return cookieValue ? cookieValue.pop() : null;
    }

    /**
     * Establece una cookie de sesión (se borra al cerrar el navegador).
     * @param {string} name - El nombre de la cookie.
     * @param {string} value - El valor de la cookie.
     */
    function _setSessionCookie(name, value) {
        // SameSite=Lax allows cross-origin cookies for localhost development
        // path=/ asegura que la cookie esté disponible en todo el sitio.
        document.cookie = `${name}=${value}; path=/; SameSite=Lax`;
    }

    /**
     * Elimina una cookie estableciendo su fecha de expiración en el pasado.
     * @param {string} name - El nombre de la cookie a eliminar.
     */
    function _deleteCookie(name) {
        document.cookie = `${name}=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Lax`;
    }

    /**
     * Decodifica el payload de un token JWT (sin verificar firma).
     * @param {string} token - El token JWT.
     * @returns {Object|null} El payload decodificado.
     */
    function _decodeToken(token) {
        try {
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join(''));
            return JSON.parse(jsonPayload);
        } catch (e) {
            console.error("Error decodificando el token:", e);
            return null;
        }
    }

    const AuthManager = {
        /**
         * Gestiona el inicio de sesión del usuario.
         * Si tiene éxito, almacena el token JWT y los datos del usuario en cookies de sesión.
         */
        async login(email, password, userType = 'patient') {
            this.logout(false); // Limpiar sesión anterior sin redirigir

            try {
                const response = await fetch(`/api/web/auth/${userType}/login`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, password })
                });

                const data = await response.json();

                if (!response.ok) {
                    throw new Error(data.detail || 'Error en el inicio de sesión.');
                }

                if (data.access_token && data.user) {
                    _setSessionCookie(TOKEN_COOKIE_KEY, data.access_token);
                    _setSessionCookie(USER_INFO_COOKIE_KEY, JSON.stringify(data.user)); // Almacenamos como string JSON
                    return data.user;
                } else {
                    throw new Error('Respuesta de login inválida desde el servidor.');
                }
            } catch (error) {
                console.error('Error en AuthManager.login:', error);
                this.logout(false); // Asegurarse de que todo esté limpio si el login falla
                throw error;
            }
        },

        /**
         * Cierra la sesión del usuario eliminando las cookies de sesión.
         */
        logout(redirect = true) {
            fetch('/api/web/auth/logout', { method: 'POST' }).catch(err => console.warn("No se pudo notificar el logout al servidor:", err));
            
            // La acción principal es eliminar las cookies del cliente.
            _deleteCookie(TOKEN_COOKIE_KEY);
            _deleteCookie(USER_INFO_COOKIE_KEY);

            if (redirect) {
                window.location.href = '/';
            }
        },

        /**
         * Obtiene el token JWT desde la cookie.
         */
        getToken() {
            return _getCookie(TOKEN_COOKIE_KEY);
        },

        /**
         * Obtiene la información del usuario.
         * Primero intenta desde cookies, luego desde datos del template (JINJA2),
         * finalmente desde api-client si está disponible.
         * Es síncrono y rápido, sin llamadas de red.
         */
        getUserInfo() {
            try {
                // 1. Intentar desde cookies de sesión (método original)
                const userInfoString = _getCookie(USER_INFO_COOKIE_KEY);
                if (userInfoString) {
                    const userInfo = JSON.parse(userInfoString);
                    if (userInfo && typeof userInfo === 'object') {
                        console.log('📝 Usuario desde cookies:', userInfo);
                        return userInfo;
                    }
                }

                // 2. Fallback: usar datos del template JINJA2 (desde base.html)
                if (window.PatientUserData) {
                    console.log('📝 Usuario desde template JINJA2:', window.PatientUserData);
                    return window.PatientUserData;
                }

                // 3. Último fallback: verificar si PredictHealthAPI tiene datos
                if (window.PredictHealthAPI && window.PredictHealthAPI.getUserInfo) {
                    const apiUserInfo = window.PredictHealthAPI.getUserInfo();
                    if (apiUserInfo) {
                        console.log('📝 Usuario desde api-client:', apiUserInfo);
                        return apiUserInfo;
                    }
                }

                console.warn('⚠️ No se pudo obtener información del usuario desde ninguna fuente');
                return null;
            } catch (e) {
                console.error("Error obteniendo información del usuario:", e);
                // No cerrar sesión automáticamente para evitar loops
                return null;
            }
        },
        
        /**
         * Verifica si el usuario tiene un token válido y no expirado en las cookies.
         */
        isLoggedIn() {
            const token = this.getToken();
            if (!token) {
                return false;
            }

            const payload = _decodeToken(token);
            if (!payload || !payload.exp) {
                // Token malformado
                this.logout(false);
                return false;
            }
            
            // Comprueba si la fecha de expiración (en segundos) ya pasó.
            const nowInSeconds = Math.floor(Date.now() / 1000);
            
            if (payload.exp < nowInSeconds) {
                console.warn("Token JWT expirado. Se requiere nuevo login.");
                this.logout(); // Limpiar sesión expirada y redirigir
                return false;
            }

            return true;
        }
    };

    // Exponer el AuthManager al objeto global 'window'
    window.AuthManager = AuthManager;

})(window);