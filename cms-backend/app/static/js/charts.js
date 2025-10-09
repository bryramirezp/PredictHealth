/**
 * PredictHealth CMS - Charts and Data Visualization
 */

CMS.charts = {
    instances: new Map(),

    /**
     * Create line chart
     */
    createLineChart: function(canvasId, data, label = 'Value', options = {}) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        // Destroy existing chart
        this.destroyChart(canvasId);

        const defaultOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            interaction: {
                intersect: false,
                mode: 'index'
            }
        };

        const chartOptions = { ...defaultOptions, ...options };

        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.labels || data.map(item => item.label || item.date || item.month),
                datasets: [{
                    label: label,
                    data: data.values || data.map(item => item.value || item.count),
                    borderColor: 'rgb(59, 130, 246)',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: 'rgb(59, 130, 246)',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: chartOptions
        });

        this.instances.set(canvasId, chart);
        return chart;
    },

    /**
     * Create bar chart
     */
    createBarChart: function(canvasId, data, label = 'Value', options = {}) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        this.destroyChart(canvasId);

        const defaultOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        };

        const chartOptions = { ...defaultOptions, ...options };

        const chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.labels || data.map(item => item.label || item.status || item.category),
                datasets: [{
                    label: label,
                    data: data.values || data.map(item => item.value || item.count),
                    backgroundColor: data.colors || 'rgba(59, 130, 246, 0.8)',
                    borderColor: data.borderColors || 'rgb(59, 130, 246)',
                    borderWidth: 1,
                    borderRadius: 4,
                    borderSkipped: false
                }]
            },
            options: chartOptions
        });

        this.instances.set(canvasId, chart);
        return chart;
    },

    /**
     * Create pie chart
     */
    createPieChart: function(canvasId, data, options = {}) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        this.destroyChart(canvasId);

        const defaultOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'right'
                }
            }
        };

        const chartOptions = { ...defaultOptions, ...options };

        const chart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: data.labels || data.map(item => item.label || item.category || item.type),
                datasets: [{
                    data: data.values || data.map(item => item.value || item.count),
                    backgroundColor: data.colors || [
                        '#3b82f6', '#10b981', '#f59e0b', '#ef4444',
                        '#8b5cf6', '#06b6d4', '#84cc16', '#f97316'
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: chartOptions
        });

        this.instances.set(canvasId, chart);
        return chart;
    },

    /**
     * Create doughnut chart
     */
    createDoughnutChart: function(canvasId, data, options = {}) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        this.destroyChart(canvasId);

        const defaultOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'right'
                }
            },
            cutout: '60%'
        };

        const chartOptions = { ...defaultOptions, ...options };

        const chart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: data.labels || data.map(item => item.label || item.category),
                datasets: [{
                    data: data.values || data.map(item => item.value || item.count),
                    backgroundColor: data.colors || [
                        '#3b82f6', '#10b981', '#f59e0b', '#ef4444',
                        '#8b5cf6', '#06b6d4', '#84cc16', '#f97316'
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: chartOptions
        });

        this.instances.set(canvasId, chart);
        return chart;
    },

    /**
     * Create horizontal bar chart
     */
    createHorizontalBarChart: function(canvasId, data, options = {}) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        this.destroyChart(canvasId);

        const defaultOptions = {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                x: {
                    beginAtZero: true
                }
            }
        };

        const chartOptions = { ...defaultOptions, ...options };

        const chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.labels || data.map(item => item.label || item.name),
                datasets: [{
                    label: data.datasetLabel || 'Value',
                    data: data.values || data.map(item => item.value || item.count || item.articles),
                    backgroundColor: data.colors || 'rgba(59, 130, 246, 0.8)',
                    borderColor: data.borderColors || 'rgb(59, 130, 246)',
                    borderWidth: 1,
                    borderRadius: 4,
                    borderSkipped: false
                }]
            },
            options: chartOptions
        });

        this.instances.set(canvasId, chart);
        return chart;
    },

    /**
     * Create multi-line chart
     */
    createMultiLineChart: function(canvasId, data, options = {}) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        this.destroyChart(canvasId);

        const defaultOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            interaction: {
                intersect: false,
                mode: 'index'
            }
        };

        const chartOptions = { ...defaultOptions, ...options };

        // Transform data for multi-line chart
        const datasets = [];
        const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

        if (data.datasets) {
            datasets.push(...data.datasets);
        } else {
            // Auto-generate datasets from data structure
            const keys = Object.keys(data[0] || {}).filter(key => key !== 'date' && key !== 'month' && key !== 'label');
            keys.forEach((key, index) => {
                datasets.push({
                    label: key.charAt(0).toUpperCase() + key.slice(1),
                    data: data.map(item => item[key]),
                    borderColor: colors[index % colors.length],
                    backgroundColor: colors[index % colors.length] + '20',
                    borderWidth: 2,
                    fill: false,
                    tension: 0.4,
                    pointBackgroundColor: colors[index % colors.length],
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                });
            });
        }

        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.map(item => item.date || item.month || item.label),
                datasets: datasets
            },
            options: chartOptions
        });

        this.instances.set(canvasId, chart);
        return chart;
    },

    /**
     * Create area chart
     */
    createAreaChart: function(canvasId, data, label = 'Value', options = {}) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        this.destroyChart(canvasId);

        const defaultOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            interaction: {
                intersect: false,
                mode: 'index'
            }
        };

        const chartOptions = { ...defaultOptions, ...options };

        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.labels || data.map(item => item.label || item.date),
                datasets: [{
                    label: label,
                    data: data.values || data.map(item => item.value || item.count),
                    borderColor: 'rgb(59, 130, 246)',
                    backgroundColor: 'rgba(59, 130, 246, 0.3)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: 'rgb(59, 130, 246)',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: chartOptions
        });

        this.instances.set(canvasId, chart);
        return chart;
    },

    /**
     * Update chart data
     */
    updateChart: function(canvasId, newData, newLabels = null) {
        const chart = this.instances.get(canvasId);
        if (!chart) return;

        if (newLabels) {
            chart.data.labels = newLabels;
        }

        chart.data.datasets.forEach((dataset, index) => {
            if (newData[index]) {
                dataset.data = newData[index];
            } else if (index === 0 && newData.length > 0) {
                dataset.data = newData;
            }
        });

        chart.update();
    },

    /**
     * Destroy chart
     */
    destroyChart: function(canvasId) {
        const chart = this.instances.get(canvasId);
        if (chart) {
            chart.destroy();
            this.instances.delete(canvasId);
        }
    },

    /**
     * Destroy all charts
     */
    destroyAll: function() {
        this.instances.forEach((chart, canvasId) => {
            this.destroyChart(canvasId);
        });
    },

    /**
     * Resize all charts
     */
    resizeAll: function() {
        this.instances.forEach(chart => {
            chart.resize();
        });
    }
};

// Initialize charts on page load
document.addEventListener('DOMContentLoaded', function() {
    // Auto-resize charts on window resize
    let resizeTimeout;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(() => {
            CMS.charts.resizeAll();
        }, 250);
    });
});

// Export for global use
window.CMS = window.CMS || {};
window.CMS.charts = CMS.charts;