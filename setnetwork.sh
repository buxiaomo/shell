#!/bin/bash
DNS='172.1.1.2'
GW='172.1.1.2'
Device_Name=`nmcli connection show | grep -v NAME |awk '{print $4}' | grep -v '\-\-'`
Con_Name=`nmcli connection show | grep -v NAME |awk '{print $1}'`

nmcli connection add con-name static type ethernet autoconnect yes ifname ${Device_Name}   ip4 $1'/24' gw4 ${GW}
nmcli connection modify static ipv4.dns ${DNS}
nmcli connection modify ${Con_Name} connection.autoconnect no
systemctl restart network


hostnamectl set-hostname host42.paas.local
nmcli connection add con-name static \
ipv4.method manual \
type ethernet autoconnect yes \
ifname ens32 ipv4.addresses '10.3.236.252/24' \
ipv4.gateway 10.3.236.254 \
ipv4.dns 202.103.24.68
nmcli connection modify ens32 autoconnect no
yum update  -y
reboot
