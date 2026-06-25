USE hbo_db;
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpsertSubscriptions
    @user_id INT,
    @plan_id INT,
    @begin_date DATE,
    @end_date DATE,
    @status VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            MERGE dbo.subscriptions WITH (HOLDLOCK) AS s
            USING (SELECT @user_id AS user_id, @plan_id AS plan_id, @begin_date AS begin_date, @end_date AS end_date, @status AS status) AS src
            ON s.user_id = src.user_id
            WHEN MATCHED THEN
                UPDATE SET 
                    s.plan_id = src.plan_id, 
                    s.begin_date = src.begin_date, 
                    s.end_date = src.end_date, 
                    s.status = src.status
            WHEN NOT MATCHED THEN
                INSERT (user_id, plan_id, begin_date, end_date, status)
                VALUES (src.user_id, src.plan_id, src.begin_date, src.end_date, src.status);
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