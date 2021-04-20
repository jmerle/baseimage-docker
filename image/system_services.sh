#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Install init process.
cp /bd_build/bin/my_init /sbin/
mkdir -p /etc/my_init.d
mkdir -p /etc/my_init.pre_shutdown.d
mkdir -p /etc/my_init.post_shutdown.d
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

## Install runit.
# We install runit from source as the apt-get version causes the bash script to hang indefinitely on ARM64
$minimal_apt_get_install wget gzip tar build-essential
mkdir -p /package
chmod 1755 /package
cd /package
wget http://smarden.org/runit/runit-2.1.2.tar.gz
gunzip runit-2.1.2.tar
tar -xpf runit-2.1.2.tar
rm runit-2.1.2.tar
cd admin/runit-2.1.2
package/compile
package/upgrade

## Install a syslog daemon and logrotate.
[ "$DISABLE_SYSLOG" -eq 0 ] && /bd_build/services/syslog-ng/syslog-ng.sh || true

## Install the SSH server.
[ "$DISABLE_SSH" -eq 0 ] && /bd_build/services/sshd/sshd.sh || true

## Install cron daemon.
[ "$DISABLE_CRON" -eq 0 ] && /bd_build/services/cron/cron.sh || true
