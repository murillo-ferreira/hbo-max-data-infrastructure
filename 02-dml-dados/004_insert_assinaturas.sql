USE hbo_db;
GO

INSERT INTO dbo.assinaturas (usuario_id, plano_id, data_inicio, status)
SELECT 
    id, -- Pega o ID do usuário
    
    -- Lógica do Plano: Se for divisível por 3 dá o plano 3, se for por 2 dá o plano 2, se não, dá o 1
    CASE 
        WHEN id % 3 = 0 THEN 3
        WHEN id % 2 = 0 THEN 2
        ELSE 1
    END AS plano_id,
    
    data_criacao,
    
    -- Lógica do Status: Se o ID for divisível por 5, o cliente cancelou
    CASE 
        WHEN id % 5 = 0 THEN 'Cancelado'
        ELSE 'Ativo'
    END AS status
FROM dbo.usuarios
WHERE id NOT IN (SELECT usuario_id FROM dbo.assinaturas);
GO