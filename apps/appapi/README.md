# AppAPI

**Warning:** currently, it is not possible to run several AppAPI docker socket proxy on the same docker host or as a shared component between several Nextcloud instances, because exApps names would conflict. There is a public Github issue about it [there](https://github.com/nextcloud/app_api/issues/523). So until this is fixed, you can only have one test instance connected to the docker socket proxy.

## Run the container

```sh
docker run -e NC_HAPROXY_PASSWORD="nextcloud" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name appapi -h appapi \
  --restart unless-stopped \
  --privileged \
  --network apps \
  -d ghcr.io/nextcloud/nextcloud-appapi-dsp:release
```

_NB: I removed this part as it seems not to be needed `-e EX_APPS_NET="ipv4@172.19.0.1" \`. However, when installing Flow, I notice that Flow publishes port 8000, so I wonder if their is an interest to keep or not the environment variable. So far, it works without for me._

To stop the container:
```sh
docker stop appapi && docker rm appapi
```

## Connect your Nextcloud instance

- Disaply Name: `Docker Socket Proxy`
- Deployment method: `docker-install`
- Daemon host: `appapi:2375` (`appapi` being the name of the AppAPI container stated in the `docker run` command)
- Nextcloud URL: Nextcloud URL 🙃
- Network: specify the docker network name, in our case `apps`
- HA Proxy password: in our case `nextcloud`
- Compute device: CPU, unless you have a GPU :)

Once configured, you can click the three dots and `Test deploy`. Launch the test, the docker pull image might stay stucked at 76% and a yellow warning may pop up, but wait a bit, and the test should finish all fine.

Then, you can install the Flow app. I always struggle a bit to find it in the app store, so here is the path: select the `Tools` category, and search for `Flow`. It should appear. I don't know why it does not show up in the `Flow` category, nor pops up when you search in the whole app list :/

