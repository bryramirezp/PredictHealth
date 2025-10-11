from flask import Blueprint, render_template, request, Response, url_for, flash
from flask_login import login_required
from app.models import db
from sqlalchemy import text, func
import csv
import io
from datetime import datetime, timedelta
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, A4
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch

reports_bp = Blueprint('reports', __name__)

@reports_bp.route('/')
@login_required
def dashboard():
    """Main reports dashboard with report type selector"""
    report_type = request.args.get('type', 'patients')
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)

    # Get filter parameters
    date_from = request.args.get('date_from')
    date_to = request.args.get('date_to')
    status_filter = request.args.get('status')
    region_filter = request.args.get('region')
    specialty_filter = request.args.get('specialty')
    validation_filter = request.args.get('validation_status')
    gender_filter = request.args.get('gender')

    # Generate report based on type
    if report_type == 'patients':
        return generate_patients_report(page, per_page, date_from, date_to,
                                      validation_filter, gender_filter, region_filter)
    elif report_type == 'doctors':
        return generate_doctors_report(page, per_page, date_from, date_to,
                                     specialty_filter, status_filter, region_filter)
    elif report_type == 'institutions':
        return generate_institutions_report(page, per_page, date_from, date_to,
                                          status_filter, region_filter)
    else:  # overview
        return generate_overview_report()

def generate_patients_report(page, per_page, date_from, date_to, validation_status, gender, region):
    """Generate patients report using vw_patient_demographics"""
    try:
        # Build query with filters
        query = """
            SELECT
                id,
                first_name,
                last_name,
                email,
                age,
                gender,
                validation_status,
                is_active,
                doctor_first_name,
                doctor_last_name,
                institution_name,
                blood_type,
                hypertension_diagnosis,
                diabetes_diagnosis,
                high_cholesterol_diagnosis,
                created_at
            FROM vw_patient_demographics
            WHERE 1=1
        """
        params = {}

        if date_from:
            query += " AND created_at >= :date_from"
            params['date_from'] = date_from
        if date_to:
            query += " AND created_at <= :date_to"
            params['date_to'] = date_to + ' 23:59:59'
        if validation_status:
            query += " AND validation_status = :validation_status"
            params['validation_status'] = validation_status
        if gender:
            query += " AND gender = :gender"
            params['gender'] = gender
        if region:
            query += " AND institution_name ILIKE :region"
            params['region'] = f'%{region}%'

        # Get total count
        count_query = f"SELECT COUNT(*) FROM ({query}) AS subquery"
        total_result = db.session.execute(text(count_query), params).scalar()
        total_pages = (total_result + per_page - 1) // per_page

        # Add pagination
        query += " ORDER BY created_at DESC LIMIT :limit OFFSET :offset"
        params['limit'] = per_page
        params['offset'] = (page - 1) * per_page

        # Execute query
        result = db.session.execute(text(query), params)
        patients = [dict(row._mapping) for row in result]

        # Get summary stats
        summary_query = """
            SELECT
                COUNT(*) as total_patients,
                COUNT(CASE WHEN validation_status = 'full_access' THEN 1 END) as validated_patients,
                COUNT(CASE WHEN gender = 'male' THEN 1 END) as male_count,
                COUNT(CASE WHEN gender = 'female' THEN 1 END) as female_count,
                ROUND(AVG(age), 1) as avg_age
            FROM vw_patient_demographics
        """
        summary_result = db.session.execute(text(summary_query)).first()
        summary = dict(summary_result._mapping) if summary_result else {}

        return render_template('reports/dashboard.html',
                             report_type='patients',
                             patients=patients,
                             summary=summary,
                             page=page,
                             total_pages=total_pages,
                             per_page=per_page,
                             filters={
                                 'date_from': date_from,
                                 'date_to': date_to,
                                 'validation_status': validation_status,
                                 'gender': gender,
                                 'region': region
                             })

    except Exception as e:
        flash(f'Error generating patients report: {str(e)}', 'error')
        return render_template('reports/dashboard.html',
                              report_type='patients',
                              patients=[],
                              summary={},
                              filters={
                                  'date_from': date_from,
                                  'date_to': date_to,
                                  'validation_status': validation_status,
                                  'gender': gender,
                                  'region': region
                              })

def generate_doctors_report(page, per_page, date_from, date_to, specialty, status, region):
    """Generate doctors report using vw_doctor_performance"""
    try:
        # Build query with filters
        query = """
            SELECT
                id,
                first_name,
                last_name,
                email,
                medical_license,
                years_experience,
                consultation_fee,
                specialty,
                institution_name,
                patient_count,
                avg_patient_age,
                created_at
            FROM vw_doctor_performance
            WHERE 1=1
        """
        params = {}

        if date_from:
            query += " AND created_at >= :date_from"
            params['date_from'] = date_from
        if date_to:
            query += " AND created_at <= :date_to"
            params['date_to'] = date_to + ' 23:59:59'
        if specialty:
            query += " AND specialty ILIKE :specialty"
            params['specialty'] = f'%{specialty}%'
        if status:
            query += " AND professional_status = :status"
            params['status'] = status
        if region:
            query += " AND institution_name ILIKE :region"
            params['region'] = f'%{region}%'

        # Get total count
        count_query = f"SELECT COUNT(*) FROM ({query}) AS subquery"
        total_result = db.session.execute(text(count_query), params).scalar()
        total_pages = (total_result + per_page - 1) // per_page

        # Add pagination
        query += " ORDER BY created_at DESC LIMIT :limit OFFSET :offset"
        params['limit'] = per_page
        params['offset'] = (page - 1) * per_page

        # Execute query
        result = db.session.execute(text(query), params)
        doctors = [dict(row._mapping) for row in result]

        # Get summary stats
        summary_query = """
            SELECT
                COUNT(*) as total_doctors,
                ROUND(AVG(consultation_fee), 2) as avg_fee,
                ROUND(AVG(years_experience), 1) as avg_experience,
                COUNT(DISTINCT specialty) as specialty_count
            FROM vw_doctor_performance
        """
        summary_result = db.session.execute(text(summary_query)).first()
        summary = dict(summary_result._mapping) if summary_result else {}

        return render_template('reports/dashboard.html',
                             report_type='doctors',
                             doctors=doctors,
                             summary=summary,
                             page=page,
                             total_pages=total_pages,
                             per_page=per_page,
                             filters={
                                 'date_from': date_from,
                                 'date_to': date_to,
                                 'specialty': specialty,
                                 'status': status,
                                 'region': region
                             })

    except Exception as e:
        flash(f'Error generating doctors report: {str(e)}', 'error')
        return render_template('reports/dashboard.html',
                              report_type='doctors',
                              doctors=[],
                              summary={},
                              filters={
                                  'date_from': date_from,
                                  'date_to': date_to,
                                  'specialty': specialty,
                                  'status': status,
                                  'region': region
                              })

def generate_institutions_report(page, per_page, date_from, date_to, status, region):
    """Generate institutions report using medical_institutions table"""
    try:
        from app.models.existing_models import MedicalInstitution

        # Build query with filters
        query = MedicalInstitution.query

        if date_from:
            query = query.filter(MedicalInstitution.created_at >= date_from)
        if date_to:
            query = query.filter(MedicalInstitution.created_at <= date_to + ' 23:59:59')
        if status:
            if status == 'active':
                query = query.filter(MedicalInstitution.is_active == True)
            elif status == 'inactive':
                query = query.filter(MedicalInstitution.is_active == False)
        if region:
            query = query.filter(MedicalInstitution.region_state.ilike(f'%{region}%'))

        # Get total count
        total_result = query.count()
        total_pages = (total_result + per_page - 1) // per_page

        # Add pagination
        institutions = query.order_by(MedicalInstitution.created_at.desc()) \
                           .paginate(page=page, per_page=per_page)

        # Get summary stats
        summary_query = """
            SELECT
                COUNT(*) as total_institutions,
                COUNT(CASE WHEN is_active THEN 1 END) as active_institutions,
                COUNT(CASE WHEN is_verified THEN 1 END) as verified_institutions,
                COUNT(DISTINCT institution_type) as type_count
            FROM medical_institutions
        """
        summary_result = db.session.execute(text(summary_query)).first()
        summary = dict(summary_result._mapping) if summary_result else {}

        return render_template('reports/dashboard.html',
                             report_type='institutions',
                             institutions=institutions,
                             summary=summary,
                             page=page,
                             total_pages=total_pages,
                             per_page=per_page,
                             filters={
                                 'date_from': date_from,
                                 'date_to': date_to,
                                 'status': status,
                                 'region': region
                             })

    except Exception as e:
        flash(f'Error generating institutions report: {str(e)}', 'error')
        return render_template('reports/dashboard.html',
                              report_type='institutions',
                              institutions=[],
                              summary={},
                              filters={
                                  'date_from': date_from,
                                  'date_to': date_to,
                                  'status': status,
                                  'region': region
                              })

def generate_overview_report():
    """Generate overview report using vw_dashboard_overview"""
    try:
        # Get overview data
        overview_result = db.session.execute(text("SELECT * FROM vw_dashboard_overview")).first()
        overview = dict(overview_result._mapping) if overview_result else {}

        # Get monthly registrations for chart
        monthly_result = db.session.execute(text("""
            SELECT
                TO_CHAR(registration_month, 'Mon YYYY') as month,
                total_registrations as count
            FROM vw_monthly_registrations
            ORDER BY registration_month DESC
            LIMIT 6
        """)).fetchall()
        monthly_data = [{'month': row.month, 'count': row.count} for row in monthly_result]

        # Get validation status distribution
        validation_result = db.session.execute(text("""
            SELECT validation_status, patient_count, percentage
            FROM vw_patient_validation_status
            ORDER BY patient_count DESC
        """)).fetchall()
        validation_data = [{'status': row.validation_status, 'count': row.patient_count,
                          'percentage': row.percentage} for row in validation_result]

        return render_template('reports/dashboard.html',
                             report_type='overview',
                             overview=overview,
                             monthly_data=monthly_data,
                             validation_data=validation_data)

    except Exception as e:
        flash(f'Error generating overview report: {str(e)}', 'error')
        return render_template('reports/dashboard.html', report_type='overview', overview={})

@reports_bp.route('/export/<report_type>/<format>')
@login_required
def export_report(report_type, format):
    """Export report data in CSV or PDF format"""
    try:
        # Get current filters from request args
        date_from = request.args.get('date_from')
        date_to = request.args.get('date_to')
        status_filter = request.args.get('status')
        region_filter = request.args.get('region')
        specialty_filter = request.args.get('specialty')
        validation_filter = request.args.get('validation_status')
        gender_filter = request.args.get('gender')

        if format == 'csv':
            return export_csv(report_type, date_from, date_to, status_filter,
                            region_filter, specialty_filter, validation_filter, gender_filter)
        elif format == 'pdf':
            return export_pdf(report_type, date_from, date_to, status_filter,
                            region_filter, specialty_filter, validation_filter, gender_filter)
        else:
            flash('Invalid export format', 'error')
            return redirect(url_for('reports.dashboard'))

    except Exception as e:
        flash(f'Error exporting report: {str(e)}', 'error')
        return redirect(url_for('reports.dashboard'))

def export_csv(report_type, date_from, date_to, status_filter, region_filter,
               specialty_filter, validation_filter, gender_filter):
    """Export data as CSV"""
    try:
        if report_type == 'patients':
            data, headers = get_patients_data(date_from, date_to, validation_filter, gender_filter, region_filter)
        elif report_type == 'doctors':
            data, headers = get_doctors_data(date_from, date_to, specialty_filter, status_filter, region_filter)
        elif report_type == 'institutions':
            data, headers = get_institutions_data(date_from, date_to, status_filter, region_filter)
        else:
            flash('Invalid report type for export', 'error')
            return redirect(url_for('reports.dashboard'))

        # Create CSV response
        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(headers)
        writer.writerows(data)

        response = Response(
            output.getvalue(),
            mimetype='text/csv',
            headers={'Content-Disposition': f'attachment; filename={report_type}_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'}
        )
        return response

    except Exception as e:
        flash(f'Error creating CSV export: {str(e)}', 'error')
        return redirect(url_for('reports.dashboard'))

def export_pdf(report_type, date_from, date_to, status_filter, region_filter,
               specialty_filter, validation_filter, gender_filter):
    """Export data as PDF"""
    try:
        if report_type == 'patients':
            data, headers = get_patients_data(date_from, date_to, validation_filter, gender_filter, region_filter)
            title = "Patients Report"
        elif report_type == 'doctors':
            data, headers = get_doctors_data(date_from, date_to, specialty_filter, status_filter, region_filter)
            title = "Doctors Report"
        elif report_type == 'institutions':
            data, headers = get_institutions_data(date_from, date_to, status_filter, region_filter)
            title = "Institutions Report"
        else:
            flash('Invalid report type for export', 'error')
            return redirect(url_for('reports.dashboard'))

        # Create PDF
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=A4)
        elements = []

        # Styles
        styles = getSampleStyleSheet()
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=16,
            spaceAfter=30,
        )

        # Title
        elements.append(Paragraph(title, title_style))
        elements.append(Spacer(1, 12))

        # Add timestamp
        timestamp = f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        elements.append(Paragraph(timestamp, styles['Normal']))
        elements.append(Spacer(1, 20))

        # Prepare table data
        table_data = [headers] + data

        # Create table
        table = Table(table_data)
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.white),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ('FONTSIZE', (0, 1), (-1, -1), 8),
        ]))

        elements.append(table)

        # Build PDF
        doc.build(elements)

        buffer.seek(0)
        response = Response(
            buffer.getvalue(),
            mimetype='application/pdf',
            headers={'Content-Disposition': f'attachment; filename={report_type}_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.pdf'}
        )
        return response

    except Exception as e:
        flash(f'Error creating PDF export: {str(e)}', 'error')
        return redirect(url_for('reports.dashboard'))

def get_patients_data(date_from, date_to, validation_status, gender, region):
    """Get patients data for export"""
    query = """
        SELECT
            first_name,
            last_name,
            email,
            age,
            gender,
            validation_status,
            doctor_first_name || ' ' || doctor_last_name as doctor_name,
            institution_name,
            blood_type,
            CASE WHEN hypertension_diagnosis THEN 'Yes' ELSE 'No' END as hypertension,
            CASE WHEN diabetes_diagnosis THEN 'Yes' ELSE 'No' END as diabetes,
            CASE WHEN high_cholesterol_diagnosis THEN 'Yes' ELSE 'No' END as high_cholesterol,
            TO_CHAR(created_at, 'YYYY-MM-DD') as registration_date
        FROM vw_patient_demographics
        WHERE 1=1
    """
    params = {}

    if date_from:
        query += " AND created_at >= :date_from"
        params['date_from'] = date_from
    if date_to:
        query += " AND created_at <= :date_to"
        params['date_to'] = date_to + ' 23:59:59'
    if validation_status:
        query += " AND validation_status = :validation_status"
        params['validation_status'] = validation_status
    if gender:
        query += " AND gender = :gender"
        params['gender'] = gender
    if region:
        query += " AND institution_name ILIKE :region"
        params['region'] = f'%{region}%'

    query += " ORDER BY created_at DESC"

    result = db.session.execute(text(query), params)
    data = [list(row) for row in result]
    headers = ['First Name', 'Last Name', 'Email', 'Age', 'Gender', 'Validation Status',
               'Doctor', 'Institution', 'Blood Type', 'Hypertension', 'Diabetes',
               'High Cholesterol', 'Registration Date']

    return data, headers

def get_doctors_data(date_from, date_to, specialty, status, region):
    """Get doctors data for export"""
    query = """
        SELECT
            first_name,
            last_name,
            email,
            medical_license,
            specialty,
            years_experience,
            consultation_fee,
            institution_name,
            patient_count,
            ROUND(avg_patient_age, 1) as avg_patient_age,
            TO_CHAR(created_at, 'YYYY-MM-DD') as registration_date
        FROM vw_doctor_performance
        WHERE 1=1
    """
    params = {}

    if date_from:
        query += " AND created_at >= :date_from"
        params['date_from'] = date_from
    if date_to:
        query += " AND created_at <= :date_to"
        params['date_to'] = date_to + ' 23:59:59'
    if specialty:
        query += " AND specialty ILIKE :specialty"
        params['specialty'] = f'%{specialty}%'
    if status:
        query += " AND professional_status = :status"
        params['status'] = status
    if region:
        query += " AND institution_name ILIKE :region"
        params['region'] = f'%{region}%'

    query += " ORDER BY created_at DESC"

    result = db.session.execute(text(query), params)
    data = [list(row) for row in result]
    headers = ['First Name', 'Last Name', 'Email', 'Medical License', 'Specialty',
               'Years Experience', 'Consultation Fee', 'Institution', 'Patient Count',
               'Avg Patient Age', 'Registration Date']

    return data, headers

def get_institutions_data(date_from, date_to, status, region):
    """Get institutions data for export"""
    from app.models.existing_models import MedicalInstitution

    query = MedicalInstitution.query

    if date_from:
        query = query.filter(MedicalInstitution.created_at >= date_from)
    if date_to:
        query = query.filter(MedicalInstitution.created_at <= date_to + ' 23:59:59')
    if status:
        if status == 'active':
            query = query.filter(MedicalInstitution.is_active == True)
        elif status == 'inactive':
            query = query.filter(MedicalInstitution.is_active == False)
    if region:
        query = query.filter(MedicalInstitution.region_state.ilike(f'%{region}%'))

    institutions = query.order_by(MedicalInstitution.created_at.desc()).all()

    data = []
    for inst in institutions:
        data.append([
            inst.name,
            inst.institution_type,
            inst.contact_email,
            inst.region_state or '',
            inst.phone or '',
            'Yes' if inst.is_active else 'No',
            'Yes' if inst.is_verified else 'No',
            inst.created_at.strftime('%Y-%m-%d') if inst.created_at else ''
        ])

    headers = ['Name', 'Type', 'Email', 'Region', 'Phone', 'Active', 'Verified', 'Registration Date']

    return data, headers
