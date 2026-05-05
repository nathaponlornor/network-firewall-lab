terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-7"

  default_tags {
    tags = {
      Project     = "network-firewall-lab"
      Environment = "lab"
      ManagedBy   = "terraform"
    }
  }
}
