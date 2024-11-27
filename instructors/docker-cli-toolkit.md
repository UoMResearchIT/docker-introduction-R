# Building our Docker CLI toolkit


## Pulling and Listing Images
```bash
docker pull spuacv/spuc:latest
```

## The structure of a Docker command
**Image:** A diagram showing the syntactic structure of a Docker command

## Listing Images
```bash
docker image ls
```

## Inspecting
```bash
docker inspect spuacv/spuc:latest
```
```bash
docker inspect spuacv/spuc:latest -f "Command: {{.Config.Cmd}}"
```
```bash
docker inspect spuacv/spuc:latest -f "Entrypoint: {{.Config.Entrypoint}}"
```
```bash
docker inspect spuacv/spuc:latest -f $'Command: {{.Config.Cmd}}\nEntrypoint: {{.Config.Entrypoint}}'
```

## Default Command
**Image:** A diagram representing the lifecycle of a container

### Further examples of container lifecycle
**Image:** Further details and examples of the lifecycle of a container


## Running
```bash
docker run spuacv/spuc:latest
```
Use `Ctrl+C` to stop the container.
```bash
docker run -d spuacv/spuc:latest
```

## Listing Containers
```bash
docker ps
```
```bash
docker ps -a
```

## Logs
Use *container name*, not image name:
```bash
docker logs ecstatic_nightingale
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```
*Error!* port was not exposed.

## Exposing ports
```bash
docker run -d -p 8321:8321 spuacv/spuc:latest
```
```bash
docker ps
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```
```bash
docker logs unruffled_noyce
```

## Setting the name of a container
```bash
docker run -d --name spuc_container -p 8321:8321 spuacv/spuc:latest
```
*Error!* **port** already in use, we need to **stop and delete**.
```bash
docker stop unruffled_noyce
docker rm unruffled_noyce
```

### Killing containers
```bash
docker kill ecstatic_nightingale
```

Now we can re-run with the name:
```bash
docker run -d --name spuc_container -p 8321:8321 spuacv/spuc:latest
```
We can also follow the logs:
```bash
docker logs -f spuc_container
```

## Executing commands in a running container
We can execute commands in a running container:
```bash
docker exec spuc_container cat config/print.config
```
Or run an interactive session:
```bash
docker exec -it spuc_container bash
```
```bash
apt update
apt install tree
tree
```
We can get out with `Ctrl+D` or `exit`.


## Interactive sessions
```bash
docker run -it alpine:latest
```

## Reviving Containers
```bash
docker kill spuc_container
docker ps
```
```bash
docker start spuc_container
```
```bash
docker ps
docker stats
```
And exit with `Ctrl+C`.

## Cleaning up
```bash
docker kill spuc_container
```
```bash
docker rm spuc_container
```
```bash
docker image rm alpine:latest
```
```bash
docker system prune
```

### Automatic cleanup
```bash
docker run -d --rm --name spuc_container -p 8321:8321 spuacv/spuc:latest
```
This is a relatively standard command.  
It will get worse.

Already ahead of Docker Desktop, but lets do more, like persist data.


## Show keypoints slide
