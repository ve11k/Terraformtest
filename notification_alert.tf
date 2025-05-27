resource "aws_sns_topic" "alerts" {
  name = "ec2-alerts-topic"
}

resource "aws_cloudwatch_metric_alarm" "alarm_public_cpu" {
  for_each = toset(aws_instance.web_test.id)

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
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "alarm_private_cpu" {
  for_each = toset(aws_instance.web_test_private.id)

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
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "alert_public_ram" {
  for_each = toset(aws_instance.web_test.id)

  alarm_name          = "HighRAM-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RAM > 80% for 5 minutes"
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "alert_private_ram" {
  for_each = toset(aws_instance.web_test_private)

  alarm_name          = "HighRAM-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RAM > 80% for 5 minutes"
  dimensions = {
    InstanceId = each.key
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alert_disk_public" {
  for_each = toset(aws_instance.web_test.id)

  alarm_name          = "HighDisk-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Disk > 85% for 5 minutes"
  dimensions = {
    InstanceId = each.key
    path       = "/"
    fstype     = "xfs" 
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "alert_disk_private" {
  for_each = toset(aws_instance.web_test_private)

  alarm_name          = "HighDisk-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Disk > 85% for 5 minutes"
  dimensions = {
    InstanceId = each.key
    path       = "/"
    fstype     = "xfs" 
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
