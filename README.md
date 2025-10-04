# PredictHealth Platform

## Overview

PredictHealth is a comprehensive health platform designed with a microservices architecture to manage various aspects of patient care, doctor interactions, institution management, and administrative tasks. It provides a robust and scalable solution for healthcare data management and user interaction.

## Technologies

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

## Architecture Deep Dive

The PredictHealth platform is built upon a microservices architecture, orchestrated using Docker Compose. This design ensures modularity, scalability, and independent deployment of services.

### Frontend

The frontend of the application is composed of static HTML, CSS, and JavaScript files. These files are served directly by the `backend-flask` application, which acts as the main web server for the user interface. The frontend provides various dashboards and forms for patients, doctors, institutions, and administrators.

### Backend (API Gateway)

The `backend-flask` service acts as the central API Gateway for the entire application. It is responsible for:
*   Serving the static frontend files (HTML, CSS, JS).
*   Routing incoming API requests to the appropriate microservices.
*   Handling session management and integrating with the `auth-jwt-service` for authentication.
*   Implementing JWT middleware to protect API endpoints.

### Microservices

The core business logic is distributed across several specialized microservices, each responsible for a specific domain:

*   **`auth-jwt-service`**: This service is dedicated to user authentication and JSON Web Token (JWT) management. It handles user login, token generation, token validation, and token revocation. It interacts with PostgreSQL for user data and Redis for token blacklisting or session management.

*   **`service-admins`**: Manages functionalities related to system administrators, including user management, system configuration, and monitoring.

*   **`service-doctors`**: Provides features specific to doctors, such as managing patient records, viewing patient health data, and making recommendations.

*   **`service-institutions`**: Handles the management of medical institutions, including registering new institutions, managing their doctors and patients, and providing institutional analytics.

*   **`service-patients`**: Focuses on patient-centric functionalities, allowing patients to view their health data, lifestyle information, notifications, and recommendations.

### Database and Caching

*   **PostgreSQL**: Serves as the primary relational database for the entire platform. Each microservice interacts with PostgreSQL to store and retrieve its respective data, ensuring data persistence and integrity.

*   **Redis**: Utilized as an in-memory data store for caching and session management. It enhances application performance by reducing the load on the primary database and provides a fast mechanism for storing temporary data like JWT tokens for revocation.

## Getting Started

To get the PredictHealth platform up and running locally, follow these simple steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/bryramirezp/PredictHealth.git
    cd PredictHealth
    ```

2.  **Build and run the services using Docker Compose:**
    ```bash
    docker-compose up --build
    ```
    This command will build the Docker images for all services (PostgreSQL, Redis, backend-flask, and all microservices) and start them in the correct order, respecting their dependencies.

3.  **Access the application:**
    Once all services are up and healthy, you can access the frontend application by navigating to `http://localhost:5000` in your web browser.

## Project Structure

The project is organized into the following main directories:

*   `backend-flask/`: Contains the Flask API Gateway application and its related configurations, middleware, and API blueprints.
*   `database/`: Holds Dockerfiles and initialization scripts for PostgreSQL and Redis.
*   `frontend/`: Contains all static assets (CSS, JS, images) and HTML templates for the user interface.
*   `microservices/`: Houses the individual microservices, each in its own subdirectory (e.g., `auth-jwt-service`, `service-admins`, `service-doctors`, `service-institutions`, `service-patients`).
*   `docker-compose.yml`: Defines the multi-container Docker application, specifying how all services are configured and linked.
