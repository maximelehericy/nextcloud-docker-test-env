FROM nextcloud:31.0.5
COPY custom_apps/globalsiteselector /var/www/html/custom_apps/globalsiteselector
RUN chown -R www-data:www-data /var/www/html
RUN chown -R www-data:root /var/www
RUN chmod -R g=u /var/www
RUN apt-get update && apt-get install -y nano patch jq wget
