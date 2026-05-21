/*
OBJETIVO: Criar uma visão relacional que combine informações sobre o comportamento do usuário com seu histórico de consumo, permitindo análises detalhadas sobre padrões de uso e preferências.
PERGUNTA DE NEGÓCIO: Quais são os padrões de comportamento dos usuários em relação ao seu histórico de consumo, e como isso pode informar estratégias de marketing e retenção?
*/

USE hbo_db;
GO

SELECT 
    u.id,
    u.nome AS 'Nome',
    hv.data_visualizacao AS [Data de Visualização],
    t.type AS [Tipo de Conteúdo],
    t.title AS [Título],
    -- Verifica se existe algum gênero especificado, caso contrário, retorna 'Não especificado'
    ISNULL(NULLIF(t.genres, '[]'), 'Não especificado') AS [Gênero]
FROM dbo.usuarios AS u JOIN dbo.historico_visualizacao AS hv ON 
    u.id = hv.usuario_id
JOIN dbo.titles AS t ON
    hv.filme_id = t.id
ORDER BY u.id, hv.data_visualizacao DESC;
GO