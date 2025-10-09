from flask import Blueprint, render_template
from flask_login import login_required
from app.models import User

reports_bp = Blueprint('reports', __name__)

@reports_bp.route('/')
@login_required
def dashboard():
    return render_template('reports/dashboard.html')
