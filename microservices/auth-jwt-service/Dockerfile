# /microservices\auth-jwt-service\Dockerfile
# /microservices/auth-jwt-service/Dockerfile

FROM python:3.11-slim

# Optimización de Python en runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Directorio de trabajo
WORKDIR /app

# Instalar deps de compilación temporalmente, instalar dependencias Python y limpiar
COPY microservices/auth-jwt-service/requirements.txt .
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev curl && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove gcc && \
    rm -rf /var/lib/apt/lists/*

# Copiar código de la aplicación
COPY microservices/shared/ ./shared/
COPY microservices/auth-jwt-service/app/ ./app/

# Añadir shared al PYTHONPATH
ENV PYTHONPATH "${PYTHONPATH}:/app/shared"

# Crear usuario no root y ajustar permisos
RUN useradd -u 1000 -m appuser && chown -R appuser:appuser /app
USER appuser

# Exponer puerto del servicio
EXPOSE 8003

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8003/health || exit 1

# Comando de inicio
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8003"]
