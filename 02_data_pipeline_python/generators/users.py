from faker import Faker

fake = Faker()
Faker.seed(191357)

def fake_user_generator(quantity: int) -> list:
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
