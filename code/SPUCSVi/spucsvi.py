from flask import Flask, request, render_template, redirect
import requests
import logging
import pandas as pd
from io import StringIO
import os

logging.basicConfig(level=logging.WARNING)
logger = logging.getLogger(__name__)

spuc_url = "http://spuc:8321"
if os.environ.get("SPUC_URL"):
    spuc_url = os.environ.get("SPUC_URL")
    
app = Flask(__name__)


@app.route("/")
def spucsvi():
    # Get data from SPUC
    response = requests.get(f"{spuc_url}/export")
    data = response.text

    if "No unicorn sightings" in data or data == "":
        return render_template("spucsvi.html", data=None)

    df = pd.read_csv(StringIO(data))
    c = df["count"].fillna(0).tolist()
    t = df["time"].ffill().tolist()
    b = df["brightness"].fillna(0).tolist()
    u = df["units"].fillna("").tolist()
    l = df["location"].fillna("").tolist()

    # Make data Plotly-friendly
    plot_data = [
        {
            "x": t,
            "y": b,
            "mode": "lines+markers+text",
            "text": ["🦄"] * len(df),
            "textfont": {"size": 25, "color": "purple"},
            "marker": {"size": 40, "symbol": "circle", "color": "purple"},
            "customdata": l,
            "hovertemplate": "Brightness: %{y}<br>Location: %{customdata}<extra></extra>",
        }
    ]
    return render_template("spucsvi.html", data=plot_data, count=c[-1], units=u[0])


@app.route("/put_unicorn", methods=["POST"])
def put_unicorn():
    location = request.form.get("location")
    brightness = request.form.get("brightness")
    response = requests.put(
        f"{spuc_url}/unicorn_spotted?location={location}&brightness={brightness}"
    )
    if response.status_code != 200:
        raise ValueError(f"Failed to register unicorn sighting. {response.json()["ERROR"]}")
    return redirect("/")


if __name__ == "__main__":
    app.run()
