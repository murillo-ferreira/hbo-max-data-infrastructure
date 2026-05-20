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

O banco de dados `hbo_db` foi desenhado para garantir a integridade do catálogo e o rastreio do comportamento dos usuários.

### Tabelas Estruturadas:

- `dbo.titles`: Catálogo completo de filmes e séries (Origem: Dataset do Kaggle).
- `dbo.planos`: Planos de assinatura disponíveis na plataforma.
- `dbo.usuarios`: Cadastro de clientes vinculados a um plano.
- `dbo.historico_visualizacao`: Tabela intermediária que registra quais títulos foram assistidos por quais usuários, aplicando restrições de `FOREIGN KEY` para garantir a integridade referencial.

---

## 🚀 Como Executar o Projeto

1. **Preparar o Servidor:** Certifique-se de ter uma instância do **SQL Server** ativa (seja local via LocalDB/Windows Service, via Docker ou na Nuvem) e conectada ao seu cliente SQL (DBeaver/VS Code).
2. **Criar a Estrutura (DDL):** Execute os scripts contidos na pasta `01-ddl-estrutura/` para criar o banco `hbo_db`, as tabelas e as chaves estrangeiras.
3. **Ingestão do Catálogo (DML):** Baixe o dataset no link do Kaggle disponível acima e faça a importação do arquivo `titles.csv` diretamente para a tabela `dbo.titles` usando o assistente do seu cliente SQL.
4. **Popular Dados Complementares:** Execute os scripts da pasta `02-dml-dados/` para inserir os registros de planos, usuários e históricos de teste.
5. **Executar as Análises:** Os scripts de consulta estão organizados na pasta `03-dql-consultas/`.

---

## 📊 Inteligência de Dados & Insights (DQL)

As consultas foram estruturadas para responder a perguntas reais de negócio, divididas por nível de complexidade:

### 1. Análise Exploratória e Filtros

- **Top 10 IMDb (`001_top_10_titulos_imdb.sql`):** Identifica os títulos mais bem avaliados pelo público, aplicando um filtro de relevância estatística (`imdb_votes > 1000`) para evitar viés de dados.
- **Isolamento de Gêneros (`002_analise_generos_likes`):** Uma query cirúrgica que lida com dados semiestruturados do CSV para isolar estritamente nichos específicos como _Mockumentaries_ (Comédia + Documentário).

### 2. Agrupamentos e Métricas (Em Desenvolvimento ⏳)

- **Insights por Tipo de Conteúdo (`003_analise_insights.sql`):** Consolida o volume total de títulos e calcula a média comparativa de notas do IMDb e TMDb para responder quais formatos (filmes ou séries) performam melhor em engajamento e crítica.
- **Volume de Lançamentos (`004_volume_lancamentos_ano`):** Análises temporais de lançamentos por ano.
- **Duração Média (`005_media_duracao_por_tipo`):** Médias de tempo de reprodução do catálogo.

### 3. Visão Relacional (JOINs) (Em Desenvolvimento ⏳)

- **Histórico de Usuários (`006_relatorio_historico_usuarios`):** Cruzamento de comportamento do usuário com o histórico de consumo.
- **Faturamento (`007_faturamento_por_plano`):** Relatório de faturamento por tipo de plano de assinatura.
