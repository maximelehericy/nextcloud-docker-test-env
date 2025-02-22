# Introduction to docker

If you are not familiar with Docker here is a (very) short summary.

## concepts

Container: box that contains a service, usually a unique sercice (db, webserver, reverse proxy...)

Docker image: compiled source which a container is started from.

Dockerfile: list of instructions to build a docker image. Usually, when you need to install a service, there are many prerequisites and dependencies. The dockerfile contains these instructions.

docker compose:

## interests

- A box delivering the service without having to know every technology involved.
- often, one unique configuration file is enough to set the few parameters needed for the service, or better, it is possible to set parameters through environment variables
- not happy, or having trouble with the current container ? Remove it, and recreate another one from scratch in seconds.

## further concepts

- named volumes: allow data persistence accross container restarts or recreation
- mounted volumes: as containers are fully encaspulated service, it is sometimes painful to edit stuff inside the container. Mounted volumes allow to bind host directories or files to directories or files into the container. What is modified on the host is changed as well on the container.

## networks

By default, a container is in the docker "bubble", and not accessible from the host system.

The usual things one can find on forums is to bind container ports to ports on the host system. For example, one could bind ports 80 and 443 to an apacbe container, and that would be sufficient to access the website in the apache container.

This is a very fast and easy approach, but quickly there is not enough ports to play with or it becomes a memory game to remember which port is bound to which service...

But going a bit further with docker networks enables one to have a production like system, with domain names, trusted TLS certificates, avoid all sort of troubles of port conflicts or self signed certificates.

Want to visit website1 ? Go to https://website1.your.local.domain.com. Want to visit website2 ? Go to https://website2.your.local.domain.com.
As simple as that :)
