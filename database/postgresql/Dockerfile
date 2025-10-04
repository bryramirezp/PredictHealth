# /database\postgresql\Dockerfile
FROM postgres:15

# Copiar el archivo de inicialización
COPY database/postgresql/init.sql /docker-entrypoint-initdb.d/init.sql

# Asegurar permisos correctos
RUN chmod 644 /docker-entrypoint-initdb.d/init.sql
