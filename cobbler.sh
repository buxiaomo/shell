#!/bin/bash
function StandardOutput() {
		echo -e "\033[32m$1\033[0m"
}
function ErrorOutput() {
		echo -e "\033[31m$1!!!\033[0m"
}
function Check_OS() {
		yum install redhat-lsb-core -y
		OS=$(lsb_release -i  | awk -F 'ID:.' '{print $2}')
		RELEASE=$(lsb_release -r | awk -F ' ' '{print $NF}')
		if [[ ${OS} != 'CentOS' ]] && [[ ${RELEASE} != '7.2.1611' ]];then
				echo "Please use OS where CentOS 7.2"
				exit 1
		fi
}
function Install_Base() {
		StandardOutput "Base Configure"
		yum install epel-release ca-certificates -y
		sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
		sed -i "s/mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo
		sed -i "s#http://download.fedoraproject.org/pub#https://mirrors.tuna.tsinghua.edu.cn#g" /etc/yum.repos.d/epel.repo
		yum install net-tools -y
		systemctl stop firewalld.service
		systemctl disable firewalld.service
		if [ $(getenforce) == "Enforcing" ];then
				StandardOutput "Setting SELinux"
				sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
				StandardOutput "reboot your system an run again"
				exit 1
		fi
}
function Install_Cobbler() {
		StandardOutput "Install Cobbler"
		yum install cobbler cobbler-web dhcp pykickstart wget perl bzip2 ed patch perl-Compress-Zlib perl-Digest-MD5 perl-Digest-SHA1 perl-libwww-perl perl-LockFile-Simple -y
}

function Configure_Cobbler() {
		StandardOutput "Configure Cobbler"
		systemctl restart cobblerd.service httpd.service
		IP=$(ifconfig | awk '/inet\>/{print $2}' | grep -v 127.0.0.1)
		Cobbler_PASSWORD=$(openssl passwd -1 -salt '123456' "root")
		cp /etc/cobbler/settings /etc/cobbler/settings.bak
		sed -i "s/next_server: 127.0.0.1/next_server: ${IP}/g" /etc/cobbler/settings
		sed -i "s/server: 127.0.0.1/server: ${IP}/g" /etc/cobbler/settings
		sed -i "s|default_password_crypted:.*|default_password_crypted: '${Cobbler_PASSWORD}'|" /etc/cobbler/settings
		sed -i 's/pxe_just_once: 0/pxe_just_once: 1/g' /etc/cobbler/settings
		# DHCP
		Cobbler_DHCP_SUBNET=$(ifconfig  | grep inet | grep -vE 'inet6|127.0.0.1' | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."0}')
		Cobbler_DHCP_ROUTER=$(route -n | grep -E '^0.0.0.0' | awk  '{print $2}')
		Cobbler_DHCP_DNS=114.114.114.114
		Cobbler_DHCP_RANGE="$(ifconfig  | grep inet | grep -vE 'inet6 | 127.0.0.1' | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."200}') $(ifconfig  | grep inet | grep -vE 'inet6 | 127.0.0.1' | awk '{print $2}' | awk -F '.' '{print $1"."$2"."$3"."250}')"
		sed -i 's/manage_dhcp: 0/manage_dhcp: 1/g' /etc/cobbler/settings
		sed -i "s/192.168.1.0/${Cobbler_DHCP_SUBNET}/" /etc/cobbler/dhcp.template
		sed -i "s/192.168.1.5/${Cobbler_DHCP_ROUTER}/" /etc/cobbler/dhcp.template
		sed -i "s/192.168.1.1;/${Cobbler_DHCP_DNS};/" /etc/cobbler/dhcp.template
		sed -i "s/192.168.1.100 192.168.1.254/${Cobbler_DHCP_RANGE}/" /etc/cobbler/dhcp.template
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
		StandardOutput "Setting Rsyncd"
		systemctl enable rsyncd.service
		rpm -ivh ftp://rpmfind.net/linux/epel/5/x86_64/debmirror-20090807-1.el5.noarch.rpm
		if [ $? = 0 ];then
				sed -i 's|@dists=.*|#@dists=|' /etc/debmirror.conf
				sed -i 's|@arches=.*|#@arches=|' /etc/debmirror.conf
		fi
		cobbler signature update
		cobbler sync
		systemctl restart dhcpd.service tftp.socket cobblerd.service httpd.service
		systemctl enable dhcpd.service tftp.socket cobblerd.service httpd.service
}

case $1 in
		install )
				Check_OS
				Install_Base
				Install_Cobbler
				Configure_Cobbler
		;;
		download )
				echo "download"
		;;
		import )
				echo "import"
		;;
		* )
				echo "$0 install|download|import"
		;;
esac

# function ImportISOImage {
# 	mkdir -p /mnt
# 	StandardOutput "import CentOS-7-x86_64-DVD-1511"
# 	if [ -e ./CentOS-7-x86_64-DVD-1511.iso ]
# 		wget -O ./CentOS-7-x86_64-DVD-1511.iso http://vault.centos.org/7.2.1511/isos/x86_64/CentOS-7-x86_64-DVD-1511.iso
# 		mount ./CentOS-7-x86_64-DVD-1511.iso /mnt
# 		cobbler import --name=CentOS-7.2.1511-x86_64 --path=/mnt/
# 		umount /mnt
# 	fi
# 	StandardOutput "import CentOS-7-x86_64-DVD-1611"
# 	if [ -e ./CentOS-7-x86_64-DVD-1611.iso ]
# 		wget -O ./CentOS-7-x86_64-DVD-1611.iso http://vault.centos.org/7.3.1611/isos/x86_64/CentOS-7-x86_64-DVD-1611.iso
# 		mount ./CentOS-7-x86_64-DVD-1611.iso /mnt
# 		cobbler import --name=CentOS-7.3.1611-x86_64 --path=/mnt/
# 		umount /mnt
# 	fi
# 	StandardOutput "import CentOS-7-x86_64-DVD-1708"
# 	if [ -e ./CentOS-7-x86_64-DVD-1708.iso ]
# 		wget -O ./CentOS-7-x86_64-DVD-1708.iso https://mirrors.tuna.tsinghua.edu.cn/centos/7.4.1708/isos/x86_64/CentOS-7-x86_64-DVD-1708.iso
# 		mount ./CentOS-7-x86_64-DVD-1708.iso /mnt
# 		cobbler import --name=CentOS-7.4.1708-x86_64 --path=/mnt/
# 		umount /mnt
# 	fi
# 	StandardOutput "import Ubuntu-16.04.2-x86_64"
# 	if [ -e ./ubuntu-16.04.2-server-amd64.iso ]
# 		wget -O ./ubuntu-16.04.2-server-amd64.iso http://vault.centos.org/7.3.1611/isos/x86_64/CentOS-7-x86_64-DVD-1611.iso
# 		mount ubuntu-16.04.2-server-amd64.iso /mnt
# 		cobbler import --name=Ubuntu-16.04.2-x86_64 --path=/mnt/
# 		umount /mnt
# 	fi
# 	cobbler sync
# }


#
#
# scp root@10.10.10.250:/vmfs/volumes/59bfa1e4-79708ae6-2e6f-f44d306e0bac/CentOS-7-x86_64-DVD-1511.iso \
# root@10.10.10.250:/vmfs/volumes/59bfa1e4-79708ae6-2e6f-f44d306e0bac/CentOS-7-x86_64-DVD-1611.iso \
# root@10.10.10.250:/vmfs/volumes/59bfa1e4-79708ae6-2e6f-f44d306e0bac/ubuntu-16.04.2-server-amd64.iso .
#
#
#
#
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
#
# # 重装
# #!/bin/bash
# yum install epel-release ca-certificates -y
# sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
# sed -i "s/mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo
# sed -i "s#http://download.fedoraproject.org/pub#https://mirrors.tuna.tsinghua.edu.cn#g" /etc/yum.repos.d/epel.repo
#
# yum install -y koan
# koan --replace-self --server=192.168.0.10 --profile=CentOS-7.3.1611-x86_64
# reboot
#
# HOSTNAME=test
# ID=20
# MAC=00:50:56:30:31:78
# cobbler system add \
# --name=${HOSTNAME}${ID} \
# --profile=CentOS-7.3.1611-x86_64 \
# --mac=${MAC} \
# --interface=eth0 \
# --ip-address=10.3.236.${ID} \
# --hostname=${HOSTNAME}${ID} \
# --gateway=10.3.236.254  --static=1
