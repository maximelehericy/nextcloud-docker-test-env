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
- ✅ Nextcloud whiteboard
- ✅ Nextcloud AppAPI docker socket proxy (for AI services)
- ✅ Only Office (for online editiong of office files)
- ✅ Open Project (for project management)

This project also provides a few **other key components** that are nearly always included in real-life Nextcloud deployments or useful for testing purposes:
- ✅ Adminer, a web based database client
- ✅ Keycloak as SAML or OIDC identity provider for SSO
- ⌛ Stalwart-mail as mail server
- ✅ LDAP for user and group management

# Requirements

Everything that follow has been done on Linux. I don't know how easily it can be ported on other OS.

# Design principles

A few key principles guided the design of this project:

- Should **run 100% locally**, internet access is not mandatory
- Have **little automation**, so it is easier to understand what are the interactions between the components
- Provide a clear picture of the **network architecture**. Many problems come from the network, understanding them is key to solve issues
- Be able to deploy **as many parallel Nextcloud instances as needed**
- **Share as many services as possible** (but Nextcloud) to save on hardware resources, and simulate real-life use-cases
- Every web service should be accessible on a **domain name over HTTPS** (without any port specified)
- Each Nextcloud instance should be "state of the art" configured, with **cron and notify_push** working (thanks @juliusknorr)
- Be able to **deploy as many services as needed** (no port mapping/publishing)
- Access to configuration files as easy as possible (work in progress)
- Ability to trash and rebuild in a minute (work in progress)

# A quick overview of the architecture

![Network architecture](./doc/network%20architecture.webp "Network architecture")

# Unfamiliar with docker ?

Read [here](./doc/familiarizewithdocker.md)

# Setup

## First things first

Before starting to play with docker, you will need a few things:

1. get a valid wildcard SSL certificate
2. install docker
3. add your host user to the docker group

### Getting a valid wildcard certificate

This is the number one thing. **Please do not go bypass this step**. Getting valid SSL certificates will definitely make the next setup steps way easier, as well as easing a lot all the integrations between Nextcloud and its satellites.

There are two pretty easy ways for this:

1. Use the Let's encrypt DNS challenge, see explanation [there](./doc/letsencryptDNSchallenge.md)
2. Use mkcert, see [here](https://github.com/FiloSottile/mkcert)

||Let's encrypt DNS challenge|mkcert|
|---|:---:|:---:|
|**Advantages**|really similar to production|very quick to setup|
||enables a local IMAP & SMTP<br /> mail server integration||
|**Drawbacks**|need to purchase a domain name|no IMAP integration possible|

As Nextcloud features an email client, the Let's Encrypt DNS challenge can be a better choice.

### Install docker

Go [there](https://docs.docker.com/engine/install/) and follow the installation procedure matching your OS.

### Add your host user to the docker group

So you don't have to sudo all the time. Follow the instructions [there](https://docs.docker.com/engine/install/linux-postinstall/)

## Dive into the docker setup

### Create the network layer

Follow the network documentation [there](./doc/Network%20setup.md)

### Tweak your `/etc/hosts` file

To your `/etc/hosts` file, add the following line:

```
172.19.0.1 test.<yourdomain> nc1.<yourdomain> nc2.<yourdomain>
```

### Configure a reverse proxy for SSL termination

SSL is beautiful to secure client-server communications, but is sometimes a pain to handle for the beginner. For that, we will use nginx, and customize a bit the default docker image. See everything [here](./apps/reverseproxy/README.md).

## Launch your first nextcloud instance

For this, we will use docker compose. Docker compose is a tool that allows to launch at once several containers, unlike the docker run command we used above.

Each sercice necessary for Nextcloud to work is decribed in a yaml file, where networks, volumes, docker images that services base on, environment variables, etc. are defined.

To follow the tutorial to spin up a first test Nextcloud instance, go [there](./apps/nextcloud/standard/README.md)

## Additional satellites

- Adminer (web-based DB client): read [here](./apps/adminer/README.md)
- Nextcloud Office (Collabora Online): read [here](./apps/collabora/README.md)
- Keycloak (IDP): read [here](./apps/keycloak/README.md)
- Only Office (online editing): read [here](./apps/onlyoffice/README.md)
- OpenProject (project management): read [here](./apps/openproject/README.md)
- Nextcloud Whiteboard (based on Excalidraw): read [here](./apps/whiteboard/README.md)
- LDAP server (based on OpenLDAP): read [here](./apps/openldap/README.md)
- AppAPI Docker Socket Proxy : read [here](./apps/appapi/README.md)
