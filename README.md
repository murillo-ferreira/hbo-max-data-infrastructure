# 🎬 HBO Max - Data Engineering & SQL Database Infrastructure

<p align="left">
  <a href="README.pt-br.md">🌐 Ver em Português</a>
</p>

[![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/en-us/sql-server/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)
[![Kaggle](https://img.shields.io/badge/Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)](https://www.kaggle.com/)

Data modeling, ingestion pipeline, and administration of a relational database system based on the **HBO Max** streaming platform. This project simulates an enterprise-level production environment, covering everything from strict DDL schema enforcement to advanced query optimization, index physical defragmentation, and disaster recovery strategies.

---

## 🧭 Project Architecture & Directory Structure

The repository follows a strict, numbered sequential deployment pipeline to ensure database evolution predictability, precisely mapped to match infrastructure modules:

```text
hbo-max-data-infrastructure/
├── 01_database_engineering/
│   ├── 01_ddl_structure/             # Schema architecture and explicit constraints
│   ├── 02_stored_procedures/         # Encapsulated data ingestion and error handling logic
│   ├── 03_dml_initial_load/          # Static catalogs and data seed deployment context
│   ├── 04_analytical_views/          # Business intelligence and analytical KPI views
│   ├── 05_database_security/         # Least privilege access and RBAC setup
│   ├── 06_backup_recovery/           # Disaster recovery and Docker-isolated backup routines
│   └── 07_performance_tuning/         # Index defragmentation and statistics optimization
├── 02_data_pipeline_python/          # Automated data generation and ingestion
└── 03_analytics_dashboard/           # Power BI semantic model and data visualization

```

---

## 🗂️ Data Modeling & Constraints Enforcement

The relational schema decouples core catalog data from billing, users, and tracking domain boundaries. All constraints are explicitly named to avoid server-generated dynamic identifiers, ensuring maintainability:

* `dbo.titles`: Content catalog schema containing movie and show metadata. Primary key enforced via `PK_titles`.
* `dbo.plans`: Product portfolio management and pricing architecture. Product values are strictly structured using the **BRL (R$)** currency format to map regional operation costs. Primary key enforced via `PK_plans_id`.
* `dbo.users`: Client authentication data and credentials. Regulated by `PK_users_id` and unique business rules.
* `dbo.subscriptions`: Fact table tracking contractual binding, user subscription logs, and Churn metrics. Hard-linked via `FK_subscriptions_users` and `FK_subscriptions_plans`.
* `dbo.watch_history`: User engagement log designed for analytic processing and recommendation engines. Hard-linked via `FK_watch_history_users` and `FK_watch_history_titles`.

> 💾 **Data Source & Seeding:** The core media metadata leverages the public dataset [HBO Max TV Shows and Movies (Victor Soeiro - Kaggle)](https://www.kaggle.com/datasets/victorsoeiro/hbo-max-tv-shows-and-movies). The raw source is processed and mapped to fit SQL server micro-datatypes (e.g., `SMALLINT` for years, `TINYINT` for durations/seasons) to minimize memory footprint. Initial system parameters, corporate pricing rules, and dimension lookups are provisioned via predictable static data seeds located inside `03_dml_initial_load/`.

---

## ⚡ Programmability & Robust Error Handling

The application layer (Python ingestion engines) does not dispatch bare, unsecured query strings directly to the storage structures. Instead, database interactions are strictly intermediated by high-performance **Stored Procedures** inside `02_stored_procedures/`, ensuring transaction safety, isolation, and robust exception interception:

### 1. Idempotent Ingestion Operations

* **`dbo.sp_UpsertTitles`:** Built to handle incremental, live API streams. Leverages the `MERGE` statement guarded by transactional `WITH (HOLDLOCK)` hints to evaluate catalogs dynamically, performing high-speed updates on volatile data (such as IMDb metrics) or executing clean inserts for newly launched media files without duplicate-key collisions.

### 2. Transaction Resilience for Mass Simulations

* **`dbo.sp_UpsertUsers` & `dbo.sp_UpsertSubscriptions`:** Tailored to back Python-driven automation engines (e.g., Faker libraries). They ensure that business mutations remain highly coherent without breaking bulk-load workflows due to individual format anomalies.
* **Fault-Tolerant Loops (`dbo.sp_InsertWatchHistory`):** Uses an isolated `BEGIN TRY...BEGIN CATCH` architecture monitored by the `XACT_STATE()` diagnostic function. If a mock-generator engine attempts to bind an active process to an invalid key pair (violating a Foreign Key boundary), the procedure gracefully captures the exception, fires an internal atomic `ROLLBACK TRANSACTION` to purge the corrupted line, and translates the error into a diagnostic message via `PRINT`. This mechanism prevents the server from returning unhandled critical failures, keeping the automated Python pipeline uninterrupted during mass telemetry workloads.

---

## 📊 Analytical Views & Business Intelligence

Database views inside `04_analytical_views/` are engineered with SARGable arguments, avoiding full-table scans and utilizing index coverage:

### Catalog & Engagement Performance

* `001_top_10_imdb_titles.sql`: Identifies top-tier content by applying a threshold filter to mitigate low-volume voting bias (`imdb_votes > 1000`).
* `002_genre_coexistence.sql`: Parses semi-structured array data from the source to isolate specific niches and genre correlation.
* `003_content_performance_insights.sql` & `005_average_duration_by_type.sql`: Comparative metric analysis evaluating movies vs. series runtime behavior and score distributions to guide original production investment.
* `004_release_volume_by_year.sql`: Tracks yearly historical catalog expansion.

### Retention & Financial Health

* `006_user_history_report.sql`: Consolidates user streaming history with complex string sanitization routines.
* `007_revenue_by_plan.sql`: Measures total accumulated gross revenue split by product type.
* `008_subscriptions_status.sql`: Monitors Active vs. Canceled customer volume to compute the platform's Evasion/Churn Rate.

---

## 🛠️ Database Administration (DBA) & Infrastructure

The core database engine reliability rests on infrastructure automation scripts:

### 1. Index Fragmentation Maintenance (`07_performance_tuning/`)

* **Diagnostics:** Evaluates physical page allocation degradation using the `sys.dm_db_index_physical_stats` Dynamic Management View (DMV).
* **Mitigation:** Automates policy-driven remediation: Executes `ALTER INDEX ... REORGANIZE` for moderate fragmentation (5% to 30%) with zero downtime, and triggers `ALTER INDEX ... REBUILD` for severe fragmentation (> 30%) to compress and redistribute data pages from scratch.

### 2. Optimizer Cost Balancing (`07_performance_tuning/`)

* **Audit:** Scans metadata flags via `sys.stats` combined with the `STATS_DATE()` function to monitor optimizer statistics freshness.
* **Execution:** Fires `UPDATE STATISTICS ... WITH FULLSCAN` routines to recalculate data distribution histograms, ensuring the Query Optimizer generates fast execution plans and avoids CPU-intensive scans.

### 3. Role-Based Access Control (`05_database_security/`)

* **Least Privilege:** Completely isolates database manipulation by creating dedicated, low-privilege application logins.
* **Granular Grants:** Restricts pipeline service accounts (e.g., Pandas integration context) strictly to explicit Stored Procedure execution privileges (`GRANT EXECUTE`), blinding security layers and blocking background access to the underlying table architecture.

### 4. Disaster Recovery & Resilience (`06_backup_recovery/`)

* **Docker-Targeted Storage:** Backs up the entire environment into a compressed `.bak` file (`backup_portfolio.bak`) inside the isolated Linux filesystem of the SQL Server Docker container.
* **Disaster Simulation:** Scripted simulation that cuts active processes using `SINGLE_USER WITH ROLLBACK IMMEDIATE`, purges the database with `DROP DATABASE`, and verifies data integrity by executing an instantaneous recovery through `RESTORE DATABASE ... WITH REPLACE`.

---

### ⚙️ Deployment & Execution Guide

1. **Spin up the infrastructure:** Ensure your local Docker container engine is running SQL Server.
2. **Generate the Database Schema:** Execute the scripts inside `01_ddl_structure/` in chronological order to build `hbo_db` and its constraints.
3. **Catalog Ingestion:** Import the `titles.csv` file into the `dbo.titles` table using the **SQL Server Import Wizard** (standard manual procedure in effect until Release 3.0.0).
4. **Compile Database Programmability:** Deploy all functional assets under `02_stored_procedures/` to establish transaction handling boundaries.
5. **Data Seeding:** Execute the scripts located in `03_dml_initial_load/` to populate the auxiliary tables.
6. **Run Maintenance & Analytics:** Deploy the analytical views and run the optimization and security control files as needed for validation.

> ⚠️ **Evolution Note:** The ingestion via *Import Wizard* is scheduled to be deprecated in Release 3.0.0, where it will be replaced by an automated Python/Pandas pipeline, ensuring better reproducibility and integrated error handling.