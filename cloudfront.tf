// use managed caching policy to avoid legacy settings 
// which prevents you from using a free plan
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "6.2.0"

  aliases = [local.full_domain]

  web_acl_id = var.web_acl_id

  # TODO: iac an s3 bucket for cloudfront logs
  #   logging_config = {
  #     bucket = "logs-my-cdn.s3.amazonaws.com"
  #   }

  origin = {
    s3_static_site = {
      domain_name = aws_s3_bucket_website_configuration.resume_website.website_endpoint
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
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

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  viewer_certificate = {
    acm_certificate_arn = aws_acm_certificate.us_cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = var.tags
}

