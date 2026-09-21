terraform {
  required_version = ">= 1.10, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.66.0"
    }
  }

  backend "s3" {
    bucket       = "tc2-tfstate-394228349360-us-east-1"
    key          = "infrastructure/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["394228349360"]

  default_tags {
    tags = {
      Project   = "tech-challenge-2"
      ManagedBy = "Terraform"
    }
  }
}
