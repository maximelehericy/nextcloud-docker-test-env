# Adminer

Adminer is a web-based database client, very usefull to browse Nextcloud database in a few clicks.

## Launch adminer container
To launch an Adminer instance, run the following command:

```sh
docker run --network apps --network databases --name adminer --restart unless-stopped -d adminer
```

The container `adminer` must be attached to:
- the `apps` network so it can talk to `reverseproxy`,
- the `database` network, so it can talk to all nextcloud database containers (see [mariadb.yml](../nextcloud/standard/mariadb.yml#L10))

## Add adminer entry to `/etc/hosts`

To be able to reach the `adminer` interface from the browser, add an adminer entry to the `/etc/hosts` file (replace <yourdomain>):

```
172.19.0.1 adminer adminer.<yourdomain>
```

## Add a conf file for the reverse proxy

```sh
nano apps/reverseproxy/conf/adminer.conf
```

Paste the following content (replace <yourdomain>):

```conf

server {
    listen 80;
    listen [::]:80;
    server_name adminer.<yourdomain>;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}


server {
    #listen 80;
    listen 443 ssl;
    http2 on;
    server_name adminer.<yourdomain>;

    include /etc/nginx/includes/ssl.conf;

    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;
    set $upstream http://adminer:8080;

    location / {
        include /etc/nginx/includes/proxy.conf;
        proxy_pass $upstream;
    }
    access_log off;
    error_log /var/log/nginx/error.log error;
}

```

Restart your `reverseproxy` container:

```sh
docker restart reverseproxy
```
