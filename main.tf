terraform {
  required_version = "1.14.3"

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
  bucket = "janice-zhong"

  tags = {
    Name    = "Janice Zhong Resume"
    Project = "janice-zhong-resume"
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

// use managed caching policy to avoid legacy settings 
// which prevents you from using a free plan
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "6.2.0"


  aliases = ["janice-zhong.com"]

 # explicitly set it to prevent `t apply` errors
  web_acl_id = "arn:aws:wafv2:us-east-1:077437902719:global/webacl/CreatedByCloudFront-52c77c23/20434394-6259-4c4d-a54c-9ee46d7c0577"

  # TODO: set up an s3 bucket for cloudfront logs
  #   logging_config = {
  #     bucket = "logs-my-cdn.s3.amazonaws.com"
  #   }

  origin = {
    s3_static_site = {
      # TODO: change it to an s3 variable
      domain_name = "janice-zhong.s3-website-ap-southeast-2.amazonaws.com"
      custom_origin_config = {
        http_port              = 80
        https_port =  443
        origin_protocol_policy = "http-only"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_static_site"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:077437902719:certificate/a92c8ee0-dafe-4535-a720-a6fb21ae69d0"
    ssl_support_method  = "sni-only"
  }

  #TODO: add tags
}

# Route53 records for CloudFront
resource "aws_route53_record" "cloudfront_a_record" {
  zone_id = "Z04471721VKE0KNBKW8MR"
  name    = "janice-zhong.com"
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cloudfront_aaaa_record" {
  zone_id = "Z04471721VKE0KNBKW8MR"
  name    = "janice-zhong.com"
  type    = "AAAA"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}