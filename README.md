# docker-mediawiki

- Based on `php:5.6-fpm` Docker image.
- Must link with `mysql-server:mysql` image for data storage.
- Contains Mediawiki 1.26.2.
- Installs `mysqli` and `opcache` PHP extensions.
- Installs ImageMagick.
- Runs php-fpm on port 9000 which can be used by webserver on the host.

Published on https://hub.docker.com/r/fancycode/mediawiki/

Sample command to run docker:

    $ docker run \
        --name my-docker-mediawiki \
        --restart=always \
        --link mysql-server:mysql \
        -p 127.0.0.1:9000:9000 \
        -v /path/to/local/config:/var/www/shared \
        -d \
        fancycode/mediawiki

The shared folder must contain the `LocalSettings.php`, any `images` folder will
replace the `images` folder of Mediawiki. The `resources` folder of Mediawiki
will be copied to the shared folder on startup so it can be accessed by the
webserver on the host.
