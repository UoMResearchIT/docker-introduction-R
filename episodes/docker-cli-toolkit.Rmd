---
title: Building our Docker CLI toolkit
teaching: 99
exercises: 99
---

Before we start to tackle Docker tasks that are only possible in the command line,
we need to build up our toolkit of Docker commands that allow us to perform the same tasks we learned to do in Docker Desktop.

:::::::::::::::::::::::::::::::::::::::: questions
- How do I use the Docker CLI to perform the same tasks we learned to do in Docker Desktop?
::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::: objectives
- Build our fundamental Docker CLI toolkit
::::::::::::::::::::::::::::::::::::::::::::::::::

## Pulling and Listing Images

To run an image, first we need to download it. You may remember that, in Docker, this is known as *pulling* an image.

Let’s try pulling the SPUC container that we used before:
```bash
docker pull spuacv/spuc:latest
```

If it is the first time you pull this image, you will see something like this:
```output
latest: Pulling from spuacv/spuc
302e3ee49805: Pull complete
6b08635bc459: Pull complete
18bb7c8edce2: Pull complete
8341816e3d13: Pull complete
174a3dce8e2a: Pull complete
67d0d37078fb: Pull complete
4a705a772a90: Pull complete
bd9732a6317b: Pull complete
44c70b826ff3: Pull complete
cee1b3575f12: Pull complete
Digest: sha256:ad219064aaaad76860c53ec8420730d69dc5f8beb9345b0a15176111c2a976c5
Status: Downloaded newer image for spuacv/spuc:latest
docker.io/spuacv/spuc:latest
```

If you'd already downloaded it before, you will instead get something like this:
```output
latest: Pulling from spuacv/spuc
Digest: sha256:ad219064aaaad76860c53ec8420730d69dc5f8beb9345b0a15176111c2a976c5
Status: Image is up to date for spuacv/spuc:latest
docker.io/spuacv/spuc:latest
```

This just means Docker detected you already had that image, so it didn't need to download it again.

The structure of the command we just used will be the same for most of the commands we will use in the Docker CLI,
so it is worth taking a moment to understand it.

::::::::: callout

## The structure of a Docker command

The Docker CLI can be intimidating, as it is easy to get very long commands that take a bit of work to understand.
However, when you understand the structure of the commands it becomes much easier to understand what is happening.

Let's dive into the structure of the command we looked at. Here is a diagram which breaks things down:

![](fig/docker_cmd.png){alt='A diagram showing the syntactic structure of a Docker command'}

* Every Docker command starts with 'docker'
* Next, you specify the type of object to act on (e.g. image, container)
* Followed by the action to perform and the name of the object (e.g. run, pull)
* You can also include additional arguments and switches as needed (e.g. the image name)

### TODO: Update the diagram to use the pull command instead!

:::::::::::::::::

## Listing Images

Now that we have pulled our image, let's check that it is there:
```bash
docker image ls
```
```output
REPOSITORY                              TAG        IMAGE ID       CREATED         SIZE
spuacv/spuc                             latest    ce72bd42e51c   3 days ago      137MB
```

This command lists (ls is short for list) all the images that we have downloaded.
It is the equivalent of the 'Images' tab in Docker Desktop.
You should see the SPUC image listed here, along with some other information about it.

## Inspecting

You may remember that in Docker Desktop we could explore the image buildup and the image's metadata.
We called this 'inspecting' the image.
To inspect an image using the Docker CLI, we can use:
```bash
docker inspect spuacv/spuc:latest
```
```output
[
    {
        "Id": "sha256:ce72bd42e51c049fe29b4c15dc912e88c4461e94c2e1d403b90e2e53dfb1b420",
        "RepoTags": [
            "spuacv/spuc:latest"
        ],
        "RepoDigests": [
            "spuacv/spuc@sha256:ad219064aaaad76860c53ec8420730d69dc5f8beb9345b0a15176111c2a976c5"
        ],
        "Parent": "",
        "Comment": "buildkit.dockerfile.v0",
        "Created": "2024-10-11T14:05:59.254831281+01:00",
        "DockerVersion": "",
        "Author": "",
        "Config": {
[...]
```

This tells you **a lot** of details about the image.
This can be useful for understanding what the image does and how it is configured but it is also quite overwhelming!

The most useful information for an image user is what the container will do when it is run.
We highlighted the `command` and `entrypoint` while inspecting images in Docker Desktop.
Let's work on getting this information *only*.

To do that we will refine our command using the `-f` flag to specify the output format.
Lets try running the following command:
```bash
docker inspect spuacv/spuc:latest -f "Command: {{.Config.Cmd}}"
```
```output
Command: [--units iuhc]
```

That's more manageable! How does it work?

The result of the inspect command is a JSON object, so we can access elements from the output hierarchically.
The `command` is part of the image's `Config`, which is at the base of the json object.
When we use double curly braces, docker understands we want to access the value of the key `Cmd` in the `Config` object.

We can do a similar thing to extract the entrypoint:
```bash
docker inspect spuacv/spuc:latest -f "Entrypoint: {{.Config.Entrypoint}}"
```
```output
Entrypoint: [python /spuc/spuc.py]
```

or even get them both at the same time:
```bash
docker inspect spuacv/spuc:latest -f "Command: {{.Config.Cmd}}\nEntrypoint: {{.Config.Entrypoint}}"
```
```output
Command: [--units iuhc]
Entrypoint: [python /spuc/spuc.py]
```

Great! So we know what the command and entrypoint are... but what do they mean?

::::::::: callout

## Default Command

The default command is the command that a container will run when it is started.
The default values are specified by the creator of an image, but can be overridden when the container is run.

The default command is formed of two parts, the *entrypoint* and the *command*.
The two are concatenated to form the full command.

### TODO: Add a diagram showing the structure of the default command, putting the bullet points in the image, as you did with the docker command diagram.

* **Entrypoint** is usually the base command for the container. It is not often overwritten.
* **Command** is commonly the set of parameters for the base command. This is overwritten frequently.

In our case, the entrypoint is `python /spuc/spuc.py` and the command is `--units iuhc`.
This means that when the container is run, it will execute the command `python /spuc/spuc.py --units iuhc`.

As mentioned, the command is commonly overwritten when the container is run.
This means we could pass different parameters to the python script when we run the container.

:::::::::::::::::

## Running

Now that we have the image, and we know what it will do, let's run it!
```bash
docker run spuacv/spuc:latest
```
```output

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


Welcome to the Space Purple Unicorn Counter!

:::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::")

:: Try recording a unicorn sighting with:
    curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```

And there we have it! The SPUC container is running and ready to count unicorns.
What we are seeing now is the equivalent of the 'Logs' tab in Docker Desktop.

The only problem we have though, is that it is 'blocking' this terminal,
so we can't run any more commands until we stop the container.

Let's stop the container using `[Ctrl+C]`, and run it again, but in the background,
'detached' from the terminal, using the `-d` flag:
```bash
docker run -d spuacv/spuc:latest
```
```output
0bb79cbb589652c265552913f6de7992cd996f6da97ecc9ba43672fe34ff5f23
```

**Note:** The `-d` flag needs to go in front of the image name!

But what is happening? We can't see the output of the container anymore!
Is the container running or not?

## Listing Containers

To see what is happening, we can use the `docker ps` command:
```bash
docker ps
```
```output
CONTAINER ID   IMAGE                  COMMAND                  CREATED              STATUS              PORTS        NAMES
0bb79cbb5896   spuacv/spuc:latest     "python /spuc/spuc.p…"   About a minute ago   Up About a minute   8321/tcp     ecstatic_nightingale
```

This command lists all the containers that are currently running.
It is the equivalent of the 'Containers' tab in Docker Desktop, except that it only shows running containers.
You can see that the SPUC container is running, and that it has been given a random name `ecstatic_nightingale`.

If you want to see all containers, including those that are stopped, you can use the `-a` flag:
```bash
docker ps -a
```
```output
CONTAINER ID   IMAGE                  COMMAND                  CREATED              STATUS                       PORTS        NAMES
0bb79cbb5896   spuacv/spuc:latest     "python /spuc/spuc.p…"   About a minute ago   Up About a minute            8321/tcp     ecstatic_nightingale
03ef43deee20   spuacv/spuc:latest     "python /spuc/spuc.p…"   10 minutes ago       Exited (0) 10 minutes ago                 suspicious_beaver
```



## Logs

So we know it is running, but we can't see the output of the container.
We can still access them though, we just need to ask Docker for the logs:
```bash
docker logs ecstatic_nightingale
```
```output

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


Welcome to the Space Purple Unicorn Counter!

:::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::")

:: Try recording a unicorn sighting with:
    curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```

Notice that we had to use the name of the container, `ecstatic_nightingale`, to get the logs.
This is because the `docker logs` command requires the name of the **container** not the **image**.


Great, now that we have a container in the background, lets try to register a unicorn sighting!
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```
```output
curl: (7) Failed to connect to localhost port 8321 after 0 ms: Couldn't connect to server
```

That is right! We need to expose the port to the host machine, as we did in Docker Desktop.

## Exposing ports

The container is running in its own isolated environment.
To be able to communicate with it, we need to tell Docker to expose the port to the host machine.

This can be done using the `-p` flag.
We also need to specify the port to be used on the host machine and the port to expose on the container, like so:
```
-p <host_port>:<container_port>
```

In this case we want to expose port 8321 on the host machine to port 8321 on the container:
```bash
docker run -d -p 8321:8321 spuacv/spuc:latest
```
```output
6edf9ebd404625541fdb674d1a696707bad775a0161882ef459c5cbcb151e24b
```

If you now look at the container that is running, you will see that the port is exposed:
```bash
docker ps
```
```output
CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS         PORTS                                       NAMES
6edf9ebd4046   spuacv/spuc:latest  "python /spuc/spuc.p…"   4 seconds ago   Up 3 seconds   0.0.0.0:8321->8321/tcp, :::8321->8321/tcp   unruffled_noyce
```
### TODO why does it say `:::8321->8321/tcp`?

So we can finally try to register a unicorn sighting:
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```
```output
{"message":"Unicorn sighting recorded!"}
```

And of course we can check the logs if we want to:
```bash
docker logs unruffled_noyce
```
```output
[...]

::::: 2024-10-15 11:19:47.751212 Unicorn spotted at moon!! Brightness: 100 iuhc
```

It can be quite inconvenient to have to find out the name of the container every time we want to see the logs,
and it is not the only time in which we'll need the name of the container to interact with it.
We can make our lives easier by naming the container when we run it.

## Setting the name of a container

We can name the container when we run it using the `--name` flag:
```bash
docker run -d --name spuc_container -p 8321:8321 spuacv/spuc:latest
```
```output
4696d5301a792451f9954ba10cc42604a904fa1a811362733050ba04270c02eb
docker: Error response from daemon: driver failed programming external
connectivity on endpoint spuc_container (67e075648d16fafdf086573169d891bee9b33bec0c1cb5535cf82c715241bb32):
 Bind for 0.0.0.0:8321 failed: port is already allocated.
```

Oops! It looks like we already have a container running on port 8321.
Of course, it is the container that we ran earlier, unruffled_noyce, and we can't have two containers running on the same port!

To fix this, we can stop the container that is running on port 8321 using the `docker stop` command:
```bash
docker stop unruffled_noyce
```
```output
unruffled_noyce
```

**Note:** Using `docker kill <container_name>`, will also work, although it is best to leave that as a last resort.

Right, now we can try running the container again:
```bash
docker run -d --name spuc_container -p 8321:8321 spuacv/spuc:latest
```
```output
bf9b2abc95a7c7f25dc8c1c4c334fcf4ce9642754ed7f6b5586d82f9e9e45ac7
```

And now we can see the logs using the name of the container, and even follow the logs in real time using the `-f` flag:
```bash
docker logs -f spuc_container
```

::: spoiler

### Logs

```output

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


Welcome to the Space Purple Unicorn Counter!

:::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::")

:: Try recording a unicorn sighting with:
    curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100

```

:::

This also blocks the terminal, so you will need to use `[Ctrl+C]` to stop following the logs.
There is an important difference though.
Because the container is running in the background, using `[Ctrl+C]` will not stop the container, only the log following.

## Executing commands in a running container

One of the very useful things we could do in docker compose was to run commands inside a container.
If you remember, we could do this using the `Exec` tab.
In the Docker CLI, we can do this using the `docker exec` command.
Lets try for example:
```bash
docker exec spuc_container cat config/print.config
```
```output
# This file configures the print output to the terminal.
# Available variables are: count, time, location, brightness, units
# The values of these variables will be replaced if wrapped in curly braces.
# Lines beginning with # are ignored.
::::: {time} Unicorn spotted at {location}!! Brightness: {brightness} {units}
```

This command runs `cat config/print.config` inside the container.
This is a step forward, but it is not quite the experience we had in Docker Desktop.
There, we had a live terminal *inside* the container,
and we could run commands interactively.

To do that, we need to use the `-it` flag, and specify a command that will load the terminal, i.e. `bash`.
Let's try launching an interactive terminal session inside the container, running the bash shell:
```bash
docker exec -it spuc_container bash
```
```output
root@50159dddde44:/spuc#
```

This is more like it! now we can run commands as if we were inside the container itself, as we did in Docker Desktop.
```bash
apt update
apt install tree
tree
```
```output
[...]

.
├── __pycache__
│   └── strings.cpython-312.pyc
├── config
│   └── print.config
├── output
├── requirements.txt
├── spuc.py
└── strings.py

4 directories, 5 files
```

To get out from this interactive session, we need to use `[Ctrl+D]`, or type `exit`.

::::::::::::::::::::::::::::::::::::::: callout

## Interactive sessions

The `-it` flag that we just used is very useful.
It actually helps us overcome the problem we had with the `alpine` container in the previous episode.
If we were to simply run the `alpine` container we would have the same issue we had before.
Namely, the container exits immediately and we can't `exec` into it.
However, we can use the `-it` flag on the `run` command, and get an interactive terminal session inside the container:
```bash
docker run -it alpine:latest
```
```output
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
43c4264eed91: Pull complete
Digest: sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d
Status: Downloaded newer image for alpine:latest
/ #
```

We are inside the container, and it stayed alive because we are running an interactive session.
We can play inside as much as we want, and when we are done, we can simply type `exit` to leave the container.
As opposed to the `spuc` container, which was running a service and we exec'ed into, this container will be terminated on exit.

:::::::::::::::::::::::::::::::::::::::::::::::

## Reviving Containers

Another thing Docker Desktop allowed us to do was to wake up a previously stopped container.
We can of course do the same thing in the Docker CLI.

To show this, lets first stop the container we have running:
```bash
docker stop spuc_container
```
```output
spuc_container
```

To *revive* the container, we can use the `docker start` command:
```bash
docker start spuc_container
```
```output
spuc_container
```

We could now check that the container is running again using the `docker ps` command.
However, lets try another useful command:
```bash
docker stats
```
```output
CONTAINER ID   NAME              CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O        PIDS
bf9b2abc95a7   spuc_container    0.01%     23.61MiB / 15.29GiB   0.15%     23.6kB / 589B     5.1MB / 201kB    5
```

This command lets us see the live resource usage of containers, similar to the task manager on Windows or top on Linux.
We can exit the stats with `[Ctrl+C]`.

As we can see, the container is alive and well, and we can now exec into it again if we want to.

## Cleaning up

The last thing we need to know is how to clean up after ourselves.
We can do this using the `docker rm` command to remove a container,
and the `docker image rm` command to remove an image:
```bash
docker stop spuc_container
```
```output
spuc_container
```
```bash
docker rm spuc_container
```
```output
spuc_container
```
```bash
docker image rm spuacv/spuc:latest
```
```output
Untagged: spuacv/spuc:latest
Untagged: spuacv/spuc@sha256:ad219064aaaad76860c53ec8420730d69dc5f8beb9345b0a15176111c2a976c5
Deleted: sha256:ce72bd42e51c049fe29b4c15dc912e88c4461e94c2e1d403b90e2e53dfb1b420
Deleted: sha256:975e4f6d3de315ced48fa0d0eda7e3af5cd4953c16adfbd443e65d6d2bf0eaa6
Deleted: sha256:f3fc2c0e51d4240d55e40b0305762df66600cdd5073a5c92008cfe8f867f5437
Deleted: sha256:f3e2fffff5c16237e6507a6196eb76fd2eba64e343c3a1b2692b73b95fcd1298
Deleted: sha256:d4d3e0d103c04b9fd2eb428699c46302a3d38d695729ee49068be07ad7e5c442
Deleted: sha256:700c7bb1865e2ca492d821c689f11175c66e9d27f210b3f04521040290c34126
Deleted: sha256:5d5adb77457c9a495a5037ce44a0db461b8d3b605177a2c3bc6dc0d7876a681d
Deleted: sha256:3a77b40519ce3ffa585333bab02f30371b4c8c7ffa10a35fd4c82a0d3423fa91
Deleted: sha256:791eb7562f83ac1fc48aa6f31129bf947d7de7d8c9b85db92131c3beb5650bd6
Deleted: sha256:c59180f9a5f41ea7e3d92ee36d5b4c01dadf5148075c0d01c394f7efc321a3ca
Deleted: sha256:8d853c8add5d1e7b0aafc4b68a3d9fb8e7a0da27970c2acf831fe63be4a0cd2c
```

An alternative is to do a single-line full clean up.
We can also remove all stopped containers and unused images using the `docker system prune` command:
```bash
docker system prune
```
```output
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - unused build cache

Are you sure you want to continue? [y/N] y
Deleted Containers:
90d006980a999176dd82e95119556cdf62431c26147bdbd3513e1733be1a5897

Deleted Images:
untagged: ghcr.io/uomresearchit/spuc@sha256:bc43ebfe7dbdbac5bc0b4d849dd2654206f4e4ed1fb87c827b91be56ce107f2e
deleted: sha256:f03fb04b8bc613f46cc1d1915d2f98dcb6e008ae8e212ae9a3dbfaa68c111476

Total reclaimed space: 13.09MB
```

### Automatic cleanup

There is one more point to make.
It is nice not to have to clean up containers manually all the time.
Luckily, the Docker CLI has a flag that will remove the container when it is stopped: `--rm`.
This can be very useful, especially when you are naming containers, as it prevents name conflicts.

Lets try it:
```bash
docker run -d --rm --name spuc_container -p 8321:8321 spuacv/spuc:latest
```

We can verify that the container exists using `docker ps`.
When the container is stopped, however, the container is automatically removed.
We don't have to worry about cleaning up afterwards, but it comes at a price.
Since we've deleted the container, there is no way to bring it back.

We will use the command going forward, as it is a good practice to keep your system clean and tidy.

<br>

The last command we ran is a relatively standard command in the Docker CLI.
If you are thinking "wow, that command is getting pretty long...", you are right!
Things will get even worse before they get better, but we will cover how to manage this later in the course.

We are now equipped with everything we saw we could do in Docker Desktop, but with steroids.
There are many more things we can do with the Docker CLI, including data persistance.
We will cover these in the next episode.

::::::::::::::::::::::::::::::::::::::: keypoints
- All the commands are structured with a main command, a specialising command, an action command, and the name of the object to act on.
- Everything we did in Docker Desktop (and more!) can be done in the Docker CLI with:

| Command                         | Description                                     |
|---------------------------------|-------------------------------------------------|
| **Images**                      |                                                 |
| `docker pull <image>`           | Pull an image from a registry                   |
| `docker image ls`               | List all images on the system                   |
| `docker inspect <image>`        | Show detailed information about an image        |
| `docker run <image>`            | Run a container from an image                   |
| `docker image rm <image>`       | Remove an image                                 |
| **Containers**                  |                                                 |
| `docker logs <container>`       | Show the logs of a container                    |
| `docker exec <container> <cmd>` | Run a command in a running container            |
| `docker stop <container>`       | Stop a running container                        |
| `docker start <container>`      | Start a stopped container                       |
| `docker rm <container>`         | Remove a container                              |
| **System**                      |                                                 |
| `docker ps`                     | List all running containers                     |
| `docker stats`                  | Show live resource usage of containers          |
| `docker system prune`           | Remove all stopped containers and unused images |


| Flag     | Used on       | Description                                        |
|----------|---------------|----------------------------------------------------|
| `-f`     | `inspect`     | Specify the output format                          |
| `-f`     | `logs`        | Follow the logs in real time                       |
| `-a`     | `ps`          | List all containers, including stopped ones        |
| `-it`    | `run`, `exec` | Interactively run a command in a running container |
| `-d`     | `run`         | Run a container in the background                  |
| `-p`     | `run`         | Expose a port from the container to the host       |
| `--name` | `run`         | Name a container                                   |
| `--rm`   | `run`         | Remove the container when it is stopped            |

::::::::::::::::::::::::::::::::::::::::::::::::::
