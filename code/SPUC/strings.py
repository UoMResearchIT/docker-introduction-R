print_config = "config/print.config"
data_vars = [
    "count",
    "time",
    "location",
    "brightness",
    "units",
]


def print(count, time, location, brightness, units):
    """
    Get the string to print to the console based on the configuration in print_config
    """
    lines = []
    try:
        with open(print_config, "r") as f:
            for line in f:
                if not line.startswith("#"):
                    lines.append(line.strip())
        if not lines:
            lines = [f"ERROR: Empty print configuration file: {print_config}"]
    except FileNotFoundError:
        lines = [f"ERROR: Missing print configuration file: {print_config}"]

    config = "\n".join(lines)

    # Replace variables in the configuration with their values
    format_dict = {var: locals()[var] for var in data_vars}
    output = config.format(**format_dict)

    return output


def write(count, time, location, brightness, units):
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


def header():
    """
    Get all the headers to write to the file
    """
    parts = []
    for var in data_vars:
        parts.append(var)
    output = ",".join(parts) + "\n"

    return output
