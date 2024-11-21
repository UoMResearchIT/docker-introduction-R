



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
```bash
docker kill spuc_container
docker run --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v ./stats.py:/spuc/plugins/stats.py -e EXPORT=true spuacv/spuc:latest --units iulu
```
## Creating Docker Images
```Dockerfile
FROM spuacv/spuc:latest
```
```bash
docker build -t spuc-stats ./
```

## Context


### The Dockerfile name
```bash
docker build -t spuc-stats -f my_recipe ./
```

```bash
docker image ls
```
```bash
docker run --rm spuc-stats
```
```bash
docker run --rm --name spuc-stats_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v ./stats.py:/spuc/plugins/stats.py -e EXPORT=true spuc-stats --units iulu
```
```Dockerfile
RUN pip install pandas
```
```bash
$ docker build -t spuc-stats ./
```
```bash
docker run --rm --name spuc-stats_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v ./stats.py:/spuc/plugins/stats.py -e EXPORT=true spuc-stats --units iulu
```
```bash
curl localhost:8321/stats
```
## COPY
```Dockerfile
COPY stats.py /spuc/plugins/stats.py
```
```bash
docker build -t spuc-stats ./
```

## Layers

```bash
docker run --rm --name spuc-stats_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -e EXPORT=true spuc-stats --units iulu
```
```Dockerfile
COPY print.config /spuc/config/print.config
```
```bash
docker build -t spuc-stats ./
docker run --rm --name spuc_container -p 8321:8321 -v spuc-volume:/spuc/output -e EXPORT=True spuc-stats --units iulu
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=saturn\&brightness=87
```
```bash
docker logs spuc_container
```
## ENV
```Dockerfile
ENV EXPORT=True
```
```bash
docker build -t spuc-stats ./
docker run --rm --name spuc-stats_container -p 8321:8321 -v spuc-volume:/spuc/output spuc-stats --units iulu
```

## ARG


## Layers - continued
```Dockerfile
FROM spuacv/spuc:latest

ENV EXPORT=True

RUN pip install pandas

COPY stats.py /spuc/plugins/stats.py
COPY print.config /spuc/config/print.config
```
```bash
docker build -t spuc-stats ./
```

## ENTRYPOINT and CMD
```Dockerfile
ENTRYPOINT ["python", "/spuc/spuc.py"]
CMD ["--units", "iulu"]
```
```bash
docker build -t spuc-stats ./
docker run --rm --name spuc-stats_container -p 8321:8321 -v spuc-volume:/spuc/output spuc-stats
```
## Building containers from the ground up
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


