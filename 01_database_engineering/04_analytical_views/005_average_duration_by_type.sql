/*
GOAL / BUSINESS QUESTION: What is the average duration of content by type?
*/

USE hbo_db;
GO

DROP VIEW IF EXISTS dbo.vw_average_duration_by_type;
GO

CREATE VIEW dbo.vw_average_duration_by_type
AS
    SELECT
        type,
        AVG(runtime) AS [average_duration]
    FROM dbo.titles
    WHERE runtime > 0
    GROUP BY type;
GO