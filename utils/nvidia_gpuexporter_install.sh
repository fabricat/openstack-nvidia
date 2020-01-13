#!/bin/bash

### see https://github.com/mindprince/nvidia_gpu_prometheus_exporter

test -z $(find /var/lib/apt/periodic/update-success-stamp -ctime -1 2>/dev/null) && sudo apt-get update
sudo apt-get install -y golang-go
go get github.com/mindprince/nvidia_gpu_prometheus_exporter
sudo cp ${HOME}/go/bin/nvidia_gpu_prometheus_exporter /usr/local/bin/

sudo tee /etc/systemd/system/nvidia_gpu_prometheus_exporter.service > /dev/null <<EOT
[Unit]
Description=Nvidia GPU Exporter for Prometheus monitoring
After=network-online.target

[Service]
User=nobody
Group=nogroup
Type=simple
ExecStart=/usr/local/bin/nvidia_gpu_prometheus_exporter

[Install]
WantedBy=multi-user.target

EOT

sudo systemctl daemon-reload
sudo systemctl enable nvidia_gpu_prometheus_exporter.service
sudo systemctl start  nvidia_gpu_prometheus_exporter.service
sudo systemctl status nvidia_gpu_prometheus_exporter.service

