terraform {
  required_version = "1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }

  # HCP terraform CLI integration
  cloud {
    organization = "janice-zhong"

    workspaces {
      project = "AWS"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "dns"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::077437902719:role/AllowCrossAccountRoute53Changes"
  }
}