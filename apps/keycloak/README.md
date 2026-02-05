# Run a keycloak instance

Keycloak is an IDentity Provider (aka IDP).

## Run keycloak into a container
Running keycloak is pretty simple:

```sh
docker run -t -d --name keycloak \
    -e KC_BOOTSTRAP_ADMIN_USERNAME=admin_tmp \
    -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin_tmp \
    -e KC_PROXY_HEADERS=xforwarded \
    -e KC_HTTP_ENABLED=true \
    -e KC_PROXY=edge \
    -e KC_HOSTNAME_STRICT=false \
    -e KEYCLOAK_ADMIN=admin \
    -e KEYCLOAK_ADMIN_PASSWORD=admin \
    -e KC_LOG_LEVEL=INFO \
    -e KC_SPI_THEME_DEFAULT:my-theme \
    --network apps \
    --restart unless-stopped \
    -v keycloak:/opt/keycloak \
    -v ${PWD}/apps/keycloak/my-theme/:/opt/keycloak/themes/my-theme \
    keycloak/keycloak:26.5 start-dev
```

To completely remove your keycloak instance and start from scratch again, you need to stop the container and delete the volume:

```sh
docker stop keycloak && docker rm keycloak
docker volume rm keycloak
```

This keycloak setup has been slightly modified so it shows a Nextcloud background on the login page. The customization is located under the [my-theme](./my-theme/) folder.

You can login to keycloak using `admin:admin` credentials.

The custom theme can be set under `Realm settings > Themes > Login theme`.

## Access your container

Same as for every other service here, to access your keycloak container, you need to:
- add an entry to your `/etc/hosts` file
- add a configuration file for keyclaok in the reverseproxy conf [folder](../reverseproxy/conf/). The following one should work:

```conf
server {
    listen 80;
    listen [::]:80;
    server_name keycloak.YOURDOMAIN;

    # Prevent nginx HTTP Server Detection
    server_tokens off;

    # Enforce HTTPS
    return 301 https://$server_name$request_uri;
}
server {
    #listen 80;
    listen 443 ssl;
    http2 on;

    server_name keycloak.YOURDOMAIN;
    # set the host under a variable allows a graceful start for nginx when the container is down.
    # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
    resolver 127.0.0.11;

    set $keycloak http://keycloak:8080;

    include /etc/nginx/includes/ssl.conf;

    location / {
        include /etc/nginx/includes/proxy.conf;
        proxy_pass $keycloak;
    }

    access_log off;
    error_log /var/log/nginx/error.log error;
}
```

## Configure Keycloak as a SAML provider for Nextcloud

There is an article on Nextcloud customer portal [here](https://portal.nextcloud.com/article/Authentication/Single-Sign-On-(SSO)/How-To-Authenticate-via-SAML-with-Keycloak-as-Identity-Provider).

## Configure Keycloak as an OIDC provider for Nextcloud

_To be explained_

## Reference articles about running keycloak with docker
- https://www.keycloak.org/getting-started/getting-started-docker
- https://skycloak.io/blog/how-to-run-keycloak-behind-a-reverse-proxy/

## Create users in bulk

See script [here](provisonning_users.sh).