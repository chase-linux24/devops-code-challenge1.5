terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "devops-code-challenge1.5"
    }
  }
}

# Retrieves current AWS account ID dynamically
data "aws_caller_identity" "current" {}

# Retrieves current AWS region dynamically
data "aws_region" "current" {}