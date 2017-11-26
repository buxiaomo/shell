#!/bin/bash
source function/colorecho.sh
. config
function inithost {
    bluecolor "Configure ssh service..."
    sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
    systemctl restart sshd
    bluecolor "Configure firewalld service..."
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    bluecolor "Configure SELinux service..."
    if [ ! -e /tmp/selinux ];then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
        touch /tmp/selinux
        bluecolor "We where reboot your system and you can run this shell"
        reboot
    fi
}
function configurerepo {
    bluecolor "Unzip the package..."
    tar -zxf file/yum.tar.xz -C ${UPLOAD_DIR}
    cp file/${ISO_FILE} ${UPLOAD_DIR}
    mkdir -p ${UPLOAD_DIR}/centos
    mount
    bluecolor "Configure repo file..."
    mkdir -p /etc/yum.repos.d/bak
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
    cp file/repo/docker.repo file/repo/base.repo file/repo/epel.repo /etc/yum.repos.d/
}
function ntp {
    bluecolor "Install the ntp..."
    yum install ntpd -y
}
inithost
