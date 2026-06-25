USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.pipeline_logs;
GO

CREATE TABLE dbo.pipeline_logs
(
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    execution_date DATETIME DEFAULT GETDATE(),
    status_execution VARCHAR(50),
    last_processed_id VARCHAR(50),
    total_records_processed INT,
    error_message NVARCHAR(MAX) NULL
);
GO