# Docker Desktop

Just to get concept right.
Not available for Linux.
Freemium.


## Dashboard
We will look at **Containers** and **Images** only.  
**Search** bar at the top to search for images.


## Getting images
Search and pull of SPUC container: **spuacv-spuc**  
Click on image to see **docs**.  
Show how to select a **tag**.  
Option to ***run*** or ***pull***.

also pull **hello-world** and **alpine** images.


## Inspecting images
Images tab shows list showing spuc, alpine and hello-world.

Click on image name to inspect.
Go to **vulnerabilities** and start analysis.

Important to check, but this is ok, verified image **python:3-slim**.

## Running 

Images are **immutable snapshots** of an environment, to be used as **templates**.

Containers are **executions of images**, they are running, and become **mutable**.

Run the **hello-world** image using the button from Images tab - confirm Run on prompt.

We are on the **Containers tab** now.  
Look at the **random name**.  
Look at Logs, Inspect, Bind mounts, Exec, Files, Stats tabs.  
It seems like the container has **already stopped**.  
Status says "Exited 0".  
Run again, **from the container**.  
Look at repeated output.

Run again, but **from the images** tab.
Look at new random name.

Nature of containers is usually **ephemeral**.  
Look at container list on Containers tab. They are both stopped.  
Why 2 and not 1 or 3?  
Run another hello-world container form the images tab to see a third.


## Interacting with containers

Not all containers are short lived. Run the **spuc** container.  
Docs say we need to **expose 8321**, so do that on **optional settings**.  
Container is still running. Confirm this on Containers tab.  
Click on name of the container to go back to its logs.

Image: Containers list, spuc still running.

### Spot a unicorn!
From a terminal:
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=100
```

The docs mention we can configure the print with the `print.config` file.
Open the terminal tab in the container.
```bash
pwd
ls
apt update
apt install nano
nano config/print.config
```
chango to
```
::::: {time} Unicorn number {count} spotted at {location}!! Brightness: {brightness} {units}
```
Then try another curl:
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=moon\&brightness=200
```
Confirm change in the printed logs.

The container is **like a VM**... but it is **not meant to**... it is meant to be ephemeral.  
Lets stop the container.  
Confirm the status is exited.

Run another spuc image **from the images** tab (**no port**).  
Try to cat the `config/print.config` file.  
Look for nano in the terminal.  
This is a new container, not the same we modified.  
Check container list.


## Reviving containers

Go back to containers list and click on start on the first spuc container.  
It is running again, and we can see the config and we have nano.


## Naming containers

Lets try adding a name to the container.  
Run a new spuc container **from the images** tab, and name it **SPUC** (**no port**).

In the container list, it is easier to find... but we didn't map the port!  
Try to use same name again, it fails.  
We cannot reuse names, we need to clean up.


## Cleaning up

From container list, delete container called **SPUC**.

From image list, try to delete `hello-world`.  
It says it is **in use**.

Delete all the containers.  
Make sure it says **unused** now. Try again.


## Limitations - Why not Docker Desktop?

Limited in how you can run the containers.

Run **alpine**. Nothing happens.


## Show keypoints slide
