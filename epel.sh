#!/bin/bash
yum install epel-release ca-certificates -y
sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
sed -i "s/mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo
sed -i "s#http://download.fedoraproject.org/pub#https://mirrors.tuna.tsinghua.edu.cn#g" /etc/yum.repos.d/epel.repo
