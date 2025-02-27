# Run a standalone Signaling Server for Nextcloud Talk

The signaling server is used to interface the Nextcloud Server with the Janus WebRTC gateway.

## Pull the reference docker image from Struktur repository

```sh
docker pull strukturag/nextcloud-spreed-signaling:master
```

## Build the custom image for our test environment

The image from struktur does not expose any ports, but we need at least one, usually the `8088`, as written in the [Dockerfile](./Dockerfile). To build this docker file, run:

```sh
bash apps/talk/signalingserver/build.sh
```

The newly built docker image is named `signalingserver`.

## Tune the `signalingserver` configuration

The configuration [file](./server.conf) has the following parameters tuned:
- `http.listen` is set to `0.0.0.0:8088`
- we can ignore `certificate` and `key` as the signaling server will run behind our reverse proxy.
- `session.hashkey`, either keep the existing content or run `openssl rand -hex 32` to get a new value
- `session.blockkey`, either keep the existing content or run `openssl rand -hex 16` to get a new value
- `clients.internalsecret`, best to keep it as is for test purpose. It will be used by the recording backend later on.
- `backends.allowall` is set to `true`, for testing purposes, to avoid having to declare each new Nextcloud instance in the signaling server configuration
- `backends.allowall`, best to keep it as is for test purpose. It will be used to configure the Nextcloud Talk app later on
- `nats.url` is set to `nats://loopback`
- `mcu.type` is set to `janus`
- `mcu.url` is set to `ws://janus:8188`
- `mcu.maxstreambitrate` can be used to shrink or extend the video stream resolution
- `mcu.maxscreenbitrate` can be used to shrink or extend the screensharing stream resolution

**Every change made to the configuration while the docker container is up will need a container restart with** `docker restart signalingserver`

## Run the signaling server in a standalone container

```sh
docker run \
    --network apps \
    --restart unless-stopped \
    --volume /etc/letsencrypt/:/etc/letsencrypt/:ro \
    --volume ${PWD}/apps/talk/signalingserver/server.conf:/config/server.conf:ro \
    --name signalingserver -d signalingserver
```

To stop and remove the container:
```sh
docker stop signalingserver && docker rm signalingserver
```

## Create a configuration file in the reverse proxy for the signaling server

```sh
nano apps/reverseproxy/conf/signalingserver.conf
```

The following configuration should work (change YOURDOMAIN !):

```conf
# configuration adapted from https://github.com/strukturag/nextcloud-spreed-signaling/blob/master/README.md#nginx
server {
    listen 443 ssl;
    http2 on;
    server_name signalingserver.YOURDOMAIN;

    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_protocols TLSv1.2;
    ssl_ecdh_curve secp384r1;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 10m;
    ssl_session_tickets off;

    # ... other existing configuration ...


    location /standalone-signaling/ {
        proxy_pass http://signalingserver:8088/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /standalone-signaling/spreed {
        proxy_pass http://signalingserver:8088/spreed;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Restart the reverse proxy
```sh
docker restart reverseproxy
```

## Configure /etc/hosts

Add the following entry to your `/etc/hosts` file: `172.19.0.1 signalingserver.YOURDOMAIN`.


## Test your signaling server is working properly

curl -i https://signaling-server.local.mlh.ovh/standalone-signaling/api/v1/welcome

## Connect your Nextcloud instance to the signaling server

Go to your Nextcloud instance `Avatar > Administration settings > Talk`.
Set the parameters as follow:
- high-performance backend URL: `https://signalingserver.YOURDOMAIN/standalone-signaling/`
- tick the `Validate SSL certificate` checkbox
- in the `Shared secret` set `the-shared-secret-for-allowall` (or the value you set in the signaling server configuration file in the `backend.secret`)

You should be all set for to have your first call !
