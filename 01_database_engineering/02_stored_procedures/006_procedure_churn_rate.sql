USE hbo_db;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ChurnRate
    @user_id INT,
    @plan_id INT,
    @begin_date DATE,
    @new_end_date DATE,
    @status VARCHAR(20) = 'CANCELLED'
AS
BEGIN TRY
    SET NOCOUNT ON;
    BEGIN TRAN
        UPDATE dbo.subscriptions
            SET end_date = @new_end_date,
                status = @status
            WHERE user_id = @user_id
            AND begin_date <= @new_end_date
            AND status = 'ACTIVE';

        IF @@ROWCOUNT = 0
        BEGIN
            THROW 51000, 'No eligible subscription found for termination.', 1;
        END
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