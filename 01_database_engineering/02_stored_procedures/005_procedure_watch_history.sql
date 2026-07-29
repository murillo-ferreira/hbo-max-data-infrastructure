USE hbo_db;
GO

CREATE OR ALTER PROCEDURE dbo.sp_InsertWatchHistory
    @user_id INT,
    @subscription_id INT, 
    @title_id INT,
    @watched_at DATETIME,
    @watch_duration INT,
    @device_type VARCHAR(20),
    @completed BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO dbo.watch_history
        (user_id, subscription_id, title_id, watched_at, watch_duration, device_type, completed)
    VALUES
        (@user_id, @subscription_id, @title_id, @watched_at, @watch_duration, @device_type, @completed);
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