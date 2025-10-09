from app.models import db
from datetime import datetime

class Role(db.Model):
    __tablename__ = 'cms_roles'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    description = db.Column(db.Text)
    permissions = db.Column(db.JSON, default=dict)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationships
    user_roles = db.relationship('UserRole', back_populates='role', lazy='dynamic')

    def __repr__(self):
        return f'<Role {self.name}>'

class UserRole(db.Model):
    __tablename__ = 'cms_user_roles'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('cms_users.id'), nullable=False)
    role_id = db.Column(db.Integer, db.ForeignKey('cms_roles.id'), nullable=False)
    assigned_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Relationships
    user = db.relationship('User', back_populates='roles')
    role = db.relationship('Role', back_populates='user_roles')

    __table_args__ = (
        db.UniqueConstraint('user_id', 'role_id', name='unique_user_role'),
    )

    def __repr__(self):
        return f'<UserRole user={self.user_id} role={self.role_id}>'