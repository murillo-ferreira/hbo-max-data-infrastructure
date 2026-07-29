import random
from config.database import create_engine
from sqlalchemy import text
import datetime as dt

engine = create_engine()

def watch_history_generator(quantity: int) -> list:
    with engine.connect() as conn:
        user_map = conn.execute(text("""
            SELECT id AS subscription_id, user_id, begin_date, end_date
            FROM dbo.subscriptions""")).mappings().all()
        
        content_data = conn.execute(text("""
            SELECT id AS title_id, runtime
            FROM dbo.titles
            WHERE runtime IS NOT NULL AND runtime > 0
            """)).mappings().all()

    user_data = {
        row["subscription_id"]:{
            "user_id":row["user_id"],
            "begin_date":row["begin_date"],
            "end_date":row["end_date"]} 
        for row in user_map
    }
    watch_history_list = []
    sample_subscriptions = random.choices(list(user_data.keys()), k=quantity)

    for subscription_id in sample_subscriptions:
        selected_content = random.choice(content_data)
        user_info = user_data.get(subscription_id)
        begin_date = user_info["begin_date"]
        end_date = user_info["end_date"] if user_info["end_date"] else dt.date.today()

        b_date = begin_date.date() if isinstance(begin_date, dt.datetime) else begin_date
        e_date = end_date.date() if isinstance(end_date, dt.datetime) else end_date
        
        covered_days = max(0, (e_date - b_date).days)
        event_date = b_date + dt.timedelta(days=random.randint(0, covered_days))

        title_id = selected_content["title_id"]
        watched_at = dt.datetime.combine(
            event_date,
            dt.time(random.randint(0, 23), random.randint(0, 59), random.randint(0, 59))
        )
        watch_duration = random.randint(0, selected_content["runtime"])
        device_type = random.choice(["Mobile", "TV", "Web"])
        watch_percentage = watch_duration / selected_content["runtime"]
        completed = 1 if watch_percentage >= 0.90 else 0
        
        record = {
            "user_id": user_info["user_id"],
            "subscription_id": subscription_id,
            "title_id": title_id,
            "watched_at": watched_at,
            "watch_duration": watch_duration,
            "device_type": device_type,
            "completed": completed
        }

        watch_history_list.append(record)

    return watch_history_list