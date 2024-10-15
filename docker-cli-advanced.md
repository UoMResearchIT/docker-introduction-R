---
title: Using the full power of the Docker CLI
teaching: 99
exercises: 99
---

Now that we have learned the basics of the Docker CLI, getting set up with all the tools we came across in Docker Desktop, we can start to explore the full power of Docker!

::::::::::::::::::::::::::::::::::::::: objectives
- Learn the lifecycle of Docker containers
- Learn about Entrypoints and Commands and how to manipulate them
- Learn how to use files with container using mounts and volumes
::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions
- What actually happens when I run a container?
- How can I control the behaviour of containers?
- How do I get data in and out of containers?
::::::::::::::::::::::::::::::::::::::::::::::::::

# Data in containers

In the earlier section on Docker Desktop, we learned how to interact with containers and used this to have a look at the unicorn_sightings.txt file.

It is quite annoying that the file does not persist between runs of the container! Also, with the file being in the container, we can't (easily) do much with it.

This is where the Docker CLI starts to shine.

## Making our data persist

Docker containers are naturally isolated from the host system, meaning that they have their own filesystems and cannot access the host filesystem.

They are also ephemeral, meaning that they are designed to be temporary and are destroyed when they are stopped. 

This is mostly a good thing, as it means that containers are lightweight and can be easily recreated, but we can't be throwing our unicorn sightings away like this!

Luckily, Docker has methods for allowing containers to persist data.

### Volumes

The first way to allow a container to access the host filesystem is by using a `volume`. A volume is a specially designated directory on the host filesystem which is shared with the container, hidden away deep in the host filesystem.

Volumes are very tightly controlled by Docker, and are designed to be used for sharing data between containers, or for persisting data between runs of a container. They are very useful, but can be a bit tricky to use.

Let's have a look at how we can use a volume to persist the `unicorn_sightings.txt` file between runs of the container.

We do this by modifying our `docker run` command to include a `-v` (for volume) flag, a volume name and a path inside the container.

**Note**: You have to be *really* careful with the syntax for this command. See the challenge box below for common mistakes (and their resolution).

```bash
$ docker run -d --rm --name spuc_container -p 8321:8321 -v spuc-volume:/output ghcr.io/uomresearchit/spuc:latest
```
```output
f1bd2bb9062348b6a1815f5076fcd1b79e603020c2d58436408c6c60da7e73d2
```

Ok! But what is happening?

We can see what containers we have created using:

```bash
$ docker volume ls
```
```output
local     spuc-volume
```

And we can see information about the volume using:

```bash
$ docker volume inspect spuc-volume
```
```output
[
    {
        "CreatedAt": "2024-10-11T11:15:09+01:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/spuc-volume/_data",
        "Name": "spuc-volume",
        "Options": null,
        "Scope": "local"
    }
]
```

Which shows us that the volume is stored in `/var/lib/docker/volumes/spuc-volume/_data` on the host filesystem. Which you can visit if you have superuser permissions (sudo).

But what about the container? Has this actually worked? Let's record some sightings and see if they persist between runs.

First, what's that over there?? A unicorn! No... three unicorns! Let's record these sightings.

```bash
$ curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
$ curl -X PUT localhost:8321/unicorn_spotted?location=earth\&brightness=10
$ curl -X PUT localhost:8321/unicorn_spotted?location=mars\&brightness=400
```
```output
{"message":"Unicorn sighting recorded!"}
{"message":"Unicorn sighting recorded!"}
{"message":"Unicorn sighting recorded!"}
```

Ok, let's check the sightings file.

```bash
$ docker exec spuc_container cat /code/output/unicorn_sightings.txt
```
```output
time,brightness,unit
2024-10-11 10:30:18.927696,100,iuhc
2024-10-11 10:30:25.744330,10,iuhc
2024-10-11 10:30:30.005247,400,iuhc
```

Now for our test, we will stop the container, run it again and check the sightings file.

```bash
$ docker stop spuc_container
$ docker run -d --rm --name spuc_container -p 8321:8321 -v spuc-volume:/code/output ghcr.io/uomresearchit/spuc:latest
$ docker exec spuc_container cat /code/output/unicorn_sightings.txt
```
```output
time,brightness,unit
2024-10-11 10:30:18.927696,100,iuhc
2024-10-11 10:30:25.744330,10,iuhc
2024-10-11 10:30:30.005247,400,iuh
```

So there we have it! The sightings persist between runs of the container. This is a great way to keep data between runs of a container, but watch out for the syntax!

::::::::::::::::::::::::::::: challenge
### Common mistakes with volumes
Given you are in a directory containing a directory named `spuc`, what will happen when you run the following commands? 

A) $ docker run -v ./spuc-volume:/foo spuc:latest

B) $ docker run -v spuc-volume:/foo spuc:latest

C) $ docker run -v ./spuc:/foo spuc:latest

D) $ docker run -v ${PWD}/spuc:/foo spuc:latest

E) $ docker run -v ${PWD}/spucs:/foo spuc:latest

:::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::: solution
A) The path to the volume must be an absolute path, not a relative path. You can use the $PWD environment variable to get the current working directory. This will create a (root owned) directory in the current working directory, which is not what you want. Use "sudo rm -rf ./spuc-volume" to remove the volume and try again.
B) This is the correct syntax for creating a volume. This will create a volume called spuc-volume and mount it to the /foo directory in the container.
C) Because ./spuc is not an absolute path, this will create a new volume called spuc and mount it to the /foo directory in the container. This is not what you want. Use "sudo rm -rf ./spuc" to remove the volume and try again.
D) This is valid syntax but not for creating a volume! This will create a bind mount instead. More on these next.
E) This will create a new volume called spuc**s** and mount it to the /foo directory in the container. This is not what you want. Use "sudo rm -rf ./spucs" to remove the volume and try again.
:::::::::::::::::::::::::::::::::::::::

### Bind mounting directories

The second way to allow a container to access the host filesystem is by using a `bind mount`. A bind mount is a direct mapping of a directory on the host filesystem to a directory in the container filesystem.

This can be appealing, as it allows you to directly access files on the host filesystem from the container, but it has its own challenges.

Let's have a look at how we can use a bind mount to persist the `unicorn_sightings.txt` file between runs of the container.

Confusingly, bind mounting is also done using the `-v` flag, but with a different syntax. We specify an **absolute** path to the directory on the host filesystem, followed by a colon, followed by the path to the directory in the container filesystem.

It can be annoying to type the full path to a directory, so we can use the `$PWD` environment variable to get the current working directory. 

```bash
$ docker stop spuc_container 
$ docker run -d --rm --name spuc_container -p 8321:8321 -v $PWD/spuc:/code/output ghcr.io/uomresearchit/spuc:latest
$ curl -X PUT localhost:8321/unicorn_spotted?location=mars\&brightness=400
$ tree spuc/
```
```output
spuc/
└── unicorn_sightings.txt
```

So now we can access the /code/output directory in the container on the host filesystem. This is totally functional way to persist data between runs of a container but there are downsides.

To illusrate this, let's see what the permissions are on the file we just created.

```bash
$ ls -l spuc/unicorn_sightings.txt
```
```output
-rw-r--r-- 1 root root 57 Oct 11 14:14 spuc/unicorn_sightings.txt
```

Argh, the file is owned by root!

This is because the container runs as root, and so any files created by the container are owned by root. This can be a problem, as you will not have permission to access the file without using `sudo`.

This is a common problem with bind mounts, and can be a bit of a pain to deal with. You can change the ownership of the file using `sudo chown`, but this can be a bit of a hassle.

Additionally, it is hard for Docker to clean up bind mounts, as they are not managed by Docker. The management of bind mounts is left to the user.

Really, neither volumes nor bind mounts are perfect, but they are both useful tools for persisting data between runs of a container and have both allowed us to keep the unicorn_sightings.txt file between runs of the container.

Later in these lessons we will see some more ergonomic ways to work with volumes and bind mounts.

## Sharing files with containers

Earlier, we looked at how to change the config file in SPUC to enable exporting. This was a bit of a hassle, as we had to use the Docker Desktop interface to do this and it did not persist between runs of the container.

We now have the tools to address this! We can use a bind mount to share the config file with the container.

Let's have a look at how we can do this. First we need to make the config file itself.

The SPUC README on dockerhub tells us that the config file should be in the following format:

```plaintext
::::: {time} Unicorn spotted at {location}!! Brightness: {brightness} {units}
```

And should be present at `/code/config/print.config`.

Let's get to it then. First we need to make the file (on the host).

```bash
$ echo "::::: {time} Unicorn spotted at {location}!! Brightness: {brightness} {units}" > print.config
```

Now we can bind mount this file to the container. Again we will use `-v` and the `$PWD` environment variable to get the current working directory. This time, however, we will specify a specific file to mount, not a directory.

```bash
$ docker stop spuc_container
$ docker run -d --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/code/config/print.config -v spuc-volume:/code/output ghcr.io/uomresearchit/spuc:latest
```

Now if we check the logs of the container, we can see that the config file has been loaded correctly and that the print format has been changed.

First, let's record another sighting, then check the logs.

```bash
$ curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
$ docker logs spuc_container
```
```output
[...]
[...]
::::: (2024-10-11 14:29:07.548965) Unicorn spotted at moon!! Brightness: 100 iuhc
```

Fantastic! We have now managed to share a file with the container, and have changed the behaviour of the container using this file.

### Summary

We have learned about volumes and bind mounts, two ways to allow a container to access the host filesystem. We have used these to persist data between runs of a container and to share files with a container.

They can both be a bit tricky to use, but are very useful tools for working with containers and have helped us get SPUC working much more like we want it to.

## Setting the environment

One other interesting reading from the SPUC README is the presence of an environment variable, `EXPORT` which can be set to `True` to enable an API endpoint for exporting the unicorn sightings.

This sounds like a useful feature, but how can we set an environment variable in a container?

Thankfully this is quite straightforward, we can use the `-e` flag to set an environment variable in a container.

Modifying our run command again:

```bash
$ docker stop spuc_container
$ docker run -d --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/code/config/print.config -v spuc-volume:/code/output -e EXPORT=true ghcr.io/uomresearchit/spuc:latest
$ docker logs spuc_container
```
```output
[...]
::::: Initializing SPUC...
::::: Units set to Imperial Unicorn Hoove Candles [iuhc].

Welcome to the Space Purple Unicorn Counter!
::::: Try 'curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100' to record a unicorn sighting!
::::: Or 'curl localhost:8321/export' to download the unicorn sightings file!
```

And now we can see that the export endpoint is available!

```bash
$ curl localhost:8321/export
```
```output
time,brightness,unit
2024-10-11 14:43:42.060883,100,iuhc
2024-10-11 14:43:48.064323,400,iuhc
2024-10-11 14:43:49.972220,10,iuhc
```

This is great! No need to bind mount or exec to get the data out of the container, we can just use the API endpoint.

Defaulting to network style connections is very common in Docker containers and saves a lot of hassle.

Environment variables are a very common tool for configuring containers. They are used to set things like API keys, database connection strings, and other configuration options.

## Passing parameters

Finally, we must address a very serious shortcoming of the SPUC container. It is recording the brightness of the unicorns in Imperial Unicorn Hoove Candles (iuhc)! This is a very outdated unit and we **must** change it to metric.

Fortunately the SPUC README tells us that we can pass a parameter to the container to set the units to metric. This is done by passing a parameter to the container when it is run, overriding the default command.

```bash
$ docker stop spuc_container
$ docker run -d --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/code/config/print.config -v spuc-volume:/code/output -e EXPORT=true ghcr.io/uomresearchit/spuc:latest --units iulu
$ curl -X PUT localhost:8321/unicorn_spotted?location=earth\&brightness=10
$ curl localhost:8321/export/
```
```output
time,brightness,unit
2024-10-11 14:43:42.060883,100,iuhc
2024-10-11 14:43:48.064323,400,iuhc
2024-10-11 14:43:49.972220,10,iuhc
2024-10-11 15:30:27.823367,10,iulu
```

::::::::::::::::::::::::::::: callout
You can also override the entrypoint of a container using the `--entrypoint` flag. This is useful if you want to run a different command in the container, or if you want to run the container interactively.

You may recall:

```bash
docker inspect ghcr.io/uomresearchit/spuc:latest -f "Entrypoint: {{.Config.Entrypoint}} Command: {{.Config.Cmd}}"
Entrypoint: [python /code/spuc.py] Command: [--units iuhc]
```

That SPUC has an entrypoint of `python /code/spuc.py` making it hard to interact with. We can override this using the `--entrypoint` flag.

```bash
$ docker run -it --rm --entrypoint /bin/sh ghcr.io/uomresearchit/spuc:latest
```

::::::::::::::::::::::::::::::::::::::: challenge
Which of these are valid entrypoint and command combinations for the SPUC container? What are the advantages and disadvantages of each?

| | Entrypoint | Command | 
|-|------------|---------|
|A| `python /code/spuc.py --units iuhc` | |
|B| `python /code/spuc.py` | `--units iuhc` | 
|C| `python` | `/code/spuc.py --units iuhc` |
|D| | `python /code/spuc.py --units iuhc` |

::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::: solution
These are all valid combinations! The best choice depends on the use case.

A) This combination bakes the command and the parameters into the image. This is useful if the command is always the same and the specified parameters are unlikely to change (although more may be appended).

B) This combination allows the command's arguments to be changd easily while baking in which Python script to run.

C) This combination allows the Python script to be changed easily, which is more likely to be bad than good!

D) This combination allows maximum flexibility, but it requires the user to know the correct command to run.
::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::

## Summary

In this section, we have learned about volumes and bind mounts, two ways to allow a container to access the host filesystem. We have used these to persist data between runs of a container and to share files with a container.

We have learned how to set environment variables and pass parameters to containers, two ways to configure the behaviour of a container.

SPUC is now running with the correct units and we can export the unicorn sightings using the API endpoint! And we are no longer losing our unicorn sightings between runs of the container.

::::::::::::::::::::::::::::::::::::::: keypoints
- Volumes and bind mounts are two ways to allow a container to access the host filesystem.
- Environment variables and parameters can be used to configure the behaviour of a container.
::::::::::::::::::::::::::::::::::::::::::::::::::
