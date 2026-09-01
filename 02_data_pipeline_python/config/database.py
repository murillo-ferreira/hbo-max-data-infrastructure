import sqlalchemy

def create_engine():
    USER = "python_pipeline_svc"
    PASSWORD = "Python1234#"
    SERVER = "127.0.0.1"
    DATABASE = "hbo_db"
    DRIVER = "ODBC Driver 18 for SQL Server"

    connection_string = f"mssql+pyodbc://{USER}:{PASSWORD}@{SERVER}/{DATABASE}?driver={DRIVER}&TrustServerCertificate=yes"

    engine = sqlalchemy.create_engine(connection_string)

    return engine