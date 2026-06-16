# 🎬 HBO Max - Infraestrutura de Banco de Dados e Engenharia SQL

Modelagem de dados, pipeline de ingestão e administração de um sistema de banco de dados relacional baseado na plataforma de streaming **HBO Max**. Este projeto simula um ambiente de produção de nível corporativo, cobrindo desde a aplicação rigorosa de esquemas DDL até otimização avançada de consultas, defragmentação física de índices e estratégias de recuperação de desastres (Disaster Recovery).

---

## 🧭 Arquitetura do Projeto e Estrutura de Diretórios

O repositório segue um pipeline de implantação sequencial e numerado estrito para garantir a previsibilidade da evolução do banco de dados:

```text
hbo-max-data-infrastructure/
├── 01_database_engineering/
│   ├── 01_ddl_structure/             # Arquitetura de esquema e restrições explícitas
│   ├── 02_stored_procedures/         # Lógica encapsulada de ingestão e tratamento de erros
│   ├── 03_dml_initial_load/          # Orquestração de massa de testes (seeds) e pipelines de carga
│   ├── 04_analytical_views/          # Business Intelligence e visões analíticas de KPIs
│   ├── 05_database_security/         # Controle de acesso por privilégio mínimo e RBAC
│   ├── 06_backup_recovery/           # Rotinas de backup e disaster recovery isoladas via Docker
│   └── 07_performance_tuning/        # Defragmentação de índices e otimização de estatísticas
├── 02_data_pipeline_python/          # Geração automatizada de dados e ingestão
└── 03_analytics_dashboard/           # Modelo semântico do Power BI e visualização de dados

```

---

## 🗂️ Modelagem de Dados e Aplicação de Restrições

O esquema relacional desacopla os dados principais do catálogo das fronteiras de domínio de faturamento, usuários e rastreamento. Todas as restrições (constraints) são nomeadas explicitamente para evitar identificadores dinâmicos gerados pelo servidor, garantindo a manutenibilidade:

* `dbo.titles`: Esquema do catálogo de conteúdo contendo metadados de filmes e séries. Chave primária aplicada via `PK_titles`.
* `dbo.plans`: Gerenciamento de portfólio de produtos e arquitetura de preços estruturada em **BRL (R$)**. Chave primária aplicada via `PK_plans_id`.
* `dbo.users`: Dados de autenticação de clientes e credenciais. Regulamentado por `PK_users_id` e regras de negócio únicas.
* `dbo.subscriptions`: Tabela fato que rastreia vínculos contratuais, logs de assinatura de usuários e métricas de Churn. Vinculada rigidamente via `FK_subscriptions_users` and `FK_subscriptions_plans`.
* `dbo.watch_history`: Log de engajamento do usuário projetado para processamento analítico e motores de recomendação. Vinculado rigidamente via `FK_watch_history_users` and `FK_watch_history_titles`.

> 💾 **Fonte dos Dados e Seeds:** Os metadados principais de mídia utilizam o dataset público [HBO Max TV Shows and Movies (Victor Soeiro - Kaggle)](https://www.google.com/search?q=https%3A%2F%2Fwww.kaggle.com%2Fdatasets%2Fvictorsoeiro%2Fhbo-max-tv-shows-and-movies). A fonte bruta é processada e mapeada para se ajustar a micro-tipos de dados do SQL Server (ex: `SMALLINT` para anos, `TINYINT` para durações/temporadas) para minimizar o consumo de memória. Parâmetros iniciais, regras de preços e lookups dimensionais são provisionados via seeds estáticos dentro de `03_dml_initial_load/`.

---

## ⚡ Programabilidade e Tratamento de Erros Robusto

A camada de aplicação (motores de ingestão Python) não envia queries brutas diretamente para as tabelas. As interações são intermediadas por **Stored Procedures** em `02_stored_procedures/`:

* **Ingestão Idempotente (`dbo.sp_UpsertTitles`):** Utiliza o comando `MERGE` protegido por `WITH (HOLDLOCK)` para realizar inserções ou atualizações de catálogo de forma atômica, evitando duplicidade em cargas incrementais da API.
* **Resiliência em Simulações (`dbo.sp_UpsertUsers`, `dbo.sp_UpsertSubscriptions`):** Projetadas para fluxos de automação com bibliotecas Faker, garantindo a integridade das transações mesmo sob alta carga de dados sintéticos.
* **Tratamento de Falhas (`dbo.sp_InsertWatchHistory`):** Arquitetura baseada em `BEGIN TRY...BEGIN CATCH` monitorada pela função `XACT_STATE()`. Em caso de violação de chaves estrangeiras ou formatos inválidos, a procedure dispara um `ROLLBACK TRANSACTION` seletivo e retorna uma mensagem de diagnóstico via `PRINT`, permitindo que o pipeline Python continue operando sem interrupções críticas.

---

## 📊 Visões Analíticas e Business Intelligence

As visões de banco de dados (Views) dentro de `04_analytical_views/` são projetadas com argumentos SARGáveis, evitando varreduras completas de tabelas e utilizando a cobertura de índices:

### Desempenho do Catálogo e Engajamento

* `001_top_10_imdb_titles.sql`: Identifica conteúdos de alto nível aplicando um filtro de limite para mitigar o viés de baixo volume de votos (`imdb_votes > 1000`).
* `002_genre_coexistence.sql`: Trata e analisa dados de arrays semiestruturados da origem para isolar nichos específicos e correlação de gêneros.
* `003_content_performance_insights.sql` e `005_average_duration_by_type.sql`: Análise métrica comparativa avaliando o comportamento do tempo de execução de filmes vs. séries e distribuições de notas.
* `004_release_volume_by_year.sql`: Rastreia a expansão histórica anual do catálogo.

### Retenção e Saúde Financeira

* `006_user_history_report.sql`: Consolida o histórico de streaming dos usuários com rotinas complexas de sanitização de strings.
* `007_revenue_by_plan.sql`: Mede a receita bruta total acumulada dividida por tipo de produto.
* `008_subscriptions_status.sql`: Monitora o volume de clientes Ativos vs. Cancelados para calcular a taxa de evasão (Churn Rate) da plataforma.

---

## 🛠️ Administração de Banco de Dados (DBA) e Infraestrutura

A confiabilidade do motor principal depende de scripts de automação:

### 1. Manutenção de Fragmentação de Índices (`07_performance_tuning/`)

* **Diagnóstico:** Avalia a degradação física utilizando `sys.dm_db_index_physical_stats`.
* **Mitigação:** Automatiza a correção via `REORGANIZE` (5-30%) e `REBUILD` (>30%).

### 2. Balanceamento de Custo do Otimizador (`07_performance_tuning/`)

* **Auditoria:** Varre `sys.stats` e `STATS_DATE()` para monitorar a atualização do otimizador.
* **Execução:** Dispara `UPDATE STATISTICS ... WITH FULLSCAN` para recalcular histogramas.

### 3. Controle de Acesso (RBAC) (`05_database_security/`)

* **Privilégio Mínimo:** Cria logins de aplicação dedicados e de baixo privilégio.
* **Permissões Granulares:** Restringe contas de serviço estritamente a escopos de execução de Stored Procedures (`GRANT EXECUTE`), prevenindo acesso direto às tabelas.

### 4. Recuperação de Desastres (`06_backup_recovery/`)

* **Docker-Targeted Storage:** Backups em `.bak` dentro do sistema de arquivos do container.
* **Simulação de Desastre:** Script que elimina o banco e valida a integridade via `RESTORE DATABASE ... WITH REPLACE`.

---

## ⚙️ Guia de Implantação e Execução

1. **Suba a infraestrutura:** Certifique-se de que o motor Docker esteja executando o SQL Server.
2. **Gere o Esquema:** Execute os scripts dentro de `01_ddl_structure/` em ordem para construir o `hbo_db`.
3. **Compile a Programabilidade:** Implante os ativos em `02_stored_procedures/`.
4. **Ingira Catálogos e Seeds:** Execute os arquivos em `03_dml_initial_load/`.
5. **Valide:** Implante as visões analíticas e rotinas de manutenção conforme necessário.