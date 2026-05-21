/*
OBJETIVO / PERGUNTA DE NEGÓCIO: Qual é a duração média (em formato de tempo) dos títulos por tipo de conteúdo?
*/

USE hbo_db;
GO


SELECT 
    type AS [Tipo],
    -- Usa o CONVERT para formatar a duração média em horas, minutos e segundos.
    CONVERT(varchar(8), DATEADD(MINUTE, AVG(runtime), CAST('00:00:00' AS datetime)), 108) AS [Duração Média]
FROM dbo.titles
WHERE runtime > 0
GROUP BY type
ORDER BY AVG(runtime) DESC;