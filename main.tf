terraform {
  required_version = "1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }

  # TODO: iac the backend s3 bucket
  backend "s3" {
    bucket       = "janice-zhong-terraform"
    key          = "terraform.state"
    use_lockfile = true
  }
}

provider "aws" {}