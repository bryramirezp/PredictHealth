# Informe de Auditoría Técnica: Arquitectura de Microservicios

## 1. Resumen Ejecutivo

Este informe presenta los resultados de una auditoría técnica de los microservicios de PredictHealth. El análisis revela problemas arquitectónicos críticos que impiden el funcionamiento del sistema como una verdadera arquitectura de microservicios. En lugar de servicios autónomos, el sistema opera como una **aplicación monolítica (`backend-flask`) con servicios satélite redundantes**.

Los hallazgos clave son:
- **Duplicación masiva de código** y lógica de negocio entre el `backend-flask` y los microservicios (`service-patients`, `service-doctors`, etc.).
- **Acoplamiento total a nivel de base de datos**, donde múltiples servicios acceden y modifican las mismas tablas, eliminando la autonomía.
- **Acoplamiento directo entre microservicios** a nivel de código, creando dependencias frágiles.
- **Ausencia de comunicación vía API** entre el `backend-flask` y los microservicios.

Las recomendaciones se centran en unificar la arquitectura, eliminar la redundancia y establecer patrones de comunicación claros para lograr un sistema mantenible, escalable y robusto.

## 2. Hallazgos Clave

### 2.1. Duplicación de Lógica de Negocio y Estructura

Se ha identificado una duplicación sistemática en dos niveles:

**a) Entre Microservicios:**
Los servicios `service-patients`, `service-doctors` y `service-institutions` comparten una estructura de directorios idéntica y replican la lógica para:
- Configuración de la aplicación FastAPI.
- Operaciones CRUD (Crear, Leer, Actualizar, Borrar) en la capa de servicio.
- Mapeo de modelos de SQLAlchemy a esquemas Pydantic.
- Manejo de la conexión a la base de datos.

**b) Entre el `backend-flask` y los Microservicios:**
El `backend-flask` **no actúa como un API Gateway**. En su lugar, contiene su propia implementación completa de la lógica de negocio, accediendo directamente a la base de datos. Por ejemplo, el archivo `backend-flask/app/api/v1/patients.py` define endpoints que realizan las mismas operaciones que el `service-patients`, creando dos puntos de entrada en competencia para gestionar los mismos datos.

### 2.2. Acoplamiento Crítico a Nivel de Base de Datos

Todos los servicios, incluido el `backend-flask`, se conectan a la misma base de datos y acceden a las mismas tablas. Este es el anti-patrón más significativo de la arquitectura actual.

- **`service-patients`** accede a `patients`, `doctors`, `medical_institutions`.
- **`service-doctors`** accede a `doctors`, `medical_institutions`, `doctor_specialties`.
- **`backend-flask`** accede a `patients`, `doctors`, `users`, `health_profiles` y muchas otras.

Este acceso compartido elimina la principal ventaja de los microservicios: la autonomía y la capacidad de evolucionar de forma independiente. Cualquier cambio en el esquema de la base de datos requiere la actualización y el redespliegue de múltiples servicios.

### 2.3. Acoplamiento Directo entre Servicios

Se ha detectado un acoplamiento a nivel de código fuente entre servicios que deberían ser independientes:

- El `service-doctors` importa y utiliza un cliente HTTP (`SyncAuthClient`) que está definido dentro del `service-patients` (`service-patients/app/clients/auth_client.py`).
- Este cliente realiza una **llamada síncrona y bloqueante** desde `service-doctors` al `auth-jwt-service` para crear usuarios. Si el servicio de autenticación falla, la creación de doctores se interrumpe, creando un punto único de fallo.

## 3. Recomendaciones

Se proponen dos caminos estratégicos para resolver estos problemas. La elección depende de los objetivos a largo plazo del proyecto.

### Opción A: Consolidar en una Arquitectura Monolítica (Recomendado a corto plazo)

Dado que el `backend-flask` ya funciona como un monolito, la forma más rápida de estabilizar el sistema es aceptar esta realidad y consolidar la lógica duplicada.

1.  **Eliminar los Microservicios Redundantes:** Desactivar y archivar `service-patients`, `service-doctors` y `service-institutions`.
2.  **Centralizar la Lógica en `backend-flask`:** Migrar cualquier lógica de negocio única de los microservicios al `backend-flask` para que este sea la única fuente de verdad.
3.  **Mantener `auth-jwt-service`:** Conservar el servicio de autenticación como un servicio independiente, ya que la gestión de la identidad es una responsabilidad que se puede aislar correctamente.
4.  **Refactorizar la Comunicación:** Asegurarse de que toda la comunicación con el `auth-jwt-service` se realice a través de un cliente HTTP bien definido dentro del `backend-flask`.

**Ventajas:**
- Reducción drástica de la complejidad y el código duplicado.
- Mantenimiento simplificado y un único punto de despliegue.
- Acepta la realidad actual de la arquitectura y la hace coherente.

### Opción B: Reconstruir hacia una Verdadera Arquitectura de Microservicios (Estratégico a largo plazo)

Si el objetivo es mantener una arquitectura de microservicios, se requiere una refactorización profunda.

1.  **Definir `backend-flask` como un Verdadero API Gateway:** Eliminar toda la lógica de negocio y el acceso a la base de datos del `backend-flask`. Su única responsabilidad debe ser redirigir las solicitudes HTTP al microservicio correspondiente.
2.  **Romper el Acoplamiento de la Base de Datos:** A largo plazo, cada microservicio debería tener su propia base de datos o, como mínimo, su propio esquema con tablas privadas. La comunicación de datos entre servicios debe realizarse exclusivamente a través de APIs.
3.  **Crear una Librería Compartida (`common`):** Para resolver el código duplicado, crear un paquete Python instalable que contenga:
    - Un cliente HTTP base para la comunicación entre servicios.
    - Modelos de datos compartidos (Pydantic).
    - Lógica de base genérica (si es inevitable el acceso compartido a corto plazo).
4.  **Eliminar la Comunicación Síncrona Problemática:** Reemplazar las llamadas síncronas directas (como la de `service-doctors` a `auth-jwt-service`) por patrones de comunicación asíncrona (eventos) o coreografía de procesos gestionada por el API Gateway.

**Ventajas:**
- Sistema escalable y resiliente.
- Autonomía de los equipos y despliegues independientes.
- Alineado con las mejores prácticas de microservicios.

## 4. Diagrama de Arquitectura Propuesta (Opción B)

```
[Cliente (UI)]
      |
      v
[backend-flask (API Gateway)] -- (Redirige llamadas HTTP) --> [service-patients] --> [DB Pacientes]
      |                                                        |
      +-------------------------------------------------------> [service-doctors]  --> [DB Doctores]
      |                                                        |
      +-------------------------------------------------------> [service-institutions] --> [DB Instituciones]
      |                                                        |
      +-------------------------------------------------------> [auth-jwt-service] --> [DB Auth]
      |
      v
[Librería Compartida (`common`)] <-- (Usada por todos los servicios para código común)
```

Este informe debe servir como punto de partida para una discusión sobre la dirección arquitectónica del proyecto. La situación actual es insostenible y requiere una acción decisiva.
