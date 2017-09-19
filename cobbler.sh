#!/bin/bash
yum install net-tools -y
IP=`ifconfig | awk '/inet\>/{print $2}' | grep -v 127.0.0.1`
passwd=`openssl passwd -1 -salt 'random-phrase-here' 'root'`
systemctl stop firewalld.service
systemctl disable firewalld.service
if [ `getenforce` = "Enforcing" ];then
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
	echo "reboot your system an run again"
	exit 1
fi
yum install epel-release ca-certificates -y
sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
sed -i "s/mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo
sed -i "s#http://download.fedoraproject.org/pub#https://mirrors.tuna.tsinghua.edu.cn#g" /etc/yum.repos.d/epel.repo
yum install cobbler pykickstart wget -y
systemctl restart cobblerd.service httpd.service
cp /etc/cobbler/settings /etc/cobbler/settings.bak
sed -i "s/next_server: 127.0.0.1/next_server: ${IP}/g" /etc/cobbler/settings
sed -i "s/server: 127.0.0.1/server: ${IP}/g" /etc/cobbler/settings
cat > /etc/xinetd.d/tftp << EOF
# default: off
# description: The tftp server serves files using the trivial file transfer \
#       protocol.  The tftp protocol is often used to boot diskless \
#       workstations, download configuration files to network-aware printers, \
#       and to start the installation process for some operating systems.
service tftp
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot
        disable                 = no
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
EOF
cobbler get-loaders
if [ $? != 0 ];then
	wget -O /var/lib/cobbler/loaders/README http://cobbler.github.io/loaders/README
	wget -O /var/lib/cobbler/loaders/COPYING.elilo http://cobbler.github.io/loaders/COPYING.elilo
	wget -O /var/lib/cobbler/loaders/COPYING.yaboot http://cobbler.github.io/loaders/COPYING.yaboot
	wget -O /var/lib/cobbler/loaders/COPYING.syslinux http://cobbler.github.io/loaders/COPYING.syslinux
	wget -O /var/lib/cobbler/loaders/elilo-ia64.efi http://cobbler.github.io/loaders/elilo-3.8-ia64.efi
	wget -O /var/lib/cobbler/loaders/yaboot http://cobbler.github.io/loaders/yaboot-1.3.17
	wget -O /var/lib/cobbler/loaders/pxelinux.0 http://cobbler.github.io/loaders/pxelinux.0-3.86
	wget -O /var/lib/cobbler/loaders/menu.c32 http://cobbler.github.io/loaders/menu.c32-3.86
	wget -O /var/lib/cobbler/loaders/grub-x86.efi http://cobbler.github.io/loaders/grub-0.97-x86.efi
	wget -O /var/lib/cobbler/loaders/grub-x86_64.efi http://cobbler.github.io/loaders/grub-0.97-x86_64.efi
fi
systemctl enable rsyncd.service
yum install perl bzip2 ed patch perl-Compress-Zlib perl-Digest-MD5 perl-Digest-SHA1 perl-libwww-perl perl-LockFile-Simple -y
rpm -ivh ftp://rpmfind.net/linux/epel/5/x86_64/debmirror-20090807-1.el5.noarch.rpm
if [ $? = 0 ];then
	sed -i 's|@dists=.*|#@dists=|' /etc/debmirror.conf
	sed -i 's|@arches=.*|#@arches=|' /etc/debmirror.conf
fi
sed -i "s|default_password_crypted:.*|default_password_crypted: '${passwd}'|" /etc/cobbler/settings
yum  -y install dhcp
cat > /etc/dhcp/dhcpd.conf << EOF
# ******************************************************************
# Cobbler managed dhcpd.conf file
#
# generated from cobbler dhcp.conf template ($date)
# Do NOT make changes to /etc/dhcpd.conf. Instead, make your changes
# in /etc/cobbler/dhcp.template, as /etc/dhcpd.conf will be
# overwritten.
#
# ******************************************************************
ddns-update-style interim;
allow booting;
allow bootp;
ignore client-updates;
set vendorclass = option vendor-class-identifier;
option pxe-system-type code 93 = unsigned integer 16;
subnet `ifconfig  | grep inet | grep -vE 'inet6|127.0.0.1' | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."0}'` netmask 255.255.255.0 {
     option routers             ${IP};
     option domain-name-servers 114.114.114.114;
     option subnet-mask         255.255.255.0;
     range dynamic-bootp        `ifconfig  | grep inet | grep -vE 'inet6|127.0.0.1' | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."200}'` `ifconfig  | grep inet | grep -vE 'inet6|127.0.0.1' | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."254}'`;
     default-lease-time         21600;
     max-lease-time             43200;
     next-server                ${IP};
     class "pxeclients" {
          match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
          if option pxe-system-type = 00:02 {
                  filename "ia64/elilo.efi";
          } else if option pxe-system-type = 00:06 {
                  filename "grub/grub-x86.efi";
          } else if option pxe-system-type = 00:07 {
                  filename "grub/grub-x86_64.efi";
          } else {
                  filename "pxelinux.0";
          }
     }
}
EOF
yum install cobbler-web -y
cobbler signature update
systemctl restart dhcpd.service tftp.socket cobblerd.service httpd.service
systemctl enable dhcpd.service tftp.socket cobblerd.service httpd.service

# mount CentOS-7-x86_64-DVD-1611.iso /mnt
# cobbler import --name=CentOS-7.3.1611-x86_64 --path=/mnt/
# umount /mnt
#
# mount CentOS-7-x86_64-DVD-1511.iso /mnt
# cobbler import --name=CentOS-7.2.1511-x86_64 --path=/mnt/
# umount /mnt
#
#
# mount ubuntu-16.04.2-server-amd64.iso /mnt
# cobbler import --name=Ubuntu-16.04.2-x86_64 --path=/mnt/
# umount /mnt
#
# cobbler repo add --name=epel --mirror=http://mirrors.aliyun.com/epel/7Server/x86_64/
# cobbler repo add --name=Zabbix --mirror=http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/
# cobbler repo add --name=MySql65 --mirror=https://repo.mysql.com/yum/mysql-5.6-community/el/7/x86_64/
# cobbler reposync --only=ONLY
# cobbler sync
