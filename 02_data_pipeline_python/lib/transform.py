from lib.api_client import get_hbo_movie_ids, get_hbo_tv_show_ids, headers, MOVIE_URL, SHOW_URL
import pandas as pd
import requests
from time import sleep

MOVIE_DETAIL_URL = "https://api.themoviedb.org/3/movie/"
SHOW_DETAIL_URL = "https://api.themoviedb.org/3/tv/"

def fetch_content_data(content_ids:list, base_url: str, content_type: str, existing_ids: set) -> list:
    """Fetch detailed metadata from TMDB for a set of content IDs.

    Skips any ID already present in the catalog to avoid redundant
    calls, tagging each fetched record with its content type so movies
    and TV shows can be told apart downstream. Requests are throttled,
    and a failed or errored request is logged and skipped rather than
    stopping the whole batch.

    Args:
        content_ids (list): TMDB IDs (int) to fetch details for.
        base_url (str): TMDB detail endpoint URL to which each ID is
            appended (e.g. the movie or TV show detail URL).
        content_type (str): Label to tag each result with, e.g.
            "MOVIE" or "SHOW".
        existing_ids (set): IDs already present in the catalog; these
            are skipped.

    Returns:
        list: Raw TMDB detail responses (dict) for each newly fetched
        item, each including a "type" field set to "content_type".
    """
    results = []

    with requests.Session() as session:
        for id in content_ids:
            if id in existing_ids:
                continue

            url = f"{base_url}{id}"
            try:
                response = session.get(url, headers=headers)
                if response.status_code == 200:
                    data = response.json()
                    data['type'] = content_type
                    results.append(data)
                else:   
                    print(f"Failed to fetch data for movie ID {id}. Status code: {response.status_code}")
            except Exception as e:
                print(f"Failed to fetch data for movie ID {id}. Error: {str(e)}")
                sleep(5)
        
            sleep(1)

    return results

def clean_df_content(data_list: list, date_field: str, name_field: str = "title") -> pd.DataFrame:
    """Normalize raw TMDB content data into the dbo.titles table schema.

    Reconciles the differing field names and structures between TMDB's
    movie and TV show responses (e.g. varying date and title field
    names, list- vs count-based season data) into one consistent
    tabular format ready for loading into the catalog.

    Args:
        data_list (list): Raw TMDB detail records (dict) as returned by
            :func:'fetch_content_data'.
        date_field (str): Name of the source field holding the release
            date (e.g. "release_date" for movies, "first_air_date" for
            TV shows).
        name_field (str): Name of the source field holding the title
            (e.g. "title" for movies, "name" for TV shows). Defaults to
            "title".

    Returns:
        pandas.DataFrame: One row per item, with columns matching the
        dbo.titles schema. Empty if "data_list" is empty.
    """
    if not data_list:
        return pd.DataFrame()

    df = pd.DataFrame(data_list)

    # Schema standard
    defaults = {
        "seasons": 0, 
        date_field: None, 
        "genres": [], 
        "origin_country": [],
        "runtime": None,
        "budget": None,
        "vote_average": None,
        "vote_count": None,
        "popularity": None
    }
    for col, val in defaults.items():
        if col not in df.columns:
            df[col] = val

    # Rename name and date fields
    df.rename(columns={
        "id": "tmdb_id",
        date_field: "release_year", 
        name_field: "title"
        }, inplace=True)

    # Transform data to match dbo.titles
    df["seasons"] = df["seasons"].apply(lambda x: len(x) if isinstance(x, list) else (x if pd.notnull(x) else 0))
    
    df["release_year"] = df["release_year"].str[:4].replace(["None", "nan", ""], None)
    
    df["genres"] = df["genres"].apply(lambda x: ", ".join([g["name"].lower() for g in x]) if isinstance(x, list) else "")
    
    df["origin_country"] = df["origin_country"].apply(lambda x: ", ".join(x) if isinstance(x, list) else "")

    cols_order = [
        "tmdb_id", "imdb_id", "title", "type", "release_year", "runtime", 
        "genres", "budget", "origin_country", "seasons", 
        "vote_average", "vote_count", "popularity"
    ]
    
    # Fill missing columns with None
    for col in cols_order:
        if col not in df.columns:
            df[col] = None
            
    return df[cols_order]

def movies_df(existing_ids):
    """Fetch and clean data for all HBO Max movies not yet in the catalog.

    Args:
        existing_ids (set): TMDB movie IDs already present in the
            catalog; these are skipped when fetching.

    Returns:
        pandas.DataFrame: One row per new movie, matching the
        dbo.titles schema.
    """
    movies_raw = fetch_content_data(get_hbo_movie_ids(), MOVIE_DETAIL_URL, "MOVIE", existing_ids)
    dfMovies = clean_df_content(movies_raw, "release_date", "title")

    return dfMovies

def tv_shows_df(existing_ids):
    """Fetch and clean data for all HBO Max TV shows not yet in the catalog.

    Args:
        existing_ids (set): TMDB TV show IDs already present in the
            catalog; these are skipped when fetching.

    Returns:
        pandas.DataFrame: One row per new TV show, matching the
        dbo.titles schema.
    """
    tv_shows_raw = fetch_content_data(get_hbo_tv_show_ids(), SHOW_DETAIL_URL, "SHOW", existing_ids)
    dfTVShows = clean_df_content(tv_shows_raw, "first_air_date", "name")

    return dfTVShows