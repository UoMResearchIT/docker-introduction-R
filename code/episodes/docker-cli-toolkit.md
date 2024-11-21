



## Pulling and Listing Images
```bash
docker pull spuacv/spuc:latest
```

## The structure of a Docker command
Image: A diagram showing the syntactic structure of a Docker command

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
Image: A diagram representing the lifecycle of a container

### Further examples of container lifecycle
Image: Further details and examples of the lifecycle of a container


## Running
```bash
docker run spuacv/spuc:latest
```
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
```bash
docker logs ecstatic_nightingale
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```
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
```bash
docker stop unruffled_noyce
docker rm unruffled_noyce
```

### Killing containers
```bash
docker kill ecstatic_nightingale
```

```bash
docker run -d --name spuc_container -p 8321:8321 spuacv/spuc:latest
```
```bash
docker logs -f spuc_container
```

### Logs

## Executing commands in a running container
```bash
docker exec spuc_container cat config/print.config
```
```bash
docker exec -it spuc_container bash
```
```bash
apt update
apt install tree
tree
```

## Interactive sessions
```bash
docker run -it alpine:latest
```

## Reviving Containers
```bash
docker kill spuc_container
```
```bash
docker start spuc_container
```
```bash
docker stats
```
## Cleaning up
```bash
docker kill spuc_container
```
```bash
docker rm spuc_container
```
```bash
docker image rm spuacv/spuc:latest
```
```bash
docker system prune
```
### Automatic cleanup
```bash
docker run -d --rm --name spuc_container -p 8321:8321 spuacv/spuc:latest
```


