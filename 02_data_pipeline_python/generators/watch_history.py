import random
from config.database import create_engine
from sqlalchemy import text
import datetime as dt

engine = create_engine()

with engine.connect() as conn:
    user_map = conn.execute(text("SELECT user_id, begin_date FROM dbo.subscriptions")).mappings().all()
    content_data = conn.execute(text("""
        SELECT id, runtime
        FROM dbo.titles
        WHERE runtime IS NOT NULL AND runtime > 0
        """)).mappings().all()

def watch_history_generator(quantity: int) -> list:
    user_data = {row["user_id"]:row["begin_date"] for row in user_map}
    watch_history_list = []
    sample_users = random.choices(list(user_data.keys()), k=quantity)

    for user_id in sample_users:
        selected_content = random.choice(content_data)
        begin_date = user_data.get(user_id)
        if isinstance(begin_date, dt.date) and not isinstance(begin_date, dt.datetime):
            begin_datetime = dt.datetime.combine(begin_date, dt.time.min)
        else:
            begin_datetime = begin_date
        covered_days = max(0, (dt.date.today() - begin_datetime.date()).days)
        sorted_days = random.randint(0, covered_days)
        random_hours = random.randint(0, 23)
        random_minutes = random.randint(0, 59)
        random_seconds = random.randint(0, 59)

        user_id = user_id
        title_id = selected_content["id"]
        watched_at = begin_datetime + dt.timedelta(
            days=sorted_days,
            hours=random_hours,
            minutes=random_minutes,
            seconds=random_seconds
        )
        watch_duration = random.randint(0, selected_content["runtime"])
        device_type = random.choice(["Mobile", "TV", "Web"])
        watch_percentage = watch_duration / selected_content["runtime"]
        completed = 1 if watch_percentage >= 0.90 else 0
        
        record = {
            "user_id": user_id,
            "title_id": title_id,
            "watched_at": watched_at,
            "watch_duration": watch_duration,
            "device_type": device_type,
            "completed": completed
        }

        watch_history_list.append(record)

    return watch_history_list