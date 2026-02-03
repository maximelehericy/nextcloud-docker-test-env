```sh
docker run \
    --name roundcube \
    --network apps \
    -e ROUNDCUBEMAIL_DEFAULT_HOST=ssl://mail.local.mlh.ovh \
    -e ROUNDCUBEMAIL_DEFAULT_PORT=993 \
    --restart unless-stopped \
    -e ROUNDCUBEMAIL_SMTP_SERVER=ssl://mail.local.mlh.ovh \
    -e ROUNDCUBEMAIL_SMTP_PORT=465 \
    -d roundcube/roundcubemail
```
