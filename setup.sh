eval $(minikube docker-env)

# helm uninstall mysql-release wordpress-release redis-release varnish-release

# kubectl create secret docker-registry regcred \
#   --docker-server=https://ghcr.io \
#   --docker-username=atinseau \
#   --docker-password=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 \
#   --docker-email=arthurtinseau@live.fr

function create_docker_cred() {
  local username=$(echo -n "atinseau:$1" | base64)
  echo -n "{\"auths\":{\"ghcr.io\":{\"auth\":\"${username}\"}}}\"" | base64
}

create_docker_cred "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"

echo "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" | docker login ghcr.io -u atinseau --password-stdin

exit 0
# echo -n "atinseau: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" | base64

# YXRpbnNlYXU6Z2hwX2d4dmQyamFqU1cwZDJUZDdNQW4ySzZqSmtpY2RZQTJaRERtQg==

# 
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