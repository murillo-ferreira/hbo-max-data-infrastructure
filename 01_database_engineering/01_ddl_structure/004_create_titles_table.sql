USE hbo_db;
GO

DROP TABLE IF EXISTS dbo.titles;
GO

CREATE TABLE dbo.titles
(
    id INT IDENTITY(1,1) NOT NULL,
    tmdb_id INT NOT NULL,
    imdb_id NVARCHAR (50) NULL,
    title VARCHAR (255) NOT NULL,
    type VARCHAR (50) NOT NULL,
    release_year SMALLINT NULL,
    runtime SMALLINT NULL,
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

CREATE UNIQUE INDEX UIX_tmdb_id_type ON dbo.titles(tmdb_id, type);
GO