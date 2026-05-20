USE hbo_db;
GO
CREATE TABLE planos (
    id INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(50) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    descricao TEXT,
);