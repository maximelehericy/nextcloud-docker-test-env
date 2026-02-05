# Roundcube

To run a Rouncube container to provide a webmail interface for the Stalwart Mail Server, use the following:

With automatic configuration via environment variables:

```sh
docker run \
    --name roundcube \
    --network apps \
    -e ROUNDCUBEMAIL_DEFAULT_HOST=ssl://YOURMAILSERVERURL \
    -e ROUNDCUBEMAIL_DEFAULT_PORT=993 \
    --restart unless-stopped \
    -e ROUNDCUBEMAIL_SMTP_SERVER=ssl://YOURMAILSERVERURL \
    -e ROUNDCUBEMAIL_SMTP_PORT=465 \
    -d roundcube/roundcubemail
```

With configuration file (volume added). See the example config file [here](config.docker.inc.example.php), where the mail domain has been added as parameter.

```sh
docker run \
    --name roundcube \
    --network apps \
    -e ROUNDCUBEMAIL_DEFAULT_HOST=ssl://YOURMAILSERVERURL \
    -e ROUNDCUBEMAIL_DEFAULT_PORT=993 \
    --restart unless-stopped \
    -e ROUNDCUBEMAIL_SMTP_SERVER=ssl://YOURMAILSERVERURL \
    -e ROUNDCUBEMAIL_SMTP_PORT=465 \
    -v "${PWD}/apps/roundcube/config.docker.inc.php:/var/roundcube/config/config.docker.inc.php" \
    -d roundcube/roundcubemail
```