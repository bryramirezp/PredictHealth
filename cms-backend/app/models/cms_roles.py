import uuid
from app.models import db
from datetime import datetime
import json

class AdminCMS(db.Model):
    __tablename__ = 'admin_cms'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.Integer, db.ForeignKey('cms_users.id'), unique=True, nullable=False)
    email = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(100), nullable=False)
    last_name = db.Column(db.String(100), nullable=False)
    department = db.Column(db.String(100))
    employee_id = db.Column(db.String(50), unique=True)
    phone = db.Column(db.String(20))
    permissions = db.Column(db.Text, default=json.dumps({
        "doctors": {"create": True, "read": True, "update": True, "delete": True},
        "patients": {"create": True, "read": True, "update": True, "delete": True},
        "medical_institutions": {"create": True, "read": True, "update": True, "delete": True}
    }))
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship to User
    user = db.relationship('User', backref=db.backref('admin_cms_profile', uselist=False))

    def get_full_name(self):
        return f"{self.first_name} {self.last_name}"

    def get_permissions(self):
        return json.loads(self.permissions) if self.permissions else {}

    def has_permission(self, resource, action):
        perms = self.get_permissions()
        return perms.get(resource, {}).get(action, False)

    def __repr__(self):
        return f'<AdminCMS {self.email}>'


class EditorCMS(db.Model):
    __tablename__ = 'editor_cms'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.Integer, db.ForeignKey('cms_users.id'), unique=True, nullable=False)
    email = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(100), nullable=False)
    last_name = db.Column(db.String(100), nullable=False)
    department = db.Column(db.String(100))
    employee_id = db.Column(db.String(50), unique=True)
    phone = db.Column(db.String(20))
    permissions = db.Column(db.Text, default=json.dumps({
        "doctors": {"create": False, "read": True, "update": True, "delete": False},
        "patients": {"create": False, "read": True, "update": True, "delete": False},
        "medical_institutions": {"create": False, "read": True, "update": True, "delete": False}
    }))
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    last_login = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship to User
    user = db.relationship('User', backref=db.backref('editor_cms_profile', uselist=False))

    def get_full_name(self):
        return f"{self.first_name} {self.last_name}"

    def get_permissions(self):
        return json.loads(self.permissions) if self.permissions else {}

    def has_permission(self, resource, action):
        perms = self.get_permissions()
        return perms.get(resource, {}).get(action, False)

    def __repr__(self):
        return f'<EditorCMS {self.email}>'