resource "aws_sns_topic" "alerts" {
  name = "ec2-alerts-topic"
}
locals {
  instance = {
    web_test         = aws_instance.web_test.id,
    web_test_private = aws_instance.web_test_private.id
  }
}
resource "aws_cloudwatch_metric_alarm" "alarm_cpu" {
  for_each = local.instance

  alarm_name          = "HighCPU-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU > 80% for 5 minutes"
  dimensions = {
    InstanceId = each.value
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alert_ram" {
  for_each = local.instance

  alarm_name          = "HighRAM-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 8
  alarm_description   = "RAM > 8% for 5 minutes"
  dimensions = {
    InstanceId = each.value
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alert_disk" {
  for_each = local.instance

  alarm_name          = "HighDisk-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Disk > 5% for 5 minutes"
  dimensions = {
    InstanceId = each.value
    path       = "/"
    fstype     = "ext4"
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
