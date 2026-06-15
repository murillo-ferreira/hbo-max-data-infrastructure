USE hbo_db;
GO

USE hbo_db;
GO

INSERT INTO dbo.assinaturas (usuario_id, plano_id, data_inicio, status)
SELECT 
    id,
    CASE 
        WHEN id % 3 = 0 THEN 3
        WHEN id % 2 = 0 THEN 2
        ELSE 1
    END AS plano_id,
    data_criacao,
    CASE 
        WHEN id % 5 = 0 THEN 'Cancelado'
        ELSE 'Ativo'
    END AS status
FROM dbo.usuarios u
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.assinaturas a 
    WHERE a.usuario_id = u.id
);
GO