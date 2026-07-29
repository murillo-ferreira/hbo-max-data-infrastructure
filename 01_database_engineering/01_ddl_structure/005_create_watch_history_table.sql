USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.watch_history;
GO

CREATE TABLE dbo.watch_history
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    subscription_id INT NOT NULL,
    title_id INT NOT NULL,
    watched_at DATETIME NOT NULL,
    watch_duration INT NOT NULL,
    device_type VARCHAR(20) NULL,
    completed BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_watch_history_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_watch_history_titles FOREIGN KEY (title_id) REFERENCES dbo.titles(id),
    CONSTRAINT FK_subscriptions_id FOREIGN KEY (subscription_id) REFERENCES dbo.subscriptions(id)
);
GO