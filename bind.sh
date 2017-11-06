#!/usr/bin/env bash
# shellname hostname lan1name lan2name BondIP1
# 配置本地YUM
mv /etc/yum.repos.d/* /root/backup/
echo "[local]
name=CentOS Local
baseurl=file:///mnt/u/
gpgcheck=0" >  /etc/yum.repos.d/local.repo
yum install bash-completion vim net-tools -y
# 卸载NetworkManager
yum remove NetworkManager -y
#关闭SELinux
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
#关闭并禁用防火墙
systemctl disable firewalld.service
systemctl stop firewalld.service
#设置主机名
hostnamectl set-hostname "paas0${1}.dfmc.local"
echo "paas0${1}.dfmc.local" > /etc/hostname
# 网卡bind
# 配置第一个Bond
cat > /etc/sysconfig/network-scripts/ifcfg-${2} << EOF
NAME=${2}
DEVICE=${2}
TYPE=Ethernet
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
ONBOOT=yes
EOF
cat > /etc/sysconfig/network-scripts/ifcfg-${3} << EOF
NAME=${3}
DEVICE=${3}
TYPE=Ethernet
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
ONBOOT=yes
EOF
cat >  /etc/sysconfig/network-scripts/ifcfg-bond0 << EOF
DEVICE=bond0
TYPE=bond
ONBOOT=yes
BOOTPROTO=static
IPADDR=${4}
GATEWAY=10.2.23.1
# GATEWAY=10.3.236.254
NETMASK=255.255.255.0
DNS1=10.2.0.1
DNS2=10.2.0.2
BONDING_OPTS="miimon=100 mode=1"
BONDING_MASTER=yes
EOF
Core = `cat /proc/cpuinfo | grep "core id" | wc -l`
HostName = `cat /etc/hostname`
Mem = `free -m | grep Mem | awk '{print $2}'`
echo "HostName: ${HostName}
Core: ${Core}
Mem: ${Mem}
" > ${4}
## 配置第二个Bond
#cat > /etc/sysconfig/network-scripts/ifcfg-${5} << EOF
#NAME=${5}
#DEVICE=${5}
#TYPE=Ethernet
#BOOTPROTO=none
#MASTER=bond1
#SLAVE=yes
#ONBOOT=yes
#EOF
#cat > /etc/sysconfig/network-scripts/ifcfg-${6} << EOF
#NAME=${6}
#DEVICE=${6}
#TYPE=Ethernet
#BOOTPROTO=none
#MASTER=bond1
#SLAVE=yes
#ONBOOT=yes
#EOF
#cat >  /etc/sysconfig/network-scripts/ifcfg-bond1 << EOF
#DEVICE=bond1
#TYPE=bond
#ONBOOT=yes
#BOOTPROTO=static
#IPADDR=${7}
## GATEWAY=10.2.23.1
#GATEWAY=10.3.236.254
#NETMASK=255.255.255.0
#DNS1=114.114.114.114
## DNS1=10.2.0.1
## DNS2=10.2.0.2
#BONDING_OPTS="miimon=100 mode=1"
#BONDING_MASTER=yes
#EOF
