USE hbo_db;
GO

CREATE OR ALTER PROCEDURE dbo.sp_InsertWatchHistory
    @user_id INT,
    @movie_id NVARCHAR(50),
    @view_date DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO dbo.watch_history
        (user_id, movie_id, view_date)
    VALUES
        (@user_id, @movie_id, @view_date);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0
        BEGIN
        ROLLBACK TRANSACTION;
    END;
        THROW;
    END CATCH;
END;
GO