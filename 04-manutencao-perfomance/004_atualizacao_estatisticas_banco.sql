-- OBJETIVO: Mostra as estatísticas existentes no banco de dados e suas datas de atualização 
-- nas tabelas criadas pelo usuário.

SELECT
    OBJECT_NAME(s.[object_id], DB_ID('hbo_db')) AS table_name,
    c.name AS column_name,
    s.name AS stat_name,
    s.[object_id],
    s.stats_id,
    sc.column_id,
    sc.stats_column_id,
    STATS_DATE(s.[object_id], s.stats_id) AS last_updated
FROM hbo_db.sys.stats s
JOIN hbo_db.sys.stats_columns sc ON s.[object_id] = sc.[object_id] AND s.stats_id = sc.stats_id
JOIN hbo_db.sys.columns c ON sc.[object_id] = c.[object_id] AND sc.column_id = c.column_id
JOIN hbo_db.sys.tables t ON s.[object_id] = t.[object_id]
WHERE t.is_ms_shipped = 0
ORDER BY last_updated DESC;
GO

-- Cenário A: Atualiza TODAS as estatísticas de uma tabela de vez só.
-- com FULLSCAN (para maior precisão).
UPDATE STATISTICS [dbo].[assinaturas] WITH FULLSCAN;

-- Cenário B: Atualiza apenas uma estatística de uma coluna da tabela.

UPDATE STATISTICS [dbo].[assinaturas] [idx_assinaturas_usuario_id] WITH FULLSCAN;