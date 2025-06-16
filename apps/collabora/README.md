# About the collabora container

To run the collabora container, rename the [coolwsd.xml.example](coolwsd.xml.example) into `coolwsd.xml`

A few things have been tuned already:

In the **net** block:
- `net.post_allow.host` as an added `collabora` entry
- `net.post_allow.host` as an added `office.YOURDOMAIN` entry that need to be changed according to your domain name
- `net.post_allow.host` as an added `*.YOURDOMAIN*` entry that need to be changed according to your domain name

- `net.lok_allow.host` as an added `collabora` entry
- `net.lok_allow.host` as an added `office.YOURDOMAIN` entry that need to be changed according to your domain name
- `net.lok_allow.host` as an added `*.YOURDOMAIN*` entry that need to be changed according to your domain name

- `net.content_security_policy` is set to `frame-ancestors *.YOURDOMAIN:*;` where .YOURDOMAIN need to be changed. This is to allow federated editing across different Nextcloud instances (see doc [here](https://github.com/nextcloud/richdocuments/blob/main/docs/federated-editing.md#allow-remote-access-on-collabora)).

In the **ssl** block:
- `ssl.enable` is set to `false`
- `ssl.termination` is set to `true`

We can ignore `cert_file_path, key_file_path, ca_file_path` as our collabora container will run behind the reverse proxy which does the SSL termination.

In the **user_interface** block:
- `user_interface.mode` is set to `tabbed`, that is a personal taste, feel free to set it otherwise :)

In the **storage** block:
- `storage.wopi.alias_groups` add the following block:

```xml
            <group>
                    <host desc="hostname to allow or deny." allow="true">https://test.YOURDOMAIN</host>
                    <alias desc="regex pattern of aliasname">https://.*.YOURDOMAIN</alias>
                    <alias desc="regex pattern of aliasname">scheme://aliasname2:port</alias>
            </group>
```

## Create a collabora conf file for the reverse proxy

```sh
nano apps/reverseproxy/conf/collabora.conf
```

Paste the following content, and modify the `.YOURDOMAIN` accordingly.

```conf
server {

 listen       443 ssl;
 server_name  office.YOURDOMAIN;

 include /etc/nginx/includes/ssl.conf;

 # set the host under a variable allows a graceful start for nginx when the container is down.
 # If declared directly after the proxy_pass directive, when the container is down, nginx throws an error and refuses to start.
 resolver 127.0.0.11;
 set $upstream http://collabora:9980;

 # static files

  client_max_body_size 512M;
  client_body_timeout 300s;
  fastcgi_buffers 64 4K;

 location ^~ /browser {
   proxy_pass $upstream;
   proxy_set_header Host $host;
 }

 # WOPI discovery URL

 location ^~ /hosting/discovery {
   proxy_pass $upstream;
   proxy_set_header Host $host;
 }

 # Capabilities

 location ^~ /hosting/capabilities {
   proxy_pass $upstream;
   proxy_set_header Host $host;
 }

 # main websocket

 location ~ ^/cool/(.*)/ws$ {
   proxy_pass $upstream;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "Upgrade";
   proxy_set_header Host $host;
   proxy_read_timeout 36000s;
 }

 # download, presentation and image upload

 location ~ ^/(c|l)ool {
   proxy_pass $upstream;
   proxy_set_header Host $host;
 }

 # Admin Console websocket

 location ^~ /cool/adminws {
   proxy_pass $upstream;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "Upgrade";
   proxy_set_header Host $host;
   proxy_read_timeout 36000s;
 }
}
```

This is the default configuration retrieved from Collabora Online documentation [here](https://sdk.collaboraonline.com/docs/installation/Proxy_settings.html#reverse-proxy-settings-in-nginx-config-ssl-termination).

## Add an entry to your `/etc/hosts` file

```sh
sudo nano /etc/hosts
```

Add the following (or append an existing line):

```
172.19.0.1 office.YOURDOMAIN
```

## Run the community container

```sh
# with the community version (CODE)
docker run -t -d --network apps --name collabora -v ${PWD}/apps/collabora/coolwsd.xml:/etc/coolwsd/coolwsd.xml --restart unless-stopped collabora/code
```

## Run the enterprise container

Download or copy in `apps/collabora` the content of this Github directory: https://github.com/CollaboraOnline/online/tree/master/docker/from-packages

```sh
# with a licence key / enterprise version
echo PLACE_YOUR_SECRET_HERE > secret_key
bash apps/collabora/build.sh
docker run -t -d --network apps --name collabora -v ${PWD}/apps/collabora/coolwsd.xml:/etc/coolwsd/coolwsd.xml --restart unless-stopped collabora
```

- The container belongs to the `apps` network, so the reverse proxy can access it.
- We mount the configuration file into the container

## Restart the container
```sh
docker container restart collabora
```
## Stop the container
```sh
docker stop collabora && docker rm collabora
```

## Enable collabora on a (or several) Nextcloud instance

Replace `.YOURDOMAIN` accordingly and execute the following. You can add other instance names after `test` to enable at once on several instances.
```sh
for instancename in test
do
    echo $instancename-nextcloud-1
    docker exec -u 33 $instancename-nextcloud-1 php occ app:install richdocuments
    docker exec -u 33 $instancename-nextcloud-1 php occ config:app:set richdocuments wopi_url --value='https://office.YOURDOMAIN'
    docker exec -u 33 $instancename-nextcloud-1 php occ richdocuments:activate-config
done
```

This is also a code block that can be added to the [Nextcloud post-installation script](../nextcloud/standard/hooks/post-installation/script.sh), if you want to enable Nextcloud Office by default for every Nextcloud instance.
