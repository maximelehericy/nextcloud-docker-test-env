# Host your own electronic signature tool

## Introduction
Based on Documenso.

The following tutorial aims to install the Documenso app along with the required PostgreSQL database, a Minio object store needed for the documents transfers in betwwen Nextcloud and Documenso, and obviously the installation and configuration of the Nextcloud Documenso integration.

A few things:
- containers will be deployed using `docker compose`, the docker compose project name is `documenso`, it will prefix all container names.
- the documenso container is named `documenso` and will be configured to be reachable on https://minio.YOURDOMAIN
- the PostgreSQL container is named `database`
- the Minio container is named `minio`, and will be configured to be reachable on https://minio.YOURDOMAIN
- Minio also provides a console accessible under https://minio.YOURDOMAIN/minio/ui
- it is mandatory that the documenso app and the minio container are both accessible from all clients (end users and Nextcloud)
- On docker hub, Documenso images are not tagged, so one needs to copy the ID of an image in order to update it (see [here](./documenso.yml#31)).
- In Nextcloud, the signature **only works on PDF files**.

We will configure OIDC authentication for Documenso to siplify account creation and login, based on our existing Keycloak setup (see [here](../keycloak/README.md)).

Documenso seems to be a very promising product, yet still young, and sometimes lacks documentation which can make the setup a bit difficult. Let's hope there are not too many mistakes in the following lines :).

Sources:
- generate a p12 certificate: https://docs.documenso.com/developers/local-development/signing-certificate
- deploy Documenso in Docker: https://github.com/documenso/documenso/blob/main/docker/README.md

## Preparation

### Generate a p12 certificate

```sh
openssl genrsa -out apps/documenso/cert/private.key 2048

# without days parameter so it is always valid
openssl req -new -x509 -key apps/documenso/cert/private.key -out apps/documenso/cert/certificate.crt # -days 365

# for the password prompt, use "documenso". If using an other password, you'll have to update the ad hoc entry in the .env file.
openssl pkcs12 -export -out apps/documenso/cert/certificate.p12 -inkey apps/documenso/cert/private.key -in apps/documenso/cert/certificate.crt -legacy
```

### Environment variables

```sh
# Generate NEXT_PRIVATE_ENCRYPTION_KEY
openssl rand -hex 32
# Generate NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY
openssl rand -hex 32
```

Copy the `.env.example` file to `.env`, and update it accordingly.
See (partial) documentation here: https://github.com/documenso/documenso/blob/c82388c40a260ea3ca3fa4a8136800135b8928e5/.env.example

### Launching the containers
```sh
docker compose -p documenso --env-file apps/documenso/.env -f apps/documenso/documenso.yml up -d
```

### Checking the logs
```sh
# for documenso
docker logs documenso-documenso-1
# for minio
docker logs documenso-minio-1
```

### Configure reverse proxy to access the containers on domains with trusted certificates


Create two new configuration files under `apps/reverseproxy/conf/`:

```sh
touch apps/reverseproxy/conf/documenso.conf
touch apps/reverseproxy/conf/minio.conf
```

Use the following reverse proxy configuration for `documenso`. Adapt `YOURDOMAIN`.

```conf
server {
    listen 80;
    listen [::]:80;
    server_name documenso.YOURDOMAIN;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    #listen 80;
    listen 443 ssl;
    http2 on;
    server_name documenso.YOURDOMAIN;

    include /etc/nginx/includes/ssl.conf;

    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;
    set $documenso http://documenso-documenso-1:3000;

    location / {
        include /etc/nginx/includes/proxy.conf;
        proxy_pass $documenso;
    }

    access_log off;
    error_log /var/log/nginx/error.log error;
}
```

And for `minio`, use the following configuration (also adapt YOURDOMAIN):

```conf

server {
    listen 80;
    listen [::]:80;
    server_name minio.YOURDOMAIN;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    #listen 80;
    listen 443 ssl;
    http2 on;
    server_name minio.YOURDOMAIN;

    include /etc/nginx/includes/ssl.conf;
    # client max body size needed to send big PDF files and avoid a 413 Entity too large issue
    client_max_body_size 0;

    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;
    set $minio http://documenso-minio-1;

    location / {
        include /etc/nginx/includes/proxy.conf;
        proxy_pass $minio:9000; # This uses the upstream directive definition to load balance
    }

   location /minio/ui/ {
      rewrite ^/minio/ui/(.*) /$1 break;
      proxy_pass $minio:9001; # This uses the upstream directive definition to load balance
   }
}

```

Restart the reverse proxy
```sh
docker restart reverseproxy
```

Check that the restart went well
```sh
docker logs reverseproxy
```

## Open Documenso web Interface

Navigate to https://documenso.YOURDOMAIN.

### Admin account creation

There is no admin account by default, so you need to create it. First option is to user adminer to execute the following SQL statement to create the following user:
- email: `admin@mail.local.mlh.ovh` (update to your domain)
- url: `admin`
- name: `admin`
- password: `password` (if you wish to set a password different that `password`, you need to generate a hash of the password you would like to set and replace the hash below)

```sql
INSERT INTO "User" (
    name,
    email,
    "emailVerified",
    password,
    source,
    "identityProvider",
    signature,
    roles,
    "createdAt",
    "lastSignedIn",
    "updatedAt",
    "twoFactorBackupCodes",
    "twoFactorEnabled",
    "twoFactorSecret",
    "customerId",
    url,
    "avatarImageId"
) VALUES (
    'admin',
    'admin@mail.local.mlh.ovh',
    NULL, -- or a specific timestamp if email is verified
    '$2a$12$IZMAXpmiIXOBbu8p2tU9ueBY10o0pvMNj3Y/U4/OczMvrtEw/7F22', --this is the bcrypt hash for the default password of password change to the hash for your REAL password make it strong
    'source_value',
    'DOCUMENSO', --this is the identity provider Documenso supports Google and OIDC however that is beyond the scope of this tutorial
    'signature_value',
    '{ADMIN}', --change to USER if you wnat to create a USER account instead
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL, -- or specific backup codes if two-factor is enabled
    FALSE,
    NULL, -- or specific secret if two-factor is enabled
    12, --this must be a UNIQUE customer ID change if necessary
    'admin', --this must be a UNIQUE URL endpoint change if necessary
    NULL -- or specific avatarImageId if available
);
```

The second option works only if you have configure SSO with OIDC sign up. Then you go to https://documenso.YOURDOMAIN, do not enter credentials but click on the `keycloak-oidc` button below the credential form. You are redirected to the keycloak (or other) IDP, where you can log in. Once logged in, your account is a default USER account, and you will need the following commands to switch it to ADMIN:

Launch PostgreSQL command line interface
```sh
docker exec -it documenso-database-1 psql -U documenso -d documenso
```

Run the SQL update statement
```sql
UPDATE "User" SET roles="{ADMIN}" WHERE "name"=admin;
exit;
```

## Try to upload a document

To verify that everything is working, try to upload a document.

## Install the Nextcloud Documenso integration app

From your Nextcloud app store, install https://apps.nextcloud.com/apps/integration_documenso.

## Connect your Nextcloud account to Documenso

Follow the instructions [here](https://github.com/nextcloud/integration_documenso#settings).

