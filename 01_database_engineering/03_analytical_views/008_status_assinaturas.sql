/*
OBJETIVO: Analisar a volumetria da base de clientes por situação contratual.
PERGUNTA DE NEGÓCIO: Quantos usuários nós temos atualmente com o status 'Ativo' versus quantos estão 'Cancelado'? (Churn Rate)
*/

USE hbo_db;
GO

SELECT 
    COUNT(*) AS [Usuários],
    a.status AS [Status]
FROM dbo.assinaturas AS a
GROUP BY a.status
ORDER BY status DESC;
