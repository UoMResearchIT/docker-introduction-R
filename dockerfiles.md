---
title: Creating Your Own Container Images
teaching: 99
exercises: 99
---

::::::::::::::::::::::::::::::::::::::::::::::::::: objectives
- Learn how to create your own container images using a `Dockerfile`.
- Learn about the core instruction set used in a `Dockerfile`.
- Learn how to build a container image from a `Dockerfile`.
- Learn how to run a container from a container image.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::: questions
- How can I create my own container images?
- What is a `Dockerfile`?
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

We've been doing well picking things up from the SPUCS README! Let's keep the streak going.

There is another cool feature on there that we haven't used yet - the ability to add new Unicorn analysis features using plugins! Let's try that out.

The README says that we need to add a Python file at `/spuc/plugins/` that defines an endpoint for the new feature.

It would be very handy to be able to get some basic statistics about our Unicorns. Let's add a new plugin that will return a statstical analysis of the brightness of the Unicorns in the database.

However you prefer - make a file `stats.py` with the following content:

```python
from __main__ import app
from __main__ import file_path

import pandas as pd

@app.route('/stats', methods=['GET'])
def stats():
    with open(file_path) as f:
        df = pd.read_csv(f)
        stats = df.describe()
        return stats.to_json()        
```

n.b. Don't worry if you're not familiar with Python or Pandas! This code will return some basic statistics about the data in the database.

Now, from our previous lesson we know how to load this file! Let's use a bind mount to load this file into the container. Since we are debugging, we'll leave out the `-d` flag so we can see the output easily.


```bash
$ docker run --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/code/config/print.config -v spuc-volume:/code/output -v $PWD/stats.py:/spuc/plugins/stats.py -e EXPORT=true ghcr.io/uomresearchit/spuc:latest --units iulu
```
```output
Traceback (most recent call last):
  File "/spuc/spuc.py", line 32, in <module>
    __import__(f"{plugin_dir}.{plugin[:-3]}")
  File "/spuc/plugins/stats.py", line 4, in <module>
    import pandas as pd
ModuleNotFoundError: No module named 'pandas'

:::: Importing plugins ::::
```

Oh... well what can we do about this? Clearly we need to install the `pandas` package in the container but how do we do that?

We could do this interactively, but we know that won't survive a restart!

Really what we need to do is **change** the image itself, so that it has `pandas` installed by default.

This takes us to one of the most fundamental features of Docker - the ability to create your own container images.

## Creating Docker Images

So how are images made? The answer is with a recipe! Named a `Dockerfile`.

A `Dockerfile` is a text file that contains a list of instructions for producing a Docker container. The instructions are terminal command and build the container image up layer by layer.

We will start at the start, all Dockerfiles start with a `FROM` instruction. This sets the base image for the container. The base image is the starting point for the container, and all subsequent instructions are run on top of this base image.

You can use **any** image as a base image and there are several offical images available on Docker Hub. For example, `ubuntu` for general purpose Linux, `python` for Python development, `alpine` for a lightweight Linux distribution, and many more.

But of course the most natural fit for us right now is to use the SPUC image as a base image. This way we can be sure that our new image will have all the dependencies we need.

Let's create a new file called `Dockerfile` (it **must** be called this!) and add the following content:

```Dockerfile
FROM ghcr.io/uomresearchit/spuc:latest
```

This is the simplest possible `Dockerfile` - it just says that our new image will be based on the SPUC image.

But what do we do with it? We need to build the image!

To do this we use the `docker build` command (short for `docker image build`). This command takes a `Dockerfile` and builds a new image from it and we will add a `-t` (tag) flag to give the image a name.

```bash
$ docker build -t spuc-stats ./
```

This command will build a new image called `spuc-stats` from the `Dockerfile` in the current directory.

We can now run this image in the same way we run any other image:

```bash
$ docker run --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/code/config/print.config -v spuc-volume:/code/output -v $PWD/stats.py:/spuc/plugins/stats.py -e EXPORT=true spuc-stats --units iulu
```
```output
Traceback (most recent call last):
  File "/spuc/spuc.py", line 32, in <module>
    __import__(f"{plugin_dir}.{plugin[:-3]}")
  File "/spuc/plugins/stats.py", line 4, in <module>
    import pandas as pd
ModuleNotFoundError: No module named 'pandas'
```

Ok! Back where we were but with some new skills!

Let's add that dependancy. We do this by adding a `RUN` instruction to the `Dockerfile`. This instruction runs a command in the container and then saves the result as a new layer in the image.

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
[...]
Installing collected packages: pytz, tzdata, six, numpy, python-dateutil, pandas                                                                
Successfully installed numpy-2.1.2 pandas-2.2.3 python-dateutil-2.9.0.post0 pytz-2024.2 six-1.16.0 tzdata-2024.2                                
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager, possibly rendering your system unusable.It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv. Use the --root-user-action option if you know what you are doing and want to suppress this warning.  
 ---> Removed intermediate container 642bfe617ba4
 ---> 6ec83b86fbd1
Successfully built 6ec83b86fbd1
Successfully tagged spuc-stats:latest
```

It is worth noting that we can ignore this warning! We are building a container image, not installing software on our host machine.

Now we can run the image again:

```bash
$ docker run --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/code/config/print.config -v spuc-volume:/code/output -v $PWD/stats.py:/spuc/plugins/stats.py -e EXPORT=True spuc-stats --units iulu
```
```output
[...]
Welcome to the Space Purple Unicorn Counter!

:::: Units set to Intergalactic Unicorn Luminiocity Units [iulu] ::::

:::: Plugins loaded ::::
['stats.py']

:: Try recording a unicorn sighting with:
    curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```

And now we can see that the `pandas` package is installed and the plugin is loaded!

Let's try out the new endpoint:

```bash
$ curl localhost:8321/stats
```
```output
{"count":{"count":3.0,"mean":1.0,"std":1.0,"min":0.0,"25%":0.5,"50%":1.0,"75%":1.5,"max":2.0},"brightness":{"count":3.0,"mean":10.0,"std":0.0,"min":10.0,"25%":10.0,"50%":10.0,"75%":10.0,"max":10.0}}
```

And there we have it! We have created our own container image with a new feature!

But why stop here? We could keep modifing the image to make it more how we would like by default.

## COPY

The first thing to look at is that it is a bit annoying having to bind mount the `stats.py` file every time we run the container. This makes sense for development but we would like to distribute the image with the plugin already installed.

We can add this file to the image itself using the `COPY` instruction.

The `COPY` instruction copies files from the host machine into the container image. It takes two arguments: the source file on the host machine and the destination in the container image.

Let's add the `COPY` instruction to the `Dockerfile`:

```Dockerfile
FROM ghcr.io/uomresearchit/spuc:latest

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
```

Now we can build the image again:

```bash
$ docker build -t spuc-stats ./
```

And run the image, this time without the bind mount for the `stats.py` file:

```bash
$ docker run --rm --name spuc_container -p 8321:8321 -v $PWD/print.config:/code/config/print.config -v spuc-volume:/code/output -e EXPORT=True spuc-stats --units iulu
```
```output
[...]
:::: Plugins loaded ::::
['stats.py']
[...]
```

If we check the logs we can see that the plugin is still loaded!

And again... why stop there? It is annoying having to mount the `print.config` file every time we run the container. We could add this file to the image as well!

```Dockerfile
FROM ghcr.io/uomresearchit/spuc:latest

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
COPY print.config /code/config/print.config
```

Rebuilding and running (without the bind mount for `print.config`):

```bash
$ docker build -t spuc-stats ./
$ docker run --rm --name spuc_container -p 8321:8321 -v spuc-volume:/code/output -e EXPORT=True spuc-stats --units iulu
```

## ENV

We can also set environment variables in the `Dockerfile` using the `ENV` instruction.
These can always be overridden when running the container but it is useful to set defaults. And we like the `EXPORT` variable so let's add that to the `Dockerfile`:

```Dockerfile
FROM ghcr.io/uomresearchit/spuc:latest

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
COPY print.config /code/config/print.config

ENV EXPORT=True
```

Rebuilding and running (without the `-e EXPORT=True` flag):

```bash
$ docker build -t spuc-stats ./
$ docker run --rm --name spuc_container -p 8321:8321 -v spuc-volume:/code/output spuc-stats --units iulu
```
```output
[...]
:::: Unicorn sightings export activated! ::::
:: Try downloading the unicorn sightings record with:
    curl localhost:8321/export
```

We can see that the `EXPORT` variable is now set to `True` by default!

## ENTRYPOINT

We're on a bit of a roll here! Let's add one more modification to the image.

Let's change away from those imperial units by default.

We can do this by changing the `ENTRYPOINT` instruction in the `Dockerfile`. So far we have been adding `--units iulu` to the end of the `docker run` which overwrites the `command`.

If we move this to the `ENTRYPOINT` instruction then it will be run every time the container is started. We'll also add a `CMD` instruction with an empty list as the CMD was set in the SPUCS container base and we don't want to set `--units` twice.

```Dockerfile
FROM ghcr.io/uomresearchit/spuc:latest

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
COPY print.config /code/config/print.config

ENV EXPORT=True

ENTRYPOINT ["python", "/spuc/spuc.py", "--units", "iulu"]
CMD []
```

Notice that we use array syntax for the `ENTRYPOINT` instruction. This is because the `ENTRYPOINT` instruction can take a list of arguments and the array syntax ensures that the arguments are passed correctly.

Let's give this a try, dropping the unnecessary `--units iulu` from the `docker run` command:

```bash
$ docker build -t spuc-stats ./
$ docker run --rm --name spuc_container -p 8321:8321 -v spuc-volume:/code/output spuc-stats
```
```output
[...]
:::: Units set to Intergalactic Unicorn Luminiocity Units [iulu] ::::
[...]
```

Much better! A far clearner command, much more customised for our use case!

## Back to reality

In this lession we have focused on modifying an image already containing a service.
This is a perfectly valid way of using Dockerfiles! But it is not the most common.

While you can base your images on any other public image, it is most common for developers to be creating containers 'from the ground up'.

The most common practice is creating images from images like `ubuntu` or `alpine` and adding your own software and configuration files.

An example of this is how the developers of the SPUC service created their image. The Dockerfile is reproduced below:

```Dockerfile
FROM python:3.12-slim

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

* started with a `python:3.12-slim` image
* installed the required packages (from a file) using `pip`
* copied the source code and configuration files
* set the default entrypoint andcommand.

This is a very common pattern for creating images and is the most common way to use Dockerfiles but it is important to realise that you can create images from **any** base image and customise them to your heart's content!

## Summary

In this lesson we have seen how to create our own container images using a `Dockerfile`.

We've added new layers with new packges installed using `RUN`, we've added files using `COPY`, set environment variables using `ENV`, and changed the default command using `ENTRYPOINT` and `CMD`.

However, we are still encumbered with quite an unwieldy command to run the container. In the next lesson we will see how to make this easier by using `docker-compose`.

:::::::::::::::::::::::::::::::::::::::: keypoints
- You can create your own container images using a `Dockerfile`.
- A `Dockerfile` is a text file that contains a list of instructions for producing a Docker container.
- `FROM`, `RUN`, `COPY`, `ENV`, `ENTRYPOINT`, and `CMD` are some of the most imprtatn instructions that can be used in a `Dockerfile`.
- The `docker build` command is used to build a container image from a `Dockerfile`.
- You can run a container from a container image using the `docker run` command.
::::::::::::::::::::::::::::::::::::::::::::::::::


