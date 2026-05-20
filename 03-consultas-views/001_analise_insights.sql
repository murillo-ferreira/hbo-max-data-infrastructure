/*
  OBJETIVO: Analisar os insights de engajamento e avaliação dos conteúdos disponíveis na plataforma.
  PERGUNTA DE NEGÓCIO: Quais tipos de conteúdo (filmes ou séries) apresentam melhor desempenho em termos de avaliação e engajamento do público?
*/

USE hbo_db;
GO

SELECT
    type AS [Tipo de Conteúdo],
    COUNT(*) AS [Total de Titulos],
    AVG(imdb_score) AS [Média de Avaliação IMDb],
    AVG(tmdb_score) AS [Média de Avaliação TMDb]
FROM dbo.titles
GROUP BY type
ORDER BY COUNT(*) DESC;
GO