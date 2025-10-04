# /microservices\service-doctors\app\services\doctor_service.py
# /microservices/service-doctors/app/services/doctor_service.py
# Doctors service - business data only

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, distinct
from typing import List, Optional, Dict, Any
from fastapi import HTTPException, status
import logging
import uuid

from app.models.doctor import Doctor
from app.models.patient import Patient
from app.models.user import User
from app.models.doctor_specialty import DoctorSpecialty
from app.core.security import SecurityUtils

logger = logging.getLogger(__name__)

class DoctorService:
    """Doctors service - business data only"""
    
    def __init__(self):
        self.common_specialties = [
            'general_medicine', 'cardiology', 'neurology', 'pediatrics',
            'gynecology', 'orthopedics', 'dermatology', 'psychiatry',
            'oncology', 'endocrinology', 'gastroenterology', 'pulmonology'
        ]
    
    def create_doctor(
        self,
        db: Session,
        doctor_data: Dict[str, Any]
    ) -> Doctor:
        """
        Create a new doctor (business data only) with centralized auth coordination.

        Flow (per Reporte3.0):
        1) Validate input (no DB transaction)
        2) Create user in centralized auth service (sync call)
        3) Create local doctor record in DB (short transaction)
        4) Update auth user reference to point to the created domain id
        5) On any failure after auth user creation, attempt compensation (delete auth user)

        Args:
            db: Database session
            doctor_data: Doctor data (expects 'password' for user creation)

        Returns:
            Doctor: Created doctor

        Raises:
            HTTPException: If validation or remote creation errors occur
        """
        user_id_created = None
        try:
            # Validate required fields
            required_fields = ['first_name', 'last_name', 'email', 'medical_license', 'password']
            for field in required_fields:
                if not doctor_data.get(field):
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Required field: {field}"
                    )

            # Ensure email is unique locally (best-effort) to fail fast
            existing_doctor = db.query(Doctor).filter(
                Doctor.email == doctor_data['email']
            ).first()

            if existing_doctor:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

            # Ensure medical license is unique locally
            existing_license = db.query(Doctor).filter(
                Doctor.medical_license == doctor_data['medical_license']
            ).first()

            if existing_license:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Medical license already registered")

            # --------------- Phase 2: Create centralized auth user (synchronous helper) ---------------
            from app.clients.auth_client import sync_auth_client

            auth_result = sync_auth_client.create_user(
                email=doctor_data['email'],
                password=doctor_data['password'],
                user_type="doctor",
                timeout=5
            )

            if not auth_result or not auth_result.get('user_id'):
                logger.error("❌ Failed to create auth user for doctor")
                raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail="Failed to create user in auth service")

            user_id_created = auth_result.get('user_id')
            logger.info(f"🔐 Auth user created with id: {user_id_created}")

            # --------------- Phase 3: Create local doctor record (short transaction) ---------------
            # Handle specialty - convert name to ID if needed
            specialty_id = None
            if doctor_data.get('specialty'):
                # Look up specialty by name
                specialty_record = db.query(DoctorSpecialty).filter(
                    DoctorSpecialty.name == doctor_data['specialty']
                ).first()
                if specialty_record:
                    specialty_id = specialty_record.id
                else:
                    # If specialty not found, log warning but continue
                    logger.warning(f"⚠️ Specialty '{doctor_data['specialty']}' not found in database")
            elif doctor_data.get('specialty_id'):
                specialty_id = doctor_data['specialty_id']

            doctor = Doctor(
                first_name=doctor_data['first_name'],
                last_name=doctor_data['last_name'],
                email=doctor_data['email'],
                medical_license=doctor_data['medical_license'],
                specialty_id=specialty_id,
                institution_id=doctor_data.get('institution_id')
            )

            db.add(doctor)
            db.commit()
            db.refresh(doctor)

            logger.info(f"✅ Doctor created (business data): {doctor.first_name} {doctor.last_name} ({doctor.email})")

            # --------------- Phase 4: Attach reference in auth service ---------------
            try:
                set_ref_ok = sync_auth_client.set_user_reference(user_id=user_id_created, reference_id=str(doctor.id))
                if not set_ref_ok:
                    # Log warning — system should enqueue compensation/reconciliation if needed
                    logger.warning(f"⚠️ Failed to set user reference in auth service for user {user_id_created}")
            except Exception as ex:
                logger.error(f"❌ Error setting user reference in auth service: {ex}")

            return doctor

        except HTTPException:
            # Preserve HTTP errors to be returned as-is
            raise
        except Exception as e:
            logger.error(f"❌ Error creating doctor: {str(e)}")
            # Attempt compensation: remove remote auth user if it was created
            try:
                if user_id_created:
                    from app.clients.auth_client import sync_auth_client as _sync
                    deleted = _sync.delete_user(user_id_created, timeout=5)
                    if deleted:
                        logger.info(f"♻️ Compensated: deleted remote auth user {user_id_created}")
                    else:
                        logger.warning(f"⚠️ Compensation failed: could not delete remote auth user {user_id_created}")
            except Exception as comp_ex:
                logger.error(f"❌ Error during compensation delete_user: {comp_ex}")

            # Rollback DB in case partial changes happened
            try:
                db.rollback()
            except Exception:
                pass

            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error creating doctor"
            )

    def create_patient(
        self,
        db: Session,
        patient_data: Dict[str, Any],
        doctor_id: str = None
    ) -> Patient:
        """
        Create a new patient (can be called by doctors)

        Args:
            db: Database session
            patient_data: Patient data including password for user creation
            doctor_id: Optional doctor ID to associate patient with

        Returns:
            Patient: Created patient

        Raises:
            HTTPException: If validation fails
        """
        try:
            # Sanitize and validate required fields
            patient_data['first_name'] = SecurityUtils.sanitize_input(patient_data.get('first_name', ''))
            patient_data['last_name'] = SecurityUtils.sanitize_input(patient_data.get('last_name', ''))
            patient_data['email'] = SecurityUtils.sanitize_input(patient_data.get('email', ''))

            required_fields = ['first_name', 'last_name', 'email', 'date_of_birth']
            try:
                SecurityUtils.validate_required_fields(patient_data, required_fields)
            except ValueError as e:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(e)
                )

            # Validate email format
            if not SecurityUtils.validate_email(patient_data['email']):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid email format"
                )

            # Check for duplicate email
            existing_patient = db.query(Patient).filter(Patient.email == patient_data['email']).first()
            if existing_patient:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email already registered"
                )

            # Create user in centralized auth table (if password provided)
            user_created = None
            try:
                if patient_data.get('password'):
                    # Hash the password
                    hashed_password = SecurityUtils.hash_password(patient_data['password'])

                    # Create user in centralized auth table
                    user = User(
                        email=patient_data['email'],
                        password_hash=hashed_password,
                        user_type="patient"
                        # reference_id will be set after patient creation
                    )

                    db.add(user)
                    db.flush()  # Get user ID without committing

                    user_created = user
                    logger.info(f"🔐 Auth user created with id: {user.id}")

                # Create patient
                patient = Patient(
                    doctor_id=doctor_id,
                    institution_id=patient_data.get('institution_id'),
                    first_name=patient_data['first_name'],
                    last_name=patient_data['last_name'],
                    email=patient_data['email'],
                    date_of_birth=patient_data['date_of_birth'],
                    gender=patient_data.get('gender'),
                    phone=patient_data.get('phone'),
                    emergency_contact_name=patient_data.get('emergency_contact_name'),
                    emergency_contact_phone=patient_data.get('emergency_contact_phone')
                )

                db.add(patient)
                db.flush()  # Get patient ID without committing

                # Set reference_id in user if user was created
                if user_created:
                    user_created.reference_id = patient.id

                # Commit both operations
                db.commit()
                db.refresh(patient)

                logger.info(f"✅ Patient created: {patient.first_name} {patient.last_name} ({patient.email})")

                return patient

            except Exception:
                # Rollback on any error
                db.rollback()
                logger.error(f"❌ Error creating patient and user: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Internal error creating patient"
                )

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error creating patient: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error creating patient"
            )

    def get_doctor_by_id(
        self, 
        db: Session, 
        doctor_id: str
    ) -> Optional[Doctor]:
        """
        Get doctor by ID

        Args:
            db: Database session
            doctor_id: Doctor ID

        Returns:
            Optional[Doctor]: Doctor found or None
        """
        try:
            doctor = db.query(Doctor).filter(
                Doctor.id == doctor_id
            ).first()
            
            return doctor
            
        except Exception as e:
            logger.error(f"❌ Error getting doctor by ID: {str(e)}")
            return None
    
    def get_doctor_by_email(
        self, 
        db: Session, 
        email: str
    ) -> Optional[Doctor]:
        """
        Get doctor by email

        Args:
            db: Database session
            email: Doctor email

        Returns:
            Optional[Doctor]: Doctor found or None
        """
        try:
            doctor = db.query(Doctor).filter(
                Doctor.email == email
            ).first()
            
            return doctor
            
        except Exception as e:
            logger.error(f"❌ Error getting doctor by email: {str(e)}")
            return None
    
    def get_doctor_by_license(
        self, 
        db: Session, 
        license_number: str
    ) -> Optional[Doctor]:
        """
        Get doctor by medical license

        Args:
            db: Database session
            license_number: Medical license number

        Returns:
            Optional[Doctor]: Doctor found or None
        """
        try:
            doctor = db.query(Doctor).filter(
                Doctor.medical_license == license_number
            ).first()
            
            return doctor
            
        except Exception as e:
            logger.error(f"❌ Error getting doctor by license: {str(e)}")
            return None
    
    def get_doctors_by_specialty(
        self,
        db: Session,
        specialty: str
    ) -> List[Doctor]:
        """
        Get doctors by specialty

        Args:
            db: Database session
            specialty: Medical specialty name

        Returns:
            List[Doctor]: List of doctors
        """
        try:
            doctors = db.query(Doctor).join(DoctorSpecialty).filter(
                DoctorSpecialty.name == specialty
            ).all()

            return doctors

        except Exception as e:
            logger.error(f"❌ Error getting doctors by specialty: {str(e)}")
            return []
    
    def get_doctors_by_institution(
        self, 
        db: Session, 
        institution_id: str
    ) -> List[Doctor]:
        """
        Get doctors by institution

        Args:
            db: Database session
            institution_id: Institution ID

        Returns:
            List[Doctor]: List of doctors
        """
        try:
            doctors = db.query(Doctor).filter(
                Doctor.institution_id == institution_id
            ).all()
            
            return doctors
            
        except Exception as e:
            logger.error(f"❌ Error getting doctors by institution: {str(e)}")
            return []
    
    def get_all_doctors(
        self, 
        db: Session, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[Doctor]:
        """
        Get all doctors with pagination

        Args:
            db: Database session
            skip: Number of records to skip
            limit: Record limit

        Returns:
            List[Doctor]: List of doctors
        """
        try:
            doctors = db.query(Doctor).offset(skip).limit(limit).all()
            
            return doctors
            
        except Exception as e:
            logger.error(f"❌ Error getting all doctors: {str(e)}")
            return []
    
    def update_doctor(
        self, 
        db: Session, 
        doctor_id: str, 
        update_data: Dict[str, Any]
    ) -> Optional[Doctor]:
        """
        Update a doctor

        Args:
            db: Database session
            doctor_id: Doctor ID
            update_data: Data to update

        Returns:
            Optional[Doctor]: Doctor updated or None
        """
        try:
            doctor = self.get_doctor_by_id(db, doctor_id)
            
            if not doctor:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Doctor not found"
                )
            
            # Verificar email único si se está actualizando
            if 'email' in update_data and update_data['email'] != doctor.email:
                existing_doctor = db.query(Doctor).filter(
                    and_(
                        Doctor.email == update_data['email'],
                        Doctor.id != doctor_id
                    )
                ).first()
                
                if existing_doctor:
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
            
            # Verificar licencia única si se está actualizando
            if 'medical_license' in update_data and update_data['medical_license'] != doctor.medical_license:
                existing_license = db.query(Doctor).filter(
                    and_(
                        Doctor.medical_license == update_data['medical_license'],
                        Doctor.id != doctor_id
                    )
                ).first()
                
                if existing_license:
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Medical license already registered")
            
            # Actualizar campos
            for field, value in update_data.items():
                if hasattr(doctor, field) and value is not None:
                    setattr(doctor, field, value)
            
            db.commit()
            db.refresh(doctor)
            
            logger.info(f"✅ Doctor updated: {doctor.first_name} {doctor.last_name}")
            
            return doctor
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error updating doctor: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error updating doctor"
            )
    
    def delete_doctor(
        self, 
        db: Session, 
        doctor_id: str
    ) -> bool:
        """
        Delete a doctor

        Args:
            db: Database session
            doctor_id: Doctor ID

        Returns:
            bool: True if deleted successfully
        """
        try:
            doctor = self.get_doctor_by_id(db, doctor_id)
            
            if not doctor:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Doctor not found"
                )
            
            db.delete(doctor)
            db.commit()
            
            logger.info(f"✅ Doctor deleted: {doctor.first_name} {doctor.last_name}")
            
            return True
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error deleting doctor: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error deleting doctor"
            )
    
    def search_doctors(
        self,
        db: Session,
        query: str,
        specialty: Optional[str] = None,
        institution_id: Optional[str] = None
    ) -> List[Doctor]:
        """
        Search doctors by criteria

        Args:
            db: Database session
            query: Search term
            specialty: Specialty name (optional)
            institution_id: Institution ID (optional)

        Returns:
            List[Doctor]: List of doctors found
        """
        try:
            # Construir consulta base con join opcional para specialty
            search_query = db.query(Doctor).outerjoin(DoctorSpecialty).filter(
                or_(
                    Doctor.first_name.ilike(f"%{query}%"),
                    Doctor.last_name.ilike(f"%{query}%"),
                    Doctor.email.ilike(f"%{query}%"),
                    Doctor.medical_license.ilike(f"%{query}%"),
                    DoctorSpecialty.name.ilike(f"%{query}%")
                )
            )

            # Aplicar filtros adicionales
            if specialty:
                search_query = search_query.filter(DoctorSpecialty.name == specialty)

            if institution_id:
                search_query = search_query.filter(Doctor.institution_id == institution_id)

            doctors = search_query.all()

            logger.info(f"✅ Search done: {len(doctors)} doctors found")

            return doctors

        except Exception as e:
            logger.error(f"❌ Error searching doctors: {str(e)}")
            return []
    
    def get_doctor_statistics(self, db: Session) -> Dict[str, Any]:
        """Get comprehensive doctor statistics"""
        try:
            # Basic counts
            total_doctors = db.query(Doctor).count()

            # Group by specialty with proper join
            specialty_stats = db.query(
                DoctorSpecialty.name,
                func.count(Doctor.id).label('count')
            ).join(
                Doctor, Doctor.specialty_id == DoctorSpecialty.id
            ).group_by(
                DoctorSpecialty.name
            ).all()

            # Group by institution
            institution_stats = db.query(
                Doctor.institution_id,
                func.count(Doctor.id).label('count')
            ).group_by(
                Doctor.institution_id
            ).all()

            # Calculate new doctors this month
            from datetime import datetime, timedelta
            current_date = datetime.now()
            month_ago = current_date - timedelta(days=30)
            new_doctors_this_month = db.query(Doctor).filter(
                Doctor.created_at >= month_ago
            ).count()

            return {
                "total_doctors": total_doctors,
                "by_specialty": {spec.name: spec.count for spec in specialty_stats} if specialty_stats else {},
                "by_institution": {str(inst.institution_id): inst.count for inst in institution_stats if inst.institution_id} if institution_stats else {},
                "new_doctors_this_month": new_doctors_this_month
            }
        except Exception as e:
            print(f"❌ Error getting statistics: {str(e)}")
            return {
                "total_doctors": 0,
                "by_specialty": {},
                "by_institution": {},
                "new_doctors_this_month": 0
            }

# Instancia global del servicio de doctores
doctor_service = DoctorService()
