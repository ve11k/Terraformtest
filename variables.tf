variable "protocol" {
  type = string
  default = "tcp"
}
variable "region" {
  default = "us-east-1"
}
variable "region_zone" {
  default = "us-east-1a"
}
variable "test_key_pem" {
  description = "Private key in PEM format"
  type        = string
  sensitive   = true
}
variable "private_key_pem" {
  description = "Private key in PEM format"
  type        = string
  sensitive   = true
}
variable "test_public_key" {
  type = string
}
variable "private_public_key" {
  type = string
}
