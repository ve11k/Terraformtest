/*resource "aws_cloudwatch_metric_alarm" "mybilling_import" {
  actions_enabled = true
  alarm_actions = [
    "arn:aws:sns:us-east-1:361769593086:Billing_monitor",
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

}*/