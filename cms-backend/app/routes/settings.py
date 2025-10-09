from flask import Blueprint, render_template, request, redirect, url_for, flash
from flask_login import login_required
from app.models import db
from app.models.existing_models import SystemSetting, Doctor, Patient, MedicalInstitution
from datetime import datetime

settings_bp = Blueprint('settings', __name__)

def save_setting(key, value, setting_type='string', category='general'):
    """Guardar o actualizar una configuración"""
    setting = SystemSetting.query.filter_by(setting_key=key).first()
    if not setting:
        setting = SystemSetting(setting_key=key, setting_type=setting_type, category=category)

    setting.setting_value = str(value)
    setting.updated_at = datetime.utcnow()

    if not setting.id:
        db.session.add(setting)
    db.session.commit()

def get_setting(key, default=None):
    """Obtener valor de configuración"""
    setting = SystemSetting.query.filter_by(setting_key=key).first()
    if setting:
        if setting.setting_type == 'boolean':
            return setting.setting_value.lower() == 'true'
        elif setting.setting_type == 'number':
            try:
                return int(setting.setting_value)
            except:
                return float(setting.setting_value)
        return setting.setting_value
    return default

@settings_bp.route('/', methods=['GET', 'POST'])
@login_required
def index():
    if request.method == 'POST':
        try:
            # Guardar configuraciones generales
            save_setting('cms_title', request.form.get('cms_title', 'PredictHealth CMS'))
            save_setting('timezone', request.form.get('timezone', 'America/Mexico_City'))
            save_setting('maintenance_mode', request.form.get('maintenance_mode') == 'on')
            save_setting('language', request.form.get('language', 'es'))

            # Guardar configuraciones de base de datos
            save_setting('db_backup_frequency', request.form.get('db_backup_frequency', 'daily'))

            # Guardar configuraciones de microservicios
            save_setting('service_timeout', request.form.get('service_timeout', '30'), 'number')
            save_setting('health_check_interval', request.form.get('health_check_interval', '60'), 'number')

            flash('Configuraciones guardadas exitosamente', 'success')
            return redirect(url_for('settings.index'))

        except Exception as e:
            db.session.rollback()
            flash(f'Error al guardar configuraciones: {str(e)}', 'error')

    # Cargar configuraciones actuales
    settings = {}
    all_settings = SystemSetting.query.all()
    for setting in all_settings:
        settings[setting.setting_key] = setting.setting_value

    # Estadísticas del sistema
    stats = {
        'total_doctors': Doctor.query.count(),
        'total_patients': Patient.query.count(),
        'total_institutions': MedicalInstitution.query.count(),
        'db_status': 'Conectado' if check_db_connection() else 'Error de conexión',
        'db_version': get_db_version()
    }

    return render_template('settings/index.html', settings=settings, stats=stats)

def check_db_connection():
    """Verificar conexión a base de datos"""
    try:
        db.session.execute(db.text('SELECT 1'))
        return True
    except:
        return False

def get_db_version():
    """Obtener versión de PostgreSQL"""
    try:
        result = db.session.execute(db.text('SELECT version()'))
        return result.fetchone()[0].split(' ')[1]
    except:
        return 'Desconocida'