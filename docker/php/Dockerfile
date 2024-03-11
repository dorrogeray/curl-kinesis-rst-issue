# Start with the build stage
FROM debian:buster as build

# Install build dependencies
RUN apt-get update && \
    apt-get install -y build-essential autoconf libtool pkg-config \
    libssl-dev libxml2-dev libonig-dev libzip-dev zlib1g-dev libsqlite3-dev wget git

# Clone and compile the custom cURL
RUN git clone --single-branch --branch ssl-shutdown-not-closed https://github.com/icing/curl.git /usr/src/curl && \
    cd /usr/src/curl && \
    ./buildconf && \
    ./configure --prefix=/usr/local --with-ssl && \
    make && \
    make install

# Download and compile PHP with the custom cURL
RUN wget https://www.php.net/distributions/php-8.2.16.tar.gz && \
    tar -xzf php-8.2.16.tar.gz && \
    cd php-8.2.16 && \
    ./configure --with-curl=/usr/local --with-openssl --enable-mbstring --with-zip && \
    make && \
    make install

# Begin the final stage
FROM debian:buster

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y libcurl4 libxml2 libzip4 libonig5 libsqlite3-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the PHP binary and configuration from the build stage
COPY --from=build /usr/local/bin/php /usr/local/bin/
COPY --from=build /usr/local/lib/php /usr/local/lib/php
COPY --from=build /usr/local/include/php /usr/local/include/php

# Copy the cURL binary and libraries from the build stage
COPY --from=build /usr/local/bin/curl /usr/local/bin/
COPY --from=build /usr/local/lib/libcurl* /usr/local/lib/

# Update the dynamic linker run-time bindings
RUN ldconfig

# Test the PHP installation and cURL version
RUN php -m && php -r 'echo "cURL version: ", curl_version()["version"], "\n";'

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ARG UID=1000
ARG GID=1000

# Create a new user "phpuser" with specified user id and group id
RUN groupadd -g ${GID} phpuser
RUN useradd -u ${UID} -g phpuser -m -s /bin/bash phpuser

# Switch to the new user for subsequent commands and container runtime
USER phpuser
