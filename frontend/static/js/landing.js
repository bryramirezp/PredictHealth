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

    /** Muestra el formulario de contacto (placeholder) */
    function showContactForm() {
        if (!modal) return;

        const modalContentDiv = document.querySelector('.modal-content');
        const modalTitle = document.querySelector('.modal-title');

        if (modalTitle) modalTitle.style.display = 'none';

        // Formulario de contacto simplificado
        modalContentDiv.innerHTML = `
            <h2 class="modal-title" style="display: none;">${originalModalTitle}</h2>
            <div class="contact-form" style="text-align: center; padding: 2rem;">
                <h3 style="color: #2d3748; margin-bottom: 1rem;">¡Gracias por tu interés!</h3>
                <p style="color: #718096; margin-bottom: 2rem; line-height: 1.6;">
                    Estamos trabajando en mejorar PredictHealth. Pronto podrás contactarnos directamente desde aquí.
                </p>
                <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
                    <a href="mailto:contact@predicthealth.com" class="btn btn-primary" style="text-decoration: none;">
                        <i class="fas fa-envelope"></i> Email
                    </a>
                    <a href="tel:+1234567890" class="btn btn-secondary" style="text-decoration: none;">
                        <i class="fas fa-phone"></i> Teléfono
                    </a>
                </div>
            </div>
        `;

        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden'; // Bloquear scroll
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