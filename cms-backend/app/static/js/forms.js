/**
 * PredictHealth CMS - Basic Form Utilities (No AJAX)
 */

// Basic confirmation function
function confirmDelete(message) {
    return confirm(message || '¿Está seguro de eliminar este registro?');
}

// Basic form validation
function validateForm(formId) {
    const form = document.getElementById(formId);
    return form.checkValidity();
}

// Initialize basic form utilities on page load
document.addEventListener('DOMContentLoaded', function() {
    // Add basic form validation feedback
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!form.checkValidity()) {
                e.preventDefault();
                // Show basic validation messages
                const invalidFields = form.querySelectorAll(':invalid');
                if (invalidFields.length > 0) {
                    invalidFields[0].focus();
                }
            }
        });
    });
});