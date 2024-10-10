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

    if "No unicorn sightings" in data or data == "":
        return render_template("spucsvi.html", data=None)

    df = pd.read_csv(StringIO(data))
    t = df["time"].tolist() if "time" in df.columns else range(len(df))
    b = df["brightness"].tolist() if "brightness" in df.columns else [1] * len(df)
    u = df["unit"].tolist() if "unit" in df.columns else [""] * len(df)
    l = df["location"].tolist() if "location" in df.columns else [""] * len(df)

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
    return render_template("spucsvi.html", data=plot_data, units=u[0])


@app.route("/put_unicorn", methods=["POST"])
def put_unicorn():
    location = request.form.get("location")
    brightness = request.form.get("brightness")
    response = requests.put(
        f"http://spuc:8321/unicorn_spotted?location={location}&brightness={brightness}"
    )
    if response.status_code != 200:
        raise ValueError(f"Failed to register unicorn sighting. {response.json()["ERROR"]}")
    return redirect("/")


if __name__ == "__main__":
    app.run()
