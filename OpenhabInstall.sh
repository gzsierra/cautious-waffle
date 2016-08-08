#!/bin/bash

# Simple script to install OpenHAB on Ubuntu

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   printf "This script must be run as root" 1>&2
   exit 1
fi

printf "\n######################\n## Java Setup \n######################\n"
# JAVA setup
apt-add-repository ppa:webupd8team/java
apt update
apt install -y oracle-java8-installer

printf "\n######################\n## MySQL Setup \n######################\n"
# MySQL setup
debconf-set-selections <<< 'mysql-server mysql-server/root_password password openhab'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password openhab'
apt-get -y install mysql-server

mysql -u root --password='openhab' -e "CREATE DATABASE OpenHAB"
mysql -u root --password='openhab' -e "CREATE USER 'openhab'@'localhost' IDENTIFIED BY 'yourpassword'"
mysql -u root --password='openhab' -e "GRANT ALL PRIVILEGES ON OpenHAB.* TO 'openhab'@'localhost'"

printf "\n######################\n## Mosquitto Setup \n######################\n"
# Mosquitto setup
apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
apt update
apt install -y mosquitto

echo 'allow_anonymous = true' >> /etc/mosquitto/mosquitto.conf
/etc/init.d/mosquitto restart

printf "\n######################\n## CoAP Setup \n######################\n"
# CoAP setup
apt install -y python3-pip
pip3 install aiocoap

git clone https://github.com/gzsierra/pycoap/ /opt/pycoap
ln -s /opt/pycoap/pyServer.py /usr/bin/coapServer
ln -s /opt/pycoap/pyGet.py /usr/bin/pyGet

## CoAP Server Setup as a Service
systemctl enable coapServer
service coapServer start

printf "\n######################\n## OpenHAB Setup \n######################\n"
# OpenHAB setup
wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' |  apt-key add -
echo "deb http://dl.bintray.com/openhab/apt-repo stable main" |  tee /etc/apt/sources.list.d/openhab.list
apt update
apt install -y openhab-runtime

apt install -y openhab-addon-binding-astro \
               openhab-addon-binding-exec \
               openhab-addon-binding-http \
               openhab-addon-binding-mqtt \
               openhab-addon-binding-mqttitude \
               openhab-addon-binding-networkhealth \
               openhab-addon-binding-wol \
               openhab-addon-binding-zwave \
               openhab-addon-persistence-mysql \
               openhab-addon-binding-hue

# Custom config file
cp file/coapServer /etc/init.d/coapServer
cp file/configurations/openhab.cfg /etc/openhab/configurations/openhab.cfg
cp file/configurations/items/demo.items /etc/openhab/configurations/items/demo.items
cp file/configurations/sitemaps/demo.sitemap /etc/openhab/configurations/sitemaps/demo.sitemap

# Starting services
systemctl enable openhab
service openhab start

systemctl enable coapServer
service coapServer start

printf "\n######################\n## Advanced CoAP \n######################\n"
# CoAP Advanced configurations
git clone https://github.com/gzsierra/musical-enigma.git /opt/musical-enigma

pip3 install psutil
pip3 install paho-mqtt

# Run advanced client
/opt/musical-enigma/pyClient.py &

# Run HUE emulator
java -jar HueEmulator-v0.7.jar &
