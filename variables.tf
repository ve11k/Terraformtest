variable "protocol" {
  type    = string
  default = "tcp"
}
variable "region" {
  default = "us-east-1"
}
variable "region_zone" {
  default = "us-east-1a"
}
variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog App Key"
  type        = string
  sensitive   = true
}
