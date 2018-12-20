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
        grub2-set-default  0 && grub2-mkconfig -o /etc/grub2.cfg
    ;;
    apt )
        apt-get install wget -y
        wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.12.14/linux-image-4.12.14-041214-generic_4.12.14-041214.201709200843_amd64.deb
        dpkg -i linux-image-4.12.14-041214-generic_4.12.14-041214.201709200843_amd64.deb
        update-grub
    ;;
esac
reboot
# # SSR
# sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
# sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
# echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf

# echo "net.core.default_qdisc = fq" >> /etc/sysctl.d/bbr.conf
# echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.d/bbr.conf
# sysctl -p
