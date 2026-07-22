# %%
from faker import Faker
import random
from config.database import create_engine
from sqlalchemy import text
import datetime as dt

engine = create_engine()

fake = Faker()
Faker.seed(191357)

with engine.connect() as conn:
    existing_ids = conn.execute(text("SELECT id FROM dbo.users")).scalars().all()
    user_data = conn.execute(text("""
                            WITH RankedSubscriptions AS (
                                SELECT 
                                    user_id,
                                    plan_id,
                                    begin_date,
                                    ROW_NUMBER() OVER (
                                        PARTITION BY user_id 
                                        ORDER BY begin_date DESC
                                    ) AS rn
                                FROM dbo.subscriptions
                                WHERE status = 'ACTIVE'
                            )
                            SELECT 
                                user_id, 
                                plan_id, 
                                begin_date 
                            FROM RankedSubscriptions 
                            WHERE rn = 1;
                            """)).mappings().all()
    
def get_eligible_churn_users() -> list:
    query = text("""
        SELECT 
            user_id, 
            plan_id, 
            begin_date
        FROM dbo.subscriptions
        WHERE status = 'ACTIVE' 
          AND user_id IN (
              SELECT user_id
              FROM dbo.subscriptions
              GROUP BY user_id
              HAVING COUNT(*) = 1
          );
    """)
    with engine.connect() as conn:
        return conn.execute(query).mappings().all()

def fake_subscriptions_generator(quantity: int) -> list:
    subscriptions_list = []
    sampled_users = random.sample(existing_ids, quantity)

    for user_id in sampled_users:
        user_id = user_id
        plan_id = random.randint(1,3)
        begin_date = fake.date_time_between(start_date='-6y', end_date='now')

        record = {
            "user_id": user_id,
            "plan_id": plan_id,
            "begin_date": begin_date
        }

        subscriptions_list.append(record)

    return subscriptions_list

def second_fake_subscriptions_generator(user_data: list) -> list:
    second_subscriptions_list = []
    min_plan_id = 1
    max_plan_id = 3

    for user in user_data:
        user_id = user["user_id"]
        existing_plans = user["plan_id"]
        existing_begin_date = user["begin_date"]
        if isinstance(existing_begin_date, dt.datetime):
            existing_begin_date = existing_begin_date.date()
        covered_days = (dt.date.today() - existing_begin_date).days

        if covered_days > 30:
            new_begin_date = existing_begin_date + dt.timedelta(days=random.randint(30, covered_days))
        else:
            new_begin_date = dt.date.today()

        new_plan_id = existing_plans
        while new_plan_id == existing_plans:
            new_plan_id = random.randint(min_plan_id, max_plan_id)
        
        record = {
            "user_id": user_id,
            "new_plan_id": new_plan_id,
            "new_begin_date": new_begin_date,
            "end_date": new_begin_date
        }
        
        second_subscriptions_list.append(record)
    
    return second_subscriptions_list

def churn_rate_generator(churn_data: list, percentage:float) -> list:
    churn_list = []
    
    sample_size = int(len(churn_data) * percentage)
    sample_users = random.sample(churn_data, sample_size)

    for user in sample_users:
        user_id = user["user_id"]
        plan_id = user["plan_id"]
        begin_date = user["begin_date"]
        covered_days = (dt.date.today() - begin_date).days
        if covered_days > 30:
            new_end_date = begin_date + dt.timedelta(days=random.randint(30, covered_days))
        else:
            new_end_date = dt.date.today()

        record = {
            "user_id": user_id,
            "plan_id": plan_id,
            "begin_date": begin_date,
            "end_date": new_end_date,
        }

        churn_list.append(record)

    return churn_list
        