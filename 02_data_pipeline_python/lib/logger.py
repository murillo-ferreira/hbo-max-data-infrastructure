from config.database import create_engine
from datetime import datetime
from sqlalchemy import text

engine = create_engine()

def log(status_execution, last_processed_id, total_records_processed, error_message):
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