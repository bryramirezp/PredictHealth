// app.js - funciones para actualizar KPIs y consumir API con nomenclatura estándar

// Cargar configuración de nomenclatura
let NomenclatureUtils = {};
if (typeof window !== 'undefined') {
    // En el navegador, cargar desde el archivo de configuración
    const script = document.createElement('script');
    script.src = '/frontend/config/nomenclature_config.js';
    script.onload = function() {
        NomenclatureUtils = window.NomenclatureUtils;
    };
    document.head.appendChild(script);
}

document.addEventListener('DOMContentLoaded', () => {
  // Función para actualizar KPIs usando nomenclatura estándar
  function updateKpis(data){
    // Usar utilidades de nomenclatura si están disponibles
    const formattedData = NomenclatureUtils.formatDashboardData ? 
        NomenclatureUtils.formatDashboardData(data) : data;
    
    document.getElementById('lastUpdate').textContent = formattedData.updatedAt || new Date().toLocaleString();
    document.getElementById('kpiDiabetes').textContent = (formattedData.diabetesRisk ?? 17) + '%';
    document.getElementById('kpiHyper').textContent = (formattedData.hypertensionRisk ?? 12) + '%';
    
    // Actualizar lista de factores
    const list = document.getElementById('factorsList');
    list.innerHTML = '';
    (formattedData.factors ?? ['IMC alto','Edad']).forEach(factor => {
      const li = document.createElement('li'); 
      li.className = 'list-group-item'; 
      li.textContent = factor;
      list.appendChild(li);
    });
    
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

  // Logout con manejo de errores mejorado
  document.getElementById('btnLogout')?.addEventListener('click', () => {
    fetch('/auth/logout', {method:'POST'})
      .then(response => {
        if (response.ok) {
          window.location.href = 'log_in.html';
        } else {
          console.error('Error en logout:', response.statusText);
        }
      })
      .catch(error => {
        console.error('Error de conexión en logout:', error);
        // Fallback: redirigir de todas formas
        window.location.href = 'log_in.html';
      });
  });

  // Función para obtener datos reales del dashboard
  window.fetchDashboard = async function(){
    try{
      const res = await fetch('/api/dashboard');
      if(!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }
      const json = await res.json();
      
      // Validar estructura de datos usando nomenclatura estándar
      if (NomenclatureUtils.validateDashboardData) {
        const isValid = NomenclatureUtils.validateDashboardData(json);
        if (!isValid) {
          console.warn('Datos del dashboard no tienen estructura válida');
        }
      }
      
      updateKpis(json);
      
      // Actualizar gráficos con datos estándar
      if(window.evolutionChart){ 
        window.evolutionChart.data.datasets[0].data = json.evolution || window.evolutionChart.data.datasets[0].data; 
        window.evolutionChart.update();
      }
      if(window.distChart){ 
        window.distChart.data.datasets[0].data = json.distribution || window.distChart.data.datasets[0].data; 
        window.distChart.update();
      }
      
      console.log('Dashboard actualizado con datos reales');
      
    }catch(err){
      console.warn('No se pudieron cargar datos reales del dashboard: ', err);
      
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
    if (!NomenclatureUtils.validateMedicalValue) return true;
    
    const errors = [];
    
    // Validar presión arterial
    if (formData.bp_systolic && formData.bp_diastolic) {
      if (!NomenclatureUtils.validateMedicalValue('presion_sistolica', formData.bp_systolic)) {
        errors.push(NomenclatureUtils.getValidationMessage('presion_sistolica'));
      }
      if (!NomenclatureUtils.validateMedicalValue('presion_diastolica', formData.bp_diastolic)) {
        errors.push(NomenclatureUtils.getValidationMessage('presion_diastolica'));
      }
      if (!NomenclatureUtils.validateBloodPressure(formData.bp_systolic, formData.bp_diastolic)) {
        errors.push('La presión diastólica debe ser menor que la sistólica');
      }
    }
    
    // Validar glucosa
    if (formData.glucose) {
      if (!NomenclatureUtils.validateMedicalValue('glucosa', formData.glucose)) {
        errors.push(NomenclatureUtils.getValidationMessage('glucosa'));
      }
    }
    
    return errors;
  };
  
  // Función para formatear datos antes de enviar al backend
  window.formatDataForBackend = function(formData) {
    if (NomenclatureUtils.mapFormToBackend) {
      return NomenclatureUtils.mapFormToBackend(formData);
    }
    return formData;
  };
});
