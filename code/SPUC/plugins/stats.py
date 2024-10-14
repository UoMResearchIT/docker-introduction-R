from __main__ import app
from __main__ import file_path

import pandas as pd

@app.route('/stats', methods=['GET'])
def stats():
    with open(file_path) as f:
        df = pd.read_csv(f)
        stats = df.describe()
        return stats.to_json()        
