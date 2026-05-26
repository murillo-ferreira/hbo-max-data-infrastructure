# 🎬 HBO Max - Infraestrutura de Dados e Engenharia SQL

[![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/pt-br/sql-server/)
[![DBeaver](https://img.shields.io/badge/DBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)](https://dbeaver.io/)
[![Kaggle](https://img.shields.io/badge/Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)](https://www.kaggle.com/)

Este repositório contém o desenvolvimento completo da infraestrutura de banco de dados para uma plataforma de streaming inspirada na **HBO Max**. O projeto cobre desde a modelagem das tabelas e ingestão de dados reais do catálogo até rotinas avançadas de tunning, manutenção de índices e atualização do otimizador de consultas (Query Optimizer).

---

## 📂 Organização do Repositório

O projeto foi estruturado seguindo uma esteira lógica de implantação e administração de um banco de dados relacional:

- **`01_ddl_estrutura/`**: Scripts de criação do banco `hbo_db`, tabelas, chaves primárias e restrições de integridade (`FOREIGN KEY`).
- **`02_dml_dados/`**: Cargas de dados para tabelas de apoio (planos, usuários cadastrados, contratos de assinaturas e histórico de player).
- **`03_dql_consultas/`**: Queries analíticas para extração de insights de negócio (faturamento, retenção, comportamento de consumo e análise de catálogo).
- **`04_performance_manutencao/`**: Rotinas de administração de banco de dados (DBA) com scripts de diagnóstico e correção de fragmentação física e lógica.

---

## 📐 Modelagem do Banco (hbo_db)

A arquitetura do banco foi desenhada para suportar uma operação de streaming, separando o catálogo de conteúdo das regras de negócio de usuários e faturamento:

- `dbo.titles`: Títulos do catálogo (filmes e séries) integrados a partir de dados reais do Kaggle.
- `dbo.planos`: Portfólio de produtos da plataforma e precificação.
- `dbo.usuarios`: Cadastro de clientes e credenciais de acesso.
- `dbo.assinaturas`: Tabela fato que gerencia os contratos vigentes, histórico de planos por cliente e controle de cancelamentos (Churn).
- `dbo.historico_visualizacao`: Registro de consumo de conteúdo por usuário para alimentar motores de recomendação.

> 💾 **Origem do Catálogo:** Os dados brutos foram extraídos do dataset público [HBO Max TV Shows and Movies (Victor Soeiro - Kaggle)](https://www.kaggle.com/datasets/victorsoeiro/hbo-max-tv-shows-and-movies). Para rodar os scripts, é necessário importar o arquivo `titles.csv` para a tabela `dbo.titles`.

---

## 🛠️ Engenharia de Consultas & Insights (DQL)

As consultas foram desenvolvidas focando em performance (evitando buscas full-table e I/O desnecessário) e respondem a cenários reais de tomada de decisão:

### Métricas de Catálogo e Engajamento

- **`001_top_10_titulos_imdb.sql`**: Filtro de relevância para identificar os títulos mais bem avaliados, ignorando vieses por baixo volume de votos (`imdb_votes > 1000`).
- **`002_analise_generos_likes.sql`**: Tratamento de dados semiestruturados do CSV para isolar nichos específicos (ex: _Mockumentaries_).
- **`003_analise_insights.sql`** e **`005_media_duracao_por_tipo.sql`**: Análise comparativa entre filmes e séries (notas médias IMDb/TMDb e tempo de tela) para direcionar investimentos em produções originais.
- **`004_volume_lancamentos_ano.sql`**: Linha do tempo do crescimento do catálogo.

### Finanças e Retenção de Clientes

- **`006_relatorio_historico_usuarios.sql`**: Consolidação do comportamento de consumo individual, aplicando tratamento de strings corrompidas do CSV (`ISNULL(NULLIF(..., '[]'), 'Não especificado')`).
- **`007_faturamento_por_plano.sql`**: Relatório de receita total acumulada por tipo de produto através de relacionamentos diretos, reduzindo o custo computacional da query.
- **`008_status_assinaturas.sql`**: Monitoramento da saúde da base (Usuários Ativos vs. Cancelados) para cálculo de taxa de evasão.

---

## ⚡ Performance e Administração de Banco (DBA)

A pasta `04_performance_manutencao/` simula a atuação interna de suporte à infraestrutura quando o volume de dados cresce e afeta a experiência do usuário final:

### 1. Saúde Física do Disco (Fragmentação)

- **Diagnóstico:** Varredura na visualização de sistema `sys.dm_db_index_physical_stats` para identificar o nível de degradação física dos índices após rotinas pesadas de gravação/exclusão.
- **Correção Dinâmica:** Aplicação de comandos `ALTER INDEX ... REORGANIZE` para fragmentações moderadas (entre 5% e 30%) sem travar as tabelas em produção, e `ALTER INDEX ... REBUILD` para estados críticos (acima de 30%) com reestruturação completa de páginas.

### 2. Saúde Lógica

- **Auditoria:** Consulta baseada em `sys.stats` e na função `STATS_DATE` para mapear a idade das estatísticas que alimentam o Otimizador de Consultas do SQL Server.
- **Atualização de Planos:** Comandos de `UPDATE STATISTICS` utilizando a cláusula `WITH FULLSCAN` para forçar a recontagem precisa do histograma de dados, evitando planos de execução ruins e picos desnecessários de CPU.

---

## 🚀 Como Executar

1. Crie o banco e a estrutura de tabelas executando os scripts da pasta `01_ddl_estrutura/`.
2. Baixe o arquivo `titles.csv` no link do Kaggle e importe os dados diretamente para a tabela `dbo.titles` usando o assistente de importação do seu cliente SQL (DBeaver/VS Code).
3. Execute os scripts da pasta `02_dml_dados/` para gerar a massa de testes de usuários e assinaturas.
4. Fique livre para rodar as análises da pasta `03_dql_consultas/` e os testes de performance da pasta `04_performance_manutencao/`.
