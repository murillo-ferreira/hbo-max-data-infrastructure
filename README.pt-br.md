# 🎬 HBO Max - Data Engineering & SQL Database Infrastructure

Modelagem de dados, pipeline de ingestão e administração de um sistema de banco de dados relacional baseado na plataforma de streaming **HBO Max**. Este projeto simula um ambiente de produção de nível corporativo, cobrindo desde a aplicação estrita de DDL, otimização avançada de queries, desfragmentação física de índices, até estratégias de recuperação de desastres (Disaster Recovery).

---

## 🧭 Arquitetura do Projeto e Estrutura de Diretórios

O repositório segue um pipeline de deploy sequencial e rigoroso para garantir a previsibilidade da evolução do banco de dados:

```text
hbo-max-data-infrastructure/
├── 01_database_engineering/          # Arquitetura de Schema e Stored Procedures
├── 04_analytical_views/              # Views de KPI e Business Intelligence
├── 04_database_administration/       # DBA e Infraestrutura
│   ├── 01_security/                  # Roles, RCSI, Auditoria
│   ├── 02_maintenance/               # sp_RunMaintenance, sp_DBHealthCheck, maintenance_log
│   └── 03_disaster_recovery/         # Backup e Restore
├── 05_data_quality/                  # Verificações de consistência de dados
├── 06_inital_setup/                  # Seeding de dados e catálogos
├── 02_data_pipeline_python/          # Pipelines de ingestão
└── 03_analytics_dashboard/           # Modelos semânticos do Power BI

```

---

## 🗂️ Modelagem de Dados e Restrições

O esquema relacional desacopla dados principais do catálogo de faturamento, usuários e limites de domínio de rastreamento. Todas as restrições são nomeadas explicitamente para evitar identificadores dinâmicos gerados pelo servidor, garantindo a manutenibilidade:

* `dbo.titles`: Catálogo de conteúdo contendo metadados de filmes e séries.
* `dbo.plans`: Gestão do portfólio de produtos e arquitetura de precificação.
* `dbo.users`: Dados de autenticação do cliente e credenciais.
* `dbo.subscriptions`: Tabela fato que rastreia vínculos contratuais e métricas de Churn.
* `dbo.watch_history`: Log de engajamento do usuário projetado para processamento analítico.

> ⚠️ **Status:** Esta é a infraestrutura da **Release 2.0.0**. O schema está totalmente definido e restrito. A população de dados (seeding) via pipelines Python e o dashboarding analítico estão agendados para a **Release 3.0.0**.

---

## 🛠️ Administração de Banco de Dados (DBA) e Infraestrutura

A confiabilidade do motor do banco de dados baseia-se em scripts de automação de infraestrutura localizados em `04_database_administration/`:

### 1. Manutenção Automatizada (`02_maintenance/`)

Arquitetura de procedures centralizada e autônoma:

* **`sp_RunMaintenance`:** Utiliza SQL Dinâmico e Cursors para identificar a fragmentação em tempo real. Executa automaticamente `ALTER INDEX ... REORGANIZE` (fragmentação entre 5-30%) ou `REBUILD` (>30%), e dispara `UPDATE STATISTICS ... WITH FULLSCAN` para manter o Query Optimizer eficiente.
* **`sp_DBHealthCheck`:** Monitoramento proativo que avalia *Wait Stats* e latência de I/O, registrando eventos críticos na tabela `dbo.maintenance_log`.
* **Log:** Tabela `dbo.maintenance_log` centralizada, capturando o status de sucesso/erro de todas as tarefas de manutenção e saúde.

### 2. Concorrência e Performance (`01_security/`)

* **RCSI:** `READ_COMMITTED_SNAPSHOT ON` aplicado para garantir operações de leitura sem bloqueio (*non-blocking*), essencial para relatórios no Power BI e ingestão de alta concorrência.

### 3. Recuperação de Desastres (`03_disaster_recovery/`)

* **Armazenamento em Docker:** Rotinas de backup configuradas para ambientes de sistema de arquivos isolados.
* **Resiliência:** Inclui scripts de simulação automatizados para verificar a integridade dos dados via `RESTORE VERIFYONLY` e `RESTORE DATABASE ... WITH REPLACE`.

---

## ⚙️ Guia de Deploy e Execução (Release 2.0.0)

1. **Ambiente:** Certifique-se de que o SQL Server esteja rodando em um container Docker.
2. **Deploy do Schema:** Execute os scripts em `01_database_engineering/` para construir a estrutura do `hbo_db`.
3. **Configuração Administrativa:** Execute as configurações de segurança (RCSI) e faça o deploy das procedures de manutenção em `04_database_administration/`.
4. **Validação:** Utilize as procedures para verificar a saúde do ambiente e preparar para a futura ingestão de dados.

> 🚀 **Nota de Evolução:** A ingestão automatizada de dados via Python/Pandas é o objetivo principal da **Release 3.0.0**, o que permitirá recursos analíticos completos e o consumo de views.