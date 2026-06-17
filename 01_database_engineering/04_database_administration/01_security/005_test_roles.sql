USE hbo_db;
GO

-- TEST 1: Pipeline validation
EXECUTE AS USER = 'python_pipeline_svc';
GO
EXEC dbo.sp_UpsertTitles @id = 'TEST', @title = 'Test', @type = 'Movie', @release_year = 2026, @runtime = 90, @genres = 'Test', @production_countries = 'BR', @seasons = NULL, @tmdb_id = '123', @tmdb_score = 5.0, @tmdb_votes = 1, @tmdb_popularity = 0.0;
GO
REVERT;
GO

-- TEST 2: Analyst validation (should fail on INSERT)
EXECUTE AS USER = 'analytics_viewer_svc';
GO
BEGIN TRY
    INSERT INTO dbo.titles
    (id, title, type, release_year, runtime, genres, production_countries)
VALUES
    ('FAIL', 'Hack', 'Movie', 2026, 90, 'Test', 'BR');
END TRY
BEGIN CATCH
    PRINT 'Success! Caught expected exception: ' + ERROR_MESSAGE();
END CATCH;
GO
REVERT;
GO