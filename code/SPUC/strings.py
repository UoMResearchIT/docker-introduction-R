import textwrap as t

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


def logo():
    logo = r"""
            \
             \
              \\
               \\\
                >\/7
            _.-(º   \
           (=___._/` \            ____  ____  _    _  ____
                )  \ |\          / ___||  _ \| |  | |/ ___|
               /   / ||\         \___ \| |_) | |  | | |
              /    > /\\\         ___) |  __/| |__| | |___
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
    return logo


def welcome(unit_long_name, units, plugin_registry):
    plugins = ""
    if plugin_registry:
        plugins = t.dedent(
            f"""
            :: The following plugins were loaded
                {", ".join(plugin_registry)}
            """.rstrip()
        )
    else:
        plugins = ":: No plugins detected"
    message = t.dedent(
        f"""
        Welcome to the Space Purple Unicorn Counter!

        :::: Units set to {unit_long_name} [{units}] ::::")
        {plugins}
        """.rstrip()
    )
    return message


def base_help():
    help = t.dedent(
        r"""
        :: Try recording a unicorn sighting with:
            curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
        """.rstrip()
    )
    return help


def export_help():
    help = t.dedent(
        r"""
        :::: Unicorn sightings export activated! ::::
        :: Try downloading the unicorn sightings record with:
            curl localhost:8321/export
        """.rstrip()
    )
    return help
