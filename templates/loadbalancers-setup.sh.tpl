#!/bin/bash
apt update
SECOND_INTERFACE_NAME=$(sed -n 15p /etc/network/interfaces | awk -F'bond-slaves' '{print $2}' | awk -F' ' '{print $2}')
sed -i '15s/\w*$//' /etc/network/interfaces
sed -i '34s/\w*$/static/' /etc/network/interfaces
sed -i '35d' /etc/network/interfaces
sed -i "35 i\    address 192.168.1.1" /etc/network/interfaces
sed -i '36d' /etc/network/interfaces
sed -i "\$a\    netmask 255.255.255.0" /etc/network/interfaces
ifdown $SECOND_INTERFACE_NAME
ifup $SECOND_INTERFACE_NAME
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sed -i "s/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/" /etc/sysctl.conf
sysctl net.ipv4.ip_forward=1
sysctl net.ipv6.conf.all.forwarding=1
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o bond0 -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent
