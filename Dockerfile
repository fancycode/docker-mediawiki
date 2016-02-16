FROM php:5.6-fpm
MAINTAINER Joachim Bauch <mail@joachim-bauch.de>

# Inspired by https://github.com/synctree/docker-mediawiki/

# Break build cache
ARG build_timestamp=undefined
RUN echo "Built on ${build_timestamp}" | tee /build.time

RUN set -x; \
    apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ENV MEDIAWIKI_VERSION 1.26
ENV MEDIAWIKI_FULL_VERSION 1.26.2

RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        g++ \
        libicu52 \
        libicu-dev \
    && pecl install intl \
    && echo extension=intl.so >> /usr/local/etc/php/conf.d/ext-intl.ini \
    && apt-get purge -y --auto-remove g++ libicu-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysqli opcache

RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends imagemagick \
    && rm -rf /var/lib/apt/lists/*

# https://www.mediawiki.org/keys/keys.txt
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
    441276E9CCD15F44F6D97D18C119E1A64D70938E \
    41B2ABE817ADD3E52BDA946F72BC1C5D23107F8A \
    162432D9E81C1C618B301EECEE1F663462D84F01 \
    1D98867E82982C8FE0ABC25F9B69B3109D3BB7B0 \
    3CEF8262806D3F0B6BA1DBDD7956EE477F901A30 \
    280DB7845A1DCAC92BB5A00A946B02565DC00AA7

RUN MEDIAWIKI_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz"; \
    set -x; \
    curl -fSL "$MEDIAWIKI_DOWNLOAD_URL" -o mediawiki.tar.gz \
    && curl -fSL "${MEDIAWIKI_DOWNLOAD_URL}.sig" -o mediawiki.tar.gz.sig \
    && gpg --verify mediawiki.tar.gz.sig \
    && tar -xf mediawiki.tar.gz -C /var/www/html --strip-components=1 \
    && rm mediawiki.tar.gz \
    && rm mediawiki.tar.gz.sig

COPY scripts/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
