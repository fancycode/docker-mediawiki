#!/bin/bash

set -e

if [ -z "$MEDIAWIKI_DB_HOST" -a -z "$MYSQL_PORT_3306_TCP_ADDR" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP_ADDR environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi

if [ -z "$MEDIAWIKI_DB_PORT" -a -z "$MYSQL_PORT_3306_TCP_PORT" ]; then
	echo >&2 'error: missing MYSQL_PORT_3306_TCP_PORT environment variable'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql ?'
	exit 1
fi

: ${MEDIAWIKI_DB_HOST:=${MYSQL_PORT_3306_TCP_ADDR}}
: ${MEDIAWIKI_DB_PORT:=${MYSQL_PORT_3306_TCP_PORT}}

: ${MEDIAWIKI_SHARED:=/var/www/shared}

if [ -d "$MEDIAWIKI_SHARED" ]; then
	# If there is no LocalSettings.php but we have one under the shared
	# directory, symlink it
	if [ -e "$MEDIAWIKI_SHARED/LocalSettings.php" -a ! -e LocalSettings.php ]; then
		ln -s "$MEDIAWIKI_SHARED/LocalSettings.php" LocalSettings.php
	fi

	# If the images directory only contains a README, then link it to
	# $MEDIAWIKI_SHARED/images, creating the shared directory if necessary
	if [ "$(ls images)" = "README" -a ! -L images ]; then
		rm -fr images
		mkdir -p "$MEDIAWIKI_SHARED/images"
		ln -s "$MEDIAWIKI_SHARED/images" images
	fi

	# Copy resources to shared folder so they can be used by nginx.
	rm -rf "$MEDIAWIKI_SHARED/resources"
	( tar cf - resources ) | ( cd "$MEDIAWIKI_SHARED" && tar xf - )
fi

export MEDIAWIKI_DB_HOST MEDIAWIKI_DB_PORT MEDIAWIKI_SHARED

echo "Using database at $MEDIAWIKI_DB_HOST:$MEDIAWIKI_DB_PORT..."
echo "Shared data located in $MEDIAWIKI_SHARED"

exec "$@"
