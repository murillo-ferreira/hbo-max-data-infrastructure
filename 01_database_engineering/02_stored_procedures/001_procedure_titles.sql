USE hbo_db;
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpsertTitles
    @id NVARCHAR(50),
    @title VARCHAR(255),
    @imdb_id NVARCHAR(50),
    @type VARCHAR(50),
    @release_year SMALLINT,
    @runtime TINYINT,
    @genres NVARCHAR(255),
    @budget INT,
    @origin_country NVARCHAR(50),
    @seasons TINYINT,
    @vote_average FLOAT,
    @vote_count INT,
    @popularity FLOAT
AS
BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRANSACTION
        MERGE dbo.titles WITH (HOLDLOCK) AS t
        USING (SELECT
    @id AS id,
    @imdb_id AS imdb_id,
    @title AS title,
    @type AS type,
    @release_year AS release_year,
    @runtime AS runtime,
    @genres AS genres,
    @budget AS budget,
    @origin_country AS origin_country,
    @seasons AS seasons,
    @vote_average AS vote_average,
    @vote_count AS vote_count,
    @popularity AS popularity
              ) AS s
        ON t.title = s.title AND t.release_year = s.release_year
        WHEN MATCHED THEN
            UPDATE SET 
                t.imdb_id = s.imdb_id,
                t.vote_average = s.vote_average, 
                t.popularity = s.popularity
        WHEN NOT MATCHED THEN
            INSERT (id, imdb_id, title, type, release_year, runtime, genres, budget, origin_country, seasons, vote_average, vote_count, popularity)
            VALUES (s.id, s.imdb_id, s.title, s.type, s.release_year, s.runtime, s.genres, s.budget, s.origin_country, s.seasons, s.vote_average, s.vote_count, s.popularity);
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