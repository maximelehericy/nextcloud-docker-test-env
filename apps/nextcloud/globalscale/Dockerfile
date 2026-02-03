FROM nextcloud:31.0.11
COPY custom_apps/globalsiteselector-2.6.0 /var/www/html/custom_apps/globalsiteselector
COPY apps/user_oidc /var/www/html/apps/user_oidc
RUN chown -R www-data:www-data /var/www/html
RUN chown -R www-data:root /var/www
RUN chmod -R g=u /var/www
RUN apt-get update && apt-get install -y nano patch jq wget
