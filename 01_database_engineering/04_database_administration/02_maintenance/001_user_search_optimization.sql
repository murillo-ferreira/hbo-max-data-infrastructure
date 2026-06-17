-- GOAL: Optimize the JOIN between dbo.users and dbo.subscriptions in search for data.

USE hbo_db;
GO

-- Enable statistics
SET STATISTICS IO ON;
GO

-- Test query
SELECT u.id,
    u.name,
    u.email,
    s.status
FROM dbo.users AS u JOIN dbo.subscriptions AS s ON
    u.id = s.user_id
-- WHERE u.email = 'placeholder@email.com' -- TODO: Integrate with fake data from Python.
GO

-- INDEXES CREATION

-- Index focused on the WHERE clause
CREATE NONCLUSTERED INDEX idx_users_email
ON dbo.users(email)
INCLUDE (name);
GO

-- Index focused on the JOIN
CREATE NONCLUSTERED INDEX idx_subscriptions_user_id
ON dbo.subscriptions(user_id)
INCLUDE (status);
GO