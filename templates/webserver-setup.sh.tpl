#!/bin/bash
apt update
apt install nginx -y
sed -i 's#Welcome to nginx!#Welcome to nginx-${webname}!#g' /var/www/html/index.nginx-debian.html
sed -i '22,23d' /etc/nginx/sites-available/default
sed -i "22 i\        listen 192.168.1.${web_private_IP}:80;" /etc/nginx/sites-available/default
sed -i "23 i\        allow 192.168.1.1;" /etc/nginx/sites-available/default
sed -i "24 i\        deny all;" /etc/nginx/sites-available/default
sed -i '6d' /etc/network/interfaces
sed -i "6 i\    address 192.168.1.${web_private_IP}" /etc/network/interfaces
sed -i '7d' /etc/network/interfaces
sed -i "7 i\    netmask 255.255.255.0" /etc/network/interfaces
sed -i '8d' /etc/network/interfaces
sed -i "8 i\    gateway 192.168.1.1" /etc/network/interfaces
service networking restart
