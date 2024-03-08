FROM php:8.2-cli

# Install dependencies for the zip extension
RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    zip \
  && rm -rf /var/lib/apt/lists/*

# Configure and install the zip extension
RUN docker-php-ext-install zip

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ARG UID=1000
ARG GID=1000

# Create a new user "phpuser" with specified user id and group id
RUN groupadd -g ${GID} phpuser
RUN useradd -u ${UID} -g phpuser -m -s /bin/bash phpuser

# Switch to the new user for subsequent commands and container runtime
USER phpuser
