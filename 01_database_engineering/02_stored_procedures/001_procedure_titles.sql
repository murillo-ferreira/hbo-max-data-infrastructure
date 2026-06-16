USE hbo_db;
GO

DROP PROCEDURE IF EXISTS dbo.sp_UpsertTitles;
GO

CREATE PROCEDURE dbo.sp_UpsertTitles
    @id NVARCHAR(50),
    @title VARCHAR(255),
    @type VARCHAR(50),
    @release_year SMALLINT,
    @age_certification NVARCHAR(50),
    @runtime TINYINT,
    @genres NVARCHAR(255),
    @production_countries NVARCHAR(50),
    @seasons TINYINT,
    @imdb_id NVARCHAR(50),
    @imdb_score DECIMAL(3, 1),
    @imdb_votes INT
AS
BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRANSACTION
        MERGE dbo.titles WITH (HOLDLOCK) AS t
        USING (SELECT @id AS id, @title AS title, @type AS type, @release_year AS release_year, @age_certification AS age_certification, @runtime AS runtime, @genres AS genres, @production_countries AS production_countries, @seasons AS seasons, @imdb_id AS imdb_id, @imdb_score AS imdb_score, @imdb_votes AS imdb_votes) AS s
        ON t.id = s.id
        WHEN MATCHED THEN
            UPDATE SET t.title = s.title, t.imdb_id = s.imdb_id, t.imdb_score = s.imdb_score, t.imdb_votes = s.imdb_votes
        WHEN NOT MATCHED THEN
            INSERT (id, title, type, release_year, age_certification, runtime, genres, production_countries, seasons, imdb_id, imdb_score, imdb_votes)
            VALUES (s.id, s.title, s.type, s.release_year, s.age_certification, s.runtime, s.genres, s.production_countries, s.seasons, s.imdb_id, s.imdb_score, s.imdb_votes);
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF (XACT_STATE()) = -1 OR (XACT_STATE()) = 1
    BEGIN
    ROLLBACK TRANSACTION;
END;
    THROW;
    END CATCH;
GO