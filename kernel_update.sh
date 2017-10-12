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
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9-rc8/linux-image-4.9.0-040900rc8-generic_4.9.0-040900rc8.201612051443_amd64.deb
dpkg -i linux-image-4.9.0*.deb
dpkg -l|grep linux-image
sudo apt-get remove linux-image-[Tab补全]
update-grub
reboot
