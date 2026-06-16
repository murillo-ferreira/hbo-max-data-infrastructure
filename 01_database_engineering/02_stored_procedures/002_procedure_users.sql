USE hbo_db;
GO

DROP PROCEDURE IF EXISTS dbo.sp_UpsertUsers;
GO

CREATE PROCEDURE dbo.sp_UpsertUsers
    @name VARCHAR(100),
    @email VARCHAR(255),
    @date_created DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            MERGE dbo.users WITH (HOLDLOCK) AS u
            USING (SELECT @name AS name, @email AS email, @date_created AS date_created) AS s
            ON u.email = s.email
            WHEN MATCHED THEN
                UPDATE SET u.name = s.name
            WHEN NOT MATCHED THEN
                INSERT (name, email, date_created)
                VALUES (s.name, s.email, s.date_created);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) = -1 OR (XACT_STATE()) = 1
        BEGIN
        ROLLBACK TRANSACTION;
    END;
        PRINT 'Error inserting user: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO