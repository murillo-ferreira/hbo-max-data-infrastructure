# 🎬 HBO Max - Data Engineering & SQL Database Infrastructure

Data modeling, transaction ingestion pipeline, and administration of a relational database system based on the **HBO Max** streaming platform. This project simulates an enterprise-level production environment, covering everything from strict DDL schema enforcement and SCD Type 2 history tracking to transactional Stored Procedures, automated Python behavior simulations, and DBA maintenance.

---

## 🧭 Project Architecture & Directory Structure

The repository follows a strict, modular directory layout mapping database architecture, ingestion workflows, and administrative tasks:

```text
hbo-max-data-infrastructure/
├── 01_database_engineering/          # Database schemas, procedures, DBA & setup
│   ├── 01_ddl_structure/             # Core table definitions (users, subscriptions, titles, etc.)
│   ├── 02_stored_procedures/         # Transactional logic (sp_CloseSubscription, insert flows)
│   ├── 03_analytical_views/          # SQL views (.gitkeep - placeholder for Release 4.0.0)
│   ├── 04_database_administration/   # Infrastructure & DBA tools
│   │   ├── 01_security/              # Security roles, permissions, logins, and audit setups
│   │   ├── 02_maintenance/           # RCSI setup, maintenance log DDL, and maintenance procedures
│   │   │   └── procedures/           # Automated DBA procedures (sp_RunMaintenance, sp_DBHealthCheck)
│   │   └── 03_disaster_recovery/     # Backup & Restore scripts
│   └── 06_inital_setup/              # Initial SQL seeds (001_load_plans.sql, legacy data_seed catalog)
├── 02_data_pipeline_python/          # Ingestion engine & synthetic generation pipeline
│   ├── config/                       # Engine setup & DB credentials (database.py)
│   ├── generators/                   # Event generators (users.py, subscriptions.py, watch_history.py)
│   ├── lib/                          # Pipeline modules (api_client.py, logger.py, transform.py)
│   ├── scripts/                      # Load execution scripts (load.py)
│   ├── sql/tables/                   # Pipeline infrastructure DDL (dbo.pipeline_logs.sql)
│   └── main.py                       # Pipeline orchestration entry point
├── requirements.txt                  # Python dependencies
├── README.md                         # Main documentation (English)
└── README.pt-br.md                   # Documentation in Portuguese

```

> ℹ️ **Note on `03_analytical_views/`:** This directory currently contains a `.gitkeep` placeholder. Analytical views and Power BI semantic models will be deployed in the upcoming release alongside the dashboard integration.

---

## 🚀 Release 3.0.0 Overview: User Lifecycle & Pipeline Engine

Release **3.0.0** introduces a dynamic data generation and ingestion ecosystem. Instead of static mock data, the system models real-world user behavior (signups, plan upgrades/downgrades, churn, and video engagement) while preserving temporal, financial, and relational integrity.

### 1. Relational History & Transactional Rigor (SQL Server / OLTP)

* **Slowly Changing Dimensions (SCD Type 2):** Implemented on `dbo.subscriptions` using `begin_date` and `end_date` tracking. This design enables point-in-time state reconstruction to determine exact plan coverage at any given historical date.
* **Atomic Stored Procedures (`02_stored_procedures/`):** Transactional procedures (such as `sp_CloseSubscription` and load procedures) encapsulated in `BEGIN TRANSACTION ... COMMIT TRANSACTION` blocks.
* **Defensive Exception Handling:** Integrated `TRY...CATCH` blocks evaluating `XACT_STATE()` for clean rollbacks, raising explicit contextual errors via `THROW` to prevent partial or corrupted database states.

### 2. Pipeline Architecture & Modular Automation (`02_data_pipeline_python/`)

The Python ETL ecosystem is decoupled into specialized execution layers:

* **Orchestration (`main.py`):** Central entry point executing the full pipeline sequence (catalog setup, user seeding, contract modifications, and watch log ingestion).
* **Domain Generators (`generators/`):**
* `users.py`: Generates user profiles with localized `Faker` instances and domain-aligned credentials.
* `subscriptions.py`: Handles multi-phase contract lifecycle, enforcing a mandatory **30-day minimum retention period** before upgrade/churn events.
* `watch_history.py`: Simulates session engagement, device distribution, watch duration, and completion rates ($\ge 90\%$ threshold).


* **Core Libraries (`lib/`):**
* `api_client.py`: Fetches real movie/show metadata from external sources (TMDB) to populate `dbo.titles`.
* `transform.py`: Performs explicit type casting (`datetime` to `date`), duration validations, and business rule sanitization.
* `logger.py`: Centralized logger streaming execution statuses and error traces into `dbo.pipeline_logs`.


* **Database Connection (`config/database.py`):** Configures SQLAlchemy and `pyodbc` connection pools.

---

## 🗂️ Core Schema Architecture

* `dbo.titles`: Content catalog storing movie and series metadata, genres, and runtimes.
* `dbo.plans`: Product tier portfolio and pricing strategy (`Basic with Ads`, `Standard`, `Premium`).
* `dbo.users`: User authentication profiles and account metadata.
* `dbo.subscriptions`: Fact/Dimension table enforcing **SCD Type 2** contract state tracking and churn metrics.
* `dbo.watch_history`: High-volume engagement fact log tracking user sessions, device types, duration, and completion (`completed BIT`).
* `dbo.pipeline_logs`: Pipeline execution audit trail storing execution timestamps, status, affected row counts, and exceptions.

---

## 🛠️ Database Administration (DBA) & Infrastructure

* **Security & Auditing (`04_database_administration/01_security/`):** Complete RBAC implementation including application roles (`001_create_roles.sql`), explicit permissions (`002_grant_permissions.sql`), dedicated database logins (`003_create_logins.sql`), and server audit configurations (`004_audit_setup.sql`).
* **Automated Maintenance & Concurrency (`04_database_administration/02_maintenance/`):**
* **RCSI Setup:** `READ_COMMITTED_SNAPSHOT` enabled on `hbo_db` to ensure non-blocking read operations during high-volume ingestion runs.
* **Logging Infrastructure:** Centralized `dbo.maintenance_log` table storing health check metrics and index operation results.
* **Proactive Procedures (`procedures/`):** Houses `sp_RunMaintenance` for index defragmentation (`REORGANIZE` at 5–30%, `REBUILD` at >30%, and `UPDATE STATISTICS ... WITH FULLSCAN`) alongside `sp_DBHealthCheck` for system telemetry monitoring.


* **Disaster Recovery (`03_disaster_recovery/`):** Container-ready backup procedures verified via `RESTORE VERIFYONLY` and `RESTORE DATABASE ... WITH REPLACE`.

---

## ⚙️ Deployment & Execution Guide

1. **Environment Setup:**
* Install Python dependencies: `pip install -r requirements.txt`
* Configure environment variables in `02_data_pipeline_python/.env` (your TMDB API Bearer Token).


2. **Deploy SQL Architecture & Security:**
* Run schema DDLs from `01_database_engineering/01_ddl_structure/`.
* Deploy Stored Procedures from `01_database_engineering/02_stored_procedures/`.
* Execute security and audit scripts sequentially from `01_database_engineering/04_database_administration/01_security/`:
1. `001_create_roles.sql`
2. `002_grant_permissions.sql`
3. `003_create_logins.sql`
4. `004_audit_setup.sql`


* Deploy DBA maintenance, RCSI setup, log infrastructure, and administrative procedures from `01_database_engineering/04_database_administration/02_maintenance/`.
* Deploy pipeline logging infrastructure from `02_data_pipeline_python/sql/tables/dbo.pipeline_logs.sql`.
* Execute initial catalog seed from `01_database_engineering/06_inital_setup/001_load_plans.sql`.


3. **Run Pipeline Orchestrator:**
```bash
python 02_data_pipeline_python/main.py

```


4. **Execution Audit:**
* Query `dbo.pipeline_logs` to review execution status, row counts, and audit execution traces for dbo.titles pipeline steps.