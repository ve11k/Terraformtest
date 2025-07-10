terraform {
  backend "s3" {
    bucket = "buckettest2875"
    key    = "testterraform/terraform.tfstate"
    region = "us-east-1"
  }
}