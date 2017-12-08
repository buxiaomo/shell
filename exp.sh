wget -O /tmp/speedtest https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
chmod +x /tmp/speedtest
python --version
D=$(/tmp/speedtest | grep Download | awk '{print $2}')
U=$(/tmp/speedtest | grep Upload | awk '{print $2}')
D=$(echo "${D} > 18.55" | bc)
U=$(echo "${U} > 19.55" | bc)
if [ ${D} -eq 1 -a ${U} -eq 1 ];then
  echo "OK"
fi
