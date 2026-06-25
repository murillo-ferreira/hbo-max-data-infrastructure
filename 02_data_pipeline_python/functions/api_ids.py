# %%
import os
from dotenv import load_dotenv
import requests
from time import sleep

# %%
load_dotenv()
BEARER_TOKEN = os.getenv('TMDB_BEARER_TOKEN')

# %%
HBO_URL = f"https://api.themoviedb.org/3/discover/movie?&language=en-US&sort_by=popularity.desc&with_watch_providers=1899&watch_region=US"

headers = {
    "accept": "application/json",
    "Authorization": f"Bearer {BEARER_TOKEN}"
}

# %%
def get_hbo_movie_ids() -> list:
    movie_ids = []
    page = 1
    total_pages = 1

    while page <= total_pages:
        url = f"{HBO_URL}&page={page}"
        response = requests.get(url, headers=headers)
        data = response.json()

        if page == 1:
            total_pages = data["total_pages"]

        results = data.get("results", [])
        if not results:
            break

        movie_ids.extend([movie["id"] for movie in results])
        
        page += 1
        sleep(1)

    return movie_ids