// /frontend\static\js\landing.js
// Landing Page JavaScript - User Type Selection Modal

document.addEventListener('DOMContentLoaded', function() {
  // Get modal and buttons
  const userTypeModal = document.getElementById('userTypeModal');
  const loginBtn = document.getElementById('loginBtn');
  const mainLoginBtn = document.getElementById('mainLoginBtn');
  // Support both legacy '.user-type-option' and current '.user-type-card' anchors
  const userTypeCards = document.querySelectorAll('.user-type-card, .user-type-option');

  // Single login modal for all user types
  const loginUrls = {
    patient: '#',
    doctor: '#',
    institution: '#'
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

      // Optional visual selection for legacy tiles
      try {
        userTypeCards.forEach(opt => opt.classList?.remove('selected'));
        this.classList?.add('selected');
      } catch {}

      // For all user types, show the generic login modal
      // Close the user type modal and show the login modal
      hideUserTypeModal();
      setTimeout(() => {
        // Trigger the login button to show the login modal
        const loginBtn = document.getElementById('loginBtn');
        if (loginBtn) {
          loginBtn.click();
        }
      }, 200);
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
  
  // Handle footer login links - all show the generic login modal
  const patientLoginLink = document.getElementById('patientLoginLink');
  const doctorLoginLink = document.getElementById('doctorLoginLink');
  const institutionLoginLink = document.getElementById('institutionLoginLink');

  function showLoginModal(e) {
    e.preventDefault();
    const loginBtn = document.getElementById('loginBtn');
    if (loginBtn) {
      loginBtn.click();
    }
  }

  if (patientLoginLink) {
    patientLoginLink.addEventListener('click', showLoginModal);
  }

  if (doctorLoginLink) {
    doctorLoginLink.addEventListener('click', showLoginModal);
  }

  if (institutionLoginLink) {
    institutionLoginLink.addEventListener('click', showLoginModal);
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
  

  console.log('PredictHealth Landing Page loaded successfully');
});
