// /frontend\static\js\landing.js
// Landing Page JavaScript - User Type Selection Modal

document.addEventListener('DOMContentLoaded', function() {
  // Get modal and buttons
  const userTypeModal = document.getElementById('userTypeModal');
  const loginBtn = document.getElementById('loginBtn');
  const mainLoginBtn = document.getElementById('mainLoginBtn');
  // Support both legacy '.user-type-option' and current '.user-type-card' anchors
  const userTypeCards = document.querySelectorAll('.user-type-card, .user-type-option');

  // Login page URLs for each user type
  const loginUrls = {
    patient: 'patient_login.html',
    doctor: 'doctor_login.html',
    institution: 'institution_login.html'
  };

  // Show modal when login buttons are clicked
  function showUserTypeModal() {
    if (userTypeModal) {
      userTypeModal.style.display = 'flex';
      document.body.style.overflow = 'hidden'; // Prevent background scrolling
    }
  }

  // Hide modal function
  function hideUserTypeModal() {
    if (userTypeModal) {
      userTypeModal.style.display = 'none';
      document.body.style.overflow = ''; // Restore scrolling
    }
  }
  
  // Add event listeners to login buttons
  if (loginBtn) {
    loginBtn.addEventListener('click', function(e) {
      e.preventDefault();
      showUserTypeModal();
    });
  }
  
  if (mainLoginBtn) {
    mainLoginBtn.addEventListener('click', function(e) {
      e.preventDefault();
      showUserTypeModal();
    });
  }
  
  // Handle user type selection (anchors or cards)
  userTypeCards.forEach(option => {
    option.addEventListener('click', function(e) {
      e.preventDefault();
      // Derive target either from data-type or href
      const userType = this.getAttribute('data-type');
      const href = this.getAttribute('href') || '';

      // Optional visual selection for legacy tiles
      try {
        userTypeCards.forEach(opt => opt.classList?.remove('selected'));
        this.classList?.add('selected');
      } catch {}

      // Determine destination
      let targetUrl = null;
      if (userType && loginUrls[userType]) {
        targetUrl = loginUrls[userType];
      } else if (href) {
        targetUrl = href; // current markup uses direct anchors to pages
      }

      // Close modal then navigate
      hideUserTypeModal();
      if (targetUrl) {
        setTimeout(() => { window.location.href = targetUrl; }, 200);
      }
    });
  });
  
  // Add hover effects to user type options
  userTypeOptions.forEach(option => {
    option.addEventListener('mouseenter', function() {
      if (!this.classList.contains('selected')) {
        this.style.transform = 'translateY(-2px)';
        this.style.boxShadow = '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)';
      }
    });

    option.addEventListener('mouseleave', function() {
      if (!this.classList.contains('selected')) {
        this.style.transform = 'translateY(0)';
        this.style.boxShadow = 'none';
      }
    });
  });

  // Close modal when clicking outside
  if (userTypeModal) {
    userTypeModal.addEventListener('click', function(e) {
      if (e.target === this) {
        hideUserTypeModal();
      }
    });
  }
  
  // Handle footer login links
  const patientLoginLink = document.getElementById('patientLoginLink');
  const doctorLoginLink = document.getElementById('doctorLoginLink');
  const institutionLoginLink = document.getElementById('institutionLoginLink');
  
  if (patientLoginLink) {
    patientLoginLink.addEventListener('click', function(e) {
      e.preventDefault();
      window.location.href = loginUrls.patient;
    });
  }
  
  if (doctorLoginLink) {
    doctorLoginLink.addEventListener('click', function(e) {
      e.preventDefault();
      window.location.href = loginUrls.doctor;
    });
  }
  
  if (institutionLoginLink) {
    institutionLoginLink.addEventListener('click', function(e) {
      e.preventDefault();
      window.location.href = loginUrls.institution;
    });
  }
  
  // Smooth scrolling for navigation links
  const navLinks = document.querySelectorAll('a[href^="#"]');
  navLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      const targetId = this.getAttribute('href').substring(1);
      const targetElement = document.getElementById(targetId);
      
      if (targetElement) {
        targetElement.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
  
  // Add animation to hero elements
  const heroElements = document.querySelectorAll('.hero-content, .hero-visual');
  heroElements.forEach((element, index) => {
    element.style.opacity = '0';
    element.style.transform = 'translateY(30px)';
    
    setTimeout(() => {
      element.style.transition = 'all 0.8s ease-out';
      element.style.opacity = '1';
      element.style.transform = 'translateY(0)';
    }, index * 200);
  });
  
  // Add scroll effect to header/navbar
  let lastScrollTop = 0;
  const navbar = document.querySelector('.header');

  if (navbar) {
    window.addEventListener('scroll', function() {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

      if (scrollTop > lastScrollTop && scrollTop > 100) {
        // Scrolling down
        navbar.style.transform = 'translateY(-100%)';
      } else {
        // Scrolling up
        navbar.style.transform = 'translateY(0)';
      }

      lastScrollTop = scrollTop;
    });

    // Add navbar transition
    navbar.style.transition = 'transform 0.3s ease-in-out';
  }
  
  // Limpiar datos de prueba del localStorage si existen
  function clearTestData() {
    const testTokens = [
      'predicthealth_access_token',
      'predicthealth_refresh_token',
      'predicthealth_user'
    ];

    let clearedData = false;
    testTokens.forEach(key => {
      const value = localStorage.getItem(key);
      if (value) {
        // Limpiar tokens inválidos o datos corruptos
        if (key === 'predicthealth_refresh_token' && value === 'null') {
          localStorage.removeItem(key);
          clearedData = true;
        } else if (key === 'predicthealth_user') {
          try {
            const userData = JSON.parse(value);
            // Verificar si los datos del usuario son válidos
            if (!userData.user_id || !userData.email) {
              localStorage.removeItem(key);
              clearedData = true;
            }
          } catch (e) {
            // Si no se puede parsear, eliminarlo
            localStorage.removeItem(key);
            clearedData = true;
          }
        }
      }
    });

    if (clearedData) {
      console.log('Datos de prueba eliminados del localStorage');
    }
  }

  // Limpiar datos de prueba al cargar la página
  clearTestData();

  console.log('PredictHealth Landing Page loaded successfully');
});
