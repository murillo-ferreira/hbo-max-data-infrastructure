USE hbo_db;
GO

DROP PROCEDURE IF EXISTS dbo.sp_InsertWatchHistory;
GO

CREATE PROCEDURE dbo.sp_InsertWatchHistory
    @user_id INT,
    @movie_id NVARCHAR(50),
    @view_date DATETIME
AS
BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
        INSERT INTO dbo.watch_history
    (user_id, movie_id, view_date)
VALUES
    (@user_id, @movie_id, @view_date);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF (XACT_STATE()) = -1 OR (XACT_STATE()) = 1
    BEGIN
    ROLLBACK TRANSACTION;
END;
    PRINT 'Error inserting watch history record: ' + ERROR_MESSAGE();
END CATCH;
GO