from flask import Blueprint, render_template, request, url_for, redirect, flash
from flask_login import login_required
from app.models import Admin, Doctor, Patient, MedicalInstitution, DoctorSpecialty, HealthProfile, User, db, InstitutionType, SpecialtyCategory
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
    
    # Handle sorting
    sort_by = request.args.get('sort_by', 'name')
    sort_order = request.args.get('sort_order', 'asc')
    
    if sort_by == 'name':
        if sort_order == 'asc':
            query = query.order_by(Doctor.last_name.asc(), Doctor.first_name.asc())
        else:
            query = query.order_by(Doctor.last_name.desc(), Doctor.first_name.desc())
    elif sort_by == 'experience':
        query = query.order_by(Doctor.years_experience.desc() if sort_order == 'desc' else Doctor.years_experience.asc())
    elif sort_by == 'consultation_fee':
        query = query.order_by(Doctor.consultation_fee.desc() if sort_order == 'desc' else Doctor.consultation_fee.asc())
    else:
        # Default sorting by name
        if sort_order == 'asc':
            query = query.order_by(Doctor.last_name.asc(), Doctor.first_name.asc())
        else:
            query = query.order_by(Doctor.last_name.desc(), Doctor.first_name.desc())

    # Paginate results first
    doctors_paginated = query.paginate(page=page, per_page=per_page)

    # Now add specialty and institution names to each doctor object
    for doctor in doctors_paginated.items:
        # Get specialty name and category
        if doctor.specialty_id:
            specialty = DoctorSpecialty.query.get(doctor.specialty_id)
            doctor.specialty_name = specialty.name if specialty else None
            if specialty and specialty.category_rel:
                doctor.specialty_category = specialty.category_rel.name
            else:
                doctor.specialty_category = None
        else:
            doctor.specialty_name = None
            doctor.specialty_category = None

        # Get institution name
        if doctor.institution_id:
            institution = MedicalInstitution.query.get(doctor.institution_id)
            doctor.institution_name = institution.name if institution else None
        else:
            doctor.institution_name = None

    # Use the original pagination object
    doctors = doctors_paginated

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

        # Check if email already exists in emails table
        from app.models import db
        existing_email = db.session.execute(
            db.text("SELECT 1 FROM emails WHERE entity_type = 'doctor' AND email_address = :email LIMIT 1"),
            {'email': request.form['email']}
        ).fetchone()
        if existing_email:
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
            medical_license=request.form['medical_license'],
            specialty_id=request.form.get('specialty_id') or None,
            institution_id=request.form.get('institution_id') or None,
            professional_status=request.form.get('professional_status', 'active'),
            years_experience=int(request.form.get('years_experience', 0)),
            consultation_fee=float(request.form.get('consultation_fee')) if request.form.get('consultation_fee') else None,
            sex_id=request.form.get('sex_id') or None
        )

        db.session.add(doctor)
        db.session.flush()  # Get doctor ID

        # Create email entry
        if request.form.get('email'):
            db.session.execute(
                db.text("""
                    INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
                    VALUES ('doctor', :entity_id, (SELECT id FROM email_types WHERE name = 'primary'), :email, TRUE, FALSE)
                """),
                {'entity_id': doctor.id, 'email': request.form['email']}
            )

        # Create phone entry
        if request.form.get('phone'):
            db.session.execute(
                db.text("""
                    INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                    VALUES ('doctor', :entity_id, (SELECT id FROM phone_types WHERE name = 'primary'), :phone, TRUE, FALSE)
                """),
                {'entity_id': doctor.id, 'phone': request.form['phone']}
            )

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
            existing_email = db.session.execute(
                db.text("""
                    SELECT 1 FROM emails
                    WHERE entity_type = 'doctor' AND email_address = :email AND entity_id != :doctor_id
                    LIMIT 1
                """),
                {'email': request.form['email'], 'doctor_id': doctor_id}
            ).fetchone()
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
            doctor.medical_license = request.form['medical_license']
            doctor.specialty_id = request.form.get('specialty_id') or None
            doctor.institution_id = request.form.get('institution_id') or None
            doctor.professional_status = request.form.get('professional_status', 'active')
            doctor.years_experience = int(request.form.get('years_experience', 0))
            doctor.consultation_fee = float(request.form.get('consultation_fee')) if request.form.get('consultation_fee') else None
            doctor.sex_id = request.form.get('sex_id') or None

            # Update or create email
            if request.form.get('email'):
                # First, remove any existing primary email for this doctor
                db.session.execute(
                    db.text("DELETE FROM emails WHERE entity_type = 'doctor' AND entity_id = :entity_id AND is_primary = TRUE"),
                    {'entity_id': doctor_id}
                )
                # Then insert the new email
                db.session.execute(
                    db.text("""
                        INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
                        VALUES ('doctor', :entity_id, (SELECT id FROM email_types WHERE name = 'primary'), :email, TRUE, FALSE)
                    """),
                    {'entity_id': doctor_id, 'email': request.form['email']}
                )

            # Update or create phone
            if request.form.get('phone'):
                # First, remove any existing primary phone for this doctor
                db.session.execute(
                    db.text("DELETE FROM phones WHERE entity_type = 'doctor' AND entity_id = :entity_id AND is_primary = TRUE"),
                    {'entity_id': doctor_id}
                )
                # Then insert the new phone
                db.session.execute(
                    db.text("""
                        INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                        VALUES ('doctor', :entity_id, (SELECT id FROM phone_types WHERE name = 'primary'), :phone, TRUE, FALSE)
                    """),
                    {'entity_id': doctor_id, 'phone': request.form['phone']}
                )

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
            (Patient.last_name.ilike(f'%{q}%'))
        )

    if doctor_filter:
        query = query.filter(Patient.doctor_id == doctor_filter)

    if institution_filter:
        query = query.filter(Patient.institution_id == institution_filter)

    # Note: validation_status column removed from Patient model to match database schema
    # This filter is no longer available

    if gender_filter:
        query = query.filter(Patient.gender == gender_filter)
    
    # Handle sorting
    sort_by = request.args.get('sort_by', 'name')
    sort_order = request.args.get('sort_order', 'asc')
    
    if sort_by == 'name':
        if sort_order == 'asc':
            query = query.order_by(Patient.last_name.asc(), Patient.first_name.asc())
        else:
            query = query.order_by(Patient.last_name.desc(), Patient.first_name.desc())
    elif sort_by == 'date_of_birth':
        if sort_order == 'asc':
            query = query.order_by(Patient.date_of_birth.asc())
        else:
            query = query.order_by(Patient.date_of_birth.desc())
    elif sort_by == 'gender':
        if sort_order == 'asc':
            query = query.order_by(Patient.gender.asc())
        else:
            query = query.order_by(Patient.gender.desc())
    else:
        # Default sorting by name
        if sort_order == 'asc':
            query = query.order_by(Patient.last_name.asc(), Patient.first_name.asc())
        else:
            query = query.order_by(Patient.last_name.desc(), Patient.first_name.desc())

    # Paginate results first
    patients_paginated = query.paginate(page=page, per_page=per_page)

    # Now add doctor, institution, and biological sex information to each patient object
    for patient in patients_paginated.items:
        # Get doctor name
        if patient.doctor_id:
            doctor = Doctor.query.get(patient.doctor_id)
            patient.doctor_name = f"Dr. {doctor.first_name} {doctor.last_name}" if doctor else None
        else:
            patient.doctor_name = None

        # Get institution name
        if patient.institution_id:
            institution = MedicalInstitution.query.get(patient.institution_id)
            patient.institution_name = institution.name if institution else None
        else:
            patient.institution_name = None

        # Get biological sex
        if patient.sex_id:
            sex_result = db.session.execute(
                db.text("SELECT display_name FROM sexes WHERE id = :sex_id LIMIT 1"),
                {'sex_id': patient.sex_id}
            ).fetchone()
            patient.biological_sex = sex_result[0] if sex_result else None
        else:
            patient.biological_sex = None

        # Get gender identity
        if patient.gender_id:
            gender_result = db.session.execute(
                db.text("SELECT display_name FROM genders WHERE id = :gender_id LIMIT 1"),
                {'gender_id': patient.gender_id}
            ).fetchone()
            patient.gender_identity = gender_result[0] if gender_result else None
        else:
            patient.gender_identity = None

    # Use the original pagination object
    patients = patients_paginated

    # Get doctors and institutions for filter dropdowns
    doctors_rows = Doctor.query.with_entities(Doctor.id, Doctor.first_name, Doctor.last_name).all()
    doctors = [{'value': str(row[0]), 'text': f"{row[1]} {row[2]}"} for row in doctors_rows]

    institutions_rows = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()
    institutions = [{'value': str(row[0]), 'text': row[1]} for row in institutions_rows]

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
    from datetime import datetime
    return render_template('entities/create_patient.html', doctors=doctors, institutions=institutions, today_date=datetime.now().date().isoformat())

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

        # Check if email already exists in emails table
        existing_email = db.session.execute(
            db.text("SELECT 1 FROM emails WHERE entity_type = 'patient' AND email_address = :email LIMIT 1"),
            {'email': request.form['email']}
        ).fetchone()
        if existing_email:
            flash('Email already exists', 'error')
            return redirect(url_for('entities.create_patient_form'))

        # Create patient
        patient = Patient(
            first_name=request.form['first_name'],
            last_name=request.form['last_name'],
            date_of_birth=request.form['date_of_birth'],
            doctor_id=request.form.get('doctor_id') or None,
            institution_id=request.form.get('institution_id') or None,
            emergency_contact_name=request.form.get('emergency_contact_name')
        )

        # Set gender_id if gender is provided
        if request.form.get('gender'):
            gender_result = db.session.execute(
                db.text("SELECT id FROM genders WHERE name = :gender_name LIMIT 1"),
                {'gender_name': request.form['gender']}
            ).fetchone()
            if gender_result:
                patient.gender_id = gender_result[0]

        db.session.add(patient)
        db.session.flush()  # Get patient ID

        # Create email entry
        if request.form.get('email'):
            db.session.execute(
                db.text("""
                    INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
                    VALUES ('patient', :entity_id, (SELECT id FROM email_types WHERE name = 'primary'), :email, TRUE, FALSE)
                """),
                {'entity_id': patient.id, 'email': request.form['email']}
            )

        # Create phone entry
        if request.form.get('phone'):
            db.session.execute(
                db.text("""
                    INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                    VALUES ('patient', :entity_id, (SELECT id FROM phone_types WHERE name = 'primary'), :phone, TRUE, FALSE)
                """),
                {'entity_id': patient.id, 'phone': request.form['phone']}
            )

        # Create emergency contact phone entry
        if request.form.get('emergency_contact_phone'):
            db.session.execute(
                db.text("""
                    INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                    VALUES ('emergency_contact', :entity_id, (SELECT id FROM phone_types WHERE name = 'emergency'), :phone, FALSE, FALSE)
                """),
                {'entity_id': patient.id, 'phone': request.form['emergency_contact_phone']}
            )

        # Create health profile if health data provided
        if any(request.form.get(field) for field in ['height_cm', 'weight_kg', 'blood_type']):
            # Get blood_type_id if blood_type is provided
            blood_type_id = None
            if request.form.get('blood_type'):
                blood_result = db.session.execute(
                    db.text("SELECT id FROM blood_types WHERE name = :blood_name LIMIT 1"),
                    {'blood_name': request.form['blood_type']}
                ).fetchone()
                if blood_result:
                    blood_type_id = blood_result[0]

            health_profile = HealthProfile(
                patient_id=patient.id,
                height_cm=float(request.form.get('height_cm')) if request.form.get('height_cm') else None,
                weight_kg=float(request.form.get('weight_kg')) if request.form.get('weight_kg') else None,
                blood_type_id=blood_type_id,
                is_smoker=request.form.get('is_smoker') == 'true',
                smoking_years=int(request.form.get('smoking_years', 0)),
                consumes_alcohol=request.form.get('consumes_alcohol') == 'true',
                alcohol_frequency=request.form.get('alcohol_frequency'),
                physical_activity_minutes_weekly=int(request.form.get('physical_activity_minutes_weekly', 0)),
                notes=request.form.get('notes')
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

    from datetime import datetime
    return render_template('entities/view_patient.html',
                          patient=patient,
                          doctor=doctor,
                          institution=institution,
                          health_profile=health_profile,
                          today_date=datetime.now().date())

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
            existing_email = db.session.execute(
                db.text("""
                    SELECT 1 FROM emails
                    WHERE entity_type = 'patient' AND email_address = :email AND entity_id != :patient_id
                    LIMIT 1
                """),
                {'email': request.form['email'], 'patient_id': patient_id}
            ).fetchone()
            if existing_email:
                flash('Email already exists', 'error')
                return redirect(url_for('entities.edit_patient', patient_id=patient_id))

            # Update patient fields
            patient.first_name = request.form['first_name']
            patient.last_name = request.form['last_name']
            patient.doctor_id = request.form.get('doctor_id') or None
            patient.institution_id = request.form.get('institution_id') or None
            patient.emergency_contact_name = request.form.get('emergency_contact_name')

            # Update gender_id if gender is provided
            if request.form.get('gender'):
                gender_result = db.session.execute(
                    db.text("SELECT id FROM genders WHERE name = :gender_name LIMIT 1"),
                    {'gender_name': request.form['gender']}
                ).fetchone()
                if gender_result:
                    patient.gender_id = gender_result[0]

            # Update or create email
            if request.form.get('email'):
                # First, remove any existing primary email for this patient
                db.session.execute(
                    db.text("DELETE FROM emails WHERE entity_type = 'patient' AND entity_id = :entity_id AND is_primary = TRUE"),
                    {'entity_id': patient_id}
                )
                # Then insert the new email
                db.session.execute(
                    db.text("""
                        INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
                        VALUES ('patient', :entity_id, (SELECT id FROM email_types WHERE name = 'primary'), :email, TRUE, FALSE)
                    """),
                    {'entity_id': patient_id, 'email': request.form['email']}
                )

            # Update or create phone
            if request.form.get('phone'):
                # First, remove any existing primary phone for this patient
                db.session.execute(
                    db.text("DELETE FROM phones WHERE entity_type = 'patient' AND entity_id = :entity_id AND is_primary = TRUE"),
                    {'entity_id': patient_id}
                )
                # Then insert the new phone
                db.session.execute(
                    db.text("""
                        INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                        VALUES ('patient', :entity_id, (SELECT id FROM phone_types WHERE name = 'primary'), :phone, TRUE, FALSE)
                    """),
                    {'entity_id': patient_id, 'phone': request.form['phone']}
                )

            # Update or create emergency contact phone
            if request.form.get('emergency_contact_phone'):
                # First, remove any existing emergency contact phone for this patient
                db.session.execute(
                    db.text("DELETE FROM phones WHERE entity_type = 'emergency_contact' AND entity_id = :entity_id"),
                    {'entity_id': patient_id}
                )
                # Then insert the new emergency contact phone
                db.session.execute(
                    db.text("""
                        INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                        VALUES ('emergency_contact', :entity_id, (SELECT id FROM phone_types WHERE name = 'emergency'), :phone, FALSE, FALSE)
                    """),
                    {'entity_id': patient_id, 'phone': request.form['emergency_contact_phone']}
                )

            # Update health profile if it exists
            health_profile = HealthProfile.query.filter_by(patient_id=patient_id).first()
            if health_profile:
                health_profile.height_cm = float(request.form.get('height_cm')) if request.form.get('height_cm') else None
                health_profile.weight_kg = float(request.form.get('weight_kg')) if request.form.get('weight_kg') else None

                # Update blood_type_id if blood_type is provided
                if request.form.get('blood_type'):
                    blood_result = db.session.execute(
                        db.text("SELECT id FROM blood_types WHERE name = :blood_name LIMIT 1"),
                        {'blood_name': request.form['blood_type']}
                    ).fetchone()
                    health_profile.blood_type_id = blood_result[0] if blood_result else None
                else:
                    health_profile.blood_type_id = None

                health_profile.is_smoker = request.form.get('is_smoker') == 'true'
                health_profile.smoking_years = int(request.form.get('smoking_years', 0))
                health_profile.consumes_alcohol = request.form.get('consumes_alcohol') == 'true'
                health_profile.alcohol_frequency = request.form.get('alcohol_frequency')
                health_profile.physical_activity_minutes_weekly = int(request.form.get('physical_activity_minutes_weekly', 0))
                health_profile.notes = request.form.get('notes')

            db.session.commit()

            flash('Patient updated successfully', 'success')
            return redirect(url_for('entities.patients'))

        except Exception as e:
            db.session.rollback()
            flash(f'Error updating patient: {str(e)}', 'error')
            return redirect(url_for('entities.edit_patient', patient_id=patient_id))

    # GET request - show edit form
    from datetime import datetime
    doctors_rows = Doctor.query.with_entities(Doctor.id, Doctor.first_name, Doctor.last_name).all()
    doctors = [{'id': row[0], 'first_name': row[1], 'last_name': row[2]} for row in doctors_rows]
    institutions = MedicalInstitution.query.with_entities(MedicalInstitution.id, MedicalInstitution.name).all()
    health_profile = HealthProfile.query.filter_by(patient_id=patient_id).first()

    return render_template('entities/edit_patient.html',
                          patient=patient,
                          doctors=doctors,
                          institutions=institutions,
                          health_profile=health_profile,
                          today_date=datetime.now().date().isoformat())

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
        query = query.filter(MedicalInstitution.name.ilike(f'%{q}%'))

    if type_filter:
        query = query.filter(MedicalInstitution.institution_type_id == type_filter)

    if status_filter:
        if status_filter == 'active':
            query = query.filter(MedicalInstitution.is_active == True)
        elif status_filter == 'inactive':
            query = query.filter(MedicalInstitution.is_active == False)

    if region_filter:
        query = query.filter(MedicalInstitution.region_state.ilike(f'%{region_filter}%'))
    
    # Handle sorting
    sort_by = request.args.get('sort_by', 'name')
    sort_order = request.args.get('sort_order', 'asc')
    
    if sort_by == 'name':
        if sort_order == 'asc':
            query = query.order_by(MedicalInstitution.name.asc())
        else:
            query = query.order_by(MedicalInstitution.name.desc())
    elif sort_by == 'created_at':
        if sort_order == 'asc':
            query = query.order_by(MedicalInstitution.created_at.asc())
        else:
            query = query.order_by(MedicalInstitution.created_at.desc())
    else:
        # Default sorting by name
        if sort_order == 'asc':
            query = query.order_by(MedicalInstitution.name.asc())
        else:
            query = query.order_by(MedicalInstitution.name.desc())
    
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
    institution_types = InstitutionType.query.filter_by(is_active=True).all()
    return render_template('entities/create_institution.html', institution_types=institution_types)

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

        # Validate institution_type_id
        institution_type_id = request.form.get('institution_type_id')
        if not institution_type_id:
            flash('Institution type is required', 'error')
            return redirect(url_for('entities.create_institution_form'))

        # Check if institution type exists
        institution_type = InstitutionType.query.get(int(institution_type_id))
        if not institution_type or not institution_type.is_active:
            flash('Invalid institution type', 'error')
            return redirect(url_for('entities.create_institution_form'))

        # Check if email already exists in emails table
        existing_email = db.session.execute(
            db.text("SELECT 1 FROM emails WHERE entity_type = 'institution' AND email_address = :email LIMIT 1"),
            {'email': request.form['contact_email']}
        ).fetchone()
        if existing_email:
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
            institution_type_id=int(institution_type_id),
            license_number=request.form['license_number'],
            website=request.form.get('website'),
            is_verified=request.form.get('is_verified') == 'true',
            is_active=request.form.get('is_active', 'true') == 'true'
        )

        db.session.add(institution)
        db.session.flush()  # Get institution ID

        # Create email entry
        if request.form.get('contact_email'):
            db.session.execute(
                db.text("""
                    INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
                    VALUES ('institution', :entity_id, (SELECT id FROM email_types WHERE name = 'primary'), :email, TRUE, FALSE)
                """),
                {'entity_id': institution.id, 'email': request.form['contact_email']}
            )

        # Create phone entry
        if request.form.get('phone'):
            db.session.execute(
                db.text("""
                    INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                    VALUES ('institution', :entity_id, (SELECT id FROM phone_types WHERE name = 'primary'), :phone, TRUE, FALSE)
                """),
                {'entity_id': institution.id, 'phone': request.form['phone']}
            )

        # Create address entry
        if request.form.get('address') or request.form.get('region_state'):
            # Get region_id if region_state is provided
            region_id = None
            if request.form.get('region_state'):
                region_result = db.session.execute(
                    db.text("SELECT id FROM regions WHERE name = :region_name LIMIT 1"),
                    {'region_name': request.form['region_state']}
                ).fetchone()
                region_id = region_result[0] if region_result else None

            db.session.execute(
                db.text("""
                    INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
                    VALUES ('institution', :entity_id, 'primary', :address, :city, :region_id, (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, FALSE)
                """),
                {
                    'entity_id': institution.id,
                    'address': request.form.get('address', ''),
                    'city': request.form.get('city', ''),
                    'region_id': region_id
                }
            )

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

            # Validate institution_type_id
            institution_type_id = request.form.get('institution_type_id')
            if not institution_type_id:
                flash('Institution type is required', 'error')
                return redirect(url_for('entities.edit_institution', institution_id=institution_id))
    
            # Check if institution type exists
            institution_type = InstitutionType.query.get(int(institution_type_id))
            if not institution_type or not institution_type.is_active:
                flash('Invalid institution type', 'error')
                return redirect(url_for('entities.edit_institution', institution_id=institution_id))

            # Check for duplicate email (excluding current institution)
            existing_email = db.session.execute(
                db.text("""
                    SELECT 1 FROM emails
                    WHERE entity_type = 'institution' AND email_address = :email AND entity_id != :institution_id
                    LIMIT 1
                """),
                {'email': request.form['contact_email'], 'institution_id': institution_id}
            ).fetchone()
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
            institution.institution_type_id = int(institution_type_id)
            institution.license_number = request.form['license_number']
            institution.website = request.form.get('website')
            institution.is_verified = request.form.get('is_verified') == 'true'
            institution.is_active = request.form.get('is_active') == 'true'

            # Update or create email
            if request.form.get('contact_email'):
                # First, remove any existing primary email for this institution
                db.session.execute(
                    db.text("DELETE FROM emails WHERE entity_type = 'institution' AND entity_id = :entity_id AND is_primary = TRUE"),
                    {'entity_id': institution_id}
                )
                # Then insert the new email
                db.session.execute(
                    db.text("""
                        INSERT INTO emails (entity_type, entity_id, email_type_id, email_address, is_primary, is_verified)
                        VALUES ('institution', :entity_id, (SELECT id FROM email_types WHERE name = 'primary'), :email, TRUE, FALSE)
                    """),
                    {'entity_id': institution_id, 'email': request.form['contact_email']}
                )

            # Update or create phone
            if request.form.get('phone'):
                # First, remove any existing primary phone for this institution
                db.session.execute(
                    db.text("DELETE FROM phones WHERE entity_type = 'institution' AND entity_id = :entity_id AND is_primary = TRUE"),
                    {'entity_id': institution_id}
                )
                # Then insert the new phone
                db.session.execute(
                    db.text("""
                        INSERT INTO phones (entity_type, entity_id, phone_type_id, phone_number, is_primary, is_verified)
                        VALUES ('institution', :entity_id, (SELECT id FROM phone_types WHERE name = 'primary'), :phone, TRUE, FALSE)
                    """),
                    {'entity_id': institution_id, 'phone': request.form['phone']}
                )

            # Update or create address
            if request.form.get('address') or request.form.get('region_state'):
                # First, remove any existing primary address for this institution
                db.session.execute(
                    db.text("DELETE FROM addresses WHERE entity_type = 'institution' AND entity_id = :entity_id AND is_primary = TRUE"),
                    {'entity_id': institution_id}
                )

                # Get region_id if region_state is provided
                region_id = None
                if request.form.get('region_state'):
                    region_result = db.session.execute(
                        db.text("SELECT id FROM regions WHERE name = :region_name LIMIT 1"),
                        {'region_name': request.form['region_state']}
                    ).fetchone()
                    region_id = region_result[0] if region_result else None

                # Then insert the new address
                db.session.execute(
                    db.text("""
                        INSERT INTO addresses (entity_type, entity_id, address_type, street_address, city, region_id, country_id, is_primary, is_verified)
                        VALUES ('institution', :entity_id, 'primary', :address, :city, :region_id, (SELECT id FROM countries WHERE iso_code = 'MEX'), TRUE, FALSE)
                    """),
                    {
                        'entity_id': institution_id,
                        'address': request.form.get('address', ''),
                        'city': request.form.get('city', ''),
                        'region_id': region_id
                    }
                )

            db.session.commit()

            flash('Institution updated successfully', 'success')
            return redirect(url_for('entities.institutions'))

        except Exception as e:
            db.session.rollback()
            flash(f'Error updating institution: {str(e)}', 'error')
            return redirect(url_for('entities.edit_institution', institution_id=institution_id))

    # GET request - show edit form
    institution_types = InstitutionType.query.filter_by(is_active=True).all()
    return render_template('entities/edit_institution.html', institution=institution, institution_types=institution_types)

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
