/*
  GOAL: Identify the year with the highest number of movie releases.
  BUSINESS QUESTION: Which year had the highest number of movie releases on the platform?
*/

USE hbo_db;
GO

DROP VIEW IF EXISTS dbo.vw_release_volume_by_year;
GO

CREATE VIEW dbo.vw_release_volume_by_year
AS
    SELECT
        release_year,
        COUNT(*) AS [movies_released]
    FROM dbo.titles
    WHERE type = 'movie'
        AND release_year > 0
    GROUP BY release_year;
GO