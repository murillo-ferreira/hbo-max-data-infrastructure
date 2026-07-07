# %%
import sys
import pandas as pd
from scripts.load import exec_load
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

exec_pipeline(dfTotal)