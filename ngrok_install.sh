#!/bin/bash
function StandardOutput {
	echo -e "\033[32m$1\033[0m"
}
function ErrorOutput {
	echo -e "\033[31m$1!!!\033[0m"
}
function InstallEpel {
	yum install epel-release -y
    sed -i "s/#baseurl/baseurl/g" /etc/yum.repos.d/epel.repo
    sed -i "s/mirrorlist/#mirrorlist/g" /etc/yum.repos.d/epel.repo
    sed -i "s#http://download.fedoraproject.org/pub#https://mirrors.tuna.tsinghua.edu.cn#g" /etc/yum.repos.d/epel.repo
		yum makecache
}
if [ $# != 1 ];then
	ErrorOutput "$0 DomainName"
	exit 1
fi

NGROK_DOMAIN=$1
InstallEpel
yum install go git screen golang-pkg-windows-amd64 golang-pkg-windows-386 golang-pkg-linux-amd64 golang-pkg-linux-386 golang-pkg-darwin-amd64 golang-pkg-darwin-386 zip curl golang-pkg-linux-arm openssl make -y
StandardOutput "Get ngrok Source package..."
[ -d /tmp/ngrokd/ ] && rm -rf /tmp/ngrokd/
[ -d /usr/local/ngrok ] || git clone https://github.com/inconshreveable/ngrok.git /usr/local/ngrok
if [ $? != 0 ];then
	ErrorOutput "Get ngrok Source package fail"
	exit 1
fi
cd /usr/local/ngrok
[ -d ./openssl ] && rm -rf ./openssl
mkdir openssl && cd openssl
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
openssl genrsa -out device.key 2048
openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000
cp -f rootCA.pem ../assets/client/tls/ngrokroot.crt
cp -f device.crt ../assets/server/tls/snakeoil.crt
cp -f device.key ../assets/server/tls/snakeoil.key
cd ..

StandardOutput "Compiler server program..."
GOOS=linux GOARCH=amd64 make release-server
if [[ $? != 0 ]];then
	ErrorOutput "Compiler server program fail"
	exit 1
fi
StandardOutput "Compiler Linux Client program..."
GOOS=linux GOARCH=amd64 make release-client
GOOS=linux GOARCH=386 make release-client
StandardOutput "Compiler Window Client program..."
GOOS=windows GOARCH=amd64 make release-client
GOOS=windows GOARCH=386 make release-client
StandardOutput "Compiler MAC Client program..."
GOOS=darwin GOARCH=386 make release-client
GOOS=darwin GOARCH=amd64 make release-client
StandardOutput "Compiler ARM Client program..."
GOOS=linux GOARCH=arm make release-client
cat > ngrok.cfg << EOF
server_addr: "$NGROK_DOMAIN:8080"
trust_host_root_certs: false

tunnels:
    ssh:
       remote_port: 22
       proto:
         tcp: "127.0.0.1:22"
    mstsc:
        remote_port: 3389
        proto:
         tcp: "127.0.0.1:3389"
    web:
     subdomain: "www"
     proto:
       http: 80
    domain:
     hostname: "www.example.com"
     proto:
       http: 80
EOF
cat > start.bat << EOF
@echo off
ipconfig /flushdns
ngrok.exe -config ngrok.cfg start ssh mstsc web
pause
EOF
cat > start.sh << EOF
./ngrok -config ngrok.cfg start ssh mstsc web
EOF
chmod +x start.sh

StandardOutput "Package required files"
mkdir -p package/{linux64,linux32,win64,win32,arm,mac64,mac32}

cp -p {start.bat,ngrok.cfg,bin/windows_amd64/ngrok.exe} package/win64/
cp -p {start.bat,ngrok.cfg,bin/windows_386/ngrok.exe} package/win32/

cp -p {start.bat,ngrok.cfg,bin/linux_arm/ngrok} package/arm/

cp -p {start.sh,ngrok.cfg,bin/darwin_amd64/ngrok}   package/mac64/
cp -p {start.sh,ngrok.cfg,bin/darwin_386/ngrok}   package/mac32/

if [[ `uname -i` = "x86_64" ]];then
	cp {start.sh,ngrok.cfg,bin/ngrok}   package/linux64/
	cp {start.sh,ngrok.cfg,bin/linux_386/ngrok}   package/linux32/
else
	cp {start.sh,ngrok.cfg,bin/ngrok}   package/linux32/
	cp {start.sh,ngrok.cfg,bin/linux_amd64/ngrok}   package/linux64/
fi
cd package
for p in `ls`
do
	mv ${p} ngrok
	zip ${p}.zip ngrok/*
	rm -rf ngrok
done
cp * ${HOME}/
if grep -Eqi "release 5." /etc/redhat-release; then
	RHEL_Ver='5'
elif grep -Eqi "release 6." /etc/redhat-release; then
	RHEL_Ver='6'
elif grep -Eqi "release 7." /etc/redhat-release; then
	RHEL_Ver='7'
fi
case $RHEL_Ver in
	'5' | '6' )
		service iptables status | grep -E 'not running|未运行防火墙' &> /dev/null
		if [[ $? != 0 ]];then
			StandardOutput 'Iptables is running Config Firewalld now ...'
			/sbin/iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
			/sbin/iptables -A INPUT -i eth0 -p tcp --dport 443 -j ACCEPT
			/sbin/iptables -A INPUT -i eth0 -p tcp --dport 4443 -j ACCEPT
			/sbin/iptables -A INPUT -i eth0 -p tcp --dport 8080 -j ACCEPT
			/sbin/iptables-save
		fi
	;;
	'7' )
		if [[ `firewall-cmd --state` = 'running' ]];then
			StandardOutput 'Firewalld is running Config Firewalld now ...'
			firewall-cmd --add-service=http --permanent &> /dev/null
			firewall-cmd --add-port=443/tcp --permanent &> /dev/null
			firewall-cmd --add-port=4443/tcp --permanent &> /dev/null
			firewall-cmd --add-port=8080/tcp --permanent &> /dev/null
			firewall-cmd --reload &> /dev/null
		fi
	;;
esac

cat > /lib/systemd/system/ngrokd.service << EOF
[Unit]
Description=Ngrok Server
After=network.target

[Service]
Type=simple
# ExecStart=/usr/local/ngrok/bin/ngrokd -domain=$NGROK_DOMAIN -log /tmp/ngrokd/ngrokd.log
ExecStart=/usr/local/ngrok/bin/ngrokd -domain="$NGROK_DOMAIN" -tunnelAddr=":8080" -log /tmp/ngrokd/ngrokd.log
# ExecStart=/usr/local/ngrok/bin/ngrokd -domain="$NGROK_DOMAIN" -httpAddr=":8080" -httpsAddr=":6061" -tunnelAddr=":6062" -tlsKey=./device.key -tlsCrt=./device.crt
ExecStop=kill -9 \`ps -aux | egrep ngrokd | grep -v 'grep' | awk '{print \$2}'\`

[Install]
WantedBy=multi-user.target
EOF
[ -d /tmp/ngrokd/ ] || mkdir -p /tmp/ngrokd/
touch /tmp/ngrokd/ngrokd.log
systemctl daemon-reload
StandardOutput "------------------How to run the server-------------------"
StandardOutput "You can do it :"
StandardOutput "    systemctl start|stop|restart ngrokd.service"
StandardOutput "------------------How to run the client-------------------"
StandardOutput "You can do it :"
StandardOutput "    you can download the client by SFTP in the ${HOME}'home directory"
