# 🎬 HBO Max - Infraestrutura de Banco de Dados e Engenharia SQL

[![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/pt-br/sql-server/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)
[![Kaggle](https://img.shields.io/badge/Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)](https://www.kaggle.com/)

Modelagem de dados, pipeline de ingestão e administração de um sistema de banco de dados relacional baseado na plataforma de streaming **HBO Max**. Este projeto simula um ambiente de produção de nível corporativo, cobrindo desde a aplicação rigorosa de esquemas DDL até otimização avançada de consultas, defragmentação física de índices e estratégias de recuperação de desastres (Disaster Recovery).

---

## 🧭 Arquitetura do Projeto e Estrutura de Diretórios

O repositório segue um pipeline de implantação sequencial e numerado estrito para garantir a previsibilidade da evolução do banco de dados:

```text
MEU-PORTFOLIO-DB/
├── 01_database_engineering/
│   ├── 01_ddl_structure/             # Arquitetura de esquema e restrições explícitas
│   ├── 02_dml_initial_load/          # Orquestração de massa de testes (seeds) e pipelines de carga
│   ├── 03_analytical_views/          # Business Intelligence e visões analíticas de KPIs
│   ├── 04_performance_tuning/         # Defragmentação de índices e otimização de estatísticas
│   ├── 05_database_security/         # Controle de acesso por privilégio mínimo e RBAC
│   └── 06_backup_recovery/           # Rotinas de backup e disaster recovery isoladas via Docker
├── 02_data_pipeline_python/          # Geração automatizada de dados e ingestão
└── 03_analytics_dashboard/           # Modelo semântico do Power BI e visualização de dados

```

---

## 🗂️ Modelagem de Dados e Aplicação de Restrições

O esquema relacional desacopla os dados principais do catálogo das fronteiras de domínio de faturamento, usuários e rastreamento. Todas as restrições (constraints) são nomeadas explicitamente para evitar identificadores dinâmicos gerados pelo servidor, garantindo a manutenibilidade:

* `dbo.titles`: Esquema do catálogo de conteúdo contendo metadados de filmes e séries. Chave primária aplicada via `PK_titles`.
* `dbo.plans`: Gerenciamento de portfólio de produtos e arquitetura de preços. Chave primária aplicada via `PK_plans_id`.
* `dbo.users`: Dados de autenticação de clientes e credenciais. Regulamentado por `PK_users_id` e regras de negócio únicas.
* `dbo.subscriptions`: Tabela fato que rastreia vínculos contratuais, logs de assinatura de usuários e métricas de Churn. Vinculada rigidamente via `FK_subscriptions_users` and `FK_subscriptions_plans`.
* `dbo.watch_history`: Log de engajamento do usuário projetado para processamento analítico e motores de recomendação. Vinculado rigidamente via `FK_watch_history_users` and `FK_watch_history_titles`.

> 💾 **Fonte dos Dados:** Os metadados principais de mídia utilizam o dataset público [HBO Max TV Shows and Movies (Victor Soeiro - Kaggle)](https://www.kaggle.com/datasets/victorsoeiro/hbo-max-tv-shows-and-movies). A fonte bruta é processada e mapeada para se ajustar a micro-tipos de dados do SQL Server (ex: `SMALLINT` para anos, `TINYINT` para durações/temporadas) para minimizar o consumo de memória.

---

## 📊 Visões Analíticas e Business Intelligence

As visões de banco de dados (Views) dentro de `03_analytical_views/` são projetadas com argumentos SARGáveis, evitando varreduras completas de tabelas (full-table scans) e utilizando a cobertura de índices:

### Desempenho do Catálogo e Engajamento

* `001_top_10_imdb_titles.sql`: Identifica conteúdos de alto nível aplicando um filtro de limite para mitigar o viés de baixo volume de votos (`imdb_votes > 1000`).
* `002_genre_coexistence.sql`: Trata e analisa dados de arrays semiestruturados da origem para isolar nichos específicos e correlação de gêneros.
* `003_content_performance_insights.sql` e `005_average_duration_by_type.sql`: Análise métrica comparativa avaliando o comportamento do tempo de execução de filmes vs. séries e distribuições de notas para direcionar o investimento em produções originais.
* `004_release_volume_by_year.sql`: Rastreia a expansão histórica anual do catálogo.

### Retenção e Saúde Financeira

* `006_user_history_report.sql`: Consolida o histórico de streaming dos usuários com rotinas complexas de sanitização de strings.
* `007_revenue_by_plan.sql`: Mede a receita bruta total acumulada dividida por tipo de produto.
* `008_subscriptions_status.sql`: Monitora o volume de clientes Ativos vs. Cancelados para calcular a taxa de evasão (Churn Rate) da plataforma.

---

## 🛠️ Administração de Banco de Dados (DBA) e Infraestrutura

A confiabilidade do motor principal do banco de dados depende de scripts de automação de infraestrutura:

### 1. Manutenção de Fragmentação de Índices (`04_performance_tuning/`)

* **Diagnóstico:** Avalia a degradação física da alocação de páginas utilizando a Visão de Gerenciamento Dinâmico (DMV) `sys.dm_db_index_physical_stats`.
* **Mitigação:** Automatiza a correção baseada em políticas: Executa `ALTER INDEX ... REORGANIZE` para fragmentação moderada (5% a 30%) com zero downtime, e aciona rotinas de `ALTER INDEX ... REBUILD` para fragmentação crítica (> 30%) para comprimir e redistribuir as páginas de dados do zero.

### 2. Balanceamento de Custo do Otimizador (`04_performance_tuning/`)

* **Auditoria:** Varre os metadados através de `sys.stats` combinado com a função `STATS_DATE()` para monitorar a atualização das estatísticas do otimizador.
* **Execução:** Dispara rotinas de `UPDATE STATISTICS ... WITH FULLSCAN` para recalcular os histogramas de distribuição de dados, garantindo que o Query Optimizer gere planos de execução rápidos e evite varreduras intensivas de CPU.

### 3. Controle de Acesso Baseado em Regras - RBAC (`05_database_security/`)

* **Privilégio Mínimo:** Isola completamente a manipulação do banco de dados criando logins de aplicação dedicados e de baixo privilégio.
* **Permissões Granulares:** Restringe as contas de serviço de pipeline (ex: contexto de integração do Pandas) estritamente a escopos explícitos de Linguagem de Manipulação de Dados (DML) como `SELECT` e `INSERT`, prevenindo brechas de segurança.

### 4. Recuperação de Desastres e Resiliência (`06_backup_recovery/`)

* **Armazenamento Direcionado ao Docker:** Realiza o backup de todo o ambiente em um arquivo `.bak` comprimido dentro do sistema de arquivos Linux isolado do container Docker do SQL Server.
* **Simulação de Desastre:** Script automatizado que encerra processos ativos usando `SINGLE_USER WITH ROLLBACK IMMEDIATE`, elimina o banco de dados com `DROP DATABASE` e valida a integridade executando uma recuperação instantânea através de `RESTORE DATABASE ... WITH REPLACE`.

---

## ⚙️ Guia de Implantação e Execução

1. **Suba a infraestrutura:** Certifique-se de que o motor local do Docker esteja executando o SQL Server.
2. **Gere o Esquema do Banco:** Execute os scripts dentro de `01_ddl_structure/` em ordem cronológica para construir o `hbo_db` e suas restrições.
3. **Ingira os Catálogos e Rode as Seeds:** Importe o dataset processado para a tabela `dbo.titles` e execute os arquivos em `02_dml_initial_load/` para gerar a massa de dados de teste.
4. **Execute a Manutenção e Análises:** Implante as visões analíticas e execute os arquivos de otimização e controle de segurança conforme necessário para validação.