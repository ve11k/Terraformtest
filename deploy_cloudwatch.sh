#!/bin/bash

set -e  # Зупинити скрипт при будь-якій помилці

# Визначення дистрибутива
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_FAMILY="$ID"
  OS_LIKE="$ID_LIKE"
else
  echo "Неможливо визначити ОС"
  exit 1
fi

# Встановлення CloudWatch Agent
install_agent() {
  if [[ "$OS_FAMILY" == "amzn" || "$OS_LIKE" == *"rhel"* ]]; then
    sudo yum install -y wget
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -O /tmp/amazon-cloudwatch-agent.rpm
    sudo rpm -U /tmp/amazon-cloudwatch-agent.rpm
  elif [[ "$OS_FAMILY" == "ubuntu" ]]; then
    sudo apt update
    sudo apt install -y wget
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
    sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb
  else
    echo "ОС не підтримується для автоматичної інсталяції агента"
    exit 1
  fi
}

install_agent

# Створення конфігурації
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [ "mem_used_percent" ]
      },
      "disk": {
        "measurement": [ "disk_used_percent" ],
        "resources": [ "/" ],
        "ignore_file_system_types": [ "sysfs", "tmpfs", "devtmpfs" ]
      }
    },
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    }
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a stop

# Запуск агента
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s