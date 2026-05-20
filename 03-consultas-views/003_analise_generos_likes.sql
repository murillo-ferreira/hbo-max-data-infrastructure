/*
  OBJETIVO: Filtrar conteúdos que pertençam estritamente à combinação de múltiplos gêneros selecionados, sem interferência de outras categorias.
  PERGUNTA DE NEGÓCIO: Quais títulos do catálogo atendem puramente ao cruzamento de nichos específicos (ex: Documentários de Comédia/Mockumentaries)?
*/

USE hbo_db;
GO

SELECT
    title,
    genres
FROM titles
WHERE genres IN (
    '[''comedy'', ''documentation'']', 
    '[''documentation'', ''comedy'']'
)
ORDER BY title;
GO