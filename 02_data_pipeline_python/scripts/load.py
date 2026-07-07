import sqlalchemy
from config.database import create_engine

engine = create_engine()

def exec_load(procedure_data):
    with engine.begin() as conn:
        for record in procedure_data:
            try:
                conn.execute(
                    sqlalchemy.text("""
                        EXEC dbo.sp_UpsertTitles 
                            @tmdb_id = :tmdb_id,
                            @imdb_id = :imdb_id,
                            @title = :title,
                            @type = :type, 
                            @release_year = :release_year, 
                            @runtime = :runtime, 
                            @genres = :genres, 
                            @budget = :budget,
                            @origin_country = :origin_country,
                            @seasons = :seasons,
                            @vote_average = :vote_average,
                            @vote_count = :vote_count,
                            @popularity = :popularity
                    """),
                    record
                )
            
            except Exception as e:
                print(f"Fatal error on TMDB ID {record.get('tmdb_id')}: {e}")
                raise