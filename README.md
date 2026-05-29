# 🎬 HBO Max - Infraestrutura de Dados e Engenharia SQL

[![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/pt-br/sql-server/)
[![DBeaver](https://img.shields.io/badge/DBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)](https://dbeaver.io/)
[![Kaggle](https://img.shields.io/badge/Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)](https://www.kaggle.com/)

Modelagem, ingestão e administração de um banco de dados relacional baseado na plataforma **HBO Max**. O projeto simula o ambiente de produção de um serviço de streaming, cobrindo desde a estruturação das tabelas até rotinas avançadas de tunning, manutenção de índices e otimização de consultas (_Query Optimizer_).

---

## 🧭 Estrutura do Projeto

O repositório está organizado de forma sequencial para implantação e gerenciamento do banco:

- **`01_ddl_estrutura/`**: Criação do banco `hbo_db`, tabelas, restrições de integridade e chaves primárias/estrangeiras.
- **`02_dml_dados/`**: Scripts de carga e geração de massa de testes (planos, usuários, contratos de assinaturas e histórico).
- **`03_dql_consultas/`**: Queries analíticas para extração de KPIs de negócio (faturamento, retenção e catálogo).
- **`04_performance_manutencao/`**: Rotinas de DBA para diagnóstico e correção de fragmentação e atualização de estatísticas.

---

## 🗂️ Modelagem de Dados

O desenho da arquitetura separa o catálogo de conteúdo das regras de negócio de faturamento e usuários:

- `dbo.titles`: Catálogo de filmes e séries integrados via dataset do Kaggle.
- `dbo.planos`: Portfólio de produtos e precificação da plataforma.
- `dbo.usuarios`: Cadastro de clientes e credenciais de acesso.
- `dbo.assinaturas`: Tabela fato que gerencia os contratos vigentes, histórico de planos e controle de cancelamentos (Churn).
- `dbo.historico_visualizacao`: Registro de consumo de conteúdo por usuário para motores de recomendação.

> 💾 **Fonte dos Dados:** O catálogo bruto utiliza o dataset público [HBO Max TV Shows and Movies (Victor Soeiro - Kaggle)](https://www.kaggle.com/datasets/victorsoeiro/hbo-max-tv-shows-and-movies). O arquivo `titles.csv` deve ser importado diretamente para a tabela `dbo.titles`.

---

## 📊 Engenharia de Consultas & Insights (DQL)

As consultas foram escritas focando em baixo custo computacional, evitando buscas _full-table_ e resolvendo dores reais de tomada de decisão:

### Catálogo e Engajamento

- **`001_top_10_titulos_imdb.sql`**: Filtro de relevância para identificar os principais conteúdos da plataforma, ignorando vieses por baixo volume de votos (`imdb_votes > 1000`).
- **`002_analise_generos_likes.sql`**: Tratamento de dados semiestruturados do CSV para isolar nichos específicos (ex: _Mockumentaries_).
- **`003_analise_insights.sql`** e **`005_media_duracao_por_tipo.sql`**: Análise comparativa (filmes vs. séries) de notas médias e tempo de tela para direcionar investimentos em produções originais.
- **`004_volume_lancamentos_ano.sql`**: Histórico de crescimento anual do catálogo.

### Finanças e Retenção

- **`006_relatorio_historico_usuarios.sql`**: Consolidação do comportamento de consumo individual com tratamento de strings nulas/vazias do CSV (`ISNULL(NULLIF(..., '[]'), 'Não especificado')`).
- **`007_faturamento_por_plano.sql`**: Relatório de receita total acumulada por tipo de produto através de relacionamentos diretos.
- **`008_status_assinaturas.sql`**: Volumetria de usuários ativos vs. cancelados para cálculo de taxa de evasão (Churn Rate).

---

## 🛠️ Performance & Administração (DBA)

A pasta `04_performance_manutencao/` contém rotinas de infraestrutura para garantir a escalabilidade do banco de dados:

### 1. Saúde Física (Fragmentação de Índices)

- **Diagnóstico:** Monitoramento via `sys.dm_db_index_physical_stats` para identificar degradação física dos índices após operações de escrita/exclusão.
- **Correção:** Aplicação de `ALTER INDEX ... REORGANIZE` para fragmentações moderadas (5% a 30%) sem _downtime_, e `ALTER INDEX ... REBUILD` para estados críticos (acima de 30%) com reestruturação completa de páginas.

### 2. Saúde Lógica (Estatísticas do Otimizador)

- **Auditoria:** Mapeamento da idade das estatísticas que alimentam o _Query Optimizer_ através de `sys.stats` e `STATS_DATE`.
- **Atualização:** Execução de `UPDATE STATISTICS ... WITH FULLSCAN` para forçar a recontagem precisa do histograma de dados, evitando planos de execução ruins e picos de CPU.

---

## ⚙️ Como Executar

1. Crie a estrutura do banco rodando os scripts da pasta `01_ddl_estrutura/`.
2. Baixe o `titles.csv` no Kaggle e importe os dados para a tabela `dbo.titles` via assistente do seu cliente SQL (DBeaver/VS Code).
3. Execute os scripts da pasta `02_dml_dados/` para gerar a massa de testes automatizada (1000 usuários e assinaturas).
4. Utilize as consultas das pastas `03_dql_consultas/` e `04_performance_manutencao/` para análises e testes de tunning.
