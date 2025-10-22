```sh
docker run \
    --name roundcube \
    --network apps \
    -e ROUNDCUBEMAIL_DEFAULT_HOST=mail.local.mlh.ovh \
    --restart unless-stopped \
    -e ROUNDCUBEMAIL_SMTP_SERVER=mail.local.mlh.ovh -d roundcube/roundcubemail
```
