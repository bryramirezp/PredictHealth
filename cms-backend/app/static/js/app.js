/**
 * PredictHealth CMS - Main JavaScript Application
 */

// Global CMS object
window.CMS = window.CMS || {};

// Configuration
CMS.config = {
    apiBaseUrl: '/api',
    csrfToken: document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
    currentUser: null,
    theme: 'light'
};

// Utility functions
CMS.utils = {
    /**
     * Show loading spinner
     */
    showLoading: function(element = document.body) {
        const spinner = document.createElement('div');
        spinner.className = 'loading-overlay';
        spinner.id = 'cms-loading';
        spinner.innerHTML = `
            <div class="loading-spinner"></div>
            <div style="margin-top: 1rem; color: var(--text-secondary);">Loading...</div>
        `;
        element.style.position = 'relative';
        element.appendChild(spinner);
    },

    /**
     * Hide loading spinner
     */
    hideLoading: function() {
        const spinner = document.getElementById('cms-loading');
        if (spinner) {
            spinner.remove();
        }
    },

    /**
     * Show alert message
     */
    showAlert: function(message, type = 'info', duration = 5000) {
        // Remove existing alerts
        const existingAlerts = document.querySelectorAll('.cms-alert');
        existingAlerts.forEach(alert => alert.remove());

        const alertDiv = document.createElement('div');
        alertDiv.className = `cms-alert cms-alert-${type}`;
        alertDiv.innerHTML = `
            <div class="cms-alert-icon">
                <i class="bi bi-${type === 'success' ? 'check-circle' :
                               type === 'error' ? 'exclamation-triangle' :
                               type === 'warning' ? 'exclamation-circle' : 'info-circle'}"></i>
            </div>
            <div>${message}</div>
        `;

        // Insert at top of page
        const container = document.querySelector('.cms-container') || document.body;
        container.insertBefore(alertDiv, container.firstChild);

        // Auto remove after duration
        if (duration > 0) {
            setTimeout(() => {
                if (alertDiv.parentNode) {
                    alertDiv.remove();
                }
            }, duration);
        }

        return alertDiv;
    },

    /**
     * Confirm dialog
     */
    confirm: function(message, title = 'Confirm Action') {
        return new Promise((resolve) => {
            const modal = document.createElement('div');
            modal.className = 'cms-modal open';
            modal.innerHTML = `
                <div class="cms-modal-dialog">
                    <div class="cms-modal-header">
                        <h3 class="cms-modal-title">${title}</h3>
                        <button class="cms-modal-close" onclick="this.closest('.cms-modal').remove(); resolve(false);">&times;</button>
                    </div>
                    <div class="cms-modal-body">
                        <p>${message}</p>
                    </div>
                    <div class="cms-modal-footer">
                        <button class="btn btn-secondary" onclick="this.closest('.cms-modal').remove(); resolve(false);">Cancel</button>
                        <button class="btn btn-danger" onclick="this.closest('.cms-modal').remove(); resolve(true);">Confirm</button>
                    </div>
                </div>
            `;
            document.body.appendChild(modal);
        });
    },

    /**
     * Format date
     */
    formatDate: function(date, format = 'short') {
        if (!date) return 'N/A';

        const d = new Date(date);
        if (isNaN(d.getTime())) return 'Invalid Date';

        if (format === 'short') {
            return d.toLocaleDateString();
        } else if (format === 'long') {
            return d.toLocaleDateString() + ' ' + d.toLocaleTimeString();
        }

        return d.toISOString().split('T')[0];
    },

    /**
     * Format number
     */
    formatNumber: function(num, decimals = 0) {
        if (num === null || num === undefined) return '0';

        return new Intl.NumberFormat('en-US', {
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        }).format(num);
    },

    /**
     * Debounce function
     */
    debounce: function(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },

    /**
     * Copy to clipboard
     */
    copyToClipboard: function(text) {
        if (navigator.clipboard) {
            navigator.clipboard.writeText(text).then(() => {
                this.showAlert('Copied to clipboard!', 'success', 2000);
            });
        } else {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            this.showAlert('Copied to clipboard!', 'success', 2000);
        }
    },

    /**
     * Get URL parameters
     */
    getUrlParams: function() {
        const params = {};
        const urlParams = new URLSearchParams(window.location.search);
        for (const [key, value] of urlParams) {
            params[key] = value;
        }
        return params;
    },

    /**
     * Set URL parameters
     */
    setUrlParams: function(params) {
        const url = new URL(window.location);
        Object.keys(params).forEach(key => {
            if (params[key] === null || params[key] === undefined || params[key] === '') {
                url.searchParams.delete(key);
            } else {
                url.searchParams.set(key, params[key]);
            }
        });
        window.history.replaceState({}, '', url);
    }
};

// API functions
CMS.api = {
    /**
     * Make API request
     */
    request: async function(url, options = {}) {
        const defaultOptions = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': CMS.config.csrfToken
            }
        };

        const finalOptions = { ...defaultOptions, ...options };

        if (finalOptions.body && typeof finalOptions.body === 'object') {
            finalOptions.body = JSON.stringify(finalOptions.body);
        }

        try {
            const response = await fetch(url, finalOptions);

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return await response.json();
            } else {
                return await response.text();
            }
        } catch (error) {
            console.error('API request failed:', error);
            throw error;
        }
    },

    /**
     * GET request
     */
    get: function(url) {
        return this.request(url);
    },

    /**
     * POST request
     */
    post: function(url, data) {
        return this.request(url, {
            method: 'POST',
            body: data
        });
    },

    /**
     * PUT request
     */
    put: function(url, data) {
        return this.request(url, {
            method: 'PUT',
            body: data
        });
    },

    /**
     * DELETE request
     */
    delete: function(url) {
        return this.request(url, {
            method: 'DELETE'
        });
    }
};

// Sidebar functionality
CMS.sidebar = {
    init: function() {
        this.bindEvents();
        this.setActiveLink();
    },

    bindEvents: function() {
        // Mobile sidebar toggle
        const mobileToggle = document.getElementById('mobile-sidebar-toggle');
        if (mobileToggle) {
            mobileToggle.addEventListener('click', () => this.toggle());
        }

        // Sidebar close button
        const closeBtn = document.querySelector('.cms-sidebar-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => this.close());
        }

        // Click outside to close
        document.addEventListener('click', (e) => {
            const sidebar = document.querySelector('.cms-sidebar');
            const toggle = document.getElementById('mobile-sidebar-toggle');

            if (sidebar && sidebar.classList.contains('open')) {
                if (!sidebar.contains(e.target) && e.target !== toggle && !toggle.contains(e.target)) {
                    this.close();
                }
            }
        });

        // Window resize
        window.addEventListener('resize', () => {
            if (window.innerWidth > 768) {
                this.close();
            }
        });
    },

    toggle: function() {
        const sidebar = document.querySelector('.cms-sidebar');
        const main = document.querySelector('.cms-main');

        if (sidebar.classList.contains('open')) {
            this.close();
        } else {
            this.open();
        }
    },

    open: function() {
        const sidebar = document.querySelector('.cms-sidebar');
        const main = document.querySelector('.cms-main');

        if (sidebar) sidebar.classList.add('open');
        if (main) main.classList.add('sidebar-open');
    },

    close: function() {
        const sidebar = document.querySelector('.cms-sidebar');
        const main = document.querySelector('.cms-main');

        if (sidebar) sidebar.classList.remove('open');
        if (main) main.classList.remove('sidebar-open');
    },

    setActiveLink: function() {
        const currentPath = window.location.pathname;
        const links = document.querySelectorAll('.cms-nav-link');

        links.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === currentPath) {
                link.classList.add('active');
            }
        });
    }
};

// User menu functionality
CMS.userMenu = {
    init: function() {
        const trigger = document.querySelector('.cms-user-trigger');
        if (trigger) {
            trigger.addEventListener('click', (e) => {
                e.stopPropagation();
                this.toggle();
            });
        }

        // Close on outside click
        document.addEventListener('click', (e) => {
            const menu = document.querySelector('.cms-user-menu');
            const trigger = document.querySelector('.cms-user-trigger');

            if (menu && menu.classList.contains('open')) {
                if (!menu.contains(e.target)) {
                    this.close();
                }
            }
        });
    },

    toggle: function() {
        const menu = document.querySelector('.cms-user-menu');
        if (menu) {
            menu.classList.toggle('open');
        }
    },

    open: function() {
        const menu = document.querySelector('.cms-user-menu');
        if (menu) {
            menu.classList.add('open');
        }
    },

    close: function() {
        const menu = document.querySelector('.cms-user-menu');
        if (menu) {
            menu.classList.remove('open');
        }
    }
};

// Modal functionality
CMS.modal = {
    open: function(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.add('open');
            document.body.style.overflow = 'hidden';
        }
    },

    close: function(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.remove('open');
            document.body.style.overflow = '';
        }
    },

    closeAll: function() {
        const modals = document.querySelectorAll('.cms-modal.open');
        modals.forEach(modal => {
            modal.classList.remove('open');
        });
        document.body.style.overflow = '';
    }
};

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    CMS.sidebar.init();
    CMS.userMenu.init();

    // Close modals on escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            CMS.modal.closeAll();
        }
    });

    // Auto-hide alerts after 5 seconds
    setTimeout(() => {
        const alerts = document.querySelectorAll('.cms-alert');
        alerts.forEach(alert => alert.remove());
    }, 5000);
});

// Export for global use
window.CMS = CMS;