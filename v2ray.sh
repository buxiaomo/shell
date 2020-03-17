#!/bin/bash
apt install curl gnupg2 ca-certificates lsb-release -y
curl -s http://nginx.org/keys/nginx_signing.key | apt-key add -
cat > /etc/apt/sources.list.d/nginx.list << EOF
deb http://nginx.org/packages/$(. /etc/os-release; echo "$ID")/ $(lsb_release -cs) nginx
deb-src http://nginx.org/packages/$(. /etc/os-release; echo "$ID")/ $(lsb_release -cs) nginx
EOF
apt-get update
apt-get install nginx -y
wget https://raw.githubusercontent.com/buxiaomo/v2ray/master/nginx.conf -O /etc/nginx/nginx.conf
rm -rf /etc/nginx/conf.d/default.conf
curl -L -s https://install.direct/go.sh | bash