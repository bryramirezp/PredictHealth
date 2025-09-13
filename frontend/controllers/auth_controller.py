# /frontend/controllers/auth_controller.py
# Controlador de autenticación

from flask import session, redirect, url_for, flash, request
from frontend.services.auth_service import AuthService
from frontend.services.logging_service import LoggingService

class AuthController:
    """Controlador para manejar autenticación de usuarios y doctores"""
    
    def __init__(self):
        self.auth_service = AuthService()
        self.logger = LoggingService()
    
    def login_patient(self, email: str, password: str):
        """Maneja el login de pacientes"""
        try:
            result = self.auth_service.authenticate_patient(email, password)
            
            if result['success']:
                # Configurar sesión
                session.update({
                    'patient_id': result['patient']['id_paciente'],
                    'patient_name': f"{result['patient']['nombre']} {result['patient']['apellido']}",
                    'patient_email': result['patient']['email'],
                    'access_token': result['access_token'],
                    'user_type': 'patient'
                })
                
                self.logger.log_user_action(
                    result['patient']['id_paciente'], 
                    'login_success', 
                    {'user_type': 'patient'}
                )
                
                flash(f'Bienvenido, {result["patient"]["nombre"]}', 'success')
                return redirect(url_for('user_dashboard'))
            else:
                self.logger.log_security_event(
                    'login_failure', 
                    None, 
                    request.remote_addr,
                    {'email': email, 'user_type': 'patient'}
                )
                flash(f'Error: {result["error"]}', 'error')
                return redirect(url_for('log_in_page'))
                
        except Exception as e:
            self.logger.log_error('login_error', str(e), None, {'user_type': 'patient'})
            flash('Error inesperado durante el login', 'error')
            return redirect(url_for('log_in_page'))
    
    def login_doctor(self, email: str, password: str):
        """Maneja el login de doctores"""
        try:
            result = self.auth_service.authenticate_doctor(email, password)
            
            if result['success']:
                # Configurar sesión
                session.update({
                    'doctor_id': result['doctor']['id_doctor'],
                    'doctor_name': f"{result['doctor']['nombre']} {result['doctor']['apellido']}",
                    'doctor_email': result['doctor']['email'],
                    'access_token': result['access_token'],
                    'user_type': 'doctor'
                })
                
                self.logger.log_user_action(
                    result['doctor']['id_doctor'], 
                    'login_success', 
                    {'user_type': 'doctor'}
                )
                
                flash(f'Bienvenido, Dr. {result["doctor"]["apellido"]}', 'success')
                return redirect(url_for('doctor_dashboard'))
            else:
                self.logger.log_security_event(
                    'login_failure', 
                    None, 
                    request.remote_addr,
                    {'email': email, 'user_type': 'doctor'}
                )
                flash(f'Error: {result["error"]}', 'error')
                return redirect(url_for('doctor_login_page'))
                
        except Exception as e:
            self.logger.log_error('login_error', str(e), None, {'user_type': 'doctor'})
            flash('Error inesperado durante el login', 'error')
            return redirect(url_for('doctor_login_page'))
    
    def logout(self):
        """Maneja el logout de usuarios"""
        user_type = session.get('user_type')
        user_id = session.get('patient_id') or session.get('doctor_id')
        
        if user_id:
            self.logger.log_user_action(user_id, 'logout', {'user_type': user_type})
        
        session.clear()
        flash('Sesión cerrada exitosamente', 'info')
        
        if user_type == 'doctor':
            return redirect(url_for('doctor_login_page'))
        else:
            return redirect(url_for('log_in_page'))
    
    def register_patient(self, patient_data: dict):
        """Maneja el registro de pacientes por doctores"""
        if session.get('user_type') != 'doctor':
            flash('Solo los doctores pueden registrar pacientes', 'error')
            return redirect(url_for('doctor_login_page'))
        
        try:
            result = self.auth_service.register_patient(patient_data, session.get('access_token'))
            
            if result['success']:
                self.logger.log_user_action(
                    session.get('doctor_id'), 
                    'patient_registered', 
                    {'patient_email': patient_data.get('email')}
                )
                flash('Paciente registrado exitosamente', 'success')
                return redirect(url_for('doctor_dashboard'))
            else:
                flash(f'Error: {result["error"]}', 'error')
                return redirect(url_for('register_patient_page'))
                
        except Exception as e:
            self.logger.log_error('patient_registration_error', str(e), session.get('doctor_id'))
            flash('Error inesperado al registrar paciente', 'error')
            return redirect(url_for('register_patient_page'))
    
    def register_doctor(self, doctor_data: dict):
        """Maneja el registro de doctores"""
        try:
            result = self.auth_service.register_doctor(doctor_data)
            
            if result['success']:
                self.logger.log_user_action(
                    result['doctor']['id_doctor'], 
                    'doctor_registered', 
                    {'email': doctor_data.get('email')}
                )
                flash('Doctor registrado exitosamente', 'success')
                return redirect(url_for('doctor_login_page'))
            else:
                flash(f'Error: {result["error"]}', 'error')
                return redirect(url_for('doctor_signup_page'))
                
        except Exception as e:
            self.logger.log_error('doctor_registration_error', str(e))
            flash('Error inesperado al registrar doctor', 'error')
            return redirect(url_for('doctor_signup_page'))
