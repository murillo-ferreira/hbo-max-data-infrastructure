USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.plans;
GO

CREATE TABLE dbo.plans
(
    id INT IDENTITY(1,1),
    name VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description VARCHAR(MAX),

    CONSTRAINT PK_plans_id PRIMARY KEY CLUSTERED (id),
);
GO