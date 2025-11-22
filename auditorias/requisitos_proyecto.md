# Proyecto Final - Integración de Aplicaciones Computacionales

## 📋 Entregables Obligatorios

Cada equipo deberá entregar los siguientes componentes en los formatos indicados:

1. **Módulo Back End Content Management System** con CRUD de todas las tablas, reportes y administración de contenidos sin usar microservicios
2. **Módulo de microservicios bilingües** (XML y JSON) protegidos con JWT y Redis
3. **Módulo Front End - Aplicación de Escritorio** consumiendo exclusivamente XML
4. **Módulo Front End - Aplicación Móvil Android** consumiendo exclusivamente JSON
5. **Reportes, indicadores y al menos 6 gráficas** en el CMS, la aplicación de escritorio y la aplicación móvil
6. **Diseño de bases de datos y colecciones NO-SQL**, normalizada hasta 3FN y usando Stored Procedures
7. **Pruebas y análisis de estrés**
8. **Reporte escrito**
9. **Archivos DUMP** de bases de datos o colecciones NO-SQL
10. **Guía de instalación** del proyecto
11. **Video demostrativo** sin límite de tiempo, montado en YouTube
12. **Presentación**

---

## 🎯 Actividades Generales

Todos los proyectos deben tener los siguientes módulos débilmente acoplados:

- Módulo Back End CMS (Content Management System) con CRUD de todas las tablas, reportes y administración de contenidos sin usar microservicios
- Módulo de microservicios bilingües (XML y JSON) protegidos con JWT y Redis
- Módulo Front End con una aplicación para escritorio consumiendo exclusivamente XML
- Módulo Front End con una aplicación móvil para Android consumiendo exclusivamente JSON
- Reportes, indicadores y al menos 6 gráficas en el CMS, la aplicación de escritorio y la aplicación móvil
- Diseño de base de datos normalizada hasta 3FN y usando Stored Procedures
- Pruebas y análisis de estrés

---

## 🔧 Funcionalidades Mínimas por Módulo

### 1. Módulo Back End CMS (Content Management System)

**Tipo:** Aplicación web monolítica (sin microservicios)

**Propósito:** Administrar contenido, usuarios y datos del sistema de forma centralizada.

**Funcionalidades mínimas:**

- **CRUD completo** sobre todas las entidades/tablas de la base de datos (crear, leer, actualizar, eliminar)
- **Interfaz de administración web** con:
  - Gestión de contenidos (artículos, páginas, bloques, etc.)
  - Gestión de usuarios y roles (al menos: administrador, editor)
  - Configuración básica del sistema
- **Autenticación y autorización** por roles (login/logout, control de acceso)
- **Validación de datos** en formularios antes de guardar
- **Conexión directa** a la base de datos (sin intermediarios)
- **Reportes y análisis:**
  - Generación de reportes tabulares con filtros (por fecha, estado, autor, categoría, etc.)
  - Exportación de reportes a PDF o CSV
  - Indicadores clave (KPIs) visibles en el panel:
    - Total de contenidos publicados
    - Contenidos en borrador o pendientes
    - Número de usuarios activos
    - Frecuencia de actualización de contenido
  - **Mínimo 6 gráficas en el dashboard:**
    1. Contenidos publicados por mes (líneas)
    2. Distribución por categoría (pastel)
    3. Estado de contenidos: publicados vs. borradores (barras apiladas)
    4. Actividad por rol de usuario (barras horizontales)
    5. Crecimiento acumulado de contenido (área)
    6. Top 5 autores con más publicaciones (barras verticales)

> **Nota:** Este módulo NO expone APIs REST. Solo es un sistema de administración interna.

---

### 2. Módulo de Microservicios Bilingües (XML y JSON)

**Tipo:** Servicios REST independientes

**Propósito:** Exponer datos del sistema a clientes externos de forma segura, eficiente y en dos formatos.

**Funcionalidades mínimas:**

- **Endpoints REST protegidos** que devuelvan datos en:
  - XML (por defecto o con `Accept: application/xml`)
  - JSON (con `Accept: application/json` o parámetro `?format=json`)
- **Autenticación mediante JWT:**
  - Endpoint `/auth/login` que valide credenciales y emita token
  - Validación del token en cada petición protegida
- **Caché con Redis:**
  - Almacenamiento de respuestas frecuentes (JWT, catálogos, contenidos estáticos, personalización global)
  - Tiempo de vida (TTL) configurable
  - Invalidación automática al modificarse datos críticos (opcional pero recomendado)
- **Acceso directo** a la misma base de datos del CMS (compartida)
- **Endpoints específicos** para reportes y KPIs, por ejemplo:
  - `GET /api/stats/contents-by-month`
  - `GET /api/reports/content-status`
  - `GET /api/kpi/total-items`
  - `GET /api/analytics/top-authors`
- Solo operaciones de **lectura (GET)** si el CMS es el único autorizado a escribir
  - Alternativa: permitir escritura si la app móvil o escritorio deben crear contenido, pero con validación estricta

> **Nota:** Este módulo no gestiona contenido directamente, solo lo expone.

---

### 3. Módulo Front End – Aplicación de Escritorio

**Tipo:** Aplicación nativa o multiplataforma (ej. Web, Java, Python, JavaFX, etc.)

**Propósito:** Consumir y visualizar contenido y análisis en entornos de escritorio.

**Funcionalidades mínimas:**

- **Consumo exclusivo de XML** desde los microservicios (módulo 2)
- **Autenticación inicial:**
  - Login → obtención de JWT → envío en cabeceras `Authorization: Bearer <token>`
- **Visualización de contenido** estructurado (noticias, artículos, páginas, etc.)
- **Reportes y análisis:**
  - Carga de datos agregados para indicadores desde endpoints específicos
  - Visualización de **al menos 6 gráficas:**
    1. Evolución mensual de nuevos contenidos
    2. Porcentaje de contenido por idioma (español/inglés)
    3. Distribución por tipo de contenido
    4. Actividad en los últimos 30 días
    5. Comparativa entre dos periodos (ej. mes actual vs. anterior)
    6. Estado de sincronización o disponibilidad de datos
  - **Indicadores resumen** en el dashboard:
    - Total de registros descargados
    - Última actualización
    - Contenidos sin leer o nuevos
- **Manejo de errores:** token expirado, XML malformado, sin conexión
- (Opcional) Exportación de reportes a PDF o impresión

> **Importante:** No debe soportar JSON. Solo XML.

---

### 4. Módulo Front End – Aplicación Móvil para Android

**Tipo:** Aplicación nativa (Kotlin/Java)

**Propósito:** Acceso móvil a contenido y análisis del sistema.

**Funcionalidades mínimas:**

- **Consumo de microservicios** (módulo 2) en JSON (más eficiente en móviles)
- **Gestión segura de JWT:**
  - Almacenamiento en Android Keystore o SharedPreferences cifrado
  - Renovación automática si el backend lo permite
- **Interfaz nativa** con navegación intuitiva:
  - Listas de contenido
  - Vista de detalle
  - Menú de reportes/analítica
- **Reportes y análisis:**
  - Carga de datos para KPIs y gráficas desde endpoints dedicados
  - Visualización de **al menos 6 gráficas móviles:**
    1. Contenidos más recientes o populares
    2. Distribución por categoría o sección
    3. Actividad semanal/mensual
    4. Comparativa de métricas (este mes vs. anterior)
    5. Estado de caché o sincronización
    6. Indicador de uso o engagement (si se mide)
  - **Indicadores clave visibles:**
    - Total de contenidos disponibles
    - Nuevos contenidos desde la última visita
    - Estado de conexión (online/offline)
- **Soporte básico offline:**
  - Caché local con Room o similar
  - Visualización de datos recientes sin conexión
- **Librería de gráficas** (ej. MPAndroidChart, Compose Charts)

> **Importante:** Las gráficas deben ser responsivas, legibles y actualizables.

---

### 5. Diseño de Base de Datos

**Tipo:** Sistema relacional (ej. PostgreSQL, MySQL, SQL Server) y sistema no relacional (ej. MongoDB, Cassandra, Kafka, etc.)

**Propósito:** Almacenar datos de forma estructurada, segura y eficiente.

**Funcionalidades mínimas:**

- **Modelo normalizado hasta Tercera Forma Normal (3FN):**
  - Eliminación de dependencias transitivas
  - Claves primarias y foráneas definidas
  - Entidades bien separadas (usuarios, contenidos, categorías, idiomas, roles, etc.)
- **Stored Procedures** (procedimientos almacenados) para:
  - Operaciones CRUD complejas
  - Transacciones multi-tabla (ej. publicar contenido + registrar auditoría)
  - Cálculo de KPIs y datos para reportes (ej. `sp_GetContentStatsByMonth`)
- **Vistas (Views)** para simplificar consultas de reportes y gráficas
- **Índices** en columnas usadas en filtros, búsquedas o joins frecuentes
- **Restricciones de integridad:**
  - NOT NULL, UNIQUE, CHECK, FOREIGN KEY
- **Tablas de auditoría** (opcional pero recomendado) para registrar cambios críticos

> **Nota:** Tanto el CMS (módulo 1) como los microservicios (módulo 2) deben interactuar con esta base de datos, preferiblemente usando los Stored Procedures para operaciones de negocio.

---

## 📝 Recomendaciones

1. Leer detenidamente la guía del proyecto asignado
2. Revisar la rúbrica de evaluación en Blackboard
3. Preparar un plan de trabajo con roles y responsabilidades
4. Crear el repositorio GitHub y configurar el despliegue en un archivo README.md
5. Iniciar diseño del diagrama ER, mockups y estructura del código

---

## 🐳 Contenedores y Nube

### Docker
- Utilizar Docker para contenerizar todos los módulos
- Probar despliegue local y en la nube

### Google Cloud Compute Engine
- Subir imágenes Docker al Container Registry
- Configurar instancias para ejecución de microservicios
- Integrar balanceo básico si aplica

---

## 📦 Estructura del Proyecto

```
proyecto-final/
├── backend-cms/
├── microservicios/
├── frontend-desktop/
├── frontend-mobile-android/
├── database/
│   ├── scripts/
│   ├── stored-procedures/
│   └── dumps/
├── docker/
├── docs/
│   ├── reporte.pdf
│   └── guia-instalacion.md
└── README.md
```

---

## 👥 Equipo y Roles

| Rol | Responsable | Tareas |
|-----|-------------|--------|
| Backend CMS | | |
| Microservicios | | |
| Frontend Desktop | | |
| Frontend Mobile | | |
| Base de Datos | | |
| DevOps | | |

---

## 🚀 Instalación y Ejecución

Ver la [Guía de Instalación](docs/guia-instalacion.md) para instrucciones detalladas.

---

## 📹 Video Demostrativo

[Enlace al video en YouTube](#)

---

## 📊 Presentación

[Enlace a la presentación](#)

---

## 📄 Licencia

Este proyecto es parte del curso de Integración de Aplicaciones Computacionales.