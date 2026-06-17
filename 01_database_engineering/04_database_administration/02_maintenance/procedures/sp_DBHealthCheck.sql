USE hbo_db;
GO

DROP PROCEDURE IF EXISTS sp_DBHealthCheck;
GO

CREATE PROCEDURE dbo.sp_DBHealthCheck
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Catch the most critical waits
    INSERT INTO dbo.maintenance_log
        (event_name, event_date, status, message)
    SELECT
        'HealthCheck - WaitStats',
        GETDATE(),
        'INFO',
        'Top wait: ' + wait_type + ' | Time: ' + CAST(wait_time_ms AS VARCHAR)
    FROM sys.dm_os_wait_stats
    WHERE wait_time_ms > 1000
        AND wait_type NOT IN ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE');

    -- 2. Check I/O Latency
    INSERT INTO dbo.maintenance_log
        (event_name, event_date, status, message)
    SELECT
        'HealthCheck - IO_Latency',
        GETDATE(),
        'WARNING',
        'High latency on: ' + DB_NAME(database_id) + ' | Latency: ' + CAST(io_stall_read_ms AS VARCHAR)
    FROM sys.dm_io_virtual_file_stats(NULL, NULL)
    WHERE io_stall_read_ms > 500;
END;
GO
