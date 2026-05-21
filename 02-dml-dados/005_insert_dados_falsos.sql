USE hbo_db;
GO

-- Variável pra controlar o loop.
DECLARE @contador INT = 1;

-- Inicia o laço de repetição
WHILE @contador <= 1000 
BEGIN
    
    INSERT INTO dbo.usuarios (nome, email, senha, data_criacao)
    VALUES (
        'Usuario ' + CAST(@contador AS VARCHAR(5)),               
        'usuario' + CAST(@contador AS VARCHAR(5)) + '@email.com',
        'senha123',                             
        -- Cria um por dia                  
        GETDATE() - @contador                                     
    );

    -- Soma +1 no contador para não dar loop infinito
    SET @contador = @contador + 1;
END;
GO