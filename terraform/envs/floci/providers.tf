terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "floci_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3             = var.floci_endpoint
    ec2            = var.floci_endpoint
    iam            = var.floci_endpoint
    sts            = var.floci_endpoint
    ecs            = var.floci_endpoint
    ecr            = var.floci_endpoint
    rds            = var.floci_endpoint
    secretsmanager = var.floci_endpoint
    sns            = var.floci_endpoint
    cloudwatch     = var.floci_endpoint
    cloudwatchlogs = var.floci_endpoint
    efs            = var.floci_endpoint
    elbv2          = var.floci_endpoint
    autoscaling    = var.floci_endpoint
    ssm            = var.floci_endpoint
    cloudfront     = var.floci_endpoint
  }
}
