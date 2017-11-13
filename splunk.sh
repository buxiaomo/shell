# SSHD
sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
systemctl restart sshd
# Disabled selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
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
# NETWORK
IP=192.168.0.199
nmcli connection add con-name static ifname eno16777728 autoconnect yes type ethernet ip4 "${IP}/24" gw4 192.168.0.1
nmcli connection modify static ipv4.method manual
nmcli connection modify static ipv4.dns 192.168.0.1
nmcli connection modify eno16777728 connection.autoconnect no
hostnamectl set-hostname SplunkIndexer02
# Splunk
SPLUNK_USER=splunk
SPLUNK_PASS=splunk
SPLUNK_URL=https://download.splunk.com/products/splunk/releases/7.0.0/linux/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
SPLUNK_URL=http://file.splunk.org.cn/splunkserver/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
SPLUNK_DOWNLOAD_FILENAME=/usr/local/src/splunk-7.0.0-c8a78efdd40f-Linux-x86_64.tgz
INSTALL_HOME=/opt
SPLUNK_HOME=${INSTALL_HOME}/splunk
adduser ${SPLUNK_USER}
echo "${SPLUNK_PASS}" | passwd --stdin ${SPLUNK_USER}
yum install wget -y
wget -O ${SPLUNK_DOWNLOAD_FILENAME} ${SPLUNK_URL}
tar -zxf ${SPLUNK_DOWNLOAD_FILENAME} -C ${INSTALL_HOME}
chown -R ${SPLUNK_USER}.${SPLUNK_USER} ${SPLUNK_HOME}
case $1 in
    server )
        su - splunk -c "${SPLUNK_HOME}/bin/splunk start --accept-license"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk edit user admin -password 'admin' -role admin -auth admin:changeme"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk set servername splunkserver -auth admin:admin"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk edit cluster-config -mode master -replication_factor 2 -search_factor 2 -secret changeme -cluster_label esxi -auth admin:admin"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk restart"
    ;;
    indexer )
        SPLUNK_MASTER_IP=splunk
        su - splunk -c "${SPLUNK_HOME}/bin/splunk start --accept-license"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk edit user admin -password 'admin' -role admin -auth admin:changeme"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk set servername Indexer01 -auth admin:admin"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk enable listen 9997 -auth admin:admin"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk disable webserver"
        # su - splunk -c "${SPLUNK_HOME}/bin/splunk set datastore-dir /var/splunk/"
        su - splunk -c "$SPLUNK_HOME/bin/splunk edit cluster-config -mode slave -master_uri https://$SPLUNK_MASTER_IP:8089 -replication_port 9887 -secret changeme -auth admin:admin"
        su - splunk -c "${SPLUNK_HOME}/bin/splunk restart"
    ;;
esac
# Splunk Indexer
