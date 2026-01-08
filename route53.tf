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

// Route53 records for API Gateway
resource "aws_route53_record" "api_a_record" {
  name    = aws_apigatewayv2_domain_name.api.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_aaaa_record" {
  name    = aws_apigatewayv2_domain_name.api.domain_name
  type    = "AAAA"
  zone_id = data.aws_route53_zone.primary.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = true
  }
}

// Route53 records for security certs
resource "aws_route53_record" "us_cert" {
  for_each = {
    for dvo in aws_acm_certificate.us_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

resource "aws_route53_record" "syd_cert" {
  for_each = {
    for dvo in aws_acm_certificate.syd_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}
