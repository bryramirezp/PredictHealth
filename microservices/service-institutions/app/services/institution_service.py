# /microservices\service-institutions\app\services\institution_service.py
# /microservicios/servicio-instituciones/services/institution_service.py
# Servicio de instituciones - solo datos de negocio

from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from typing import List, Optional, Dict, Any
from fastapi import HTTPException, status
import logging
import uuid

from app.models.institution import MedicalInstitution
from app.models.doctor import Doctor
from app.models.user import User
from app.core.security import SecurityUtils

logger = logging.getLogger(__name__)

class InstitutionService:
    """Institution service - business data only"""
    
    def __init__(self):
        # Must match database/postgresql/init.sql
        self.allowed_types = [
            'preventive_clinic',
            'insurer',
            'public_health',
            'hospital',
            'health_center'
        ]
    
    def create_institution(
        self, 
        db: Session, 
        institution_data: Dict[str, Any]
    ) -> MedicalInstitution:
        """
        Create a new medical institution
        
        Args:
            db: Sesión de base de datos
            institution_data: Datos de la institución
            
        Returns:
            MedicalInstitution: Institución creada
            
        Raises:
            HTTPException: Si hay errores de validación
        """
        try:
            # Sanitizar y validar datos de entrada
            institution_data['name'] = SecurityUtils.sanitize_input(institution_data.get('name', ''))
            institution_data['contact_email'] = SecurityUtils.sanitize_input(institution_data.get('contact_email', ''))
            institution_data['address'] = SecurityUtils.sanitize_input(institution_data.get('address', ''))
            institution_data['region_state'] = SecurityUtils.sanitize_input(institution_data.get('region_state', ''))
            
            # Validate required fields
            required_fields = ['name', 'institution_type', 'contact_email']
            try:
                SecurityUtils.validate_required_fields(institution_data, required_fields)
            except ValueError as e:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=str(e)
                )
            
            # Validate email format
            if not SecurityUtils.validate_email(institution_data['contact_email']):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Formato de email inválido"
                )
            
            # Validate institution type
            if institution_data['institution_type'] not in self.allowed_types:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid institution_type. Allowed: {', '.join(self.allowed_types)}"
                )
            
            # Enforce unique email
            existing_institution = db.query(MedicalInstitution).filter(
                MedicalInstitution.contact_email == institution_data['contact_email']
            ).first()
            
            if existing_institution:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email already registered"
                )
            
            # Create institution first (business data only)
            institution = MedicalInstitution(
                name=institution_data['name'],
                institution_type=institution_data['institution_type'],
                contact_email=institution_data['contact_email'],
                address=institution_data.get('address'),
                region_state=institution_data.get('region_state')
            )

            db.add(institution)
            db.flush()  # Get institution ID without committing

            # Create user in centralized auth table (if password provided)
            user_created = None
            if institution_data.get('password'):
                # Hash the password
                hashed_password = SecurityUtils.hash_password(institution_data['password'])

                # Create user in centralized auth table with institution ID as reference
                user = User(
                    email=institution_data['contact_email'],
                    password_hash=hashed_password,
                    user_type="institution",
                    reference_id=institution.id  # Now we have the institution ID
                )

                db.add(user)
                db.flush()  # Get user ID without committing

                user_created = user
                logger.info(f"🔐 Auth user created with id: {user.id}")

            # Commit both operations
            db.commit()
            db.refresh(institution)

            logger.info(f"✅ Institution created: {institution.name} ({institution.contact_email})")

            return institution
            
            return institution
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error creando institución: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error creating institution"
            )
    
    def get_institution_by_id(
        self, 
        db: Session, 
        institution_id: str
    ) -> Optional[MedicalInstitution]:
        """
        Get institution by ID
        
        Args:
            db: Sesión de base de datos
            institution_id: ID de la institución
            
        Returns:
            Optional[MedicalInstitution]: Institución encontrada o None
        """
        try:
            institution = db.query(MedicalInstitution).filter(
                MedicalInstitution.id == institution_id
            ).first()
            
            return institution
            
        except Exception as e:
            logger.error(f"❌ Error obteniendo institución por ID: {str(e)}")
            return None
    
    def get_institution_by_email(
        self, 
        db: Session, 
        email: str
    ) -> Optional[MedicalInstitution]:
        """
        Get institution by email
        
        Args:
            db: Sesión de base de datos
            email: Email de la institución
            
        Returns:
            Optional[MedicalInstitution]: Institución encontrada o None
        """
        try:
            institution = db.query(MedicalInstitution).filter(
                MedicalInstitution.contact_email == email
            ).first()
            
            return institution
            
        except Exception as e:
            logger.error(f"❌ Error obteniendo institución por email: {str(e)}")
            return None
    
    def get_institutions_by_type(
        self, 
        db: Session, 
        institution_type: str
    ) -> List[MedicalInstitution]:
        """
        Get institutions by type
        
        Args:
            db: Sesión de base de datos
            institution_type: Tipo de institución
            
        Returns:
            List[MedicalInstitution]: Lista de instituciones
        """
        try:
            institutions = db.query(MedicalInstitution).filter(
                MedicalInstitution.institution_type == institution_type
            ).all()
            
            return institutions
            
        except Exception as e:
            logger.error(f"❌ Error obteniendo instituciones por tipo: {str(e)}")
            return []
    
    def get_institutions_by_region(
        self, 
        db: Session, 
        region: str
    ) -> List[MedicalInstitution]:
        """
        Get institutions by region
        
        Args:
            db: Sesión de base de datos
            region: Región/estado
            
        Returns:
            List[MedicalInstitution]: Lista de instituciones
        """
        try:
            institutions = db.query(MedicalInstitution).filter(
                MedicalInstitution.region_state.ilike(f"%{region}%")
            ).all()
            
            return institutions
            
        except Exception as e:
            logger.error(f"❌ Error obteniendo instituciones por región: {str(e)}")
            return []
    
    def get_all_institutions(
        self, 
        db: Session, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[MedicalInstitution]:
        """
        Obtiene todas las instituciones con paginación
        
        Args:
            db: Sesión de base de datos
            skip: Número de registros a saltar
            limit: Límite de registros
            
        Returns:
            List[MedicalInstitution]: Institutions list
        """
        try:
            institutions = db.query(MedicalInstitution).offset(skip).limit(limit).all()
            
            return institutions
            
        except Exception as e:
            logger.error(f"❌ Error obteniendo todas las instituciones: {str(e)}")
            return []
    
    def update_institution(
        self, 
        db: Session, 
        institution_id: str, 
        update_data: Dict[str, Any]
    ) -> Optional[MedicalInstitution]:
        """
        Update an institution
        
        Args:
            db: Sesión de base de datos
            institution_id: ID de la institución
            update_data: Datos a actualizar
            
        Returns:
            Optional[MedicalInstitution]: Institución actualizada o None
        """
        try:
            institution = self.get_institution_by_id(db, institution_id)
            
            if not institution:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Institución no encontrada"
                )
            
            # Validar tipo si se está actualizando
            if 'institution_type' in update_data:
                if update_data['institution_type'] not in self.allowed_types:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Invalid institution_type. Allowed: {', '.join(self.allowed_types)}"
                    )
            
            # Actualizar campos
            for field, value in update_data.items():
                if hasattr(institution, field) and value is not None:
                    setattr(institution, field, value)
            
            db.commit()
            db.refresh(institution)
            
            logger.info(f"✅ Institution updated: {institution.name}")
            
            return institution
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error actualizando institución: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error updating institution"
            )
    
    def delete_institution(
        self, 
        db: Session, 
        institution_id: str
    ) -> bool:
        """
        Delete an institution
        
        Args:
            db: Sesión de base de datos
            institution_id: ID de la institución
            
        Returns:
            bool: True si se eliminó correctamente
        """
        try:
            institution = self.get_institution_by_id(db, institution_id)
            
            if not institution:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Institución no encontrada"
                )
            
            db.delete(institution)
            db.commit()
            
            logger.info(f"✅ Institution deleted: {institution.name}")
            
            return True
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"❌ Error eliminando institución: {str(e)}")
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal error deleting institution"
            )
    
    def search_institutions(
        self, 
        db: Session, 
        query: str, 
        institution_type: Optional[str] = None,
        region: Optional[str] = None
    ) -> List[MedicalInstitution]:
        """
        Search institutions by criteria
        
        Args:
            db: Sesión de base de datos
            query: Término de búsqueda
            institution_type: Tipo de institución (opcional)
            region: Región (opcional)
            
        Returns:
            List[MedicalInstitution]: Lista de instituciones encontradas
        """
        try:
            # Construir consulta base
            search_query = db.query(MedicalInstitution).filter(
                or_(
                    MedicalInstitution.name.ilike(f"%{query}%"),
                    MedicalInstitution.contact_email.ilike(f"%{query}%"),
                    MedicalInstitution.address.ilike(f"%{query}%")
                )
            )
            
            # Aplicar filtros adicionales
            if institution_type:
                search_query = search_query.filter(
                    MedicalInstitution.institution_type == institution_type
                )
            
            if region:
                search_query = search_query.filter(
                    MedicalInstitution.region_state.ilike(f"%{region}%")
                )
            
            institutions = search_query.all()
            
            logger.info(f"✅ Search done: {len(institutions)} institutions found")
            
            return institutions
            
        except Exception as e:
            logger.error(f"❌ Error buscando instituciones: {str(e)}")
            return []
    
    def get_institution_statistics(self, db: Session) -> Dict[str, Any]:
        """
        Get institutions statistics
        
        Args:
            db: Sesión de base de datos
            
        Returns:
            Dict[str, Any]: Estadísticas de instituciones
        """
        try:
            total_institutions = db.query(MedicalInstitution).count()
            
            # Estadísticas por tipo
            type_stats = {}
            for institution_type in self.allowed_types:
                count = db.query(MedicalInstitution).filter(
                    MedicalInstitution.institution_type == institution_type
                ).count()
                type_stats[institution_type] = count
            
            # Estadísticas por región
            region_stats = db.query(
                MedicalInstitution.region_state,
                db.func.count(MedicalInstitution.id)
            ).group_by(MedicalInstitution.region_state).all()
            
            return {
                "total_institutions": total_institutions,
                "by_type": type_stats,
                "by_region": dict(region_stats)
            }
            
        except Exception as e:
            logger.error(f"❌ Error obteniendo estadísticas: {str(e)}")
            return {}

    def get_statistics(self, db: Session) -> Dict[str, Any]:
        """Get comprehensive institution statistics"""
        try:
            # Basic counts
            total = db.query(MedicalInstitution).count()

            # Group by type
            type_stats = db.query(
                MedicalInstitution.institution_type,
                func.count(MedicalInstitution.id).label('count')
            ).group_by(
                MedicalInstitution.institution_type
            ).all()

            # Group by region
            region_stats = db.query(
                MedicalInstitution.region_state,
                func.count(MedicalInstitution.id).label('count')
            ).group_by(
                MedicalInstitution.region_state
            ).all()

            return {
                "total_institutions": total,
                "by_type": {stat.institution_type: stat.count for stat in type_stats if stat.institution_type},
                "by_region": {stat.region_state: stat.count for stat in region_stats if stat.region_state}
            }
        except Exception as e:
            print(f"❌ Error getting statistics: {str(e)}")
            return {
                "total_institutions": 0,
                "by_type": {},
                "by_region": {}
            }

    def authenticate_institution(self, db: Session, email: str, password: str) -> Optional[MedicalInstitution]:
        """
        Authenticate an institution by email and password

        Args:
            db: Database session
            email: Institution email
            password: Plain text password

        Returns:
            Optional[MedicalInstitution]: Institution if authenticated, None otherwise
        """
        try:
            # Get institution by email
            institution = self.get_institution_by_email(db, email)

            if not institution:
                logger.warning(f"⚠️ Institution not found for email: {email}")
                return None

            # Check if password is set
            if not institution.password_hash:
                logger.warning(f"⚠️ No password set for institution: {email}")
                return None

            # Verify password
            if SecurityUtils.verify_password(password, institution.password_hash):
                logger.info(f"✅ Institution authenticated: {email}")
                # Update last login
                self.update_last_login(db, str(institution.id))
                return institution
            else:
                logger.warning(f"⚠️ Invalid password for institution: {email}")
                return None

        except Exception as e:
            logger.error(f"❌ Error authenticating institution: {str(e)}")
            return None

    def update_last_login(self, db: Session, institution_id: str) -> bool:
        """
        Update institution's last login timestamp

        Args:
            db: Database session
            institution_id: Institution ID

        Returns:
            bool: True if updated successfully
        """
        try:
            from datetime import datetime

            institution = db.query(MedicalInstitution).filter(
                MedicalInstitution.id == institution_id
            ).first()

            if institution:
                institution.last_login = datetime.utcnow()
                db.commit()
                logger.info(f"✅ Last login updated for institution: {institution_id}")
                return True
            else:
                logger.warning(f"⚠️ Institution not found: {institution_id}")
                return False

        except Exception as e:
            logger.error(f"❌ Error updating last login: {str(e)}")
            db.rollback()
            return False

# Instancia global del servicio de instituciones
institution_service = InstitutionService()
