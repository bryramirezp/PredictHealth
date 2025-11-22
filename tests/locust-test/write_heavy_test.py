# write_heavy_test.py
"""
Prueba de Escritura Intensiva (Write-Heavy Test):
- Objetivo: Estresar la capacidad del sistema para crear y actualizar datos (POST, PUT).
- Carga: Baja a moderada (las escrituras son más costosas).
- Duración: Moderada (5-10 minutos).
- Tareas: Solo ejecuta las tareas etiquetadas como 'write'.
"""

from common.users import DoctorUser, PatientUser, InstitutionUser
import common.reporting

# --- Comandos para Ejecutar esta Prueba ---
#
# Windows (PowerShell):
# $env:DOCTORS="20"; $env:PATIENTS="20"; $env:INSTITUTIONS="20"; locust -f write_heavy_test.py --headless -u 60 -r 6 --run-time 5m -T write
#
# Linux / macOS / Git Bash:
# DOCTORS=20 PATIENTS=20 INSTITUTIONS=20 locust -f write_heavy_test.py --headless -r 6 --run-time 5m -T write