/*
OBJETIVO: Criar uma visão relacional que combine informações sobre o faturamento por tipo de plano de assinatura, permitindo análises detalhadas sobre a receita gerada por cada categoria de plano.
PERGUNTA DE NEGÓCIO: Qual é o faturamento gerado por cada tipo de plano de assinatura, e como isso pode informar estratégias de precificação e marketing?
*/

USE hbo_db;
GO

SELECT 
    p.nome AS [Tipo de Plano],
    SUM(p.preco) AS [Faturamento Total]
FROM dbo.planos AS p JOIN dbo.assinaturas AS a ON
    p.id = a.plano_id
GROUP BY p.nome
ORDER BY [Faturamento Total] DESC;
GO