# /microservices\service-admins\Dockerfile
FROM python:3.11-slim

# Optimización de Python en runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Directorio de trabajo
WORKDIR /app

# Instalar deps de compilación temporalmente, instalar dependencias Python y limpiar
COPY microservices/service-admins/requirements.txt .
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev curl && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove gcc && \
    rm -rf /var/lib/apt/lists/*

# Copiar código mínimo necesario para producción
COPY microservices/service-admins/app/ ./app/

# Crear directorio para logs y usuario no root
RUN mkdir -p /app/logs && \
    useradd -u 1000 -m appuser && \
    chown -R appuser:appuser /app
USER appuser

# Exponer puerto del servicio
EXPOSE 8006

# Comando de inicio
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8006"]