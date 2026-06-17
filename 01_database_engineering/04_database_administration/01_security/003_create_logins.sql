USE master;
GO

-- Creating local logins
IF NOT EXISTS (SELECT *
FROM sys.server_principals
WHERE name = N'python_pipeline_svc')
CREATE LOGIN python_pipeline_svc WITH PASSWORD = 'Python1234#';
GO

IF NOT EXISTS (SELECT *
FROM sys.server_principals
WHERE name = N'analytics_viewer_svc')
CREATE LOGIN analytics_viewer_svc WITH PASSWORD = 'analytics1234#';
GO

-- Mapping logins to roles
USE hbo_db;
GO

IF NOT EXISTS (SELECT *
FROM sys.database_principals
WHERE name = N'python_pipeline_svc')
CREATE USER python_pipeline_svc FOR LOGIN python_pipeline_svc;
ALTER ROLE python_pipeline_role ADD MEMBER python_pipeline_svc;
GO

IF NOT EXISTS (SELECT *
FROM sys.database_principals
WHERE name = N'analytics_viewer_svc')
CREATE USER analytics_viewer_svc FOR LOGIN analytics_viewer_svc;
ALTER ROLE analytics_viewer_role ADD MEMBER analytics_viewer_svc;
GO