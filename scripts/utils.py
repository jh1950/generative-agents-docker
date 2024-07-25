import csv
from os import getenv

openai_api_key = getenv("OPENAI_API_KEY", "")
key_owner = getenv("OPENAI_API_OWNER", "")

frontend_root = getenv("FRONTEND_ROOT", "")
maze_assets_loc = f"../../{frontend_root}/static_dirs/assets"
env_matrix = f"{maze_assets_loc}/the_ville/matrix"
env_visuals = f"{maze_assets_loc}/the_ville/visuals"

fs_storage = f"../../{frontend_root}/storage"
fs_temp_storage = f"../../{frontend_root}/temp_storage"

with open(f"{env_matrix}/maze/collision_maze.csv") as f:
    data = csv.reader(f, delimiter=",")
    for d in data:
        blockid = sorted({int(x.strip()) for x in d})[1]
collision_block_id = blockid

# Verbose
debug = True
