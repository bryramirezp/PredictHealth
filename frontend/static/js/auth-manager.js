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
    logout
};
