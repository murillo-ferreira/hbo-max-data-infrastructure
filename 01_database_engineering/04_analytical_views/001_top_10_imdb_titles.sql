/*
  GOAL: Identify the top 10 titles with the highest IMDb scores.
  BUSINESS QUESTION: What are the top 10 titles with the highest IMDb scores?
*/

USE hbo_db;
GO

DROP VIEW IF EXISTS dbo.vw_top_10_imdb_titles;
GO

CREATE VIEW dbo.vw_top_10_imdb_titles
AS
  SELECT TOP 10
    title,
    type,
    imdb_score,
    imdb_votes
  FROM dbo.titles
  WHERE imdb_votes > 1000
  ORDER BY imdb_score DESC;
GO