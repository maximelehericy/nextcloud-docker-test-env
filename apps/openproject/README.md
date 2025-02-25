# Run OpenProject

- Copy the `openproject.env.example` file and rename it to `openproject.env`.
- Change the `YOURDOMAIN` according to your domain.
- Run the following command:

```sh
docker run -d --name openproject \
  --env-file apps/openproject/openproject.env \
  -v openproject_pgdata:/var/openproject/pgdata \
  -v openproject_assets:/var/openproject/assets \
  --network apps \
  --restart unless-stopped \
  openproject/openproject:15.0.2
```

To stop the container:

```sh
docker stop openproject && docker rm openproject
```

To remove the persistent data:
```sh
docker volume rm openproject_pgdata openproject_assets
```

Then:
- add an entry in the `/etc/hosts` file matching the content of the `openproject.env` file
- install and configure the OpenProject integration app from the Nextcloud app store
- add a conf file for the reverse proxy. The following example should work:

```conf
server {
    listen 80;
    listen [::]:80;
    server_name openproject.YOURDOMAIN;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}
server {
    #listen 80;
    listen 443 ssl;
    http2 on;

    server_name openproject.YOURDOMAIN;
    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;

    set $openproject http://openproject;

    include /etc/nginx/includes/ssl.conf;



    location / {
        include /etc/nginx/includes/proxy.conf;
        proxy_pass $openproject;
    }

    access_log off;
    error_log /var/log/nginx/error.log error;
}

```
