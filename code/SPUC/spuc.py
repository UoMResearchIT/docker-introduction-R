import os
import sys
from typing import Union
from datetime import datetime

import argparse
import print_format as pf

from flask import Flask, send_file, request
from waitress import serve

count = None
units = None
app = Flask(__name__)

file_name = "unicorn_sightings.txt"
file_path = f"output/{file_name}"

help_string = """
Welcome to the Space Purple Unicorn Counter!
::::: Try 'curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100' to record a unicorn sighting!
::::: Or 'curl localhost:8321/export' to download the unicorn sightings file!
"""

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

    # --------------------------------------------------------------------------
    # Get the location and brightness from the request

    location = request.args.get("location")
    brightness = request.args.get("brightness")

    time = datetime.now()

    # --------------------------------------------------------------------------
    # Initialize unicorn count from the file
    global count
    if not os.path.exists(file_path):
        with open(file_path, "w") as unicorn_file:
            unicorn_file.write(pf.get_header())
        count = 0
    if count == None:
        with open(file_path) as f:
            num_lines = sum(1 for line in f)
        count = num_lines - 1

    # --------------------------------------------------------------------------
    # Write the sighting to a file and print to the console
    with open(file_path, "a") as unicorn_file:
        # Append the location to the file (increases count by 1)
        line = pf.get_file_str(count, time, location, brightness, units)
        if line:
            count += 1
        unicorn_file.write(line)

        # Print the line to the console
        console_line = pf.get_print_str(count, time, location, brightness, units)
        print(console_line)
        sys.stdout.flush()

    return {"message": "Unicorn sighting recorded!"}


if __name__ == "__main__":

    # --------------------------------------------------------------------------
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

    # --------------------------------------------------------------------------
    # Set the units

    units = args.units
    if units == "iuhc":
        unit_long_name = "Imperial Unicorn Hoove Candles"
    elif units == "iulu":
        unit_long_name = "Intergalactic Unicorn Luminiocity Units"

    # --------------------------------------------------------------------------
    # Print the initialization message

    logo = r"""
            \\
             \\
              \\
               \\
                >\/7
            _.-(6'  \
           (=___._/` \            ____  ____  _    _  ____
                )  \ |           / ___||  _ \| |  | |/ ___|
               /   / |           \___ \| |_) | |  | | |
              /    > /            ___) |  __/| |__| | |___
             j    < _\           |____/|_|    \____/ \____|
         _.-' :      ``.
         \ r=._\        `.       Space Purple Unicorn Counter
        <`\\_  \         .`-.
         \ r-7  `-. ._  ' .  `\
          \`,      `-.`7  7)   )
           \/         \|  \'  / `-._
                      ||    .'
                       \\  (
                        >\  >
                    ,.-' >.'
                   <.'_.''
                     <'
    """
    print(logo)
    print(f"::::: Initializing SPUC...")
    print(f"::::: Units set to {unit_long_name} [{units}].")
    print(f"{help_string}")
    sys.stdout.flush()

    # --------------------------------------------------------------------------
    # Run the API

    serve(app, host="0.0.0.0", port=8321)
