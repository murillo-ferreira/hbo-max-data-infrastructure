USE hbo_db;
GO

SET STATISTICS IO ON;
GO

-- Cenário 1: Otimização de datas (SARGability)

CREATE INDEX idx_usuarios_data_criacao
ON dbo.usuarios(data_criacao);
GO

-- Query não-sargable
-- O banco de dados terá que percorrer todos os registros para encontrar o resultado
SELECT 
    id,
    nome,
    email
FROM dbo.usuarios
WHERE YEAR(data_criacao) = 2026;
GO


-- Query sargable
-- O banco de dados terá que percorrer apenas os registros que satisfazem o filtro
SELECT
    id,
    nome,
    email
FROM dbo.usuarios
WHERE data_criacao BETWEEN '2026-05-10' AND '2026-05-21';
GO

-- Cenário 2: Indíces compostos (múltiplas colunas)

-- Indíce composto

CREATE NONCLUSTERED INDEX idx_plano_status
ON dbo.assinaturas(plano_id, status)
INCLUDE (usuario_id, data_inicio, data_fim);
GO

-- Query teste
SELECT
    plano_id,
    status
FROM dbo.assinaturas
WHERE plano_id = 1 AND status = 'Cancelado';
GO