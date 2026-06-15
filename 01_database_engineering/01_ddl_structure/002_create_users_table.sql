USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.users;
GO

CREATE TABLE dbo.users
(
    id INT IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    date_created DATETIME DEFAULT GETDATE(),

    CONSTRAINT PK_users_id PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_users_email UNIQUE (email)
);
GO