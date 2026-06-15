USE master;
GO

-- 1. Create a full backup of the database hbo_db locally in Docker
BACKUP DATABASE hbo_db
TO DISK = '/var/opt/mssql/data/hbo_db.bak' -- Nome padronizado conforme o Roadmap
WITH FORMAT,
    MEDIANAME = 'SQLServerBackups',
    NAME = 'Full Backup of hbo_db'; -- Nome interno em inglês
GO

-- 2. Delete the database to simulate a disaster recovery scenario
ALTER DATABASE hbo_db 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

DROP DATABASE IF EXISTS hbo_db;
GO

-- 3. Restore the database from the local backup file
RESTORE DATABASE hbo_db
FROM DISK = '/var/opt/mssql/data/hbo_db.bak'
WITH REPLACE;
GO