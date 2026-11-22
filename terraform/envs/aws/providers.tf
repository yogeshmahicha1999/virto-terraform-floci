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

  # PROPOSED (real AWS me enable karna hai): remote state, encrypted + locking
  # backend "s3" {
  #   bucket         = "<org>-virto-tfstate"
  #   key            = "virto/aws/terraform.tfstate"
  #   region         = "ap-south-1"
  #   encrypt        = true
  #   dynamodb_table = "virto-tfstate-lock"
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "virto-commerce"
      ManagedBy = "terraform"
    }
  }
}
