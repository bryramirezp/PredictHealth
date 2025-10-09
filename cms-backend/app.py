#!/usr/bin/env python3
"""
PredictHealth CMS - Content Management System
Main application entry point
"""

import os
from app import create_app

app = create_app(os.getenv('FLASK_ENV') or 'development')

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5001)),
        debug=app.config['DEBUG']
    )