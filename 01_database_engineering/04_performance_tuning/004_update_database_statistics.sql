-- GOAL: Show the existing statistics in the database and their update dates in the tables created by the user.

SELECT
    OBJECT_NAME(s.[object_id]) AS table_name,
    s.name AS stat_name,
    STATS_DATE(s.[object_id], s.stats_id) AS last_updated,
    s.auto_created, -- Indica se o próprio SQL criou para ajudar o otimizador
    s.user_created
-- Indica se foi criada por um usuário ou índice
FROM hbo_db.sys.stats AS s
    JOIN hbo_db.sys.tables AS t ON s.[object_id] = t.[object_id]
WHERE t.is_ms_shipped = 0
ORDER BY last_updated DESC;
GO


-- Case A: Update all statistics of a table at once.
UPDATE STATISTICS dbo.subscriptions WITH FULLSCAN;

-- Case B: Update a specific statistics of a column in a table.
UPDATE STATISTICS dbo.subscriptions [idx_subscriptions_user_id] WITH FULLSCAN;