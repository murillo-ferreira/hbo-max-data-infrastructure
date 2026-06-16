USE hbo_db;
GO

DROP PROCEDURE IF EXISTS dbo.sp_UpsertSubscriptions;
GO

CREATE PROCEDURE dbo.sp_UpsertSubscriptions
    @user_id INT,
    @plan_id INT,
    @begin_date DATE,
    @end_date DATE,
    @status VARCHAR(20)
AS
BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1
FROM dbo.subscriptions
WHERE user_id = @user_id)
    BEGIN
    INSERT INTO dbo.subscriptions
        (user_id, plan_id, begin_date, end_date, status)
    VALUES
        (@user_id, @plan_id, @begin_date, @end_date, @status);
END;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF (XACT_STATE()) = -1 OR (XACT_STATE()) = 1
    BEGIN
    ROLLBACK TRANSACTION;
END;
    PRINT 'Error inserting subscription: ' + ERROR_MESSAGE();
END CATCH;
GO