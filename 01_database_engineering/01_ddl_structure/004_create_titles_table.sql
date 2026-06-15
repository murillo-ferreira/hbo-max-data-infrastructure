USE hbo_db;
GO

CREATE TABLE dbo.titles
(
    [id] NVARCHAR (50) NOT NULL,
    [title] NVARCHAR (255) NOT NULL,
    [type] NVARCHAR (50) NOT NULL,
    [description] NVARCHAR (MAX) NULL,
    [release_year] SMALLINT NOT NULL,
    [age_certification] NVARCHAR (50) NULL,
    [runtime] TINYINT NOT NULL,
    [genres] NVARCHAR (255) NOT NULL,
    [production_countries] NVARCHAR (50) NOT NULL,
    [seasons] TINYINT NULL,
    [imdb_id] NVARCHAR (50) NULL,
    [imdb_score] DECIMAL (3,1) NULL,
    [imdb_votes] INT NULL,
    [tmdb_popularity] DECIMAL (10,4) NULL,
    [tmdb_score] DECIMAL (3,1) NULL,

    CONSTRAINT PK_titles PRIMARY KEY (id)
);
GO