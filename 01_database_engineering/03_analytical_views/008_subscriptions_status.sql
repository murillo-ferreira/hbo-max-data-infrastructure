/*
  GOAL: Identify the volume of clients by contractual status.
  BUSINESS QUESTION: How many users do we have with the status 'Active' versus how many are 'Cancelled' (Churn Rate)?
*/

USE hbo_db;
GO

DROP VIEW IF EXISTS dbo.vw_subscriptions_status;
GO


CREATE VIEW dbo.vw_subscriptions_status
AS
  SELECT
    COUNT(*) AS [users],
    s.status
  FROM dbo.subscriptions AS s
  GROUP BY s.status;
GO