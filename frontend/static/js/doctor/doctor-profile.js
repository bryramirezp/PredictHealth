// /frontend/static/js/doctor-profile.js
// Lógica para el perfil del doctor (profile.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/doctor/profile')) {
        if (!window.DoctorCore) {
            console.error("Error: doctor-core.js no está cargado.");
            return;
        }
        
        const userInfo = await DoctorCore.checkAuth();
        if (userInfo) {
            initDoctorProfilePage(userInfo);
        }
    }
});

/**
 * Inicializa la página de "Mi Perfil Profesional".
 * @param {object} userInfo - La información del usuario (doctor)
 */
async function initDoctorProfilePage(userInfo) {
    console.log("Inicializando página de Perfil del Doctor...");
    const form = document.getElementById('doctor-profile-form');
    if (!form) {
        console.error("No se encontró el formulario 'doctor-profile-form'.");
        return;
    }

    try {
        // 1. Cargar datos del perfil
        const profileData = await DoctorCore.apiRequest(DoctorCore.ENDPOINTS.MY_PROFILE());
        
        // 2. Poblar el formulario
        form.specialty.value = profileData.specialty_name || '';
        form.experience.value = profileData.years_experience || 0;
        form.consultationFee.value = profileData.consultation_fee || '';

        // TODO: Cargar select de especialidades
        // (Necesitaríamos un nuevo endpoint para listar especialidades)

        // 3. Configurar el envío del formulario
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleProfileUpdate(form, profileData.specialty_id); // Pasar ID actual
        });
        
        // TODO: Configurar formularios de contacto y seguridad

    } catch (error) {
        console.error('Error al cargar el perfil del doctor:', error);
        DoctorCore.showErrorMessage(error.message || 'No se pudo cargar el perfil.');
    }
}

/**
 * Maneja el envío del formulario de actualización de perfil.
 * @param {HTMLFormElement} form - El formulario del perfil
 * @param {string} currentSpecialtyId - El ID de la especialidad actual
 */
async function handleProfileUpdate(form, currentSpecialtyId) {
    const submitBtn = form.querySelector('button[type="submit"]');
    
    const formData = new FormData(form);
    const data = {
        // specialty_id: formData.get('specialty_id') || currentSpecialtyId, // Usar el ID del select
        years_experience: parseInt(formData.get('experience'), 10),
        consultation_fee: parseFloat(formData.get('consultationFee'))
    };

    // TODO: El campo 'specialty' es un 'text' por ahora.
    // Para que funcione, el backend (DoctorUpdateRequest) debe aceptar 'specialty_name'
    // o el frontend debe tener un <select> con 'specialty_id'.
    // Por ahora, solo actualizaremos los campos numéricos.
    
    try {
        submitBtn.disabled = true;
        submitBtn.textContent = "Actualizando...";

        await DoctorCore.apiRequest(DoctorCore.ENDPOINTS.MY_PROFILE(), {
            method: 'PUT',
            body: data
        });

        DoctorCore.showSuccessMessage('Perfil actualizado exitosamente.');
        
    } catch (error) {
        console.error('Error al actualizar el perfil:', error);
        // El apiRequest ya muestra el error
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = "Actualizar Perfil Profesional";
    }
}