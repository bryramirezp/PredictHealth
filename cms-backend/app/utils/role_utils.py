from functools import wraps
from flask import session, flash, redirect, url_for
from flask_login import current_user

def role_required(required_role):
    """
    Decorator to check if user has the required role.

    Args:
        required_role (str): The required role ('admin', 'editor', etc.)

    Returns:
        Function decorator
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                flash('Please log in to access this page.', 'warning')
                return redirect(url_for('auth.login'))

            user_role = session.get('user_role')
            if not user_role:
                flash('Your session has expired. Please log in again.', 'warning')
                return redirect(url_for('auth.login'))

            if user_role != required_role:
                flash(f'Access denied. {required_role.title()} role required.', 'danger')
                return redirect(url_for('dashboard.index'))

            return f(*args, **kwargs)
        return decorated_function
    return decorator

def admin_required(f):
    """Decorator for admin-only access"""
    return role_required('admin')(f)

def editor_required(f):
    """Decorator for editor-only access"""
    return role_required('editor')(f)

def get_current_user_role():
    """Get the current user's role from session"""
    return session.get('user_role')

def get_current_user_role_display():
    """Get the current user's role display name"""
    return session.get('role_display', 'User')

def has_permission(resource, action):
    """
    Check if current user has permission for a specific resource and action.

    Args:
        resource (str): The resource ('doctors', 'patients', 'medical_institutions')
        action (str): The action ('create', 'read', 'update', 'delete')

    Returns:
        bool: True if user has permission, False otherwise
    """
    if not current_user.is_authenticated:
        return False

    user_role = get_current_user_role()

    # Admin has all permissions
    if user_role == 'admin':
        return True

    # Editor has limited permissions
    if user_role == 'editor':
        editor_permissions = {
            'doctors': {'read': True, 'update': True},
            'patients': {'read': True, 'update': True},
            'medical_institutions': {'read': True, 'update': True}
        }
        return editor_permissions.get(resource, {}).get(action, False)

    return False