#!/bin/bash

if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [[ "$ID" == "amzn" || "$ID_LIKE" == *"rhel"* ]]; then
    yum install -y amazon-cloudwatch-agent
  elif [[ "$ID" == "ubuntu" ]]; then
    apt update && apt install -y amazon-cloudwatch-agent
  fi
fi

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ],
        "ignore_file_system_types": ["sysfs", "tmpfs", "devtmpfs"]
      }
    },
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    }
  }
}
EOF


/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s