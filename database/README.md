# PredictHealth Database

Database infrastructure and configuration for the PredictHealth health platform. Manages PostgreSQL for persistent data storage and Redis for caching and session management.

## Overview

The PredictHealth database system supports a microservices architecture for a health platform. It provides centralized data storage for user authentication, medical institutions, doctors, patients, health profiles, and administrative functions.

## Architecture

### PostgreSQL 15
- **Purpose**: Primary relational database for all persistent data
- **Schema**: Third Normal Form (3NF) normalized schema supporting multiple user types and health domain entities
- **Initialization**: Automatic schema creation via `init.sql` on container startup
- **Extensions**: `uuid-ossp` (UUID generation), `pgcrypto` (cryptographic functions)

### Redis
- **Purpose**: In-memory data store for cache, sessions, and temporary data
- **Configuration**: Custom configuration with persistence and memory management
- **Memory Limit**: 1GB with LRU eviction policy
- **Persistence**: AOF (Append-Only File) enabled with `everysec` fsync

## Database Schema

### Core Health Tables

- **users**: Centralized authentication table for all user types (patients, doctors, institutions)
- **medical_institutions**: Health institutions (clinics, hospitals, insurers, etc.)
- **doctor_specialties**: Medical specialty definitions with categories
- **doctors**: Healthcare provider profiles with specialties and institutions
- **patients**: Patient information with validation workflow
- **health_profiles**: Complete health information (1:1 with patients)

### Normalized Contact Information

- **emails**: Normalized email addresses with verification tracking
- **phones**: Normalized phone numbers with country/area codes
- **addresses**: Normalized addresses with geolocation support
- **countries**: Country catalog with ISO codes
- **regions**: Hierarchical region/state catalog

### Catalog Tables

- **institution_types**: Institution type definitions
- **specialty_categories**: Specialty category hierarchy
- **sexes**: Biological sex catalog (for medical records)
- **genders**: Gender identity catalog (inclusive)
- **blood_types**: Blood type catalog with compatibility matrices
- **email_types**: Email type classifications
- **phone_types**: Phone type classifications

### Medical Data Tables

- **medical_conditions**: Medical condition catalog
- **medications**: Medication catalog
- **patient_conditions**: Patient-diagnosed conditions (many-to-many)
- **patient_medications**: Patient medications (many-to-many)
- **patient_allergies**: Patient allergies (many-to-many)

### CMS Tables

- **cms_users**: CMS user accounts (admin/editor roles)
- **cms_roles**: Role definitions (Admin, Editor)
- **cms_permissions**: Granular permissions (resource-action pairs)
- **cms_role_permissions**: Junction table for role-permission assignments
- **system_settings**: Dynamic system configuration

### Key Relationships

```
users (1) ──── (1) domain entities (patients/doctors/institutions)
    │
    └── user_type determines reference_id target

patients (N) ──── (1) doctors
patients (N) ──── (1) medical_institutions
patients (1) ──── (1) health_profiles
doctors (N) ──── (1) medical_institutions
doctors (N) ──── (1) doctor_specialties
```

- Patients must be associated with both a doctor AND institution (enforced constraint)
- Doctors must be linked to an institution (enforced constraint)
- Health profiles are 1:1 with patients (unique constraint)
- CMS users have role-based permissions through normalized junction tables

## Database Features

### Stored Procedures

- **`sp_create_patient_with_profile`**: Atomic patient registration with health profile creation
- **`sp_get_patient_stats_by_month`**: KPI reports for patient metrics and analysis
- **`sp_get_doctor_performance_stats`**: Doctor performance metrics and patient care statistics
- **`sp_get_institution_analytics`**: Institution-level analysis and statistics

### Database Views

Pre-optimized views for dashboards and reports:

- **`vw_patient_demographics`**: Patient demographic data with doctor/institution associations
- **`vw_doctor_performance`**: Doctor performance metrics and patient counts
- **`vw_monthly_registrations`**: Monthly registration analysis
- **`vw_health_condition_stats`**: Population health statistics and prevalence
- **`vw_dashboard_overview`**: General system summary metrics
- **`vw_doctor_specialty_distribution`**: Specialty distribution analysis
- **`vw_geographic_distribution`**: Geographic distribution of health entities
- **`vw_health_condition_prevalence`**: Health condition prevalence statistics
- **`vw_patient_validation_status`**: Patient validation workflow status

### Performance Optimization

#### Strategic Indexing
- Partial indexes on active records for frequently queried tables
- Composite indexes for complex join operations
- Foreign key indexes for referential integrity performance
- Specialized indexes for health condition filtering

#### Memory Management
- Redis LRU policy with 1GB memory limit
- Automatic snapshot persistence
- Optimized query plans through strategic indexing

### Data Integrity Constraints

#### Business Logic Constraints
- Patient association validation (must have both doctor AND institution)
- Emergency contact consistency validation
- Smoking/alcohol consumption logic validation
- Age and format validation constraints

#### Referential Integrity
- Soft foreign keys for flexible associations
- Cascade operations for dependent data
- Unique constraints on critical business fields

### Automated Triggers

Timestamp management triggers automatically update `updated_at` fields on all relevant tables, ensuring data consistency without application intervention.

## Configuration

### Docker Compose

PostgreSQL and Redis services are defined in the root `docker-compose.yml`:

```yaml
postgres:
  build: database/postgresql/Dockerfile
  environment:
    POSTGRES_DB: predicthealth_db
    POSTGRES_USER: predictHealth_user
    POSTGRES_PASSWORD: password
  ports: ["5432:5432"]
  volumes: [postgres_data:/var/lib/postgresql/data]

redis:
  build: database/redis/Dockerfile
  ports: ["6379:6379"]
  volumes: [redis_data:/data]
```

### Environment Variables

- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `POSTGRES_DB`: Database name (default: `predicthealth_db`)
- `POSTGRES_USER`: Database user (default: `predictHealth_user`)
- `POSTGRES_PASSWORD`: Database password

### Redis Configuration

Located in `database/redis/redis.conf`:

- Port: 6379
- Max memory: 1GB
- Eviction policy: `allkeys-lru`
- Persistence: AOF enabled with `everysec` fsync
- Save points: 900s (1 change), 300s (10 changes), 60s (10000 changes)

### Dependencies

`requirements.txt`:
- `psycopg2-binary>=2.9.0`: PostgreSQL adapter for Python
- `python-dotenv>=0.19.0`: Environment variable management

## Operations

### Initialization Process

1. **Container Startup**: PostgreSQL 15 container initializes with custom configuration
2. **Schema Creation**: `init.sql` executes automatically, creating:
   - Database extensions (uuid-ossp, pgcrypto)
   - Fully normalized 3NF schema with all tables and relationships
   - Complete constraints and business logic validation
   - Strategic indexes for query performance optimization
   - Automated triggers for timestamp management
   - Stored procedures for complex operations
   - Database views for reports and analysis
   - Seed data (doctor specialties, CMS roles/permissions, test users)
3. **Redis Configuration**: Alpine-based Redis container with custom configuration for persistence and memory management

### Data Flow Architecture

1. **Authentication Layer**: Centralized `users` table handles authentication for all user types
2. **Domain Services**: Specialized microservices manage their respective domain data through normalized tables
3. **Cache Layer**: Redis provides high-performance cache for sessions, temporary data, and frequently accessed information
4. **CMS Administration**: Role-based access control through `cms_users`, `cms_roles`, and `cms_permissions` tables
5. **Analysis and Reports**: Pre-computed views and stored procedures provide real-time insights and KPIs

### Microservice Integration

The database serves the following microservices with optimized data access patterns:

- **auth-jwt-service**: JWT token management and centralized authentication via `users` table
- **service-patients**: Patient lifecycle management with health profiles and validation workflows
- **service-doctors**: Doctor profiles, specialties, and performance analysis
- **service-institutions**: Medical institution management and geographic analysis
- **cms-backend**: Administrative functions with role-based permissions and system configuration

Each microservice maintains optimized connections to both PostgreSQL (persistent data) and Redis (cache/sessions).

## Maintenance

### Backups

- Configured for 30-day retention via environment variables
- Automated backup scripts leverage native PostgreSQL backup capabilities
- Redis persistence ensures session data durability

### Monitoring and Analysis

- **Real-Time Dashboards**: Pre-computed views provide instant access to KPIs
- **User Activity Tracking**: Failed login attempts and authentication events logged in `users` table
- **Health Analysis**: Complete patient health statistics through optimized views
- **Performance Metrics**: Stored procedures deliver doctor and institution performance data
- **Geographic Insights**: Regional distribution analysis for health planning

### Performance Optimization

- **Strategic Indexing**: Partial and composite indexes optimize query performance
- **Memory Management**: Redis LRU policy with 1GB limit prevents memory exhaustion
- **Query Optimization**: Views and stored procedures reduce application-side processing
- **Connection Pooling**: Efficient database connection management across microservices

## Development Setup

1. Ensure Docker and Docker Compose are installed
2. Database containers are orchestrated via project root `docker-compose.yml`
3. Environment variables in `.env` are loaded automatically
4. Python scripts in this directory can be used for migrations and maintenance

### Accessing the Database

**PostgreSQL**:
```bash
# From host (if psql installed)
psql -h localhost -p 5432 -U predictHealth_user -d predicthealth_db

# From container
docker exec -it predicthealth-postgres psql -U predictHealth_user -d predicthealth_db
```

**Redis**:
```bash
# From host (if redis-cli installed)
redis-cli -h localhost -p 6379

# From container
docker exec -it predicthealth-redis redis-cli
```

## Security Considerations

### Authentication and Authorization
- **Password Security**: bcrypt hashing for all user passwords
- **Role-Based Access Control**: Granular permissions through CMS roles and permissions system
- **Account Protection**: Failed login attempt tracking with configurable lockout policies
- **Session Management**: Redis-based session handling with automatic expiration

### Data Protection
- **Input Validation**: Complete constraints prevent invalid data entry
- **Business Logic Security**: Database-level validation ensures data integrity
- **Emergency Contact Validation**: Consistent emergency contact information validation
- **Age and Format Constraints**: Database constraints apply realistic data ranges

### Infrastructure Security
- **Container Networks**: Redis configured for secure inter-container communication
- **Access Control**: Database access patterns specific per microservice
- **Data Consistency**: Transactional operations prevent partial data updates
- **Audit Logging**: User activity tracking through authentication logs

### Compliance Features
- **Health Data Standards**: Structured storage for medical information
- **Patient Privacy**: Validation workflows ensure authorized access to data
- **Regulatory Compliance**: Architecture prepared for audits for health regulations
