# PredictHealth - Aplicación de Escritorio

Aplicación de gestión de salud personal desarrollada con Python y CustomTkinter para pacientes.

## Características

- Autenticación JWT con validación de tipo de usuario (solo pacientes)
- Dashboard con 6 gráficas de salud 
- Sistema de reservaciones médicas (crear, ver, cancelar)
- Historial médico completo (solo lectura)
- Gestión de perfil (nombre, fecha de nacimiento, foto de perfil)
- Persistencia de sesión con token JWT
- Interfaz con colores de PredictHealth

## Requisitos

- Python 3.8 o superior
- Conexión a internet (backend en `http://localhost:5000/api/web`)

## Instalación

### Windows

**Opción 1: Script automático**
```powershell
.\instalar.bat
```

**Opción 2: Manual**
```powershell
pip install -r requirements.txt
```

### Linux / macOS

**Opción 1: Script automático**
```bash
chmod +x instalar.sh
./instalar.sh
```

**Opción 2: Manual**
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Dependencias

```
customtkinter>=5.2.0
matplotlib>=3.7.0
pillow>=10.0.0
requests>=2.31.0
```

## Ejecución

### Windows

**Opción 1: Script**
```powershell
.\ejecutar.bat
```

**Opción 2: Manual**
```powershell
python main.py
```

### Linux / macOS

**Opción 1: Script**
```bash
chmod +x ejecutar.sh
./ejecutar.sh
```

**Opción 2: Manual**
```bash
source venv/bin/activate
python main.py
```

## Estructura del Proyecto

```
PredictHealthPCApp/
├── main.py                 # Punto de entrada principal
├── config.py              # Configuración, colores, endpoints API
├── requirements.txt       # Dependencias Python
├── assets/
│   └── logo.jpg          # Logo de PredictHealth
├── views/
│   ├── login.py          # Vista de autenticación
│   ├── dashboard.py      # Dashboard con 6 gráficas de salud
│   ├── reservaciones.py  # Gestión de reservaciones médicas
│   ├── historial.py      # Historial médico (lectura)
│   └── perfil.py         # Perfil de usuario
└── services/
    └── api_service.py    # Cliente API para backend
```

## Configuración

Editar `config.py`:

- `API_BASE_URL`: URL del backend (default: `http://localhost:5000/api/web`)
- `WINDOW_SIZE`: Tamaño inicial de ventana (default: `1800x1500`)
- `LOGO_PATH`: Ruta al logo (default: `assets/logo.jpg`)

## Funcionalidades Detalladas

### Dashboard

6 gráficas de salud:
1. Presión Arterial (sistólica/diastólica)
2. Frecuencia Cardíaca
3. Control de Peso
4. Actividad Física (pasos diarios)
5. Calidad del Sueño (horas)
6. Citas Mensuales

Datos desde backend o mock si no hay conexión.

### Reservaciones

- Ver reservaciones activas
- Crear nueva reservación (tipo consulta, doctor, fecha/hora)
- Cancelar reservaciones
- Filtrar por estado (pendiente, confirmada, cancelada)

### Historial Médico

- Visualización de historial completo
- Solo lectura (edición desde versión web)
- Registros cronológicos

### Perfil de Usuario

- Editar nombre y fecha de nacimiento
- Actualizar foto de perfil
- Información de contacto (solo lectura)

## Credenciales de Prueba

- Email: `paciente1@test.predicthealth.com`
- Password: `Paciente123!`

## Autenticación

- Login con JWT token
- Validación de tipo de usuario (solo pacientes)
- Token persistente en `~/.predicthealth_token.json`
- Sesión expira según `expires_in` del backend
- Auto-logout en error de autenticación

## Solución de Problemas

**ModuleNotFoundError**
```powershell
pip install --upgrade -r requirements.txt
```

**Error de conexión al backend**
- Verificar que backend esté ejecutándose en `http://localhost:5000`
- Verificar `API_BASE_URL` en `config.py`

**Error cargando logo**
- Verificar que `assets/logo.jpg` existe
- La aplicación funciona sin logo

**Ventana muy pequeña/grande**
- Editar `WINDOW_SIZE` en `config.py`
- Tamaño mínimo: 1200x800

**Token expirado**
- La aplicación solicita login automáticamente
- Eliminar `~/.predicthealth_token.json` para forzar login

## Desarrollo

**Ejecutar en modo desarrollo:**
```powershell
python main.py
```

**Estructura de archivos clave:**
- `main.py`: Aplicación principal, navegación, sidebar
- `services/api_service.py`: Cliente HTTP, gestión de tokens, llamadas API
- `views/*.py`: Componentes de UI por módulo
- `config.py`: Configuración centralizada

## Autores

Bryan Ramirez  
Mariana Samperio  
Margarita Cuervo

Desarrollado para el proyecto PredictHealth - Integración de Aplicaciones Computacionales
