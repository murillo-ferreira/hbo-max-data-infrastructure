from config.database import create_engine
from datetime import datetime
from sqlalchemy import text

engine = create_engine()

def log(status_execution, last_processed_id, total_records_processed, error_message):
    """Record a pipeline execution's outcome for monitoring and auditing.

    Persists a single run's status, progress checkpoint, and any error
    encountered, so pipeline runs can be tracked and resumed or debugged
    later.

    Args:
        status_execution (str): Outcome of the run, e.g. "SUCCESS" or
            "FAILED".
        last_processed_id: Identifier of the last record processed,
            used as a resume checkpoint for the next run.
        total_records_processed (int): Number of records processed
            during this run.
        error_message (str): Error details if the run failed, or
            "None" if it succeeded.

    Returns:
        None
    """
    with engine.begin() as conn:
        conn.execute(
            text("""
                INSERT INTO dbo.pipeline_logs (status_execution, last_processed_id, total_records_processed, error_message, execution_date)
                VALUES (:status_execution, :last_processed_id, :total_records_processed, :error_message, :execution_date)
            """),
            {
                "status_execution": status_execution,
                "last_processed_id": last_processed_id,
                "total_records_processed": total_records_processed,
                "error_message": error_message,
                "execution_date": datetime.now()
            }
        )
        
    print(f"[LOG] State '{status_execution}' registered with success.")