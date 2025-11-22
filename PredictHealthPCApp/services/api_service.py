# services/api_service.py - Servicio para manejar todas las peticiones al CMS

import requests
import json
import os
from typing import Optional, Dict, Any
from datetime import datetime, timedelta
from config import API_BASE_URL, API_TIMEOUT, ENDPOINTS

class APIService:
    def __init__(self):
        self.base_url = API_BASE_URL
        self.token = None
        self.user_data = None
        self.token_expires_at = None
        self.token_file = os.path.join(os.path.expanduser('~'), '.predicthealth_token.json')
        
        # Intentar cargar token persistido al iniciar
        self._load_token()
        
    def set_token(self, token: str):
        """Guardar el token JWT"""
        self.token = token
    
    def get_headers(self) -> Dict[str, str]:
        """Headers para las peticiones con JWT"""
        headers = {'Content-Type': 'application/json'}
        if self.token:
            headers['Authorization'] = f'Bearer {self.token}'
        return headers
    
    # ==================== AUTH ====================
    def login(self, email: str, password: str) -> Dict[str, Any]:
        """Login con JWT a través del gateway"""
        try:
            url = f"{self.base_url}/auth/login"
            
            response = requests.post(
                url,
                json={
                    'email': email,
                    'password': password
                },
                timeout=API_TIMEOUT
            )
            
            if response.status_code == 200:
                data = response.json()
                
                # El gateway retorna: {"status": "success", "data": {"access_token": "...", "user_id": "...", "user_type": "...", "expires_in": 900}}
                if data.get('status') != 'success':
                    return {'success': False, 'message': data.get('message', 'Error en el login')}
                
                auth_data = data.get('data', {})
                
                # Guardar token y datos
                temp_token = auth_data.get('access_token')
                temp_user_id = auth_data.get('user_id')
                temp_user_type = auth_data.get('user_type')
                expires_in = auth_data.get('expires_in', 900)
                
                # Validar tipo de usuario
                if temp_user_type != 'patient':
                    return {
                        'success': False,
                        'message': f'Esta aplicación es solo para pacientes.\nTipo de usuario: {temp_user_type}'
                    }
                
                # Guardar token y calcular expiración
                self.token = temp_token
                self.token_expires_at = datetime.now() + timedelta(seconds=expires_in)
                user_id = temp_user_id
                
                # Guardar token en archivo
                self._save_token()
                
                # Obtener perfil del paciente (sin validar token ya que acaba de ser creado)
                try:
                    # Inicializar user_data mínimo antes de pedir perfil para que get_perfil no falle
                    if not self.user_data:
                        self.user_data = {
                            'id': user_id,
                            'nombre': '',
                            'email': email,
                            'telefono': '',
                            'fecha_nacimiento': '',
                            'user_type': temp_user_type
                        }
                    profile_result = self.get_perfil(skip_validation=True)
                    if profile_result.get('success'):
                        profile_data = profile_result.get('data', {})
                        personal_info = profile_data.get('personal_info', {})
                        emails = profile_data.get('emails', [])
                        phones = profile_data.get('phones', [])
                        
                        nombre = personal_info.get('first_name', '')
                        apellido = personal_info.get('last_name', '')
                        full_name = f"{nombre} {apellido}".strip()
                        
                        # Obtener email primario: primero de personal_info.primary_email, luego buscar en emails
                        primary_email = personal_info.get('primary_email') or next((e.get('email_address') for e in emails if e.get('is_primary')), email)
                        primary_phone = next((p.get('phone_number') for p in phones if p.get('is_primary')), '')
                        
                        self.user_data = {
                            'id': user_id,
                            'nombre': full_name if full_name else email.split('@')[0].title(),
                            'email': primary_email,
                            'telefono': primary_phone,
                            'fecha_nacimiento': personal_info.get('date_of_birth', ''),
                            'user_type': temp_user_type
                        }
                    else:
                        # Fallback si no se puede obtener perfil
                        self.user_data = {
                            'id': user_id,
                            'nombre': email.split('@')[0].title(),
                            'email': email,
                            'telefono': '',
                            'fecha_nacimiento': '',
                            'user_type': temp_user_type
                        }
                except Exception as e:
                    print(f"⚠️ Error obteniendo perfil: {str(e)}")
                    # Fallback
                    self.user_data = {
                        'id': user_id,
                        'nombre': email.split('@')[0].title(),
                        'email': email,
                        'telefono': '',
                        'fecha_nacimiento': '',
                        'user_type': temp_user_type
                    }
                
                return {
                    'success': True,
                    'token': self.token,
                    'user': self.user_data
                }
            else:
                error_data = response.json() if response.headers.get('content-type', '').startswith('application/json') else {}
                error_message = error_data.get('message', f'Credenciales incorrectas (Error {response.status_code})')
                return {'success': False, 'message': error_message}
                
        except Exception as e:
            print(f"❌ Error en login: {str(e)}")
            import traceback
            traceback.print_exc()
            return {'success': False, 'message': f'Error: {str(e)}'}
        
    def logout(self) -> bool:
        """Cerrar sesión llamando al gateway"""
        try:
            if self.token:
                url = f"{self.base_url}/auth/logout"
                response = requests.post(
                    url,
                    headers=self.get_headers(),
                    timeout=API_TIMEOUT
                )
                # Continuar con logout local incluso si falla el servidor
                if response.status_code not in [200, 401, 403]:
                    print(f"⚠️ Error en logout del servidor: {response.status_code}")
        except Exception as e:
            print(f"⚠️ Error llamando logout del servidor: {str(e)}")
        
        # Limpiar datos locales
        self.token = None
        self.user_data = None
        self.token_expires_at = None
        self._delete_token()
        return True
    
    # ==================== TOKEN VALIDATION ====================
    def validate_token(self) -> bool:
        """Validar token antes de requests críticos"""
        if not self.token:
            return False
        
        # Validar expiración local primero
        if self.token_expires_at and datetime.now() >= self.token_expires_at:
            print("⚠️ Token expirado localmente")
            return False
        
        try:
            url = f"{self.base_url}/auth/session/validate"
            response = requests.get(
                url,
                headers=self.get_headers(),
                timeout=API_TIMEOUT
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('status') == 'success':
                    validation_data = data.get('data', {})
                    # El endpoint puede retornar 'valid' o directamente el objeto user
                    if validation_data.get('valid') or validation_data.get('user'):
                        return True
            
            # Si es 401 o 403, el token definitivamente es inválido
            if response.status_code in [401, 403]:
                print("⚠️ Token rechazado por servidor (401/403)")
                return False
            
            return False
        except requests.exceptions.RequestException as e:
            # Error de conexión - no podemos validar, pero no significa que el token sea inválido
            print(f"⚠️ Error de conexión validando token: {str(e)}")
            return False
        except Exception as e:
            print(f"⚠️ Error validando token: {str(e)}")
            return False
    
    def _check_auth_error(self, response) -> Optional[Dict[str, Any]]:
        """Verificar si la respuesta es un error de autenticación"""
        if response.status_code in [401, 403]:
            return {
                'success': False,
                'message': 'Sesión expirada. Por favor, inicia sesión nuevamente.',
                'auth_error': True
            }
        return None
    
    # ==================== PERFIL ====================
    def get_perfil(self, skip_validation: bool = False) -> Dict[str, Any]:
        """Obtener datos del perfil desde el gateway"""
        try:
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión activa'}
            
            # Validar token antes de la petición (excepto si skip_validation=True, útil durante login)
            if not skip_validation and not self.validate_token():
                return {'success': False, 'message': 'Token expirado', 'auth_error': True}
            
            url = f"{self.base_url}/patient/profile"
            response = requests.get(
                url,
                headers=self.get_headers(),
                timeout=API_TIMEOUT
            )
            
            auth_error = self._check_auth_error(response)
            if auth_error:
                return auth_error
            
            if response.status_code == 200:
                data = response.json()
                if data.get('status') == 'success':
                    profile_data = data.get('data', {})
                    # Actualizar user_data con datos del perfil usando estructura del microservicio
                    personal_info = profile_data.get('personal_info', {})
                    emails = profile_data.get('emails', [])
                    phones = profile_data.get('phones', [])
                    
                    nombre = personal_info.get('first_name', '')
                    apellido = personal_info.get('last_name', '')
                    full_name = f"{nombre} {apellido}".strip()
                    
                    # Obtener email primario: primero de personal_info.primary_email, luego buscar en emails
                    primary_email = personal_info.get('primary_email') or next((e.get('email_address') for e in emails if e.get('is_primary')), self.user_data.get('email', ''))
                    primary_phone = next((p.get('phone_number') for p in phones if p.get('is_primary')), self.user_data.get('telefono', ''))
                    
                    self.user_data.update({
                        'nombre': full_name if full_name else self.user_data.get('nombre', ''),
                        'email': primary_email,
                        'telefono': primary_phone,
                        'fecha_nacimiento': personal_info.get('date_of_birth', self.user_data.get('fecha_nacimiento', ''))
                    })
                    
                    return {'success': True, 'data': profile_data}
            
            return {'success': False, 'message': f'Error {response.status_code}'}
            
        except Exception as e:
            print(f"Error en get_perfil: {str(e)}")
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    def update_perfil(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Actualizar perfil a través del gateway"""
        try:
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión'}
            
            # Validar token antes de la petición
            if not self.validate_token():
                return {'success': False, 'message': 'Token expirado', 'auth_error': True}
            
            # Usar gateway proxy para actualizar perfil
            # Nota: El gateway puede no tener endpoint PUT /patient/profile, usar gateway proxy
            url = f"{self.base_url.replace('/api/web', '/api/v1')}/patients/{self.user_data.get('id')}"
            
            update_data = {}
            
            # Nombre: separar en first_name y last_name
            if 'nombre' in data:
                nombre_completo = data.get('nombre', '')
                partes = nombre_completo.split(' ', 1)
                update_data['first_name'] = partes[0] if len(partes) > 0 else ''
                update_data['last_name'] = partes[1] if len(partes) > 1 else ''
            
            # Fecha de nacimiento: funciona directamente
            if 'fecha_nacimiento' in data:
                update_data['date_of_birth'] = data['fecha_nacimiento']
            
            # Email y teléfono: solo actualizar localmente (backend puede no soportarlo)
            if 'email' in data:
                self.user_data['email'] = data['email']
            if 'telefono' in data:
                self.user_data['telefono'] = data['telefono']
            
            # Si no hay nada que enviar al backend
            if not update_data:
                return {'success': True, 'message': 'Cambios guardados localmente'}
            
            response = requests.put(
                url,
                json=update_data,
                headers=self.get_headers(),
                timeout=API_TIMEOUT
            )
            
            auth_error = self._check_auth_error(response)
            if auth_error:
                return auth_error
            
            if response.status_code == 200:
                # Actualizar datos locales
                if 'nombre' in data:
                    self.user_data['nombre'] = data['nombre']
                if 'fecha_nacimiento' in data:
                    self.user_data['fecha_nacimiento'] = data['fecha_nacimiento']
                
                return {'success': True, 'message': 'Perfil actualizado'}
            
            return {'success': False, 'message': f'Error {response.status_code}'}
            
        except Exception as e:
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    # ==================== HISTORIAL MÉDICO ====================
    def get_historial_medico(self) -> Dict[str, Any]:
        """Obtener historial médico completo del paciente desde el gateway"""
        try:
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión'}
            
            # Validar token antes de la petición
            if not self.validate_token():
                return {'success': False, 'message': 'Token expirado', 'auth_error': True}
            
            url = f"{self.base_url}/patient/medical-record"
            
            response = requests.get(
                url, 
                headers=self.get_headers(),
                timeout=API_TIMEOUT
            )
            
            auth_error = self._check_auth_error(response)
            if auth_error:
                return auth_error
            
            if response.status_code == 200:
                data = response.json()
                if data.get('status') == 'success':
                    return {'success': True, 'data': data.get('data', {})}
                return {'success': False, 'message': data.get('message', 'Error obteniendo historial')}
            
            return {'success': False, 'message': f'Error {response.status_code}'}
            
        except Exception as e:
            print(f"Error obteniendo historial médico: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    # ==================== RESERVACIONES ====================
    def get_reservaciones(self) -> Dict[str, Any]:
        """
        Obtener reservaciones del usuario
        TODO: Conectar cuando tu compañero tenga el endpoint listo
        Endpoint: GET /api/reservaciones
        """
        try:
            mock_reservaciones = [
                {
                    'id': 1,
                    'fecha': '2024-11-25',
                    'hora': '10:00',
                    'tipo': 'Consulta General',
                    'doctor': 'Dr. Juan Pérez',
                    'status': 'Confirmada'
                },
                {
                    'id': 2,
                    'fecha': '2024-12-05',
                    'hora': '14:30',
                    'tipo': 'Cardiología',
                    'doctor': 'Dr. Carlos Martínez',
                    'status': 'Pendiente'
                }
            ]
            return {'success': True, 'data': mock_reservaciones}
            
            # url = f"{self.base_url}{ENDPOINTS['reservaciones']}"
            # response = requests.get(url, headers=self.get_headers(), timeout=API_TIMEOUT)
            # if response.status_code == 200:
            #     return {'success': True, 'data': response.json()}
            # return {'success': False, 'message': 'Error al obtener reservaciones'}
            
        except Exception as e:
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    def crear_reservacion(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Crear nueva reservación
        TODO: Conectar cuando tu compañero tenga el endpoint listo
        Endpoint: POST /api/reservaciones
        Body: {"fecha": "...", "hora": "...", "tipo": "...", "doctor": "..."}
        """
        try:
            return {
                'success': True,
                'message': 'Reservación creada exitosamente',
                'data': {
                    'id': 3,
                    **data,
                    'status': 'Confirmada'
                }
            }
            
            # url = f"{self.base_url}{ENDPOINTS['reservaciones']}"
            # response = requests.post(url, json=data, headers=self.get_headers(), timeout=API_TIMEOUT)
            # if response.status_code == 201:
            #     return {'success': True, 'message': 'Reservación creada', 'data': response.json()}
            # return {'success': False, 'message': 'Error al crear reservación'}
            
        except Exception as e:
            return {'success': False, 'message': f'Error: {str(e)}'}
        
    def get_doctores_disponibles(self) -> Dict[str, Any]:
        """Obtener lista de doctores (con fallback a datos locales)"""
        try:
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión'}
            
            # Validar token antes de la petición
            if not self.validate_token():
                return {'success': False, 'message': 'Token expirado', 'auth_error': True}
            
            # Intentar obtener de la API a través del gateway
            try:
                # Usar gateway proxy para doctores
                url = f"{self.base_url.replace('/api/web', '/api/v1')}/doctors"
                
                response = requests.get(
                    url,
                    headers=self.get_headers(),
                    timeout=API_TIMEOUT
                )
                
                auth_error = self._check_auth_error(response)
                if auth_error:
                    return auth_error
                
                if response.status_code == 200:
                    doctores = response.json()
                    print(f"✅ Doctores obtenidos de API: {len(doctores)}")
                    return {'success': True, 'data': doctores}
            except Exception as e:
                print(f"⚠️ Error obteniendo doctores de API: {e}")
            
            # Fallback a datos mock
            doctores_mock = [
                {
                    'id': '21000000-e29b-41d4-a716-446655440001',
                    'first_name': 'Roberto',
                    'last_name': 'Sánchez',
                    'specialty_name': 'Cardiology',
                    'years_experience': 15,
                    'institution_name': 'Hospital General del Centro'
                },
                {
                    'id': '22000000-e29b-41d4-a716-446655440002',
                    'first_name': 'Patricia',
                    'last_name': 'Morales',
                    'specialty_name': 'Internal Medicine',
                    'years_experience': 12,
                    'institution_name': 'Clínica Familiar del Norte'
                },
                {
                    'id': '23000000-e29b-41d4-a716-446655440003',
                    'first_name': 'Fernando',
                    'last_name': 'Vázquez',
                    'specialty_name': 'Endocrinology',
                    'years_experience': 18,
                    'institution_name': 'Centro de Salud Preventiva Sur'
                },
                {
                    'id': '24000000-e29b-41d4-a716-446655440004',
                    'first_name': 'Gabriela',
                    'last_name': 'Ríos',
                    'specialty_name': 'Family Medicine',
                    'years_experience': 10,
                    'institution_name': 'Instituto Cardiovascular del Bajío'
                },
                {
                    'id': '25000000-e29b-41d4-a716-446655440005',
                    'first_name': 'Antonio',
                    'last_name': 'Jiménez',
                    'specialty_name': 'Emergency Medicine',
                    'years_experience': 22,
                    'institution_name': 'Centro Médico del Pacífico'
                }
            ]
            
            print(f"✅ Usando doctores mock: {len(doctores_mock)}")
            return {'success': True, 'data': doctores_mock}
            
        except Exception as e:
            print(f"Error obteniendo doctores: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    def get_citas(self) -> Dict[str, Any]:
        """Obtener citas del paciente (almacenadas localmente)"""
        try:
            import json
            import os
            
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión'}
            
            # Archivo local para guardar citas
            citas_file = os.path.join(os.path.expanduser('~'), '.predicthealth_citas.json')
            
            if os.path.exists(citas_file):
                with open(citas_file, 'r', encoding='utf-8') as f:
                    todas_citas = json.load(f)
                
                # Filtrar solo las citas de este usuario
                user_id = str(self.user_data.get('id'))
                citas_usuario = [c for c in todas_citas if c.get('patient_id') == user_id]
                
                return {'success': True, 'data': citas_usuario}
            
            return {'success': True, 'data': []}
            
        except Exception as e:
            print(f"Error obteniendo citas: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    def crear_cita(self, cita_data: Dict[str, Any]) -> Dict[str, Any]:
        """Crear nueva cita (guardada localmente)"""
        try:
            import json
            import os
            from datetime import datetime
            
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión'}
            
            citas_file = os.path.join(os.path.expanduser('~'), '.predicthealth_citas.json')
            
            # Cargar citas existentes
            if os.path.exists(citas_file):
                with open(citas_file, 'r', encoding='utf-8') as f:
                    todas_citas = json.load(f)
            else:
                todas_citas = []
            
            # Crear nueva cita con ID único
            nueva_cita = {
                'id': len(todas_citas) + 1,
                'patient_id': str(self.user_data.get('id')),
                'doctor_id': cita_data.get('doctor_id'),
                'doctor_name': cita_data.get('doctor_name'),
                'fecha': cita_data.get('fecha'),
                'hora': cita_data.get('hora'),
                'motivo': cita_data.get('motivo'),
                'estado': 'programada',
                'created_at': datetime.now().isoformat()
            }
            
            todas_citas.append(nueva_cita)
            
            # Guardar
            with open(citas_file, 'w', encoding='utf-8') as f:
                json.dump(todas_citas, f, ensure_ascii=False, indent=2)
            
            return {'success': True, 'data': nueva_cita}
            
        except Exception as e:
            print(f"Error creando cita: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    def cancelar_cita(self, cita_id: int) -> Dict[str, Any]:
        """Cancelar una cita (actualiza archivo local)"""
        try:
            import json
            import os
            
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión'}
            
            citas_file = os.path.join(os.path.expanduser('~'), '.predicthealth_citas.json')
            
            if not os.path.exists(citas_file):
                return {'success': False, 'message': 'No hay citas'}
            
            # Cargar y actualizar
            with open(citas_file, 'r', encoding='utf-8') as f:
                todas_citas = json.load(f)
            
            # Buscar y cancelar
            user_id = str(self.user_data.get('id'))
            encontrada = False
            
            for cita in todas_citas:
                if cita.get('id') == cita_id and cita.get('patient_id') == user_id:
                    cita['estado'] = 'cancelada'
                    encontrada = True
                    break
            
            if not encontrada:
                return {'success': False, 'message': 'Cita no encontrada'}
            
            # Guardar
            with open(citas_file, 'w', encoding='utf-8') as f:
                json.dump(todas_citas, f, ensure_ascii=False, indent=2)
            
            return {'success': True, 'message': 'Cita cancelada'}
            
        except Exception as e:
            print(f"Error cancelando cita: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}
        
    def get_proxima_cita(self) -> Dict[str, Any]:
        """Obtener la próxima cita programada"""
        try:
            result = self.get_citas()
            
            if not result.get('success'):
                return {'success': False, 'message': result.get('message')}
            
            citas = result['data']
            
            # Filtrar solo programadas
            programadas = [c for c in citas if c.get('estado') == 'programada']
            
            if not programadas:
                return {'success': True, 'data': None}
            
            # Ordenar por fecha
            from datetime import datetime
            
            def parse_fecha(cita):
                try:
                    fecha_str = f"{cita.get('fecha')} {cita.get('hora')}"
                    return datetime.strptime(fecha_str, '%Y-%m-%d %H:%M')
                except:
                    return datetime.max
            
            programadas_ordenadas = sorted(programadas, key=parse_fecha)
            
            # Retornar la más próxima
            return {'success': True, 'data': programadas_ordenadas[0]}
            
        except Exception as e:
            print(f"Error obteniendo próxima cita: {e}")
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    # ==================== ESTADÍSTICAS ====================
    def get_estadisticas(self) -> Dict[str, Any]:
        """Obtener datos para las gráficas del dashboard"""
        print(f"🔍 get_estadisticas() llamado. user_data: {self.user_data}")
        
        try:
            if not self.user_data:
                return {'success': False, 'message': 'No hay sesión'}
            
            user_id = self.user_data.get('id')
            
            # 1. Obtener datos del dashboard (KPIs básicos)
            dashboard_url = f"http://localhost:8004/api/v1/patients/{user_id}/dashboard"
            
            dashboard_response = requests.get(
                dashboard_url,
                headers={'Authorization': f'Bearer {self.token}'},
                timeout=API_TIMEOUT
            )
            
            if dashboard_response.status_code != 200:
                return {'success': False, 'message': f'Error en dashboard: {dashboard_response.status_code}'}
            
            dashboard_data = dashboard_response.json()
            
            # 2. Obtener historial médico (condiciones y medicamentos)
            medical_record_url = f"http://localhost:8004/api/v1/patients/{user_id}/medical-record"
            
            medical_response = requests.get(
                medical_record_url,
                headers={'Authorization': f'Bearer {self.token}'},
                timeout=API_TIMEOUT
            )
            
            if medical_response.status_code == 200:
                medical_data = medical_response.json()
                
                # Combinar datos
                dashboard_data['conditions'] = medical_data.get('conditions', [])
                dashboard_data['medications'] = medical_data.get('medications', [])
            else:
                print(f"⚠️ No se pudieron obtener datos médicos: {medical_response.status_code}")
                dashboard_data['conditions'] = []
                dashboard_data['medications'] = []
            
            # 3. Agregar datos de citas locales
            citas_result = self.get_proxima_cita()
            if citas_result.get('success') and citas_result.get('data'):
                dashboard_data['next_appointment'] = citas_result['data']
            
            print(f"✅ Datos combinados: conditions={len(dashboard_data.get('conditions', []))}, medications={len(dashboard_data.get('medications', []))}")
            
            return {'success': True, 'data': dashboard_data}
            
        except Exception as e:
            print(f"Error obteniendo estadísticas: {e}")
            import traceback
            traceback.print_exc()
            return {'success': False, 'message': f'Error: {str(e)}'}
    
    def _get_mock_estadisticas(self):
        """Datos mock de respaldo"""
        mock_stats = {
            'presion_arterial': {
                'fechas': ['Nov 01', 'Nov 08', 'Nov 15', 'Nov 21'],
                'sistolica': [120, 118, 122, 119],
                'diastolica': [80, 78, 82, 79]
            },
            'frecuencia_cardiaca': {
                'fechas': ['Nov 01', 'Nov 08', 'Nov 15', 'Nov 21'],
                'valores': [72, 70, 75, 71]
            },
            'peso': {
                'fechas': ['Oct', 'Nov'],
                'valores': [70.5, 69.8]
            },
            'nivel_actividad': {
                'dias': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
                'pasos': [8500, 10200, 7800, 9500, 11000, 6500, 5000]
            },
            'horas_sueno': {
                'dias': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
                'horas': [7.5, 8, 6.5, 7, 8.5, 9, 8]
            },
            'citas_mensuales': {
                'meses': ['Jul', 'Ago', 'Sep', 'Oct', 'Nov'],
                'cantidad': [2, 1, 3, 2, 4]
            }
        }
        return {'success': True, 'data': mock_stats}
    
    # ==================== TOKEN PERSISTENCE ====================
    def _save_token(self):
        """Guardar token en archivo para persistencia"""
        try:
            if self.token and self.token_expires_at:
                token_data = {
                    'token': self.token,
                    'expires_at': self.token_expires_at.isoformat(),
                    'user_id': self.user_data.get('id') if self.user_data else None
                }
                with open(self.token_file, 'w', encoding='utf-8') as f:
                    json.dump(token_data, f)
        except Exception as e:
            print(f"⚠️ Error guardando token: {str(e)}")
    
    def _load_token(self):
        """Cargar token desde archivo y validarlo"""
        try:
            if os.path.exists(self.token_file):
                with open(self.token_file, 'r', encoding='utf-8') as f:
                    token_data = json.load(f)
                
                token = token_data.get('token')
                expires_at_str = token_data.get('expires_at')
                user_id = token_data.get('user_id')
                
                if token and expires_at_str:
                    expires_at = datetime.fromisoformat(expires_at_str)
                    # Solo cargar si no ha expirado localmente
                    if datetime.now() < expires_at:
                        self.token = token
                        self.token_expires_at = expires_at
                        # Intentar validar token con el servidor (no crítico si falla)
                        try:
                            if self.validate_token():
                                print("✅ Token cargado y validado")
                                # Si hay user_id guardado, crear user_data básico
                                if user_id and not self.user_data:
                                    self.user_data = {
                                        'id': user_id,
                                        'nombre': 'Usuario',
                                        'email': '',
                                        'telefono': '',
                                        'fecha_nacimiento': '',
                                        'user_type': 'patient'
                                    }
                                return True
                            else:
                                # Token inválido en servidor, eliminar archivo
                                print("⚠️ Token inválido en servidor")
                                self._delete_token()
                                return False
                        except Exception as e:
                            # Si no se puede conectar al servidor, usar token localmente
                            print(f"⚠️ No se pudo validar token con servidor: {str(e)}")
                            print("⚠️ Usando token local (se validará en próxima petición)")
                            if user_id and not self.user_data:
                                self.user_data = {
                                    'id': user_id,
                                    'nombre': 'Usuario',
                                    'email': '',
                                    'telefono': '',
                                    'fecha_nacimiento': '',
                                    'user_type': 'patient'
                                }
                            return True
                    else:
                        # Token expirado localmente, eliminar archivo
                        print("⚠️ Token expirado localmente")
                        self._delete_token()
        except Exception as e:
            print(f"⚠️ Error cargando token: {str(e)}")
            self._delete_token()
        
        return False
    
    def _delete_token(self):
        """Eliminar archivo de token"""
        try:
            if os.path.exists(self.token_file):
                os.remove(self.token_file)
        except Exception as e:
            print(f"⚠️ Error eliminando token: {str(e)}")
    
    