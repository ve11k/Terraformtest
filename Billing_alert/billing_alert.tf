resource "aws_cloudwatch_metric_alarm" "Billing_alert" {
  actions_enabled = true
  alarm_actions = [
    aws_sns_topic.billing_alerting_topic.arn
  ]
  alarm_description   = "AWSBilling"
  alarm_name          = "AWSBilling"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    "Currency" = "USD"
  }
  evaluate_low_sample_count_percentiles = null
  evaluation_periods                    = 1
  extended_statistic                    = null
  insufficient_data_actions             = []
  metric_name                           = "EstimatedCharges"
  namespace                             = "AWS/Billing"
  ok_actions                            = []
  period                                = 21600
  statistic                             = "Maximum"
  tags                                  = {}
  tags_all                              = {}
  threshold                             = 3
  threshold_metric_id                   = null
  treat_missing_data                    = "missing"
  unit                                  = null
}

resource "aws_sns_topic" "billing_alerting_topic" {
  name = "billing_alerting_topic"
}

resource "aws_sns_topic_subscription" "billing_alert_subscription" {
  topic_arn = aws_sns_topic.billing_alerting_topic.arn
  protocol = "email"
  endpoint = var.alert_subscription_email
}