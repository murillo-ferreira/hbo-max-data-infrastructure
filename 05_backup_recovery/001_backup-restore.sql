USE master;
GO

-- Cria o backup da database hbo_db local no Docker
BACKUP DATABASE hbo_db
TO DISK = '/var/opt/mssql/data/backup_portfolio.bak'
WITH FORMAT,
NAME = 'Backup Inicial do Portfólio';
GO


-- Exclui a database hbo_db
ALTER DATABASE hbo_db 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

DROP DATABASE IF EXISTS hbo_db;
GO

-- Restaura a database hbo_db
RESTORE DATABASE hbo_db
FROM DISK = '/var/opt/mssql/data/backup_portfolio.bak'
WITH REPLACE;
GO