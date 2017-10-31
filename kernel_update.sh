#!/bin/bash
whereis yum &> /dev/null
if [ $? == 0 ];
    CMD=yum
else
    CMD=apt
fi
case ${CMD} in
    yum )
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
        rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
        yum --enablerepo=elrepo-kernel install kernel-lt kernel-lt-headers kernel-lt-devel -y
    ;;
    apt )
        apt-get install wget -y
        wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10/linux-image-4.10.0-041000-generic_4.10.0-041000.201702191831_amd64.deb
        dpkg -i linux-image-4.10.0-041000-generic_4.10.0-041000.201702191831_amd64.deb
        update-grub
    ;;
esac
reboot
# # SSR
# sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
# sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
# echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
# sysctl -p
