USE hbo_db;
GO

DROP PROCEDURE IF EXISTS dbo.sp_UpsertTitles;
GO

CREATE PROCEDURE dbo.sp_UpsertTitles
    @id NVARCHAR(50),
    @title VARCHAR(255),
    @type VARCHAR(50),
    @release_year SMALLINT,
    @runtime TINYINT,
    @genres NVARCHAR(255),
    @production_countries NVARCHAR(50),
    @seasons TINYINT,
    @tmdb_id NVARCHAR(50),
    @tmdb_score DECIMAL(3, 1),
    @tmdb_votes INT,
    @tmdb_popularity DECIMAL(10, 3)
AS
BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRANSACTION
        MERGE dbo.titles WITH (HOLDLOCK) AS t
        USING (SELECT
    @id AS id,
    @title AS title,
    @type AS type,
    @release_year AS release_year,
    @runtime AS runtime,
    @genres AS genres,
    @production_countries AS production_countries,
    @seasons AS seasons,
    @tmdb_id AS tmdb_id,
    @tmdb_score AS tmdb_score,
    @tmdb_votes AS tmdb_votes,
    @tmdb_popularity AS tmdb_popularity
              ) AS s
        ON t.id = s.id
        WHEN MATCHED THEN
            UPDATE SET 
                t.title = s.title, 
                t.tmdb_id = s.tmdb_id, 
                t.tmdb_score = s.tmdb_score, 
                t.tmdb_votes = s.tmdb_votes,
                t.tmdb_popularity = s.tmdb_popularity
        WHEN NOT MATCHED THEN
            INSERT (id, title, type, release_year, runtime, genres, production_countries, seasons, tmdb_id, tmdb_score, tmdb_votes, tmdb_popularity)
            VALUES (s.id, s.title, s.type, s.release_year, s.runtime, s.genres, s.production_countries, s.seasons, s.tmdb_id, s.tmdb_score, s.tmdb_votes, s.tmdb_popularity);
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0
    BEGIN
    ROLLBACK TRANSACTION;
END;
    THROW;
END CATCH;
GO