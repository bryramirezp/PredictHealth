// /frontend\static\js\app.js
// app.js - funciones para actualizar KPIs y consumir API con JSON

// Cargar configuración de nomenclatura desde static
let Nomenclature = window.NomenclatureUtils || {};
if (typeof window !== 'undefined' && !window.NomenclatureUtils) {
    const script = document.createElement('script');
    script.src = '/static/js/nomenclature_config.js';
    script.onload = function() {
        Nomenclature = window.NomenclatureUtils || {};
    };
    document.head.appendChild(script);
}
// Simplified token accessor for session-based auth (no tokens needed)
function getAuthToken() {
  // Sessions use cookies, no need for Authorization header
  return null;
}

// Utilidades JSON para PredictHealth
const PredictHealthAPI = {
    // Dashboard
    async fetchDashboard() {
        try {
            const response = await fetch('/api/dashboard', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include' // Incluir cookies automáticamente
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return {
                success: true,
                data: await response.json()
            };
        } catch (error) {
            console.error('Error fetching dashboard:', error);
            return {
                success: false,
                error: error.message
            };
        }
    },

    // Mediciones
    async saveMeasurements(measurementsData) {
        try {
            const response = await fetch('/api/measurements', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include', // Incluir cookies automáticamente
                body: JSON.stringify(measurementsData)
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return {
                success: true,
                data: await response.json()
            };
        } catch (error) {
            console.error('Error saving measurements:', error);
            return {
                success: false,
                error: error.message
            };
        }
    },

    // Estilo de vida
    async saveLifestyle(lifestyleData) {
        try {
            const response = await fetch('/api/lifestyle', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include', // Incluir cookies automáticamente
                body: JSON.stringify(lifestyleData)
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return {
                success: true,
                data: await response.json()
            };
        } catch (error) {
            console.error('Error saving lifestyle:', error);
            return {
                success: false,
                error: error.message
            };
        }
    },

    // Logout
    async logout() {
        try {
            const response = await fetch('/api/v1/auth/logout', {
                method: 'POST',
                credentials: 'include' // Incluir cookies automáticamente
            });

            if (response.ok) {
                return { success: true };
            } else {
                // Logout local exitoso aunque el servidor haya fallado
                return { success: true, warning: 'Logout local completado' };
            }
        } catch (error) {
            console.error('Error during logout:', error);
            // Logout local exitoso aunque haya error de conexión
            return { success: true, warning: 'Logout local completado' };
        }
    }
};

document.addEventListener('DOMContentLoaded', () => {
  // Función para actualizar KPIs usando nomenclatura estándar
  function updateKpis(data){
    // Usar utilidades de nomenclatura si están disponibles
    const formattedData = Nomenclature.formatDashboardData ? 
        Nomenclature.formatDashboardData(data) : data;
    
    const lastUpdateEl = document.getElementById('lastUpdate');
    if (lastUpdateEl) lastUpdateEl.textContent = formattedData.updatedAt || new Date().toLocaleString();
    const kpiDiabetesEl = document.getElementById('kpiDiabetes');
    if (kpiDiabetesEl) kpiDiabetesEl.textContent = (formattedData.diabetesRisk ?? 17) + '%';
    const kpiHyperEl = document.getElementById('kpiHyper');
    if (kpiHyperEl) kpiHyperEl.textContent = (formattedData.hypertensionRisk ?? 12) + '%';
    
    // Actualizar lista de factores
    const list = document.getElementById('factorsList');
    if (list) {
      list.innerHTML = '';
      (formattedData.factors ?? ['IMC alto','Edad']).forEach(factor => {
        const li = document.createElement('li'); 
        li.className = 'list-group-item'; 
        li.textContent = factor;
        list.appendChild(li);
      });
    }
    
    // Actualizar recomendaciones si están disponibles
    if (formattedData.recommendations && formattedData.recommendations.length > 0) {
      updateRecommendations(formattedData.recommendations);
    }
  }
  
  // Función para actualizar recomendaciones
  function updateRecommendations(recommendations) {
    const recommendationsContainer = document.getElementById('recommendationsList');
    if (!recommendationsContainer) return;
    
    recommendationsContainer.innerHTML = '';
    recommendations.forEach(rec => {
      const div = document.createElement('div');
      div.className = `alert alert-${getRecommendationAlertClass(rec.tipo)}`;
      div.innerHTML = `
        <h6>${rec.titulo || 'Recomendación'}</h6>
        <p>${rec.contenido || rec.content}</p>
        ${rec.acciones ? `<small><strong>Acciones:</strong> ${rec.acciones.join(', ')}</small>` : ''}
      `;
      recommendationsContainer.appendChild(div);
    });
  }
  
  // Función para obtener clase CSS según tipo de recomendación
  function getRecommendationAlertClass(tipo) {
    switch(tipo) {
      case 'urgente': return 'danger';
      case 'preventivo': return 'warning';
      case 'general': return 'info';
      case 'seguimiento': return 'secondary';
      default: return 'info';
    }
  }

  // Carga demo al iniciar con datos estándar
  updateKpis({
    updatedAt: new Date().toLocaleString(), 
    diabetesRisk: 17, 
    hypertensionRisk: 12, 
    factors: ['IMC alto','Sedentarismo'],
    recommendations: [
      {
        tipo: 'preventivo',
        titulo: 'Ejemplo de recomendación',
        contenido: 'Mantener actividad física regular',
        acciones: ['Caminar 30 min diarios', 'Ejercicio cardiovascular']
      }
    ]
  });

  // Logout con manejo de errores mejorado - USANDO JSON
  document.getElementById('btnLogout')?.addEventListener('click', async () => {
    try {
      const result = await PredictHealthAPI.logout();
      if (result.success) {
        console.log('Logout exitoso');
        window.location.href = 'log_in.html';
      } else {
        console.error('Error en logout:', result.error);
        // Redirigir de todos modos
        window.location.href = 'log_in.html';
      }
    } catch (error) {
      console.error('Error en logout:', error);
      window.location.href = 'log_in.html';
    }
  });

  // Función para obtener datos reales del dashboard - USANDO JSON
  window.fetchDashboard = async function(){
    try {
      console.log('Obteniendo datos del dashboard con JSON...');
      const result = await PredictHealthAPI.fetchDashboard();

      if (result.success) {
        const data = result.data;

        // Validar estructura de datos usando nomenclatura estándar
        if (Nomenclature.validateDashboardData) {
          const isValid = Nomenclature.validateDashboardData(data);
          if (!isValid) {
            console.warn('Datos del dashboard no tienen estructura válida');
          }
        }

        updateKpis(data);

        // Actualizar gráficos con datos estándar
        if(window.evolutionChart) {
          window.evolutionChart.data.datasets[0].data = data.evolution || window.evolutionChart.data.datasets[0].data;
          window.evolutionChart.update();
        }
        if(window.distChart) {
          window.distChart.data.datasets[0].data = data.distribution || window.distChart.data.datasets[0].data;
          window.distChart.update();
        }

        console.log('Dashboard actualizado con datos JSON reales');
      } else {
        throw new Error(result.error || 'Error desconocido');
      }
    } catch(err) {
      console.warn('No se pudieron cargar datos reales del dashboard:', err);

      // Fallback: mantener datos demo
      updateKpis({
        updatedAt: 'Datos no disponibles',
        diabetesRisk: 25,
        hypertensionRisk: 20,
        factors: ['Error de conexión', 'Datos no disponibles']
      });
    }
  };
  
  // Función para validar datos de mediciones antes de enviar
  window.validateMeasurementData = function(formData) {
    if (!Nomenclature.validateMedicalValue) return true;
    
    const errors = [];
    
    // Validar presión arterial
    if (formData.bp_systolic && formData.bp_diastolic) {
      if (!Nomenclature.validateMedicalValue('presion_sistolica', formData.bp_systolic)) {
        errors.push(Nomenclature.getValidationMessage('presion_sistolica'));
      }
      if (!Nomenclature.validateMedicalValue('presion_diastolica', formData.bp_diastolic)) {
        errors.push(Nomenclature.getValidationMessage('presion_diastolica'));
      }
      if (!Nomenclature.validateBloodPressure(formData.bp_systolic, formData.bp_diastolic)) {
        errors.push('La presión diastólica debe ser menor que la sistólica');
      }
    }
    
    // Validar glucosa
    if (formData.glucose) {
      if (!Nomenclature.validateMedicalValue('glucosa', formData.glucose)) {
        errors.push(Nomenclature.getValidationMessage('glucosa'));
      }
    }
    
    return errors;
  };
  
  // Función para formatear datos antes de enviar al backend
  window.formatDataForBackend = function(formData) {
    if (Nomenclature.mapFormToBackend) {
      return Nomenclature.mapFormToBackend(formData);
    }
    return formData;
  };

  // Función para enviar mediciones usando JSON
  window.saveMeasurements = async function(measurementsData) {
    try {
      console.log('Enviando mediciones usando JSON...');
      const result = await PredictHealthAPI.saveMeasurements(measurementsData);

      if (result.success) {
        console.log('Mediciones guardadas exitosamente con JSON');
        return { success: true, message: 'Mediciones guardadas correctamente' };
      } else {
        console.error('Error guardando mediciones:', result.error);
        return { success: false, error: result.error };
      }
    } catch (error) {
      console.error('Error en saveMeasurements:', error);
      return { success: false, error: error.message };
    }
  };

  // Función para enviar datos de estilo de vida usando JSON
  window.saveLifestyle = async function(lifestyleData) {
    try {
      console.log('Enviando estilo de vida usando JSON...');
      const result = await PredictHealthAPI.saveLifestyle(lifestyleData);

      if (result.success) {
        console.log('Estilo de vida guardado exitosamente con JSON');
        return { success: true, message: 'Hábitos de vida guardados correctamente' };
      } else {
        console.error('Error guardando estilo de vida:', result.error);
        return { success: false, error: result.error };
      }
    } catch (error) {
      console.error('Error en saveLifestyle:', error);
      return { success: false, error: error.message };
    }
  };

  // Función para login usando JSON
  window.login = async function(email, password, userType = 'patient') {
    try {
      // Usar AuthManager si está disponible, sino fallback a PredictHealthAPI
      if (window.AuthManager) {
        console.log(`Iniciando sesión ${userType} usando AuthManager...`);
        const authManager = window.AuthManager;
        const result = await authManager.login(email, password, userType);

        if (result.success) {
          console.log(`Login ${userType} exitoso`);
          return { success: true, data: result.user, redirect: result.redirect };
        } else {
          console.error(`Error en login ${userType}:`, result.error);
          return { success: false, error: result.error };
        }
      } else {
        // Fallback básico usando fetch directo
        console.log(`Iniciando sesión ${userType} usando fetch directo...`);

        const response = await fetch(`/auth/${userType}/login`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(
            userType === 'institution'
              ? { contact_email: email, password: password }
              : { email: email, password: password }
          )
        });

        const result = await response.json();

        if (response.ok && result.access_token) {
          console.log(`Login ${userType} exitoso`);
          return { success: true, data: result };
        } else {
          console.error(`Error en login ${userType}:`, result.message || result.error);
          return { success: false, error: result.message || result.error };
        }
      }
    } catch (error) {
      console.error('Error en login:', error);
      return { success: false, error: error.message };
    }
  };
});
