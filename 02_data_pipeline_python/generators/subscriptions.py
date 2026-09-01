from faker import Faker
import random
from config.database import create_engine
from sqlalchemy import text
import datetime as dt

engine = create_engine()

fake = Faker()
Faker.seed(191357)

def fake_subscriptions_generator(quantity: int) -> list:
    """Generate a batch of brand-new fake subscriptions for random users.

    Randomly selects users from the existing user base (without
    replacement) and assigns each one a new subscription with a random
    plan and a random start date, simulating first-time sign-ups.

    Args:
        quantity (int): Number of fake subscriptions to generate. Must
            not exceed the number of available existing users.

    Returns:
        list: A list of dicts, each representing a new subscription
        record with "user_id", "plan_id", and "begin_date".
    """
    with engine.connect() as conn:
        existing_ids = conn.execute(text("SELECT id FROM dbo.users")).scalars().all()
        
    subscriptions_list = []
    sampled_users = random.sample(existing_ids, quantity)

    for user_id in sampled_users:
        user_id = user_id
        plan_id = random.randint(1, 3)
        begin_date = fake.date_time_between(start_date='-6y', end_date='now')

        record = {
            "user_id": user_id,
            "plan_id": plan_id,
            "begin_date": begin_date
        }

        subscriptions_list.append(record)

    return subscriptions_list

def get_active_subscriptions() -> list:
    """Fetch the most recent active subscription for each user."""
    user_data = text("""
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
        SELECT user_id, plan_id, begin_date 
        FROM RankedSubscriptions 
        WHERE rn = 1;
    """)
    with engine.connect() as conn:
        return conn.execute(user_data).mappings().all()
    
def second_fake_subscriptions_generator(user_data: list) -> list:
    """Simulate plan changes (renewals) for users' existing subscriptions.

    For each user's current subscription, generates a follow-up
    subscription event on a different plan, simulating a renewal,
    upgrade, or downgrade that occurs after their initial subscription
    period.

    Args:
        user_data (list): A list of dicts describing current
            subscriptions, each with "user_id", "plan_id", and
            "begin_date" (a "date" or "datetime").

    Returns:
        list: A list of dicts, each representing the resulting
        subscription change with "user_id", "new_plan_id",
        "new_begin_date", and "end_date".
    """
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

def get_eligible_churn_users() -> list:
    """Fetch active subscribers who are on their very first subscription.

    Identifies users whose current subscription is the only subscription
    record they have ever had, making them eligible candidates for
    simulating a churn event (as opposed to users who have already
    upgraded, downgraded, or renewed at least once).

    Returns:
        list: A list of row mappings, each containing "user_id",
        "plan_id", and "begin_date" for an eligible user's active
        subscription.
    """
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


def churn_rate_generator(churn_data: list, percentage: float) -> list:
    """Simulate churn by ending a percentage of eligible subscriptions.

    Randomly samples a subset of the given subscriptions, sized
    according to the target churn percentage, and assigns each sampled
    subscription an end date, simulating those users cancelling their
    subscription.

    Args:
        churn_data (list): A list of dicts describing eligible
            subscriptions, each with "user_id", "plan_id", and
            "begin_date" (a "date").
        percentage (float): Fraction (between 0 and 1) of
            "churn_data" to mark as churned.

    Returns:
        list: A list of dicts, each representing a churned
        subscription with "user_id", "plan_id", "begin_date",
        and "end_date".
    """
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