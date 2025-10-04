# Plataforma PredictHealth

## Descripción General

PredictHealth es una plataforma integral de salud diseñada con una arquitectura de microservicios para gestionar diversos aspectos del cuidado del paciente, interacciones con médicos, gestión de instituciones y tareas administrativas. Proporciona una solución robusta y escalable para la gestión de datos de salud y la interacción con usuarios.

## Tecnologías

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

## Análisis Profundo de la Arquitectura

La plataforma PredictHealth está construida sobre una arquitectura de microservicios, orquestada mediante Docker Compose. Este diseño garantiza modularidad, escalabilidad y despliegue independiente de servicios.

### Frontend

El frontend de la aplicación está compuesto por archivos estáticos de HTML, CSS y JavaScript. Estos archivos son servidos directamente por la aplicación `backend-flask`, que actúa como el servidor web principal para la interfaz de usuario. El frontend proporciona varios paneles de control y formularios para pacientes, médicos, instituciones y administradores.

### Backend (API Gateway)

El servicio `backend-flask` actúa como el API Gateway central para toda la aplicación. Es responsable de:
*   Servir los archivos estáticos del frontend (HTML, CSS, JS).
*   Enrutar las solicitudes API entrantes a los microservicios apropiados.
*   Gestionar sesiones e integrarse con el `auth-jwt-service` para la autenticación.
*   Implementar middleware JWT para proteger los endpoints de la API.

### Microservicios

La lógica de negocio central está distribuida entre varios microservicios especializados, cada uno responsable de un dominio específico:

*   **`auth-jwt-service`**: Este servicio está dedicado a la autenticación de usuarios y la gestión de JSON Web Tokens (JWT). Maneja el inicio de sesión de usuarios, generación de tokens, validación de tokens y revocación de tokens. Interactúa con PostgreSQL para datos de usuarios y Redis para la lista negra de tokens o gestión de sesiones.

*   **`service-admins`**: Gestiona funcionalidades relacionadas con los administradores del sistema, incluyendo gestión de usuarios, configuración del sistema y monitoreo.

*   **`service-doctors`**: Proporciona características específicas para médicos, como gestionar registros de pacientes, ver datos de salud de pacientes y hacer recomendaciones.

*   **`service-institutions`**: Maneja la gestión de instituciones médicas, incluyendo el registro de nuevas instituciones, gestión de sus médicos y pacientes, y proporcionar análisis institucionales.

*   **`service-patients`**: Se centra en funcionalidades centradas en el paciente, permitiendo a los pacientes ver sus datos de salud, información de estilo de vida, notificaciones y recomendaciones.

### Base de Datos y Caché

*   **PostgreSQL**: Sirve como la base de datos relacional principal para toda la plataforma. Cada microservicio interactúa con PostgreSQL para almacenar y recuperar sus datos respectivos, asegurando la persistencia e integridad de los datos.

*   **Redis**: Utilizado como un almacén de datos en memoria para caché y gestión de sesiones. Mejora el rendimiento de la aplicación al reducir la carga en la base de datos principal y proporciona un mecanismo rápido para almacenar datos temporales como tokens JWT para revocación.

## Primeros Pasos

Para poner en funcionamiento la plataforma PredictHealth localmente, sigue estos sencillos pasos:

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/bryramirezp/PredictHealth.git
    cd PredictHealth
    ```

2.  **Construir y ejecutar los servicios usando Docker Compose:**
    ```bash
    docker-compose up --build
    ```
    Este comando construirá las imágenes Docker para todos los servicios (PostgreSQL, Redis, backend-flask y todos los microservicios) y los iniciará en el orden correcto, respetando sus dependencias.

3.  **Acceder a la aplicación:**
    Una vez que todos los servicios estén activos y saludables, puedes acceder a la aplicación frontend navegando a `http://localhost:5000` en tu navegador web.

## Estructura del Proyecto

El proyecto está organizado en los siguientes directorios principales:

*   `backend-flask/`: Contiene la aplicación Flask API Gateway y sus configuraciones relacionadas, middleware y blueprints de API.
*   `database/`: Contiene Dockerfiles y scripts de inicialización para PostgreSQL y Redis.
*   `frontend/`: Contiene todos los recursos estáticos (CSS, JS, imágenes) y plantillas HTML para la interfaz de usuario.
*   `microservices/`: Alberga los microservicios individuales, cada uno en su propio subdirectorio (por ejemplo, `auth-jwt-service`, `service-admins`, `service-doctors`, `service-institutions`, `service-patients`).
*   `docker-compose.yml`: Define la aplicación Docker multi-contenedor, especificando cómo se configuran y vinculan todos los servicios.
