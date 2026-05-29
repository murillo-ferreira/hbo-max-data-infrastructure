/*
  OBJETIVO: Identificar os 10 conteúdos mais bem avaliados pelo público.
  PERGUNTA DE NEGÓCIO: Quais produções são os "carros-chefes" de engajamento e crítica da plataforma?
*/

USE hbo_db;
GO

SELECT TOP 10
    title AS [Título],
    type AS Tipo,
    imdb_score AS [Avaliação IMDb],
    imdb_votes AS [Total de Votos]
FROM dbo.titles
WHERE imdb_votes > 1000
ORDER BY imdb_score DESC;