-- 1. Verifies the integrity of the backup file
RESTORE VERIFYONLY 
FROM DISK = '/var/opt/mssql/backup/hbo_db.bak' 
WITH CHECKSUM;
GO

--  2 (optional). Checks the header of the backup file
RESTORE HEADERONLY 
FROM DISK = '/var/opt/mssql/backup/hbo_db.bak';
GO