#!/bin/bash
TYPE=`lsb_release -d | awk '{print $2}'`
case TYPE in
    *CentOS* )
        yum install epel-release ca-certificates -y
        sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
        sed -i "s/mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo
        sed -i "s#http://download.fedoraproject.org/pub#https://mirrors.tuna.tsinghua.edu.cn#g" /etc/yum.repos.d/epel.repo
        yum install -y koan
        koan --replace-self --server=${COBBLER_SERVER} --profile=CentOS-7.3.1611-x86_64
    ;;
    *Ubuntu* )
        apt-get install koan -y
        koan --replace-self --server=${COBBLER_SERVER} --system=${hostname}
    ;;
esac
