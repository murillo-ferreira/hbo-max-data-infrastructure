# 📁 06 - Backup & Recovery (Multiplatform Docker)

This module demonstrates the project's data resilience strategy, covering the complete lifecycle of backup generation, security extraction to the physical machine (Host), and post-disaster restoration.

## How to Execute the Lifecycle

### 1. Generate the Internal Backup
Open your SQL editor connected to the container and execute the first part of the script (`BACKUP DATABASE`). This will generate the isolated `.bak` file inside the container's Linux environment at `/var/opt/mssql/data/hbo_db.bak`.

### 2. Copy the Backup to the Physical Machine (Host)
Since the container operates as an isolated sandbox, we extract the `.bak` file to your actual host machine to ensure true data redundancy.

Open your operating system's terminal (Terminal on Linux/Mac or PowerShell/CMD on Windows) and run the command below:

#### On Linux / Mac
```bash
docker cp <your_container_name>:/var/opt/mssql/data/hbo_db.bak ~/Documents/SQL_Backups/

```

#### On Windows

```bash
docker cp <your_container_name>:/var/opt/mssql/data/hbo_db.bak C:\SQL_Backups\

```

> 💡 **Production Note:** Replace `<your_container_name>` with the actual active container name configured in your Docker Desktop / CLI environment. Also, ensure that the target directory (`SQL_Backups`) already exists on your physical host machine before executing the command.

### 3. Simulate Disaster & Execute Restore

To validate that the backup is resilient and production-ready:

1. Run the second phase of the maintenance script to forcefully terminate active connections and drop the `hbo_db` database.
2. Run the final phase (`RESTORE DATABASE`) to trigger the contingency plan and restore the database state seamlessly.