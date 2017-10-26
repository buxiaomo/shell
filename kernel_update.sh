#!/bin/bash

# import key
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# install elrepo repo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
# install kernel
yum --enablerepo=elrepo-kernel install kernel-lt kernel-lt-headers kernel-lt-devel -y

# modify grub
grub2-set-default 0
KERNEL_VERSION=
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10/linux-image-4.10.0-041000-generic_4.10.0-041000.201702191831_amd64.deb
dpkg -i linux-image-4.10.0
dpkg -l|grep linux-image
sudo apt-get remove linux-image-[Tab补全]
update-grub
reboot

# SSR
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
sysctl -p
