import sys
import pandas as pd
import random
from scripts.load import exec_load, exec_load_users, exec_load_subscriptions, exec_load_second_subscriptions, exec_load_churn_rate
from generators.users import fake_user_generator
from generators.subscriptions import fake_subscriptions_generator, second_fake_subscriptions_generator, get_eligible_churn_users, churn_rate_generator
from lib.logger import log
from config.database import create_engine
from sqlalchemy import text
from lib.transform import movies_df, tv_shows_df

engine = create_engine()

def get_existing_ids():
    with engine.connect() as conn:
        result = conn.execute(text("SELECT tmdb_id FROM dbo.titles"))
        return {row[0] for row in result}

def exec_pipeline(df:pd.DataFrame):
    total_valid_ids = 0
    last_valid_id = None

    try:
        if df.empty:
                print("No new data to process. All database records are up to date.")
                log(
                    status_execution="SUCCESS",
                    last_processed_id=None,
                    total_records_processed=0,
                    error_message="No new data to process."
                )
                return
            
        total_valid_ids = len(df)
        last_valid_id = str(df["tmdb_id"].iloc[-1])

        # Convert np.nan to None (NULL)
        raw_records = df.to_dict(orient="records")
        procedureData = [{k: (None if pd.isna(v) else v) for k, v in r.items()} for r in raw_records]
        
        # Incremental load via stored procedure
        exec_load(procedureData)

        print(f"Successfully processed {total_valid_ids} valid IDs.")
        print(f"Last valid ID: {last_valid_id}")

        log(
        status_execution="SUCCESS",
        last_processed_id=last_valid_id,
        total_records_processed=total_valid_ids,
        error_message=None
        )

    except Exception as critical_error:
        print(f"An error occurred: {critical_error}")
        log(
        status_execution="FAILED",
        last_processed_id=last_valid_id,
        total_records_processed=total_valid_ids,
        error_message=str(critical_error)
        )
        sys.exit(1)

existing_ids = get_existing_ids()

dfMovies = movies_df(existing_ids)
dfShows = tv_shows_df(existing_ids)
dfTotal = pd.concat([dfMovies, dfShows])

def run_users_load(quantity):
    users = fake_user_generator(quantity)

    exec_load_users(users)

    print(f"{len(users)} users inserted with success.")

def run_subscriptions_load(quantity):
    users = fake_subscriptions_generator(quantity)

    exec_load_subscriptions(users)

    print(f"{len(users)} users inserted with success.")

def run_load_second_subscriptions(percentage: float):
    with engine.connect() as conn:
        active_users = conn.execute(text("SELECT user_id, plan_id, begin_date FROM dbo.subscriptions WHERE status = 'ACTIVE'")).mappings().all()

    sample_size = int(len(active_users) * percentage)
    sample_users = random.sample(active_users, sample_size)

    second_payload_load = second_fake_subscriptions_generator(sample_users)
    exec_load_second_subscriptions(second_payload_load)

    print(f"{len(sample_users)} users affected with success.")

def run_load_churn_rate(percentage: float):

    raw_churn_data = get_eligible_churn_users()
    churn_records = churn_rate_generator(raw_churn_data, percentage)

    exec_load_churn_rate(churn_records)

    print(f"{len(churn_records)} users affected with success.")

exec_pipeline(dfTotal)
run_users_load(10000)
run_subscriptions_load(10000)
run_load_second_subscriptions(0.3)
run_load_churn_rate(0.3)