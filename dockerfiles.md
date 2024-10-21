---
title: Creating Your Own Container Images
teaching: 99
exercises: 99
---

::::::::::::::::::::::::::::::::::::::::::::::::::: objectives
- Learn how to create your own container images using a `Dockerfile`.
- Introduce the core instructions used in a `Dockerfile`.
- Learn how to build a container image from a `Dockerfile`.
- Learn how to run a container from a *local* container image.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::: questions
- How can I create my own container images?
- What is a `Dockerfile`?
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

The SPUC documentation just keeps on giving, let's keep the streak going!

There is another cool feature on there that we haven't used yet -
the ability to add new unicorn analysis features using plugins! Let's try that out.

The docs says that we need to add a Python file at `/spuc/plugins/` that defines an endpoint for the new feature.

It would be very handy to be able to get some basic statistics about our Unicorns.
Let's add a new plugin that will return a statistical analysis of the brightness of the unicorns in the database.

First lets make a file `stats.py` with the following content:
```python
from __main__ import app
from __main__ import file_path

import pandas as pd
import os

@app.route("/stats", methods=["GET"])
def stats():
    if not os.path.exists(file_path):
        return {"message": "No unicorn sightings yet!"}

    with open(file_path) as f:
        df = pd.read_csv(f)
        df = df.iloc[:, 1:]
        stats = df.describe()
        return stats.to_json()
```

Don't worry if you're not familiar with Python or Pandas.
Understanding this snippet of code is not our aim.
The code will return some statistics about the data in `file_path`.

We already know how to load this file.
Let's use a bind mount to share the file with the container.
Since we are debugging, we'll leave out the `-d` flag so we can see the output easily.
```bash
docker run --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v $PWD/stats.py:/spuc/plugins/stats.py -e EXPORT=true spuacv/spuc:latest --units iulu
```
```output
Traceback (most recent call last):
  File "/spuc/spuc.py", line 31, in <module>
    __import__(f"{plugin_dir}.{plugin[:-3]}")
  File "/spuc/plugins/stats.py", line 4, in <module>
    import pandas as pd
ModuleNotFoundError: No module named 'pandas'
```

Oh... well what can we do about this?
Clearly we need to install the `pandas` package in the container but how do we do that?
We could do this interactively, but we know that won't survive a restart!

Really what we need to do is **change** the image itself, so that it has `pandas` installed by default.
This takes us to one of the most fundamental features of Docker - the ability to create your own container images.

## Creating Docker Images

So how are images made? With a recipe!

Images are created from a text file that contains a list of instructions, called a `Dockerfile`.
The instructions are terminal commands, and build the container image up layer by layer.

All *Dockerfiles* start with a `FROM` instruction.
This sets the *base image* for the container.
The base image is the starting point for the container, and all subsequent instructions are run on top of this base image.

You can use **any** image as a base image.
There are several *official* images available on Docker Hub which are very commonly used.
For example, `ubuntu` for general purpose Linux, `python` for Python development, `alpine` for a lightweight Linux distribution, and many more.

But of course, the most natural fit for us right now is to use the SPUC image as a base image.
This way we can be sure that our new image will have all the dependencies we need.

Let's create a new file called `Dockerfile` and add the following content:
```Dockerfile
FROM spuacv/spuc:latest
```

This is the simplest possible Dockerfile - it just says that our new image will be based on the SPUC image.

But what do we do with it? We need to build the image!

To do this we use the `docker build` command (short for `docker image build`).
This command takes a Dockerfile and builds a new image from it.
Just as when saving a file, we also need to name the image we are building.
We give the image a name with the `-t` (tag) flag:
```bash
docker build -t spuc-stats ./
```
```output
[+] Building 0.0s (5/5) FINISHED                                                             docker:default
 => [internal] load build definition from Dockerfile                                                   0.0s
 => => transferring dockerfile: 61B                                                                    0.0s
 => [internal] load metadata for docker.io/spuacv/spuc:latest                                          0.0s
 => [internal] load .dockerignore                                                                      0.0s
 => => transferring context: 2B                                                                        0.0s
 => CACHED [1/1] FROM docker.io/spuacv/spuc:latest                                                     0.0s
 => exporting to image                                                                                 0.0s
 => => exporting layers                                                                                0.0s
 => => writing image sha256:ccde35b1f9e872bde522e9fe91466ef983f9b579cffc2f457bff97f74206e839           0.0s
 => => naming to docker.io/library/spuc-stats                                                          0.0s
 ```

Congratulations, you have now built an image!
The command built a new image called `spuc-stats` from the `Dockerfile` in the current directory.

:::::::::::: spoiler

## Context

By default, the `docker build` command looks for a file called `Dockerfile` in the path specified by the last argument.

This last argument is called the *build context*, and it **must** be the path to a directory.

It is very common to see `.` or `./` used as the build context, both of which refer to the current directory.

All of the instructions in the `Dockerfile` are run as if we were in the build context directory.

::::::::::::::::::::

:::::::::::: spoiler

### The Dockerfile name

As mentioned before, by default the `docker build` command looks for a file called `Dockerfile`.

However, you can specify a different file name using the `-f` flag.
For example, if your Dockerfile is called `my_recipe` you can use:
```bash
docker build -t spuc-stats -f my_recipe ./
```

::::::::::::::::::::

If you now list the images on your system you should see the new image `spuc-stats` listed:
```bash
docker image ls
```
```output
spuacv/spuc                             latest    ccde35b1f9e8   25 hours ago     137MB
spuc-stats                              latest    21210c129ca9   5 minutes ago    137MB
```
We can now run this image in the same way we would run any other image:
```bash
docker run --rm spuc-stats
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

:::: Units set to Imperial Unicorn Hoove Candles [iuhc] ::::

:: Try recording a unicorn sighting with:
    curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100

:: No plugins detected
```

So we have a copy of the SPUC image with a new name, but nothing has changed!
In fact, we can pass all the same arguments to the `docker run` command as we did before:
```bash
docker run --rm --name spuc-stats_container -p 8321:8321 -v $PWD/print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v $PWD/stats.py:/spuc/plugins/stats.py -e EXPORT=true spuc-stats --units iulu
```
```output
Traceback (most recent call last):
  File "/spuc/spuc.py", line 31, in <module>
    __import__(f"{plugin_dir}.{plugin[:-3]}")
  File "/spuc/plugins/stats.py", line 4, in <module>
    import pandas as pd
ModuleNotFoundError: No module named 'pandas'
```

We are back where we were, but we can now start to make this container image our own!

Let's first fix that dependency problem.
We do this by adding a `RUN` instruction to the `Dockerfile`.
This instruction runs a command in the container and then saves the result as a new layer in the image.
In this case we want to install the `pandas` package so we add the following lines to the `Dockerfile`:
```Dockerfile
RUN pip install pandas
```

This will install the `pandas` package in the container using Python's package manager `pip`.
Now we can build the image again:
```bash
$ docker build -t spuc-stats ./
```
```output
[+] Building 11.1s (6/6) FINISHED                                                            docker:default
 [...]
 => CACHED [1/2] FROM docker.io/spuacv/spuc:latest                                                     0.0s
 => [2/2] RUN pip install pandas                                                                      10.5s
 => exporting to image                                                                                 0.4s
 => => exporting layers                                                                                0.4s
 => => writing image sha256:e548b862a5c4dd91551668e068d4ad46e6a25d3a3dbed335e780a01f954a2c26           0.0s
 => => naming to docker.io/library/spuc-stats                                                          0.0s
```

You might have noticed a warning about running `pip` as the root user.
We are building a container image, not installing software on our host machine,
so we can ignore this warning.

Let's run the image again:
```bash
docker run --rm --name spuc-stats_container -p 8321:8321 -v $PWD/print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v $PWD/stats.py:/spuc/plugins/stats.py -e EXPORT=true spuc-stats --units iulu
```
```output
[...]
Welcome to the Space Purple Unicorn Counter!
[...]
:::: Plugins loaded! ::::
:: Available plugins
    stats.py

[...]
```

It worked! We no longer get the error about the missing `pandas` package, and the plugin is loaded!

Let's try out the new endpoint
(you may want to do this from another terminal,
or exit with `Ctrl+C` and re-run with `-d` first):
```bash
curl localhost:8321/stats
```
```output
{"brightness":{"count":6.0,"mean":267.3333333333,"std":251.7599385658,"min":18.0,"25%":93.75,"50%":219.5,"75%":344.5,"max":709.0}}
```

And there we have it! We have created our own container image with a new feature!

But why stop here? We could keep modifying the image to make it more how we would like by default.

## COPY

It is a bit annoying having to bind mount the `stats.py` file every time we run the container.
This makes sense for development, because we can potentially modify the script while the container runs,
but we would like to distribute the image with the plugin already installed.

We can add this file to the image itself using the `COPY` instruction.
This copies files from the host machine into the container image.
It takes two arguments: the source file on the host machine and the destination in the container image.

Let's add it to the `Dockerfile`:
```Dockerfile
COPY stats.py /spuc/plugins/stats.py
```

Now we can build the image again:
```bash
docker build -t spuc-stats ./
```
```output
[...]
 => [1/3] FROM docker.io/spuacv/spuc:latest                                                         0.0s
 => [internal] load build context                                                                   0.0s
 => => transferring context: 287B                                                                   0.0s
 => CACHED [2/3] RUN pip install pandas                                                             0.0s
 => [3/3] COPY stats.py /spuc/plugins/stats.py                                                      0.0s
 => exporting to image                                                                              0.0s
 [...]
```

:::::::::::: spoiler

## Layers

You might have now noticed that on every build we are getting messages like `CACHED [2/3]...` above.

Every instruction* in a Dockerfile creates a new `layer` in the image.

Each layer is saved with a specific hash.
If the set of instructions up to that layer remain unchanged,
Docker will use the cached layer, instead of rebuilding it.
This results in a lot of time and space being saved!

In the case above, we had already run the `FROM` and `RUN` instructions in a previous build.
Docker was able to use the cached layers for those 2 instructions,
and only had to do some work for the `COPY` layer.

::::::::::::::::::::

And run the image again, but this time without the bind mount for the `stats.py` file:
```bash
docker run --rm --name spuc-stats_container -p 8321:8321 -v $PWD/print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -e EXPORT=true spuc-stats --units iulu
```
```output
[...]
Welcome to the Space Purple Unicorn Counter!
[...]
:::: Plugins loaded! ::::
:: Available plugins
    stats.py
[...]
```

The plugin is still loaded!

And again... why stop there?
We've already configured the print how we like it, so lets add it to the image as well!
```Dockerfile
COPY print.config /spuc/config/print.config
```

Now we rebuild and re-run (without the bind mount for `print.config`):
```bash
docker build -t spuc-stats ./
docker run --rm --name spuc_container -p 8321:8321 -v spuc-volume:/spuc/output -e EXPORT=True spuc-stats --units iulu
```
```output
[...]
 => [1/4] FROM docker.io/spuacv/spuc:latest                                                         0.0s
 => [internal] load build context                                                                   0.0s
 => => transferring context: 152B                                                                   0.0s
 => CACHED [2/4] RUN pip install pandas                                                             0.0s
 => CACHED [3/4] COPY stats.py /spuc/plugins/stats.py                                               0.0s
 => [4/4] COPY print.config /spuc/config/print.config                                               0.0s
 => exporting to image                                                                              0.0s
[...]
Welcome to the Space Purple Unicorn Counter!
[...]
```

OOh! a unicorn! lets record it!
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=saturn\&brightness=87
```
```output
{"message":"Unicorn sighting recorded!"}
```
and the logs confirm copying the print config worked:
```bash
docker logs spuc_container
```
```output
[...]
::::: Unicorn number 7 spotted at saturn! Brightness: 87 iulu
```

The `run` command is definitely improving! Is there anything else we can do to make it even better?

## ENV

We can also set environment variables in the `Dockerfile` using the `ENV` instruction.
These can always be overridden when running the container, as we have done ourselves, but it is useful to set defaults.
We like the `EXPORT` variable set to `True`, so let's add that to the `Dockerfile`:
```Dockerfile
ENV EXPORT=True
```

Rebuilding and running (without the `-e EXPORT=True` flag) results in:
```bash
docker build -t spuc-stats ./
docker run --rm --name spuc-stats_container -p 8321:8321 -v spuc-volume:/spuc/output spuc-stats --units iulu
```
```output
[...]
 => [1/4] FROM docker.io/spuacv/spuc:latest                                                         0.0s
 => [internal] load build context                                                                   0.0s
 => => transferring context: 61B                                                                    0.0s
 => CACHED [2/4] RUN pip install pandas                                                             0.0s
 => CACHED [3/4] COPY stats.py /spuc/plugins/stats.py                                               0.0s
 => CACHED [4/4] COPY print.config /spuc/config/print.config                                        0.0s
 => exporting to image                                                                              0.0s
[...]
Welcome to the Space Purple Unicorn Counter!
[...]
:::: Unicorn sightings export activated! ::::
:: Try downloading the unicorn sightings record with:
    curl localhost:8321/export
```

The `EXPORT` variable is now set to `True` by default!

:::::::::::: spoiler

## Layers - continued

You might have noticed that the `ENV` instruction did not create a new layer in the image.

This instruction is a bit special, as it only modifies the configuration of the image.
The environment is set on every instruction of the dockerfile, so it is not saved as a separate layer.

However, environment variables *can* have an effect on instructions bellow it.
Because of this, moving the `ENV` instruction will *change* the layers, and the cache is no longer valid.

We can see this by moving the `ENV` instruction in our `Dockerfile` before the RUN command:
```Dockerfile
FROM spuacv/spuc:latest

ENV EXPORT=True

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
COPY print.config /spuc/config/print.config
```

If we now try to build again, we will get this output:
```bash
docker build -t spuc-stats ./
```
```output
[+] Building 10.4s (9/9) FINISHED                                                         docker:default
 => [internal] load build definition from Dockerfile                                                0.0s
 => => transferring dockerfile: 187B                                                                0.0s
 => [internal] load metadata for docker.io/spuacv/spuc:latest                                       0.0s
 => [internal] load .dockerignore                                                                   0.0s
 => => transferring context: 2B                                                                     0.0s
 => CACHED [1/4] FROM docker.io/spuacv/spuc:latest                                                  0.0s
 => [internal] load build context                                                                   0.0s
 => => transferring context: 61B                                                                    0.0s
 => [2/4] RUN pip install pandas                                                                    9.8s
 => [3/4] COPY stats.py /spuc/plugins/stats.py                                                      0.0s
 => [4/4] COPY print.config /spuc/config/print.config                                               0.0s
 => exporting to image                                                                              0.5s
 => => exporting layers                                                                             0.5s
 => => writing image sha256:5a64cc132a7cbbc532b9e97dd17e5fb83239dfe42dae9e6df4d150c503d73691        0.0s
 => => naming to docker.io/library/spuc-stats                                                       0.0s
```

As you can see, the first layer is cached, but everything after the `ENV` instruction is rebuilt.
Our environment variable has absolutely no effect on the `RUN` instruction, but Docker does not know that.
The only thing that matters is that it *could* have had an effect.

It is therefore recommended that you put the `ENV` instructions only when they are needed.

A similar thing happens with the `ENTRYPOINT` and `CMD` instructions, which we will cover next.
Since these are not needed at all during the build, they are best placed at the end of the `Dockerfile`.

::::::::::::::::::::

## ENTRYPOINT and CMD

We're on a bit of a roll here! Let's add one more modification to the image.
Let's change away from those imperial units by default.

We can do this by changing the default command in the `Dockerfile`.
As you may remember, the default command is composed of an *entrypoint* and a *command*.
We can modify either of them in the Dockerfile.
Just to make clear wheat the full command is directly from our dockerfile, lets write down both:
```Dockerfile
ENTRYPOINT ["python", "/spuc/spuc.py"]
CMD ["--units", "iulu"]
```

Notice that we used an array syntax.
Both the `ENTRYPOINT` and `CMD` instructions can take a list of arguments,
and the array syntax ensures that the arguments are passed correctly.

Let's give this a try, dropping the now unnecessary `--units iulu` from the `docker run` command:
```bash
docker build -t spuc-stats ./
docker run --rm --name spuc-stats_container -p 8321:8321 -v spuc-volume:/spuc/output spuc-stats
```
```output
[...]
 => [1/4] FROM docker.io/spuacv/spuc:latest                                                         0.0s
 => CACHED [2/4] RUN pip install pandas                                                             0.0s
 => CACHED [3/4] COPY stats.py /spuc/plugins/stats.py                                               0.0s
 => CACHED [4/4] COPY print.config /spuc/config/print.config                                        0.0s
 => exporting to image                                                                              0.0s
[...]
:::: Units set to Intergalactic Unicorn Luminiocity Units [iulu] ::::
[...]
```

Much better! A far cleaner command, much more customised for our use case!

## Building containers from the ground up

In this lesson we adjusted the SPUC image, which already contains a service.
This is a perfectly valid way of using Dockerfiles!
But it is not the most common.

While you can base your images on any other public image,
it is most common for developers to be creating containers 'from the ground up'.

The most common practice is creating images from images like `ubuntu` or `alpine` and adding your own software and configuration files.
An example of this is how the developers of the SPUC service created their image.
The Dockerfile is reproduced below:

```Dockerfile
FROM python:3.12-slim

RUN apt update
RUN apt install -y curl

WORKDIR /spuc

COPY ./requirements.txt /spuc/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /spuc/requirements.txt

COPY ./*.py /spuc/
COPY ./config/*.config /spuc/config/
RUN mkdir /spuc/output

EXPOSE 8321

ENTRYPOINT ["python", "/spuc/spuc.py"]
CMD ["--units", "iuhc"]
```

From this we can see the developers:

* Started `FROM` a `python:3.12-slim` image
* Use `RUN` to install the required packages
* `COPY` the source code and configuration files
* Set the default `ENTRYPOINT` and `CMD`.

There are also two other instructions in this Dockerfile that we haven't covered yet.

* `WORKDIR` sets the working directory for the container.
  It is used to create a directory and then change into it.
  You may have noticed before that when we exec into the SPUC container we start in the `/spuc` directory.
  All of the commands after a `WORKDIR` instruction are run from the directory it sets.
* `EXPOSE` is used to expose a port from the container to the host machine.
  This is not strictly necessary, but it is a good practice to document which ports the service uses.


:::::::::::::::::::::::::::::::::::::::: keypoints
- You can create your own container images using a `Dockerfile`.
- A `Dockerfile` is a text file that contains a list of instructions to produce a container image.
- Each instruction in a `Dockerfile` creates a new `layer` in the image.
- `FROM`, `WORKDIR`, `RUN`, `COPY`, `ENV`, `ENTRYPOINT` and `CMD` are some of the most important instructions used in a `Dockerfile`.
- To build a container image from a `Dockerfile` you use the command:  
  `docker build -t <image_name> <context_path>`
- You can run a container from a local image just like any other image, with docker run.
::::::::::::::::::::::::::::::::::::::::::::::::::
