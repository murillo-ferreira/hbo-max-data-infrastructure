USE hbo_db;
GO

SET STATISTICS IO ON;
GO

-- Case 1: Dates optimization (SARGable queries)
CREATE INDEX idx_user_date_creation
ON dbo.users(date_created);
GO

-- Non-sargable query
-- The database will have to scan all the records to find the result
SELECT
    id,
    name,
    email
FROM dbo.users
WHERE YEAR(date_created) = 2026;
GO


-- Query sargable
-- O banco de dados terá que percorrer apenas os registros que satisfazem o filtro
SELECT
    id,
    name,
    email
FROM dbo.users
WHERE date_created BETWEEN '2026-01-01' AND '2026-12-31';
GO

-- Case 2: Composite indexes (multiple columns)

-- Composite index
CREATE NONCLUSTERED INDEX idx_plan_status
ON dbo.subscriptions(plan_id, status)
INCLUDE (user_id, begin_date, end_date);
GO

-- Test query
SELECT
    plan_id,
    status
FROM dbo.subscriptions
WHERE plan_id = 1 AND status = 'cancelled';
GO