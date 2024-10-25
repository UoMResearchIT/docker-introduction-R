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

# Welcome to the Space Purple Unicorn Counter!

This image provides a service with which you can register space purple unicorn sightings!

## Running the service
To start the service run:
```
docker run -p 8321:8321 spuacv/spuc:latest
```

## Registering a sighting
It provides an API in the exposed port **8321**, which can be hit to add an event to the sightings record.
The `location` and `brightness` of the unicorn need to be passed as parameters of a put request.
For example:
```
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```
will register a unicorn sighting on the moon with a brightness of 100iuhc.

The default behaviour is to set *Imperial Unicorn Hoove Candles* [iuhc],
but it can be configured to use *Intergalactic Unicorn Luminosity Units* [iulu].

## Output configuration
The running container will confirm the sighting record with a print output.

The output can be configured in the `/spuc/config/print.config` file.

The default config is set to:
```
::::: {time} Unicorn spotted at {location}!! Brightness: {brightness} {units}
```

## Exporting records

It can also provide an export of the sighting records if the `EXPORT` environment variable is set to `True`.
A GET request to 8321/export will allow you to download the file, i.e.:
```
curl localhost:8321/export
```

## Changing units

The brightness units can be changed from Imperial Unicorn Hoove Candles (iuhc) to Intergalactic Unicorn Luminosity Units (iulu)
by passing the parameters `--units iuhc` on container startup.

## Plugins

Files with a python extension (`.py`) placed in the `/spuc/plugins/` directory will be automatically imported on container startup.
To add a plugin, define it as a python script and make sure you define an endpoint for the new feature.
For example:
```python
from __main__ import app

@app.route("/my_plugin", methods=["GET"])
def my_plugin():
    return {"message": "My plugin worked!"}, 200
```

## Brought to you by:

![LOGO](/episodes/fig/SPUA/SPUA_logo.png "SPUA Logo.")
