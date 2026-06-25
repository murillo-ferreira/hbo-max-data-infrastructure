# %%
import os
from dotenv import load_dotenv
import pandas as pd
import requests
from time import sleep

# %%
load_dotenv()
BEARER_TOKEN = os.getenv('TMDB_BEARER_TOKEN')

# %%
BASE_URL = "https://api.themoviedb.org/3/movie/"

headers = {
    "accept": "application/json",
    "Authorization": f"Bearer {BEARER_TOKEN}"
}

# %%
def movie_data_cleanser(movie_ids:list, existing_ids: set = None) -> pd.DataFrame:

    if existing_ids is None:
        existing_ids = set()
    
    valid_movies = []

    with requests.Session() as session:
        for id in movie_ids:
            if id in existing_ids:
                continue

            url = f"{BASE_URL}{id}"
            try:
                response = session.get(url, headers=headers)
                if response.status_code == 200:
                    data = response.json()
                    valid_movies.append(data)
                else:   
                    print(f"Failed to fetch data for movie ID {id}. Status code: {response.status_code}")
            except Exception as e:
                print(f"Failed to fetch data for movie ID {id}. Error: {str(e)}")
                sleep(5)
                continue

            sleep(1)
            
        if not valid_movies:
            return pd.DataFrame(columns=["id", "imdb_id", "title", "type", "release_year", "runtime", "genres", "budget", "origin_country", "seasons", "vote_average", "vote_count", "popularity"])
        
        dfLoad = pd.DataFrame(valid_movies)

        # Rename columns to match dbo.titles
        dfLoad.rename(
            columns={
                "release_date": "release_year",
            },
            inplace=True
        )

        # Format release_date (now release_year) to only show year
        dfLoad["release_year"] = dfLoad["release_year"].str[:4]

        # Format genres to show only genre names
        dfLoad["genres"] = dfLoad["genres"].apply(lambda x: [genre["name"].lower() for genre in x]).str.join(", ")

        # Format origin_country to string
        dfLoad["origin_country"] = dfLoad["origin_country"].str.join(", ")

        # Add type column
        dfLoad["type"] = "MOVIE"

        # Reorder columns
        dfLoad = dfLoad.reindex(
            columns=[
                    "id",
                    "imdb_id",
                    "title",
                    "type",
                    "release_year",
                    "runtime",
                    "genres",
                    "budget",
                    "origin_country",
                    "seasons",
                    "vote_average",
                    "vote_count",
                    "popularity",
            ]
        )

        return dfLoad