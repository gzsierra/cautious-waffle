#!/bin/bash

# Simple script to install OpenHAB on Ubuntu

# JAVA setup
sudo apt-add-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

# MySQL setup
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password your_password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password your_password'
sudo apt-get -y install mysql-server

mysql -u root -p root_password password your_password -e "CREATE DATABASE OpenHAB"
mysql -u root -p root_password password your_password -e "CREATE USER 'openhab'@'localhost' IDENTIFIED BY 'yourpassword'"
mysql -u root -p root_password password your_password -e "GRANT ALL PRIVILEGES ON OpenHAB.* TO 'openhab'@'localhost'"

# Mosquitto setup
sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
sudo apt-get update
sudo apt-get install mosquitto

sudo echo 'allow_anonymous = true' >> /etc/mosquitto/mosquitto.conf
sudo /etc/init.d/mosquitto restart

# OpenHAB setup
wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' | sudo apt-key add -
echo "deb http://dl.bintray.com/openhab/apt-repo stable main" | sudo tee /etc/apt/sources.list.d/openhab.list
sudo apt-get update
sudo apt-get install openhab-runtime

sudo apt-get install openhab-addon-binding-astro \
                     openhab-addon-binding-exec \
                     openhab-addon-binding-http \
                     openhab-addon-binding-mqtt \
                     openhab-addon-binding-mqttitude \
                     openhab-addon-binding-networkhealth \
                     openhab-addon-binding-wol \
                     openhab-addon-binding-zwave \
                     openhab-addon-persistence-mysql

sudo cp file/configurations/openhab.cfg /etc/openhab/configurations/openhab.cfg
sudo cp file/configurations/items/demo.items /etc/openhab/configurations/items/demo.items
sudo cp file/configurations/sitemaps/demo.sitemap /etc/openhab/configurations/sitemaps/demo.sitemap

# Starting services
sudo systemctl enable openhab
