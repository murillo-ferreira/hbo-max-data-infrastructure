USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.titles;
GO

CREATE TABLE dbo.titles
(
    id INT NOT NULL,
    imdb_id NVARCHAR (50) NULL,
    title VARCHAR (255) NOT NULL,
    type VARCHAR (50) NOT NULL,
    release_year SMALLINT NOT NULL,
    runtime SMALLINT NOT NULL,
    genres NVARCHAR (255) NOT NULL,
    budget INT NULL,
    origin_country NVARCHAR (50) NOT NULL,
    seasons SMALLINT NULL,
    vote_average FLOAT NULL,
    vote_count INT NULL,
    popularity FLOAT NULL,

    CONSTRAINT PK_titles PRIMARY KEY (id)
);
GO