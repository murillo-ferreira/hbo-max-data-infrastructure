USE hbo_db;
GO

INSERT INTO dbo.assinaturas (usuario_id, plano_id, data_inicio, status)
SELECT 
    id,               -- Pega o ID de cada usuário existente
    1,                -- Define o ID do plano fixo (ex: 1)
    data_criacao,     -- Data de início padrão
    'Ativo'           -- Status padrão
FROM dbo.usuarios;
GO