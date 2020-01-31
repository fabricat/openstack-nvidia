#!/bin/bash
VERSION="0.18.1"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# inspired by https://devconnected.com/complete-node-exporter-mastery-with-prometheus/#a_Installing_the_Node_Exporter
cd /usr/local/src/
wget "https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz"
tar xvzf "node_exporter-${VERSION}.linux-amd64.tar.gz"
cp "node_exporter-${VERSION}.linux-amd64/node_exporter" /usr/local/bin/
useradd -rs /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter

tee /etc/systemd/system/node_exporter.service > /dev/null <<EOT
[Unit]
Description=Node Exporter for Prometheus monitoring
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.systemd --collector.filesystem.ignored-fs-types="^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs|tmpfs|fuse\\..+)$"

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start  node_exporter.service
systemctl status node_exporter.service --no-pager

