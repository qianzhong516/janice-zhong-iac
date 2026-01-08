# Fetch the domain's zone id
data "aws_route53_zone" "primary" {
  name         = local.full_domain
  private_zone = false
}

# Route53 records for CloudFront
resource "aws_route53_record" "cloudfront_a_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.full_domain
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cloudfront_aaaa_record" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.full_domain
  type    = "AAAA"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}