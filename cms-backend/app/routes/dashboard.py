from flask import Blueprint, render_template, session
from flask_login import login_required
from app.models import db
from app.utils.role_utils import get_current_user_role, get_current_user_role_display
from sqlalchemy import text

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/')
@login_required
def index():
    # Get dashboard overview from view
    overview_row = db.session.execute(text("SELECT * FROM vw_dashboard_overview")).first()
    dashboard_overview = {
        'total_patients': overview_row.total_patients if overview_row else 0,
        'total_doctors': overview_row.total_doctors if overview_row else 0,
        'total_institutions': overview_row.total_institutions if overview_row else 0,
        'total_users': overview_row.total_users if overview_row else 0,
        'validated_patients': overview_row.validated_patients if overview_row else 0,
        'avg_consultation_fee': float(overview_row.avg_consultation_fee) if overview_row and overview_row.avg_consultation_fee else 0.0
    } if overview_row else None

    # Get monthly registrations for chart
    monthly_rows = db.session.execute(text("""
        SELECT
            TO_CHAR(registration_month, 'Mon YYYY') as month,
            total_registrations as count
        FROM vw_monthly_registrations
        ORDER BY registration_month DESC
        LIMIT 6
    """)).fetchall()

    # Get current year for procedures
    from datetime import datetime
    current_year = datetime.now().year

    # Convert to dictionaries and format for Chart.js
    monthly_data = [{'month': row.month, 'count': row.count} for row in monthly_rows]
    months_data = [item['month'] for item in reversed(monthly_data)]
    counts_data = [item['count'] for item in reversed(monthly_data)]

    # Get doctor specialty distribution for chart
    specialty_rows = db.session.execute(text("""
        SELECT specialty, doctor_count
        FROM vw_doctor_specialty_distribution
        WHERE doctor_count > 0
        ORDER BY doctor_count DESC
        LIMIT 8
    """)).fetchall()
    specialty_data = [{'specialty': row.specialty, 'doctor_count': row.doctor_count} for row in specialty_rows]

    # Get geographic distribution
    geographic_rows = db.session.execute(text("""
        SELECT region_state, institution_count, doctor_count, patient_count
        FROM vw_geographic_distribution
        ORDER BY institution_count DESC
    """)).fetchall()
    geographic_data = [{'region_state': row.region_state, 'institution_count': row.institution_count,
                       'doctor_count': row.doctor_count, 'patient_count': row.patient_count} for row in geographic_rows]

    # Get health condition prevalence
    health_rows = db.session.execute(text("""
        SELECT condition, patient_count
        FROM vw_health_condition_prevalence
        ORDER BY patient_count DESC
    """)).fetchall()
    health_conditions = [{'condition': row.condition, 'patient_count': row.patient_count} for row in health_rows]

    # Get patient validation status
    validation_rows = db.session.execute(text("""
        SELECT validation_status, patient_count, percentage
        FROM vw_patient_validation_status
        ORDER BY patient_count DESC
    """)).fetchall()
    validation_status = [{'validation_status': row.validation_status, 'patient_count': row.patient_count,
                         'percentage': row.percentage} for row in validation_rows]

    # Get user role information
    user_role = get_current_user_role()
    user_role_display = get_current_user_role_display()

    return render_template('dashboard/index.html',
                          dashboard_overview=dashboard_overview,
                          months_data=months_data,
                          counts_data=counts_data,
                          specialty_data=specialty_data,
                          geographic_data=geographic_data,
                          health_conditions=health_conditions,
                          validation_status=validation_status,
                          user_role=user_role,
                          user_role_display=user_role_display)