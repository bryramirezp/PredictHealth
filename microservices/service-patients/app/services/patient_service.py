# /microservices\service-patients\app\services\patient_service.py
# /microservices/service-patients/app/services/patient_service.py
# Patients service - business data only

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from typing import List, Optional, Dict, Any
from fastapi import HTTPException, status
import logging
from datetime import date, datetime
import uuid

from app.models.patient import Patient

logger = logging.getLogger(__name__)

class PatientService:
    """Patients service - business data only"""
    
    def __init__(self):
        self.allowed_genders = ['male', 'female', 'other']
        self.validation_states = ['pending', 'doctor_validated', 'institution_validated', 'full_access']
    
    def create_patient(
        self, 
        db: Session, 
        patient_data: Dict[str, Any]
    ) -> Patient:
        """
        Create a new patient

        Args:
            db: Database session
            patient_data: Patient data

        Returns:
            Patient: Created patient

        Raises:
            HTTPException: If validation errors occur
        """
        try:
            # Validate required fields
            required_fields = ['first_name', 'last_name', 'email', 'date_of_birth']
            for field in required_fields:
                if not patient_data.get(field):
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Required field: {field}"
                    )
            
            # Validate gender if provided
            if patient_data.get('gender') and patient_data['gender'] not in self.allowed_genders:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid gender. Allowed: {', '.join(self.allowed_genders)}"
                )
            
            # Ensure email is unique
            existing_patient = db.query(Patient).filter(
                Patient.email == patient_data['email']
            ).first()
            
            if existing_patient:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
            
            # Create patient
            patient = Patient(
                first_name=patient_data['first_name'],
                last_name=patient_data['last_name'],
                email=patient_data['email'],
                date_of_birth=patient_data['date_of_birth'],
                gender=patient_data.get('gender'),
                validation_status=patient_data.get('validation_status', 'pending'),
                doctor_id=patient_data.get('doctor_id'),
                institution_id=patient_data.get('institution_id')
            )
            
            db.add(patient)
            db.commit()
            db.refresh(patient)
            
            logger.info(f"✅ Patient created: {patient.first_name} {patient.last_name} ({patient.email})")
            
            return patient
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error creating patient: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error creating patient"
            )
    
    def get_patient_by_id(
        self, 
        db: Session, 
        patient_id: str
    ) -> Optional[Patient]:
        """
        Get patient by ID

        Args:
            db: Database session
            patient_id: Patient ID

        Returns:
            Optional[Patient]: Patient found or None
        """
        try:
            patient = db.query(Patient).filter(
                Patient.id == patient_id
            ).first()
            
            return patient
            
        except Exception as e:
            logger.error(f"❌ Error getting patient by ID: {str(e)}")
            return None
    
    def get_patient_by_email(
        self, 
        db: Session, 
        email: str
    ) -> Optional[Patient]:
        """
        Get patient by email

        Args:
            db: Database session
            email: Patient email

        Returns:
            Optional[Patient]: Patient found or None
        """
        try:
            patient = db.query(Patient).filter(
                Patient.email == email
            ).first()
            
            return patient
            
        except Exception as e:
            logger.error(f"❌ Error getting patient by email: {str(e)}")
            return None
    
    def get_patients_by_doctor(
        self, 
        db: Session, 
        doctor_id: str
    ) -> List[Patient]:
        """
        Get patients by doctor

        Args:
            db: Database session
            doctor_id: Doctor ID

        Returns:
            List[Patient]: List of patients
        """
        try:
            patients = db.query(Patient).filter(
                Patient.doctor_id == doctor_id
            ).all()
            
            return patients
            
        except Exception as e:
            logger.error(f"❌ Error getting patients by doctor: {str(e)}")
            return []
    
    def get_patients_by_institution(
        self, 
        db: Session, 
        institution_id: str
    ) -> List[Patient]:
        """
        Get patients by institution

        Args:
            db: Database session
            institution_id: Institution ID

        Returns:
            List[Patient]: List of patients
        """
        try:
            patients = db.query(Patient).filter(
                Patient.institution_id == institution_id
            ).all()
            
            return patients
            
        except Exception as e:
            logger.error(f"❌ Error getting patients by institution: {str(e)}")
            return []
    
    def get_patients_by_validation_state(
        self, 
        db: Session, 
        validation_state: str
    ) -> List[Patient]:
        """
        Get patients by validation status

        Args:
            db: Database session
            validation_state: Validation state

        Returns:
            List[Patient]: List of patients
        """
        try:
            patients = db.query(Patient).filter(
                Patient.validation_status == validation_state
            ).all()
            
            return patients
            
        except Exception as e:
            logger.error(f"❌ Error getting patients by validation state: {str(e)}")
            return []
    
    def get_all_patients(
        self, 
        db: Session, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[Patient]:
        """
        Get all patients with pagination

        Args:
            db: Database session
            skip: Number of records to skip
            limit: Record limit

        Returns:
            List[Patient]: List of patients
        """
        try:
            patients = db.query(Patient).offset(skip).limit(limit).all()
            
            return patients
            
        except Exception as e:
            logger.error(f"❌ Error getting all patients: {str(e)}")
            return []
    
    def update_patient(
        self, 
        db: Session, 
        patient_id: str, 
        update_data: Dict[str, Any]
    ) -> Optional[Patient]:
        """
        Update a patient

        Args:
            db: Database session
            patient_id: Patient ID
            update_data: Data to update

        Returns:
            Optional[Patient]: Patient updated or None
        """
        try:
            patient = self.get_patient_by_id(db, patient_id)
            
            if not patient:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Patient not found"
                )
            
            # Validate gender if being updated
            if 'gender' in update_data and update_data['gender'] not in self.allowed_genders:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid gender. Allowed: {', '.join(self.allowed_genders)}"
                )
            
            # Validate validation state if being updated
            if 'validation_status' in update_data and update_data['validation_status'] not in self.validation_states:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid validation_status. Allowed: {', '.join(self.validation_states)}"
                )
            
            # Check unique email if being updated
            if 'email' in update_data and update_data['email'] != patient.email:
                existing_patient = db.query(Patient).filter(
                    and_(
                        Patient.email == update_data['email'],
                        Patient.id != patient_id
                    )
                ).first()
                
                if existing_patient:
                    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
            
            # Update fields
            for field, value in update_data.items():
                if hasattr(patient, field) and value is not None:
                    setattr(patient, field, value)
            
            db.commit()
            db.refresh(patient)
            
            logger.info(f"✅ Patient updated: {patient.first_name} {patient.last_name}")
            
            return patient
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error updating patient: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error updating patient"
            )
    
    def delete_patient(
        self, 
        db: Session, 
        patient_id: str
    ) -> bool:
        """
        Delete a patient

        Args:
            db: Database session
            patient_id: Patient ID

        Returns:
            bool: True if deleted successfully
        """
        try:
            patient = self.get_patient_by_id(db, patient_id)
            
            if not patient:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")
            
            db.delete(patient)
            db.commit()
            
            logger.info(f"✅ Patient deleted: {patient.first_name} {patient.last_name}")
            
            return True
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error deleting patient: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Internal error deleting patient"
            )
    
    def search_patients(
        self, 
        db: Session, 
        query: str, 
        gender: Optional[str] = None,
        validation_state: Optional[str] = None,
        doctor_id: Optional[str] = None,
        institution_id: Optional[str] = None
    ) -> List[Patient]:
        """
        Search patients by criteria

        Args:
            db: Database session
            query: Search term
            gender: Gender (optional)
            validation_state: Validation state (optional)
            doctor_id: Doctor ID (optional)
            institution_id: Institution ID (optional)

        Returns:
            List[Patient]: List of patients found
        """
        try:
            # Build base query
            search_query = db.query(Patient).filter(
                or_(
                    Patient.first_name.ilike(f"%{query}%"),
                    Patient.last_name.ilike(f"%{query}%"),
                    Patient.email.ilike(f"%{query}%")
                )
            )
            
            # Apply additional filters
            if gender:
                search_query = search_query.filter(Patient.gender == gender)

            if validation_state:
                search_query = search_query.filter(Patient.validation_status == validation_state)
            
            if doctor_id:
                search_query = search_query.filter(Patient.doctor_id == doctor_id)

            if institution_id:
                search_query = search_query.filter(Patient.institution_id == institution_id)
            
            patients = search_query.all()
            
            logger.info(f"✅ Search done: {len(patients)} patients found")
            
            return patients
            
        except Exception as e:
            logger.error(f"❌ Error searching patients: {str(e)}")
            return []
    
    def get_patient_statistics(self, db: Session) -> Dict[str, Any]:
        """Get comprehensive patient statistics"""
        try:
            # Basic counts
            total = db.query(Patient).count()

            # Group by gender
            gender_stats = db.query(
                Patient.gender,
                func.count(Patient.id).label('count')
            ).group_by(
                Patient.gender
            ).all()

            # Group by validation status
            val_stats = db.query(
                Patient.validation_status,
                func.count(Patient.id).label('count')
            ).group_by(
                Patient.validation_status
            ).all()

            # Group by doctor
            doctor_stats = db.query(
                Patient.doctor_id,
                func.count(Patient.id).label('count')
            ).group_by(
                Patient.doctor_id
            ).all()

            # Calculate new patients this month
            from datetime import datetime, timedelta
            current_date = datetime.now()
            month_ago = current_date - timedelta(days=30)
            new_patients_this_month = db.query(Patient).filter(
                Patient.created_at >= month_ago
            ).count()

            # Format statistics
            by_gender = {stat.gender: stat.count for stat in gender_stats if stat.gender}
            by_validation = {stat.validation_status: stat.count for stat in val_stats if stat.validation_status}
            by_doctor = {str(stat.doctor_id): stat.count for stat in doctor_stats if stat.doctor_id}

            return {
                "total_patients": total,
                "by_gender": by_gender,
                "by_validation_state": by_validation,
                "by_doctor": by_doctor,
                "new_patients_this_month": new_patients_this_month
            }
        except Exception as e:
            print(f"❌ Error getting statistics: {str(e)}")
            return {
                "total_patients": 0,
                "by_gender": {},
                "by_validation_state": {
                    "pending": 0,
                    "doctor_validated": 0,
                    "institution_validated": 0,
                    "full_access": 0
                },
                "by_doctor": {},
                "new_patients_this_month": 0
            }
    
    def calculate_age(self, birth_date: date) -> int:
        """
        Calculate patient age

        Args:
            birth_date: Birth date

        Returns:
            int: Age in years
        """
        try:
            today = date.today()
            age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
            return age
        except Exception as e:
            logger.error(f"❌ Error calculating age: {str(e)}")
            return 0

# Global instance of patients service
patient_service = PatientService()
