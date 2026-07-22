USE hbo_db;
GO

CREATE OR ALTER PROCEDURE dbo.sp_InsertSubscription
    @user_id INT,
    @plan_id INT,
    @begin_date DATE,
    @status VARCHAR(20) = 'ACTIVE'
AS
BEGIN
    INSERT INTO dbo.subscriptions
        (user_id, plan_id, begin_date, end_date, status)
    VALUES
        (@user_id, @plan_id, @begin_date, NULL, @status);
END;
GO