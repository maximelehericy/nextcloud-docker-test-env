# Nextcloud Dev version

Sometimes it is useful to deploy Nextcloud versions in development to test certain upcoming features.

Julius developed a very convient way of doing this, see the official documentation here: https://juliusknorr.github.io/nextcloud-docker-dev/

Hereafter is a very short excerpt of Julius work:

```sh
# default "vanilla" dev container
docker run -d -p 8080:80 ghcr.io/juliusknorr/nextcloud-dev-php84:latest
```

```sh
# standalone dev container with code from a specific branch and accessible through https on a dedicated domain name.
docker run -d --network apps --name test-nextcloud-1 -p 8080:80 \
    -v ${PWD}/apps/nextcloud/globalscale/custom_apps/globalsiteselector:/var/www/html/apps-extra/globalsiteselector \
    -e SERVER_BRANCH=master   \
    -e NEXTCLOUD_TRUSTED_DOMAINS=test.local.mlh.ovh \
    -e TRUSTED_PROXIES=172.19.0.1 \
    -e OVERWRITEPROTOCOL=https \
    --restart unless-stopped ghcr.io/juliusknorr/nextcloud-dev-php84:latest

# apply correct permissions on mapped apps
docker exec test-nextcloud-1 chown -R www-data:www-data /var/www/html/apps-extra
```
