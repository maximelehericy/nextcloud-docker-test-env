# Deploy an email server (imap and smtp)

At the difference of the other services, deploying Stalwart Mail server requires you to hold a domain name. Indeed, some DNS records have to be added to it so mails are properly delivered.

Once setup, this mail server should allow you to test Nextcloud Mail, the email client embedded into Nextcloud Hub, and also to serve as SMTP server for your local services that need to send emails (notifications, password resets and so on).

I wrote this README a while after setting Stalwart-mail up, feel free to ping me if you feel like some step is missing !


## Deployment

As you can see below, deploying `stalwart-mail` differs a little bit from the rest of the services in this project: there is a fixed IP assigned to the mail server. This is because Stalwart-Mail uses protocols others than https (smtp, imap, etc.), which our nginx reverse proxy as is can't help with. We could have choosen to setup another reverse proxy that would have acted on a lower layer of the network, independently from the protocols, but I found that there were a quicker and simpler way.

A brief digression about docker networking here, feel free to continue if you don't care: docker networks ranges from `172.16.0.0/16` to `172.31.0.0/16` (this is a standard for local/internal networks). You can check that using `docker network inspect apps` for example, and you will see that the apps subnet is `172.19.0.0/16`, and all services* have IPs in the range `172.19.1.0/24` (`172.19.1.1` to `172.19.1.254` for those not (yet) familiar with IP masks). We could think that these IPs are only accessible from inside docker, but actually no. From your host system, if you type `http://172.19.0.1/` in your browser, you'll end up on `Proxy Backend Not Found`, which is exactly the content of our [page-not-found.html](../reverseproxy/page-not-found.html). That means we can actually ping with its IP address any service running inside docker.

_*Actually all services but thoses with a fixed IP_

Now, let's back to our Stalwart Mail server. If we can access it from our host, why should we put a reverse proxy in front of it ? Let's just give it a fixed IP `172.19.0.2`, and add to our `/etc/hosts` file that `172.19.0.2` is actually `mail.YOURDOMAIN`. That way, `mail.YOURDOMAIN` will point directly to your Stalwart mail server, without any intermediary. That means that you can also reach `25/tcp, 110/tcp, 143/tcp, 443/tcp, 465/tcp, 587/tcp, 993/tcp, 995/tcp, 4190/tcp, 8080/tcp` also directly, which is rather convenient.

So let's run it:

```sh
docker run -d -t \
    --network apps --ip 172.19.0.2 \
    --restart unless-stopped \
    --volume stalwart:/opt/stalwart-mail \
    --volume /etc/letsencrypt/:/etc/letsencrypt/:ro \
    --name stalwart-mail stalwartlabs/mail-server:latest
```

In case you need to stop it and remove it:
```sh
docker stop stalwart-mail && docker rm stalwart-mail
```

In case you want to start from scratch again, you will need to remove the volume bind to the container that stores its data persistently:
```sh
docker volume rm stalwart
```

## Configuration

Execute `docker logs stalwart-mail` to get the admin password.

Navigate to http://mail.YOURDOMAIN:8080/login and... login.

_In case your admin account has lost his admn permissions and you have no other way to recover it, there is this [interesting article](https://wayneoutthere.com/2024/10/12/how-to-reset-your-stalwart-mail-admin-password/) ;)_

Then, perform the following:
- In `Directory > Settings > Network` set your hostname `mail.YOURDOMAIN` and save.
- In `Directory > Settings > TLS > Certificates` click create certificate, and paste (replace `YOURDOMAIN`):
  - set a title
  - in Certificate, paste: `%{file:/etc/letsencrypt/live/YOURDOMAIN/fullchain.pem}%` (see letsencrypt volume binding in the `docker run` command above)
  - in Private key, paste: `%{file:/etc/letsencrypt/live/YOURDOMAIN/privkey.pem}%` (see letsencrypt volume binding in the `docker run` command above)
  - and save.
- In `Directory > Domains` (click `Management` to return to setting home page :shrug:), click `Create domain`, and enter `mail.YOURDOMAIN` or just `YOURDOMAIN`.
- Save, and `click the three dots > View DNS records > scroll down` and copy the content from the text field.
- Go to your domain name provider and paste those DNS entries into your DNS settings.
- You should be nearly all set.
- Go to `Directory > Accounts`, and create a bunch of accounts to use as you wish !

## Test !

Once this is done, you can log in to a Nextcloud instance and try to connect an email client :)
