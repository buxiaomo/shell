#!/bin/bash
ZOOKEEPER_VERSION=3.4.10
KAFKA_VERSION=0.10.2.1
SCALA_VERSION=2.10

yum install java-1.8.0-openjdk.x86_64 -y

wget https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -O /usr/local/src/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
tar -zxf /usr/local/src/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /usr/local/src
mv /usr/local/src/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /usr/local/kafka

wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz -O /usr/local/src/zookeeper-${ZOOKEEPER_VERSION}.tar.gz
tar -zxf /usr/local/src/zookeeper-${ZOOKEEPER_VERSION}.tar.gz -C /usr/local/src
mv /usr/local/src/zookeeper-${ZOOKEEPER_VERSION} /usr/local/zookeeper

cat > /etc/profile.d/kafka.sh << EOF
export KAFKA_HOME=/usr/local/kafka
export PATH=\$PATH:\$KAFKA_HOME/bin
EOF
# 
cat > /etc/systemd/system/kafka.service << EOF
[Unit]
Description=Kafka
After=network.target
After=zookeeper.target

[Service]
Type=simple
ExecStart=/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/bin/kill -SIGTERM $MAINPID
RestartSec=15
SuccessExitStatus=0 143
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/zookeeper.service << EOF
[Unit]
Description=Zookeeper
After=network.target

[Service]
Type=forking
Restart=on-failure
WorkingDirectory=/usr/local/zookeeper/
ExecStart=/usr/local/zookeeper/bin/zkServer.sh start
ExecStop=/usr/local/zookeeper/bin/zkServer.sh stop
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/profile.d/zookeeper.sh << EOF
export ZOOKEEPER_HOME=/usr/local/zookeeper
export PATH=\$PATH:\$ZOOKEEPER_HOME/bin
EOF
systemctl daemon-reload
