while read -r ou;
do
    echo $ou
    cat > ${PWD}/apps/openldap/ldifs/3-$ou.ldif <<EOL
dn: cn=$ou,ou=groups,dc=local,dc=org
cn: $ou
description: $ou
objectclass: groupOfNames
EOL
done < ${PWD}/apps/openldap/resources/organizational-units.txt


for ou in "MyCompany";
do
    echo $ou
    cat > ${PWD}/apps/openldap/ldifs/4-$ou.ldif <<EOL
dn: cn=$ou,ou=groups,dc=local,dc=org
cn: $ou
description: $ou
objectclass: groupOfNames
EOL
done


echo "" > 2-MyCompany-People.ldif
for i in {21001..21100};
do
    echo $i
    family_n=$((1 + $RANDOM % 13000))
    familyName=$(sed -n "${family_n}p" ${PWD}/apps/openldap/resources/family-names.txt)

    given_n=$((1 + $RANDOM % 8000))
    givenName=$(sed -n "${given_n}p" ${PWD}/apps/openldap/resources/given-names.txt)

    ou_n=$((1 + $RANDOM % 8))
    ou=$(sed -n "${ou_n}p" ${PWD}/apps/openldap/resources/organizational-units.txt)

    fullName="$givenName $familyName"
    uid=$(echo "${givenName~}.${familyName~}" | sed "s/[' ]//g" | tr '[:upper:]' '[:lower:]')
    email="$uid@mail.local.mlh.ovh"

    echo $givenName $familyName
    echo $fullName
    echo $email
    echo $uid

cat >> ${PWD}/apps/openldap/ldifs/2-MyCompany-People.ldif <<EOL

dn: uid=$uid,ou=people,dc=local,dc=org
objectClass: posixAccount
objectClass: shadowAccount
objectClass: inetOrgPerson
cn: $givenName $familyName
sn: $familyName
uid: $uid
mail: $uid@mail.local.mlh.ovh
userPassword: $uid
uidNumber: $i
gidNumber: $i
homeDirectory: /home/$uid
EOL

cat >> ${PWD}/apps/openldap/ldifs/3-$ou.ldif <<EOL
member: uid=$uid,ou=people,dc=local,dc=org
EOL

cat >> ${PWD}/apps/openldap/ldifs/4-MyCompany.ldif <<EOL
member: uid=$uid,ou=people,dc=local,dc=org
EOL

done




