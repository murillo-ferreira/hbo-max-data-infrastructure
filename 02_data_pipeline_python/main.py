# %%
import sys
import pandas as pd
from scripts.load import exec_load
from lib.logger import log
from config.database import create_engine
from lib.api_client import get_hbo_movie_ids
from sqlalchemy import text
from lib.transform import movie_data_cleanser

# %%
engine = create_engine()

# %%
def exec_pipeline():
    total_valid_ids = 0
    last_valid_id = None
    
    try:
        # ID extraction
        movie_ids = get_hbo_movie_ids()

        # Search for existing IDs
        with engine.begin() as conn:
            result = conn.execute(text("SELECT id FROM dbo.titles"))
            existing_ids = {row[0] for row in result}

        dfMovies = movie_data_cleanser(movie_ids, existing_ids)

        if dfMovies.empty:
                print("No new data to process. All database records are up to date.")
                log(
                    status_execution="SUCCESS",
                    last_processed_id=None,
                    total_records_processed=0,
                    error_message="No new data to process."
                )
                return
            
        total_valid_ids = len(dfMovies)
        last_valid_id = str(dfMovies["id"].iloc[-1])

        # Convert np.nan to None (NULL)
        raw_records = dfMovies.to_dict(orient="records")
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

# %%
exec_pipeline()