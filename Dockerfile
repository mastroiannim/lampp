FROM alpine

EXPOSE 80

ENV HOSTNAME localhost
RUN echo $(hostname)  > /etc/hostname
RUN apk add --no-cache --upgrade bash
#The rc-update tool is a part of the openrc package which is not included in the base image.
RUN apk add openrc
RUN apk add apache2
RUN apk add mariadb mariadb-client

RUN apk update
RUN apk add php83 php83-mysqli phpmyadmin php83-apache2 php83-session php83-iconv

RUN openrc
RUN touch /run/openrc/softlevel

COPY /htdocs/. /var/www/localhost/htdocs/.

COPY apache2 /etc/init.d/apache2
RUN chmod 775 /etc/init.d/apache2
COPY config.inc.php /etc/phpmyadmin/config.inc.php
RUN chmod 755 /etc/phpmyadmin/config.inc.php
COPY mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN chmod 755 /etc/my.cnf.d/mariadb-server.cnf

RUN chmod -R 777 /usr/share/phpmyadmin
RUN ln -s /usr/share/webapps/phpmyadmin /var/www/localhost/htdocs/phpmyadmin

RUN service mariadb setup

CMD service apache2 start; service mariadb start; bash
