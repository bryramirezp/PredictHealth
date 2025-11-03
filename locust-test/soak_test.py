# soak_test.py
"""
Prueba de Resistencia (Soak Test):
- Objetivo: Detectar degradación de rendimiento o fugas de memoria bajo carga sostenida.
- Carga: Moderada y constante.
- Duración: Larga (30+ minutos).
- Tareas: Ejecuta todas las tareas EXCEPTO las de 'smoke'.
"""

from common.users import DoctorUser, PatientUser, InstitutionUser
import common.reporting

# --- Comandos para Ejecutar esta Prueba ---
#
# Windows (PowerShell):
# $env:DOCTORS="30"; $env:PATIENTS="30"; $env:INSTITUTIONS="30"; locust -f soak_test.py --headless -u 90 -r 10 --run-time 30m -E smoke
#
# Linux / macOS / Git Bash:
# DOCTORS=30 PATIENTS=30 INSTITUTIONS=30 locust -f soak_test.py --headless -r 10 --run-time 30m -E smoke