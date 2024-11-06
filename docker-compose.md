---
title: Using Docker Compose
teaching: 99
exercises: 99
---

::::::::::::::::::::::::::::::::::::::::::::::::::: objectives
- Learn how to run multiple containers together.
- Clean up our run command for once and for all.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::: questions
- What is Docker Compose?
- Why and when would I use it?
- How can I translate my `docker run` commands into a `docker-compose.yml` file?
- How can I make containers communicate with each other?
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

We've manage to come a long way in making the SPUC container work better for us, but it still lacks a little something.
If we want to open this service to our local community, we can hardly expect them to hit the API with a curl command!

Luckily, the SPUA released the SPUC Super Visualiser (SPUCSVi)!
The SPUCSVi is a web-based tool that allows you to register unicorn sightings,
and also see the record of unicorn sightings.
Handily, the SPUA also made it available as a Docker container.

Now that you have seen several `docker run` commands,
you can well imagine how cumbersome running multiple containers can get.
Even more so if we want the different containers to play well with each other.

Enter: Docker Compose!

Docker Compose is a tool for defining and running multi-container applications.
With Compose, you use a YAML file to configure your application's services.
Then, with a single command, you create and start all the services from your configuration.

Let's take a look at Docker Compose and see how it can help us run SPUC and SPUCSVi.

## Running a container

As an initial step, we will learn how to run a container using Docker Compose.

The first thing we need to do is create a `docker-compose.yml` file.
All `docker-compose.yml` files start with `services:`.
This is the root element under which we define the services we want to run.
```yml
services:
```

Next, let's add the service for the SPUC container.
We'll call it `spuc` and we will tell it what `image` to use.
```yml
services:
  spuc:                            # The name of the service
    image: spuacv/spuc:latest      # The image to use
```

This is actually enough for us to run the container!
But we won't use `docker run` any more.

Instead, we will use the base command `docker compose`.
To run the services, we add the command `up`, signalling that we want to bring services up (i.e. start them).
```bash
docker compose up
```
```output
[+] Running 2/0
 ✔ Network docker_intro_default   Created                           0.1s
 ✔ Container docker_intro-spuc-1  Created                           0.0s
Attaching to spuc-1
spuc-1  | 
spuc-1  |             \
spuc-1  |              \
spuc-1  |               \\
spuc-1  |                \\\
spuc-1  |                 >\/7
spuc-1  |             _.-(º   \
spuc-1  |            (=___._/` \            ____  ____  _    _  ____
spuc-1  |                 )  \ |\          / ___||  _ \| |  | |/ ___|
spuc-1  |                /   / ||\         \___ \| |_) | |  | | |
spuc-1  |               /    > /\\\         ___) |  __/| |__| | |___
spuc-1  |              j    < _\           |____/|_|    \____/ \____|
spuc-1  |          _.-' :      ``.
spuc-1  |          \ r=._\        `.       Space Purple Unicorn Counter
spuc-1  |         <`\\_  \         .`-.
spuc-1  |          \ r-7  `-. ._  ' .  `\
spuc-1  |           \`,      `-.`7  7)   )
spuc-1  |            \/         \|  \'  / `-._
spuc-1  |                       ||    .'
spuc-1  |                        \\  (
spuc-1  |                         >\  >
spuc-1  |                     ,.-' >.'
spuc-1  |                    <.'_.''
spuc-1  |                      <'
spuc-1  |     
spuc-1  | 
spuc-1  | Welcome to the Space Purple Unicorn Counter!
spuc-1  | 
spuc-1  | :::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::
spuc-1  | 
spuc-1  | :: Try recording a unicorn sighting with:
spuc-1  |     curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
spuc-1  | 
spuc-1  | :: No plugins detected
spuc-1  |
```

So we have our container running! With a couple of interesting bits of output to note:

- A container was created named `docker-intro-spuc-1`. (The directory name is prepended to the container name)
- A `network` was created for the container - we will dig into what this means later!
- The tool is running in the foreground, so we can see the output of the tool

We can stop the container by pressing `[Ctrl+C]` in the terminal.

## Configuring the container

We have managed to run our container, but we are still a way off from reproducing our last `run` command.
It's ok, we need to add more configuration to our Docker Compose file.

Let's recall our `docker run` command for the regular SPUC container (rather than the one we made ourselves - we'll get to that in a bit):
```bash
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v stats.py:/spuc/plugins/stats.py -e EXPORT=true spuacv/spuc:latest --units iulu
```

There are a lot of flags here!
Each of these flags has a corresponding key in Docker Compose.
Lets order all the elements we want in a table, so we can see what we need to add to our `docker-compose.yml` file.

| Flag                                          | Description                                             |
|-----------------------------------------------|---------------------------------------------------------|
| `-d`                                          | Run the container in the background                     |
| `--rm`                                        | Remove the container when it stops                      |
| `--name spuc_container`                       | Name the container `spuc_container`                     |
| `-p 8321:8321`                                | Map port 8321 on the host to port 8321 in the container |
| `-v ./print.config:/spuc/config/print.config` | Bind mount the `./print.config` file into the container |
| `-v spuc-volume:/spuc/output`                 | Persist the `/spuc/output` directory in a volume        |
| `-v ./stats.py:/spuc/plugins/stats.py`        | Bind mount the `./stats.py` plugin into the container   |
| `-e EXPORT=true`                              | Set the environment variable `EXPORT` to `true`         |
| `--units iulu`                                | Set the units to Imperial Unicorn Length Units          |

We can now start translate this into a Docker Compose file bit by bit!

### Running in the background

To run a docker compose stack in the background, we can use the `-d` (for detach) flag when calling `docker compose up`.
```bash
$ docker compose up -d
```
```output
[+] Running 1/1
 ✔ Container docker-intro-spuc-1  Started                                   0.2s
```

Of course, this means we can no longer see the logs! But we can still access them using the `logs` command.
```bash
docker compose logs
```
```output
spuc-1  | 
spuc-1  |             \
spuc-1  |              \
spuc-1  |               \\
spuc-1  |                \\\
spuc-1  |                 >\/7
spuc-1  |             _.-(º   \
spuc-1  |            (=___._/` \            ____  ____  _    _  ____
spuc-1  |                 )  \ |\          / ___||  _ \| |  | |/ ___|
spuc-1  |                /   / ||\         \___ \| |_) | |  | | |
spuc-1  |               /    > /\\\         ___) |  __/| |__| | |___
spuc-1  |              j    < _\           |____/|_|    \____/ \____|
spuc-1  |          _.-' :      ``.
spuc-1  |          \ r=._\        `.       Space Purple Unicorn Counter
spuc-1  |         <`\\_  \         .`-.
spuc-1  |          \ r-7  `-. ._  ' .  `\
spuc-1  |           \`,      `-.`7  7)   )
spuc-1  |            \/         \|  \'  / `-._
spuc-1  |                       ||    .'
spuc-1  |                        \\  (
spuc-1  |                         >\  >
spuc-1  |                     ,.-' >.'
spuc-1  |                    <.'_.''
spuc-1  |                      <'
spuc-1  |     
spuc-1  | 
spuc-1  | Welcome to the Space Purple Unicorn Counter!
spuc-1  | 
spuc-1  | :::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::
spuc-1  | 
spuc-1  | :: Try recording a unicorn sighting with:
spuc-1  |     curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
spuc-1  | 
spuc-1  | :: No plugins detected
spuc-1  | 
spuc-1  | 
spuc-1  |             \
spuc-1  |              \
spuc-1  |               \\
spuc-1  |                \\\
spuc-1  |                 >\/7
spuc-1  |             _.-(º   \
spuc-1  |            (=___._/` \            ____  ____  _    _  ____
spuc-1  |                 )  \ |\          / ___||  _ \| |  | |/ ___|
spuc-1  |                /   / ||\         \___ \| |_) | |  | | |
spuc-1  |               /    > /\\\         ___) |  __/| |__| | |___
spuc-1  |              j    < _\           |____/|_|    \____/ \____|
spuc-1  |          _.-' :      ``.
spuc-1  |          \ r=._\        `.       Space Purple Unicorn Counter
spuc-1  |         <`\\_  \         .`-.
spuc-1  |          \ r-7  `-. ._  ' .  `\
spuc-1  |           \`,      `-.`7  7)   )
spuc-1  |            \/         \|  \'  / `-._
spuc-1  |                       ||    .'
spuc-1  |                        \\  (
spuc-1  |                         >\  >
spuc-1  |                     ,.-' >.'
spuc-1  |                    <.'_.''
spuc-1  |                      <'
spuc-1  |     
spuc-1  | 
spuc-1  | Welcome to the Space Purple Unicorn Counter!
spuc-1  | 
spuc-1  | :::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::
spuc-1  | 
spuc-1  | :: Try recording a unicorn sighting with:
spuc-1  |     curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
spuc-1  | 
spuc-1  | :: No plugins detected
spuc-1  |
```

Now... something a bit funny is happening here... why are we seeing the output twice?

We've actually started the same container twice!
We only **stopped** the container when we pressed `[Ctrl+C]`, and didn't remove it.

### Removing the container when it stops

We can stop and remove the container with the `down` command.
```bash
docker compose down
```
```output
[+] Running 2/2
 ✔ Container docker_intro-spuc-1  Removed                                  0.1s
 ✔ Network docker_intro_default   Removed                                  0.2s
```

In practice, you only *need* to use `down` if you *need* to remove the container.
If you just want to stop it, you can use `[Ctrl+C]` like we did before.

### Naming the container

The next item in our list is the name of the container.
We can name the container using the `container_name` key.
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container            # The name of the container
```
```bash
docker compose up -d
```
```output
[+] Running 2/0
 ✔ Network docker-intro_default          Created                           0.0s
 ✔ Container spuc_container              Started                           0.0s
```

::::::::::::::::::::::::::::: spoiler

#### Updating the compose file

You do not necessarily need to `down` your containers to update the configuration, Docker Compose can be *smart* like that.

You can update the `docker-compose.yml` file in your text editor and then run `docker compose up -d` to see the changes take effect.

**Warning**: This is not always foolproof! Some changes will require a rebuild of the container.
It is also worth noting that Docker Compose does not *save* the status with which you started your services.
When you do a `down`, it will look at the *current* file, and stop the services as described in that file.

:::::::::::::::::::::::::::::

### Exporting a port

Currently, if we attempt to record a sighting of a unicorn, we will get a connection refused error. 
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=asteroid\&brightness=242
```
```output
curl: (7) Failed to connect to localhost port 8321 after 0 ms: Could not connect to server
```

This is because we haven't mapped the port from the container to the host.
We can do this using the `ports` key using the notation `host_port:container_port`.

It's worth noting the `ports` key is a list, so we can map multiple ports if we need to,
and that the host and container ports don't have to be the same!

```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:                          # Starts the list of ports to map
      - 8321:8321                   # Maps port 8321 on the host to port 8321 in the container
```
```bash
docker compose up -d
```
```output
[+] Running 2/0
 ✔ Network docker-intro_default          Created                           0.0s
 ✔ Container spuc_container              Created                           0.0s
```

Now we can record a unicorn sighting!
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=asteroid\&brightness=242
```
```output
{"message":"Unicorn sighting recorded!"}
```

### Bind mounts

As before, we want to make sure that our print configuration is being used by SPUC.
We will use a bind mount for this - mapping a file from the host to the container.

As with the CLI, this is (confusingly) done using the `volumes` key.
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:                                        # Starts the list of volumes/bind mounts
      - ./print.config:/spuc/config/print.config    # Bind mounts the print.config file
```
```bash
docker compose up -d
```
``` output
[+] Running 2/2
 ✔ Network docker_intro_default  Created                           0.1s
 ✔ Container spuc_container      Started                           0.2s
```

Now, if you record some sightings, you should see them formatted according to the configuration in `print.config`.

As before, whether a bind mount or volume is performed is based on whether the argument on the left of the colon is a *name* or a *path*.
If it is a *path* (i.e. starts with `/` or `./`), it generates a bind mount.
Otherwise, it generates a volume.

### Volumes

Let's add a volume to persist the unicorn sightings between runs of the container.
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output                  # Mounts the volume named spuc-volume
```
```bash
docker compose up -d
```
```output
service "spuc" refers to undefined volume spuc-volume: invalid compose project
```

Oops! We forgot to declare the volume!
Although we added the instruction to use the volume, we didn't tell Docker Compose that we needed that volume.

We can do this by adding a `volumes` key to the file.
The volumes are separate from *services*, so they are declared at the same level.
To declare a named volume, we specify its name and end with a `:`.
We will do this at the end of the file.
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output              # Mounts the volume named spuc-volume

volumes:                                      # Starts section for declaring volumes
  spuc-volume:                                # Declares a volume named spuc-volume
```
```bash
docker compose up -d
```
```output
[+] Running 2/2
 ✔ Volume "docker_intro_spuc-volume"  Created                            0.0s
 ✔ Container spuc_container           Started                           10.3s
```
Now, if you record some sightings and then stop and start the container, you should see that the sightings are still there!

However, we can now use a cool feature of Docker Compose - the ability to remove volumes when the container is removed.

We can do this using the `-v` flag with the `down` command. Which tells Docker to remove any volumes named in the `volumes` key.

You can confirm this by running `docker volume ls` before and after running `down`.

```bash
$ docker volume ls
$ docker compose down -v
$ docker volume ls
```
```output
DRIVER        VOLUME NAME
local         docker_intro_spuc-volume
local         spuc-volume

[+] Running 3/3
 ✔ Container spuc_container         Removed                   10.2s
 ✔ Volume docker_intro_spuc-volume  Removed                    0.0s
 ✔ Network docker_intro_default     Removed                    0.2s

DRIVER        VOLUME NAME
local         spuc-volume
```

### Setting an environment variable

Next, we need to set the `EXPORT` environment variable to `true`.
This is done using the `environment` key.

```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
    environment:                      # Starts list of environment variables to set
      - EXPORT=true                   # Sets the EXPORT environment variable to true

volumes:
  spuc-volume:
```
```bash
docker compose up -d
docker compose logs
```
```output
[...]
spuc_container  | 
spuc_container  | :::: Unicorn sightings export activated! ::::
spuc_container  | :: Try downloading the unicorn sightings record with:
spuc_container  |     curl localhost:8321/export
spuc_container  |
```

We can see that the environment variable has been set by the output of the tool and the export functionality is now available.

### Overriding the default command

Finally, lets set the units by overriding the command, as we did before.
For this, we use the `command` key.

```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]          # Overrides the default command

volumes:
  spuc-volume:
```
```bash
docker compose up -d
docker compose logs
```
```output
[...]
spuc_container  | 
spuc_container  | :::: Units set to Intergalactic Unicorn Luminosity Units [iulu] ::::
spuc_container  |
[...]
```

### Enabling the plugin

We're nearly back to where we were with our `docker run` command!
The only thing we are missing is enabling the plugin.

We used a bind mount before to put the plugin file in the container, so lets try again:
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py        # Mounts the stats.py plugin
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

volumes:
  spuc-volume:
```
```bash
docker compose up -d
```
```output
[+] Running 1/1
 ✔ Container spuc_container  Started                            10.3s
```

Seems to have worked, lets look at the logs to see if the plugin was loaded.
```bash
docker compose logs
```
```output
spuc_container  | Traceback (most recent call last):
spuc_container  |   File "/spuc/spuc.py", line 31, in <module>
spuc_container  |     __import__(f"{plugin_dir}.{plugin[:-3]}")
spuc_container  |   File "/spuc/plugins/stats.py", line 4, in <module>
spuc_container  |     import pandas as pd
spuc_container  | ModuleNotFoundError: No module named 'pandas'
```

Oh no! We've hit an error! The `pandas` library isn't installed in the container -
which was the whole reason that we made our own container in the first place!

Let's go back to that.

## Building containers in Docker Compose

We could use the tag we used when we built the container to use that image.
However, this would mean that if we want to adjust our locally built container, we would have to rebuild it separately.

Instead, we can use the `build` key to tell Docker Compose to build the container if needed.

To do that, we use the `build` key instead of the `image` key:
```yml
services:
  spuc:
  # image: spuacv/spuc:latest
    build:                        # Instead of using the 'image' key, we use the 'build' key
      context: .                  # Sets the build context (the directory in which the Dockerfile is located)
      dockerfile: Dockerfile      # Sets the name of the Dockerfile
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
```

This tells docker compose to look for the Dockerfile in the current directory.
If needed, it will then build the container and tag it with the current directory and service names.

Now, we have to be a little careful with our up command!
If we run `up`, Docker Compose will default to checking if the image exists and if it does, it will use that image.
This is ok... unless we have made changes to the Dockerfile!

To ensure that the image is built, we can run `docker compose build`.
This will build (all) the image(s) specified inside our `docker-compose.yml`.
After building, we use the usual `up` command.

Alternatively, we can add the `--build` flag to the `up` command, which results in Docker building the image right before starting the container.
This will rebuild the image every time you run it, but use cached layers if they exist.

Let's start our services using that flag, and verify that the plugin is loaded.
```bash
docker compose up --build -d
docker compose logs
```
```output
[+] Building 9.2s (10/10) FINISHED                                                        docker:default
 => [spuc internal] load build definition from Dockerfile                                           0.0s
 => => transferring dockerfile: 250B                                                                0.0s
 => [spuc internal] load metadata for docker.io/spuacv/spuc:latest                                  0.0s
 => [spuc internal] load .dockerignore                                                              0.0s
 => => transferring context: 2B                                                                     0.0s
 => [spuc 1/4] FROM docker.io/spuacv/spuc:latest                                                    0.1s
 => [spuc internal] load build context                                                              0.0s
 => => transferring context: 546B                                                                   0.0s
 => [spuc 2/4] RUN pip install pandas                                                               8.5s
 => [spuc 3/4] COPY stats.py /spuc/plugins/stats.py                                                 0.0s 
 => [spuc 4/4] COPY print.config /spuc/config/print.config                                          0.0s 
 => [spuc] exporting to image                                                                       0.5s 
 => => exporting layers                                                                             0.5s 
 => => writing image sha256:b17d7f75ac398b083476cc3fda502875b1d1355b59ad2bdc9d0526f202be9c05        0.0s 
 => => naming to docker.io/library/docker_intro-spuc                                                0.0s 
 => [spuc] resolving provenance for metadata file                                                   0.0s
[+] Running 1/1
 ✔ Container spuc_container  Started                                                                0.3s
[...]
spuc_container  | 
spuc_container  | :::: Plugins loaded! ::::
spuc_container  | :: Available plugins
spuc_container  |     stats.py
spuc_container  | 
[...]
 ```

You should now have a container running with the stats plugin enabled!


::::::::::::::::::::::::::: spoiler

#### Simpler Dockerfile

You may have noticed that we ended up *duplicating* most of the configuration from the Dockerfile within the `docker-compose.yml` file.

In reality, if we are using Docker Compose we do not need to bake in all of the configuration inside the Dockerfile.
The only thing that was different was the `pip install pandas` command.
Therefore, our dockerfile could be as simple as this:
```Dockerfile
FROM spuacv/spuc:latest
RUN pip install pandas
```

Alternatively, we could simplify our `docker-compose.yml` file by removing the duplicated configuration.
However, this would make the `docker-compose.yml` file less self-contained and more dependent on the Dockerfile.
It is usually a better idea to keep the configuration in the `docker-compose.yml` file, as it makes it easier to understand and maintain.

:::::::::::::::::::::::::::::::::::

## Connecting multiple services

We have now managed to replicate our `docker run` command in a more readable and maintainable way.

There is an argument to be made that, even for running a single service, Docker Compose is a useful tool.
It brings an ephemeral run command, that would need careful documentation to replicate, into a single file that can be version controlled and shared.
It is also much easier on the eye than a long `docker run` command!

Where Docker Compose really shines, though, is when you have multiple services that need to be run together.
And we happen to have another service that we need to run - SPUCSVi!

### Adding SPUCSVi to our Docker Compose file

We can add SPUCSVi to our Docker Compose file in the same way that we added SPUC, by adding another service to the `services` key.

The SPUCSVi documentation helpfully provides a table of configuration options what we can use to configure the service, reproduced here:

| Item       | Description                                                | Default                     |
|------------|------------------------------------------------------------|-----------------------------|
| Image Name | The name of the image to use                               | `spuacv/spucsvi:latest`     |
| Port       | The container port the service runs on                     | `8322`                      |
| SPUC_URL   | An environment variable to set the URL of the SPUC service | `http://spuc:8321`          |

We can use this to add SPUCSVi to our Docker Compose file!

But how do we know the correct URL for the SPUC service?
This touches on a couple of clever tricks that Docker Compose uses to make running multiple services easier.

First, Docker Compose creates a network for each stack that it starts.
This means that, unless overridden, all services in the stack can communicate with each other.

Second, Docker Compose uses the service name as the hostname for the service.
This means that we can use the service name as the hostname in the URL!
For our service named `spuc`, the hostname would be `spuc` with the protocol `http` prepended and `port` appended i.e. `http://spuc:8321`.

Knowing this, we are able to add SPUCSVi to our Docker Compose file!
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

  spucsvi:                            # Declare a new service named spucsvi
    image: spuacv/spucsvi:latest      # Specify the image to use
    container_name: spucsvi_container # Name the container spucsvi
    ports:                            # 
      - "8322:8322"                   # Map port 8322 on the host to port 8322 in the container
    environment:                      # 
      - SPUC_URL=http://spuc:8321     # Specify the SPUC_URL environment variable

volumes:
  spuc-volume:
```

Now both services will be started at the same time!

```bash
docker compose up -d
docker compose logs
```
```output
[+] Running 3/3
 ✔ Network docker_intro_default  Created                                                           0.1s
 ✔ Container spuc_container      Created                                                           0.0s
 ✔ Container spucsvi_container   Created                                                           0.0s
Attaching to spuc_container, spucsvi_container
spuc_container     |
spuc_container     |             \
spuc_container     |              \
spuc_container     |               \\
spuc_container     |                \\\
spuc_container     |                 >\/7
spuc_container     |             _.-(º   \
spuc_container     |            (=___._/` \            ____  ____  _    _  ____
spuc_container     |                 )  \ |\          / ___||  _ \| |  | |/ ___|
spuc_container     |                /   / ||\         \___ \| |_) | |  | | |
spuc_container     |               /    > /\\\         ___) |  __/| |__| | |___
spuc_container     |              j    < _\           |____/|_|    \____/ \____|
spuc_container     |          _.-' :      ``.
spuc_container     |          \ r=._\        `.       Space Purple Unicorn Counter
spuc_container     |         <`\\_  \         .`-.
spuc_container     |          \ r-7  `-. ._  ' .  `\
spuc_container     |           \`,      `-.`7  7)   )
spuc_container     |            \/         \|  \'  / `-._
spuc_container     |                       ||    .'
spuc_container     |                        \\  (
spuc_container     |                         >\  >
spuc_container     |                     ,.-' >.'
spuc_container     |                    <.'_.''
spuc_container     |                      <'
spuc_container     |
spuc_container     |
spuc_container     | Welcome to the Space Purple Unicorn Counter!
spuc_container     |
spuc_container     | :::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::
spuc_container     |
spuc_container     | :: Try recording a unicorn sighting with:
spuc_container     |     curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
spuc_container     |
spuc_container     | :::: Plugins loaded! ::::
spuc_container     | :: Available plugins
spuc_container     |     stats.py
spuc_container     |
spuc_container     | :::: Unicorn sightings export activated! ::::
spuc_container     | :: Try downloading the unicorn sightings record with:
spuc_container     |     curl localhost:8321/export
spuc_container     |
spucsvi_container  |
spucsvi_container  |      .-'''-. .-------.   ___    _     _______      .-'''-. ,---.  ,---..-./`)
spucsvi_container  |     / _     \\  _(`)_ \.'   |  | |   /   __  \    / _     \|   /  |   |\ .-.')
spucsvi_container  |    (`' )/`--'| (_ o._)||   .'  | |  | ,_/  \__)  (`' )/`--'|  |   |  .'/ `-' \
spucsvi_container  |   (_ o _).   |  (_,_) /.'  '_  | |,-./  )       (_ o _).   |  | _ |  |  `-'`"`
spucsvi_container  |    (_,_). '. |   '-.-' '   ( \.-.|\  '_ '`)      (_,_). '. |  _( )_  |  .---.
spucsvi_container  |   .---.  \  :|   |     ' (`. _` /| > (_)  )  __ .---.  \  :\ (_ o._) /  |   |
spucsvi_container  |   \    `-'  ||   |     | (_ (_) _)(  .  .-'_/  )\    `-'  | \ (_,_) /   |   |
spucsvi_container  |    \       / /   )      \ /  . \ / `-'`-'     /  \       /   \     /    |   |
spucsvi_container  |     `-...-'  `---'       ``-'`-''    `._____.'    `-...-'     `---`     '---'
spucsvi_container  |
spucsvi_container  |     :::: SPUC Super Visualizer serving on localhost:8322 ::::
spucsvi_container  |
```


As the logs suggest, we can now view the SPUCSVi interface by visiting `localhost:8322` in our browser.

A visual treat awaits, and an easier way to record and view our unicorn sightings!

### Networks

We briefly mentioned networks earlier, noting that, by default, Docker Compose creates a network for each stack.

However, by overriding the default network, we can perform some interesting tricks.

Now that we can record Unicorns using the SPUCSVi interface, we don't need to be able to access the SPUC service directly.

This means we can isolate the SPUC service from the host network.
This is a good security practice and helps keep things tidy.

To do this we need to stop exposing the ports for SPUC, by removing the `ports` key from the SPUC service:
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    # ports:                            # We can remove these two lines
    #   - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321

volumes:
  spuc-volume:
```

```bash
docker compose up -d
```

Now, the SPUC service is only accessible from within the Docker network!
Try doing a curl to register a sighting and you wont be able to.
However, you can still register sightings through the SPUCSVi interface.

This can be taken further to create networks with very limited purposes.
For example in a typical web app you may make it so that the frontend can connect only to backend, but not to the database.

::::::::::::::::::::::::::::::::::: spoiler

#### Network names

You may have noticed that the network that Docker Compose created for our stack is named `docker_intro_default`.
This is because Docker Compose uses the name of the directory that the `docker-compose.yml` file is in as the name of the network.

If you want to specify the name of the network, you can use the `networks` key in the `docker-compose.yml` file.
You also need to specify the network name for each service that you want to connect to the network.

For example, to specify the network name as `spuc_network`, you would add the following to the file:

```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
    networks:                         # Starts list of networks to connect this service to
      - spuc_network                  # Connects to the spuc_network network

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    networks:                         # Starts list of networks to connect this service to
      - spuc_network                  # Connects to the spuc_network network

volumes:
  spuc-volume:

networks:                             # Starts section for declaring networks
  spuc_network:                       # Declares a network for spuc
    name: spuc_network                # Specifies the name of the network
```

:::::::::::::::::::::::::::::::::::::::::::

### Depends on

There is an important problem that we haven't addressed yet - what happens if the SPUCSVi service starts before the SPUC service?

This is a common problem when running multiple services together - services that depend on each other need to start in a specific order.

Docker Compose has a solution to this - the `depends_on` key.

We can use this key to tell Docker Compose that the SPUCSVi service depends on the SPUC service.
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:                     # Starts section for declaring dependencies
      - spuc                        # Declares that the spucsvi service depends on the spuc service

volumes:
  spuc-volume:
```

Now, when we run `docker compose up`, the SPUCSVi service will wait until SPUC has started before it starts.

But there is a catch!
The `depends_on` key only ensures that the service is started in the correct order.
It doesn't check if the service is *ready*!

This can be a problem if a service is fast to start but slow to be ready.
For example, a database service may start quickly, but take a while to be ready to accept connections.

To address this, Docker Compose allows you to define a `healthcheck` for a service.
This is a command that is run periodically (from inside the container) to check if the service is *ready*.
The command failing (returning a non-zero exit code) means that the service is not ready.

We can try this out by adding a `healthcheck` to the SPUC service.
Since we don't want SPUCSVi to start until the record of unicorn sightings is ready,
we can use the `curl` command to check if the `/export` endpoint is available.
We need to add the `--fail` flag to `curl` to ensure that it returns a non-zero exit code if the endpoint is not available.

The other change we need to make is to add a `condition` to the `depends_on` key in the SPUCSVi service.
This tells Docker Compose to only start the service if the service it depends on is *healthy*, rather than just *started*.
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
    healthcheck:                                                  # Starts section for declaring healthchecks
      test: ["CMD", "curl", "--fail", "http://spuc:8321/export"]  # Specifies the healthcheck command (ran from inside the container)
      interval: 3s                                                # Specifies the interval between healthchecks
      timeout: 2s                                                 # Specifies the timeout for the healthcheck
      retries: 5                                                  # Specifies the number of retries before failing completely

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:
      spuc:                                                       # This changed from a list (- spuc) to a mapping (spuc:)
        condition: service_healthy                                # Specifies further conditions for starting the service

volumes:
  spuc-volume:
```

Now, when we run `docker compose up`, the SPUCSVi service will only start when the SPUC service is *ready*.

::::::::::::::::::::::::::::::::::: spoiler

#### Simulating a slow start

This is a little hard to see in action as the SPUC service starts so quickly.
To be able to see it, let's add a `sleep` command to the `entrypoint` of the SPUC service to simulate a slow start.

```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
    entrypoint: ["sh", "-c", "sleep 5 && python /spuc/spuc.py"]   # Adds a sleep command to the entrypoint to simulate a slow start
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://spuc:8321/export"]
      interval: 3s
      timeout: 2s
      retries: 5

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:
      spuc:
       condition: service_healthy

volumes:
  spuc-volume:
```
```bash
docker compose up -d
```
```output
[+] Running 3/3
 ✔ Network docker_intro_default  Created                                   0.1s 
 ✔ Container spuc_container      Healthy                                   6.7s 
 ✔ Container spucsvi_container   Started                                   6.8s
```

As yoy can see, the SPUCSVi service only started after the SPUC service was healthy.

:::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::: spoiler

#### Simulating an unhealthy service

To simulate a service that does not pass the healthcheck,
we can set the `EXPORT` environment variable to `false` in the SPUC service.
This will mean that the export endpoint is not available, so the healthcheck will fail.
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=false                                # Sets the EXPORT environment variable to false
    command: ["--units", "iulu"]
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://spuc:8321/export"]
      interval: 3s
      timeout: 2s
      retries: 5

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:
      spuc:
       condition: service_healthy

volumes:
  spuc-volume:
```
```bash
docker compose up -d
```
```output
[+] Running 3/3
 ✔ Network docker_intro_default  Created                                                            0.1s 
 ✘ Container spuc_container      Error                                                             15.7s 
 ✔ Container spucsvi_container   Created                                                            0.0s 
dependency failed to start: container spuc_container is unhealthy
```

The SPUC service shows an error, because it failed all 5 retries, and the SPUCSVi service was not started.

**Warning**: Even though *unhealthy*, the `spuc_container` is running. You can check this by running `docker ps`.

:::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::: keypoints
- Docker Compose is a tool for defining and running multi-container stacks in a YAML file.
  They can also serve as a way of structuring and documenting `docker run` commands for single containers.
- Instructions are saved in a `docker-compose.yml` file, where services, networks, and volumes are defined.
- Each `service` is a separate container, and it can be fully configured from within the file.
- Bind mounts and `volumes` can be declared for each service, and they can be shared between containers too.
- You can define `networks`, which can be used to connect or isolate containers from each other.
- All the services, volumes and networks are started together using the `docker compose up` command.
- They can be stopped using the `docker compose down` command.
- Container images can be built as the services are spun up by using the `--build` flag.
- The order in which services start can be controlled using the `depends_on` key.
- A `healthcheck` can be defined to verify the status of a service.
  These are commands run from within the container to make sure it is *ready*.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
