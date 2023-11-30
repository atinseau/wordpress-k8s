### Utils ###
function wp-cli() {
  wp --path=$WORDPRESS_PATH $@
}

#############

# Waiting for mysql

COUNT=0
until nc -z -v -w30 $WORDPRESS_DB_HOST 3306; do
  echo 'Waiting for MySQL...'
  sleep 0.5

  COUNT=$((COUNT+1))

  if [ $COUNT -gt 60 ]; then
    echo 'MySQL is not ready. Exiting...'
    exit 1
  fi
done


# Preparing nginx
sed -i "s~\$WORDPRESS_PATH~$WORDPRESS_PATH~g" /tmp/default.template
sudo mv /tmp/default.template /etc/nginx/sites-available/default

# Installing wordpress

if [ ! -f wp-config.php ]; then
  echo 'No wp-config.php found. Creating...'
  wp-cli config create \
    --dbname=$WORDPRESS_DB_NAME \
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$WORDPRESS_DB_PASSWORD \
    --dbhost=$WORDPRESS_DB_HOST
fi

if ! wp-cli db check; then
  echo "Database \"$WORDPRESS_DB_NAME\" not found. Creating..."
  wp-cli db create
fi

if ! wp-cli core is-installed; then
  echo 'WordPress is not installed. Installing...'
  wp-cli core install \
    --url="${WORDPRESS_HOST}" \
    --title="${WORDPRESS_TITLE:-"example-title"}" \
    --admin_user="${WORDPRESS_ADMIN_USER:-"admin"}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD:-"password"}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL:-"admin@example.com"}" \
    --skip-email
fi

if nc -z -v -w30 $WORDPRESS_REDIS_HOST 6379 &> /dev/null \
  && (! wp-cli plugin is-active redis-cache || ! wp-cli plugin is-installed redis-cache)
then
  echo 'Redis cache is not active. Installing and activating...'
  wp-cli plugin install redis-cache --activate

  echo 'Configuring redis cache...'
  wp-cli config set WP_REDIS_HOST $WORDPRESS_REDIS_HOST
  wp-cli config set WP_REDIS_PORT ${WORDPRESS_REDIS_PORT:-6379}
  wp-cli redis enable
fi

if [ -n "$WORDPRESS_VARNISH_HOST" ] \
  && (! wp-cli plugin is-active  varnish-http-purge || ! wp-cli plugin is-installed varnish-http-purge)
then
  echo 'Varnish HTTP Purge is not active. Installing and activating...'
  wp-cli plugin install varnish-http-purge --activate

  wp-cli config set VHP_VARNISH_IP $WORDPRESS_VARNISH_HOST
fi

wp-cli config set FS_METHOD direct

# Cleaning up basic wordpress install
wp-cli plugin delete hello
wp-cli plugin delete akismet

wp-cli theme delete twentytwentythree
wp-cli theme delete twentytwentytwo

wp rewrite structure /%postname%/

sudo service nginx start
sudo service php8.2-fpm start

tail -f /dev/null