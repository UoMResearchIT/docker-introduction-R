from flask import Flask, request, render_template
import requests
import logging
import pandas as pd
from io import StringIO


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)


@app.route("/")
def spucsvi():
    # get data (hit localhost 8321 at export endpoint)
    response = requests.get("http://spuc:8321/export")
    data = response.text
    data = "time,location,brightness,unit\n2013-10-04 10:23:00,moon,100,iuhc\n2013-10-04 11:05:00,mars,200,iuhc\n2013-10-04 22:48:00,earth,300,iuhc\n"
    df = pd.read_csv(StringIO(data))

    # Convert DataFrame to dictionary format for Plotly
    plot_data = [
        {"x": df["time"].tolist(), "y": df["brightness"].tolist(), "type": "timeseries"}
    ]
    logger.error(f" ------------ \n{df}")

    return render_template("spucsvi.html", data=plot_data)


if __name__ == "__main__":
    app.run()
