USE master;
GO

CREATE SERVER AUDIT Security_Audit_Errors
TO FILE (FILEPATH = '/var/opt/mssql/log/audit');
GO

ALTER SERVER AUDIT Security_Audit_Errors
WITH (STATE = ON);
GO

USE hbo_db;
GO

-- Create audit specifications for the audit logs to capture failed access attempts and schema changes in the database.
IF NOT EXISTS (SELECT *
FROM sys.database_audit_specifications
WHERE name = 'Audit_Failed_Access')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION Audit_Failed_Access
    FOR SERVER AUDIT Security_Audit_Errors
    ADD (FAILED_DATABASE_AUTHENTICATION_GROUP),
    ADD (SCHEMA_OBJECT_ACCESS_GROUP)
    WITH (STATE = ON);
END
GO

-- Create a view for the audit logs
CREATE VIEW dbo.vw_Audit_Logs
AS
    SELECT
        event_time,
        action_id,
        succeeded,
        session_server_principal_name,
        database_principal_name,
        object_name,
        statement
    FROM sys.fn_get_audit_file('/var/opt/mssql/log/audit/*.sqlaudit', DEFAULT, DEFAULT);
GO

-- View the audit logs
SELECT *
FROM dbo.vw_Audit_Logs
WHERE succeeded = 0;
GO