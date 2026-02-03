# Network setup

There are four main networks in our setup:
- the `local` network contains all the services from a docker compose file (`nextcloud`, `db`, `cache`, `cron`, `push`). Outside of compose, this network appears as `<composeProjectName>_local`
- the `databases` network contains all the databases (mostly Nextcloud `db` database), plus `adminer`, our web-based database client
- the `push` network contains all the Nextcloud notify_push `push` services, plus the reverse proxy [1]
- the `apps` network contains all the other services that need to be accessible from the host, plus the reverse proxy


[1] Inside compose, the service `push` references the Nextcloud server as `http://nextcloud`. `push` also needs to be reachable by the reverse proxy to be able to send notifications, so theoretically, we could tie `push` to the `apps` network. But if we launch several docker compose projects, there will be several `nextcloud` services. That is not a problem, except for the `push` services, that will randomly pick a `nextcloud` service. Might be the right one, might be the wrong one. To fix this, it is mandatory that a `push` service accesses one unique `nextcloud` service. Therefore, `push` cannot be on the `apps` network anymore. So we create the `push` network, that the reverse proxy can also access.

## Network architecture

![Network architecture](./network%20architecture.webp "Network architecture")

## create the `apps` network

- We set the name to `apps`.
- The `-d bridge` means that this network is accessible from the host system.
- The `--subnet 172.19.0.0/16` defines the boundaries of the network `apps` (from `172.19.0.1` to `172.19.255.254`)
- As we need some fixed IPs ([see network diagram](./network%20architecture.webp)), we also limit the automatic IP assignment range to `172.19.1.0/24` (from `172.19.1.1` to `172.19.1.254`) which should be way enough for our testing purposes.

```sh
docker network create apps -d bridge --subnet 172.19.0.0/16 --ip-range 172.19.1.0/24
```
**If you already have existing docker networks, there might be conflict if the subnet is already attributed**
If you change the `subnet` parameter, pay attention to report that modification in the `/etc/host` file during the next steps.

## create the `push` network

```sh
docker network create push -d bridge
```

## create the `databases` network
```sh
docker network create databases -d bridge
```
