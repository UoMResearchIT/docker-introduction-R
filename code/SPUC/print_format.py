from datetime import datetime

print_config = "config/print.config"
data_vars = [
    "count",
    "time",
    "location",
    "brightness",
    "units",
]


def get_print_str(count, time, location, brightness, units):
    """
    Get the string to print to the console based on the configuration in print_config
    """
    lines = []
    with open(print_config, "r") as f:
        for line in f:
            if not line.startswith("#"):
                lines.append(line.strip())

    config = "\n".join(lines)
    output = config.format(
        count=count,
        time=time,
        location=location,
        brightness=brightness,
        units=units,
    )

    return output


def get_file_str(count, time, location, brightness, units):
    """
    Get the string to write to the file (includes all the data)
    """
    local_vars = locals()
    if any(local_vars[var] is None for var in data_vars):
        raise ValueError("Incomplete data: All variables must be defined")

    parts = []
    for var in data_vars:
        parts.append(str(local_vars[var]))
    output = ",".join(parts) + "\n"

    return output


def get_header():
    """
    Get all the headers to write to the file
    """
    parts = []
    for var in data_vars:
        parts.append(var)
    output = ",".join(parts) + "\n"

    return output
