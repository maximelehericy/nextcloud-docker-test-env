# LDAP, OpenLDAP

This one has been a pretty tough one to setup without prior LDAP knowledge.
After a lot of fails and retries, I reach to the following conclusion:
1. There are two containers packaging OpenLDAP:
  - osixia/docker-openldap, which is not maintained anymore
  - bitnami/openldap (I went for this one)
1. I could not find a very good GUI to manage OpenLDAP content:
  - I read about phpLDAPAdmin aka PLA, but it is still under development and lacks features like adding users
  - I tried wheelybird/ldap-user-manager, but had too many errors using it. They mainly based their integration with osixia/docker-openldap, and integration with bitnami/openldap did not work really good for me
2. Once you gets the LDAP logic, and how to initiate the OpenLDAP container with prepopulated users and group structure, it is pretty simple to get an LDAP instance running with basic features
3. SSL or TLS or encrypted communication with the LDAP has been too much pain for now, I gave up, but happy to receive some support here :)

## References, sources

- To spin up an OpenLDAP container: [bitnami/openldap README.md](https://github.com/bitnami/containers/blob/6aef6d10866d3677da0a006be5f323307030781b/bitnami/openldap/README.md)
- To enable `memberOf` module which is necessary for Nextcloud LDAP full featured integration: [Github issue](https://github.com/bitnami/containers/issues/982#issuecomment-1220354408)
- To learn about LDAP structure and tweak the [init.ldif](./ldifs/init.ldif)which populates our OpenLDAP deployment, there is the super extensive but really good doc from zytrax [here](https://www.zytrax.com/books/ldap/ch5/step2.html).

## Spin up the OpenLDAP

A few configuration files are needed:
- `openldap.env` contains the environment variables that preconfigure our OpenLDAP container. For a simple deployement, nothing particular has to be changed.
- `ldifs/init.ldif` contains the init structure of our LDAP. Feel free to modify it according to your needs, but pay attention to the syntax and order of blocks !

To start the container, run:
```sh
docker run -d --restart unless-stopped --name ldap \
  --network apps \
  --env-file ${PWD}/apps/openldap/openldap.env \
  -v ${PWD}/apps/openldap/schema/memberof.ldif:/opt/bitnami/openldap/etc/schema/memberof.ldif \
  -v openldap_data:/bitnami/openldap \
  -v ${PWD}/apps/openldap/ldifs/:/ldifs/ \
  bitnami/openldap:latest
```

The main parameters of this OpenLDAP deployment, that will be usefull for the LDAP integration with Nextcloud are:
- LDAP host `ldap://ldap` and port `1389`
- LDAP root `dc=local,dc=org`

The `init.ldif` file provides 7 users, 6 of them being part of the `nextcloud` group can be allowed to connect to Nextcloud.

Once your LDAP is setup, you can use the following command to preconfigure your Nextcloud LDAP integration:

```sh
instancename=test
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv app:enable user_ldap
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:create-empty-config
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldap_host 'ldap://ldap'
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldap_port '1389'
# docker exec -it -u 33 $instancename-nextcloud-1 php occ ldap:set-config s01 ldap_dn 'cn=ldapconector,ou=users,dc=nextcloud,dc=com'
# docker exec -it -u 33 $instancename-nextcloud-1 php occ ldap:set-config s01 ldap_agent_password 'ldapconector'
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldap_base 'dc=local,dc=org'
# filters the users of nextcloud LDAP group membership
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldapUserFilter '(&(|(objectclass=inetOrgPerson))(|(memberof=cn=nextcloud,ou=groups,dc=local,dc=org)))'
# allow the users to login using their uid and mail
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldapLoginFilter '(&(&(|(objectclass=inetOrgPerson))(|(memberof=cn=nextcloud,ou=groups,dc=local,dc=org)))(|(uid=%uid)(|(mailPrimaryAddress=%uid)(mail=%uid))(|(uid=%uid))))'
# list all the groupsOfNames from the LDAP
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldapGroupFilter '(&(|(objectclass=groupOfNames)))'
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldapGroupDisplayName 'cn'
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldapUserDisplayName 'uid'
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldapEmailAttribute 'mail'
# enable the following if you want to disable Nextcloud username mapping on LDAP uuid which is a non-sense character string. However, if you happen to disconnect and reconnect your ldap, that might mess with usernames :)
# docker exec -it -u 33 $instancename-nextcloud-1 php occ ldap:set-config s01 ldapExpertUsernameAttr 'uid'
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:test-config s01
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:set-config s01 ldapConfigurationActive '1'
docker exec -it -u 33 $instancename-nextcloud-1 php occ -vvv ldap:check-group --update nextcloud
```


## LDAP commands examples

Some example of LDAP commands to go further:

```sh
# search all groups
docker exec ldap ldapsearch -H "ldapi:///" -x -b "ou=groups,dc=local,dc=org"

# search all users
docker exec ldap ldapsearch -H "ldapi:///" -x -b "ou=people,dc=local,dc=org"

# search one user based on uid
docker exec ldap ldapsearch -H "ldapi:///" -x -b "ou=people,dc=local,dc=org" "(uid=alice)"

# search all members of the ldap group nextcloud
docker exec ldap ldapsearch -H "ldapi:///" -x -b "ou=people,dc=local,dc=org" "(memberof=cn=nextcloud,ou=groups,dc=local,dc=org)"

# add a file to ldap to add, modify or delete LDAP records
docker exec ldap ldapadd -x -D "cn=ldapadmin,dc=local,dc=org" -w ldapadmin -H "ldapi:///" -f /postldifs/init.ldif
```

