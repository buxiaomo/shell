#!/bin/bash
apt-get update
apt-get dist-upgrade -y
apt-get install apt-transport-https ca-certificates -y
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://mirrors.tuna.tsinghua.edu.cn/docker/apt/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual -y
apt-get install linux-image-generic-lts-xenial -y
apt-get install docker-engine -y

# vim /etc/docker/daemon.json

Aliyun_Quicken='https://i3jtbyvy.mirror.aliyuncs.com'
systemctl disable docker.service
systemctl stop docker.service
sed -i "s|ExecStart=/usr/bin/dockerd*|ExecStart=/usr/bin/dockerd --registry-mirror=${Aliyun_Quicken} -H unix:///var/run/docker.sock|g" /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl enable docker.service
systemctl start docker.service

curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/1.16.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
