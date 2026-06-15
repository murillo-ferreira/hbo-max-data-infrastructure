-- OBJETIVO: Otimizar o JOIN entre dbo.usuarios e dbo.assinaturas nas busca por dados.

USE hbo_db;
GO

-- Análise de leitura de páginas
SET STATISTICS IO ON;
GO

-- Query de teste
SELECT u.id,
       u.nome,
       u.email,
       a.status
FROM dbo.usuarios AS u JOIN dbo.assinaturas AS a ON
    u.id = a.usuario_id
WHERE email = 'usuario999@email.com'
GO

-- CRIAÇÃO DOS INDEXES

-- Index focado no filtro WHERE
CREATE NONCLUSTERED INDEX idx_usuarios_email
ON dbo.usuarios(email)
INCLUDE (nome);
GO

-- Index focado no JOIN
CREATE NONCLUSTERED INDEX idx_assinaturas_usuario_id
ON dbo.assinaturas(usuario_id);
GO