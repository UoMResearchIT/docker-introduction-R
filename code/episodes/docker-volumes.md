



## Making our data persist
## Volumes
```bash
docker kill spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v spuc-volume:/spuc/output spuacv/spuc:latest
```
```bash
docker volume ls
```

### Inspecting the volume
```bash
docker volume inspect spuc-volume
```

```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
curl -X PUT localhost:8321/unicorn_spotted?location=earth\&brightness=10
curl -X PUT localhost:8321/unicorn_spotted?location=mars\&brightness=400
```
```bash
docker exec spuc_container cat /spuc/output/unicorn_sightings.txt
```
```bash
docker kill spuc_container
docker ps -a
```
```bash
docker run -d --rm --name spuc_container -p 8321:8321 -v spuc-volume:/spuc/output spuacv/spuc:latest
docker exec spuc_container cat /spuc/output/unicorn_sightings.txt
```
## Bind mounts
```bash
docker kill spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./spuc/output:/spuc/output spuacv/spuc:latest
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=mercury\&brightness=400
cat spuc/output/unicorn_sightings.txt
```
```bash
docker kill spuc_container
ls spuc/output
```
```bash
docker run -d --rm --name spuc_container -p 8321:8321 -v ./spuc/output:/spuc/output spuacv/spuc:latest
cat spuc/output/unicorn_sightings.txt
```
```bash
ls -l spuc/unicorn_sightings.txt
```
### Bind mount files
```bash
echo "::::: {time} Unicorn number {count} spotted at {location}! Brightness: {brightness} {units}" > print.config
```
```bash
docker kill spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output spuacv/spuc:latest
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=jupyter\&brightness=210
docker logs spuc_container
```
```bash
echo "::::: Unicorn number {count} spotted at {location}! Brightness: {brightness} {units}" > print.config
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=venus\&brightness=148
docker logs spuc_container
```

# ! Challenge:
## Common mistakes with volumes
# !! Solution:




