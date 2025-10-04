// /frontend\static\js\charts.js
// charts.js - inicializa Chart.js con datos de muestra y provee funciones para actualizar
document.addEventListener('DOMContentLoaded', function(){
  // Evitar errores si Chart.js no fue cargado
  if (typeof Chart === 'undefined') { return; }

  // ejemplo: evolutionChart (line)
  const evoEl = document.getElementById('evolutionChart');
  if (evoEl) {
    const evoCtx = evoEl.getContext('2d');
    window.evolutionChart = new Chart(evoCtx, {
      type: 'line',
      data: {
        labels: ['6 sem', '5 sem','4 sem','3 sem','2 sem','1 sem'],
        datasets: [{
          label: 'Riesgo diabetes (%)',
          data: [12,14,16,13,15,17],
          fill: true,
          tension: .3,
          borderWidth: 2
        }]
      },
      options: {
        responsive:true,
        plugins:{legend:{display:false}}
      }
    });
  }

  const distEl = document.getElementById('distChart');
  if (distEl) {
    const distCtx = distEl.getContext('2d');
    window.distChart = new Chart(distCtx, {
      type:'doughnut',
      data:{
        labels:['Alto','Medio','Bajo'],
        datasets:[{data:[12,30,58], borderWidth:1}]
      },
      options:{responsive:true}
    });
  }
});

document.addEventListener('DOMContentLoaded', () => {
  // Evitar errores si Chart.js no fue cargado
  if (typeof Chart === 'undefined') { return; }

  const ctx = document.getElementById('measurementsChart');
  if (ctx) {
    new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Semana 1','Semana 2','Semana 3','Semana 4'],
        datasets: [
          { label: 'Sistólica', data: [120, 122, 118, 121], borderColor: '#0d6efd', fill: false },
          { label: 'Diastólica', data: [80, 82, 78, 79], borderColor: '#f59e0b', fill: false },
          { label: 'Glucosa', data: [95, 100, 98, 97], borderColor: '#10b981', fill: false }
        ]
      }
    });
  }
});
