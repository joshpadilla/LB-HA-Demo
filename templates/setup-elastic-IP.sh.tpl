#!/bin/bash
apt-get update
sed '27s/$/\n/' /etc/network/interfaces
sed -i "28 i\auto bond0:1" /etc/network/interfaces
sed -i "29 i\iface bond0:1 inet static" /etc/network/interfaces
sed -i "30 i\    address ${Elastic_IP}" /etc/network/interfaces
sed -i "31 i\    netmask 255.255.255.255" /etc/network/interfaces
ifup bond0:1
apt-get install bird -y
mv /etc/bird/bird.conf /etc/bird/bird.conf.original
PACKET_PRIVATE_PEER_GATEWAY_IP=$(route -n | grep '10.0.0.0' | awk '{$1=$1};1' | cut -d' ' -f2)
sed -i "s/(PEER_GATEWAY_PRIVATE_IP)/$PACKET_PRIVATE_PEER_GATEWAY_IP/" /tmp/bird-config-file.conf
sed -i '30d' /tmp/bird-config-file.conf
service bird stop
systemctl enable bird.service
systemctl enable bird6.service
cp /tmp/bird-config-file.conf /etc/bird/bird.conf
service bird start
apt-get install haproxy -y
rm /etc/haproxy/haproxy.cfg
sed -i "s#/32##" /tmp/haproxy-config.cfg
cp /tmp/haproxy-config.cfg /etc/haproxy/haproxy.cfg
echo "net.ipv4.ip_nonlocal_bind = 1" >> /etc/sysctl.conf
service haproxy restart
apt-get install keepalived -y
