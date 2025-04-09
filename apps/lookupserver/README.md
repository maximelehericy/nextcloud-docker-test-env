# Set up a lookup server for Nextcloud

What is needed:
0. a working reverse proxy (see [here](../reverseproxy/README.md) and there ).
1. an apache container (nextcloud original dockerfile tuned)

Note: before building, **change the public URL of your lookup server** [there](./apache/server/config/config.php#59).

```sh
bash apps/lookupserver/apache/build.sh
bash apps/lookupserver/lsdb/build.sh
```

Default usernames and passwords for the lookup server itself and its database are `lookup` and `lookup`. Changing the username/password for the lookup server itself either happens in the [config.php](./apache/server/config/config.php). Changing the username:password for the database happens in the [lookupdb.yml](lookupdb.yml)

2. a mariadb container in which the dump needs to be imported

```sh
docker compose -p ls -f apps/lookupserver/lookupdb.yml -f apps/lookupserver/lookupserver.yml down
docker volume rm ls_lookup
docker volume rm ls_db
docker compose -p ls -f apps/lookupserver/lookupdb.yml -f apps/lookupserver/lookupserver.yml up -d
```

Nextcloud is very tolerant to the lookup server loosing data. It is possible to completely drop the lookup server, rebuild it empty, and the Nextcloud nodes using it will resync the data automatically upon next cronjob.

# References
- tweak the docker image of the lookup server: https://stackoverflow.com/questions/56295895/can-not-find-autoload-php-when-running-laravel-in-a-docker-container

## Reverse proxy conf for the lookup server

Create a configuration file in the conf folder of your reverse proxy for the lookup server:
```sh
touch apps/reverseproxy/conf/lookup.conf
```

Paste the following config in the file (change the domain ;)
```conf
server {
    listen 80;
    listen [::]:80;
    server_name  lookup.YOURDOMAIN;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}


server {
    #listen 80;
    listen 443 ssl;
    http2 on;
    server_name lookup.YOURDOMAIN;

    include /etc/nginx/includes/ssl.conf;

    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;
    set $upstream http://lookup;

    location / {
        include /etc/nginx/includes/proxy.conf;
        proxy_pass $upstream;
    }
    access_log off;
    error_log /var/log/nginx/error.log error;
}
```

Restart the reverse proxy
```sh
docker restart reverseproxy
```

## test lookup server

Some test curl request to verify the lookup server is working as expected:

From inside the container:
```sh
# get lookup server status
curl -X GET http://localhost/status
# insert data
curl -v -X POST -H "Content-Type: application/json" -H "Authorization: Bearer lookup" -d @/var/www/html/data/test.json http://localhost/users
# search for data from the lookup server container itself
curl -v -X GET http://localhost/users?search=alice
```

You can check the test file uploaded during the docker build command [here](./apache/server/data/test.json).

From outside the container:
```sh
# get lookup server status
curl -X GET https://lookup.local.mlh.ovh/status
# search for a user from outside of docker
curl -v -X GET https://lookup.local.mlh.ovh/users?search=alice
# instert data in the lookup database
curl -v -X POST -H "Content-Type: application/json" -H "Authorization: Bearer lookup" -d @apps/globalscale/lookup/apache/server/data/test.json https://lookup.local.mlh.ovh/users
```

To test the db connection in between the containers, use the following:

```sh
docker exec -it -u 33 ls-lookup-1 mysql -h db -u lookup -plookup lookup -e "show databases;";
```
