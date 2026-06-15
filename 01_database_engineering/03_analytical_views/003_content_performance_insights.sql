/*
  GOAL: Analyze engagement and rating insights for available content on the platform.
  BUSINESS QUESTION: Which types of content (movies or series) have better engagement and rating performance?
*/

USE hbo_db;
GO

DROP VIEW IF EXISTS dbo.vw_content_performance_insights;
GO

CREATE VIEW dbo.vw_content_performance_insights
AS
  SELECT
    type,
    COUNT(*) AS [amount_of_titles],
    AVG(imdb_score) AS [average_IMDB_score],
    AVG(tmdb_score) AS [average_TMDB_score]
  FROM dbo.titles
  GROUP BY type
GO