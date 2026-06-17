USE master;
GO

ALTER DATABASE hbo_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE hbo_db SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

ALTER DATABASE hbo_db SET READ_COMMITTED_SNAPSHOT ON;
GO

ALTER DATABASE hbo_db SET MULTI_USER;
GO

-- Check if RCSI is enabled
SELECT name, is_read_committed_snapshot_on, snapshot_isolation_state
FROM sys.databases
WHERE name = 'hbo_db';