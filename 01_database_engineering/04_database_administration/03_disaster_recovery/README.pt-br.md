# 📁 03 - Disaster Recovery

Este módulo contém as rotinas de segurança para proteção e recuperação do banco de dados `hbo_db`.

## 📜 Estrutura de Scripts

### 1. `001_backup_restore.sql`

Este script realiza o ciclo completo de contingência:

* **Backup:** Gera uma cópia integral do banco (`hbo_db.bak`) com verificação de `CHECKSUM`.
* **Simulação de Desastre:** Force a exclusão do banco de dados após garantir que o backup foi gerado.
* **Restauração:** Executa o *restore* imediato para validar a integridade dos dados e a disponibilidade do sistema.

> ⚠️ **Aviso Crítico:** Este script inclui um comando `DROP DATABASE`. **Nunca execute este arquivo em um ambiente de produção ou onde existam dados que não foram extraídos para um local seguro.**

### 2. `002_verify_backup.sql`

Utilizado para validar o arquivo de backup antes de qualquer operação de restauração:

* **`RESTORE VERIFYONLY`:** Garante que o arquivo de backup não está corrompido e que o SQL Server consegue lê-lo.
* **`RESTORE HEADERONLY`:** Exibe metadados do backup (data de criação, nome do banco, etc.) para auditoria.

---

## 🚀 Guia de Operação (Multiplatform Docker)

Para manter a redundância externa ao container (Host):

1. **Geração e Extração:**
Após rodar o backup dentro do container, extraia o arquivo para a sua máquina física para garantir que, caso o container seja destruído, você não perca os dados:
```bash
# Exemplo para Linux/Mac ou PowerShell (ajuste o caminho de destino)
docker cp <nome_do_container>:/var/opt/mssql/backup/hbo_db.bak ~/SeuDiretorioDeBackups/

```


2. **Validação de Rotina:**
Recomenda-se rodar o script `002_verify_backup.sql` semanalmente para garantir que o backup está íntegro e legível.