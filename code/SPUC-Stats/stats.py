from __main__ import app
from __main__ import file_path

import pandas as pd
import os


@app.route("/stats", methods=["GET"])
def stats():
    if not os.path.exists(file_path):
        return {"message": "No unicorn sightings yet!"}

    with open(file_path) as f:
        df = pd.read_csv(f)
        df = df.iloc[:, 1:]
        stats = df.describe()
        return stats.to_json()
