# %%
from functions.data_filter import movie_data_cleanser
from functions.api_ids import get_hbo_movie_ids

# %%
def pipeline_extract_transform(target_count: int):
    id_list = get_hbo_movie_ids(target_count)
    dfMovies = movie_data_cleanser(id_list)
    
    return dfMovies