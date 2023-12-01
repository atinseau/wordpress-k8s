eval $(minikube docker-env)


# docker build -t wordpress wordpress/docker
# docker build -t varnish varnish/docker

# MYSQL DEPLOYMENT
MYSQL_RELEASE_NAME=mysql-release
MYSQL_RELEASE_DIFF=$(helm diff upgrade $MYSQL_RELEASE_NAME mysql/  -f values.yaml | wc -l)

if [[ "$MYSQL_RELEASE_DIFF" > 0 ]]; then
  echo "mysql-release has changed. Updating..."
  helm upgrade --install $MYSQL_RELEASE_NAME mysql/ -f values.yaml
else
  echo "mysql-release has not changed. Skipping..."
fi

# REDIS DEPLOYMENT
REDIS_RELEASE_NAME=redis-release
REDIS_RELEASE_DIFF=$(helm diff upgrade $REDIS_RELEASE_NAME redis/  -f values.yaml | wc -l)

if [[ "$REDIS_RELEASE_DIFF" > 0 ]]; then
  echo "redis-release has changed. Updating..."
  helm upgrade --install $REDIS_RELEASE_NAME redis/ -f values.yaml
else
  echo "redis-release has not changed. Skipping..."
fi

# WORDPRESS DEPLOYMENT
WORDPRESS_RELEASE_NAME=wordpress-release
WORDPRESS_RELEASE_DIFF=$(helm diff upgrade $WORDPRESS_RELEASE_NAME wordpress/  -f values.yaml | wc -l)

if [[ "$WORDPRESS_RELEASE_DIFF" > 0 ]]; then
  echo "wordpress-release has changed. Updating..."
  helm upgrade --install wordpress-release wordpress/ -f values.yaml
else
  echo "wordpress-release has not changed. Skipping..."
fi

VARNISH_RELEASE_NAME=varnish-release
VARNISH_RELEASE_DIFF=$(helm diff upgrade $VARNISH_RELEASE_NAME varnish/  -f values.yaml | wc -l)

if [[ "$VARNISH_RELEASE_DIFF" > 0 ]]; then
  echo "varnish-release has changed. Updating..."
  helm upgrade --install $VARNISH_RELEASE_NAME varnish/ -f values.yaml
else
  echo "varnish-release has not changed. Skipping..."
fi