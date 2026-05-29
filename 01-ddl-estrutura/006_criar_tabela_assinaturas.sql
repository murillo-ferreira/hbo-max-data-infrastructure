USE hbo_db;
GO

CREATE TABLE dbo.assinaturas (
    id INT PRIMARY KEY IDENTITY(1,1),
    usuario_id INT NOT NULL,
    plano_id INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES dbo.usuarios(id),
    FOREIGN KEY (plano_id) REFERENCES dbo.planos(id)
);
GO