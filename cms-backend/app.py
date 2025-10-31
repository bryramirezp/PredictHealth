#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PredictHealth CMS - Content Management System
Main application entry point
"""

import os
import sys

# Ensure UTF-8 encoding for stdout/stderr
if sys.version_info[0] >= 3:
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

from app import create_app

app = create_app(os.getenv('FLASK_ENV') or 'development')

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5001)),
        debug=app.config['DEBUG']
    )