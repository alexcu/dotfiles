## Docker

Using aliases defined in `~/.zshrc_docker` based on this [Gist](https://gist.github.com/jgrodziski/9ed4a17709baad10dbcd4530b60dfcbb).

| Alias     | Command                            | Description                                                      |
|-----------|------------------------------------|------------------------------------------------------------------|
| dex       | `docker exec -it <container>`      | Execute a bash shell inside the RUNNING <container>              |
| di        | `docker inspect <container>`       | Return low-level information on Docker objects                   |
| dim       | `docker images`                    | List images                                                      |
| dip       | N/A                                | IP addresses of all named running containers                     |
| dl        | `docker logs <container>`          | Return logs of the container                                     |
| dnames    | N/A                                | Get names of all containers                                      |
| dps       | `docker ps`                        | List all containers                                              |
| dpsa      | `docker ps -a`                     | List all containers including those not running                  |
| drmc      | `docker rm <exited>`               | Removes all exited containers                                    |
| drmi      | `docker rmi <dangling>`            | Removes all dangling images                                      |
| drun      | `docker run -it <img> <cmd>`       | Run command from an image within a new container                 |
| dbash     | `docker run -it bash:4.4`          | Run bash within docker                                           |
| dsp       | `docker system prune --all`        | Remove unused system data                                        |
| dsr       | `docker stop <c>; docker rm <c>`   | Stop then remove <container>                                     |




## Docker Compose

Using the [Docker Compose](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker-compose) zshrc plugin.

| Alias     | Command                        | Description                                                      |
|-----------|--------------------------------|------------------------------------------------------------------|
| dco       | `docker-compose`               | Docker-compose main command                                      |
| dcb       | `docker-compose build`         | Build containers                                                 |
| dce       | `docker-compose exec`          | Execute command inside a container                               |
| dcps      | `docker-compose ps`            | List containers                                                  |
| dcrestart | `docker-compose restart`       | Restart container                                                |
| dcrm      | `docker-compose rm`            | Remove container                                                 |
| dcr       | `docker-compose run`           | Run a command in container                                       |
| dcstop    | `docker-compose stop`          | Stop a container                                                 |
| dcup      | `docker-compose up`            | Build, (re)create, start, and attach to containers for a service |
| dcupb     | `docker-compose up --build`    | Same as `dcup`, but build images before starting containers      |
| dcupd     | `docker-compose up -d`         | Same as `dcup`, but starts as daemon                             |
| dcdn      | `docker-compose down`          | Stop and remove containers                                       |
| dcl       | `docker-compose logs`          | Show logs of container                                           |
| dclf      | `docker-compose logs -f`       | Show logs and follow output                                      |
| dcpull    | `docker-compose pull`          | Pull image of a service                                          |
| dcstart   | `docker-compose start`         | Start a container                                                |
| dck       | `docker-compose kill`          | Kills containers                                                 |
