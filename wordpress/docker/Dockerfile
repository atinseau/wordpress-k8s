FROM debian:buster-slim

# Install dependencies
RUN apt update && apt install -y \
  lsb-release \
  apt-transport-https \
  ca-certificates \
  wget \
  curl \
  netcat \
  default-mysql-client \
  sudo \
  nginx

# Install PHP
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN apt update && apt upgrade -y
RUN apt install -y  \
  php8.2 \
  php8.2-fpm \
  php8.2-mysqli \
  php8.2-curl \
  php8.2-dom \
  php8.2-imagick \
  php8.2-mbstring \
  php8.2-zip \
  php8.2-intl \
  php8.2-gd \
  php8.2-redis


# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Fixing permissions
RUN adduser www-data sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER www-data
WORKDIR /home/www-data
ENV WORDPRESS_PATH /home/www-data/wordpress

# Install WordPress
RUN mkdir -p ${WORDPRESS_PATH}
WORKDIR ${WORDPRESS_PATH}

RUN sudo mkdir -p /var/www/.wp-cli
RUN sudo chown -R www-data:www-data /var/www/.wp-cli
RUN wp core download --locale=fr_FR

# RUN sudo chown -R www-data:www-data ${WORDPRESS_PATH}

# Moving all required files to the container
COPY run.sh /tmp/run.sh
COPY default.template /tmp/default.template

RUN sudo chown -R www-data:www-data /tmp/run.sh
RUN sudo chown -R www-data:www-data /tmp/default.template


CMD ["bash", "/tmp/run.sh"]