/*
OBJETIVO: Consultar o volume de filmes lançados por ano na plataforma HBO Max.
PERGUNTA DE NEGÓCIO: Qual ano teve o maior número de estreias de filmes na plataforma?
*/

USE hbo_db;
GO

SELECT 
    release_year AS [Ano de Lançamento],
    COUNT(*) AS [Total de Filmes]
FROM dbo.titles
WHERE type = 'movie'
    AND release_year > 0
GROUP BY release_year
ORDER BY [Total de Filmes] DESC;
GO