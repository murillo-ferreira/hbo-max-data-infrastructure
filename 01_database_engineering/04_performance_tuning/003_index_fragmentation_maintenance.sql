-- GOAL: Identify and analyze the fragmentation of the existing indices in the database.

SELECT
    DB_NAME(ips.database_id) AS database_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    ips.avg_fragmentation_in_percent,
    ips.index_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID('hbo_db'), NULL, NULL, NULL, 'LIMITED') AS ips
    JOIN sys.indexes AS i ON i.object_id = ips.object_id
        AND i.index_id = ips.index_id
WHERE ips.database_id = DB_ID('hbo_db')
ORDER by ips.avg_fragmentation_in_percent DESC;
GO

-- Case A: Fragmentation between 5% and 30%
-- Reorganize existent pages without shutting down the database.

-- CLUSTERED INDEXES
ALTER INDEX [PK_users_id] 
ON dbo.users 
REORGANIZE;

ALTER INDEX [UQ_users_email]
ON dbo.users 
REORGANIZE;

ALTER INDEX [PK_subscriptions_id]
ON dbo.subscriptions 
REORGANIZE;

-- NONCLUSTERED INDEXES
ALTER INDEX [idx_plan_status] 
ON dbo.subscriptions
REORGANIZE;

ALTER INDEX [idx_users_email] 
ON dbo.users 
REORGANIZE;

-- Case B: Fragmentation above 30%
-- Rebuild the index from scratch, compressing the data.

-- CLUSTERED INDEXES
ALTER INDEX [PK_titles] 
ON dbo.titles
REBUILD;

-- NONCLUSTERED INDEXES
ALTER INDEX [idx_subscriptions_user_id] 
ON dbo.subscriptions
REBUILD;

ALTER INDEX [idx_user_date_creation] 
ON dbo.users
REBUILD;