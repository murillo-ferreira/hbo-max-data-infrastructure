USE hbo_db;
GO

IF NOT EXISTS (SELECT *
FROM sys.database_principals
WHERE name = N'python_pipeline_role')
CREATE ROLE python_pipeline_role;
GO

IF NOT EXISTS (SELECT *
FROM sys.database_principals
WHERE name = N'analytics_viewer_role')
CREATE ROLE analytics_viewer_role;
GO