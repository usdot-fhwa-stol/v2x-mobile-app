import glob
import utils

def load_map_hex():
    maps = []
    for file_name in glob.glob("sample_data/map/*.txt"):
        with open(file_name, "r") as f:
            map_hex = f.read()            
            maps.append(map_hex)
    return maps