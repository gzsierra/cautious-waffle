#!/bin/bash

# Simple script to install OpenHAB on Ubuntu

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# JAVA setup
apt-add-repository ppa:webupd8team/java
apt update
apt install oracle-java8-installer

# MySQL setup
debconf-set-selections <<< 'mysql-server mysql-server/root_password password openhab'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password openhab'
apt-get -y install mysql-server

mysql -u root --password='openhab' -e "CREATE DATABASE OpenHAB"
mysql -u root --password='openhab' -e "CREATE USER 'openhab'@'localhost' IDENTIFIED BY 'yourpassword'"
mysql -u root --password='openhab' -e "GRANT ALL PRIVILEGES ON OpenHAB.* TO 'openhab'@'localhost'"

# Mosquitto setup
apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
apt update
apt install mosquitto

echo 'allow_anonymous = true' >> /etc/mosquitto/mosquitto.conf
/etc/init.d/mosquitto restart

# CoAP setup
# apt install git
git clone https://github.com/gzsierra/pycoap/ /opt/pycoap
ln -s /opt/pycoap/pyServer.py /usr/bin/coapServer
ln -s /opt/pycoap/pyGet.py /usr/bin/pyGet

## CoAP Server Setup as a Service
update-rc.d coapServer defaults
systemctl enable coapServer

# OpenHAB setup
wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' |  apt-key add -
echo "deb http://dl.bintray.com/openhab/apt-repo stable main" |  tee /etc/apt/sources.list.d/openhab.list
apt update
apt install openhab-runtime

apt install openhab-addon-binding-astro \
            openhab-addon-binding-exec \
            openhab-addon-binding-http \
            openhab-addon-binding-mqtt \
            openhab-addon-binding-mqttitude \
            openhab-addon-binding-networkhealth \
            openhab-addon-binding-wol \
            openhab-addon-binding-zwave \
            openhab-addon-persistence-mysql

# Custom config file
cp file/coapServer /etc/init.d/coapServer
cp file/configurations/openhab.cfg /etc/openhab/configurations/openhab.cfg
cp file/configurations/items/demo.items /etc/openhab/configurations/items/demo.items
cp file/configurations/sitemaps/demo.sitemap /etc/openhab/configurations/sitemaps/demo.sitemap

# Starting services
systemctl enable openhab
