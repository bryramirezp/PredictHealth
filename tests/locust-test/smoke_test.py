# smoke_test.py
"""
Prueba de Humo (Smoke Test):
- Objetivo: Verificar rápidamente que todos los servicios están en línea y responden.
- Carga: Muy baja (5 usuarios de cada tipo).
- Duración: Muy corta (1 minuto).
- Tareas: Solo ejecuta las tareas etiquetadas como 'smoke' (los endpoints /health).
"""

# Importa las clases de usuario que contienen la lógica de las tareas.
from common.users import DoctorUser, PatientUser, InstitutionUser

# Importa el módulo de reportes. Esto activa automáticamente los listeners de eventos
# para recolectar métricas y generar los reportes HTML y CSV al finalizar.
import common.reporting

# --- Comandos para Ejecutar esta Prueba ---
#
# Windows (PowerShell):
# $env:DOCTORS="5"; $env:PATIENTS="5"; $env:INSTITUTIONS="5"; locust -f smoke_test.py --headless -u 15 -r 3 --run-time 1m -T smoke

# Linux / macOS / Git Bash:
# DOCTORS=5 PATIENTS=5 INSTITUTIONS=5 locust -f smoke_test.py --headless -r 3 --run-time 1m -T smoke