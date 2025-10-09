from flask import Blueprint, render_template, request, url_for, redirect, flash
from flask_login import login_required
from app.models import Admin, Doctor, Patient, MedicalInstitution, DoctorSpecialty, HealthProfile, User, db
from app.models.existing_models import MainUser

entities_bp = Blueprint('entities', __name__)

@entities_bp.route('/doctors')
@login_required
def doctors():
    from flask import request

    page = request.args.get('page', 1, type=int)
    per_page = 20

    # Get filter parameters
    q = request.args.get('q', '')
    specialty_filter = request.args.get('specialty', '')
    institution_filter = request.args.get('institution', '')
    status_filter = request.args.get('status', '')
    min_experience = request.args.get('min_experience', type=int)

    # Build query with filters
    query = Doctor.query

    if q:
        query = query.filter(
            (Doctor.first_name.ilike(f'%{q}%')) |
            (Doctor.last_name.ilike(f'%{q}%')) |
            (Doctor.email.ilike(f'%{q}%')) |
            (Doctor.medical_license.ilike(f'%{q}%'))
        )

    if specialty_filter:
        query = query.filter(Doctor.specialty_id == specialty_filter)

    if institution_filter:
        query = query.filter(Doctor.institution_id == institution_filter)

    if status_filter:
        query = query.filter(Doctor.professional_status == status_filter)

    if min_experience is not None:
        query = query.filter(Doctor.years_experience >= min_experience)

    # Paginate results
    doctors = query.paginate(page=page, per_page=per_page)

    # Get specialties and institutions for filter dropdowns
    specialties = DoctorSpecialty.query.filter_by(is_active=True).all()
    institutions = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()

    def url_for_page(page_num):
        args = request.args.copy()
        args['page'] = page_num
        return url_for('entities.doctors', **args)

    return render_template('entities/doctors.html',
                          doctors=doctors,
                          specialties=specialties,
                          institutions=institutions,
                          current_page=doctors.page,
                          total_pages=doctors.pages,
                          url_for_page=url_for_page)

@entities_bp.route('/doctors/create', methods=['GET'])
@login_required
def create_doctor_form():
    """Show form to create a new doctor"""
    specialties = DoctorSpecialty.query.filter_by(is_active=True).all()
    institutions = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()
    return render_template('entities/create_doctor.html', specialties=specialties, institutions=institutions)

@entities_bp.route('/doctors', methods=['POST'])
@login_required
def create_doctor():
    """Create a new doctor from form submission"""
    try:
        # Validate required fields
        required_fields = ['first_name', 'last_name', 'email', 'phone', 'medical_license']
        for field in required_fields:
            if not request.form.get(field) or not request.form.get(field).strip():
                flash(f'{field.replace("_", " ").title()} is required', 'error')
                return redirect(url_for('entities.create_doctor_form'))

        # Check if email already exists
        existing_doctor = Doctor.query.filter_by(email=request.form['email']).first()
        if existing_doctor:
            flash('Email already exists', 'error')
            return redirect(url_for('entities.create_doctor_form'))

        # Check if medical license already exists
        existing_license = Doctor.query.filter_by(medical_license=request.form['medical_license']).first()
        if existing_license:
            flash('Medical license already exists', 'error')
            return redirect(url_for('entities.create_doctor_form'))

        # Create doctor
        doctor = Doctor(
            first_name=request.form['first_name'],
            last_name=request.form['last_name'],
            email=request.form['email'],
            phone=request.form['phone'],
            medical_license=request.form['medical_license'],
            specialty_id=request.form.get('specialty_id') or None,
            institution_id=request.form.get('institution_id') or None,
            professional_status=request.form.get('professional_status', 'active'),
            years_experience=int(request.form.get('years_experience', 0)),
            consultation_fee=float(request.form.get('consultation_fee')) if request.form.get('consultation_fee') else None
        )

        db.session.add(doctor)
        db.session.commit()

        flash('Doctor created successfully', 'success')
        return redirect(url_for('entities.doctors'))

    except Exception as e:
        db.session.rollback()
        flash(f'Error creating doctor: {str(e)}', 'error')
        return redirect(url_for('entities.create_doctor_form'))

@entities_bp.route('/doctors/view/<doctor_id>')
@login_required
def view_doctor(doctor_id):
    """View doctor details"""
    doctor = Doctor.query.get_or_404(doctor_id)

    # Get related data
    specialty = None
    institution = None
    if doctor.specialty_id:
        specialty = DoctorSpecialty.query.get(doctor.specialty_id)
    if doctor.institution_id:
        institution = MedicalInstitution.query.get(doctor.institution_id)

    return render_template('entities/view_doctor.html',
                          doctor=doctor,
                          specialty=specialty,
                          institution=institution)

@entities_bp.route('/doctors/edit/<doctor_id>', methods=['GET', 'POST'])
@login_required
def edit_doctor(doctor_id):
    """Edit doctor details"""
    doctor = Doctor.query.get_or_404(doctor_id)

    if request.method == 'POST':
        try:
            # Validate required fields
            required_fields = ['first_name', 'last_name', 'email', 'phone', 'medical_license']
            for field in required_fields:
                if not request.form.get(field) or not request.form.get(field).strip():
                    flash(f'{field.replace("_", " ").title()} is required', 'error')
                    return redirect(url_for('entities.edit_doctor', doctor_id=doctor_id))

            # Check for duplicate email (excluding current doctor)
            existing_email = Doctor.query.filter(Doctor.email == request.form['email'], Doctor.id != doctor_id).first()
            if existing_email:
                flash('Email already exists', 'error')
                return redirect(url_for('entities.edit_doctor', doctor_id=doctor_id))

            # Check for duplicate license (excluding current doctor)
            existing_license = Doctor.query.filter(Doctor.medical_license == request.form['medical_license'], Doctor.id != doctor_id).first()
            if existing_license:
                flash('Medical license already exists', 'error')
                return redirect(url_for('entities.edit_doctor', doctor_id=doctor_id))

            # Update doctor fields
            doctor.first_name = request.form['first_name']
            doctor.last_name = request.form['last_name']
            doctor.email = request.form['email']
            doctor.phone = request.form['phone']
            doctor.medical_license = request.form['medical_license']
            doctor.specialty_id = request.form.get('specialty_id') or None
            doctor.institution_id = request.form.get('institution_id') or None
            doctor.professional_status = request.form.get('professional_status', 'active')
            doctor.years_experience = int(request.form.get('years_experience', 0))
            doctor.consultation_fee = float(request.form.get('consultation_fee')) if request.form.get('consultation_fee') else None

            db.session.commit()

            flash('Doctor updated successfully', 'success')
            return redirect(url_for('entities.doctors'))

        except Exception as e:
            db.session.rollback()
            flash(f'Error updating doctor: {str(e)}', 'error')
            return redirect(url_for('entities.edit_doctor', doctor_id=doctor_id))

    # GET request - show edit form
    specialties = DoctorSpecialty.query.filter_by(is_active=True).all()
    institutions = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()
    return render_template('entities/edit_doctor.html',
                          doctor=doctor,
                          specialties=specialties,
                          institutions=institutions)

@entities_bp.route('/doctors/delete/<doctor_id>', methods=['POST'])
@login_required
def delete_doctor(doctor_id):
    """Delete a doctor"""
    try:
        doctor = Doctor.query.get_or_404(doctor_id)
        db.session.delete(doctor)
        db.session.commit()

        flash('Doctor deleted successfully', 'success')
        return redirect(url_for('entities.doctors'))

    except Exception as e:
        db.session.rollback()
        flash(f'Error deleting doctor: {str(e)}', 'error')
        return redirect(url_for('entities.doctors'))

@entities_bp.route('/patients')
@login_required
def patients():
    from flask import request

    page = request.args.get('page', 1, type=int)
    per_page = 20

    # Get filter parameters
    q = request.args.get('q', '')
    doctor_filter = request.args.get('doctor', '')
    institution_filter = request.args.get('institution', '')
    validation_status_filter = request.args.get('validation_status', '')
    gender_filter = request.args.get('gender', '')

    # Build query with filters
    query = Patient.query

    if q:
        query = query.filter(
            (Patient.first_name.ilike(f'%{q}%')) |
            (Patient.last_name.ilike(f'%{q}%')) |
            (Patient.email.ilike(f'%{q}%'))
        )

    if doctor_filter:
        query = query.filter(Patient.doctor_id == doctor_filter)

    if institution_filter:
        query = query.filter(Patient.institution_id == institution_filter)

    if validation_status_filter:
        query = query.filter(Patient.validation_status == validation_status_filter)

    if gender_filter:
        query = query.filter(Patient.gender == gender_filter)

    # Paginate results
    patients = query.paginate(page=page, per_page=per_page)

    # Get doctors and institutions for filter dropdowns
    doctors_rows = Doctor.query.with_entities(Doctor.id, Doctor.first_name, Doctor.last_name).all()
    doctors = [{'id': row[0], 'first_name': row[1], 'last_name': row[2]} for row in doctors_rows]

    institutions_rows = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()
    institutions = [{'id': row[0], 'name': row[1]} for row in institutions_rows]

    def url_for_page(page_num):
        args = request.args.copy()
        args['page'] = page_num
        return url_for('entities.patients', **args)

    return render_template('entities/patients.html',
                          patients=patients,
                          doctors=doctors,
                          institutions=institutions,
                          current_page=patients.page,
                          total_pages=patients.pages,
                          url_for_page=url_for_page)

@entities_bp.route('/patients/create', methods=['GET'])
@login_required
def create_patient_form():
    """Show form to create a new patient"""
    doctors_rows = Doctor.query.with_entities(Doctor.id, Doctor.first_name, Doctor.last_name).all()
    doctors = [{'id': row[0], 'first_name': row[1], 'last_name': row[2]} for row in doctors_rows]
    institutions = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()
    return render_template('entities/create_patient.html', doctors=doctors, institutions=institutions)

@entities_bp.route('/patients', methods=['POST'])
@login_required
def create_patient():
    """Create a new patient from form submission"""
    try:
        # Validate required fields
        required_fields = ['first_name', 'last_name', 'email', 'date_of_birth', 'phone']
        for field in required_fields:
            if not request.form.get(field) or not request.form.get(field).strip():
                flash(f'{field.replace("_", " ").title()} is required', 'error')
                return redirect(url_for('entities.create_patient_form'))

        # Validate at least one medical association
        if not request.form.get('doctor_id') and not request.form.get('institution_id'):
            flash('At least one medical association (doctor or institution) is required', 'error')
            return redirect(url_for('entities.create_patient_form'))

        # Check if email already exists
        existing_patient = Patient.query.filter_by(email=request.form['email']).first()
        if existing_patient:
            flash('Email already exists', 'error')
            return redirect(url_for('entities.create_patient_form'))

        # Create patient
        patient = Patient(
            first_name=request.form['first_name'],
            last_name=request.form['last_name'],
            email=request.form['email'],
            date_of_birth=request.form['date_of_birth'],
            gender=request.form.get('gender'),
            phone=request.form['phone'],
            doctor_id=request.form.get('doctor_id') or None,
            institution_id=request.form.get('institution_id') or None,
            emergency_contact_name=request.form.get('emergency_contact_name'),
            emergency_contact_phone=request.form.get('emergency_contact_phone')
        )

        db.session.add(patient)
        db.session.flush()  # Get patient ID

        # Create health profile if health data provided
        if any(request.form.get(field) for field in ['height_cm', 'weight_kg', 'blood_type']):
            health_profile = HealthProfile(
                patient_id=patient.id,
                height_cm=float(request.form.get('height_cm')) if request.form.get('height_cm') else None,
                weight_kg=float(request.form.get('weight_kg')) if request.form.get('weight_kg') else None,
                blood_type=request.form.get('blood_type')
            )
            db.session.add(health_profile)

        db.session.commit()

        flash('Patient created successfully', 'success')
        return redirect(url_for('entities.patients'))

    except Exception as e:
        db.session.rollback()
        flash(f'Error creating patient: {str(e)}', 'error')
        return redirect(url_for('entities.create_patient_form'))

@entities_bp.route('/patients/view/<patient_id>')
@login_required
def view_patient(patient_id):
    """View patient details"""
    patient = Patient.query.get_or_404(patient_id)

    # Get related data
    doctor = None
    institution = None
    if patient.doctor_id:
        doctor = Doctor.query.get(patient.doctor_id)
    if patient.institution_id:
        institution = MedicalInstitution.query.get(patient.institution_id)

    # Get health profile
    health_profile = HealthProfile.query.filter_by(patient_id=patient_id).first()

    return render_template('entities/view_patient.html',
                          patient=patient,
                          doctor=doctor,
                          institution=institution,
                          health_profile=health_profile)

@entities_bp.route('/patients/edit/<patient_id>', methods=['GET', 'POST'])
@login_required
def edit_patient(patient_id):
    """Edit patient details"""
    patient = Patient.query.get_or_404(patient_id)

    if request.method == 'POST':
        try:
            # Validate required fields
            required_fields = ['first_name', 'last_name', 'email', 'date_of_birth', 'phone']
            for field in required_fields:
                if not request.form.get(field) or not request.form.get(field).strip():
                    flash(f'{field.replace("_", " ").title()} is required', 'error')
                    return redirect(url_for('entities.edit_patient', patient_id=patient_id))

            # Validate at least one medical association
            if not request.form.get('doctor_id') and not request.form.get('institution_id'):
                flash('At least one medical association (doctor or institution) is required', 'error')
                return redirect(url_for('entities.edit_patient', patient_id=patient_id))

            # Check for duplicate email (excluding current patient)
            existing_email = Patient.query.filter(Patient.email == request.form['email'], Patient.id != patient_id).first()
            if existing_email:
                flash('Email already exists', 'error')
                return redirect(url_for('entities.edit_patient', patient_id=patient_id))

            # Update patient fields
            patient.first_name = request.form['first_name']
            patient.last_name = request.form['last_name']
            patient.email = request.form['email']
            patient.date_of_birth = request.form['date_of_birth']
            patient.gender = request.form.get('gender')
            patient.phone = request.form['phone']
            patient.doctor_id = request.form.get('doctor_id') or None
            patient.institution_id = request.form.get('institution_id') or None
            patient.emergency_contact_name = request.form.get('emergency_contact_name')
            patient.emergency_contact_phone = request.form.get('emergency_contact_phone')

            db.session.commit()

            flash('Patient updated successfully', 'success')
            return redirect(url_for('entities.patients'))

        except Exception as e:
            db.session.rollback()
            flash(f'Error updating patient: {str(e)}', 'error')
            return redirect(url_for('entities.edit_patient', patient_id=patient_id))

    # GET request - show edit form
    doctors_rows = Doctor.query.with_entities(Doctor.id, Doctor.first_name, Doctor.last_name).all()
    doctors = [{'id': row[0], 'first_name': row[1], 'last_name': row[2]} for row in doctors_rows]
    institutions = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()
    health_profile = HealthProfile.query.filter_by(patient_id=patient_id).first()

    return render_template('entities/edit_patient.html',
                          patient=patient,
                          doctors=doctors,
                          institutions=institutions,
                          health_profile=health_profile)

@entities_bp.route('/patients/delete/<patient_id>', methods=['POST'])
@login_required
def delete_patient(patient_id):
    """Delete a patient"""
    try:
        patient = Patient.query.get_or_404(patient_id)
        db.session.delete(patient)
        db.session.commit()

        flash('Patient deleted successfully', 'success')
        return redirect(url_for('entities.patients'))

    except Exception as e:
        db.session.rollback()
        flash(f'Error deleting patient: {str(e)}', 'error')
        return redirect(url_for('entities.patients'))

@entities_bp.route('/institutions')
@login_required
def institutions():
    from flask import request

    page = request.args.get('page', 1, type=int)
    per_page = 20

    # Get filter parameters
    q = request.args.get('q', '')
    type_filter = request.args.get('type', '')
    status_filter = request.args.get('status', '')
    region_filter = request.args.get('region', '')

    # Build query with filters
    query = MedicalInstitution.query

    if q:
        query = query.filter(
            (MedicalInstitution.name.ilike(f'%{q}%')) |
            (MedicalInstitution.contact_email.ilike(f'%{q}%'))
        )

    if type_filter:
        query = query.filter(MedicalInstitution.institution_type == type_filter)

    if status_filter:
        if status_filter == 'active':
            query = query.filter(MedicalInstitution.is_active == True)
        elif status_filter == 'inactive':
            query = query.filter(MedicalInstitution.is_active == False)

    if region_filter:
        query = query.filter(MedicalInstitution.region_state.ilike(f'%{region_filter}%'))

    # Paginate results
    institutions = query.paginate(page=page, per_page=per_page)

    def url_for_page(page_num):
        args = request.args.copy()
        args['page'] = page_num
        return url_for('entities.institutions', **args)

    return render_template('entities/institutions.html',
                           institutions=institutions,
                           current_page=institutions.page,
                           total_pages=institutions.pages,
                           url_for_page=url_for_page)

@entities_bp.route('/institutions/create', methods=['GET'])
@login_required
def create_institution_form():
    """Show form to create a new institution"""
    return render_template('entities/create_institution.html')

@entities_bp.route('/institutions', methods=['POST'])
@login_required
def create_institution():
    """Create a new institution from form submission"""
    try:
        # Validate required fields
        required_fields = ['name', 'institution_type', 'contact_email', 'license_number']
        for field in required_fields:
            if not request.form.get(field) or not request.form.get(field).strip():
                flash(f'{field.replace("_", " ").title()} is required', 'error')
                return redirect(url_for('entities.create_institution_form'))

        # Validate institution_type
        allowed_types = ['preventive_clinic', 'insurer', 'public_health', 'hospital', 'health_center']
        if request.form['institution_type'] not in allowed_types:
            flash('Invalid institution type', 'error')
            return redirect(url_for('entities.create_institution_form'))

        # Check if email already exists
        existing_institution = MedicalInstitution.query.filter_by(contact_email=request.form['contact_email']).first()
        if existing_institution:
            flash('Contact email already exists', 'error')
            return redirect(url_for('entities.create_institution_form'))

        # Check if license number already exists
        existing_license = MedicalInstitution.query.filter_by(license_number=request.form['license_number']).first()
        if existing_license:
            flash('License number already exists', 'error')
            return redirect(url_for('entities.create_institution_form'))

        # Create institution
        institution = MedicalInstitution(
            name=request.form['name'],
            institution_type=request.form['institution_type'],
            contact_email=request.form['contact_email'],
            license_number=request.form['license_number'],
            address=request.form.get('address'),
            region_state=request.form.get('region_state'),
            phone=request.form.get('phone'),
            website=request.form.get('website'),
            is_verified=request.form.get('is_verified') == 'true',
            is_active=request.form.get('is_active', 'true') == 'true'
        )

        db.session.add(institution)
        db.session.commit()

        flash('Institution created successfully', 'success')
        return redirect(url_for('entities.institutions'))

    except Exception as e:
        db.session.rollback()
        flash(f'Error creating institution: {str(e)}', 'error')
        return redirect(url_for('entities.create_institution_form'))

@entities_bp.route('/institutions/view/<institution_id>')
@login_required
def view_institution(institution_id):
    """View institution details"""
    institution = MedicalInstitution.query.get_or_404(institution_id)
    return render_template('entities/view_institution.html', institution=institution)

@entities_bp.route('/institutions/edit/<institution_id>', methods=['GET', 'POST'])
@login_required
def edit_institution(institution_id):
    """Edit institution details"""
    institution = MedicalInstitution.query.get_or_404(institution_id)

    if request.method == 'POST':
        try:
            # Validate required fields
            required_fields = ['name', 'institution_type', 'contact_email', 'license_number']
            for field in required_fields:
                if not request.form.get(field) or not request.form.get(field).strip():
                    flash(f'{field.replace("_", " ").title()} is required', 'error')
                    return redirect(url_for('entities.edit_institution', institution_id=institution_id))

            # Validate institution_type
            allowed_types = ['preventive_clinic', 'insurer', 'public_health', 'hospital', 'health_center']
            if request.form['institution_type'] not in allowed_types:
                flash('Invalid institution type', 'error')
                return redirect(url_for('entities.edit_institution', institution_id=institution_id))

            # Check for duplicate email (excluding current institution)
            existing_email = MedicalInstitution.query.filter(MedicalInstitution.contact_email == request.form['contact_email'], MedicalInstitution.id != institution_id).first()
            if existing_email:
                flash('Contact email already exists', 'error')
                return redirect(url_for('entities.edit_institution', institution_id=institution_id))

            # Check for duplicate license (excluding current institution)
            existing_license = MedicalInstitution.query.filter(MedicalInstitution.license_number == request.form['license_number'], MedicalInstitution.id != institution_id).first()
            if existing_license:
                flash('License number already exists', 'error')
                return redirect(url_for('entities.edit_institution', institution_id=institution_id))

            # Update institution fields
            institution.name = request.form['name']
            institution.institution_type = request.form['institution_type']
            institution.contact_email = request.form['contact_email']
            institution.license_number = request.form['license_number']
            institution.address = request.form.get('address')
            institution.region_state = request.form.get('region_state')
            institution.phone = request.form.get('phone')
            institution.website = request.form.get('website')
            institution.is_verified = request.form.get('is_verified') == 'true'
            institution.is_active = request.form.get('is_active') == 'true'

            db.session.commit()

            flash('Institution updated successfully', 'success')
            return redirect(url_for('entities.institutions'))

        except Exception as e:
            db.session.rollback()
            flash(f'Error updating institution: {str(e)}', 'error')
            return redirect(url_for('entities.edit_institution', institution_id=institution_id))

    # GET request - show edit form
    return render_template('entities/edit_institution.html', institution=institution)

@entities_bp.route('/institutions/delete/<institution_id>', methods=['POST'])
@login_required
def delete_institution(institution_id):
    """Delete an institution"""
    try:
        institution = MedicalInstitution.query.get_or_404(institution_id)
        db.session.delete(institution)
        db.session.commit()

        flash('Institution deleted successfully', 'success')
        return redirect(url_for('entities.institutions'))

    except Exception as e:
        db.session.rollback()
        flash(f'Error deleting institution: {str(e)}', 'error')
        return redirect(url_for('entities.institutions'))

