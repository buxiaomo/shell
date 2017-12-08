#!/bin/bash
. ./splunk.config
. ./colorecho.sh

SPLUNK_URL=''
SPLUNK_DOWNLOAD_FILENAME=''
SPLUNK_HOME=${INSTALL_HOME}/splunk

# NETWORK
# IP=192.168.0.14
# nmcli connection add con-name static ifname ens32 autoconnect yes type ethernet ip4 "${IP}/24" gw4 192.168.0.1
# nmcli connection modify static ipv4.method manual
# nmcli connection modify static ipv4.dns 192.168.0.1
# nmcli connection modify ens32 connection.autoconnect no

if [ $# -eq 0 ];then
    echo "./$0 server|indexer|forwarder"
    exit 1
fi
case $1 in
    server )
        SPLUNK_URL=https://download.splunk.com/products/splunk/releases/7.0.0/linux/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_URL=http://file.splunk.org.cn/splunkserver/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_DOWNLOAD_FILENAME=/usr/local/src/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_HOME=${INSTALL_HOME}/splunk
    ;;
    indexer )
        SPLUNK_URL=https://download.splunk.com/products/splunk/releases/7.0.0/linux/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_URL=http://file.splunk.org.cn/splunkserver/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_DOWNLOAD_FILENAME=/usr/local/src/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_HOME=${INSTALL_HOME}/splunk
    ;;
    forwarder )
        SPLUNK_URL=http://file.splunk.org.cn/splunkforward/splunkforwarder-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_DOWNLOAD_FILENAME=/usr/local/src/splunkforwarder-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
        SPLUNK_HOME=${INSTALL_HOME}/splunkforwarder
    ;;
esac
echo "Server Type: $1
Hostname: ${HOSTNAME}
Splunk Home: ${SPLUNK_HOME}
Splunk Master IP: ${SPLUNK_MASTER_IP}
Deployment Server IP: ${DEPLOYMENT_SERVER_IP}
Splunk User: ${SPLUNK_USER}
Splunk PASS: ${SPLUNK_PASS}
Install Home: ${INSTALL_HOME}
Splunk Download Url: ${SPLUNK_URL}
Splunk Download Filename: ${SPLUNK_DOWNLOAD_FILENAME}"
read -p "Please check your configuration is correct(y/n): " YN
if [ ${YN} != "y" ];then
    exit 1
fi
sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
systemctl restart sshd
# Disabled selinux
if [ $(getenforce) != "Disabled" ];then
    sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    bluecolor "We where reboot your system and you can run this shell"
    reboot
fi
systemctl stop firewalld.service
systemctl disable firewalld.service
# NTP
yum install ntp -y
sed -i "s/server 0.centos.pool.ntp.org iburst/server cn.ntp.org.cn iburst/g" /etc/ntp.conf
sed -i "s/server 1.centos.pool.ntp.org iburst/server ntp1.aliyun.com iburst/g" /etc/ntp.conf
sed -i "s/server 2.centos.pool.ntp.org iburst/server ntp2.aliyun.com iburst/g" /etc/ntp.conf
sed -i "s/server 3.centos.pool.ntp.org iburst/server ntp3.aliyun.com iburst/g" /etc/ntp.conf
systemctl restart ntpd.service
systemctl enable ntpd.service
yum install wget -y
yum update -y
# Splunk
adduser ${SPLUNK_USER}
echo "${SPLUNK_PASS}" | passwd --stdin ${SPLUNK_USER}
hostnamectl set-hostname ${HOSTNAME}

wget -O ${SPLUNK_DOWNLOAD_FILENAME} ${SPLUNK_URL}
tar -zxf ${SPLUNK_DOWNLOAD_FILENAME} -C ${INSTALL_HOME}
chown -R ${SPLUNK_USER}.${SPLUNK_USER} ${SPLUNK_HOME}
case $1 in
    server )
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk start --accept-license"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk edit user admin -password 'admin' -role admin -auth admin:changeme"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk set servername ${HOSTNAME} -auth admin:admin"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk edit cluster-config -mode master -replication_factor 2 -search_factor 2 -secret changeme -cluster_label esxi -auth admin:admin"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk restart"
        cat > /etc/profile.d/splunk.sh <<EOF
export SPLUNK_HOME=/opt/splunk
export PATH=\$SPLUNK_HOME/bin:\$PATH
EOF
    ;;
    indexer )
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk start --accept-license"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk edit user admin -password 'admin' -role admin -auth admin:changeme"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk set servername ${HOSTNAME} -auth admin:admin"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk enable listen 9997 -auth admin:admin"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk disable webserver"
        mkdir -p /var/splunk/
        chown -R ${SPLUNK_USER}.${SPLUNK_USER} /var/splunk/
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk set datastore-dir /var/splunk/ -auth admin:admin"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk edit cluster-config -mode slave -master_uri https://${SPLUNK_MASTER_IP}:8089 -replication_port 9887 -secret changeme -auth admin:admin"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk restart"
        mkdir -p /opt/frozen/web
        chown -R admin.admin /opt/frozen/web
        /opt/splunk/bin/splunk add index web \
        -maxTotalDataSizeMB 60000 \
        -maxDataSize 3000 \
        -coldToFrozenDir /opt/frozen/web -auth admin:admin
        cat > /etc/profile.d/splunk.sh <<EOF
export SPLUNK_HOME=/opt/splunk
export PATH=\$SPLUNK_HOME/bin:\$PATH
EOF
    ;;
    forwarder )
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk edit user admin -password 'admin' -role admin -auth admin:changeme"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk set servername ${HOSTNAME} -auth admin:admin"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk set deploy-poll ${DEPLOYMENT_SERVER_IP}:8089 -auth admin:admin"
        # su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk add forward-server 192.168.0.11:9997"
        # su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk add forward-server 192.168.0.12:9997"
        su - ${SPLUNK_USER} -c "${SPLUNK_HOME}/bin/splunk restart"
        cat > /etc/profile.d/splunkforwarder.sh <<EOF
export SPLUNK_HOME=/opt/splunkforwarder
export PATH=\$SPLUNK_HOME/bin:\$PATH
EOF
    ;;
esac
