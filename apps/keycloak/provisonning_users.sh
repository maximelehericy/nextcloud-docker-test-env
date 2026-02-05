# fetch admin secret from file
export MY_ADMIN_PASSWORD=$(cat apps/keycloak/adminpassword.key)
# get a keycloak bearer token
export BEARER_TOKEN=$(curl -X POST \
  https://keycloak.local.mlh.ovh/realms/master/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=admin-cli&username=admin&password=$MY_ADMIN_PASSWORD" | jq -r '.access_token')

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
