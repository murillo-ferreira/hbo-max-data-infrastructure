USE hbo_db;
GO

-- 1. Criamos a variável para controlar o loop
DECLARE @contador INT = 1;

-- 2. Iniciamos o laço de repetição para gerar 1000 usuários
WHILE @contador <= 1000
BEGIN
    
    INSERT INTO dbo.usuarios (nome, email, senha, data_criacao)
    VALUES (
        'Usuario ' + CAST(@contador AS VARCHAR(5)),               -- Nome: 'Usuario 1', 'Usuario 2'...
        'usuario' + CAST(@contador AS VARCHAR(5)) + '@email.com',  -- Email único (Garante a restrição UNIQUE)
        'senha123',                                               -- Senha simples em texto puro
        GETDATE() - @contador                                     -- Data: Cria um por dia retroativo no passado
    );

    -- 3. Soma +1 no contador para avançar para o próximo usuário
    SET @contador = @contador + 1;
END;
GO