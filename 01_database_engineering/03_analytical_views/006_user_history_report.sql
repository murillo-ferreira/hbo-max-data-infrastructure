/*
  GOAL: Generate a relational view that combines information about user behavior with their consumption history, allowing detailed analyses of usage patterns and preferences.
  BUSINESS QUESTION: What is the user behavior and consumption history?
*/

USE hbo_db;
GO

DROP VIEW IF EXISTS dbo.vw_user_history_report;
GO

CREATE VIEW dbo.vw_user_history_report
AS
    SELECT
        u.id AS user_id,
        u.name AS user_name,
        wh.view_date,
        t.type,
        t.title,
        -- Verify if there is any genre specified, if not, return 'Non Specified'
        ISNULL(NULLIF(t.genres, '[]'), 'Non Specified') AS genres
    FROM dbo.users AS u JOIN dbo.watch_history AS wh ON 
    u.id = wh.user_id
        JOIN dbo.titles AS t ON
    wh.movie_id = t.id;
GO