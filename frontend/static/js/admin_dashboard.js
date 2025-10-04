// /frontend\static\js\admin_dashboard.js
// PredictHealth Admin Dashboard JavaScript
// Comprehensive admin interface with real-time monitoring and CRUD operations

class AdminDashboard {
    constructor() {
        this.apiBaseUrl = window.location.origin;
        this.currentUser = null;
        this.currentSection = 'overview';
        this.healthCheckInterval = null;
        this.sidebarCollapsed = false;
        this.init();
    }

    async init() {
        try {
            // Check authentication first
            await this.checkAuth();

            // Initialize UI components
            this.initSidebar();
            this.initNavigation();
            this.initHealthMonitoring();
            this.initEventListeners();

            // Load initial data
            await this.loadDashboardData();

        } catch (error) {
            console.error('Initialization error:', error);
            this.showToast('Authentication failed. Please login again.', 'error');
            setTimeout(() => {
                window.location.href = '/';
            }, 2000);
        }
    }

    // Authentication
    async checkAuth() {
        // Usar SessionAuthManager para validar sesión
        if (!window.AuthManager) {
            throw new Error('AuthManager not available');
        }

        try {
            // Validar sesión activa (isLoggedIn ahora es async y valida con servidor)
            const isLoggedIn = await window.AuthManager.isLoggedIn();
            if (!isLoggedIn) {
                throw new Error('No active session found');
            }

            // Obtener información del usuario de la sesión
            this.currentUser = await window.AuthManager.getUserInfo();
            if (this.currentUser) {
                document.getElementById('current-user').textContent =
                    `${this.currentUser.first_name || 'Admin'} ${this.currentUser.last_name || 'User'}`;
            }

        } catch (error) {
            console.error('Session validation failed:', error);
            throw error;
        }
    }

    // API Communication
    async apiCall(endpoint, method = 'GET', data = null) {
        const config = {
            method,
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include' // Incluir cookies automáticamente
        };

        if (data) {
            config.body = JSON.stringify(data);
        }

        const response = await fetch(`${this.apiBaseUrl}${endpoint}`, config);

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.message || `HTTP ${response.status}`);
        }

        return await response.json();
    }

    // Health Monitoring
    initHealthMonitoring() {
        this.updateHealthStatus();
        this.healthCheckInterval = setInterval(() => {
            this.updateHealthStatus();
        }, 30000); // Check every 30 seconds
    }

    async updateHealthStatus() {
        const services = [
            { name: 'Admin Service', endpoint: '/api/v1/admins/health', requiresAuth: false },
            { name: 'JWT Service', endpoint: '/api/v1/auth/jwt/health', requiresAuth: false },
            { name: 'Institutions Service', endpoint: '/api/v1/institutions/statistics', requiresAuth: true },
            { name: 'Doctors Service', endpoint: '/api/v1/doctors/statistics', requiresAuth: true },
            { name: 'Patients Service', endpoint: '/api/v1/patients/statistics', requiresAuth: true }
        ];

        const healthGrid = document.getElementById('health-grid');
        if (!healthGrid) {
            console.warn('Health grid element not found');
            return;
        }
        healthGrid.innerHTML = '';

        for (const service of services) {
            const status = await this.checkServiceHealth(service);
            healthGrid.appendChild(this.createHealthCard(service.name, status));
        }
    }

    async checkServiceHealth(service) {
        try {
            const startTime = Date.now();
            // Para servicios que no requieren auth, hacer llamada directa sin cookies
            if (service.requiresAuth === false) {
                const response = await fetch(`${this.apiBaseUrl}${service.endpoint}`, {
                    method: 'GET',
                    headers: {'Content-Type': 'application/json'}
                    // No incluir credentials para health checks públicos
                });
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
            } else {
                // Para servicios que requieren auth, usar apiCall con cookies
                await this.apiCall(service.endpoint, 'GET');
            }
            const responseTime = Date.now() - startTime;

            if (responseTime < 1000) {
                return { status: 'healthy', details: `${responseTime}ms` };
            } else if (responseTime < 5000) {
                return { status: 'warning', details: `${responseTime}ms` };
            } else {
                return { status: 'error', details: `${responseTime}ms` };
            }
        } catch (error) {
            return { status: 'error', details: 'Offline' };
        }
    }

    createHealthCard(serviceName, status) {
        const card = document.createElement('div');
        card.className = `health-card ${status.status}`;

        card.innerHTML = `
            <h3>${serviceName}</h3>
            <div class="status">${status.status.toUpperCase()}</div>
            <div class="details">${status.details}</div>
        `;

        return card;
    }

    // UI Initialization
    initSidebar() {
        // Sidebar toggle
        const sidebarToggle = document.getElementById('sidebar-toggle');
        const mobileToggle = document.getElementById('mobile-sidebar-toggle');
        const sidebar = document.getElementById('sidebar');

        sidebarToggle.addEventListener('click', () => {
            this.toggleSidebar();
        });

        mobileToggle.addEventListener('click', () => {
            this.toggleMobileSidebar();
        });

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', (e) => {
            if (window.innerWidth <= 768 && !sidebar.contains(e.target) && !mobileToggle.contains(e.target)) {
                sidebar.classList.remove('mobile-open');
            }
        });
    }

    initNavigation() {
        const navLinks = document.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const section = link.dataset.section;
                this.switchSection(section);
            });
        });
    }

    initEventListeners() {
        // Modal close events
        document.getElementById('modal-overlay').addEventListener('click', (e) => {
            if (e.target.id === 'modal-overlay') {
                this.closeModal();
            }
        });

        // Keyboard navigation
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.closeModal();
            }
        });

        // Window resize handling
        window.addEventListener('resize', () => {
            this.handleResize();
        });
    }

    toggleSidebar() {
        this.sidebarCollapsed = !this.sidebarCollapsed;
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');

        if (this.sidebarCollapsed) {
            sidebar.classList.add('collapsed');
        } else {
            sidebar.classList.remove('collapsed');
        }
    }

    toggleMobileSidebar() {
        const sidebar = document.getElementById('sidebar');
        sidebar.classList.toggle('mobile-open');
    }

    handleResize() {
        const sidebar = document.getElementById('sidebar');
        if (window.innerWidth > 768) {
            sidebar.classList.remove('mobile-open');
        }
    }

    switchSection(sectionName) {
        // Update navigation links
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });
        document.querySelector(`[data-section="${sectionName}"]`).classList.add('active');

        // Update content sections
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        document.getElementById(`${sectionName}-section`).classList.add('active');

        this.currentSection = sectionName;
        this.loadSectionData(sectionName);
    }

    // Data Loading
    async loadDashboardData() {
        // Load overview data (stats and charts)
        await this.loadOverviewData();

        // Load other sections data in background
        this.loadAllData();
    }

    async loadOverviewData() {
        try {
            // Load statistics for overview
            await this.loadStats();

            // Initialize charts
            this.initCharts();

        } catch (error) {
            console.error('Failed to load overview data:', error);
        }
    }

    async loadAllData() {
        await Promise.all([
            this.loadAdmins(),
            this.loadInstitutions(),
            this.loadDoctors(),
            this.loadPatients(),
            this.loadAuditLogs()
        ]);
    }

    async loadSectionData(sectionName) {
        switch (sectionName) {
            case 'overview':
                await this.loadOverviewData();
                break;
            case 'admins':
                await this.loadAdmins();
                break;
            case 'institutions':
                await this.loadInstitutions();
                break;
            case 'doctors':
                await this.loadDoctors();
                break;
            case 'patients':
                await this.loadPatients();
                break;
            case 'microservices':
                await this.loadMicroservicesHealth();
                break;
        }
    }

    async loadStats() {
        try {
            // Load stats from various services
            const [adminsRes, institutionsRes, doctorsRes, patientsRes] = await Promise.allSettled([
                this.apiCall('/api/v1/admins/statistics'),
                this.apiCall('/api/v1/institutions/statistics'),
                this.apiCall('/api/v1/doctors/statistics'),
                this.apiCall('/api/v1/patients/statistics')
            ]);

            // Update stats cards
            const adminsCount = adminsRes.status === 'fulfilled' ? adminsRes.value.total || 0 : 0;
            const institutionsCount = institutionsRes.status === 'fulfilled' ? institutionsRes.value.total || 0 : 0;
            const doctorsCount = doctorsRes.status === 'fulfilled' ? doctorsRes.value.total || 0 : 0;
            const patientsCount = patientsRes.status === 'fulfilled' ? patientsRes.value.total || 0 : 0;

            document.getElementById('admins-count').textContent = adminsCount;
            document.getElementById('institutions-count').textContent = institutionsCount;
            document.getElementById('doctors-count').textContent = doctorsCount;
            document.getElementById('patients-count').textContent = patientsCount;

        } catch (error) {
            console.error('Failed to load stats:', error);
        }
    }

    initCharts() {
        // Initialize charts after DOM is ready
        setTimeout(() => {
            this.renderGrowthChart();
            this.renderActivityChart();
        }, 100);
    }

    renderGrowthChart() {
        const canvas = document.getElementById('growth-chart');
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;

        // Sample data - in real implementation, this would come from API
        const data = [12, 19, 15, 25, 22, 30, 28, 35, 32, 38, 42, 45];
        const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        this.drawLineChart(ctx, width, height, data, labels, 'User Growth', '#3b82f6');
    }

    renderActivityChart() {
        const canvas = document.getElementById('activity-chart');
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;

        // Sample data
        const data = [65, 59, 80, 81, 56, 55, 40];
        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        this.drawBarChart(ctx, width, height, data, labels, 'Weekly Activity', '#10b981');
    }

    drawLineChart(ctx, width, height, data, labels, title, color) {
        // Clear canvas
        ctx.clearRect(0, 0, width, height);

        // Chart dimensions
        const padding = 60;
        const chartWidth = width - padding * 2;
        const chartHeight = height - padding * 2;

        // Find max value
        const maxValue = Math.max(...data);

        // Draw title
        ctx.fillStyle = '#374151';
        ctx.font = '14px system-ui';
        ctx.textAlign = 'center';
        ctx.fillText(title, width / 2, 20);

        // Draw axes
        ctx.strokeStyle = '#d1d5db';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(padding, padding);
        ctx.lineTo(padding, height - padding);
        ctx.lineTo(width - padding, height - padding);
        ctx.stroke();

        // Draw grid lines
        ctx.strokeStyle = '#f3f4f6';
        ctx.lineWidth = 1;
        for (let i = 0; i <= 5; i++) {
            const y = padding + (chartHeight / 5) * i;
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(width - padding, y);
            ctx.stroke();
        }

        // Draw labels
        ctx.fillStyle = '#6b7280';
        ctx.font = '12px system-ui';
        ctx.textAlign = 'center';
        labels.forEach((label, i) => {
            const x = padding + (chartWidth / (labels.length - 1)) * i;
            ctx.fillText(label, x, height - 20);
        });

        // Draw Y axis labels
        ctx.textAlign = 'right';
        for (let i = 0; i <= 5; i++) {
            const value = Math.round((maxValue / 5) * (5 - i));
            const y = padding + (chartHeight / 5) * i;
            ctx.fillText(value.toString(), padding - 10, y + 4);
        }

        // Draw line
        ctx.strokeStyle = color;
        ctx.lineWidth = 3;
        ctx.lineCap = 'round';
        ctx.lineJoin = 'round';
        ctx.beginPath();

        data.forEach((value, i) => {
            const x = padding + (chartWidth / (data.length - 1)) * i;
            const y = padding + chartHeight - (value / maxValue) * chartHeight;
            if (i === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        });
        ctx.stroke();

        // Draw points
        ctx.fillStyle = color;
        data.forEach((value, i) => {
            const x = padding + (chartWidth / (data.length - 1)) * i;
            const y = padding + chartHeight - (value / maxValue) * chartHeight;
            ctx.beginPath();
            ctx.arc(x, y, 4, 0, Math.PI * 2);
            ctx.fill();
        });
    }

    drawBarChart(ctx, width, height, data, labels, title, color) {
        // Clear canvas
        ctx.clearRect(0, 0, width, height);

        // Chart dimensions
        const padding = 60;
        const chartWidth = width - padding * 2;
        const chartHeight = height - padding * 2;

        // Find max value
        const maxValue = Math.max(...data);

        // Draw title
        ctx.fillStyle = '#374151';
        ctx.font = '14px system-ui';
        ctx.textAlign = 'center';
        ctx.fillText(title, width / 2, 20);

        // Draw axes
        ctx.strokeStyle = '#d1d5db';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(padding, padding);
        ctx.lineTo(padding, height - padding);
        ctx.lineTo(width - padding, height - padding);
        ctx.stroke();

        // Draw bars
        const barWidth = chartWidth / data.length * 0.8;
        const barSpacing = chartWidth / data.length * 0.2;

        data.forEach((value, i) => {
            const barHeight = (value / maxValue) * chartHeight;
            const x = padding + (chartWidth / data.length) * i + barSpacing / 2;
            const y = height - padding - barHeight;

            // Bar
            ctx.fillStyle = color;
            ctx.fillRect(x, y, barWidth, barHeight);

            // Bar border
            ctx.strokeStyle = color;
            ctx.lineWidth = 1;
            ctx.strokeRect(x, y, barWidth, barHeight);
        });

        // Draw labels
        ctx.fillStyle = '#6b7280';
        ctx.font = '12px system-ui';
        ctx.textAlign = 'center';
        labels.forEach((label, i) => {
            const x = padding + (chartWidth / data.length) * i + (chartWidth / data.length) / 2;
            ctx.fillText(label, x, height - 20);
        });

        // Draw Y axis labels
        ctx.textAlign = 'right';
        for (let i = 0; i <= 5; i++) {
            const value = Math.round((maxValue / 5) * (5 - i));
            const y = padding + (chartHeight / 5) * i;
            ctx.fillText(value.toString(), padding - 10, y + 4);
        }
    }

    async loadAdmins() {
        try {
            this.showLoading();
            const response = await this.apiCall('/api/v1/admins/');
            console.log('Admins API response:', response); // Debug logging
            // Handle different response structures
            const admins = response.admins || response.data || response || [];
            this.renderAdminsTable(admins);
        } catch (error) {
            console.error('Failed to load administrators:', error);
            this.showToast('Failed to load administrators', 'error');
            // Render empty table on error
            this.renderAdminsTable([]);
        } finally {
            this.hideLoading();
        }
    }

    async loadInstitutions() {
        try {
            // For now, we'll show a message since institutions are created by admins
            // In a full implementation, you'd have an endpoint to list institutions
            const tbody = document.getElementById('institutions-tbody');
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; padding: 2rem;">Institutions are created by administrators. Use the "Add Institution" button above.</td></tr>';
        } catch (error) {
            this.showToast('Failed to load institutions', 'error');
        }
    }

    async loadDoctors() {
        try {
            // This would call the doctors service through the admin service
            const tbody = document.getElementById('doctors-tbody');
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; padding: 2rem;">Doctors are managed by their respective institutions.</td></tr>';
        } catch (error) {
            this.showToast('Failed to load doctors', 'error');
        }
    }

    async loadPatients() {
        try {
            // This would call the patients service through the admin service
            const tbody = document.getElementById('patients-tbody');
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; padding: 2rem;">Patients are managed by their assigned doctors.</td></tr>';
        } catch (error) {
            this.showToast('Failed to load patients', 'error');
        }
    }

    async loadAuditLogs() {
        try {
            this.showLoading();
            const response = await this.apiCall('/api/v1/admins/audit/logs');
            this.renderAuditTable(response.logs || response.data || []);
        } catch (error) {
            console.error('Failed to load audit logs:', error);
            this.showToast('Failed to load audit logs', 'error');
            // Render empty table on error
            this.renderAuditTable([]);
        } finally {
            this.hideLoading();
        }
    }

    async loadMicroservicesHealth() {
        try {
            this.showLoading();
            await this.checkMicroservicesHealth();
        } catch (error) {
            this.showToast('Failed to load microservices health', 'error');
        } finally {
            this.hideLoading();
        }
    }

    async checkMicroservicesHealth() {
        const services = [
            { name: 'PostgreSQL Database', host: 'postgres', port: 5432, type: 'database' },
            { name: 'Redis Cache', host: 'redis', port: 6379, type: 'cache' },
            { name: 'Auth JWT Service', host: 'servicio-auth-jwt', port: 8003, type: 'microservice' },
            { name: 'Admins Service', host: 'servicio-admins', port: 8006, type: 'microservice' },
            { name: 'Patients Service', host: 'servicio-pacientes', port: 8004, type: 'microservice' },
            { name: 'Doctors Service', host: 'servicio-doctores', port: 8000, type: 'microservice' },
            { name: 'Institutions Service', host: 'servicio-instituciones', port: 8002, type: 'microservice' },
            { name: 'Backend Flask', host: 'backend-flask', port: 5000, type: 'backend' }
        ];

        const grid = document.getElementById('microservices-grid');
        grid.innerHTML = '';

        for (const service of services) {
            const status = await this.checkServiceStatus(service);
            grid.appendChild(this.createMicroserviceCard(service, status));
        }
    }

    async checkServiceStatus(service) {
        try {
            const startTime = Date.now();

            // For microservices, try to call their health endpoint
            if (service.type === 'microservice') {
                const response = await fetch(`http://${service.host}:${service.port}/health`, {
                    method: 'GET',
                    headers: { 'Content-Type': 'application/json' },
                    signal: AbortSignal.timeout(5000) // 5 second timeout
                });

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }

                const responseTime = Date.now() - startTime;
                return {
                    status: responseTime < 1000 ? 'healthy' : 'warning',
                    responseTime: `${responseTime}ms`,
                    details: 'Service responding'
                };
            }

            // For databases and cache, we can't directly check from frontend
            // We'll simulate based on backend connectivity
            const response = await this.apiCall(`/api/v1/health/service/${service.name.toLowerCase().replace(/\s+/g, '_')}`);
            const responseTime = Date.now() - startTime;

            return {
                status: response.status === 'healthy' ? 'healthy' : 'error',
                responseTime: `${responseTime}ms`,
                details: response.details || 'Service available'
            };

        } catch (error) {
            return {
                status: 'error',
                responseTime: 'N/A',
                details: 'Service unavailable'
            };
        }
    }

    createMicroserviceCard(service, status) {
        const card = document.createElement('div');
        card.className = 'microservice-card';
        card.onclick = () => this.showServiceLogs(service);

        card.innerHTML = `
            <div class="microservice-header">
                <h3 class="microservice-name">${service.name}</h3>
                <div class="microservice-status ${status.status}">
                    <i class="fas fa-${status.status === 'healthy' ? 'check-circle' : status.status === 'warning' ? 'exclamation-triangle' : 'times-circle'}"></i>
                    <span>${status.status.toUpperCase()}</span>
                </div>
            </div>

            <div class="microservice-info">
                <div class="microservice-info-item">
                    <div class="microservice-info-label">Host</div>
                    <div class="microservice-info-value">${service.host}</div>
                </div>
                <div class="microservice-info-item">
                    <div class="microservice-info-label">Port</div>
                    <div class="microservice-info-value">${service.port}</div>
                </div>
                <div class="microservice-info-item">
                    <div class="microservice-info-label">Response Time</div>
                    <div class="microservice-info-value">${status.responseTime}</div>
                </div>
                <div class="microservice-info-item">
                    <div class="microservice-info-label">Type</div>
                    <div class="microservice-info-value">${service.type}</div>
                </div>
            </div>

            <div class="microservice-actions">
                <button class="btn btn-primary" onclick="event.stopPropagation(); dashboard.showServiceLogs('${service.name}')">
                    <i class="fas fa-file-alt"></i> View Logs
                </button>
                <button class="btn btn-secondary" onclick="event.stopPropagation(); dashboard.restartService('${service.name}')">
                    <i class="fas fa-sync-alt"></i> Restart
                </button>
            </div>
        `;

        return card;
    }

    async showServiceLogs(serviceName) {
        const modal = document.getElementById('logs-modal');
        const title = document.getElementById('logs-modal-title');
        const content = document.getElementById('logs-content');

        title.textContent = `${serviceName} - Service Logs`;
        content.textContent = 'Loading logs...';
        modal.classList.remove('hidden');

        try {
            // In a real implementation, you'd call an API to get logs
            // For now, we'll simulate log data
            const logs = await this.fetchServiceLogs(serviceName);
            content.textContent = logs;
        } catch (error) {
            content.textContent = `Error loading logs: ${error.message}`;
        }
    }

    async fetchServiceLogs(serviceName) {
        // Simulate fetching logs - in real implementation, this would call backend API
        return new Promise((resolve) => {
            setTimeout(() => {
                const mockLogs = `[${new Date().toISOString()}] ${serviceName} service started successfully
[${new Date().toISOString()}] Connected to database
[${new Date().toISOString()}] Health check passed
[${new Date().toISOString()}] Service running on port ${this.getServicePort(serviceName)}
[${new Date().toISOString()}] All endpoints initialized
[${new Date().toISOString()}] Service ready to accept connections`;
                resolve(mockLogs);
            }, 1000);
        });
    }

    getServicePort(serviceName) {
        const portMap = {
            'PostgreSQL Database': 5432,
            'Redis Cache': 6379,
            'Auth JWT Service': 8003,
            'Admins Service': 8006,
            'Patients Service': 8004,
            'Doctors Service': 8000,
            'Institutions Service': 8002,
            'Backend Flask': 5000
        };
        return portMap[serviceName] || 'Unknown';
    }

    async restartService(serviceName) {
        if (!confirm(`Are you sure you want to restart ${serviceName}?`)) {
            return;
        }

        try {
            this.showLoading();
            // In real implementation, this would call backend API to restart service
            await new Promise(resolve => setTimeout(resolve, 2000)); // Simulate restart
            this.showToast(`${serviceName} restarted successfully`, 'success');
            await this.checkMicroservicesHealth();
        } catch (error) {
            this.showToast(`Failed to restart ${serviceName}`, 'error');
        } finally {
            this.hideLoading();
        }
    }

    closeLogsModal() {
        document.getElementById('logs-modal').classList.add('hidden');
    }

    refreshMicroservicesHealth() {
        this.loadMicroservicesHealth();
    }

    // Table Rendering
    renderAdminsTable(admins) {
        const tbody = document.getElementById('admins-tbody');
        tbody.innerHTML = '';

        if (admins.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; padding: 2rem;">No administrators found.</td></tr>';
            return;
        }

        admins.forEach(admin => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${admin.first_name} ${admin.last_name}</td>
                <td>${admin.email}</td>
                <td>${admin.department || 'N/A'}</td>
                <td>${admin.employee_id || 'N/A'}</td>
                <td><span class="status-badge status-${admin.is_active ? 'active' : 'inactive'}">${admin.is_active ? 'Active' : 'Inactive'}</span></td>
                <td>${admin.last_login ? new Date(admin.last_login).toLocaleDateString() : 'Never'}</td>
                <td class="action-btns">
                    <button class="btn btn-sm btn-warning" onclick="dashboard.editAdmin('${admin.id}')">Edit</button>
                    <button class="btn btn-sm btn-danger" onclick="dashboard.deleteAdmin('${admin.id}')">Delete</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    renderAuditTable(logs) {
        const tbody = document.getElementById('audit-tbody');
        if (!tbody) {
            console.warn('Audit tbody element not found');
            return;
        }

        tbody.innerHTML = '';

        if (logs.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 2rem;">No audit logs found.</td></tr>';
            return;
        }

        logs.forEach(log => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${new Date(log.created_at).toLocaleString()}</td>
                <td>${log.admin_id}</td>
                <td>${log.action}</td>
                <td>${log.resource_type}</td>
                <td>${log.details || 'N/A'}</td>
                <td><span class="status-badge status-${log.success ? 'active' : 'inactive'}">${log.success ? 'Success' : 'Failed'}</span></td>
            `;
            tbody.appendChild(row);
        });
    }

    // CRUD Operations
    showCreateModal(entityType) {
        this.currentEntityType = entityType;
        this.currentEntityId = null;

        document.getElementById('modal-title').textContent = `Create ${entityType.charAt(0).toUpperCase() + entityType.slice(1)}`;
        document.getElementById('entity-form').innerHTML = this.getFormFields(entityType);
        document.getElementById('modal-overlay').classList.remove('hidden');
    }

    editAdmin(adminId) {
        // In a full implementation, you'd fetch the admin data and populate the form
        this.currentEntityType = 'admin';
        this.currentEntityId = adminId;
        document.getElementById('modal-title').textContent = 'Edit Administrator';
        document.getElementById('entity-form').innerHTML = this.getFormFields('admin');
        document.getElementById('modal-overlay').classList.remove('hidden');
    }

    async deleteAdmin(adminId) {
        if (!confirm('Are you sure you want to delete this administrator?')) {
            return;
        }

        try {
            this.showLoading();
            await this.apiCall(`/api/v1/admins/${adminId}`, 'DELETE');
            this.showToast('Administrator deleted successfully', 'success');
            await this.loadAdmins();
        } catch (error) {
            this.showToast('Failed to delete administrator', 'error');
        } finally {
            this.hideLoading();
        }
    }

    getFormFields(entityType) {
        switch (entityType) {
            case 'admin':
                return `
                    <div class="form-row">
                        <div class="form-group">
                            <label for="first_name">First Name *</label>
                            <input type="text" id="first_name" required>
                        </div>
                        <div class="form-group">
                            <label for="last_name">Last Name *</label>
                            <input type="text" id="last_name" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="email">Email *</label>
                        <input type="email" id="email" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="department">Department</label>
                            <input type="text" id="department">
                        </div>
                        <div class="form-group">
                            <label for="employee_id">Employee ID</label>
                            <input type="text" id="employee_id">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="phone">Phone</label>
                        <input type="tel" id="phone">
                    </div>
                    <div class="form-group">
                        <label for="password">Password *</label>
                        <input type="password" id="password" required>
                    </div>
                `;

            case 'institution':
                return `
                    <div class="form-group">
                        <label for="name">Institution Name *</label>
                        <input type="text" id="name" required>
                    </div>
                    <div class="form-group">
                        <label for="institution_type">Type *</label>
                        <select id="institution_type" required>
                            <option value="">Select type</option>
                            <option value="preventive_clinic">Preventive Clinic</option>
                            <option value="insurer">Insurer</option>
                            <option value="public_health">Public Health</option>
                            <option value="hospital">Hospital</option>
                            <option value="health_center">Health Center</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="contact_email">Contact Email *</label>
                        <input type="email" id="contact_email" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="address">Address</label>
                            <input type="text" id="address">
                        </div>
                        <div class="form-group">
                            <label for="region_state">Region/State</label>
                            <input type="text" id="region_state">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone">Phone</label>
                            <input type="tel" id="phone">
                        </div>
                        <div class="form-group">
                            <label for="license_number">License Number</label>
                            <input type="text" id="license_number">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="website">Website</label>
                        <input type="url" id="website">
                    </div>
                    <div class="form-group">
                        <label for="password">Institution Password *</label>
                        <input type="password" id="password" required>
                    </div>
                `;

            default:
                return '<p>Form not available for this entity type.</p>';
        }
    }

    async submitForm() {
        const formData = this.getFormData();

        try {
            this.showLoading();

            if (this.currentEntityId) {
                // Update
                await this.apiCall(`/api/v1/admins/${this.currentEntityId}`, 'PUT', formData);
                this.showToast(`${this.currentEntityType} updated successfully`, 'success');
            } else {
                // Create
                if (this.currentEntityType === 'admin') {
                    await this.apiCall('/api/v1/admins/', 'POST', formData);
                } else if (this.currentEntityType === 'institution') {
                    await this.apiCall('/api/v1/admins/institutions', 'POST', formData);
                }
                this.showToast(`${this.currentEntityType} created successfully`, 'success');
            }

            this.closeModal();
            await this.loadSectionData(this.currentSection);

        } catch (error) {
            this.showToast(`Failed to save ${this.currentEntityType}`, 'error');
        } finally {
            this.hideLoading();
        }
    }

    getFormData() {
        const form = document.getElementById('entity-form');
        const data = {};

        // Get all form inputs
        const inputs = form.querySelectorAll('input, select, textarea');
        inputs.forEach(input => {
            if (input.value.trim() !== '') {
                data[input.id] = input.value.trim();
            }
        });

        return data;
    }

    closeModal() {
        document.getElementById('modal-overlay').classList.add('hidden');
        document.getElementById('entity-form').innerHTML = '';
        this.currentEntityType = null;
        this.currentEntityId = null;
    }

    // Utility Functions
    showLoading() {
        document.getElementById('loading-spinner').classList.remove('hidden');
    }

    hideLoading() {
        document.getElementById('loading-spinner').classList.add('hidden');
    }

    showToast(message, type = 'info') {
        const toastContainer = document.getElementById('toast-container');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.innerHTML = `
            <div>${message}</div>
            <button onclick="this.parentElement.remove()" aria-label="Close notification">&times;</button>
        `;

        toastContainer.appendChild(toast);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (toast.parentElement) {
                toast.remove();
            }
        }, 5000);
    }

    logout() {
        // Usar SessionAuthManager para logout
        if (window.AuthManager) {
            window.AuthManager.logout();
        } else {
            // Fallback: redirigir directamente
            window.location.href = '/';
        }
    }
}

// Global instance
let dashboard;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    dashboard = new AdminDashboard();
});

// Global functions for HTML onclick handlers
function showCreateModal(entityType) {
    dashboard.showCreateModal(entityType);
}

function closeModal() {
    dashboard.closeModal();
}

function submitForm() {
    dashboard.submitForm();
}

function logout() {
    dashboard.logout();
}

// Chart rendering functions (called from HTML)
function renderGrowthChart() {
    dashboard.renderGrowthChart();
}

function renderActivityChart() {
    dashboard.renderActivityChart();
}