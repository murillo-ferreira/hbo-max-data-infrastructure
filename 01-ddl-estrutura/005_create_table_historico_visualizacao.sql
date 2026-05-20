USE hbo_db;
GO
CREATE TABLE historico_visualizacao (
    id INT PRIMARY KEY IDENTITY(1,1),
    usuario_id INT NOT NULL,
    filme_id NVARCHAR(50) NOT NULL,
    data_visualizacao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (filme_id) REFERENCES titles(id)
);
GO