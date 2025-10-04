// /frontend\static\js\validations.js
// validaciones simples reutilizables
document.addEventListener('submit', function(e){
  const form = e.target;
  if (form.matches('#registerForm')) {
    // ejemplo: validar edad y que usuario no use caracteres raros
    const age = Number(form.age?.value || form.querySelector('input[name="age"]')?.value || 0);
    if (age <= 0 || age > 120) {
      e.preventDefault();
      alert('Ingresa una edad válida.');
    }
  }
  // Agregar más validaciones segun id del form...
});
