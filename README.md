# 🎬 HBO Max - Data Engineering & SQL Database Infrastructure

Data modeling, ingestion pipeline, and administration of a relational database system based on the **HBO Max** streaming platform. This project simulates an enterprise-level production environment, covering everything from strict DDL schema enforcement to advanced query optimization, automated index physical defragmentation, and disaster recovery strategies.

---

## 🧭 Project Architecture & Directory Structure

The repository follows a strict, numbered sequential deployment pipeline to ensure database evolution predictability:

```text
hbo-max-data-infrastructure/
├── 01_database_engineering/          # Schema architecture and stored procedures
├── 04_analytical_views/              # KPI and Business Intelligence views
├── 04_database_administration/       # DBA & Infrastructure
│   ├── 01_security/                  # Roles, RCSI, Auditing
│   ├── 02_maintenance/               # sp_RunMaintenance, sp_DBHealthCheck, maintenance_log
│   └── 03_disaster_recovery/         # Backup/Restore
├── 05_data_quality/                  # Data consistency checks
├── 06_inital_setup/                  # Data seeding and catalogs
├── 02_data_pipeline_python/          # Ingestion pipelines
└── 03_analytics_dashboard/           # Power BI semantic models

```

---

## 🗂️ Data Modeling & Constraints Enforcement

The relational schema decouples core catalog data from billing, users, and tracking domain boundaries. All constraints are explicitly named to avoid server-generated dynamic identifiers, ensuring maintainability:

* `dbo.titles`: Content catalog schema containing movie and show metadata.
* `dbo.plans`: Product portfolio management and pricing architecture.
* `dbo.users`: Client authentication data and credentials.
* `dbo.subscriptions`: Fact table tracking contractual binding and Churn metrics.
* `dbo.watch_history`: User engagement log designed for analytic processing.

> ⚠️ **Status:** This is the **Release 2.0.0** infrastructure. The schema is fully defined and constrained. Data population (seeding) via Python pipelines and analytical dashboarding are scheduled for **Release 3.0.0**.

---

## 🛠️ Database Administration (DBA) & Infrastructure

The core database engine reliability rests on infrastructure automation scripts located in `04_database_administration/`:

### 1. Automated Maintenance (`02_maintenance/`)

Centralized, autonomous procedure architecture:

* **`sp_RunMaintenance`:** Uses Dynamic SQL and Cursors to identify fragmentation in real-time. It automatically executes `ALTER INDEX ... REORGANIZE` (5-30% fragmentation) or `REBUILD` (>30%), and triggers `UPDATE STATISTICS ... WITH FULLSCAN` to keep the Query Optimizer efficient.
* **`sp_DBHealthCheck`:** Proactive monitoring that evaluates `Wait Stats` and I/O latency, logging critical events into `dbo.maintenance_log`.
* **Logging:** Centralized `dbo.maintenance_log` capturing success/error status of all maintenance and health tasks.

### 2. Concurrency & Performance (`01_security/`)

* **RCSI:** `READ_COMMITTED_SNAPSHOT ON` applied to ensure non-blocking read operations, essential for Power BI reporting and high-concurrency ingestion.

### 3. Disaster Recovery (`03_disaster_recovery/`)

* **Docker-Targeted Storage:** Backup routines configured for isolated filesystem environments.
* **Resilience:** Includes automated simulation scripts to verify data integrity via `RESTORE VERIFYONLY` and `RESTORE DATABASE ... WITH REPLACE`.

---

## ⚙️ Deployment & Execution Guide (Release 2.0.0)

1. **Environment:** Ensure SQL Server is running in a Docker container.
2. **Schema Deployment:** Execute scripts in `01_database_engineering/` to build the `hbo_db` structure.
3. **Administration Setup:** Run security configurations (RCSI) and deploy the maintenance procedures in `04_database_administration/`.
4. **Validation:** Use the procedures to verify environment health and prepare for upcoming data ingestion.

> 🚀 **Evolution Note:** Automated data ingestion via Python/Pandas is the primary objective for **Release 3.0.0**, which will enable full analytical capabilities and view consumption.