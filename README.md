# Objective of this project

Provide a test environment where it is easy to test Nextcloud features, integrations, under different architectures.

✅ already available
⌛ available soon
⚙️ under construction

This project implemented **Nextcloud** in the following ways:
- ✅ Standalone Nextcloud
- ✅ Federated Nextcloud instances (with several standalone instances)
- ⌛ Nextcloud Global Scale

This project also provides the following **integrations**:
- ✅ Nextcloud Office (based on Collabora Online, for online editiong of office files)
- ⌛ Nextcloud talk high-performance backend (for performant videoconference)
- ⌛ Nextcloud talk recording backend
- ⌛ Nextcloud whiteboard
- ⌛ Nextcloud AppAPI docker socket proxy (for AI services)
- ⌛ Only Office (for online editiong of office files)
- ⌛ Open Project (for project management)

This project also provides a few **other key components** that are nearly always included in real-life Nextcloud deployments or useful for testing purposes:
- ✅ Adminer, a web based database client
- ⌛ Keycloak as SAML or OIDC identity provider for SSO
- ⌛ Stalwart-mail as mail server
- ⚙️ LDAP

# Requirements

Everything that follow has been done on Linux. I don't know how easily it can be ported on other OS.

# Design principles

A few key principles guided the design of this project:

- Should run 100% locally, internet access is not mandatory
- Have little automation, so it is easier to understand what are the interactions between the components
- Provide a clear picture of the network architecture. Many problems come from the network, understanding them is key to solve issues
- Be able to deploy as many parallel Nextcloud instances as needed
- Share as many services as possible (but Nextcloud) to save on hardware resources, and simulate real-life use-cases
- Every web service should be accessible over HTTPS
- Each Nextcloud instance should be "state of the art" configured, with cron and notify_push working (thanks @juliusknorr)
- Be able to deploy as many services as needed (no port mapping/publishing)
- Access to configuration files as easy as possible (work in progress)
- Ability to trash and rebuild in a minute (work in progress)

# A quick overview of the architecture

![Network architecture](./doc/network%20architecture.webp "Network architecture")

# Unfamiliar with docker ?

Read [here](./doc/familiarizewithdocker.md)

# SETUP A LOCAL TEST ENV WITH DOCKER

## first things first

Before starting to play with docker, we need a few things.

### a domain name with a valid wildcard certificate for all subdomains

THE number 1 thing. There are two ways for this:

1. Use the Let's encrypt DNS challenge, see explanation [there](./doc/letsencryptDNSchallenge.md)
2. Use mkcert, see [here](https://github.com/FiloSottile/mkcert)

NB: the first option is a bit more complex as it requires you to purchase a domain name, but allows you to setup a real email server (stalwart-mail), which might not be possible with mkcert.

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

For that, we will use nginx, and customize a bit the default docker image. See everything [here](./apps/reverseproxy/README.md)).

### concept

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
