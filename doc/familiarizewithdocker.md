# Introduction to docker

If you are not familiar with Docker here is a (very) short summary.

## Main concepts

`docker compose`: a docker tool to launch simultaneously a project made of several containers, volumes and networks.

Container: box that contains a service, usually a unique sercice (db, webserver, reverse proxy...)

Docker image: compiled source which a container is started from.

Dockerfile: list of instructions to build a docker image. Usually, when you need to install a service, there are many prerequisites and dependencies. The dockerfile contains these instructions.

## Interests

- Each container can be compared to a box delivering the service without having to know every technology involved.
- Often, one unique configuration file is enough to set the few parameters needed for the service, or better, it is possible to set parameters through environment variables
- Having trouble with the current container ? Remove it, and recreate another one from scratch in seconds.

## Further concepts

- Named volumes: allow data persistence accross container restarts or recreation
- Mounted volumes: as containers are fully encaspulated service, it is sometimes painful to edit stuff inside the container. Mounted volumes allow to bind host directories or files to directories or files into the container. What is modified on the host is changed as well on the container.

## Networks

By default, a container is in the docker "bubble", and not accessible from the host system.

The usual thing which is done to access a container from the host is to bind container ports to ports on the host system. For example, one could bind ports 80 and 443 to an apache container, and that would be sufficient to access the website in the apache container.

While this is a very easy and valid approach, in our case there is quickly not enough ports to allow access all the services we need. To overcome this, we will go a bit further with docker networks.
