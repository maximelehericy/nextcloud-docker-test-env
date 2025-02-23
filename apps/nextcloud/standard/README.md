# Launch a Nextcloud instance

For this, we will use `docker compose`. `docker compose` is a tool that allows to launch at once several containers, unlike the docker run command we used previously for the reverse proxy.

Docker compose does an interesting thing when launching a set of services: it prefixes all the services with a project label, so it is easy to know which containers are siblings. If not specified, a random name is applied, but we will prpfit from that feature to name our different test instances: nc1, nc2, nc3, test, tutorial, sse, etc. For this tutorial, we will use the `test` project name.


## Yaml files
Each sercice that should be launched is decribed in a yaml file, where one can specify the networks, volumes, docker images that services base on, environment variables, etc.

In our case, for a standard nextcloud, we have three yaml files:
- mariadb.yml
- redis.yml
- nextcloud.yml

## Environment variables

In the [nextcloud.env](../nextcloud.env.example) file, replace `<yourdomain>` by your actual domain in the NEXTCLOUD_TRUSTED_DOMAINS environment variable. **Rename the file into `nextcloud.env`**.

All the environment variable usable to deploy Nextcloud in Docker are listed [here](https://github.com/nextcloud/docker#auto-configuration-via-environment-variables).

In our case, the default ones are located in the yaml files (`redis.yml, mariadb.yml, nextcloud.yml`), and a few ones in the `nextcloud.env` file.

## Build the notify_push docker image

This has to be done once for all:

```sh
bash apps/notify_push/build.sh
```

## Launch the first instance

If you successfully set the NEXTCLOUD_TRUSTED_DOMAINS in the `nextcloud.env` file, we can now launch a first `test` Nextcloud instance with the following command:

```sh
docker compose -p test -f apps/nextcloud/standard/mariadb.yml -f apps/nextcloud/standard/nextcloud.yml -f apps/nextcloud/standard/redis.yml up -d
```

Check that your containers are running with: `docker ps | grep test`.

Check the Nextcloud installation went well with: `docker logs test-nextcloud-1`. You might have to wait for a minute or so to let the installation finish completely. You should see something similar to:

```log
[Sun Feb 23 18:46:24.771747 2025] [core:notice] [pid 1:tid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
```

To stop this `test` Nextcloud instance, run the following:
```sh
docker compose -p test -f apps/nextcloud/standard/mariadb.yml -f apps/nextcloud/standard/nextcloud.yml -f apps/nextcloud/standard/redis.yml down
```

If you want to restart a stopped docker compose project, simply run again the first command (`docker compose [...] up -d`).

When launching a Nextcloud instance with docker compose, two volumes are created:
- `test_nextcloud`
- `test_db`

If you want to completely remove a Nextcloud instance (for a fresh restart for example), after the `docker compose [...] down` command, run:

```sh
docker volume rm test_nextcloud test_db
```

# Tweaks

There are a few tweaks here and there so that a Nextcloud instance is nearly completely ready after its launch:
- using the environments variables in the `yaml` files and in the `nextcloud.env`, plenty of parameters are already set (admin user and password, db user and password, db host, etc...)
- Nextcloud docker image can triggers scripts (see [here](https://github.com/nextcloud/docker#auto-configuration-via-hook-folders)). In our case, there is one script that apply post-installation commands, see the file [here](./hooks/post-installation/script.sh).

# Still a few commands to finish the installation

Despite all the previous auto-configuration stuff and post-installation scripts, there is a last command that must be run in order to setup a few important things that depend on the "name" of the instance. For our `test` instance, we would run the following:

```sh
for instancenanme in test
do
    echo $instancename-nextcloud-1

    # change instance name
    docker exec -u 33 $instancename-nextcloud-1 php occ config:app:set theming name --value="$instancename"
    docker exec -u 33 $instancename-nextcloud-1 php occ config:system:set overwrite.cli.url --value="https://$instancename.<yourdomain>"

    # install notify_push
    docker exec -u 33 $instancename-nextcloud-1 php occ app:enable notify_push
    docker exec -u 33 $instancename-nextcloud-1 php occ notify_push:reset
    sleep 1
    docker exec -u 33 $instancename-nextcloud-1 php occ notify_push:setup https://$instancename.<yourdomain>/push
done
```

# Launching several Nextcloud instance in parallel

Simply run the `docker compose -p projectName [...] up -d` command as many times as you want, each time with changing the `projectName`.
