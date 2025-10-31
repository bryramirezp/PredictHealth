from flask import Blueprint, render_template, redirect, url_for, flash, request, session
from flask_login import login_user, logout_user, login_required, current_user
from app.models import User, AdminCMS, EditorCMS, db

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    # Redirect if already logged in
    if current_user.is_authenticated:
        return redirect(url_for('dashboard.index'))

    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        remember = request.form.get('remember', False)

        if not email or not password:
            flash('Please provide both email and password.', 'danger')
            return render_template('auth/login.html')

        # Only authenticate CMS users (admin/editor) from cms_users table
        user = User.query.filter_by(email=email).first()

        if user and user.check_password(password):
            # Determine user role by checking user_type field
            if user.user_type == 'admin':
                session['user_role'] = 'admin'
                session['role_display'] = 'Administrator'
            elif user.user_type == 'editor':
                session['user_role'] = 'editor'
                session['role_display'] = 'Editor'
            else:
                session['user_role'] = 'user'
                session['role_display'] = 'User'

            login_user(user, remember=remember)
            flash(f'Welcome back, {user.get_full_name()}! You are logged in as {session["role_display"]}.', 'success')

            # Redirect to next page or dashboard
            next_page = request.args.get('next')
            if next_page:
                return redirect(next_page)
            return redirect(url_for('dashboard.index'))
        else:
            flash('Invalid email or password.', 'danger')

    return render_template('auth/login.html')

@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    session.clear()
    flash('You have been logged out successfully.', 'info')
    return redirect(url_for('auth.login'))