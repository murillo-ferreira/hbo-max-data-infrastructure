USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.watch_history;
GO

CREATE TABLE dbo.watch_history
(
    id INT IDENTITY(1,1),
    user_id INT NOT NULL,
    content_id INT NOT NULL,
    view_date DATETIME DEFAULT GETDATE(),

    CONSTRAINT PK_watch_history_id PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_watch_history_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_watch_history_titles FOREIGN KEY (content_id) REFERENCES dbo.titles(tmdb_id)
);
GO