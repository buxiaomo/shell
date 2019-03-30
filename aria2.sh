apt-get install aria2 -y


dir=/mnt/nfs/aria2
disk-cache=32M
continue=true
file-allocation=trunc
max-concurrent-downloads=5
max-connection-per-server=15
max-overall-download-limit=0
max-download-limit=0
max-overall-upload-limit=0
max-upload-limit=0
disable-ipv6=true
min-split-size=10M
split=10
input-file=/etc/aria2/aria2.session
save-session=/etc/aria2/aria2.session
save-session-interval=60
enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-listen-port=6800
rpc-secret=xiaomo
follow-torrent=true
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
bt-seed-unverified=true
bt-save-metadata=true

cat > /etc/systemd/system/aria2.service << EOF
[Unit]
Description=aria2
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/aria2c --conf-path=/etc/aria2/aria2.conf
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=15
SuccessExitStatus=0 143
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF