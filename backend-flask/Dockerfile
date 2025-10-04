# /backend-flask\Dockerfile
# /backend-flask/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements y instalar dependencias de Python
COPY backend-flask/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación backend
COPY backend-flask/ .

# Copiar el directorio frontend para los templates
COPY frontend/ /app/frontend/

# Crear usuario no root y ajustar permisos
RUN useradd -u 1000 -m appuser && chown -R appuser:appuser /app
USER appuser

# Exponer el puerto
EXPOSE 5000

# Comando para ejecutar la aplicación
CMD ["python", "app.py"]
