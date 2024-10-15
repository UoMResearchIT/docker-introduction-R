import os
import sys
from datetime import datetime

import argparse
import strings as s

from flask import Flask, send_file, request
import logging
from waitress import serve

logging.basicConfig(level=logging.WARNING)
logger = logging.getLogger(__name__)

app = Flask(__name__)

file_name = "unicorn_sightings.txt"
file_path = f"output/{file_name}"

count = None
units = None

# ------------------------------------------------------------------------------
# Endpoints imported from plugins

plugin_dir = "plugins"
plugin_registry = []
if os.path.exists(plugin_dir):
    for plugin in os.listdir(plugin_dir):
        if plugin.endswith(".py") and plugin != "__init__.py":
            __import__(f"{plugin_dir}.{plugin[:-3]}")
            plugin_registry.append(plugin)

# ------------------------------------------------------------------------------
# Endpoint for exporting the unicorn sightings if the EXPORT environment variable is set to True
if os.environ.get("EXPORT") == "True":

    @app.route("/export/", methods=["GET"])
    def chart():
        if not os.path.exists(file_path):
            return {"message": "No unicorn sightings yet!"}

        return send_file(file_path, as_attachment=True)


# ------------------------------------------------------------------------------
# Endpoint for recording unicorn sightings
@app.route("/unicorn_spotted", methods=["PUT"])
def unicorn_sighting() -> dict:

    # Get the location and brightness from the request
    location = request.args.get("location")
    brightness = request.args.get("brightness")

    if not location or not brightness:
        return {"ERROR": "Missing data: Need location and brightness."}, 400

    time = datetime.now()

    # Initialize unicorn count from the file
    global count
    if not os.path.exists(file_path):
        with open(file_path, "w") as unicorn_file:
            unicorn_file.write(s.header())
        count = 0
    if count == None:
        with open(file_path) as f:
            num_lines = sum(1 for line in f)
        count = num_lines - 1

    # Write the sighting to a file and print to the console
    with open(file_path, "a") as unicorn_file:
        # Write to file and increase count
        line = s.write(count, time, location, brightness, units)
        if line:
            count += 1
        unicorn_file.write(line)

        # Print to the console
        console_line = s.print(count, time, location, brightness, units)
        print(console_line)
        sys.stdout.flush()

    return {"message": "Unicorn sighting recorded!"}, 200


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    # Parse the command line arguments
    parser = argparse.ArgumentParser(description="Run the unicorn sighting API")
    parser.add_argument(
        "--units",
        type=str,
        default="iuhc",
        choices=["iuhc", "iulu"],
        help="The units to use for the unicorn brightness",
    )
    args = parser.parse_args()

    # Set the units
    units = args.units
    if units == "iuhc":
        unit_long_name = "Imperial Unicorn Hoove Candles"
    elif units == "iulu":
        unit_long_name = "Intergalactic Unicorn Luminiocity Units"

    # Print the initialization message
    print(s.logo())
    print(s.welcome(unit_long_name, units, plugin_registry))
    print(s.base_help())
    if os.environ.get("EXPORT", "").lower() in ["1", "true", "t", "on", "yes", "y"]:
        print(s.export_help())
    print()
    sys.stdout.flush()

    # Run the API
    serve(app, host="0.0.0.0", port=8321)
