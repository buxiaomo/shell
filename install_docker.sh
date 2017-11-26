#!/bin/bash
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
    ;;
    apt )
        apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
        curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
        add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
        apt-get update
        apt-get install docker-ce -y
    ;;
esac

cat > /etc/docker/daemon.json << EOF
{
"registry-mirrors" : [
"https://i3jtbyvy.mirror.aliyuncs.com"
],
"debug" : true,
"experimental" : true
}
EOF
# docker-compose
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/1.16.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

# # SSR
# sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
# sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
# echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
# echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
# sysctl -p


# # docker-engine
# apt-get update
# apt-get dist-upgrade -y
# apt-get install apt-transport-https ca-certificates -y
# apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# echo "deb https://mirrors.tuna.tsinghua.edu.cn/docker/apt/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
# apt-get update
# apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y
# apt-get install linux-image-generic-lts-xenial -y
# apt-get install docker-engine -y
