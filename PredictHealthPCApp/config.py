# config.py - Configuración de colores y constantes de PredictHealth

# Colores PredictHealth
COLORS = {
    # Primary Colors
    'primary_blue': '#2196F3',
    'primary_blue_dark': '#2B1AE9',
    'primary_blue_light': '#67BFD5',
    
    # Secondary Colors
    'secondary_purple': '#8B5CF6',
    'secondary_purple_dark': '#7C3AED',
    'secondary_purple_light': '#A78BFA',
    
    # Neutrals
    'white': '#FFFFFF',
    'black': '#000000',
    'gray_light': '#F9FAFB',
    'gray_medium': '#6B7280',
    'gray_dark': '#374151',
    
    # Status
    'error_red': '#EF4444',
    'success_green': '#10B981',
    'warning_yellow': '#F59E0B'
}

# Configuración de la aplicación
APP_TITLE = "PredictHealth"
WINDOW_SIZE = "1800x1500"
LOGO_PATH = "assets/logo.jpg"

# Configuración del API (cambiar cuando tengas el backend real)
API_BASE_URL = "http://localhost:5000/api/web"  # Cambiar a tu URL del CMS
API_TIMEOUT = 10

# Rutas de endpoints (para cuando estén listos)
ENDPOINTS = {
    'login': '/auth/login',
    'logout': '/auth/logout',
    'perfil': '/usuarios/perfil',
    'historial': '/usuarios/historial',
    'reservaciones': '/reservaciones',
    'estadisticas': '/estadisticas'
}
