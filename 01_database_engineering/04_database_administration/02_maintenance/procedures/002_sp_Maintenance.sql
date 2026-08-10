USE hbo_db;
GO

DROP PROCEDURE IF EXISTS dbo.sp_RunMaintenance;
GO

CREATE PROCEDURE dbo.sp_RunMaintenance
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @tableName NVARCHAR(256), @indexName NVARCHAR(256), @frag FLOAT;

    -- Cursor to check indexes with more than 5% fragmentation
    DECLARE cur_idx CURSOR FOR 
    SELECT OBJECT_NAME(ips.object_id), i.name, ips.avg_fragmentation_in_percent
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
        JOIN sys.indexes AS i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
    WHERE ips.avg_fragmentation_in_percent > 5;

    OPEN cur_idx;
    FETCH NEXT FROM cur_idx INTO @tableName, @indexName, @frag;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Decides wether to REORGANIZE or REBUILD
        IF @frag < 30
            SET @sql = 'ALTER INDEX ' + QUOTENAME(@indexName) + ' ON ' + QUOTENAME(@tableName) + ' REORGANIZE;';
        ELSE
            SET @sql = 'ALTER INDEX ' + QUOTENAME(@indexName) + ' ON ' + QUOTENAME(@tableName) + ' REBUILD;';

        BEGIN TRY
            EXEC sp_executesql @sql;
            INSERT INTO dbo.maintenance_log
        VALUES
            ('Index Maint', GETDATE(), 'SUCCESS', @indexName + ' processed.');
        END TRY
        BEGIN CATCH
            INSERT INTO dbo.maintenance_log
        VALUES
            ('Index Maint', GETDATE(), 'ERROR', ERROR_MESSAGE());
        END CATCH

        FETCH NEXT FROM cur_idx INTO @tableName, @indexName, @frag;
    END

    CLOSE cur_idx;
    DEALLOCATE cur_idx;

    -- Update statistics
    BEGIN TRY
    UPDATE STATISTICS dbo.subscriptions WITH FULLSCAN;
    INSERT INTO dbo.maintenance_log
    VALUES
        ('Stats Update', GETDATE(), 'SUCCESS', 'Subscriptions statistics updated.');
END TRY
BEGIN CATCH
    INSERT INTO dbo.maintenance_log
    VALUES
        ('Stats Update', GETDATE(), 'ERROR', ERROR_MESSAGE());
END CATCH
END;