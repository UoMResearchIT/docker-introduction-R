from flask import Flask, request, render_template, redirect
import requests
import logging
import pandas as pd
from io import StringIO


logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)


@app.route("/")
def spucsvi():
    # Get data from SPUC
    response = requests.get("http://spuc:8321/export")
    data = response.text
    df = pd.read_csv(StringIO(data))
    # Make data Plotly-friendly
    plot_data = [
        {
            "x": df["time"].tolist(),
            "y": df["brightness"].tolist(),
            "type": "timeseries",
        }
    ]
    return render_template("spucsvi.html", data=plot_data)


@app.route("/put_unicorn", methods=["POST"])
def put_unicorn():
    location = request.form.get("location")
    brightness = request.form.get("brightness")
    requests.put(
        f"http://spuc:8321/unicorn_spotted?location={location}&brightness={brightness}"
    )
    return redirect("/")


if __name__ == "__main__":
    app.run()
