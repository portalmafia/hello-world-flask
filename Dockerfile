FROM debian:stretch-slim

ENV PYAPP_DEPS \
                python3-pip \
                apache2 \
                libapache2-mod-wsgi 

RUN apt-get update && apt-get install -y \
                   $PYAPP_DEPS \
           && rm -r /var/lib/apt/lists/*

RUN pip3 install virtualenv
ENV APP_NAME myfirstapp
RUN mkdir -p /var/www/$APP_NAME
ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars
RUN set -eux; \
	\
	sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS"; \
	\
# setup directories and permissions
	. "$APACHE_ENVVARS"; \
	for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
		/var/www/html \
		/var/www/$APP_NAME \
	; do \
		rm -rvf "$dir"; \
		mkdir -p "$dir"; \
		chown "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
		chmod 777 "$dir"; \
	done; \
	\
	ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"; \
	chown -R --no-dereference "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$APACHE_LOG_DIR"



WORKDIR /var/www/$APP_NAME
COPY ./hello.conf /etc/apache2/sites-available/hello.conf
COPY ./hello.py .
COPY ./hello.wsgi .
RUN a2dissite 000-default.conf
RUN a2ensite hello.conf
RUN virtualenv .env
RUN .env/bin/pip3 install flask
CMD apachectl -D FOREGROUND
EXPOSE 80
