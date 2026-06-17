USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.subscriptions;
GO

CREATE TABLE dbo.subscriptions
(
    id INT IDENTITY(1,1),
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    begin_date DATE NOT NULL,
    end_date DATE NULL,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT PK_subscriptions_id PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_subscriptions_users FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_subscriptions_plans FOREIGN KEY (plan_id) REFERENCES dbo.plans(id)
);
GO