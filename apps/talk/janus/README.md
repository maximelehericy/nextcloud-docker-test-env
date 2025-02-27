# Janus configuration for Nextcloud Talk

Janus is the WebRTC gateway used by Nextcloud Talk. The WebRTC gateway is the component handling all the audio and video streams.

Janus uses UDP protocol that cannot be proxied by our reverse proxy, so it is a case similar to Stalwart, we need to access the container directly without going through the reverse proxy. That is why we will give `janus` as fixed IP: `172.19.0.3`

Add the following line to your `/etc/hosts` file: `172.19.0.3 janus.YOURDOMAIN`

## Build Janus docker image

```sh
bash apps/talk/janus/build.sh
```

## Tweak Janus configuration file

Copy and rename the `janus-local-docker.conf.example` into `janus-local-docker.conf`, and modify the parameters as below:

- `general.interface` is set to `172.19.0.3` (our janus container will have a fixed IP)
- `general.server_name` is set to `janus.YOURDOMAIN` (replace YOURDOMAIN)
- `certificates.cert_pem` is set to `"/etc/letsencrypt/live/YOURDOMAIN/fullchain.pem"` (replace YOURDOMAIN)
- `certificates.cert_key` is set to `"/etc/letsencrypt/live/YOURDOMAIN/privkey.pem"` (replace YOURDOMAIN)
- `media.rtp_port_range` is set to `"20000-40000"`

## Launch a standalone Janus container

Once the configuration is done, you can run Janus:

```sh
docker run \
    --network apps --ip 172.19.0.3 \
    --restart unless-stopped \
    --volume /etc/letsencrypt/:/etc/letsencrypt/:ro \
    --volume ${PWD}/apps/talk/janus/janus-local-docker.conf:/usr/local/etc/janus/janus.jcfg:ro \
    --name janus -d janus janus --full-trickle
```

In the above:
- our `janus` container has a fixed IP
- letsencrypt certificates are mounted to the container so `janus` can encrypt the streams
- we mount the config file [janus-local-docker.conf](janus-local-docker.conf.example) inside the container as `janus.jcfg`


To stop and remove the container
```sh
docker stop janus && docker rm janus
```

To continue the Talk setup, install a standalone signaling server [here](../signalingserver/README.md).
