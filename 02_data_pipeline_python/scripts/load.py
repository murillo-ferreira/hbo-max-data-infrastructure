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

def exec_load_users(procedure_data):
    with engine.begin() as conn:
        for record in procedure_data:
            try:
                conn.execute(
                    sqlalchemy.text("""
                        EXEC dbo.sp_UpsertUsers
                            @name = :name,
                            @email = :email,
                            @date_created = :date_created
                    """),
                    record
                )
            
            except Exception as e:
                print(f"Couldn't load user on database: {e}")
                raise

def exec_load_subscriptions(procedure_data):
    with engine.begin() as conn:
        for record in procedure_data:
            try:
                conn.execute(
                    sqlalchemy.text("""
                        EXEC dbo.sp_InsertSubscription
                            @user_id = :user_id,
                            @plan_id = :plan_id,
                            @begin_date = :begin_date
                    """),
                    record
                )
            
            except Exception as e:
                print(f"Couldn't load subscription on database: {e}")

def exec_load_second_subscriptions(procedure_data):
    with engine.begin() as conn:
        for record in procedure_data:
            try:
                conn.execute(
                    sqlalchemy.text("""
                        EXEC dbo.sp_CloseSubscription
                            @user_id = :user_id,
                            @new_plan_id = :new_plan_id,
                            @new_begin_date = :new_begin_date,
                            @end_date = :end_date
                    """),
                    record
                )
            
            except Exception as e:
                print(f"Couldn't load second subscription on database: {e}")

def exec_load_churn_rate(procedure_data):
    with engine.begin() as conn:
        for record in procedure_data:
            try:
                conn.execute(
                    sqlalchemy.text("""
                        EXEC dbo.sp_ChurnRate
                            @user_id = :user_id,
                            @plan_id = :plan_id,
                            @begin_date = :begin_date,
                            @new_end_date = :end_date
                        """),
                        record
                    )

            except Exception as e:
                print(f"Couldn't cancel subscription: {e}")

def exec_watch_history(procedure_data):
    with engine.begin() as conn:
        for record in procedure_data:
            try:
                conn.execute(
                    sqlalchemy.text("""
                        EXEC dbo.sp_InsertWatchHistory
                            @user_id = :user_id,
                            @subscription_id = :subscription_id, 
                            @title_id = :title_id, 
                            @watched_at = :watched_at, 
                            @watch_duration = :watch_duration,
                            @device_type = :device_type,
                            @completed = :completed
                        """),
                        record
                    )

            except Exception as e:
                print(f"Couldn't load watch history on database: {e}")