// /frontend/static/js/doctor-institution.js
// Lógica para la página "Mi Institución" (my-institution.html)

document.addEventListener('DOMContentLoaded', async () => {
    if (window.location.pathname.includes('/doctor/my-institution')) {
        if (!window.DoctorCore) {
            console.error("Error: doctor-core.js no está cargado.");
            return;
        }
        
        const userInfo = await DoctorCore.checkAuth();
        if (userInfo) {
            initMyInstitutionPage(userInfo);
        }
    }
});

/**
 * Inicializa la página de "Mi Institución".
 * @param {object} userInfo - La información del usuario (doctor)
 */
async function initMyInstitutionPage(userInfo) {
    console.log("Inicializando página de Mi Institución...");
    const container = document.getElementById('institution-details');
    if (!container) {
         console.error("No se encontró el contenedor '#institution-details'.");
         return;
    }

    try {
        DoctorCore.showLoading('institution-details', 'Cargando institución...');
        
        const data = await DoctorCore.apiRequest(DoctorCore.ENDPOINTS.MY_INSTITUTION());
        
        let addressHtml = "No especificada";
        if (data.address) {
            addressHtml = [
                data.address.street_address,
                data.address.city,
                data.address.region_name,
                data.address.postal_code
            ].filter(Boolean).join(', '); // Filtra nulos y une con coma
        }

        container.innerHTML = `
            <h2 class="card-title">${data.name}</h2>
            <ul class="list-group list-group-flush">
                <li class="list-group-item"><strong>Tipo:</strong> ${data.type || 'N/A'}</li>
                <li class="list-group-item"><strong>Dirección:</strong> ${addressHtml}</li>
                <li class="list-group-item"><strong>Teléfono:</strong> ${data.phone || 'N/A'}</li>
                <li class="list-group-item"><strong>Email de Contacto:</strong> ${data.email || 'N/A'}</li>
                <li class="list-group-item"><strong>Sitio Web:</strong> ${data.website ? `<a href="${data.website}" target="_blank">${data.website}</a>` : 'N/A'}</li>
                <li class="list-group-item"><strong>Número de Licencia:</strong> ${data.license_number || 'N/A'}</li>
            </ul>
        `;

    } catch (error) {
        console.error('Error al cargar la institución:', error);
        container.innerHTML = `<p class="text-danger">Error al cargar la institución: ${error.message}</p>`;
    }
}