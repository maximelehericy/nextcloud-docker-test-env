# Spreed Signaling Server configuration for Nextcloud Talk

The installation of the Talk Recording backend relies on the sources from the official repository accessible [here](https://github.com/nextcloud/nextcloud-talk-recording).

The steps in a nutshell:
1. download the sources from Github
2. build the docker image
3. check the configuration file
4. start the container
5. add a conf file for the reverse proxy
6. add en entry in the `/etc/hosts` file
7. configure the Nextcloud Talk app
8. Record !

## Download sources from github

To make it work in our environment, downlaod the latest release (currently v0.1) into the `apps/talkrecording` directory, either manually, or using the commands below:
```sh
wget -P /tmp https://github.com/nextcloud/nextcloud-talk-recording/archive/refs/tags/v0.1.tar.gz
tar -xf /tmp/v0.1.tar.gz -C ${PWD}/apps/talkrecording/
```

## Build the docker image

Once the files have been downloaded, you can run the following `build.sh` script, which differs a little bit from the other scripts.

The shipped [Dockerfile](https://github.com/nextcloud/nextcloud-talk-recording/blob/d6f5a9e72bcb87ef674f2ec710d9ea29eff505b7/docker-compose/Dockerfile#L48) does not expose any port, meaning that the container is not accessible from other containers. For that reason, with the `build.sh` script:
- the first step is the build of a docker image using the standard Dockerfile from the official repository `nextcloud-talk-recording`
- the second step is the build of a custom docker image for our tests, build upon the step above

```sh
bash apps/talkrecording/build.sh
```

## Configuration file

Into the `server.conf`, the modified parameters are the following ones (**no changes needed**):

Modify the parameters as follow:
- `http.listen` is set to `0.0.0.0:8000`
- `app.trustedproxies` is set to `172.16.0.0/12`
- `backend.allowall` is set to `true`
- `backend.secret` is set to `the-shared-secret-for-allowall`
- `signaling.internalsecret` is set to `the-shared-secret-for-internal-clients`

_It is not necessary to set parameters for specific signaling servers, as we set the `allowall` parameter to true._

## Run the `talkrecording` container

Below our `server.conf` file is mounted into the container. We can run it with:

```sh
docker run \
    --network apps \
    --restart unless-stopped \
    --volume ${PWD}/apps/talkrecording/server.conf:/etc/nextcloud-talk-recording/server.conf:ro \
    --name talkrecording -d talkrecording:v0.1.8000
```

To stop the containers:
```sh
docker stop talkrecording && docker rm talkrecording
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
    server_name talkrecording.local.mlh.ovh;

    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_protocols TLSv1.2;
    ssl_ecdh_curve secp384r1;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 10m;
    ssl_session_tickets off;

    # ... other existing configuration ...

    resolver 127.0.0.11;

    set $recording http://talkrecording:8000;

    location / {
        proxy_pass $recording/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /spreed {
        proxy_pass $recording/spreed;
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

Add the following entry to your `/etc/hosts` file: `172.19.0.1 talkrecording.YOURDOMAIN`.


## Connect the recording server to the Nextcloud Talk app

Go to your Nextcloud instance `Avatar > Administration settings > Talk`.
In the `Recording backend` section, set the parameters as follow:
- high-performance backend URL: `https://talkrecording.YOURDOMAIN`
- tick the `Validate SSL certificate` checkbox
- in the `Shared secret` set `the-shared-secret-for-internal-clients`

You should be all set to record your first call !

