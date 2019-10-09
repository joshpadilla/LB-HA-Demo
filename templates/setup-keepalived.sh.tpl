#!/bin/bash
service keepalived stop
SECOND_INTERFACE_NAME=$(ip -o address show | grep 192.168.1.1 | awk -F': ' '{print $2}' | awk -F'inet ' '{print $1}')
sudo mkdir -p /etc/keepalived
sed -i "s/(SECOND_INTERFACE)/$SECOND_INTERFACE_NAME/" /tmp/keepalived-config.conf
cp /tmp/keepalived-config.conf /etc/keepalived/keepalived.conf
service keepalived start
