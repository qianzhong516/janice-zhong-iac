terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }

  backend "s3" {
    bucket       = "janice-zhong-terraform"
    key          = "terraform.state"
    use_lockfile = true
  }
}

provider "aws" {}

resource "aws_s3_bucket" "janice-zhong-bucket" {
  bucket = "janice-zhong-1234"

  tags = {
    Name = "Janice Zhong Resume"
  }
}

resource "aws_s3_bucket_public_access_block" "unblock_bucket_public_access" {
  bucket = aws_s3_bucket.janice-zhong-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_views" {
  bucket     = aws_s3_bucket.janice-zhong-bucket.id
  policy     = data.aws_iam_policy_document.allow_public_views.json
  depends_on = [aws_s3_bucket_public_access_block.unblock_bucket_public_access]
}

data "aws_iam_policy_document" "allow_public_views" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.janice-zhong-bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "janice-zhong-website" {
  bucket = aws_s3_bucket.janice-zhong-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}