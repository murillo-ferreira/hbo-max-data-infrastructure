import os
from dotenv import load_dotenv
import requests
from time import sleep

load_dotenv()
BEARER_TOKEN = os.getenv('TMDB_BEARER_TOKEN')

MOVIE_URL = f"https://api.themoviedb.org/3/discover/movie?&language=en-US&sort_by=popularity.desc&with_watch_providers=1899&watch_region=US"
SHOW_URL = f"https://api.themoviedb.org/3/discover/tv?&language=en-US&sort_by=popularity.desc&with_watch_providers=1899&watch_region=US"

headers = {
    "accept": "application/json",
    "Authorization": f"Bearer {BEARER_TOKEN}"
}

def get_paginated_ids(base_url: str) -> list:
    all_ids = []
    page = 1
    total_pages = 1

    while page <= total_pages:
        url = f"{base_url}&page={page}"
        response = requests.get(url, headers=headers)
        data = response.json()

        if page == 1:
            total_pages = data.get("total_pages", 1)

        results = data.get("results", [])
        if not results:
            break

        all_ids.extend([item["id"] for item in results])

        page += 1
        sleep(1)
    
    return all_ids

def get_hbo_movie_ids() -> list:
    return get_paginated_ids(MOVIE_URL)

def get_hbo_tv_show_ids() -> list:
    return get_paginated_ids(SHOW_URL)