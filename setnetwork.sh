#!/bin/bash
DNS='192.168.0.1'
GW='192.168.0.10'
Device_Name=`nmcli connection show | grep -v NAME |awk '{print $4}' | grep -v '\-\-'`
Con_Name=`nmcli connection show | grep -v NAME |awk '{print $1}'`

nmcli connection add con-name static type ethernet autoconnect yes ifname ${Device_Name}   ip4 $1'/24' gw4 ${GW}
nmcli connection modify static ipv4.dns 114.114.114.114
nmcli connection modify eno16777728 connection.autoconnect no
systemctl restart network

nmcli connection add con-name static \
autoconnect yes ifname eno16777728 \
type ethernet ip4 '10.10.10.3/24' gw4 10.10.10.1

hostnamectl set-hostname splunkserver
nmcli connection add con-name static \
ipv4.method manual \
type ethernet autoconnect yes \
ifname eno16777728 ipv4.addresses '192.168.0.10/24' \
ipv4.gateway 192.168.0.1 \
ipv4.dns 192.168.0.1
nmcli connection modify ens32 autoconnect no
yum update  -y
reboot


nmcli connection add con-name static type ethernet autoconnect yes ifname eno16777728   ip4 10.0.1.10/16 gw4 10.0.0.1
