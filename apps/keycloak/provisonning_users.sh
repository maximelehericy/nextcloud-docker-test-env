# fetch admin secret from file
export MY_ADMIN_PASSWORD=$(cat apps/keycloak/adminpassword.key)
# get a keycloak bearer token
export BEARER_TOKEN=$(curl -X POST \
  https://keycloak.local.mlh.ovh/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=admin-cli&username=admin&password=$MY_ADMIN_PASSWORD" | jq -r '.access_token')

# create groups

for groupname in "Group_A" "Group_B" "Group_C" "Group_D" "Group_E" Internal External
do
    echo "Creating $groupname"
    curl -X POST \
    https://keycloak.local.mlh.ovh/admin/realms/master/groups \
    -H "Authorization: Bearer $BEARER_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"$groupname\"
    }"

done

# create accounts
for accountname in alice bob charlie david eve francis georgina helene iori jeanne karola laura maxence nicole oriane pauline quentin romane sandra tomaso ulia victor william xavier yaya zeno
do
    echo "Creating $accountname"
    #export secret=$(mkpasswd -m sha-512 $accountname)
    displayName="$(echo "${accountname^}")"    
    
    curl -X POST \
    https://keycloak.local.mlh.ovh/admin/realms/master/users \
    -H "Authorization: Bearer $BEARER_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"$accountname\",
        \"email\": \"$accountname@local.mlh.ovh\",
        \"firstName\": \"$displayName\",
        \"lastName\": \"${displayName:0:1}\",
        \"enabled\": true,
        \"emailVerified\": false,
        \"credentials\": [
            {
                \"type\": \"password\",
                \"value\": \"$accountname\",
                \"temporary\": false
            }
        ]
    }"

done






while IFS=',' read -r accountname group1 group2; do
    echo "$username"
    echo "$group1"
    echo "$group2"
    # Perform any operations on $line here

export BEARER_TOKEN=$(curl -X POST \
  https://keycloak.local.mlh.ovh/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=admin-cli&username=admin&password=$MY_ADMIN_PASSWORD" | jq -r '.access_token')

userID=$(curl -X GET https://keycloak.local.mlh.ovh/admin/realms/master/users?username={$accountname} \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer $BEARER_TOKEN" | jq -r '.[]' | jq -r .id)

echo $accountname $userID

group1ID=$(curl -X GET https://keycloak.local.mlh.ovh/admin/realms/master/groups?search={$group1} \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer $BEARER_TOKEN" | jq -r '.[]' | jq -r .id)

echo $group1 $group1ID

group2ID=$(curl -X GET https://keycloak.local.mlh.ovh/admin/realms/master/groups?search={$group2} \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer $BEARER_TOKEN" | jq -r '.[]' | jq -r .id)

echo $group2 $group2ID

curl -X PUT https://keycloak.local.mlh.ovh/admin/realms/master/users/$userID/groups/$group1ID \
    -H "Content-Type: application/json" \
    -d "{}" \
    -H "Authorization: Bearer $BEARER_TOKEN"

curl -X PUT https://keycloak.local.mlh.ovh/admin/realms/master/users/$userID/groups/$group2ID \
    -H "Content-Type: application/json" \
    -d "{}" \
    -H "Authorization: Bearer $BEARER_TOKEN"

done < ${PWD}/apps/keycloak/usermapping.txt

