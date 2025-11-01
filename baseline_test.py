# baseline_test.py
"""
Prueba de Línea Base (Baseline Test):
- Objetivo: Establecer una métrica de rendimiento base con una carga moderada y constante.
- Carga: 50 usuarios de cada tipo (150 en total).
- Duración: Corta (5 minutos).
- Tareas: Ejecuta todas las tareas (lectura, escritura) EXCEPTO las de 'smoke'.
"""

from common.users import DoctorUser, PatientUser, InstitutionUser
import common.reporting

# --- Comandos para Ejecutar esta Prueba ---
#
# Windows (PowerShell):
# $env:DOCTORS="50"; $env:PATIENTS="50"; $env:INSTITUTIONS="50"; locust -f baseline_test.py --headless -u 150 -r 15 --run-time 5m -E smoke
#
# Linux / macOS / Git Bash:
# DOCTORS=50 PATIENTS=50 INSTITUTIONS=50 locust -f baseline_test.py --headless -r 15 --run-time 5m -E smoke