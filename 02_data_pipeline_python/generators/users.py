from faker import Faker

fake = Faker()
Faker.seed(191357)


def fake_user_generator(quantity: int) -> list:
    """Generate a batch of fake users with unique names and matching emails.

    Creates synthetic user records for seeding purposes,
    deriving each user's email address from their generated name (rather
    than using an unrelated random email) so the two fields stay
    consistent with each other.

    Args:
        quantity (int): Number of fake users to generate.

    Returns:
        list: A list of dicts, each representing a user with "name",
        "email", and "date_created".
    """
    users_list = []

    for i in range(quantity):
        name = fake.unique.name()
        domain = fake.email().split("@")[1]
        prefix = name.lower().replace(" ", ".").replace("..", ".")
        email = f"{prefix}@{domain}"
        date_created = fake.date_time_between(start_date='-6y', end_date='now')

        user = {
            "name": name,
            "email": email,
            "date_created": date_created
        }
        users_list.append(user)

    return users_list