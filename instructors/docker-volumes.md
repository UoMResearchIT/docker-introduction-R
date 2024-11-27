# Sharing information with containers


Containers are ephemeral, but we want our unicorn sightings to persist.

## Volumes
Managed by Docker, hidden away in file system.  
They are declared with `name:path`:
**-v spuc-volume:/spuc/output**

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

Now let's spot some unicorns!
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
curl -X PUT localhost:8321/unicorn_spotted?location=earth\&brightness=10
curl -X PUT localhost:8321/unicorn_spotted?location=mars\&brightness=400
```
```bash
docker exec spuc_container cat /spuc/output/unicorn_sightings.txt
```
Kill the container and make sure it was removed:
```bash
docker kill spuc_container
docker ps -a
```
And run it again, using **the same volume**, and check for the sightings:
```bash
docker run -d --rm --name spuc_container -p 8321:8321 -v spuc-volume:/spuc/output spuacv/spuc:latest
docker exec spuc_container cat /spuc/output/unicorn_sightings.txt
```


## Bind mounts
Managed by the user, can be handy, can be dangerous.  
They are declared with `path:path`:
**-v ./spuc/output:/spuc/output**

```bash
docker kill spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./spuc/output:/spuc/output spuacv/spuc:latest
```
Now let's spot some unicorns!
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=mercury\&brightness=400
cat spuc/output/unicorn_sightings.txt
```
Kill the container and make sure it was removed:
```bash
docker kill spuc_container
ls spuc/output
```
The directory is now in our current wd.
If we use the same bind mount, we can see the sightings:
```bash
docker run -d --rm --name spuc_container -p 8321:8321 -v ./spuc/output:/spuc/output spuacv/spuc:latest
cat spuc/output/unicorn_sightings.txt
```
```bash
ls -l spuc/unicorn_sightings.txt
```
In some versions of docker, this might be owned by root!


### Bind mount files
We can bind mount individual files, like the print config.
First we create the file:
```bash
echo "::::: {time} Unicorn number {count} spotted at {location}! Brightness: {brightness} {units}" > print.config
```
Then we kill the running container and mount it in:
```bash
docker kill spuc_container
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output spuacv/spuc:latest
```
Register a sighting:
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=jupyter\&brightness=210
docker logs spuc_container
```

This file can be edited while the container runs. For example:
```bash
echo "::::: Unicorn number {count} spotted at {location}! Brightness: {brightness} {units}" > print.config
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=venus\&brightness=148
docker logs spuc_container
```

**Warning:** We replaced the file in the container with the file from the host filesystem.  
We could do the same with a whole directory, but be careful not to overwrite important files in the container!

## ! Challenge: Common mistakes with volumes
```bash
docker run -v spuc-vol spuacv/spuc:latest
```
**Problem:** Missing path to mount volume. It uses /spuc-vol in the container, but it wont persist!  
**Fix:** You only messed up the container, nothing to worry about. Stop it and try again.

```bash
docker run -v ./spucs/output:/spuc/output spuacv/spuc:latest
```
**Problem:** You misspelled the path! This will create a new directory called **spucs** and mount it.  
**Fix:** Use sudo rm -rf ./spucs to remove the directory and try again.

```bash
ocker run -v ./spuc-vol:/spuc/output spuacv/spuc:latest
```
**Problem:** `path:path` Therefore, bind mount, and will create **spuc-vol**.  
**Fix:** Use sudo rm -rf ./spuc-volume to remove the directory and try again.

```bash
docker run -v ./spuc:/spuc spuacv/spuc:latest
```
**Problem:** Replaced everything in the container with empty! Could not find /spuc/spuc.py.  
**Fix:** You only messed up the container, nothing to worry about. Try again.

```bash
docker run -v print.config:/spuc/config/print.config spuacv/spuc:latest
```
**Problem:** `name:path`, so volume... However, print.config is not a directory.  
**Fix:** Use docker volume rm print.config to remove the volume and try again.


## Show keypoints slide
