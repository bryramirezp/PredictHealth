# shape_spike_test.py
"""
Prueba de Picos (Spike Test):
- Objetivo: Observar cómo se comporta y recupera el sistema ante un pico de carga repentino.
- Carga: Controlada por la clase CustomShape.
- Duración: Definida por la suma de las duraciones de las etapas en CustomShape.
- Tareas: Ejecuta todas las tareas EXCEPTO las de 'smoke'.
"""

from locust.shape import LoadTestShape

# Importa la lógica de comportamiento y reportes
from common.users import DoctorUser, PatientUser, InstitutionUser
import common.reporting

class CustomShape(LoadTestShape):
    """
    Define una forma de carga con una base, un pico repentino y una recuperación.
    """
    stages = [
        {"duration": 60, "users": 200, "spawn_rate": 50},   # Etapa 1: Carga base de 200 usuarios
        {"duration": 120, "users": 200, "spawn_rate": 50},  # Etapa 2: Mantener carga base
        {"duration": 10, "users": 1000, "spawn_rate": 80},  # Etapa 3: PICO (subir de 200 a 1000 en 10s)
        {"duration": 120, "users": 1000, "spawn_rate": 80}, # Etapa 4: Mantener el pico
        {"duration": 60, "users": 0, "spawn_rate": 50},     # Etapa 5: Bajar a 0
    ]
    
    def tick(self):
        run_time = self.get_run_time()
        for stage in self.stages:
            if run_time < stage["duration"]:
                return (stage["users"], stage["spawn_rate"])
            run_time -= stage["duration"]
        return None # Fin de la prueba

# --- Comandos para Ejecutar esta Prueba ---
#
# Windows (PowerShell) / Linux / macOS:
# (No se usan variables de entorno para el número de usuarios)
# locust -f shape_spike_test.py --headless -E smoke