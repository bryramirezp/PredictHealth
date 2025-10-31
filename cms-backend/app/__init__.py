from flask import Flask, redirect, url_for
from flask_login import LoginManager
from flask_wtf.csrf import CSRFProtect
from .config import config
from .models import db

login_manager = LoginManager()
csrf = CSRFProtect()

def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Configure UTF-8 encoding
    app.config['JSON_AS_ASCII'] = False
    app.config['JSON_SORT_KEYS'] = False
    
    # Ensure templates are processed with UTF-8 encoding
    app.jinja_env.auto_reload = True
    app.jinja_env.trim_blocks = True
    app.jinja_env.lstrip_blocks = True

    # Initialize extensions
    db.init_app(app)
    login_manager.init_app(app)
    csrf.init_app(app)

    # Configure login manager
    login_manager.login_view = 'auth.login'
    login_manager.login_message = 'Please log in to access this page.'
    login_manager.login_message_category = 'info'

    # Register blueprints
    from .routes.auth import auth_bp
    from .routes.dashboard import dashboard_bp
    from .routes.entities import entities_bp
    from .routes.reports import reports_bp
    from .routes.settings import settings_bp
    from .routes.monitoring import monitoring_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(dashboard_bp, url_prefix='/dashboard')
    app.register_blueprint(entities_bp, url_prefix='/entities')
    app.register_blueprint(reports_bp, url_prefix='/reports')
    app.register_blueprint(settings_bp, url_prefix='/settings')
    app.register_blueprint(monitoring_bp, url_prefix='/monitoring')

    # User loader for Flask-Login
    @login_manager.user_loader
    def load_user(user_id):
        from .models import User
        return User.query.get(user_id)

    # Context processor for templates
    @app.context_processor
    def inject_globals():
        return {
            'cms_title': app.config.get('CMS_TITLE', 'PredictHealth CMS'),
            'cms_version': app.config.get('CMS_VERSION', '1.0.0')
        }

    # Health check endpoint
    @app.route('/health')
    def health():
        return {
            'status': 'healthy',
            'service': 'cms-backend',
            'version': app.config.get('CMS_VERSION', '1.0.0')
        }

    # Root endpoint - redirect to login or dashboard
    @app.route('/')
    def index():
        from flask_login import current_user
        if current_user.is_authenticated:
            return redirect(url_for('dashboard.index'))
        return redirect(url_for('auth.login'))

    return app
