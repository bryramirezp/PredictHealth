// /static/js/landing.js

// Espera a que el DOM esté cargado
document.addEventListener('DOMContentLoaded', () => {

    // --- Variables Globales ---
    const modal = document.getElementById('modal');
    const modalTitleEl = document.querySelector('.modal-title');
    const learnMoreBtn = document.getElementById('learnMoreBtn');
    const loginBtn = document.getElementById('loginBtn');
    const closeModalBtn = document.getElementById('closeModalBtn');

    // Guardar contenido original del modal
    const originalModalTitle = modalTitleEl ? modalTitleEl.innerHTML : '';
    const originalModalContent = document.querySelector('.modal-content') ? document.querySelector('.modal-content').innerHTML : '';

    // Parámetros de URL
    const urlParams = new URLSearchParams(window.location.search);
    const showLoginOnLoad = urlParams.get('show_login') === 'true';

    // --- Funciones Principales ---

    /** Muestra el formulario de login */
    function showLoginModal() {
        if (!modal) return;

        // Restaurar contenido original por si estaba el de "Contacto"
        const modalContentDiv = document.querySelector('.modal-content');
        if (modalContentDiv.innerHTML !== originalModalContent) {
             modalContentDiv.innerHTML = originalModalContent;
        }

        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden'; // Bloquear scroll
        clearLoginForm();

        // Reactivar listeners del formulario restaurado
        const toggleBtn = document.getElementById('toggleLoginPassword');
        if (toggleBtn) {
            // Remover listener anterior si existe para evitar duplicados
            toggleBtn.removeEventListener('click', toggleLoginPasswordVisibility);
            toggleBtn.addEventListener('click', toggleLoginPasswordVisibility);
        }
        
        // Agregar event listener al formulario para submit
        // Remover listener anterior si existe para evitar duplicados
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.removeEventListener('submit', handleLogin);
            loginForm.addEventListener('submit', handleLogin);
        }

        // El botón de cerrar se re-asigna en los listeners globales
    }

    /** Muestra el formulario de contacto */
    function showContactForm() {
        if (!modal) return;

        const modalContentDiv = document.querySelector('.modal-content');
        const modalTitle = document.querySelector('.modal-title');

        if (modalTitle) modalTitle.style.display = 'none';

        // Formulario de contacto completo
        modalContentDiv.innerHTML = `
            <h2 class="modal-title" style="display: block; margin-bottom: 1.5rem;">Contáctanos</h2>
            <div class="contact-form" style="max-width: 500px; margin: 0 auto; padding: 1rem;">
                <form id="contactForm" style="display: flex; flex-direction: column; gap: 1rem;">
                    <div>
                        <label for="contactName" style="display: block; margin-bottom: 0.5rem; color: #2d3748; font-weight: 500;">
                            <i class="fas fa-user me-2"></i>Nombre
                        </label>
                        <input 
                            type="text" 
                            id="contactName" 
                            name="name" 
                            required 
                            style="width: 100%; padding: 0.75rem; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 1rem;"
                            placeholder="Tu nombre completo"
                        >
                    </div>
                    
                    <div>
                        <label for="contactEmail" style="display: block; margin-bottom: 0.5rem; color: #2d3748; font-weight: 500;">
                            <i class="fas fa-envelope me-2"></i>Email
                        </label>
                        <input 
                            type="email" 
                            id="contactEmail" 
                            name="email" 
                            required 
                            style="width: 100%; padding: 0.75rem; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 1rem;"
                            placeholder="tu@email.com"
                        >
                    </div>
                    
                    <div>
                        <label for="contactPhone" style="display: block; margin-bottom: 0.5rem; color: #2d3748; font-weight: 500;">
                            <i class="fas fa-phone me-2"></i>Número de Teléfono
                        </label>
                        <input 
                            type="tel" 
                            id="contactPhone" 
                            name="phone" 
                            style="width: 100%; padding: 0.75rem; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 1rem;"
                            placeholder="+1 234 567 8900"
                        >
                    </div>
                    
                    <div>
                        <label for="contactMessage" style="display: block; margin-bottom: 0.5rem; color: #2d3748; font-weight: 500;">
                            <i class="fas fa-comment me-2"></i>Comentario
                        </label>
                        <textarea 
                            id="contactMessage" 
                            name="message" 
                            required 
                            rows="4"
                            style="width: 100%; padding: 0.75rem; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 1rem; resize: vertical; font-family: inherit;"
                            placeholder="Escribe tu mensaje aquí..."
                        ></textarea>
                    </div>
                    
                    <div id="contactFormMessage" style="display: none; padding: 0.75rem; border-radius: 8px; margin-top: 0.5rem;"></div>
                    
                    <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 0.5rem;">
                        <button 
                            type="button" 
                            onclick="closeModal()" 
                            class="btn btn-secondary"
                            style="padding: 0.75rem 1.5rem; border: none; border-radius: 8px; cursor: pointer; background: #e2e8f0; color: #2d3748;"
                        >
                            Cancelar
                        </button>
                        <button 
                            type="submit" 
                            id="contactSubmitBtn"
                            class="btn btn-primary"
                            style="padding: 0.75rem 1.5rem; border: none; border-radius: 8px; cursor: pointer; background: #3182ce; color: white;"
                        >
                            <i class="fas fa-paper-plane me-2"></i>Enviar
                        </button>
                    </div>
                </form>
            </div>
        `;

        // Agregar event listener al formulario
        const contactForm = document.getElementById('contactForm');
        if (contactForm) {
            contactForm.addEventListener('submit', handleContactSubmit);
        }

        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden'; // Bloquear scroll
    }

    /** Maneja el envío del formulario de contacto */
    async function handleContactSubmit(e) {
        e.preventDefault();
        
        const form = e.target;
        const submitBtn = document.getElementById('contactSubmitBtn');
        const messageDiv = document.getElementById('contactFormMessage');
        
        // Obtener datos del formulario
        const formData = new FormData(form);
        const contactData = {
            name: formData.get('name'),
            email: formData.get('email'),
            phone: formData.get('phone') || '',
            message: formData.get('message'),
            timestamp: Date.now()
        };

        // Validación básica
        if (!contactData.name || !contactData.email || !contactData.message) {
            showContactMessage('Por favor completa todos los campos requeridos.', 'error');
            return;
        }

        // Deshabilitar botón y mostrar loading
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Enviando...';
        messageDiv.style.display = 'none';

        try {
            const response = await fetch('/api/web/contact', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(contactData)
            });

            const result = await response.json();

            if (response.ok) {
                showContactMessage('¡Mensaje enviado exitosamente! Te responderemos pronto.', 'success');
                form.reset();
                // Cerrar modal después de 2 segundos
                setTimeout(() => {
                    closeModal();
                }, 2000);
            } else {
                showContactMessage(result.message || 'Error al enviar el mensaje. Por favor intenta nuevamente.', 'error');
            }
        } catch (error) {
            console.error('Error al enviar formulario de contacto:', error);
            showContactMessage('Error de conexión. Por favor verifica tu conexión e intenta nuevamente.', 'error');
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Enviar';
        }
    }

    /** Muestra mensaje en el formulario de contacto */
    function showContactMessage(message, type) {
        const messageDiv = document.getElementById('contactFormMessage');
        if (!messageDiv) return;

        messageDiv.style.display = 'block';
        messageDiv.textContent = message;
        messageDiv.style.padding = '0.75rem';
        messageDiv.style.borderRadius = '8px';
        
        if (type === 'success') {
            messageDiv.style.backgroundColor = '#c6f6d5';
            messageDiv.style.color = '#22543d';
            messageDiv.style.border = '1px solid #9ae6b4';
        } else {
            messageDiv.style.backgroundColor = '#fed7d7';
            messageDiv.style.color = '#742a2a';
            messageDiv.style.border = '1px solid #fc8181';
        }
    }

    /** Cierra el modal (Login o Contacto) */
    function closeModal() {
        if (!modal) return;
        modal.style.display = 'none';
        document.body.style.overflow = ''; // Restaurar scroll
    }

    /** Limpia el formulario de login */
    function clearLoginForm() {
        const emailInput = document.getElementById('loginEmail');
        const passwordInput = document.getElementById('loginPassword');
        const messageDiv = document.getElementById('loginMessage');

        if (emailInput) emailInput.value = '';
        if (passwordInput) passwordInput.value = '';
        if (messageDiv) messageDiv.style.display = 'none';
    }

    /** Muestra/oculta la contraseña */
    function toggleLoginPasswordVisibility() {
        const passwordInput = document.getElementById('loginPassword');
        const toggleIcon = document.getElementById('toggleLoginPassword').querySelector('i');

        if (!passwordInput || !toggleIcon) return;

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            toggleIcon.classList.remove('fa-eye-slash');
            toggleIcon.classList.add('fa-eye');
        } else {
            passwordInput.type = 'password';
            toggleIcon.classList.remove('fa-eye');
            toggleIcon.classList.add('fa-eye-slash');
        }
    }

    /** Muestra un mensaje en el formulario de login */
    function showLoginMessage(message, type = 'info') {
        const messageDiv = document.getElementById('loginMessage');
        if (!messageDiv) return;

        messageDiv.textContent = message;
        messageDiv.className = `login-message ${type}`;
        messageDiv.style.display = 'block';

        if (type === 'success') {
            setTimeout(() => {
                messageDiv.style.display = 'none';
            }, 3000);
        }
    }

    /** Maneja el envío del formulario de login */
    async function handleLogin(e) {
        // Prevenir el comportamiento por defecto del formulario
        if (e) {
            e.preventDefault();
        }
        
        const email = document.getElementById('loginEmail').value;
        const password = document.getElementById('loginPassword').value;
        const submitBtn = document.querySelector('#loginForm .form-submit');

        if (!email || !password) {
            showLoginMessage('Por favor, completa todos los campos.', 'error');
            return;
        }

        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.textContent = 'Iniciando sesión...';
        }

        try {
            const response = await fetch('/api/web/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: email, password: password })
            });

            const result = await response.json();

            if (response.ok && result.status === 'success') {
                showLoginMessage('Login exitoso. Redirigiendo...', 'success');
                setTimeout(() => {
                    const userType = result.data.user_type;
                    const redirectUrls = {
                        'patient': '/patient/dashboard',
                        'doctor': '/doctor/dashboard',
                        'institution': '/institution/dashboard'
                    };
                    window.location.href = redirectUrls[userType] || '/';
                }, 1000);
            } else {
                throw new Error(result.message || 'Error en la autenticación');
            }

        } catch (error) {
            console.error('Error en login:', error);
            showLoginMessage(error.message || 'Error al iniciar sesión. Inténtalo de nuevo.', 'error');
        } finally {
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Iniciar Sesión';
            }
        }
    }

    // --- WebGL Background Shader ---
    const canvas = document.getElementById("iridescence-canvas");
    if (canvas) {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        const gl = canvas.getContext("webgl");

        if (!gl) {
            console.error("WebGL no soportado");
        } else {
            const vertexShaderSrc = `
                attribute vec2 position;
                attribute vec2 uv;
                varying vec2 vUv;
                void main() {
                    vUv = uv;
                    gl_Position = vec4(position, 0, 1);
                }
            `;
            const fragmentShaderSrc = `
                precision highp float;
                uniform float uTime;
                uniform vec3 uColor;
                uniform vec3 uResolution;
                uniform vec2 uMouse;
                uniform float uAmplitude;
                uniform float uSpeed;
                varying vec2 vUv;
                void main() {
                    float mr = min(uResolution.x, uResolution.y);
                    vec2 uv = (vUv.xy * 2.0 - 1.0) * uResolution.xy / mr;
                    uv += (uMouse - vec2(0.5)) * uAmplitude;
                    float d = -uTime * 0.5 * uSpeed;
                    float a = 0.0;
                    for (float i = 0.0; i < 8.0; ++i) {
                        a += cos(i - d - a * uv.x);
                        d += sin(uv.y * i + a);
                    }
                    d += uTime * 0.5 * uSpeed;
                    vec3 col = vec3(cos(uv * vec2(d, a)) * 0.6 + 0.4, cos(a + d) * 0.5 + 0.5);
                    col = cos(col * cos(vec3(d, a, 2.5)) * 0.5 + 0.5) * uColor;
                    gl_FragColor = vec4(col, 1.0);
                }
            `;

            const createShader = (gl, type, source) => {
                const shader = gl.createShader(type);
                gl.shaderSource(shader, source);
                gl.compileShader(shader);
                if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
                    console.error(gl.getShaderInfoLog(shader));
                    gl.deleteShader(shader);
                    return null;
                }
                return shader;
            };

            const createProgram = (gl, vertexShader, fragmentShader) => {
                const program = gl.createProgram();
                gl.attachShader(program, vertexShader);
                gl.attachShader(program, fragmentShader);
                gl.linkProgram(program);
                if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
                    console.error(gl.getProgramInfoLog(program));
                    return null;
                }
                return program;
            };

            const vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSrc);
            const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSrc);
            const program = createProgram(gl, vertexShader, fragmentShader);

            const positions = new Float32Array([-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]);
            const uvs = new Float32Array([0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1]);

            const positionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
            gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);

            const uvBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, uvBuffer);
            gl.bufferData(gl.ARRAY_BUFFER, uvs, gl.STATIC_DRAW);

            const positionAttributeLocation = gl.getAttribLocation(program, "position");
            const uvAttributeLocation = gl.getAttribLocation(program, "uv");
            const timeUniformLocation = gl.getUniformLocation(program, "uTime");
            const colorUniformLocation = gl.getUniformLocation(program, "uColor");
            const resolutionUniformLocation = gl.getUniformLocation(program, "uResolution");
            const mouseUniformLocation = gl.getUniformLocation(program, "uMouse");
            const amplitudeUniformLocation = gl.getUniformLocation(program, "uAmplitude");
            const speedUniformLocation = gl.getUniformLocation(program, "uSpeed");

            let mouseX = 0.5, mouseY = 0.5;
            const mouseReact = false;

            if (mouseReact) {
                canvas.addEventListener('mousemove', (e) => {
                    const rect = canvas.getBoundingClientRect();
                    mouseX = (e.clientX - rect.left) / rect.width;
                    mouseY = 1.0 - (e.clientY - rect.top) / rect.height;
                });
            }

            const render = (time) => {
                gl.viewport(0, 0, canvas.width, canvas.height);
                gl.clear(gl.COLOR_BUFFER_BIT);
                gl.useProgram(program);

                gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
                gl.enableVertexAttribArray(positionAttributeLocation);
                gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

                gl.bindBuffer(gl.ARRAY_BUFFER, uvBuffer);
                gl.enableVertexAttribArray(uvAttributeLocation);
                gl.vertexAttribPointer(uvAttributeLocation, 2, gl.FLOAT, false, 0, 0);

                gl.uniform1f(timeUniformLocation, time * 0.001);
                gl.uniform3f(colorUniformLocation, 0.3, 0.3, 1.0); // Color azul
                gl.uniform3f(resolutionUniformLocation, canvas.width, canvas.height, canvas.width / canvas.height);
                gl.uniform2f(mouseUniformLocation, mouseX, mouseY);
                gl.uniform1f(amplitudeUniformLocation, 0.1);
                gl.uniform1f(speedUniformLocation, 1.0);

                gl.drawArrays(gl.TRIANGLES, 0, 6);
                requestAnimationFrame(render);
            }
            requestAnimationFrame(render);

            window.addEventListener('resize', () => {
                canvas.width = window.innerWidth;
                canvas.height = window.innerHeight;
            });
        }
    }

    // --- Event Listeners ---
    if (learnMoreBtn) {
        learnMoreBtn.addEventListener('click', showContactForm);
    }
    if (loginBtn) {
        loginBtn.addEventListener('click', showLoginModal);
    }
    if (closeModalBtn) {
        closeModalBtn.addEventListener('click', closeModal);
    }
    if (modal) {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModal();
            }
        });
    }

    // Configurar event listener del formulario de login (si ya existe en el DOM)
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }
    
    // Configurar event listener del botón de toggle de contraseña (si ya existe en el DOM)
    const toggleBtn = document.getElementById('toggleLoginPassword');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', toggleLoginPasswordVisibility);
    }

    // Teclado
    document.addEventListener('keydown', (e) => {
        if (modal && modal.style.display === 'flex') {
            if (e.key === 'Enter') {
                // Solo si el formulario de login es visible
                const loginForm = document.getElementById('loginForm');
                if (loginForm) {
                    e.preventDefault();
                    handleLogin(e);
                }
            } else if (e.key === 'Escape') {
                closeModal();
            }
        }
    });

    // Mostrar modal si la URL lo indica
    if (showLoginOnLoad) {
        setTimeout(() => {
            showLoginModal();
        }, 500);
    }
});