#!/bin/bash


rpm -ivh kernel-devel-3.10.0-514.el7.x86_64.rpm

yum install bash-completion vim wget -y
# Set Network
00:50:56:88:93:14
00:50:56:88:8D:EC
nmcli con add con-name bond0 type bond ifname bond0 mode 1 ip4 192.168.0.53/24 gw4 192.168.0.1
nmcli connection modify bond0 ipv4.dns 192.168.0.1
nmcli con add con-name bond0-slave0 type bond-slave ifname ens32 master bond0
nmcli con add con-name bond0-slave1 type bond-slave ifname ens36 master bond0

px
00:50:56:20:C8:A5
00:50:56:32:85:43

nmcli con add con-name bond1 type bond ifname bond1 mode 1 ip4 10.0.10.3/24
nmcli con add con-name bond1-slave0 type bond-slave ifname ens37 master bond1
nmcli con add con-name bond1-slave1 type bond-slave ifname ens38 master bond1


# Set variable
DEV_NAME=/dev/sdc1
DOCKER_VERSION=17.03.1.ce
NFS_SERVER=10.10.1.100
# Set sshd
sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
systemctl restart sshd
# Disabled selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
# Stop and Disabled Firewalld
systemctl stop firewalld.service
systemctl disable firewalld.service
# Set NTP
yum install ntp -y
sed -i "s/server 0.centos.pool.ntp.org iburst/server cn.ntp.org.cn iburst/g" /etc/ntp.conf
sed -i "s/server 1.centos.pool.ntp.org iburst/server ntp1.aliyun.com iburst/g" /etc/ntp.conf
sed -i "s/server 2.centos.pool.ntp.org iburst/server ntp2.aliyun.com iburst/g" /etc/ntp.conf
sed -i "s/server 3.centos.pool.ntp.org iburst/server ntp3.aliyun.com iburst/g" /etc/ntp.conf
systemctl restart ntpd.service
systemctl enable ntpd.service
# Install Docker
yum install yum-utils lvm2 device-mapper-persistent-data jq curl -y
cat > /etc/yum.repos.d/docker-ce.repo << EOF
[dockerrepo]
name=Docker Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker/yum/repo/centos7
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker/yum/gpg
EOF
yum install docker-engine-selinux-${DOCKER_VERSION}* docker-engine-${DOCKER_VERSION}* -y
# Set Docker Sotrage devie
systemctl stop docker.service
if [ -e ${DEV_NAME} ];then
    pvcreate ${DEV_NAME}
    vgcreate docker ${DEV_NAME}
    lvcreate --wipesignatures y -n root -l 95%VG docker
    lvcreate --wipesignatures y -n rootmeta -l 1%VG docker
    lvscan
    lvconvert -y --zero n -c 512K --thinpool docker/root --poolmetadata docker/rootmeta
    if [ ! -e /etc/lvm/profile/docker-thinpool.profile ];then
        cat > /etc/lvm/profile/docker-thinpool.profile << EOF
activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
}
EOF
    fi
    lvchange --metadataprofile docker-thinpool docker/root
    lvs -o+seg_monitor
fi
# mkfs.ext4 /dev/docker/thinpool
if [ -e /var/lib/docker ];then
    mkdir /var/lib/docker.bak
    mv /var/lib/docker/* /var/lib/docker.bak
    rm -rf /var/lib/docker/*
fi
[ -e /etc/docker ] || mkdir -p /etc/docker
if [ -e /etc/docker/daemon.json ];then
    touch /etc/docker/daemon.json
    cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors" : [
    "https://i3jtbyvy.mirror.aliyuncs.com"
  ],
  "storage-driver": "devicemapper",
  "storage-opts": [
     "dm.thinpooldev=/dev/mapper/docker-root",
     "dm.use_deferred_removal=true",
     "dm.use_deferred_deletion=true"
   ],
   "debug" : true,
   "experimental" : true
}
EOF
fi
systemctl daemon-reload
systemctl enable docker.service
systemctl start docker.service
docker info

bash -c "$(docker run --rm daocloud.io/daocloud/dce:2.6.1 install --listen-addr 192.168.0.51:2377 --advertise-addr 192.168.0.51)"


export Host_IP="192.168.0.53"
export Node1_IP="192.168.0.51"
export Node2_IP="192.168.0.52"
export Node3_IP="192.168.0.53"
mkdir -p /var/local/px/etcd
docker run -d \
-p 22380:22380 \
-p 22379:2379 \
--name px_etcd \
--volume /var/local/px/etcd:/etcd-data:rw \
--restart always \
--env ETCD_NAME="px-etcd-${Host_IP}" \
--env ETCD_DATA_DIR="/etcd-data" \
--env ETCD_ADVERTISE_CLIENT_URLS="http://${Host_IP}:22379" \
--env ETCD_LISTEN_PEER_URLS="http://0.0.0.0:22380" \
--env ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379" \
--env ETCD_INITIAL_ADVERTISE_PEER_URLS="http://${Host_IP}:22380" \
--env ETCD_INITIAL_CLUSTER="px-etcd-${Node1_IP}=http://${Node1_IP}:22380,px-etcd-${Node2_IP}=http://${Node2_IP}:22380,px-etcd-${Node3_IP}=http://${Node3_IP}:22380" \
--env ETCD_INITIAL_CLUSTER_STATE="new" \
--env ETCD_INITIAL_CLUSTER_TOKEN="pwx" \
--env ETCD_AUTO_COMPACTION_RETENTION="3" \
--env ETCD_QUOTA_BACKEND_BYTES="$((8*1024*1024*1024))" \
--env ETCD_SNAPSHOT_COUNT="5000" \
daocloud.io/daocloud/etcd:v3.2.9


docker run --entrypoint /runc-entry-point.sh \
--rm -i --privileged=true \
-v /opt/pwx:/opt/pwx \
-v /etc/pwx:/etc/pwx \
192.168.0.51/daocloud/px-enterprise:1.2.11.2

uuidgen


/opt/pwx/bin/px-runc install -c 7857b880-1fb7-4ef1-92b4-9e40c232656e \
-k etcd://192.168.0.51:22379,etcd://192.168.0.52:22379,etcd://192.168.0.53:22379 \
-m bond0 \
-d bond1 \
-s /dev/sdb -s /dev/sdc \
-x swarm

systemctl start portworx
/opt/pwx/bin/runc list
systemctl enable portworx
ln -vfs /opt/pwx/bin/pxctl /usr/bin/pxctl
pxctl status
# Set NFS
yum install nfs-utils.x86_64 -y
mkdir /mnt/nfs
mount ${NFS_SERVER}:/nfs /mnt/nfs
echo "${NFS_SERVER}:/nfs /mnt/nfs nfs defaults 0 0" >> /etc/fs
df -h | grep nfs
