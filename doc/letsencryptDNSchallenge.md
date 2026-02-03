# Get SSL certificates for local use with Let's Encrypt DNS challenge

Aside the usual Letsencrypt HTTP challenge that everyone knows about, there is another one called the DNS challenge. It allows to generate wildcard (*) certificates valid for all subdomains, and it allows also to get certificate on a machine that cannot be reached from the internet.

You can read more about it [there](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge).

There are a few providers that provide APIs to support this method to obtain certificates, see [here](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438).

I had a domain name at OVH, so the instructions below apply for a domain name purchased at OVH, but you can choose the provider of your choice.

## Prerequisites

### Buy a domain name at OVH

Before going any further, you will need to purchase a domain name from \[OVH\](<https://www.ovhcloud.com/en/domains/>). Domain names ending with ".ovh" are pretty cheap (2€/year).

### Install python

On debian based distros:

```sh
apt install pip
```

On RedHat based distros:

```sh
dnf install pip
```

### Create a virtual environment for pip to run certbot

```sh
python3 -m venv certbot
source certbot/bin/activate
```

### Install certbot

```sh
pip install certbot
pip install certbot-dns-ovh
```
## Get certificates

### Create an OVH API token

Go there (and connect to your OVH account): <https://eu.api.ovh.com/createToken/>

Grant rights as follow:

```
GET /domain/zone/*
PUT /domain/zone/*
POST /domain/zone/*
DELETE /domain/zone/*
```

Or as follow (more fine grained permissions):

```
GET /domain/zone/
GET: /domain/zone/{domain.name}/
GET /domain/zone/{domain.ext}/status
GET /domain/zone/{domain.ext}/record
GET /domain/zone/{domain.ext}/record/*
POST /domain/zone/{domain.ext}/record
POST /domain/zone/{domain.ext}/refresh
DELETE /domain/zone/{domain.ext}/record/*
```

Save your API token credentials:

```
dns_ovh_endpoint
dns_ovh_application_key
dns_ovh_application_key
dns_ovh_application_key
```

On your host system, create a file to store those credentials:

```
sudo mkdir /root/.secrets
sudo mkdir /root/.secrets/certbot
sudo nano /root/.secrets/certbot/ovh.ini
```

Paste the following content in the file

```
# OVH API credentials used by Certbot
dns_ovh_endpoint = ovh-eu
dns_ovh_application_key = MDAwMDAwMDAwMDAw
dns_ovh_application_secret = MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAw
dns_ovh_consumer_key = MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAw
```

Protect the file by changing permission access

```sh
chmod 600 /root/.secrets/certbot/ovh.ini
```

### Request the certificate

Run the certificate request according DNS challenge against OVH API. For example, to get a certificate for *local.yourdomain.ovh* and *\*.local.yourdomain.ovh*, run:

```sh
sudo certbot certonly --dns-ovh \
--dns-ovh-credentials /root/.secrets/certbot/ovh.ini \
-d local.yourdomain.ovh -d *.local.yourdomain.ovh
```

The command should return `Successfully received certificate.` and tell you its location (cert and privkey).

### Handle certificate renewal

**Manually**

Run:

```sh
sudo certbot renew
```

**Automatically**

Add certificate renewal in your crontab

```sh
sudo crontab -e
```

```sh
sudo certbot renew
```

## Reference articles

Reference articles (FR) - with OVH as domain name provider
- https://supersonique-studio.com/2020/06/creation-de-certificats-lets-encrypt-a-travers-les-dns-ovh-dns-01-challenge/
- https://buzut.net/certbot-challenge-dns-ovh-wildcard/
