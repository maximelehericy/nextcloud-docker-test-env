# Configure the reverse proxy

There will be many different services in docker containers inside docker. As explained earlier, we need a reverse proxy that will listen on the domain names defined in the `/etc/hosts` file and will proxy the requests to the containers.

For our reverse proxy service, we will use a slightly modified `nginx` docker image.

The `reverseproxy` folder contains various subfolders and files:
- `conf` contains the configuration files for every services that should be accessible from the host: Nextcloud, Collabora, Keycloak, etc.
- `includes` contains some common configuration for all the services, such as SSL configuration, we'll come back later on that.
- `Dockerfile` is the file used to build the container
- `build.sh` is the short script to call when it is needed to (re)build the docker image `reverseproxy` out of the standard `nginx` one.

# Tune the reverseproxy commands and files

## Docker run command

```sh
docker run \
    --network apps --ip 172.19.0.1 \
    --network push \
    --restart unless-stopped \
    --volume /etc/letsencrypt/:/etc/letsencrypt/:ro \
    --volume ${PWD}/apps/reverseproxy/conf:/etc/nginx/conf.d:ro \
    -e SSL_CERTIFICATE_LOCATION=/etc/letsencrypt/live/local.mlh.ovh \
    --name reverseproxy -d reverseproxy
```

If you used the Let's Encrypt DNS challenge method to obtain your certificates, you can probably use this command as is. However, if you used the mkcert option to get your SSL certificates, you will have to adapt the `--volume /etc/letsencrypt/:/etc/letsencrypt/:ro` accordingly.

## Specify the location of your SSL certificate

In the `includes/ssl.conf.example` replace the value of the `ssl_certificate_key` and `ssl_certificate` parameters, so it matches the correct location of the certificates in the container.

If you used the Let's Encrypt DNS challenge, you probably just have to replace `<yourdomain>` by the domain you chose. If you used the mkcert options, you probably have to change the location to match what has been specified in the volume mount above.

## Change the `conf/nextcloud.conf` file

In the `conf/nextcloud.conf` file, adapt:
- the server directives in both virtual hosts (80 and 443)
- in the server block listening on port 443, adapt the `if` directives to match your setup.

## Build the `reverseproxy` docker image

Make sure your terminal is located at the root of the folder `nextcloud-docker-test-env`.

Run `bash apps/reverseproxy/build.sh`.

# Start the `reverseproxy` docker container

Run the command explained above.

## After any change in the `conf` folder

`docker restart reverseproxy`

## After any change in the `includes` folder

```sh
docker stop reverse proxy && docker rm reverseproxy
bash apps/reverseproxy/build.sh
```
And run the `docker run` command again.

## Make sur eeverything goes fine

`docker logs reverseproxy` should tell you after a restart if everything goes well. Usually, this command return:

```log
2025/02/23 18:17:46 [notice] 1#1: start worker processes
2025/02/23 18:17:46 [notice] 1#1: start worker process 20
2025/02/23 18:17:46 [notice] 1#1: start worker process 21
2025/02/23 18:17:46 [notice] 1#1: start worker process 22
2025/02/23 18:17:46 [notice] 1#1: start worker process 23
2025/02/23 18:17:46 [notice] 1#1: start worker process 24
2025/02/23 18:17:46 [notice] 1#1: start worker process 25
2025/02/23 18:17:46 [notice] 1#1: start worker process 26
2025/02/23 18:17:46 [notice] 1#1: start worker process 27
```
