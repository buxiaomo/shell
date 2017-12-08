yum install python-pip -y
pip install shadowsocks setuptools
R=$(uname -r | awk -F '-' '{print $1}')
echo "3.7 ${R}" | awk '$1<$2' &> /dev/null
if [ $? -eq 0 ];then
    ssserver -s 0.0.0.0 -p 8388 -k xiaomo -m aes-256-cfb --workers 20 -d start
    echo "ssserver -s 0.0.0.0 -p 8388 -k xiaomo -m aes-256-cfb --workers 20 -d start" >> /etc/rc.local
else
    ssserver -s 0.0.0.0 -p 8388 -k xiaomo -m aes-256-cfb --workers 20 --fast-open -d start
    echo "ssserver -s 0.0.0.0 -p 8388 -k xiaomo -m aes-256-cfb --workers 20 --fast-open -d start" >> /etc/rc.local
fi
chmod +x /etc/rc.local
/sbin/iptables -I INPUT -p tcp --dport 8388 -j ACCEPT
/etc/rc.d/init.d/iptables save
