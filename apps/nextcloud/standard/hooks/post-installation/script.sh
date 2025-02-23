
# disable apps
php occ app:disable firstrunwizard
php occ app:disable password_policy
php occ app:disable photos
php occ app:disable survey_client

# enable apps
php occ app:enable notify_push
php occ app:enable user_oidc

# change skeletion
mkdir -p /var/www/html/data/skeleton/Documents
php occ config:system:set skeletondirectory --value="data/skeleton"

# performance
php occ config:system:set dbpersistent --value="true"

# logging
php occ config:system:set logtimezone --value='Europe/Berlin'

# configure email
# see nextcloud.env file

# others
php occ config:system:set default_phone_region --value="FR"
php occ config:system:set activity_use_cached_mountpoints --value="true"
php occ config:system:set sort_groups_by_name --value='true'
php occ config:system:set allow_user_to_change_display_name --value='false'

# domains, proxies, etc.
# see nextcloud.env file

# allow federation with local instances
php occ config:system:set allow_local_remote_servers --value='true'

# post-install
php occ maintenance:repair --include-expensive
php occ db:add-missing-indices


