/*
  GOAL: Identify titles that contain a specific combination of genres (co-occurrence).
  BUSINESS QUESTION: Which titles in the catalog are classified as both 'Comedy' AND 'Documentation' simultaneously, regardless of other existing genres?
*/

USE hbo_db;
GO

DROP VIEW IF EXISTS dbo.vw_genre_coexistence;
GO

CREATE VIEW dbo.vw_genre_coexistence
AS
  SELECT
    title,
    ISNULL(genres, 'Non Specified') AS genres_cleaned
  FROM dbo.titles
  WHERE genres LIKE '%comedy%' AND genres LIKE '%documentation%'
GO