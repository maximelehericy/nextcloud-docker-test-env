# Nextcloud Whiteboard

At the moment, the Nextcloud Whiteboard has one limitation: it cannot be used by multiple Nextcloud instances.

Tune the `whiteboard.env.example` file in order to connect your whiteboard to a selected Nextcloud instance. Then, run the following command:

```sh
docker run \
    --network apps \
    --env-file apps/whiteboard/whiteboard.env \
    --restart unless-stopped \
    --name whiteboard \
    -d ghcr.io/nextcloud-releases/whiteboard:release
```

Then:
- add an entry in the `/etc/hosts` file matching the content of the `openproject.env` file
- install and configure the Nextclodu Whiteboard integration app from the Nextcloud app store
- add a conf file for the reverse proxy. The following example should work:

```conf

server {
    listen 80;
    listen [::]:80;
    server_name whiteboard.YOURDOMAIN;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}


server {
    #listen 80;
    listen 443 ssl;
    http2 on;
    server_name whiteboard.YOURDOMAIN;

    include /etc/nginx/includes/ssl.conf;

    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;
    set $upstream http://whiteboard:3002;

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;

        proxy_pass $upstream;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    access_log off;
    error_log /var/log/nginx/error.log error;
}


```
