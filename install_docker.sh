#!/bin/bash
# apt autoremove
yum --version &> /dev/null
if [ $? == 0 ];
    CMD=yum
else
    CMD=apt
fi
case ${CMD} in
    yum )
        yum install -y yum-utils device-mapper-persistent-data lvm2 curl
        yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        yum -y install docker-ce
        vgcreate docker /dev/sdb
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
        mkdir -p /var/lib/docker.bak
        mv /var/lib/docker/* /var/lib/docker.bak
        rm -rf /var/lib/docker/*
        cat > /etc/docker/daemon.json << EOF
{
  "storage-driver": "devicemapper",
  "storage-opts": [
     "dm.thinpooldev=/dev/mapper/docker-root",
     "dm.use_deferred_removal=true",
     "dm.use_deferred_deletion=true",
     "dm.basesize=50G"
   ],
    "registry-mirrors" : [
        "https://i3jtbyvy.mirror.aliyuncs.com"
    ],
    "insecure-registries": [
        "0.0.0.0/0"
    ],
   "debug" : true
}
EOF
    ;;
    apt )
        locale-gen en_US.UTF-8
        echo "export LC_CTYPE=\"en_US.UTF-8\"" >> ${HOME}/.bashrc
        apt-get remove docker docker-engine docker.io -y
        apt-get update
        apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
        # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
        apt-key fingerprint 0EBFCD88
        # add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo add-apt-repository \
   "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
        apt-get update
        apt-get install docker-ce -y
    ;;
esac
systemctl stop docker
echo "/dev/sda1 /var/lib/docker xfs defaults 0 0" >> /etc/fstab
cat > /etc/docker/daemon.json << EOF
{
    "registry-mirrors" : [
        "https://i3jtbyvy.mirror.aliyuncs.com"
    ],
    "insecure-registries" : [
        "0.0.0.0/0"
    ],
    "debug" : true,
    "experimental" : true
}
EOF
systemctl restart docker

# docker-compose
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/1.16.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose


export LC_CTYPE="en_US.UTF-8"

# # SSR
# sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
# sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
# echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
# sysctl -p

# curl -s  --unix-socket /run/docker.sock http://unix/info  | jq .Name | sed 's/"//g'

# # docker-engine
# apt-get update
# apt-get dist-upgrade -y
# apt-get install apt-transport-https ca-certificates -y
# apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A9*12897C070ADBF76221572C52609D
# echo "deb https://mirrors.tuna.tsinghua.edu.cn/docker/apt/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
# apt-get update
# apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y
# apt-get install linux-image-generic-lts-xenial -y
# apt-get install docker-engine -y


echo "/dev/vdb2 /mysql ext4 defaults 0 0" >> /etc/fstab