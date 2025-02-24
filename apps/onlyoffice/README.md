# Run Only Office in a Docker container for test purposes

## Start the container
```sh
docker run -d --name onlyoffice \
  --network apps \
  --restart unless-stopped \
  -e JWT_ENABLED=true \
  -e JWT_SECRET=onlyoffice \
  onlyoffice/documentserver:8.2.2
```

## Remove the container
docker stop onlyoffice && docker rm onlyoffice

## Only Office secret

By default, Only Office sets a random secret that must be entered in Nextcloud Only Office connector. The default secret can be retrieved with the following command:

```sh
docker exec -it onlyoffice cat /etc/onlyoffice/documentserver/local.json | jq '.services.CoAuthoring.secret.session.string'
```

For simplicity reasons, the secret in set to `onlyoffice` with the `-e JWT_SECRET=onlyoffice` parameter from the `docker run` command. This is the value that you will have to enter in the Nextcloud settings for Only Office.

## Access your Only Office container

As for every other service, it is need two things:
1. add an entry to the `/etc/hosts` file of your host system, like `172.19.0.1 onlyoffice.YOURDOMAIN`
2. add a conf file in the reverse proxy conf folder. The following should nicely fit:

```conf
server {
    listen 80;
    listen [::]:80;
    server_name onlyoffice.YOURDOMAIN;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}
server {
    #listen 80;
    listen 443 ssl;
    http2 on;

    server_name onlyoffice.YOURDOMAIN;
    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;

    set $onlyoffice http://onlyoffice;

    include /etc/nginx/includes/ssl.conf;

    location / {
        include /etc/nginx/includes/proxy.conf;
        proxy_pass $onlyoffice;
    }

    access_log off;
    error_log /var/log/nginx/error.log error;
}
```
