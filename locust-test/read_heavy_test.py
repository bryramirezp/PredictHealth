# read_heavy_test.py
"""
Prueba de Lectura Intensiva (Read-Heavy Test):
- Objetivo: Estresar la capacidad del sistema para servir datos (operaciones GET y de búsqueda).
- Carga: Alta (ej. 150 usuarios en total, 50 de cada tipo).
- Duración: Moderada (5-10 minutos).
- Tareas: Solo ejecuta las tareas etiquetadas como 'read' en el archivo common/users.py.
"""

# Importa las clases de usuario que contienen la lógica de las tareas.
from common.users import DoctorUser, PatientUser, InstitutionUser

# Importa el módulo de reportes. Esto activa automáticamente los listeners de eventos
# para recolectar métricas y generar los reportes HTML y CSV al finalizar.
import common.reporting

# --- Comandos para Ejecutar esta Prueba ---
#
# Windows (PowerShell):
# $env:DOCTORS="50"; $env:PATIENTS="50"; $env:INSTITUTIONS="50"; locust -f read_heavy_test.py --headless -u 150 -r 15 --run-time 5m -T read
#
# Linux / macOS / Git Bash:
# DOCTORS=50 PATIENTS=50 INSTITUTIONS=50 locust -f read_heavy_test.py --headless -u 150 -r 15 --run-time 5m -T read