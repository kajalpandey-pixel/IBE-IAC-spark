provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket         = "booking-engine-terraform-state-spark"
    key            = "internet-booking-engine/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table-spark"
    encrypt        = true
    use_lockfile   = true
  }
}