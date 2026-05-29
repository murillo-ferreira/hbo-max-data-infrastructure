# 📁 05 - Backup & Recovery (Docker Multiplataforma)

Este módulo demonstra a estratégia de resiliência de dados do projeto, cobrindo o ciclo completo de geração de backup, exportação de segurança para a máquina física (Host) e restauração pós-desastre.

## Como Executar o Fluxo

### 1. Gerar o Backup Interno

Abra o seu editor SQL conectado ao container e execute a primeira parte do script `001_backup-restore.sql` (`BACKUP DATABASE`). Isso gerará o arquivo `.bak` isolado dentro do ambiente Linux do container.

### 2. Copiar o Backup para a Máquina Física (Host)

Como o container funciona como um ambiente isolado, precisamos extrair o arquivo `.bak` para a sua máquina real para garantir a segurança dos dados.

Abra o terminal do seu sistema operacional (Terminal no Linux/Mac ou PowerShell/CMD no Windows) e execute o comando adaptado para o seu ambiente:

#### No Linux / No Mac

```bash
docker cp sqlserver_container:/var/opt/mssql/data/backup_portfolio.bak /home/seu_usuario/Documents/SQL_Backups/

```

#### No Windows

```bash
docker cp sqlserver_container:/var/opt/mssql/data/backup_portfolio.bak C:\SQL_Backups\

```

> **Nota Técnica:** Certifique-se de que a pasta de destino (`SQL_Backups`) já esteja criada na sua máquina antes de rodar o comando.

### 3. Simular o Desastre e Rodar o Restore

Para homologar que o backup é válido e resiliente:

1. Execute a segunda parte do script `001_backup-restore.sql` para forçar a queda e exclusão completa da database `hbo_db`.
2. Execute a terceira parte (`RESTORE DATABASE`) para acionar o plano de contingência e restaurar o banco de dados exatamente do ponto onde o backup foi tirado.
