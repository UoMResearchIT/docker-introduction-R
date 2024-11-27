# Configuring containers


Explore the docs we found on Docker Hub.
We can:
- Set an environment variable **EXPORT** to **True** to export the logs to a file.
- Pass a parameter to change the units.


## Setting the environment
We set environment variables with `-e name=value`:
```bash
docker stop spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -e EXPORT=true spuacv/spuc:latest
docker logs spuc_container
```
And we can now try it:
```bash
curl localhost:8321/export
```
So we no longer need a bind mount, a volume would work just fine.

Defaulting to network style connections is very common in Docker containers.

Environment variables are a very common tool for configuring containers.


## Passing parameters (overriding the command)

SPUC is recording the brightness of the unicorns in **Imperial Unicorn Hoove Candles** (iuhc)!  
We must change it to the much more standard **Intergalactic Unicorn Luminosity Units** (iulu).

Parameters are passed on the command. Remember:
```bash
docker inspect spuacv/spuc:latest -f "Entrypoint: {{.Config.Entrypoint}}\nCommand: {{.Config.Cmd}}"
```
To override it, we write the command we want at the end:
```bash
docker stop spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -e EXPORT=true spuacv/spuc:latest --units iulu
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=pluto\&brightness=66
curl localhost:8321/export
```
This worked, but now we have a mix of units!
We have to remove the volume to fix this:
```bash
docker stop spuc_container
docker volume rm spuc-volume
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -e EXPORT=true spuacv/spuc:latest --units iulu
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=177
curl -X PUT localhost:8321/unicorn_spotted?location=earth\&brightness=18
curl -X PUT localhost:8321/unicorn_spotted?location=mars\&brightness=709
curl -X PUT localhost:8321/unicorn_spotted?location=jupyter\&brightness=372
curl -X PUT localhost:8321/unicorn_spotted?location=venus\&brightness=262
curl -X PUT localhost:8321/unicorn_spotted?location=pluto\&brightness=66
curl localhost:8321/export
```

Overriding the command is a very common way to configure containers.


## Overriding the entrypoint
This is less common, but it can also be done:
```bash
docker run -it --rm --entrypoint /bin/sh spuacv/spuc:latest
```

## Challenge: Entrypoint + Command combinations

|     | Entrypoint                          | Command                             |
| --- | ----------------------------------- | ----------------------------------- |
| A   | `python /spuc/spuc.py --units iuhc` |                                     |
| B   | `python /spuc/spuc.py`              | `--units iuhc`                      |
| C   | `python`                            | `/spuc/spuc.py --units iuhc`        |
| D   |                                     | `python /spuc/spuc.py --units iuhc` |

All valid combinations, but with different implications:
- **A:** Ok if unlikely to change (although more may be appended).
- **B:** program baked in, arguments easily changed -- STANDARD.
- **C:** Python script can be changed easily, which is more likely to be bad than good!
- **D:** Maximum flexibility, but re-write the whole command to modify even the parameters.


## Show keypoints slide
