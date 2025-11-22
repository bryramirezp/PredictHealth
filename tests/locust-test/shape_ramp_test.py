# shape_ramp_test.py
"""
Prueba de Rampa (Ramp-Up / Ramp-Down Test):
- Objetivo: Simular un crecimiento y decrecimiento gradual de usuarios para ver cómo escala el sistema.
- Carga: Controlada por la clase CustomShape, no por variables de entorno.
- Duración: Definida por la suma de las duraciones de las etapas en CustomShape.
- Tareas: Ejecuta todas las tareas EXCEPTO las de 'smoke'.
"""

from locust.shape import LoadTestShape

# Importa la lógica de comportamiento y reportes
from common.users import DoctorUser, PatientUser, InstitutionUser
import common.reporting

class CustomShape(LoadTestShape):
    """
    Define una forma de carga con etapas de subida, meseta y bajada.
    """
    stages = [
        {"duration": 60, "users": 100, "spawn_rate": 10},   # Etapa 1: Subir a 100 usuarios en 60s
        {"duration": 180, "users": 100, "spawn_rate": 10},  # Etapa 2: Mantener 100 usuarios por 180s
        {"duration": 60, "users": 0, "spawn_rate": 10},     # Etapa 3: Bajar a 0 usuarios en 60s
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
# locust -f shape_ramp_test.py --headless -E smoke