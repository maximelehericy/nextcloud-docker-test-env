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
