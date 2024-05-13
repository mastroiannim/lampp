FROM alpine

EXPOSE 80


ENV HOSTNAME localhost
RUN echo $(hostname)  > /etc/hostname

RUN apk update
RUN apk add openrc --no-cache --upgrade

RUN apk add bash
RUN apk add apache2
RUN apk add mariadb mariadb-client
RUN apk add php83 php83-mysqli phpmyadmin php83-apache2 php83-session php83-iconv

COPY /htdocs/. /var/www/localhost/htdocs/.


COPY config.inc.php /etc/phpmyadmin/config.inc.php
RUN chmod 755 /etc/phpmyadmin/config.inc.php

COPY mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
RUN chmod 755 /etc/my.cnf.d/mariadb-server.cnf

RUN chmod -R 755 /usr/share/phpmyadmin
RUN ln -s /usr/share/webapps/phpmyadmin /var/www/localhost/htdocs/phpmyadmin

RUN openrc
RUN touch /run/openrc/softlevel

RUN sed -i 's/extra_commands="configdump configtest modules virtualhosts"/extra_commands="configdump configtest modules"/g' /etc/init.d/apache2

# Tell openrc its running inside a container, till now that has meant LXC
RUN   sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
# Tell openrc loopback and net are already there, since docker handles the networking
echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
# no need for loggers
sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
# can't get ttys unless you run the container in privileged mode
sed -i '/tty/d' /etc/inittab &&\
# can't set hostname since docker sets it
sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
# can't mount tmpfs since not privileged
sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
# can't do cgroups
sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh &&\
# clean apk cache
rm -rf /var/cache/apk/*

RUN service mariadb setup

CMD service apache2 start; service mariadb start; bash

