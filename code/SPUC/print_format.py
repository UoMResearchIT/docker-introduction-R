from datetime import datetime
import config


def get_str(location, brightness, units):
    output = ""
    if config.WRITE_DATETIME:
        output += f"{datetime.now()},"
    if config.WRITE_LOCATION:
        output += f"{location},"
    if config.WRITE_BRIGHTNESS:
        output += f"{brightness},"
    if config.WRITE_UNITS:
        output += f"{units}"
    output += "\n"

    return output


def get_header():
    output = ""
    if config.WRITE_DATETIME:
        output += "time,"
    if config.WRITE_LOCATION:
        output += "location,"
    if config.WRITE_BRIGHTNESS:
        output += "brightness,"
    if config.WRITE_UNITS:
        output += "unit"
    output += "\n"

    return output
