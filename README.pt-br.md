# 🎬 HBO Max - Engenharia de Dados & Infraestrutura de Banco de Dados SQL

Modelagem de dados, pipeline de ingestão transacional e administração de um sistema de banco de dados relacional baseado na plataforma de streaming **HBO Max**. Este projeto simula um ambiente de produção em nível corporativo, cobrindo desde a aplicação rigorosa de schemas DDL e rastreamento de histórico via SCD Tipo 2 até Stored Procedures transacionais, simulações automatizadas de comportamento de usuários em Python e rotinas de manutenção DBA.

---

## 🧭 Arquitetura do Projeto & Estrutura de Diretórios

O repositório segue um layout de diretórios estrito e modular, mapeando a arquitetura do banco de dados, fluxos de trabalho de ingestão e tarefas administrativas:

```text
hbo-max-data-infrastructure/
├── 01_database_engineering/          # Schemas, procedures, DBA e configuração inicial
│   ├── 01_ddl_structure/             # Definição das tabelas principais (users, subscriptions, titles, etc.)
│   ├── 02_stored_procedures/         # Lógica transacional (sp_CloseSubscription, fluxos de inserção)
│   ├── 03_analytical_views/          # Views SQL (.gitkeep - placeholder para a Release 4.0.0)
│   ├── 04_database_administration/   # Infraestrutura & Ferramentas de DBA
│   │   ├── 01_security/              # Roles de segurança, permissões, logins e auditoria
│   │   ├── 02_maintenance/           # Configuração de RCSI, DDL de log e procedures de manutenção
│   │   │   └── procedures/           # Procedures automatizadas de DBA (sp_RunMaintenance, sp_DBHealthCheck)
│   │   └── 03_disaster_recovery/     # Scripts de Backup & Restore
│   └── 06_inital_setup/              # Carga inicial SQL (001_load_plans.sql, catálogo legacy)
├── 02_data_pipeline_python/          # Engine de ingestão & pipeline de geração sintética
│   ├── config/                       # Credenciais do banco & conexão SQLAlchemy (database.py)
│   ├── generators/                   # Geradores de eventos (users.py, subscriptions.py, watch_history.py)
│   ├── lib/                          # Módulos do pipeline (api_client.py, logger.py, transform.py)
│   ├── scripts/                      # Scripts de execução de carga (load.py)
│   ├── sql/tables/                   # DDL de infraestrutura do pipeline (dbo.pipeline_logs.sql)
│   └── main.py                       # Ponto de entrada e orquestração do pipeline
├── requirements.txt                  # Dependências Python
├── README.md                         # Documentação principal (Inglês)
└── README.pt-br.md                   # Documentação em Português

```

> ℹ️ **Nota sobre `03_analytical_views/`:** Este diretório atualmente contém um arquivo `.gitkeep` como placeholder. As views analíticas e os modelos semânticos do Power BI serão implantados na próxima release, junto com a integração do dashboard.

---

## 🚀 Visão Geral da Release 3.0.0: Ciclo de Vida do Usuário & Engine de Pipeline

A Release **3.0.0** introduz um ecossistema dinâmico de geração e ingestão de dados. Em vez de dados fictícios estáticos, o sistema simula o comportamento real dos usuários (cadastros, trocas de plano com upgrades/downgrades, cancelamentos e consumo de conteúdo), garantindo integridade temporal, financeira e relacional.

### 1. Histórico Relacional & Rigor Transacional (SQL Server / OLTP)

* **Dimension de Alteração Lenta (SCD Tipo 2):** Implementada na tabela `dbo.subscriptions` utilizando controle por `begin_date` e `end_date`. Esse design permite reconstruir o estado histórico exato para determinar a cobertura de plano de qualquer cliente em qualquer ponto do tempo.
* **Stored Procedures Atômicas (`02_stored_procedures/`):** Procedures transacionais (como `sp_CloseSubscription` e rotinas de carga) encapsuladas em blocos `BEGIN TRANSACTION ... COMMIT TRANSACTION`.
* **Tratamento Defensivo de Exceções:** Blocos `TRY...CATCH` integrados avaliando `XACT_STATE()` para rollbacks limpos, disparando erros contextuais explícitos via `THROW` para evitar estados parciais ou corrompidos no banco.

### 2. Arquitetura do Pipeline & Automação Modular (`02_data_pipeline_python/`)

O ecossistema ETL em Python é desacoplado em camadas especializadas de execução:

* **Orquestração (`main.py`):** Ponto de entrada central que executa a sequência completa do pipeline (carga de catálogos, população de usuários, modificações contratuais e ingestão do histórico de consumo).
* **Geradores de Domínio (`generators/`):**
* `users.py`: Gera perfis de usuários com instâncias localizadas da biblioteca `Faker` e credenciais alinhadas ao domínio.
* `subscriptions.py`: Gerencia o ciclo de vida contratual em múltiplas fases, impondo uma **janela mínima de retenção de 30 dias** antes de eventos de upgrade ou churn.
* `watch_history.py`: Simula sessões de consumo, distribuição de dispositivos, tempo assistido e taxa de conclusão ($\ge 90\%$ de duração).


* **Bibliotecas Core (`lib/`):**
* `api_client.py`: Consome metadados reais de filmes/séries de fontes externas (TMDB API) para popular a tabela `dbo.titles`.
* `transform.py`: Executa conversões explícitas de tipo (`datetime` para `date`), validações de duração e sanitização de regras de negócio.
* `logger.py`: Logger centralizado enviando estados de execução e traces de erro para a tabela `dbo.pipeline_logs`.


* **Conexão com Banco de Dados (`config/database.py`):** Configura pools de conexão via SQLAlchemy e `pyodbc`.

---

## 🗂️ Arquitetura do Schema Principal

* `dbo.titles`: Catálogo de conteúdo armazenando metadados de filmes e séries, gêneros e durações (`runtime`).
* `dbo.plans`: Portfolio de produtos e estratégia de preços (`Básico com Anúncios`, `Padrão`, `Premium`).
* `dbo.users`: Perfis de autenticação e metadados de conta dos usuários.
* `dbo.subscriptions`: Tabela Fato/Dimensão aplicando o controle de estado contratual via **SCD Tipo 2** e métricas de churn.
* `dbo.watch_history`: Log fato de alto volume de engajamento rastreando sessões, dispositivos, tempo assistido e conclusão (`completed BIT`).
* `dbo.pipeline_logs`: Trilha de auditoria de execução do pipeline armazenando timestamps, status, contagem de linhas afetadas e exceções.

---

## 🛠️ Administração de Banco de Dados (DBA) & Infraestrutura

* **Segurança & Auditoria (`04_database_administration/01_security/`):** Implementação completa de RBAC, incluindo roles de aplicação (`001_create_roles.sql`), permissões explícitas (`002_grant_permissions.sql`), logins dedicados (`003_create_logins.sql`) e configurações de auditoria do servidor (`004_audit_setup.sql`).
* **Manutenção Automatizada & Concorrência (`04_database_administration/02_maintenance/`):**
* **Configuração do RCSI:** `READ_COMMITTED_SNAPSHOT` habilitado no `hbo_db` para garantir operações de leitura não-bloqueantes durante execuções de carga massiva.
* **Infraestrutura de Logs:** Tabela centralizada `dbo.maintenance_log` armazenando métricas de health check e resultados de manutenção de índices.
* **Procedures Proativas (`procedures/`):** Contém a `sp_RunMaintenance` para desfragmentação de índices (`REORGANIZE` entre 5–30%, `REBUILD` >30% e `UPDATE STATISTICS ... WITH FULLSCAN`) e a `sp_DBHealthCheck` para monitoramento da telemetria do sistema.


* **Disaster Recovery (`03_disaster_recovery/`):** Rotinas de backup adaptadas para contêineres e verificadas via `RESTORE VERIFYONLY` e `RESTORE DATABASE ... WITH REPLACE`.

---

## ⚙️ Guia de Implantação e Execução

1. **Configuração do Ambiente:**
* Instale as dependências Python: `pip install -r requirements.txt`
* Configure as variáveis de ambiente em `02_data_pipeline_python/.env` (incluindo o Token Bearer da API do TMDB).


2. **Implantação da Arquitetura SQL & Segurança:**
* Execute os DDLs de estrutura em `01_database_engineering/01_ddl_structure/`.
* Implante as Stored Procedures em `01_database_engineering/02_stored_procedures/`.
* Execute os scripts de segurança e auditoria sequencialmente em `01_database_engineering/04_database_administration/01_security/`:
1. `001_create_roles.sql`
2. `002_grant_permissions.sql`
3. `003_create_logins.sql`
4. `004_audit_setup.sql`


* Implante os scripts de manutenção, RCSI, tabela de log e procedures administrativas em `01_database_engineering/04_database_administration/02_maintenance/`.
* Implante a tabela de auditoria do pipeline a partir de `02_data_pipeline_python/sql/tables/dbo.pipeline_logs.sql`.
* Execute o script de carga inicial de planos em `01_database_engineering/06_inital_setup/001_load_plans.sql`.


3. **Execução do Orquestrador do Pipeline:**
```bash
python 02_data_pipeline_python/main.py

```


4. **Auditoria da Execução:**
* Consulte a tabela `dbo.pipeline_logs` para revisar o status da execução, contagem de linhas e traces de auditoria de cada etapa do pipeline da dbo.titles.