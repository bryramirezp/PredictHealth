# common/users.py

import os
import json
import random
import csv
import datetime
from locust import HttpUser, task, between, tag
from locust.clients import HttpSession
from locust.exception import StopUser

# --- Configuración Específica de Hosts ---
TEST_CONFIG = {
    "hosts": {
        "auth": "http://localhost:8003",
        "doctors": "http://localhost:8000",
        "patients": "http://localhost:8004",
        "institutions": "http://localhost:8002"
    }
}

# --- Datos de Prueba para Filtros Realistas ---
DOCTOR_SPECIALTIES = ["Cardiology", "Dermatology", "Neurology", "Pediatrics", "General Medicine", "Endocrinology", "Family Medicine", "Internal Medicine"]
PATIENT_GENDERS = ["Male", "Female", "Other"]
INSTITUTION_TYPES = ["hospital", "preventive_clinic", "health_center"]
REGIONS = ["Ciudad de México", "Nuevo León", "Jalisco", "Guanajuato", "Yucatán", "Sinaloa"]

# --- Carga de Credenciales ---
def load_user_credentials():
    credentials = {"doctors": [], "patients": [], "institutions": []}
    try:
        with open('user.csv', 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                user_id, email, pwd = row.get('id', '').strip(), row.get('email', '').strip(), row.get('password', '').strip()
                if user_id and email and pwd:
                    credential_data = {"id": user_id, "email": email, "password": pwd}
                    if email.startswith('dr.'): credentials["doctors"].append(credential_data)
                    elif email.startswith('contacto@'): credentials["institutions"].append(credential_data)
                    else: credentials["patients"].append(credential_data)
        print(f"✅ Loaded {len(credentials['doctors'])} doctors, {len(credentials['patients'])} patients, {len(credentials['institutions'])} institutions.")
        return credentials
    except FileNotFoundError:
        print("⚠️ user.csv not found. Users will not be able to log in.")
        return credentials
USER_CREDENTIALS = load_user_credentials()

# --- Clases de Usuario Base y Específicas ---

class BasePredictHealthUser(HttpUser):
    abstract = True
    wait_time = between(1, 3)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.auth_token, self.user_credentials, self.user_id = None, None, None
        self.retrieved_ids = {"doctors": [], "institutions": []}

    def on_start(self):
        self.login()
        if not self.auth_token:
            # Si el login falla, se detiene este usuario virtual para no generar errores en cascada.
            raise StopUser()

    def login(self):
        if self.user_credentials:
            try:
                login_payload = {"email": self.user_credentials["email"], "password": self.user_credentials["password"]}
                auth_host = TEST_CONFIG["hosts"]["auth"]
                login_url = f"{auth_host}/auth/login"

                with self.client.post(login_url, json=login_payload, catch_response=True, name="/auth/login") as resp:
                    if resp.ok:
                        self.auth_token = resp.json().get("access_token")
                        self.user_id = self.user_credentials.get("id")
                    else:
                        resp.failure(f"Login failed for {self.user_credentials['email']} with status {resp.status_code}")
            except Exception as e:
                self.environment.events.request.fire(request_type="POST", name="/auth/login", response_time=0, response_length=0, exception=e)

    def get_auth_headers(self):
        return {"Authorization": f"Bearer {self.auth_token}"}

class DoctorUser(BasePredictHealthUser):
    host = TEST_CONFIG["hosts"]["doctors"]
    
    def on_start(self):
        if USER_CREDENTIALS["doctors"]: self.user_credentials = random.choice(USER_CREDENTIALS["doctors"])
        super().on_start()

    @task(1)
    @tag("health", "smoke")
    def health_check(self): self.client.get("/health", name="/health")
    
    @task(10)
    @tag("read")
    def list_doctors(self):
        with self.client.get("/api/v1/doctors", headers=self.get_auth_headers(), name="/api/v1/doctors", catch_response=True) as response:
            if response.ok and response.text:
                try:
                    data = response.json()
                    if isinstance(data, list) and data: self.retrieved_ids["doctors"] = [item.get('id') for item in data if item.get('id')]
                except json.JSONDecodeError: pass
    
    @task(5)
    @tag("read")
    def get_doctor_by_id(self):
        if not self.retrieved_ids["doctors"]: return
        self.client.get(f"/api/v1/doctors/{random.choice(self.retrieved_ids['doctors'])}", headers=self.get_auth_headers(), name="/api/v1/doctors/{doctor_id}")

    @task(1)
    @tag("write")
    def create_doctor(self):
        if not USER_CREDENTIALS["institutions"]: return
        payload = {
            "first_name": "LoadTest", "last_name": f"Doctor-{random.randint(1000, 9999)}",
            "sex_id": random.randint(1, 2),
            "medical_license": f"MED-LT-{random.randint(10000, 99999)}",
            "specialty_id": random.randint(1, 8),
            "years_experience": random.randint(1, 30),
            "consultation_fee": round(random.uniform(500.0, 2000.0), 2),
            "institution_id": random.choice(USER_CREDENTIALS["institutions"])["id"],
            "professional_status": "active"
        }
        self.client.post("/api/v1/doctors", headers=self.get_auth_headers(), json=payload, name="/api/v1/doctors")

    @task(3)
    @tag("read", "stats")
    def get_statistics(self): self.client.get("/api/v1/doctors/statistics", headers=self.get_auth_headers(), name="/api/v1/doctors/statistics")

class PatientUser(BasePredictHealthUser):
    host = TEST_CONFIG["hosts"]["patients"]
    
    def on_start(self):
        if USER_CREDENTIALS["patients"]: self.user_credentials = random.choice(USER_CREDENTIALS["patients"])
        super().on_start()

    @task(1)
    @tag("health", "smoke")
    def health_check(self): self.client.get("/health", name="/health")

    @task(10)
    @tag("read")
    def list_patients(self): self.client.get("/api/v1/patients", headers=self.get_auth_headers(), name="/api/v1/patients")

    @task(1)
    @tag("write")
    def create_patient(self):
        if not USER_CREDENTIALS["doctors"] or not USER_CREDENTIALS["institutions"]: return
        start_date, end_date = datetime.date(1950, 1, 1), datetime.date(2005, 12, 31)
        random_date = start_date + datetime.timedelta(days=random.randint(0, (end_date - start_date).days))
        
        # === CORRECCIÓN DEFINITIVA ===
        # El payload ahora usa `sex_id` y `gender_id` como enteros, igual que en populate.txt
        payload = {
            "first_name": "LoadTest", "last_name": f"Patient-{random.randint(1000, 9999)}",
            "date_of_birth": random_date.isoformat(),
            "sex_id": random.randint(1, 2), # Asumiendo 1=male, 2=female
            "gender_id": random.randint(1, 3), # Asumiendo IDs 1, 2, 3 para géneros
            "doctor_id": random.choice(USER_CREDENTIALS["doctors"])["id"],
            "institution_id": random.choice(USER_CREDENTIALS["institutions"])["id"]
        }
        self.client.post("/api/v1/patients", headers=self.get_auth_headers(), json=payload, name="/api/v1/patients")

class InstitutionUser(BasePredictHealthUser):
    host = TEST_CONFIG["hosts"]["institutions"]
    
    def on_start(self):
        if USER_CREDENTIALS["institutions"]: self.user_credentials = random.choice(USER_CREDENTIALS["institutions"])
        super().on_start()
        
    @task(1)
    @tag("health", "smoke")
    def health_check(self): self.client.get("/health", name="/health")

    @task(10)
    @tag("read")
    def list_institutions(self):
        with self.client.get("/api/v1/institutions", headers=self.get_auth_headers(), name="/api/v1/institutions", catch_response=True) as response:
            if response.ok and response.text:
                try:
                    data = response.json()
                    if isinstance(data, list) and data: self.retrieved_ids["institutions"] = [item.get('id') for item in data if item.get('id')]
                except json.JSONDecodeError: pass
    
    @task(5)
    @tag("read")
    def get_institution_by_id(self):
        if not self.retrieved_ids["institutions"]: return
        self.client.get(f"/api/v1/institutions/{random.choice(self.retrieved_ids['institutions'])}", headers=self.get_auth_headers(), name="/api/v1/institutions/{institution_id}")

    @task(4)
    @tag("read")
    def search_institutions(self):
        payload = {"query": random.choice(["Clinic", "Lab", "Hospital", "Center"])}
        self.client.post("/api/v1/institutions/search", headers=self.get_auth_headers(), json=payload, name="/api/v1/institutions/search")

    @task(1)
    @tag("write")
    def update_institution(self):
        if not self.retrieved_ids["institutions"]: return
        institution_id = random.choice(self.retrieved_ids["institutions"])
        payload = {"region": random.choice(REGIONS)}
        self.client.put(f"/api/v1/institutions/{institution_id}", headers=self.get_auth_headers(), json=payload, name="/api/v1/institutions/{institution_id} (PUT)")