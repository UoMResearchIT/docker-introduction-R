from datetime import datetime
import config


def get_str(location, brightness, units):
    parts = []
    if config.WRITE_DATETIME:
        parts.append(f"{datetime.now()}")
    if config.WRITE_LOCATION:
        parts.append(f"{location}")
    if config.WRITE_BRIGHTNESS:
        parts.append(f"{brightness}")
    if config.WRITE_UNITS:
        parts.append(f"{units}")
    output = ",".join(parts) + "\n"

    return output


def get_header():
    parts = []
    if config.WRITE_DATETIME:
        parts.append("time")
    if config.WRITE_LOCATION:
        parts.append("location")
    if config.WRITE_BRIGHTNESS:
        parts.append("brightness")
    if config.WRITE_UNITS:
        parts.append("unit")
    output = ",".join(parts) + "\n"

    return output
