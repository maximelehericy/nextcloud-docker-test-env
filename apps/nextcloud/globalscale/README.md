# Test Nextcloud global scale

The following steps will mainly reuse deployment steps from a standard Nextcloud, as described [here](../standard/README.md) (yml files are mostly identical, except for the image tag). **If you have not yet deployed a Nextcloud instance following the README.md [here](../standard/README.md), it is strongly advised as you will be more familiar with the concpets specific to this test environment.

For a global scale setup, we will deploy:
- a lookupserver
- a master node
- two regular nodes
- a teams node (in beta)

To deploy the lookup server, see [here](../../lookupserver/README.md).

## Configuration of Nextcloud in Global Scale mode.

Prepare custom Dockerfile importing the global site selector app.
```sh
# download the globalsite selector app from github
wget -O globalsiteselector.tar.gz https://github.com/nextcloud/globalsiteselector/archive/refs/tags/v2.6.1.tar.gz
# mkdir to prepare export
mkdir globalsiteselector
# extract code archive
tar -xzf globalsiteslector.tar.gz -C globalsiteselector --strip-components=1
# build the app
(cd globalsiteselector && make release)
# export the built app to global scale custom_apps directory
tar -xzf globalsiteselector/build/artifacts/globalsiteselector-2.6.1.tar.gz -C apps/nextcloud/globalscale/custom_apps
# remove unecessary leftovers
rm globalsiteselector.tar.gz
rm -vrf globalsiteselector
```

## build the nextcloud global scale image
```sh
bash apps/nextcloud/globalscale/build.sh
```

Note: if you change the image tag in the [build.sh](./build.sh) file, you need to update [nextcloud.yml](nextcloud.yml) accordingly.

## Prepare the docker reverseproxy (nginx)

If you already deployed Nextcloud instances using this docker test environment, then, what you probably just have to do is adding some entrie shere and there in the existing reverse proxy configuration file for Nextcloud instance [here](../../reverseproxy/conf/nextcloud.conf), especially add the following:
- master.YOURDOMAIN node1.YOURDOMAIN node2.YOURDOMAIN teams.YOURDOMAIN to the `server_name` directives (in 80 and 443)
- the following block for each of the 4 nextcloud instances of the global scale setup (master, node1, node2, teams):

```conf
    if ($host = master.yourdomain) {
        set $nextcloud http://master-nextcloud-1;
        set $push http://master-push-1:7867;
    }
```

You should also add the ad hoc entries in your `/etc/hosts` file.

## launch a set of nextcloud instances

```sh
# master will be the global scale master node
# node1 and node2 will be two example nodes in the global scale setup
# teams can be an additional node that host federated teams (still to be documented)

for pname in master node1 node2 #teams
do
    docker compose -p $pname -f apps/nextcloud/globalscale/mariadb.yml -f apps/nextcloud/globalscale/nextcloud.yml -f apps/nextcloud/globalscale/redis.yml up -d
    sleep 5
done
```

## to remove a previous gs setup

```sh
for pname in master node1 node2
do
    docker compose -p $pname -f apps/nextcloud/globalscale/mariadb.yml -f apps/nextcloud/globalscale/nextcloud.yml -f apps/nextcloud/globalscale/redis.yml down
    # comment or uncomment the two lines below if you want to restart from scratch the setup and remove the volumes
    # docker volume rm $pname\_nextcloud
    # docker volume rm $pname\_db
done
```

## Apply tweaks to all nodes
```sh
for instancename in master node1 node2 teams
do
    # change instance name
    docker exec -u 33 $instancename-nextcloud-1 php occ config:app:set theming name --value="$instancename"
    docker exec -u 33 $instancename-nextcloud-1 php occ config:system:set overwrite.cli.url --value="https://$instancename.local.mlh.ovh"
    # install notify_push
    docker exec -u 33 $instancename-nextcloud-1 php occ app:enable notify_push
    docker exec -u 33 $instancename-nextcloud-1 php occ notify_push:reset
    sleep 1
    docker exec -u 33 $instancename-nextcloud-1 php occ notify_push:setup https://$instancename.local.mlh.ovh/push
done
```

## apply GS tweaks to master only

```sh
    docker exec -u 33 master-nextcloud-1 php occ app:enable globalsiteselector
    docker exec -u 33 master-nextcloud-1 php occ config:system:set gs.enabled --value="true"
    docker exec -u 33 master-nextcloud-1 php occ config:system:set gs.federation --value="global"
    docker exec -u 33 master-nextcloud-1 php occ config:system:set gss.mode --value="master"
    docker exec -u 33 master-nextcloud-1 php occ config:system:set gss.master.admin 0 --value="admin"
    docker exec -u 33 master-nextcloud-1 php occ config:system:set gss.master.csp-allow 0 --value="*.local.mlh.ovh"
    docker exec -u 33 master-nextcloud-1 php occ config:system:set lookup_server --value="https://lookup.local.mlh.ovh"
    docker exec -u 33 master-nextcloud-1 php occ config:system:set gss.jwt.key --value="lookup"
```

## configure authentication on master
### Enable OIDC auth

```sh
docker exec -u 33 master-nextcloud-1 php occ app:disable user_saml
docker exec -u 33 master-nextcloud-1 php occ config:system:delete gss.discovery.saml.slave.mapping
docker exec -u 33 master-nextcloud-1 php occ app:enable user_oidc
docker exec -u 33 master-nextcloud-1 php occ config:system:set gss.user.discovery.module --value="\OCA\GlobalSiteSelector\UserDiscoveryModules\UserDiscoveryOIDC"
# your OIDC ID provider must send a parameter, e.g. gss_instance that provides the exact gs node url of a user
docker exec -u 33 master-nextcloud-1 php occ config:system:set gss.discovery.oidc.slave.mapping --value="gss_instance"
# set the below to 1 if you want to force the OIDC authentication
docker exec -u 33 master-nextcloud-1 php occ config:app:set --value=0 user_oidc allow_multiple_user_backends
```

### enable SAML auth
```sh
docker exec -u 33 gsmaster-nextcloud-1 php occ app:disable user_oidc
docker exec -u 33 gsmaster-nextcloud-1 php occ config:system:delete gss.discovery.oidc.slave.mapping
docker exec -u 33 gsmaster-nextcloud-1 php occ app:enable user_saml
docker exec -u 33 gsmaster-nextcloud-1 php occ config:system:set gss.user.discovery.module --value="\OCA\GlobalSiteSelector\UserDiscoveryModules\UserDiscoverySAML"
docker exec -u 33 gsmaster-nextcloud-1 php occ config:system:set gss.discovery.saml.slave.mapping --value="gss_instance"
```

## apply tweaks on secondary nodes only
```sh
for i in node1 node2 teams;
do
    docker exec -u 33 $i-nextcloud-1 php occ app:enable globalsiteselector
    docker exec -u 33 $i-nextcloud-1 php occ config:system:set gs.enabled --value="true"
    docker exec -u 33 $i-nextcloud-1 php occ config:system:set gs.federation --value="global"
    docker exec -u 33 $i-nextcloud-1 php occ config:system:set gss.mode --value="slave"
    docker exec -u 33 $i-nextcloud-1 php occ config:system:set gss.master.url --value="https://master.local.mlh.ovh"
    docker exec -u 33 $i-nextcloud-1 php occ config:system:set lookup_server --value="https://lookup.local.mlh.ovh"
    docker exec -u 33 $i-nextcloud-1 php occ config:system:set gss.jwt.key --value="lookup"
    docker exec -u 33 $i-nextcloud-1 php occ globalsiteselector:users:update

    # enables and configure richdocuments
    docker exec -u 33 $i-nextcloud-1 php occ app:install richdocuments --force
    docker exec -u 33 $i-nextcloud-1 php occ app:enable richdocuments
    docker exec -u 33 $i-nextcloud-1 php occ config:app:set richdocuments wopi_url --value='https://office.local.mlh.ovh'
    docker exec -u 33 $i-nextcloud-1 php occ config:app:set richdocuments federation_use_trusted_domains --value="yes"
    docker exec -u 33 $i-nextcloud-1 php occ richdocuments:activate-config
    docker exec -u 33 $i-nextcloud-1 php occ config:system:set gs.trustedHosts 0 --value="*.local.mlh.ovh"

    # trigger cron once
    docker exec -u 33 $i-nextcloud-1 php cron.php
    docker exec -u 33 ls-lookup-1 php replicationcron.php
done
```

## Address book syncing
In order to populate the lookup server and allow federated contact search, run the below several times.
```sh
# sync address books
for i in node1 node2 teams;
do
    docker exec -it -u 33 $i-nextcloud-1 php cron.php
    docker exec -it -u 33 $i-nextcloud-1 php occ dav:sync-system-addressbook
    docker exec -it -u 33 $i-nextcloud-1 php occ federation:sync-addressbooks
done
```

## enable debugging for globalsiteselector app

Add the following conf to the `config.php` in the container:

```php
  'log.condition' =>
  array (
    'apps' =>
    array (
      0 => 'globalsiteselector',
    ),
  ),
```
