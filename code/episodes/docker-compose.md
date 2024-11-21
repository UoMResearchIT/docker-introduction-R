



## Running a container
```yml
services:
```
```yml
services:
  spuc:                            # The name of the service
    image: spuacv/spuc:latest      # The image to use
```
```bash
docker compose up
```
## Configuring the container
```bash
docker run -d --rm --name spuc_container -p 8321:8321 -v ./print.config:/spuc/config/print.config -v spuc-volume:/spuc/output -v stats.py:/spuc/plugins/stats.py -e EXPORT=true spuacv/spuc:latest --units iulu
```
### Running in the background
```bash
$ docker compose up -d
```
```bash
docker compose logs
```
### Removing the container when it stops
```bash
docker compose down
```
### Naming the container
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container            # The name of the container
```
```bash
docker compose up -d
```

#### Updating the compose file

### Exporting a port
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=asteroid\&brightness=242
```
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:                          # Starts the list of ports to map
      - 8321:8321                   # Maps port 8321 on the host to port 8321 in the container
```
```bash
docker compose up -d
```
```bash
curl -X PUT localhost:8321/unicorn_spotted?location=asteroid\&brightness=242
```
### Bind mounts
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:                                        # Starts the list of volumes/bind mounts
      - ./print.config:/spuc/config/print.config    # Bind mounts the print.config file
```
```bash
docker compose up -d
```
### Volumes
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output                  # Mounts the volume named spuc-volume
```
```bash
docker compose up -d
```
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output              # Mounts the volume named spuc-volume

volumes:                                      # Starts section for declaring volumes
  spuc-volume:                                # Declares a volume named spuc-volume
```
```bash
docker compose up -d
```
```bash
$ docker volume ls
$ docker compose down -v
$ docker volume ls
```
### Setting an environment variable
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
    environment:                      # Starts list of environment variables to set
      - EXPORT=true                   # Sets the EXPORT environment variable to true

volumes:
  spuc-volume:
```
```bash
docker compose up -d
docker compose logs
```
### Overriding the default command
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]          # Overrides the default command

volumes:
  spuc-volume:
```
```bash
docker compose up -d
docker compose logs
```
### Enabling the plugin
```yml
services:
  spuc:
    image: spuacv/spuc:latest
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py        # Mounts the stats.py plugin
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

volumes:
  spuc-volume:
```
```bash
docker compose up -d
```
```bash
docker compose logs
```
## Building containers in Docker Compose
```yml
services:
  spuc:
  # image: spuacv/spuc:latest
    build:                        # Instead of using the 'image' key, we use the 'build' key
      context: .                  # Sets the build context (the directory in which the Dockerfile is located)
      dockerfile: Dockerfile      # Sets the name of the Dockerfile
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
```
```bash
docker compose up --build -d
docker compose logs
```

#### Simpler Dockerfile
```Dockerfile
FROM spuacv/spuc:latest
RUN pip install pandas
```

## Connecting multiple services
### Adding SPUCSVi to our Docker Compose file
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    ports:
      - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

  spucsvi:                            # Declare a new service named spucsvi
    image: spuacv/spucsvi:latest      # Specify the image to use
    container_name: spucsvi_container # Name the container spucsvi
    ports:                            #
      - "8322:8322"                   # Map port 8322 on the host to port 8322 in the container
    environment:                      #
      - SPUC_URL=http://spuc:8321     # Specify the SPUC_URL environment variable

volumes:
  spuc-volume:
```
```bash
docker compose up -d
docker compose logs
```
### Networks
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    # ports:                            # We can remove these two lines
    #   - 8321:8321
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321

volumes:
  spuc-volume:
```
```bash
docker compose up -d
```

#### Network names
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
    networks:                         # Starts list of networks to connect this service to
      - spuc_network                  # Connects to the spuc_network network

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    networks:                         # Starts list of networks to connect this service to
      - spuc_network                  # Connects to the spuc_network network

volumes:
  spuc-volume:

networks:                             # Starts section for declaring networks
  spuc_network:                       # Declares a network for spuc
    name: spuc_network                # Specifies the name of the network
```

### Depends on
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:                     # Starts section for declaring dependencies
      - spuc                        # Declares that the spucsvi service depends on the spuc service

volumes:
  spuc-volume:
```
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
    healthcheck:                                                  # Starts section for declaring healthchecks
      test: ["CMD", "curl", "--fail", "http://spuc:8321/export"]  # Specifies the healthcheck command (ran from inside the container)
      interval: 3s                                                # Specifies the interval between healthchecks
      timeout: 2s                                                 # Specifies the timeout for the healthcheck
      retries: 5                                                  # Specifies the number of retries before failing completely

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:
      spuc:                                                       # This changed from a list (- spuc) to a mapping (spuc:)
        condition: service_healthy                                # Specifies further conditions for starting the service

volumes:
  spuc-volume:
```

#### Simulating a slow start
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=true
    command: ["--units", "iulu"]
    entrypoint: ["sh", "-c", "sleep 5 && python /spuc/spuc.py"]   # Adds a sleep command to the entrypoint to simulate a slow start
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://spuc:8321/export"]
      interval: 3s
      timeout: 2s
      retries: 5

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:
      spuc:
       condition: service_healthy

volumes:
  spuc-volume:
```
```bash
docker compose up -d
```


#### Simulating an unhealthy service
```yml
services:
  spuc:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: spuc_container
    volumes:
      - ./print.config:/spuc/config/print.config
      - spuc-volume:/spuc/output
      - ./stats.py:/spuc/plugins/stats.py
    environment:
      - EXPORT=false                                # Sets the EXPORT environment variable to false
    command: ["--units", "iulu"]
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://spuc:8321/export"]
      interval: 3s
      timeout: 2s
      retries: 5

  spucsvi:
    image: spuacv/spucsvi:latest
    container_name: spucsvi
    ports:
      - "8322:8322"
    environment:
      - SPUC_URL=http://spuc:8321
    depends_on:
      spuc:
       condition: service_healthy

volumes:
  spuc-volume:
```
```bash
docker compose up -d
```



