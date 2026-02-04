# in Stalwart admin settings, go to Directory > API keys
bearer=$(cat ./apps/stalwart/stalwartAPI.key)

for accountname in alice bob charlie david eve francis georgina helene iori jeanne karola laura maxence nicole oriane pauline quentin romane sandra tomaso ulia victor william xavier yaya zeno
do
    echo "Creating $accountname"
    export secret=$(mkpasswd -m sha-512 $accountname)
    displayName="$(echo "${accountname^}" | awk '{print $0 " " substr($0, 1, 1)}')"
    curl 'https://mail.local.mlh.ovh/api/principal' \
    -X POST \
    -H "Authorization: Bearer $bearer" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\":\"individual\",
        \"name\":\"$accountname\",
        \"description\":\"$displayName\",
        \"secrets\":[\"$secret\"],
        \"emails\":[\"$accountname@local.mlh.ovh\"],
        \"roles\":[\"user\"]
        }"
done

for accountname in  guest1 guest2 guest3 user1 user2 user3 user4 user5 user6 nextcloud
do
    echo "Creating $accountname"
    export secret=$(mkpasswd -m sha-512 $accountname)
    displayName=$accountname
    curl 'https://mail.local.mlh.ovh/api/principal' \
    -X POST \
    -H "Authorization: Bearer $bearer" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\":\"individual\",
        \"name\":\"$accountname\",
        \"description\":\"$displayName\",
        \"secrets\":[\"$secret\"],
        \"emails\":[\"$accountname@local.mlh.ovh\"],
        \"roles\":[\"user\"]
        }"
done
