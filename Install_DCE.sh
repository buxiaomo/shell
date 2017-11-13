#!/bin/bash
# Set variable
DEV_NAME=/dev/sdb1
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

# Set NFS
yum install nfs-utils.x86_64 -y
mkdir /mnt/nfs
mount ${NFS_SERVER}:/nfs /mnt/nfs
echo "${NFS_SERVER}:/nfs /mnt/nfs nfs defaults 0 0" >> /etc/fs
df -h | grep nfs
