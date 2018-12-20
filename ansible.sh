#!/bin/bash
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install ansible -y
sed -i "s/#host_key_checking.*/host_key_checking = False/g" /etc/ansible/ansible.cfg