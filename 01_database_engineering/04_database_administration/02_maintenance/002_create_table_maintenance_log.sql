USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.maintenance_log;
GO

CREATE TABLE dbo.maintenance_log
(
    id INT NOT NULL IDENTITY(1,1),
    event_name VARCHAR(50) NOT NULL,
    event_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    message VARCHAR(MAX)

        CONSTRAINT PK_maintenance_log_id PRIMARY KEY (id)
);
GO