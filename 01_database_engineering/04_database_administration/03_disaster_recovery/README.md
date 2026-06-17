# 📁 03 - Disaster Recovery

This module contains the security routines for protection and recovery of the `hbo_db` database.

## 📜 Script Structure

### 1. `001_backup_restore.sql`

This script performs the complete contingency cycle:

* **Backup:** Generates a full database copy (`hbo_db.bak`) with `CHECKSUM` verification.
* **Disaster Simulation:** Forcefully drops the database after ensuring the backup has been generated.
* **Restore:** Executes an immediate *restore* to validate data integrity and system availability.

> ⚠️ **Critical Warning:** This script includes a `DROP DATABASE` command. **Never execute this file in a production environment or where there is data that has not been extracted to a secure location.**

### 2. `002_verify_backup.sql`

Used to validate the backup file before any restoration operation:

* **`RESTORE VERIFYONLY`:** Ensures that the backup file is not corrupted and that SQL Server can read it.
* **`RESTORE HEADERONLY`:** Displays backup metadata (creation date, database name, etc.) for auditing purposes.

---

## 🚀 Operation Guide (Multiplatform Docker)

To maintain redundancy external to the container (Host):

1. **Generation and Extraction:**
After running the backup inside the container, extract the file to your physical machine to ensure that, should the container be destroyed, you do not lose your data:

```bash
# Example for Linux/Mac or PowerShell (adjust the destination path accordingly)
docker cp <container_name>:/var/opt/mssql/backup/hbo_db.bak ~/YourBackupDirectory/

```

2. **Routine Validation:**
It is recommended to run the `002_verify_backup.sql` script weekly to ensure that the backup is intact and readable.