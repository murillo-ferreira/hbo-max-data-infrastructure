USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.titles;
GO

CREATE TABLE dbo.titles
(
    id NVARCHAR (50) NOT NULL,
    title VARCHAR (255) NOT NULL,
    type VARCHAR (50) NOT NULL,
    release_year SMALLINT NOT NULL,
    runtime TINYINT NOT NULL,
    genres NVARCHAR (255) NOT NULL,
    production_countries NVARCHAR (50) NOT NULL,
    seasons TINYINT NULL,
    tmdb_id NVARCHAR (50) NULL,
    tmdb_score DECIMAL (3,1) NULL,
    tmdb_votes INT NULL,
    tmdb_popularity DECIMAL (10,3) NULL,

    CONSTRAINT PK_titles PRIMARY KEY (id)
);
GO