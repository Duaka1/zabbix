#!/bin/bash

# Dừng thực thi script nếu có lệnh không thực thi được
set -e

sudo timedatectl set-timezone Asia/Ho_Chi_Minh

sudo apt-get install open-vm-tools whiptail snmp-mibs-downloader vim traceroute iputils-ping -y


wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu$(lsb_release -rs)_all.deb
sudo dpkg -i zabbix-release_7.0-1+ubuntu$(lsb_release -rs)_all.deb
sudo apt update
sudo apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent


curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup 
sudo bash mariadb_repo_setup --mariadb-server-version=10.11

sudo apt update && apt upgrade -y
sudo apt -y install mariadb-server

sudo systemctl start mariadb
sudo systemctl enable mariadb

echo "Configuring Mariadb..."

mysql_secure_installation <<EOF
y
Beyond@2024
Beyond@2024
y
y
y
y
EOF

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql

sudo mysql -uroot -p'rootDBpass' -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
sudo mysql -uroot -p'rootDBpass' -e "create user 'zabbix'@'localhost' identified by 'zabbixDBpass';"
sudo mysql -uroot -p'rootDBpass' -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbixDBpass';"


sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p'zabbixDBpass' zabbix


sudo sed -i 's/^# DBPassword=.*/DBPassword=zabbixDBpass/' /etc/zabbix/zabbix_server.conf


sudo sed -i 's/^EnableGlobalScripts=0/EnableGlobalScripts=1/' /etc/zabbix/zabbix_server.conf



sudo systemctl restart zabbix-server zabbix-agent 
sudo systemctl enable zabbix-server zabbix-agent

sudo apt update 
sudo apt install locales 
sudo locale-gen en_US.UTF-8 
sudo update-locale LANG=en_US.UTF-8

systemctl restart apache2
systemctl enable apache2


