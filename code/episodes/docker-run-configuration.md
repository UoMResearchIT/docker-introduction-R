



## Setting the environment
```bash
docker stop spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -e EXPORT=true spuacv/spuc:latest
docker logs spuc_container
```
```bash
curl localhost:8321/export
```
## Passing parameters (overriding the command)
```bash
docker inspect spuacv/spuc:latest -f "Entrypoint: {{.Config.Entrypoint}}\nCommand: {{.Config.Cmd}}"
```
```bash
docker stop spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -e EXPORT=true spuacv/spuc:latest --units iulu
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=pluto\&brightness=66
curl localhost:8321/export
```
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
## Overriding the entrypoint
```bash
docker run -it --rm --entrypoint /bin/sh spuacv/spuc:latest
```

# ! Challenge:
# !! Solution:




