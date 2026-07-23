USE hbo_db;
GO

-- For Python Pipeline Role
GRANT EXECUTE ON OBJECT::dbo.sp_UpsertTitles TO python_pipeline_role;
GRANT EXECUTE ON OBJECT::dbo.sp_UpsertUsers TO python_pipeline_role;
GRANT EXECUTE ON OBJECT::dbo.sp_UpsertSubscriptions TO python_pipeline_role;
GRANT EXECUTE ON OBJECT::dbo.sp_InsertWatchHistory TO python_pipeline_role;
GO
GRANT EXECUTE ON OBJECT::dbo.sp_InsertSubscription TO python_pipeline_role;
GO
GRANT EXECUTE ON OBJECT::dbo.sp_CloseSubscription TO python_pipeline_role;
GRANT EXECUTE ON OBJECT::dbo.sp_ChurnRate TO python_pipeline_role;
GRANT SELECT ON OBJECT::dbo.titles TO python_pipeline_role;
GO
GRANT SELECT ON OBJECT::dbo.users TO python_pipeline_role;
GRANT SELECT ON OBJECT::dbo.subscriptions TO python_pipeline_role;
GRANT INSERT ON OBJECT:: dbo.subscriptions TO python_pipeline_role;
GRANT SELECT ON OBJECT::dbo.watch_history TO python_pipeline_role;
GRANT INSERT ON OBJECT:: dbo.watch_history TO python_pipeline_role;
GRANT INSERT ON OBJECT::dbo.pipeline_logs TO python_pipeline_role;
GO
GRANT INSERT ON OBJECT::dbo.titles TO python_pipeline_role;