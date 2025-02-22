# objectives of this guide

Since I have started to work for Nextcloud, I have always felt moments where the tools I had for testing Nextcloud were not enough. At the beginning, I relied on LTDs, but it is sometimes slow, sometimes it bugs and I can't help but asking sysadmin to the recue, sometimes I am on the train and getting crazy because of the intermitent internet connection. Also when custo for customer C collides with custo of customer A and B in the middle of a demo...

So I started to play with docker, having my first nextcloud instance deployed and accessed on localhost, and started to taste to the ease of dropping and recreating everything from scratch in a minute. But as Nextcloud is barely a standalone app but rather integrates with a galaxy of stuff that start to be pretty large, localhost and port mapping, quickly gets limited... SSL encrytpion had been another kind of problem...

I tested for some time to work on a hosted VM, where I could install everything I needed, and easily get trusted SSL certificates.

But again it drove me crazy trying to ssh on the train... and "mine de rien", installing VMs takes time...

So I went back to docker... on a Quimper - Berlin train trip i searched for a way of having trusted certificates locally on my computer. I found a solution in Berlin, and that unlocked a new era for my local testing lab: i could now access all my services running in docker over https, using real domain names.

To overcome the ports mapping problem of docker (docker gateway has only one port 443 🙃), quickly I had a reverse proxy in place to access various nextcloud instances running at the same time.

I could now play with federation, have collabora or only office working not on my computer ip but on real domain names, like in production.

And with a little bit of extra work, I got working a full galaxy of stuff that is useful for a Nextcloud demo or some crazy Nextcloud tests to check and answer a prospect request:

- collabora
- a whiteboard
- only office
- open project
- appapi docker socket proxy
- federated instances
- a global scale setup with a lookup server
- an identity provider
- a mail server
- talk hpb
- talk recording backend
- ldap
- ...

I have now a nearly complete production system, and my work would have probably be a lot easier if I had had this before. So here is the guide, and I hope it will help others having a proper test lab that will in the end serve Nextcloud development, performance and stability.

# requirements

Everything that follow has been done on Linux. I don't know how easily it can be ported on other OS.

# principles and guidelines

A few key principles, guidelines, that helped me design what follows:

- should run 100% locally, internet access is not mandatory
- I want to understand the things I deploy (no AIO-like automated deployment)
- I want to understand and have a clear picture of the network architecture. Many problems come from the network, understanding them is key to solve issues
- I want to be able to deploy as many nextcloud instances as I need
- on the other hand, I want as many other components as possible to be shared among all my nextcloud instances (e.g. to save on hardware resources, I don't want to spin up one collabora server per nextcloud instance)
- every web service should be accessible over https
- each nextcloud instance should be configured in a state of the art way, with cron and notify_push working (thks julius)
- be able to deploy as many services as needed (no port mapping/publishing)
- access to configuration files as easy as possible (work in progress)
- ability to trash and rebuild in a minute (work in progress)

# a quick overview of the architecture

The /etc/hosts file from the computer acts as DNS: every new service accessible from the host should be declared in the /etc/hosts file.

Most of the domain entries  from /etc/hosts are mapped to a single fixed ip, the one of an nginx reverse proxy that serves web services hosted in docker containers.

From the network point of view, all web services belong to the "apps" network. Most of the services are launched with the docker run command.

Nextcloud is the only exception, and is launched with docker compose as it requires other components to run (Redis, DB, cron, notify_push and apache), and those other components cannot be shared by other nextcloud instances.

All nextcloud databases belong to the database network, and can be queried with adminer, a web based database client.

# DOCKER INTRODUCTION

## concepts

Container: box that contains a service, usually a unique sercice (db, webserver, reverse proxy...)

Docker image: compiled source which a container is started from.

Dockerfile: list of instructions to build a docker image. Usually, when you need to install a service, there are many prerequisites and dependencies. The dockerfile contains these instructions.

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

# SETUP A LOCAL TEST ENV WITH DOCKER

## first things first

Before starting to play with docker, we need a few things.

### a domain name with a valid wildcard certificate for all subdomains

THE number 1 thing.
That is done with the Let's encrypt DNS challenge: go [there](./doc/DNSchallenge.md) to follow the guide.

### install docker

Go [there](https://docs.docker.com/engine/install/) and follow the installation procedure matching your OS.

### add your host user to the docker group

So you don't have to sudo all the time. Follow the instructions [there](https://docs.docker.com/engine/install/linux-postinstall/)

### get notes somewhere

To track things that your brain will forget

## dive into docker setup

### set the network layer

Follow the network documentation [there](./doc/Network%20setup.md)

### configure a reverse proxy for SSL termination

SSL is beautiful to secure client-server communications, but a pain to handle for the noob.

For that, we will use nginx, and customize a bit the default docker image.

#### concept

Each service has its own reverse proxy conf file to keep things well organized.

### set up the first nextcloud instance

For this, we will use docker compose. Docker compose is a tool that allows to launch at once several containers, unlike the docker run command we used above.

Each sercice that should be launched is decribed in a yaml file, where one can specify the networks, volumes, docker images that services base on, environment variables, etc.

Docker compose does an interesting thing when launching a set of servives: it prefixes all the services with a project label, so it is easy to know which containers are siblings. If not specified, a random name is applied, but we will prpfit from that feature to name our different test instances: nc1, nc2, nc3, test, tutorial, sse, etc.

#### prepare the yaml files for the services

#### structure the directory if you need to map volumes

#### run docker compose up

#### add an entry for the new service in your /etc/hosts file

#### tweak the nc.conf file for the reverseproxy to serve the newly created container

#### open your browser and access the service !

# going further

## list of usefull services

- adminer: web based database client
- stalwart-mail: mail server
- keycloak: to enable sso
- all the galaxy of services around nextcloud:
  - nextcloud talk hpb
  - nextcloud talk recording backend
  - openproject
  - whiteboard
  - appapi
  - collabora
  - onlyoffice

## what it is possible to test

- federation (files and talk)
- global scale
- database clustering, replication...
- server-side encryption
- oidc, saml
- e2ee
