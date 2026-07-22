USE hbo_db;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CloseSubscription
    @user_id INT,
    @new_plan_id INT,
    @end_date DATE,
    @new_begin_date DATE,
    @status VARCHAR(20) = 'ACTIVE'
AS
BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRAN
    UPDATE dbo.subscriptions
        SET end_date = @end_date,
            status = 'CANCELLED'
        WHERE user_id = @user_id
        AND status = 'ACTIVE'
        AND begin_date <= @end_date;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 51000, 'No eligible active subscription found for termination on the specified date.', 1;
    END

    INSERT INTO dbo.subscriptions
        (user_id, plan_id, begin_date, end_date, status)
    VALUES
        (@user_id, @new_plan_id, @new_begin_date, NULL, @status)
    COMMIT TRAN
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    THROW;
END CATCH;
GO