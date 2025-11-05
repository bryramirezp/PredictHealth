// /frontend/static/js/auth-manager.js

/**
 * Lee el valor de una cookie específica.
 * @param {string} name - El nombre de la cookie.
 * @returns {string|null} El valor de la cookie o null si no se encuentra.
 */
function getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
    return null;
}

/**
 * Gestiona el inicio de sesión del usuario.
 * @param {string} email - Email del usuario
 * @param {string} password - Contraseña del usuario
 * @param {string} userType - Tipo de usuario (patient, doctor, institution)
 * @returns {Promise<Object>} Resultado del login con éxito o error
 */
async function login(email, password, userType = 'patient') {
    try {
        const response = await fetch('/api/v1/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                email: email,
                password: password,
                user_type: userType
            })
        });

        const data = await response.json();

        if (!response.ok) {
            return {
                success: false,
                error: data.error || data.message || 'Error en el login'
            };
        }

        if (data.success) {
            // La cookie ya fue establecida por el backend
            return {
                success: true,
                user: data.user,
                tokenInfo: data.token_info
            };
        } else {
            return {
                success: false,
                error: data.error || 'Error en el login'
            };
        }

    } catch (error) {
        console.error('Error en login:', error);
        return {
            success: false,
            error: 'Error de conexión al servidor'
        };
    }
}

/**
 * Verifica si el usuario está autenticado.
 * @returns {Promise<boolean>} True si está autenticado, false si no
 */
async function isLoggedIn() {
    try {
        // Verificar si hay cookie de sesión primero
        const sessionCookie = getCookie('predicthealth_session');
        if (!sessionCookie) {
            return false;
        }

        const response = await fetch('/api/web/auth/session/validate', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            return false;
        }

        const data = await response.json();
        return data.valid === true;
    } catch (error) {
        console.error('Error verificando sesión:', error);
        return false;
    }
}

/**
 * Obtiene la información del usuario autenticado.
 * @returns {Promise<Object|null>} Información del usuario o null si no está autenticado
 */
async function getUserInfo() {
    try {
        // Verificar si hay cookie de sesión primero
        const sessionCookie = getCookie('predicthealth_session');
        if (!sessionCookie) {
            return null;
        }

        const response = await fetch('/api/web/auth/session/validate', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            return null;
        }

        const data = await response.json();
        return data.valid ? data.user : null;
    } catch (error) {
        console.error('Error obteniendo información del usuario:', error);
        return null;
    }
}

/**
 * Gestiona el cierre de sesión del usuario.
 * Llama al endpoint de logout del backend para limpiar la cookie de sesión
 * y luego redirige al usuario a la página de inicio.
 */
async function logout() {
    try {
        const response = await fetch('/api/web/auth/logout', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('El servidor no pudo cerrar la sesión.');
        }

    } catch (error) {
        console.error('Error al intentar cerrar la sesión:', error);
    } finally {
        // Redirigir siempre a la página de inicio, incluso si el logout falla
        window.location.href = '/';
    }
}

// Para mayor comodidad, podemos exponer las funciones en un objeto global
window.AuthManager = {
    getCookie,
    login,
    isLoggedIn,
    getUserInfo,
    logout
};
