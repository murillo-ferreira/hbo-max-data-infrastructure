import sqlalchemy
from config.database import create_engine

engine = create_engine()

def exec_load(procedure_data):
    success_count = 0
    error_count = 0
    for record in procedure_data:
        try:
            with engine.begin() as conn:
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
            success_count += 1
        except Exception as e:
            error_count += 1
            print(f"Error loading record for tmdb_id {record.get('tmdb_id')}: {e}")
    
    print(f"Titles Load Completed: {success_count} success, {error_count} errors.")

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
                raise

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
                raise

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
                raise

def exec_watch_history(procedure_data):
    success_count = 0
    error_count = 0

    for record in procedure_data:
        try:
            with engine.begin() as conn:
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
            success_count += 1
        except Exception as e:
            error_count += 1
            print(f"Error loading record for user_id {record.get('user_id')}: {e}")

    print(f"Watch History Load Completed: {success_count} success, {error_count} errors.")