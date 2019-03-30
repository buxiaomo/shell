[Unit]
Description=Frp Server
Documentation=https://github.com/fatedier/frp
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frpc -c /usr/local/etc/frpc.ini
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=15
Restart=on-failure

[Install]
WantedBy=multi-user.target