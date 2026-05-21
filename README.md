# 🎬 HBO Max Data Infrastructure & Analytics

[![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/pt-br/sql-server/)
[![DBeaver](https://img.shields.io/badge/DBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)](https://dbeaver.io/)
[![Kaggle](https://img.shields.io/badge/Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white)](https://www.kaggle.com/)

Este projeto simula a infraestrutura de banco de dados e a camada analítica de uma plataforma de streaming baseada na **HBO Max**. Ele abrange desde a modelagem conceitual, tratamento de integridade referencial até a criação de queries de inteligência de negócio (DQL) utilizando dados reais do catálogo.

---

## 📂 Fonte dos Dados (Dataset)

Os dados brutos do catálogo de filmes e séries utilizados neste projeto foram extraídos do Kaggle:
👉 [HBO Max TV Shows and Movies (Victor Soeiro)](https://www.kaggle.com/datasets/victorsoeiro/hbo-max-tv-shows-and-movies?resource=download)

_Nota: Para rodar o projeto, baixe o arquivo `titles.csv` do link acima._

---

## 🛠️ Tecnologias e Ferramentas

- **SGBD:** Microsoft SQL Server (Compatível com instâncias locais, Docker containers ou instâncias em nuvem)
- **IDE/Cliente SQL:** DBeaver / VS Code (SQL Server Extension)
- **Linguagem:** T-SQL (Transact-SQL)
- **Versionamento:** Git & GitHub (Seguindo o padrão _Conventional Commits_ e _Git Flow_)

---

## 📐 Modelagem e Arquitetura do Banco de Dados

O banco de dados `hbo_db` adota uma abordagem de modelagem corporativa, isolando os dados cadastrais das operações financeiras/transacionais por meio de uma tabela ponte.

### Tabelas Estruturadas:

- `dbo.titles`: Catálogo completo de filmes e séries (Origem: Dataset do Kaggle).
- `dbo.planos`: Catálogo de produtos com tipos de planos de assinatura e precificação.
- `dbo.usuarios`: Cadastro de informações pessoais e credenciais dos clientes.
- `dbo.assinaturas`: Tabela ponte (fato) que gerencia o histórico de contratos, vínculos de planos por usuário, datas de vigência e controle de status de assinatura.
- `dbo.historico_visualizacao`: Registra quais títulos foram assistidos por quais usuários, aplicando restrições rígidas de `FOREIGN KEY` para garantir a integridade referencial.

---

## 🚀 Como Executar o Projeto

1. **Preparar o Servidor:** Certifique-se de ter uma instância do **SQL Server** ativa (seja local via LocalDB/Windows Service, via Docker ou na Nuvem) e conectada ao seu cliente SQL (DBeaver/VS Code).
2. **Criar a Estrutura (DDL):** Execute os scripts contidos na pasta `01-ddl-estrutura/` para criar o banco `hbo_db`, as tabelas e as chaves estrangeiras.
3. **Ingestão do Catálogo (DML):** Baixe o dataset no link do Kaggle disponível acima e faça a importação do arquivo `titles.csv` diretamente para a tabela `dbo.titles` usando o assistente do seu cliente SQL.
4. **Popular Dados Complementares:** Execute os scripts da pasta `02-dml-dados/` para inserir os registros de planos, usuários, assinaturas vinculadas e históricos de teste.
5. **Executar as Análises:** Os scripts de consulta estão organizados na pasta `03-dql-consultas/`.

---

## 📊 Inteligência de Dados & Insights (DQL)

As consultas foram estruturadas para responder a perguntas reais de negócio, divididas por nível de complexidade e aplicando otimizações sêniores (uso explícito de schemas, aliases curtos e prevenção de I/O desnecessário):

### 1. Análise Exploratória e Filtros

- **Top 10 IMDb (`001_top_10_titulos_imdb.sql`):** Identifica os títulos mais bem avaliados pelo público, aplicando um filtro de relevância estatística (`imdb_votes > 1000`) para evitar viés de dados.
- **Isolamento de Gêneros (`002_analise_generos_likes.sql`):** Uma query cirúrgica que lida com dados semiestruturados do CSV para isolar estritamente nichos específicos como _Mockumentaries_ (Comédia + Documentário).

### 2. Agrupamentos e Métricas

- **Insights por Tipo de Conteúdo (`003_analise_insights.sql`):** Consolida o volume total de títulos e calcula a média comparativa de notas do IMDb e TMDb para responder quais formatos (filmes ou séries) performam melhor em engajamento e crítica.
- **Volume de Lançamentos por Ano (`004_volume_lancamentos_ano.sql`):** Análise temporal do crescimento do catálogo da plataforma ao longo do tempo.
- **Duração Média do Catálogo (`005_media_duracao_por_tipo.sql`):** Médias de tempo de reprodução segregadas por tipo de conteúdo para apoiar o time de originais.

### 3. Visão Relacional Avançada (JOINs & Data Cleansing)

- **Histórico de Consumo de Usuários (`006_relatorio_historico_usuarios.sql`):** Cruzamento do comportamento individual de consumo dos usuários. Trata inconsistências de strings vazias originadas no arquivo bruto (`'[]'`) utilizando o combo avançado de funções `ISNULL(NULLIF(t.genres, '[]'), 'Não especificado')`.
- **Faturamento por Categoria de Plano (`007_faturamento_por_plano.sql`):** Relatório de receita total acumulada por tipo de plano através de um `JOIN` relacional otimizado, omitindo tabelas desnecessárias para menor custo de processamento.
- **Métricas de Retenção e Saúde da Base (`008_status_assinaturas.sql`):** Monitoramento de saúde de clientes (Churn Rate) que agrupa e contabiliza o volume de usuários com planos ativos versus contratos cancelados.
