# Arquitectura de Microservicios - PredictHealth

## 1. Arquitectura y Flujo de Comunicación

### Flujo de una Petición Autenticada

```
Cliente (Frontend)
    ↓ [Cookie: predicthealth_jwt]
Backend Gateway (Flask)
    ↓ [@require_auth decorator]
    ↓ [POST /auth/verify-token]
Auth Service (JWT)
    ↓ [Token válido]
Backend Gateway
    ↓ [Headers: Authorization, X-User-ID, X-User-Type]
    ↓ [Proxy reverso]
Microservicio de Dominio (FastAPI)
    ↓ [get_current_user dependency]
    ↓ [verify_jwt_token]
    ↓ [Lógica de negocio]
Respuesta al Cliente
```

### Componentes Principales

#### 1.1 Backend Gateway (`backend-flask/app/api/v1/gateway.py`)

**Responsabilidades:**
- Intercepta todas las peticiones a rutas protegidas (`/patients/*`, `/doctors/*`, `/institutions/*`)
- Valida el token JWT antes de reenviar la petición
- Inyecta headers de contexto al microservicio destino

**Implementación:**

```12:48:backend-flask/app/api/v1/gateway.py
SERVICE_URLS = {
    "patients": os.getenv("PATIENTS_SERVICE_URL", "http://servicio-pacientes:8004"),
    "doctors": os.getenv("DOCTORS_SERVICE_URL", "http://servicio-doctores:8000"),
    "institutions": os.getenv("INSTITUTIONS_SERVICE_URL", "http://servicio-instituciones:8002"),
    "auth": os.getenv("AUTH_SERVICE_URL", "http://servicio-auth-jwt:8003"),
}

def require_auth(f):
    """Decorador para validar el token JWT antes de reenviar la solicitud."""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.cookies.get('predicthealth_jwt')

        if not token:
            return jsonify({"error": "Token de autenticación no proporcionado"}), 401

        try:
            auth_service_url = SERVICE_URLS.get("auth")
            verify_url = f"{auth_service_url}/auth/verify-token"
            auth_resp = requests.post(verify_url, headers={"Authorization": f"Bearer {token}"}, timeout=5)

            if auth_resp.status_code != 200:
                return jsonify({"error": "Token inválido o expirado"}), 401

            g.user_info = auth_resp.json().get("payload", {})

        except requests.exceptions.RequestException:
            return jsonify({"error": "No se pudo conectar con el servicio de autenticación"}), 503

        return f(*args, **kwargs)
    return decorated_function
```

**Proxy Reverso:**

```51:86:backend-flask/app/api/v1/gateway.py
def _proxy_request(service, path):
    """Función interna para reenviar una solicitud a un microservicio."""
    service_url = SERVICE_URLS.get(service)
    if not service_url:
        return jsonify({"error": "Servicio no encontrado"}), 404

    url = f"{service_url}{request.full_path}"

    headers = {key: value for (key, value) in request.headers if key.lower() not in ['host', 'cookie']}
    
    token = request.cookies.get('predicthealth_jwt')
    if token:
        headers['Authorization'] = f"Bearer {token}"
    data = request.get_data()

    if 'user_info' in g:
        headers['X-User-ID'] = g.user_info.get('user_id', '')
        headers['X-User-Type'] = g.user_info.get('user_type', '')

    try:
        resp = requests.request(
            method=request.method,
            url=url,
            headers=headers,
            data=data,
            timeout=10
        )
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        response_headers = [(name, value) for (name, value) in resp.raw.headers.items() if name.lower() not in excluded_headers]
        return Response(resp.content, resp.status_code, response_headers)

    except requests.exceptions.RequestException as e:
        return jsonify({"error": "Error de comunicación con el servicio", "details": str(e)}), 502
```

**Rutas de Proxy:**

```95:111:backend-flask/app/api/v1/gateway.py
@gateway_bp.route('/patients/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def patients_proxy(path):
    """Proxy protegido para el servicio de pacientes."""
    return _proxy_request('patients', f"/api/v1/patients/{path}")

@gateway_bp.route('/doctors/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def doctors_proxy(path):
    """Proxy protegido para el servicio de doctores."""
    return _proxy_request('doctors', f"/api/v1/doctors/{path}")

@gateway_bp.route('/institutions/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def institutions_proxy(path):
    """Proxy protegido para el servicio de instituciones."""
    return _proxy_request('institutions', f"/api/v1/institutions/{path}")
```

#### 1.2 Microservicio de Dominio (`service-patients/app/main.py`)

**Responsabilidades:**
- Valida el token JWT localmente (Zero Trust)
- Extrae el contexto del usuario para autorización granular
- Ejecuta la lógica de negocio específica del dominio

**Validación JWT:**

```39:55:microservices/service-patients/app/main.py
def verify_jwt_token(token: str) -> Dict[str, Any]:
    """Verifica y decodifica un token JWT."""
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Token inválido")

def get_current_user(authorization: str = Header(None)) -> Dict[str, Any]:
    """Obtiene el usuario actual desde el token JWT en el encabezado."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token de autorización 'Bearer' requerido")
    
    token = authorization.split(" ")[1]
    return verify_jwt_token(token)
```

**Autorización Granular:**

```57:62:microservices/service-patients/app/main.py
def require_patient_access(current_user: Dict[str, Any], patient_id: str):
    """Verifica que el usuario actual tenga permiso para acceder a los datos de un paciente."""
    user_id_from_token = current_user.get("reference_id") or current_user.get("user_id")
    
    if current_user.get("user_type") == "patient" and str(user_id_from_token) != patient_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para acceder a este recurso")
```

**Uso en Endpoints:**

```226:235:microservices/service-patients/app/main.py
@app.get("/api/v1/patients/{patient_id}", response_model=PatientResponse)
def get_patient(patient_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene la información detallada de un paciente específico."""
    require_patient_access(current_user, patient_id)
    
    patient_dict = _get_patient_details_from_db(patient_id)
    if not patient_dict:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Paciente no encontrado.")
    
    return patient_dict
```

#### 1.3 Servicio de Autenticación (`auth-jwt-service/app/main.py`)

**Responsabilidades:**
- Emisión de tokens JWT durante el login
- Validación centralizada de tokens (`/auth/verify-token`)
- Creación de usuarios de autenticación (`/users/create`)

**Login:**

```44:101:microservices/auth-jwt-service/app/main.py
@app.post("/auth/login")
def login(request: LoginRequest):
    try:
        if not request.email or not request.password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email y contraseña son requeridos"
            )
        
        query = "SELECT id, email, password_hash, user_type, reference_id, is_active FROM users WHERE email = %s"
        user_data = execute_query(query, (request.email,), fetch_one=True)
        if not user_data:
            logger.warning(f"Login attempt with non-existent email: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email o contraseña incorrectos"
            )

        if not verify_password(request.password, user_data['password_hash']):
            logger.warning(f"Failed password verification for email: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email o contraseña incorrectos"
            )

        if not user_data['is_active']:
            logger.warning(f"Login attempt for inactive user: {request.email}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Usuario desactivado. Contacte al administrador."
            )

        token_data = {
            "user_id": str(user_data['id']),
            "user_type": user_data['user_type'],
            "email": user_data['email'],
            "roles": [user_data['user_type']],
            "metadata": {"reference_id": str(user_data['reference_id'])}
        }

        access_token = create_access_token(data=token_data, expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        
        logger.info(f"Successful login for user: {request.email}, user_type: {user_data['user_type']}")
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": str(user_data['id']),
            "user_type": user_data['user_type'],
            "email": user_data['email'],
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "refresh_token": None
        }
```

**Verificación de Token:**

```113:124:microservices/auth-jwt-service/app/main.py
@app.post("/auth/verify-token", response_model=VerifyTokenResponse)
def verify_token(authorization: str = Header(..., alias="Authorization")):
    if not authorization.startswith("Bearer "):
        return VerifyTokenResponse(valid=False, payload=None)

    token = authorization.split(" ")[1]
    try:
        payload_dict = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM], options={"verify_exp": True})
        payload = TokenPayload(**payload_dict)
        return VerifyTokenResponse(valid=True, payload=payload)
    except jwt.PyJWTError:
        return VerifyTokenResponse(valid=False, payload=None)
```

## 2. Detalle de Autenticación

### 2.1 Principio Zero Trust

Cada microservicio valida el token JWT independientemente. El gateway actúa como primer filtro, pero no es suficiente para garantizar seguridad.

**Flujo de Validación:**

1. **Gateway**: Valida token contra Auth Service antes de reenviar
2. **Microservicio**: Valida token localmente usando `JWT_SECRET_KEY` compartido
3. **Autorización**: El microservicio usa el payload del token para decisiones de acceso

### 2.2 Estructura del Token JWT

```python
{
    "user_id": "uuid-del-usuario-auth",
    "user_type": "patient|doctor|institution",
    "email": "usuario@example.com",
    "roles": ["patient"],
    "metadata": {
        "reference_id": "uuid-de-la-entidad-de-dominio"
    },
    "exp": 1234567890
}
```

**Campos Clave:**
- `user_id`: ID del registro en la tabla `users` del Auth Service
- `reference_id`: ID de la entidad de dominio (paciente, doctor, institución)
- `user_type`: Tipo de usuario para routing y autorización

### 2.3 Creación de Usuario de Autenticación

Cuando se crea una entidad de dominio (paciente, doctor, institución), se debe crear también un usuario en el Auth Service:

```148:159:microservices/service-patients/app/main.py
        auth_user = create_auth_user(
            email=patient_data.contact_email.email_address,
            password=patient_data.password,
            user_type='patient',
            reference_id=patient_id
        )
        
        if not auth_user:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE, 
                detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada."
            )
```

**Cliente Compartido:**

```13:44:microservices/shared/auth_client.py
def create_user(email: str, password: str, user_type: str, reference_id: str) -> Optional[Dict[str, Any]]:
    """
    Llama al auth-jwt-service para crear un nuevo usuario.

    Args:
        email: Email del usuario.
        password: Contraseña en texto plano.
        user_type: Tipo de usuario ('patient', 'doctor', etc.).
        reference_id: El UUID de la entidad de dominio asociada.

    Returns:
        Un diccionario con los datos del usuario creado o None si falla.
    """
    create_url = f"{AUTH_SERVICE_URL}/users/create"
    payload = {
        "email": email,
        "password": password,
        "user_type": user_type,
        "reference_id": str(reference_id)
    }

    try:
        response = requests.post(create_url, json=payload, timeout=5)
        response.raise_for_status()
        logger.info(f"Usuario creado exitosamente en el servicio de autenticación para {email}")
        return response.json()
    except requests.exceptions.RequestException as e:
        logger.error(f"Error al conectar con auth-jwt-service: {e}")
        return None
    except Exception as e:
        logger.error(f"Error inesperado al crear usuario en auth-jwt-service: {e}")
        return None
```

### 2.4 Variables de Entorno Requeridas

**Backend Gateway:**
- `JWT_SECRET_KEY`: Clave secreta compartida para firmar/verificar tokens
- `JWT_ALGORITHM`: Algoritmo de firma (default: `HS256`)
- `PATIENTS_SERVICE_URL`: URL del servicio de pacientes
- `DOCTORS_SERVICE_URL`: URL del servicio de doctores
- `INSTITUTIONS_SERVICE_URL`: URL del servicio de instituciones
- `AUTH_SERVICE_URL`: URL del servicio de autenticación

**Microservicios de Dominio:**
- `JWT_SECRET_KEY`: Misma clave que el gateway
- `JWT_ALGORITHM`: Mismo algoritmo que el gateway
- `AUTH_SERVICE_URL`: URL del servicio de autenticación (para `create_user`)

## 3. Guía de Replicación para Doctores e Instituciones

### 3.1 Checklist de Implementación

#### Configuración Base

- [x] **Variables de Entorno**: Asegurar que `JWT_SECRET_KEY` y `JWT_ALGORITHM` sean idénticos en todos los servicios
- [x] **Gateway Routes**: Verificar que `gateway.py` tenga las rutas de proxy configuradas (ya existen en líneas 101-111)

#### Dependencias del Microservicio

- [ ] **JWT Library**: Instalar `pyjwt` en `requirements.txt`
- [ ] **Auth Client**: Importar `create_user` desde `shared.auth_client`

#### Implementación de Autenticación

- [ ] **Funciones de Validación**: Copiar `verify_jwt_token` y `get_current_user` de `service-patients/app/main.py` (líneas 39-55)
- [ ] **Función de Autorización**: Implementar `require_doctor_access` o `require_institution_access` según corresponda

**Ejemplo para Doctores:**

```python
def require_doctor_access(current_user: Dict[str, Any], doctor_id: str):
    """Verifica que el usuario actual tenga permiso para acceder a los datos de un doctor."""
    user_id_from_token = current_user.get("reference_id") or current_user.get("user_id")
    
    if current_user.get("user_type") == "doctor" and str(user_id_from_token) != doctor_id:
        raise HTTPException(status_code=403, detail="No tienes permiso para acceder a este recurso")
```

#### Rutas de la API

- [ ] **Prefijo de Rutas**: Todos los endpoints deben usar `/api/v1/doctors` o `/api/v1/institutions`
- [ ] **Dependencia de Autenticación**: Agregar `current_user: Dict[str, Any] = Depends(get_current_user)` a todos los endpoints protegidos
- [ ] **Autorización**: Llamar a la función de autorización antes de ejecutar la lógica de negocio

**Ejemplo de Endpoint:**

```python
@app.get("/api/v1/doctors/{doctor_id}", response_model=DoctorResponse)
def get_doctor(doctor_id: str, current_user: Dict[str, Any] = Depends(get_current_user)):
    """Obtiene la información detallada de un doctor específico."""
    require_doctor_access(current_user, doctor_id)
    
    doctor_dict = _get_doctor_details_from_db(doctor_id)
    if not doctor_dict:
        raise HTTPException(status_code=404, detail="Doctor no encontrado.")
    
    return doctor_dict
```

#### Creación de Entidades con Usuario de Auth

- [ ] **Transacción Atómica**: Envolver la creación de la entidad y del usuario de auth en una transacción
- [ ] **Rollback**: Si falla la creación del usuario de auth, hacer rollback de la entidad creada
- [ ] **Llamada a create_user**: Usar `create_auth_user` con `user_type='doctor'` o `user_type='institution'`

**Ejemplo de Transacción:**

```python
def _create_full_doctor_transaction(doctor_data: DoctorCreateRequest) -> UUID:
    """Ejecuta la creación completa de un doctor dentro de una transacción atómica."""
    with DatabaseConnection() as (conn, cursor):
        # Validar email único
        cursor.execute("SELECT id FROM emails WHERE email_address = %s", (doctor_data.contact_email.email_address,))
        if cursor.fetchone():
            raise HTTPException(status_code=409, detail="El email ya está en uso.")

        # Crear doctor
        doctor_query = """
            INSERT INTO doctors (...)
            VALUES (...)
            RETURNING id
        """
        cursor.execute(doctor_query, (...))
        doctor_id = cursor.fetchone()['id']

        # Crear email
        email_query = """
            INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
            VALUES ('doctor', %s, (SELECT id FROM email_types WHERE name = 'primary'), %s, TRUE, FALSE)
        """
        cursor.execute(email_query, (doctor_id, doctor_data.contact_email.email_address))

        # Crear usuario de autenticación
        auth_user = create_auth_user(
            email=doctor_data.contact_email.email_address,
            password=doctor_data.password,
            user_type='doctor',
            reference_id=doctor_id
        )
        
        if not auth_user:
            raise HTTPException(
                status_code=503, 
                detail="No se pudo crear la cuenta de usuario. La operación ha sido cancelada."
            )
            
    return doctor_id
```

### 3.2 Estructura de Archivos Esperada

```
microservices/
├── service-doctors/
│   └── app/
│       ├── main.py          # Endpoints con autenticación
│       ├── domain.py        # Modelos Pydantic
│       └── db.py            # Conexión a base de datos
├── service-institutions/
│   └── app/
│       ├── main.py          # Endpoints con autenticación
│       ├── domain.py        # Modelos Pydantic
│       └── db.py            # Conexión a base de datos
└── shared/
    └── auth_client.py       # Cliente HTTP para Auth Service
```

### 3.3 Verificación Post-Implementación

1. **Health Check**: Verificar que `/health` responda correctamente
2. **Autenticación**: Probar que endpoints protegidos rechacen peticiones sin token
3. **Autorización**: Verificar que usuarios solo puedan acceder a sus propios recursos
4. **Creación**: Validar que la creación de entidades también cree usuarios en Auth Service
5. **Gateway**: Confirmar que las rutas del gateway funcionen correctamente

### 3.4 Notas Importantes

- **JWT_SECRET_KEY**: Debe ser la misma en todos los servicios. Si cambia, todos los tokens existentes se invalidan.
- **Transacciones**: La creación de entidades y usuarios de auth debe ser atómica. Si falla una, debe fallar la otra.
- **Reference ID**: El `reference_id` en el token debe corresponder al ID de la entidad de dominio (doctor_id, institution_id).
- **User Type**: Debe coincidir exactamente con el tipo esperado ('doctor', 'institution', 'patient').

