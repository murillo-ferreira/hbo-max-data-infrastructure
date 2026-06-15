-- OBJETIVO: Identificar e analisar as fragmentações dos índices existentes no banco de dados.
SELECT
    DB_NAME(ips.database_id) AS database_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    ips.avg_fragmentation_in_percent,
    ips.index_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID('hbo_db'), NULL, NULL, NULL, 'LIMITED') AS ips
JOIN sys.indexes AS i ON i.object_id = ips.object_id
AND i.index_id = ips.index_id
WHERE ips.database_id = DB_ID('hbo_db')
ORDER by ips.avg_fragmentation_in_percent DESC;
GO

-- Cenário A: Fragmentação entre 5% e 30%
-- Reorganiza as páginas existentes sem derrubar o banco.

-- CLUSTERED INDEXES
ALTER INDEX [PK__usuarios__3213E83F305B0686] 
ON [dbo].[usuarios] 
REORGANIZE;

ALTER INDEX [UQ__usuarios__AB6E6164CD985E7D]
ON [dbo].[usuarios] 
REORGANIZE;

ALTER INDEX [PK__assinatu__3213E83FDB77D6DF]
ON [dbo].[assinaturas] 
REORGANIZE;

-- NONCLUSTERED INDEXES
ALTER INDEX [idx_plano_status] 
ON [dbo].[assinaturas] 
REORGANIZE;

ALTER INDEX [idx_usuarios_email] 
ON [dbo].[usuarios] 
REORGANIZE;

-- Cenário B: Fragmentação acima de 30%
-- Reconstrói o índice do zero, compactando os dados.

-- CLUSTERED INDEXES
ALTER INDEX [PK_titles] 
ON [dbo].[titles]
REBUILD;

-- NONCLUSTERED INDEXES
ALTER INDEX [idx_assinaturas_usuario_id] 
ON [dbo].[assinaturas]
REBUILD;

ALTER INDEX [idx_usuarios_data_criacao] 
ON [dbo].[usuarios] 
REBUILD;

-- Observações:
-- Ao rodar este script em ambiente local, você notará que índices como 
-- 'idx_assinaturas_usuario_id' (50%) e 'idx_usuarios_data_criacao' (33%) 
-- não reduzem a fragmentação mesmo após o REBUILD/REORGANIZE.
--
-- O motor do banco recusa gastar processamento reorganizando 
-- páginas mistas, pois o impacto de ler 2 ou 3 páginas fragmentadas é zero.